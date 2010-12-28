;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(define-native-php-fun not (x)
  (if (%%%eq x nil)
      t
      nil))
