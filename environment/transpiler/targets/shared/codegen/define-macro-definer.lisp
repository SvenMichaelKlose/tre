;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-codegen-macro-definer (name tr-ref)
  `(defmacro ,name (&rest x)
     (print-definition `(,name ,,x.))
     `(progn
	    (define-codegen-macro ,tr-ref ,,@x))))
