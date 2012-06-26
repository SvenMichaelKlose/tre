;;;;; tré – Copyright (c) 2008–2009,2012 Sven Michael Klose <pixel@copei.de>

(dont-inline %cons)

(define-native-js-fun %cons (a d)
  (= this.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'cons)
     this._ a
     this.__ d)
  this)

(define-native-js-fun cons (x y)
  (new %cons x y))
