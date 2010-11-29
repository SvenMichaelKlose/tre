;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(dont-inline __cons)

(define-native-php-fun cons (x y)
  (new __cons x y))
