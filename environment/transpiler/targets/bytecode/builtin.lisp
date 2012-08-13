;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defmacro make-bc-builtins ()
  (print
  `(progn
     ,@(mapcar (fn `(define-bc-std-macro ,_ (&rest x)
 			          `(%bc-builtin ,(list '%quote _) ,,(length x) ,,@x)))
               (remove-if (fn in? _ 'cons '%quote) *builtins*))
     ,@(mapcar (fn `(define-bc-std-macro ,_ (&rest x)
 			          `(%bc-special ,(list '%quote _) ,,(length x) ,,@x)))
               *specials*))))

(make-bc-builtins)
