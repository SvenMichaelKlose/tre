;;;; TRE environment
;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Primitive functions directly assigned to atoms without.

(setq *universe* (cons 'not
                 (cons 'last
                 (cons '%nconc
                 (cons 'copy-tree
				 (cons '*variables* *universe*))))))

(setq *variables* (cons (cons '*show-definitions* nil)
						nil))

;;; Helper functions (helping us to stay sane).

(%set-atom-fun not
  #'((x)
	   (if x
		   nil
		   t)))

(%set-atom-fun copy-tree
  #'((x)
    (if x
		(if (atom x)
            x
        	(cons (copy-tree (car x))
              	  (copy-tree (cdr x)))))))

(%set-atom-fun last
  #'((x)
    (if x
		(if (cdr x)
            (last (cdr x))
            x))))

(%set-atom-fun %nconc
  #'((a b)
    (if a
        (progn
		  (rplacd (last a) b)
    	  a)
		b)))
