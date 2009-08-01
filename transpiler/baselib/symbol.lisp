;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;; All symbols are stored in this array for reuse.
(defvar *symbols* (make-array))

;; Symbol constructor
;;
;; It has a function field but that isn't used yet.
(define-native-js-fun %symbol (name pkg)
  no-args
  (setf this.__class ,(transpiler-obfuscated-symbol-string *js-transpiler*
														  'symbol)
		this.n name	; name
     	this.v nil	; value
      	this.f nil	; function
		this.p (or pkg nil))	; package
  this)

;; Find symbol by name or create a new one.
;;
;; Wraps the 'new'-operator.
;; XXX rename to %QUOTE ?
(define-native-js-fun %lookup-symbol (name pkg)
  no-args
  (unless (and (%%%= ,*nil-symbol-name* name)
			   (not pkg))
    ; Make package if missing.
    (or (aref *symbols* pkg)
	    (setf (aref *symbols* pkg) (make-array)))
    ; Get or make symbol.
    (or (aref (aref *symbols* pkg) name)
	    (setf (aref (aref *symbols* pkg) name) (new %symbol name pkg)))))

(define-native-js-fun symbol (name pkg)
  no-args
  (%lookup-symbol name pkg))

(define-native-js-fun %%usetf-symbol-function (v x)
  no-args
  (setq x.f v))
