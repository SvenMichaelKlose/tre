;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(php-type-predicate %numberp "number")

(defun %wrap-char-number (x)
  (if (characterp x)
	  (char-code x)
	  x))

(mapcan-macro _
	'((number+ %%%+)
	  (+ %%%+)
	  (number- %%%-)
	  (- %%%-))
  `((defun ,_. (&rest x)
      (let n (%wrap-char-number x.)
	    (dolist (i .x n)
	      (setf n (,._. n (%wrap-char-number i))))))))

(mapcan-macro _
	'(= < >)
  `((defun ,_ (x y)
      (with (xn (%wrap-char-number x)
		     yn (%wrap-char-number y))
	    (,($ '%%% _) xn yn)))))

(defun numberp (x)
  (or (%numberp x)
	  (characterp x)))

(defun integer (x)
  (declare type number x)
  (if (characterp x)
      (char-code x)
      x))
