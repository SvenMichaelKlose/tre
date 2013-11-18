;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun butlast-path-component (x)
  (apply #'+ (pad (butlast (path-pathlist x)) "/")))

(defun url-without-filename (x)
  (? x
     (butlast-path-component x)
	 ""))

(defun url-schema (x)
  (car (split #\/ x)))

(defun url-has-schema? (x)
  (alet (split #\/ x)
    (& (ends-with? !. ":")
	   (empty-string? .!.))))

(defun url-without-schema (x)
  (? (url-has-schema? x)
     (subseq x (+ 2 (length (url-schema x))))
     x))

(defun url-path (x)
  (& x (apply #'+ (pad (cdr (path-pathlist (url-without-schema x))) "/"))))

(defun url-without-path (x)
  (apply #'+ (pad (subseq (path-pathlist x) 0 3) "/")))
