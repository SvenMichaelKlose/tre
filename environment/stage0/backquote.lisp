;;;;; tré – Copyright (c) 2006–2012 Sven Michael Klose <pixel@copei.de>

(defun any-quasiquote?  (x)
  (& (cons? x)
     (in? x. 'quasiquote 'quasiquote-splice)))

(defun quasiquote (x)
  (error "',' outside backquote"))

(defun quasiquote-splice (x)
  (error "',@' outside backquote"))
