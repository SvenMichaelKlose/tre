;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun number-sym (x)
  (with (digit
		  (fn (if (< _ 24)
				  (+ #\a _)
				  (+ (- #\0 24) _)))
		 rec
		   (fn (unless (= 0 _)
				 (with (m (mod _ 34))
				   (cons (digit m)
						 (rec (/ (- _ m) 34)))))))
	(make-symbol (list-string (cons #\_ (rec x))))))
