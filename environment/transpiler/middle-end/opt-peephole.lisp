;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defvar *opt-peephole?* t)
(defvar *opt-peephole-funinfo* nil)
(defvar *opt-peephole-body* nil)

(defmacro opt-peephole-rec (a d val fun name &optional (setq? nil))
  `(with (plc (when (%setq? ,a)
			    (%setq-place ,a))
		  body (lambda-body ,val))
     (let f (copy-lambda ,val
                         :name ,name
                         :body (with-temporary *opt-peephole-body* body
                                 (with-temporary *opt-peephole-funinfo* (get-lambda-funinfo ,val)
                                   (,fun body))))
       (cons ,(? setq?
	            '`(%setq ,plc ,f)
			    'f)
		     (,fun ,d)))))

(defmacro opt-peephole-fun (fun &rest body)
  `(when x
	 (with-cons a d x
	   (?
		 (named-lambda? a) (opt-peephole-rec a d ..a. ,fun .a.)
		 (%setq-named-lambda? a) (opt-peephole-rec a d (caddr (%setq-value a)) ,fun (cadr (%setq-value a)) t)
		 (%setq-lambda? a) (opt-peephole-rec a d (%setq-value a) ,fun nil t)
		 ,@body
		 t (cons a (,fun d))))))

(defmacro def-opt-peephole-fun (name &rest body)
  `(defun ,name (x)
     (opt-peephole-fun ,name
       ,@body)))

(defun assignment-of-identity? (a)
  (and (%setq? a)
	   (identity? ..a.)))

