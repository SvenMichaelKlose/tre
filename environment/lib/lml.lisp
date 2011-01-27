;;;;; TRE environment
;;;;; Copyright (C) 2006-2008,2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LML function library

(defun string-or-cons? (expr)
  (or (string? expr) (cons? expr)))

;;;; LML utilities

(defun lml-get-children (x)
  (when (cons? x)
    (? (cons? x.)
       x
       (lml-get-children .x))))

(defun lml-get-attribute (x name)
  (when x
    (unless (cons? x.)
      (if (eq name x.)
          (second x)
          (lml-get-attribute .x name)))))

(defun lml-child? (expr)
  (string-or-cons? expr))

(defun lml-attr-string (x)
  (string-downcase (if x
					   (string x)
					   "")))

(defun lml-attr-value-string (x)
  (? (string? x)
	 x
  	 (string-downcase (if x (string x) ""))))
