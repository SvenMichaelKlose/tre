;;;;; tré – Copyright (c) 2008–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun dot-expand-make-expr (which num x)
  (? (< 0 num)
	 `(,which ,(dot-expand-make-expr which (1- num) x))
	 x))

(defun dot-expand-count-start (x &optional (num 0))
  (? (== #\. (car x))
	 (dot-expand-count-start (cdr x) (1+ num))
	 (values num x)))

(defun dot-expand-count-end (x &optional (num 0))
  (? (== #\. (car (last x)))
	 (dot-expand-count-end (butlast x) (1+ num))
	 (values num x)))

(defun dot-expand-list (x &optional (num 0))
  (with ((num-cdrs without-start) (dot-expand-count-start x)
		 (num-cars without-end) (dot-expand-count-end without-start))
	(dot-expand-make-expr 'car num-cars
		                  (dot-expand-make-expr 'cdr num-cdrs
		  	                                    (dot-expand (list-symbol without-end))))))

(defun dot-expand (x)
  (with (starts-with-dot?  (fn == #\. (elt _ 0))
  		 dot-position (fn position #\. _ :test #'==)
		 conv
			#'((x)
				 (with (sl (string-list (symbol-name x))
						l  (length sl)
					    p  (dot-position sl))
				   (?
					 (| (== 1 l) (not p))
						x
					 (| (== #\. (car sl)) (== #\. (car (last sl))))
						(dot-expand-list sl)
					 `(%slot-value ,(list-symbol (subseq sl 0 p))
						           ,(conv (list-symbol (subseq sl (1+ p))))))))
		 label?
		   (fn (not (| (cons? _)
					   (number? _)
				       (string? _)))))
    (when x
      (?
		(label? x) (conv x)
		(cons? x) (cons-r dot-expand x)
      	x))))

(%set-atom-fun *dotexpand-hook* #'dot-expand)
