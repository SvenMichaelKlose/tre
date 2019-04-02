(defnative %cons (a d)
  (= this.__class ,(convert-identifier 'cons)
     this._  a
     this.__ d)
  this)

(defnative cons (x y)
  (new %cons x y))
