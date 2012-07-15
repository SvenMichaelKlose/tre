;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(define-bc-macro cons (a d)
  `(%cons ,a ,d))

(define-bc-macro identity (x)
  x)
