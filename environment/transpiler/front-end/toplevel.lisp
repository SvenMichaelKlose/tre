;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

;; In this pass
;; - Accesses to the object in a method are thisified.
;; - Functions are inlined.
;; - Function arguments are renamed.
;; - Nested functions are merged.
;; - Anonymous functions are exported.
;; - FUNINFO objects are built for all functions.
(transpiler-pass transpiler-preexpand-compose (tr)
    fake-expression-expand (fn with-temporary *expex-warn?* t
		                         (transpiler-expression-expand tr _)
		                         _)
    lambda-expand (fn transpiler-lambda-expand tr _)
    rename-function-arguments #'rename-function-arguments
    opt-inline (fn ? *opt-inline?*
                     (opt-inline tr _)
	                 _)
    thisify (fn thisify (transpiler-thisify-classes tr) _))

(defun transpiler-frontend-2 (tr x)
  (funcall (transpiler-preexpand-compose tr) x))

;; In this pass
;; - All macros are expanded.
;; - Expression blocks are kept in VM-SCOPE expressions, which is a mix of BLOCK and TAGBODY.
;; - Conditionals are implemented with VM-GO and VM-GO-NIL.
;; - Quoting is done by %QUOTE (same as QUOTE) exclusively.
;; - Backquotes are implemented with CONS and APPEND.
;; - Literal characters are converted (ECMAScript).
(transpiler-pass transpiler-simple-expand-compose (tr)
    literal-conversion (fn funcall (transpiler-literal-conversion tr) _)
    backquote-expand #'backquote-expand
    compiler-macroexpand #'compiler-macroexpand
    transpiler-macroexpand-2 (fn transpiler-macroexpand tr _)
    quasiquote-expand #'quasiquote-expand
    transpiler-macroexpand-1 (fn ? (transpiler-dot-expand? tr)
                                   (transpiler-macroexpand tr _)
                                   _)
    dot-expand (fn ? (transpiler-dot-expand? tr)
                     (dot-expand _)
                     _))

(defun transpiler-frontend-1 (tr x)
  (funcall (transpiler-simple-expand-compose tr) x))

(defun transpiler-frontend (tr x)
  (transpiler-frontend-2 tr (transpiler-frontend-1 tr x)))
