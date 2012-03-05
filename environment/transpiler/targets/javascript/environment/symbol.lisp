;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defvar *symbols* (make-hash-table))

(dont-inline %symbol) ; XXX remove this one?

;; Symbol constructor
;;
;; It has a function field but that isn't used yet.
(define-native-js-fun %symbol (name pkg)
  (setf this.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'symbol)
		this.n name	; name
     	this.v this	; value
      	this.f nil	; function
		this.p (or pkg nil))	; package
  this)

;; Find symbol by name or create a new one.
(define-native-js-fun symbol (name pkg)
  (unless (%%%= ,*nil-symbol-name* name)
    (or (%%%= ,*t-symbol-name* name)
	    (let pkg-name (? pkg pkg.n ,*nil-symbol-name*)
          ; Make package if missing.
          (let symbol-table (or (%href *symbols* pkg-name)
	    				        (setf (%href *symbols* pkg-name) (make-hash-table)))
            ; Get or make symbol.
            (or (%href symbol-table name)
	            (setf (%href symbol-table name) (new %symbol name pkg))))))))

(define-native-js-fun %%usetf-symbol-function (v x)
  (setq x.f v))
