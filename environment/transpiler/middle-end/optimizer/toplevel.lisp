;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun two-subsequent-tags? (a d)
  (and a (atom a)
       d. (atom d.)))

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
				               #'opt-peephole-remove-void)
				      x)))
      (? *opt-peephole?*
	       (with-temporary *opt-peephole-funinfo* (transpiler-global-funinfo *current-transpiler*)
             (with-temporary *opt-peephole-body* statements
	           (repeat-while-changes #'rec
		         (opt-peephole-remove-identity statements))))
         statements)))
