;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(define-native-php-fun not (x)
  (if x
      nil
      t))
