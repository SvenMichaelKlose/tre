;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *symbols* (%%%make-hash-table))

(define-native-js-fun %symbol (name pkg)
  (= this.__class ,(obfuscated-identifier 'symbol)
     this.n name
     this.v this
     this.f nil
     this.p (| pkg nil))
  this)

(define-native-js-fun symbol (name pkg)
  (unless (%%%== ,*nil-symbol-name* name)
    (| (%%%== ,*t-symbol-name* name)
	   (with (pkg-name     (? pkg pkg.n ,*nil-symbol-name*)
              symbol-table (| (%%%aref *symbols* pkg-name)
	   				          (%%%=-aref (%%%make-hash-table) *symbols* pkg-name)))
         (| (%%%aref symbol-table name)
            (%%%=-aref (new %symbol name pkg) symbol-table name))))))

(define-native-js-fun =-symbol-function (v x)
  (setq x.f v))
