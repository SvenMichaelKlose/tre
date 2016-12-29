(defun dot-expand-make-expr (which num x)
  (? (< 0 num)
	 `(,which ,(dot-expand-make-expr which (-- num) x))
	 x))

(defun dot-expand-head-length (x &optional (num 0))
  (? (eql #\. x.)
	 (dot-expand-head-length .x (++ num))
	 (values num x)))

(defun dot-expand-tail-length (x &optional (num 0))
  (? (eql #\. (car (last x)))
	 (dot-expand-tail-length (butlast x) (++ num))
	 (values num x)))

(defun dot-expand-list (x)
  (with ((num-cdrs without-start) (dot-expand-head-length x)
		 (num-cars without-end)   (dot-expand-tail-length without-start))
	(dot-expand-make-expr 'car num-cars
		                  (dot-expand-make-expr 'cdr num-cdrs
		  	                                    (dot-expand (list-symbol without-end))))))

(defun dot-position (x)
  (position #\. x :test #'character==))

(defun no-dot-notation? (x)
  (with (sl  (string-list (symbol-name x))
         l   (length sl)
         p   (dot-position sl))
    (| (== 1 l)
       (not p))))

(defun has-dot-notation? (x)
  (with (sl  (string-list (symbol-name x)))
    (| (eql #\. sl.)
       (eql #\. (car (last sl))))))

(defun dot-expand-conv (x)
  (with (sl  (string-list (symbol-name x))
         p   (dot-position sl))
    (?
      (no-dot-notation? x)   x
      (has-dot-notation? x)  (dot-expand-list sl)
      `(%slot-value ,(list-symbol (subseq sl 0 p))
                    ,(dot-expand-conv (list-symbol (subseq sl (++ p))))))))

(defun dot-expand (x)
  (?
    (symbol? x)  (dot-expand-conv x)
    (cons? x)    (. (dot-expand x.)
                    (dot-expand .x))
    x))

(= *dot-expand* #'dot-expand)
