;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Text container.

(defstruct text-container
  x
  y
  lines)

(defun text-container-line (txt &optional (n nil))
  (elt (text-container-lines txt)
	   (or n (text-container-y txt))))

(defun text-container-up (txt &optional (n 1))
  (with (y	(text-container-y txt))
	(desaturate! (text-container-y txt) y n)
	(if (desaturates? y n)
		y
		n)))

(defun text-container-left (txt &optional (n 1))
  (with (x	(text-container-x txt))
	(desaturate! (text-container-x txt) x n)
	(if (desaturates? x n)
		x
		n)))

(defun text-container-down (txt &optional (n 1))
  (with (y		(text-container-y txt)
		 h		(1- (length (text-container-lines txt))))
	(saturate! (text-container-y txt) y n h)
	(if (saturates? y n h)
	    (- h y)
	    n)))

(defun text-container-right (txt &optional (n 1))
  (with (x		(text-container-x txt)
  		 y		(text-container-y txt)
	     lines  (text-container-lines txt)
    	 line	(elt lines y)
    	 w		(1- (length line)))
	(saturate! (text-container-x txt) x n w)
	(if (saturates? x n w)
		(- w x)
		n)))
