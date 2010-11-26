;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(define-native-php-fun not (x)
  (if x
	  nil
	  t))
