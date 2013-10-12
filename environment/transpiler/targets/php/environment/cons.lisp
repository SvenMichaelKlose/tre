;;;;; tré – Copyright (c) 2008–2011,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *cars* *cdrs* *cprd* *cons-id* a d sa sd)

(define-native-php-fun cons (x y)
  (new __cons x y))
