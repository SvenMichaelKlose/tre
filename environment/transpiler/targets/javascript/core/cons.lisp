(defvar *default-listprop* nil)

(defnative %cons (a d)
  (= this.__class ,(obfuscated-identifier 'cons)
     this._  a
     this.__ d
     this._p *default-listprop*)
  this)

(defnative cons (x y)
  (new %cons x y))
