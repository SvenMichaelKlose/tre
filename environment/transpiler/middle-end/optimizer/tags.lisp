;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun two-subsequent-tags? (a d)
  (& a (atom a)
     d. (atom d.)))

(defun has-no-jumps-to (x tag)
  (dolist (i x t)
    (& (vm-jump? i)
       (== (%%go-tag i) tag)
       (return nil))))

(defun tags-lambda (x)
  (with (body x
		 spare-tags (remove-if-not [has-no-jumps-to body _]
		  				           (remove-if-not #'number? x)))
    (remove-if [member _ spare-tags] x)))

(defun remove-spare-tags-body (x)
  (copy-lambda x :body (remove-spare-tags (tags-lambda (lambda-body x)))))

(defun remove-spare-tags (x)
  (with-cons a d x
	 (. (? (named-lambda? a)
           (remove-spare-tags-body a)
           a)
		(remove-spare-tags d))))
   
(defun optimize-tags (statements)
  (with (removed-tags nil
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
			    (optimizer reduce-tags
    		      (two-subsequent-tags? a d)
                    (progn
				      (add-removed-tag a d.)
				      (reduce-tags d))
    		      (& (number? a)
                     (%%go? d.))
                    (progn
                      (add-removed-tag a (%%go-tag d.))
				      (reduce-tags d))))

         translate-tags
		   [maptree [!? (assoc _ removed-tags)
                        .!
                        _]
                    _])
    (remove-spare-tags (translate-tags (reduce-tags statements)))))
