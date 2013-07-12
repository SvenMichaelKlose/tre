;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defmacro make-bc-builtins ()
  `(progn
     ,@(mapcar ^(define-bc-macro ,_ (&rest x)
 			      `(%bc-builtin ,(list '%quote _) ,,(length x) ,,@x))
               (remove-if [in? _ 'cons '%quote] *builtins*))))

;(make-bc-builtins)
