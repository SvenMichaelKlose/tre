;;;;; tré – Copyright (C) 2006–2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun string-or-cons? (expr)
  (| (string? expr) (cons? expr)))

(defun lml-get-children (x)
  (& (cons? x)
     (? (cons? x.)
        x
        (lml-get-children .x))))

(defun lml-get-attribute (x name)
  (& x
     (unless (cons? x.)
       (? (eq name x.)
          (cadr x)
          (lml-get-attribute .x name)))))

(defun lml-child? (expr)
  (string-or-cons? expr))

(defun string-or-empty-string (x)
  (? x (string x) ""))

(defun lml-attr-string (x)
  (& (cons? x) (error "cannot take cons as a LML attribute"))
  (string-downcase (string-or-empty-string x)))

(defun lml-attr-value-string (x)
  (? (string? x)
	 x
     (lml-attr-string x)))
