;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defmacro define-codegen-macro-definer (name tr-ref)
  `(defmacro ,name (&rest x)
     (when *show-definitions*
       (print `(,name ,,x.)))
     `(progn
	    (transpiler-add-obfuscation-exceptions ,tr-ref ',,x.)
	    (define-codegen-macro ,tr-ref ,,@x))))
