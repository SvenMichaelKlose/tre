;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun two-subsequent-tags? (a d)
  (& a (atom a)
     d. (atom d.)))

(defun opt-peephole-has-no-jumps-to (x tag)
  (dolist (i x t)
    (& (vm-jump? i)
       (== (%%go-tag i) tag)
       (return nil))))

(defun opt-peephole-tags-lambda (x)
  (with (body x
		 spare-tags (find-all-if [opt-peephole-has-no-jumps-to body _]
		  				         (find-all-if #'number? x)))
    (remove-if [member _ spare-tags :test #'eq] x)))

(defun opt-peephole-remove-spare-tags-body (x)
  (copy-lambda x :body (opt-peephole-remove-spare-tags (opt-peephole-tags-lambda (lambda-body x)))))

(defun opt-peephole-remove-spare-tags (x)
  (with-cons a d x
	 (cons (?
	  		 (named-lambda? a)       (opt-peephole-remove-spare-tags-body a)
	  		 (& (%setq? a)
	  	   	    (lambda? ..a.)) `(%setq ,.a. ,(opt-peephole-remove-spare-tags-body ..a.))
			 a)
		   (opt-peephole-remove-spare-tags d))))
   
(defun opt-peephole (statements)
  (with
	  (removed-tags nil
       replace-tag
         #'((old-dest new-dest)
			  (= removed-tags (filter [? (eq ._ old-dest)
                                         (cons _. new-dest)
                                         _]
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
    		    (& (number? a)
                   (%%go? d.))
                  (progn
                    (add-removed-tag a (cadr d.))
				    (reduce-tags d))))

       translate-tags
		 [maptree [!? (assoc _ removed-tags :test #'eq)
                      .!
                      _]
                  _]
	   rec
		 [funcall (compose #'opt-peephole-remove-void
                           #'opt-peephole-remove-%%go-nil-heads
                           #'opt-peephole-rename-temporaries
                           #'opt-peephole-remove-code
                           #'opt-peephole-remove-assignments
                           #'opt-peephole-remove-identity
                           #'opt-peephole-remove-spare-tags
                           #'translate-tags
                           #'reduce-tags)
                  _])
  (? *opt-peephole?*
     (with-temporaries (*funinfo* (transpiler-global-funinfo *transpiler*)
                        *body*    statements)
       (repeat-while-changes #'rec statements))
     statements)))
