;;;;; TRE tree processor
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun dot-expand-make-expr (which num x)
  (if (< 0 num)
	  `(,which ,(dot-expand-make-expr which (1- num) x))
	  x))

(defun dot-expand-count-start (x &optional (num 0))
  (if (= #\. (car x))
	  (dot-expand-count-start (cdr x) (1+ num))
	  (values num x)))

(defun dot-expand-count-end (x &optional (num 0))
  (if (= #\. (car (last x)))
	  (dot-expand-count-end (butlast x) (1+ num))
	  (values num x)))

(defun dot-expand-list (x &optional (num 0))
  (with ((num-cdrs without-start) (dot-expand-count-start x)
		 (num-cars without-end) (dot-expand-count-end without-start))
	(dot-expand-make-expr
		'car
	  	num-cars
		(dot-expand-make-expr
			'cdr
		  	num-cdrs
		  	(dot-expand (list-symbol without-end))))))

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

					 (or (= #\. (car sl))
					 	 (= #\. (car (last sl))))
						(dot-expand-list sl)

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
