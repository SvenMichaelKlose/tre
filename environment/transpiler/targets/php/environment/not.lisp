;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(define-native-php-fun not (x)
  no-args ; Tells transpiler not to store argument definitions.
  (if x
	  nil
	  t))
