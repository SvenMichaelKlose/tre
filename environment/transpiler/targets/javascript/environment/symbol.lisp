;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *symbols* (make-hash-table))

(dont-inline %symbol)

;; Symbol constructor
;;
;; It has a function field but that isn't used yet.
(define-native-js-fun %symbol (name pkg)
  (setf this.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'symbol)
		this.n name
     	this.v this
      	this.f nil
		this.p (or pkg nil))
  this)

;; Find symbol by name or create a new one.
(define-native-js-fun symbol (name pkg)
  (unless (%%%= ,*nil-symbol-name* name)
    (or (%%%= ,*t-symbol-name* name)
	    (with (pkg-name (? pkg pkg.n ,*nil-symbol-name*)
               symbol-table (or (%href *symbols* pkg-name)
	    				        (setf (%href *symbols* pkg-name) (make-hash-table))))
          (or (%href symbol-table name)
              (setf (%href symbol-table name) (new %symbol name pkg)))))))

(define-native-js-fun %%usetf-symbol-function (v x)
  (setq x.f v))
