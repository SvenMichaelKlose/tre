; tré – Copyright (c) 2009–2014,2016 Sven Michael Klose <pixel@copei.de>

(defun butlast-path-component (x)
  (pathlist-path (pad (butlast (path-pathlist x)) "/")))

(defun url-without-filename (x)
  (? x
     (butlast-path-component x)
	 ""))

(defun url-schema (x)
  (car (path-pathlist x)))

(defun url-has-schema? (x)
  (alet (path-pathlist x)
    (& (tail? !. ":")
	   (empty-string? .!.))))

(defun url-without-schema (x)
  (? (url-has-schema? x)
     (subseq x (+ 2 (length (url-schema x))))
     x))

(defun url-path (x)
  (pathlist-path (pad (cdr (path-pathlist (url-without-schema x))) "/")))

(defun url-without-path (x)
  (pathlist-path (pad (subseq (path-pathlist x) 0 3) "/")))
