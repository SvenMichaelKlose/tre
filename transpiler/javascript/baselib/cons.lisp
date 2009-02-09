;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; First part of the core functions
;;;;;
;;;;; It contains the essential functions needed to store argument
;;;;; definitions for APPLY.

;; Cell object constructor.
(define-native-js-fun %cons (a d)
  no-args
  (setf this.__class "cons"
        this._ a
  		this.__ d)
  this)

;; Cell constructor
;;
;; Wraps the 'new'-operator.
(define-native-js-fun cons (x y)
  no-args
  (new %cons x y))
