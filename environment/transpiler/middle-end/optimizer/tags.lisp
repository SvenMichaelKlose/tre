(fn two-subsequent-tags? (a d)
  (& a (atom a)
     d. (atom d.)))

(fn has-no-jumps-to? (x tag)
  (@ (i x t)
    (& (vm-jump? i)
       (== (%%go-tag i) tag)
       (return nil))))

(fn tags-lambda (x)
  (with (body        x
		 spare-tags  (remove-if-not [has-no-jumps-to? body _]
		  				            (remove-if-not #'number? x)))
    (remove-if [member _ spare-tags] x)))

(fn remove-spare-tags-body (x)
  (copy-lambda x :body (remove-spare-tags (tags-lambda (lambda-body x)))))

(fn remove-spare-tags (x)
  (with-cons a d x
	 (. (? (named-lambda? a)
           (remove-spare-tags-body a)
           a)
		(remove-spare-tags d))))
   
(fn optimize-tags (statements)
  (with (removed-tags nil
         replace-tag
           #'((old-dest new-dest)
			    (= removed-tags (@ [? (eq ._ old-dest)
                                      (. _. new-dest)
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
                    {(add-removed-tag a d.)
				     (reduce-tags d)}
    		      (& (number? a)
                     (%%go? d.))
                    {(add-removed-tag a (%%go-tag d.))
				     (reduce-tags d)}))

         translate-tags
                    ; XXX [| (assoc-value _ removed-tags) _]
		   [maptree [!? (assoc _ removed-tags)
                        .!
                        _]
                    _])
    (remove-spare-tags (translate-tags (reduce-tags statements)))))
