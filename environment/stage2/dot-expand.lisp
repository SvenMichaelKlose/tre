;;;;; TRE tree processor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun dot-expand (x)
  (with (starts-with-dot?
		   (fn = #\. (elt _ 0))

  		 dot-position
		   (fn position #\. _ :test #'=)

  		 list-symbol
		   (fn make-symbol (list-string _))

		 conv
			#'((x)
				 (with (sl (string-list (symbol-name x))
						l  (length sl)
					    p  (dot-position sl))
				   (cond
					 ((or (= 1 l)
						  (not p))
						 x)

					 ((= (1+ p) l)
						 `(car ,(list-symbol (subseq sl 0 (1- l)))))

					 ((= 0 p)
						 (when (= #\. (elt sl (1- l)))
						   (error "symbol ~A must either start or end with a dot" (symbol-name x)))
						 `(cdr ,(list-symbol (subseq sl 1))))

					 (t `(%slot-value
						   ,(list-symbol (subseq sl 0 p))
						   ,(conv (list-symbol (subseq sl (1+ p)))))))))

		 label?
		   (fn (not (or (consp _)
						(numberp _)
				        (stringp _)))))
    (when x
	  ; Combine expression and next symbol to %SLOT-VALUE if symbol
	  ; starts with a dot.
      (cond
;		((and (consp x)
;			  (consp (cdr x))
;			  (label? (second x))
;			  (< 1 (length (symbol-name (second x))))
;			  (starts-with-dot? (symbol-name (second x))))
;		  	(cons `(%slot-value ,(dot-expand (first x))
;							    ,(conv (make-symbol (subseq (symbol-name (second x))
;														    1))))
;			      (dot-expand (cddr x))))
		((label? x)
		   (conv x))

		((consp x)
		   (cons (dot-expand (car x))
				 (dot-expand (cdr x))))

      	(t x)))))

(%set-atom-fun *DOTEXPAND-HOOK* #'dot-expand)
