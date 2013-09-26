;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun dot-expand-make-expr (which num x)
  (? (< 0 num)
	 `(,which ,(dot-expand-make-expr which (-- num) x))
	 x))

(defun dot-expand-head-length (x &optional (num 0))
  (? (== #\. (car x))
	 (dot-expand-head-length (cdr x) (++ num))
	 (values num x)))

(defun dot-expand-tail-length (x &optional (num 0))
  (? (== #\. (car (last x)))
	 (dot-expand-tail-length (butlast x) (++ num))
	 (values num x)))

(defun dot-expand-list (x)
  (with ((num-cdrs without-start) (dot-expand-head-length x)
		 (num-cars without-end)   (dot-expand-tail-length without-start))
	(dot-expand-make-expr 'car num-cars
		                  (dot-expand-make-expr 'cdr num-cdrs
		  	                                    (dot-expand (list-symbol without-end))))))

(defun dot-expand (x)
  (with (dot-position [position #\. _ :test #'==]
		 conv
			#'((x)
				 (with (sl (string-list (symbol-name x))
						l  (length sl)
					    p  (dot-position sl))
				   (?
					 (| (== 1 l) (not p)) x
					 (| (== #\. (car sl)) (== #\. (car (last sl)))) (dot-expand-list sl)
					 `(%slot-value ,(list-symbol (subseq sl 0 p))
						           ,(conv (list-symbol (subseq sl (++ p))))))))
		 label?
		   [not (| (cons? _)
				   (number? _)
				   (string? _))])
    (when x
      (?
		(label? x) (conv x)
		(cons? x)  (listprop-cons x (dot-expand (car x))
                                    (dot-expand (cdr x)))
      	x))))

(%set-atom-fun *dotexpand-hook* #'dot-expand)
