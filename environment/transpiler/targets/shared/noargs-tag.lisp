;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun list-without-noargs-tag (x)
  (remove 'no-args x))

(defun body-has-noargs-tag? (body)
  (eq 'no-args body.))

(defun body-with-noargs-tag (body)
  (& (body-has-noargs-tag? body)
     (error "Body already has NOARGS tag."))
  `(no-args ,@body))

(defun body-without-noargs-tag (body)
  (? (body-has-noargs-tag? body)
     .body
     body))
