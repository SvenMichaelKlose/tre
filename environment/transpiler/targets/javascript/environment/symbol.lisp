;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *symbols* (%%%make-hash-table))

(dont-inline %symbol)

(define-native-js-fun %symbol (name pkg)
  (= this.__class ,(transpiler-obfuscated-symbol-string *transpiler* 'symbol)
     this.n name
     this.v this
     this.f nil
     this.p (| pkg nil))
  this)

(define-native-js-fun symbol (name pkg)
  (unless (%%%== ,*nil-symbol-name* name)
    (| (%%%== ,*t-symbol-name* name)
	   (with (pkg-name     (? pkg pkg.n ,*nil-symbol-name*)
              symbol-table (| (%href *symbols* pkg-name)
	   				          (= (%href *symbols* pkg-name) (%%%make-hash-table))))
         (| (%href symbol-table name)
            (= (%href symbol-table name) (new %symbol name pkg)))))))

(define-native-js-fun %%u=-symbol-function (v x)
  (setq x.f v))
