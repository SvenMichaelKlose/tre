;;;; TRE environment
;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Primitive functions directly assigned to atoms without.

(setq *universe* (cons 'not
                 (cons 'last
                 (cons '%nconc
                 (cons 'copy-tree
				 (cons '*variables* *universe*))))))

(setq *variables* (cons (cons '*variables* nil)
				  (cons (cons '*universe* nil)
				  (cons (cons '*keyword-package* nil)
				  (cons (cons '*show-definitions* nil)
				  (cons (cons '*environment-path* nil)
				  (cons (cons '*endianess* nil)
				  (cons (cons '*pointer-size* nil)
				  (cons (cons '*cpu-type* nil)
				  (cons (cons '*libc-path* nil)
				  (cons (cons '*have-environment-tests* nil)
						nil)))))))))))

;;; Helper functions (helping us to stay sane).

;tredoc
; "Returns T if argument is not NIL."
; (returns :type boolean)
(%set-atom-fun not
  #'((x)
	   (if x
		   nil
		   t)))

;tredoc
; "Copies a tree of cells without copying atoms."
; (returns :type boolean)
(%set-atom-fun copy-tree
  #'((x)
    (if x
		(if (atom x)
            x
        	(cons (copy-tree (car x))
              	  (copy-tree (cdr x)))))))

;tredoc
; (arg :type list)
; (returns :type list "Last cell of a list.")
(%set-atom-fun last
  #'((x)
    (if x
		(if (cdr x)
            (last (cdr x))
            x))))

;tredoc
; (args :type list)
; "Destructively concatenates its arguments."
; (returns :type list)
(%set-atom-fun %nconc
  #'((a b)
    (if a
        (progn
		  (rplacd (last a) b)
    	  a)
		b)))
