;;;; TRE environment
;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Primitive functions directly assigned to atoms without.

(setq *universe* (cons 'not
                 (cons 'last
                 (cons '%nconc
                 (cons 'copy-tree *universe*)))))

;;; Helper functions (helping us to stay sane).

;(%set-atom-fun eql
;  #'((x y)
;	  (block eql
;	    (cond
;		  ((numberp x)
;		     (cond
;			   ((numberp y)
;			      (cond
;			        ((not (= (%number-type x) (%number-type y)))
;			          (return-from eql (= x y)))))))
;	      (t  (eq x y))))))

(%set-atom-fun not
  #'((x)
	   (cond
		 (x nil)
		 (t t))))

(%set-atom-fun copy-tree
  #'((x)
    (cond
      (x (cond
           ((atom x)
               x)
           (t  (cons (copy-tree (car x))
                     (copy-tree (cdr x)))))))))

(%set-atom-fun last
  #'((x)
    (cond
      (x  (cond
            ((cdr x)
                (last (cdr x)))
            (t  x))))))

(%set-atom-fun %nconc
  #'((a b)
    (rplacd (last a) b)
    a))
