;;;;; TRE compiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defvar *opt-peephole?* t)
(defvar *opt-peephole-funinfo* nil)
(defvar *opt-peephole-symbols* (make-hash-table :test #'eq))

(defun opt-peephole-collect-syms-0 (x h)
  (?
    (symbol? x) (setf (href h x) (1+ (or (href h x) 0)))
    (atom x) nil
    (progn
      (opt-peephole-collect-syms-0 x. h)
      (opt-peephole-collect-syms-0 .x h))))

;(metacode-walker opt-peephole-collect-syms-0 (x h)
;:traverse?	t
;   :if-symbol	(setf (href h x) (1+ (or (href h x) 0)))
;:if-function (opt-peephole-collect-syms-0 (%setq-place x) h))

(defun opt-peephole-collect-syms (x)
  (let h (make-hash-table :test #'eq)
	(opt-peephole-collect-syms-0 x h)
	h))

(defun opt-peephole-uncollect-syms-0 (x num h)
  (?
    (symbol? x) (when (href h x)
                  (setf (href h x) (- (href h x) num)))
    (atom x) nil
    (progn
      (opt-peephole-uncollect-syms-0 x. num h)
      (opt-peephole-uncollect-syms-0 .x num h))))

;(metacode-walker opt-peephole-uncollect-syms-0 (x num)
;	:traverse?	t
;    :if-symbol	(setf (href *opt-peephole-symbols* x) (- (href *opt-peephole-symbols* x) 1))
;	:if-function (opt-peephole-uncollect-syms-0 (%setq-place x) num))

(defun opt-peephole-uncollect-syms (x ret num)
  (opt-peephole-uncollect-syms-0 x num *opt-peephole-symbols*)
  ret)

(defun opt-peephole-count (x)
  (or (href *opt-peephole-symbols* x) 0))

(defvar *opt-peephole-body* nil)

(defun opt-peephole-rec (a d val fun name collect-symbols &optional (setq? nil))
  (with (plc (when (%setq? a)
			   (%setq-place a))
		 body (lambda-body val))
	(with-temporary *opt-peephole-body* body
	  (with-temporary *opt-peephole-funinfo* (get-lambda-funinfo val)
	    (with-temporary *opt-peephole-symbols* (? collect-symbols
									              (opt-peephole-collect-syms body)
										          *opt-peephole-symbols*)
          (let f (copy-lambda val :name name :body (funcall fun body))
	        (cons (? setq?
				     `(%setq ,plc ,f)
				     f)
		          (funcall fun d))))))))

(defmacro opt-peephole-fun ((fun &key (collect-symbols nil)) &rest body)
  `(when x
	 (with-cons a d x
	   (?
		 (named-lambda? a) (opt-peephole-rec a d ..a. ,fun .a. ,collect-symbols)

		 (and (%setq? a)
			  (named-lambda? (%setq-value a)))
		   (opt-peephole-rec a d (caddr (%setq-value a)) ,fun (cadr (%setq-value a)) ,collect-symbols t)

		 (and (%setq? a)
			  (lambda? (%setq-value a)))
		   (opt-peephole-rec a d (%setq-value a) ,fun nil ,collect-symbols t)

	   	 (cond
		   ,@body
		   (t (cons a (funcall ,fun d))))))))

(defun opt-peephole-has-no-jumps-to (x tag)
  (dolist (i x t)
	(when (vm-jump? i)
	  (when (= (vm-jump-tag i) tag)
		(return nil)))))

(defun opt-peephole-tags-lambda (x)
  (with (body x
		 spare-tags (find-all-if (fn opt-peephole-has-no-jumps-to body _)
		  				         (find-all-if #'number? x)))
    (remove-if (fn member _ spare-tags :test #'eq) x)))

(defun opt-peephole-remove-spare-tags-body (x)
  (copy-lambda x :body (opt-peephole-remove-spare-tags (opt-peephole-tags-lambda (lambda-body x)))))

(defun opt-peephole-remove-spare-tags (x)
  (when x
	(cons (?
	  		(named-lambda? x.)
			  (opt-peephole-remove-spare-tags-body x.)

	  		(and (%setq? x.)
	  	   		 (lambda? (caddr x.)))
	      	  `(%setq ,(cadr x.) ,(opt-peephole-remove-spare-tags-body (caddr x.)))

			x.)
		  (opt-peephole-remove-spare-tags .x))))

(defun assignment-of-identity? (a)
  (and (%setq? a)
	   (identity? ..a.)))

(defun opt-peephole-remove-identity (x)
  (opt-peephole-fun (#'opt-peephole-remove-identity)
      ((assignment-of-identity? a)
	     (cons `(%setq ,.a. ,(cadr ..a.))
			   (opt-peephole-remove-identity d)))))

(defun opt-peephole-find-next-tag (x)
  (when x
	(? (atom x.)
	   x
	   (opt-peephole-find-next-tag .x))))

(defun void-assignment? (a)
  (and (%setq? a)
	   (eq .a. ..a.)))

(defun reversed-assignments? (a d)
  (let n d
    (and (%setq? a)
	     (%setq? n)
         .a.
	     (atom .a.)
	     (eq .a. (caddr n))
	     (eq (cadr n) ..a.))))

(defun jump-to-following-tag? (a d)
  (and d (vm-jump? a)
       (? (%%vm-go? a)
          (eq .a. d.)
          (eq ..a. d.))))

;; Remove unreached code or code that does nothing.
(defun opt-peephole-remove-void (x)
  (opt-peephole-fun (#'opt-peephole-remove-void)
	  ((void-assignment? a) (opt-peephole-remove-void d))
	  ((reversed-assignments? a d) (cons a (opt-peephole-remove-void .d)))
	  ((jump-to-following-tag? a d) (opt-peephole-remove-void d))
	  ; Remove code after label until next tag.
	  ((%%vm-go? a) (cons a (opt-peephole-remove-void (opt-peephole-find-next-tag d))))))

(defun %setq-on? (x plc)
  (and (%setq? x)
       (eq (%setq-place x) plc)))

(defun opt-peephole-will-be-used-again? (x v)
  (with (traversed-tags nil
         rec #'((x v)
                 (?
	               (not x) (~%ret? v)	; End of block always returns ~%RET.
	               (atom x)	(error "illegal meta-code: statement expected")
	               (lambda? x.)	(rec .x v)
                   (%%vm-go? x.) (let tag (cadr x.)
                                   (aif (member tag *opt-peephole-body* :test #'eq)
                                        (unless (member tag traversed-tags :test #'eq)
                                            (progn
                                              (push tag traversed-tags)
                                              (rec .! v)))
                                        t));(error "tag missing")))
                   (%setq-on? x. v) (find-tree (%setq-value x.) v :test #'eq)
                   (find-tree x. v :test #'eq) t
                   (vm-jump? x.) t
                   (rec .x v))))
    (or (and (not (~%ret? v))
             (transpiler-defined-variable *current-transpiler* v))
        (funinfo-immutable? *opt-peephole-funinfo* v)
        (rec x v))))

(defun removable-place? (x)
  (and x (atom x)
       (funinfo-in-env? *opt-peephole-funinfo* x)
       (not (eq x (funinfo-lexical *opt-peephole-funinfo*)))
       (not (funinfo-lexical? *opt-peephole-funinfo* x))))

(defun assignment-to-unused-place (a d)
  (and (%setq? a)
       (removable-place? (%setq-place a))
	   (or (and (not (~%ret? (%setq-place a)))
			    (integer= 1 (opt-peephole-count (%setq-place a))))
           (not (opt-peephole-will-be-used-again? d (%setq-place a))))))

(defun assignment-to-unneccessary-temoporary? (a d)
  (and d
	   (%setq? a)
	   (%setq? d.)
	   (let plc (%setq-place a)
		 (and plc (eq plc (%setq-value d.))
 			  (removable-place? plc)
			  (or (and (integer= 2 (opt-peephole-count plc))
                       (not (~%ret? plc)))
				  (not (opt-peephole-will-be-used-again? .d plc)))))))

(defun two-subsequent-tags? (a d)
  (and a (atom a)
       d. (atom d.)))

(defun vm-go-nil-head? (a d)
  (and d
       (%setq? a)
       (atom (%setq-value a))
       (eq '~%ret (%setq-place a))
       (%%vm-go-nil? d.)
       (eq '~%ret (cadr d.))))

(defun opt-peephole (statements)
  (with
	  (fnord nil
	   removed-tags nil

	   ; Remove code without side-effects whose result won't be used.
	   remove-code
	     #'((x)
			  (opt-peephole-fun (#'remove-code :collect-symbols t)
				((assignment-to-unused-place a d)
				   (? (atomic-or-without-side-effects? (%setq-value a))
			  		  (opt-peephole-uncollect-syms a (remove-code d) 1)
			  		  (opt-peephole-uncollect-syms (%setq-place a) (let v (%setq-value a)
                                                                     (? (or (atom v)
                                                                            (functional? v.))
                                                                         (remove-code d)
                                                                         (cons `(%setq nil ,v)
							                                                   (remove-code d))))
                                                   1)))))

	   remove-assignments
	     #'((x)
			  (opt-peephole-fun (#'remove-assignments :collect-symbols t)
			    ((assignment-to-unneccessary-temoporary? a d)
				   (let plc (%setq-place a)
				     (opt-peephole-uncollect-syms plc (cons `(%setq ,(%setq-place d.) ,(%setq-value a))
								                            (remove-assignments .d))
                                                  2)))))

	   remove-vm-go-nil-heads
	     #'((x)
			  (opt-peephole-fun (#'remove-vm-go-nil-heads)
			    ((vm-go-nil-head? a d)
				   (cons `(%%vm-go-nil ,(%setq-value a) ,(caddr d.))
				          (remove-vm-go-nil-heads .d)))))

       replace-tag
         #'((old-dest new-dest)
			 (setf removed-tags (filter (fn ? (eq ._ old-dest)
                                              (cons _. new-dest)
                                              _)
                                        removed-tags)))

       add-removed-tag
         #'((old-tag new-tag)
			 (replace-tag old-tag new-tag)
		     (acons! old-tag new-tag removed-tags))

	   reduce-tags
		 #'((x)
			  (opt-peephole-fun (#'reduce-tags)
    		    ((two-subsequent-tags? a d)
				   (add-removed-tag a .x.)
				   (reduce-tags d))
    		    ((and (number? a)
                      (%%vm-go? .x.))
                   (add-removed-tag a (cadr d.))
				   (reduce-tags d))))

	   rec
		 #'((x)
			  (maptree #'((x)
			                (aif (assoc x removed-tags :test #'eq)
				                 .!
					             x))
					   (funcall
						 (compose ;#'remove-vm-go-nil-heads
                                  #'reduce-tags
								  #'opt-peephole-remove-spare-tags
								  #'remove-code
								  #'remove-assignments
								  #'opt-peephole-remove-void)
						 x))))
      (? *opt-peephole?*
	     (with-temporary *opt-peephole-funinfo* (transpiler-global-funinfo *current-transpiler*)
	       (repeat-while-changes #'rec
		     (opt-peephole-remove-identity statements)))
         statements)))
