;;;;; TRE tree processor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun dot-expand (x)
  (with (starts-with-dot?
		   (fn = #\. (elt _ 0))

  		 dot-position
		   (fn position #\. _ :test #'=)

		 conv
			#'((x)
				 (with (sl (string-list (symbol-name x))
						l  (length sl)
					    p  (dot-position sl))
				   (if
					 (or (= 1 l)
						 (not p))
						x

					 (= 0 p)
						`(cdr ,(dot-expand (list-symbol (subseq sl 1))))

					 (= (1+ p) l)
						`(car ,(list-symbol (subseq sl 0 (1- l))))

					 `(%slot-value
					 	,(list-symbol (subseq sl 0 p))
						,(conv (list-symbol (subseq sl (1+ p))))))))

		 label?
		   (fn (not (or (consp _)
						(numberp _)
				        (stringp _)))))
    (when x
	  ; Combine expression and next symbol to %SLOT-VALUE if symbol
	  ; starts with a dot.
      (if
;		((and (consp x)
;			  (consp (cdr x))
;			  (label? (second x))
;			  (< 1 (length (symbol-name (second x))))
;			  (starts-with-dot? (symbol-name (second x))))
;		  	(cons `(%slot-value ,(dot-expand (first x))
;							    ,(conv (make-symbol (subseq (symbol-name (second x))
;														    1))))
;			      (dot-expand (cddr x))))
		(label? x)
		  (conv x)

		(consp x)
		  (cons (dot-expand (car x))
			    (dot-expand (cdr x)))

      	x))))

(%set-atom-fun *DOTEXPAND-HOOK* #'dot-expand)
