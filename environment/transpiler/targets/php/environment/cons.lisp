;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(dont-inline %cons)

;; Cell object constructor.
(define-native-php-fun %cons (a d)
  (setf this.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'cons)
        this._ a
  		this.__ d)
  this)

;; Cell constructor
;;
;; Wraps the 'new'-operator.
(define-native-php-fun cons (x y)
  (new %cons x y))
