;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(define-native-js-fun %not (x)
  (? x
     (when (eq nil x.)
       (%not .x))
     t))

(define-native-js-fun not (&rest x)
  (%not x))
