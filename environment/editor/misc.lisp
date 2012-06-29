;;;;; tré – Copyright (c) 2008,2011–2012 Sven Michael Klose <pixel@copei.de>
;;;;;
;;;;; Miscellaneous.

(defmacro define-template-macro (name head &optional tail)
   "Define simple head/tail template."
  `(defmacro ,name (n args &rest b)
 	 (with (description (& b (cons? b) (string? (car b)) (car b))
			body (? description (cdr b) b))
       `(defun ,,n ,,args
		  ,,@(list description)
          ,@head
          ,,@body
          ,@tail))))

(defmacro define-tail-macro (name tail)
  `(define-template-macro ,name nil ,tail))
