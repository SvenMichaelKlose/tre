;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-c-macro %%%eq (&rest x)
  `("TREPTR_TRUTH(" ,(pad x "==") ")"))
