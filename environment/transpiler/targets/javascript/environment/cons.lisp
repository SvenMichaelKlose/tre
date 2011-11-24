;;;;; tré - Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(dont-inline %cons)

(define-native-js-fun %cons (a d)
  (setf this.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'cons)
        this._ a
  		this.__ d)
  this)

(define-native-js-fun cons (x y)
  (new %cons x y))
