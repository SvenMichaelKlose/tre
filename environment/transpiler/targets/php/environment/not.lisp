;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(define-native-php-fun %not (x)
  (? x
     (when (eq nil x.)
       (%not .x))
     t))

(define-native-php-fun not (&rest x)
  (%not x))
