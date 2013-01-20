;;;;; tré – Copyright (c) 2008–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(dont-inline %cons)

(defvar *default-listprop* nil)

(define-native-js-fun %cons (a d)
  (= this.__class ,(transpiler-obfuscated-symbol-string *transpiler* 'cons)
     this._  a
     this.__ d
     this._p *default-listprop*)
  this)

(define-native-js-fun cons (x y)
  (new %cons x y))
