;;;;; tré – Copyright 2006,2008,2011–2013 (c) Sven Klose <pixel@copei.de>
;;;;;
;;;;; XXX experimental - LOOP can only do infinite loops.

;(defun stream-get (x)
;  (read-char x))

;(defun stream-peek (x)
;  (peek-char x))

;(defun stream-next (x)
;  (stream-get x)
;  x)

;(defun %loop-single-with-clause (x)
;  (with (mk-with  #'((var form)
;  					   `(with (,var ,form)
;	  				   	  ,@(? (eq 'and (stream-peek x))
;	    				       (%loop-single-with-clause (stream-next x))
;							   (%loop-var-clause x))))
;		 var (stream-get x))
;	(? (eq '= (stream-peek x))
;	   (mk-with var (stream-get (stream-next x)))
;	   (mk-with var nil))))

;(defun %loop-with-clause (x)
;  (when (eq 'with (stream-peek x))
;	(%loop-single-with-clause (stream-next x))))

;(defun %loop-var-clause (x)
;  (| (%loop-with-clause x)))

;(defun %loop-extended (x)
;  (with (;(exp0 x) (%loop-name-clause x)
;  		 (exp1 x) (%loop-var-clause x)
;  		 (exp2 x) (%loop-main-clause x))
;	(when x
;	  (error "Trailing LOOP clause ~A." x))
;	(append exp1 exp2)))

(defmacro loop (&rest body)
  (let tag (gensym)
    `(block nil
        (tagbody
          ,tag
          ,@body
          (go ,tag)))))
