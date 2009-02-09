;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(js-type-predicate %numberp number)

(defun %wrap-char-number (x)
  (if (characterp x)
	  (char-code x)
	  x))

(defun number+ (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%+ n (%wrap-char-number i))))))

(defun + (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%+ n (%wrap-char-number i))))))

(defun number- (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%- n (%wrap-char-number i))))))

(defun - (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%- n (%wrap-char-number i))))))

(defun = (x y)
  (with (xn (%wrap-char-number x)
		 yn (%wrap-char-number y))
	(%%%= xn yn)))

(defun < (x y)
  (with (xn (%wrap-char-number x)
		 yn (%wrap-char-number y))
	(%%%< xn yn)))

(defun > (x y)
  (with (xn (%wrap-char-number x)
		 yn (%wrap-char-number y))
	(%%%> xn yn)))

(defun numberp (x)
  (or (%numberp x)
	  (characterp x)))

(defun integer (x)
  (assert (numberp x)
    (error "number expected"))
  (if (characterp x)
      (char-code x)
      x))
