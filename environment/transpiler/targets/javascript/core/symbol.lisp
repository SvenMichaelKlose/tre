(var *symbols* (%%%make-object))
(var *package* nil)

(defnative %symbol (name pkg)
  (= this.__class ,(obfuscated-identifier 'symbol)
     this.n name
     this.v this
     this.f nil
     this.p (| pkg nil))
  this)

(defnative symbol (name pkg)
  (unless (%%%== "NIL" name)
    (| (%%%== "T" name)
       (with (pkg-name      (? pkg
                               pkg.n
                               (!? *package*
                                   !.n
                                   "NIL"))
              symbol-table  (| (%%%aref *symbols* pkg-name)
   				               (%%%=-aref (%%%make-object) *symbols* pkg-name)))
         (| (%%%aref symbol-table name)
            (%%%=-aref (new %symbol name pkg) symbol-table name))))))

(setq *package* (symbol "TRE" nil))

(var *keyword-package* (symbol "KEYWORD" nil))

(defnative =-symbol-function (v x)
  (setq x.f v))