(def-opt-peephole-fun opt-peephole-remove-identity
  (assignment-of-identity? a)
    (cons `(%setq ,.a. ,(cadr ..a.))
	      (opt-peephole-remove-identity d)))

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
(def-opt-peephole-fun opt-peephole-remove-void
  (void-assignment? a) (opt-peephole-remove-void d)
  (reversed-assignments? a d) (cons a (opt-peephole-remove-void .d))
  (jump-to-following-tag? a d) (opt-peephole-remove-void d)
  ; Remove code after label until next tag.
  (%%vm-go? a) (cons a (opt-peephole-remove-void (opt-peephole-find-next-tag d))))

(defun %setq-on? (x plc)
  (and (%setq? x)
       (eq (%setq-place x) plc)))

(defun opt-peephole-tag-code (tag)
  (member tag *opt-peephole-body* :test #'eq))

(defun opt-peephole-will-be-used-again? (x v)
  (with (traversed-tags nil
         traverse-tag #'((tag v)
                          (aif (opt-peephole-tag-code tag)
                               (unless (member tag traversed-tags :test #'eq)
                                 (push tag traversed-tags)
                                 (rec .! v))
                               (progn
                                 (print *opt-peephole-body*)
                                 (print tag)
                                 (error "no tag"))))
         rec #'((x v)
                 (with (a x.
                        d .x)
                   (?
	                 (not x) (~%ret? v)
	                 (atom x) (error "illegal meta-code: statement expected")
	                 (lambda? a) (rec d v)
                     (%%vm-go? a) (traverse-tag .a. v)
                     (%setq-on? a v) (find-tree (%setq-value a) v :test #'eq)
                     (find-tree a v :test #'eq) t
                     (vm-conditional-jump? a) (or (traverse-tag ..a. v)
                                                  (rec d v))
                     (rec d v)))))
    (or (eq *opt-peephole-funinfo* (transpiler-global-funinfo *current-transpiler*))
        (and (not (~%ret? v))
             (transpiler-defined-variable *current-transpiler* v))
        (funinfo-immutable? *opt-peephole-funinfo* v)
        (rec x v))))

(defun removable-place? (x)
  (and x (atom x)
       (funinfo-in-env? *opt-peephole-funinfo* x)
       (not (eq x (funinfo-lexical *opt-peephole-funinfo*)))
       (not (funinfo-lexical? *opt-peephole-funinfo* x))))

(defun assignment-to-unused-place? (a d)
  (and (%setq? a)
       (removable-place? (%setq-place a))
       (not (opt-peephole-will-be-used-again? d (%setq-place a)))))

(defun assignment-to-unneccessary-temoporary? (a d)
  (and d
	   (%setq? a)
	   (%setq? d.)
	   (let-when plc (%setq-place a)
		 (and (eq plc (%setq-value d.))
 			  (removable-place? plc)
			  (not (opt-peephole-will-be-used-again? .d plc))))))

(defun two-subsequent-tags? (a d)
  (and a (atom a)
       d. (atom d.)))

(defun vm-go-nil-head? (a d)
  (and d
       (%setq? a)
       (atom (%setq-value a))
       (%%vm-go-nil? d.)
       (let plc (%setq-place a)
         (and (eq plc (cadr d.))
              (removable-place? plc)
              (not (opt-peephole-will-be-used-again? (opt-peephole-tag-code (caddr d.)) plc))
              (not (opt-peephole-will-be-used-again? .d plc))))))

(defun assignment-to-symbol? (x)
  (and (%setq? x)
       (awhen (%setq-place x)
         (atom !))))

(def-opt-peephole-fun opt-peephole-not
  (and (%setq? a)
       (eq t (%setq-value a))
       (%%vm-go-nil? d.)
       (with (tag (caddr d.)
              val (cadr d.)
              flag (%setq-place a))
         (and (removable-place? flag)
              (%setq-on? .d. flag)
              (not (%setq-value .d.))
              (eq tag ..d.)
              (%%vm-go-nil? ...d.)
              (eq flag (cadr ...d.))
              (not (opt-peephole-will-be-used-again? (opt-peephole-tag-code (caddr ...d.)) flag))
              (not (opt-peephole-will-be-used-again? ....d flag)))))
    `((%vm-go-not-nil ,(cadr d.) ,(caddr ...d.))))

(def-opt-peephole-fun opt-peephole-rename-temporaries
  (and (assignment-to-symbol? a)
       (%setq? d.)
       (with (plc (%setq-place a)
              val (%setq-value d.))
         (and (not (in? plc '~%ret '~%tmp))
              (cons? val)
              (removable-place? plc)
              (find-tree .val plc :test #'eq)
              (or (eq (%setq-place d.) plc)
                  (not (opt-peephole-will-be-used-again? .d plc))))))
    (with (plc (%setq-place a)
           val (%setq-value d.)
           fi *opt-peephole-funinfo*)
      (funinfo-env-adjoin fi '~%tmp)
      `((%setq ~%tmp ,(%setq-value a))
        (%setq ,(%setq-place d.) ,(replace-tree plc '~%tmp val :test #'eq))
        ,@(opt-peephole-rename-temporaries .d))))

(def-opt-peephole-fun opt-peephole-remove-code
  (assignment-to-unused-place? a d)
	(? (atomic-or-functional? (%setq-value a))
  	   (opt-peephole-remove-code d)
  	   (cons `(%setq nil ,(%setq-value a))
	         (opt-peephole-remove-code d))))

(def-opt-peephole-fun opt-peephole-remove-assignments
  (assignment-to-unneccessary-temoporary? a d)
	(let plc (%setq-place a)
	  (cons `(%setq ,(%setq-place d.) ,(%setq-value a))
	        (opt-peephole-remove-assignments .d))))

(def-opt-peephole-fun opt-peephole-remove-vm-go-nil-heads
  (vm-go-nil-head? a d)
    (cons `(%%vm-go-nil ,(%setq-value a) ,(caddr d.))
          (opt-peephole-remove-vm-go-nil-heads .d)))

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
	  		(named-lambda? x.) (opt-peephole-remove-spare-tags-body x.)
	  		(and (%setq? x.)
	  	   		 (lambda? (caddr x.))) `(%setq ,(cadr x.) ,(opt-peephole-remove-spare-tags-body (caddr x.)))
			x.)
		  (opt-peephole-remove-spare-tags .x))))
   
(defun opt-peephole (statements)
  (with
	  (removed-tags nil
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
			  (opt-peephole-fun reduce-tags
    		    (two-subsequent-tags? a d)
                  (progn
				    (add-removed-tag a d.)
				    (reduce-tags d))
    		    (and (number? a)
                     (%%vm-go? d.))
                  (progn
                    (add-removed-tag a (cadr d.))
				    (reduce-tags d))))

       translate-tags
		 #'((x)
    		 (maptree (fn aif (assoc _ removed-tags :test #'eq)
                              .!
                              _)
                      x))
	   rec
		 #'((x)
             (funcall (compose #'translate-tags
                               #'reduce-tags
                               #'opt-peephole-remove-vm-go-nil-heads
                               #'opt-peephole-rename-temporaries
			                   #'opt-peephole-remove-spare-tags
				               #'opt-peephole-remove-code
				               #'opt-peephole-remove-assignments
				               #'opt-peephole-remove-void
				               ;#'opt-peephole-not
                               )
				      x)))
      (? *opt-peephole?*
	       (with-temporary *opt-peephole-funinfo* (transpiler-global-funinfo *current-transpiler*)
             (with-temporary *opt-peephole-body* statements
	           (repeat-while-changes #'rec
		         (opt-peephole-remove-identity statements))))
         statements)))
