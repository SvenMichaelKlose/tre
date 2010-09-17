;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;; After this pass
;; - Functions are inlined.
;; - Nested functions are merged.
;; - Optional: Anonymous functions were exported.
;; - FUNINFO objects are built for all functions.
;; - Accesses to the object in a method are thisified.
(defun transpiler-preexpand-compose (tr)
  (compose
	  (fn with-temporary *expex-warn?* t
		   (transpiler-expression-expand tr _)
		   _)
      (fn transpiler-lambda-expand tr _)
	  #'rename-function-arguments
	  (fn (if *opt-inline?*
			  (opt-inline tr _)
			  _))
      (fn thisify (transpiler-thisify-classes tr) _)))

(defun transpiler-frontend-2 (tr x)
  (funcall (transpiler-preexpand-compose tr) x))

;; After this pass
;; - All macros are expanded.
;; - Expression blocks are kept in VM-SCOPE expressions, which is a mix
;;   of BLOCK and TAGBODY.
;; - Conditionals are implemented with VM-GO and VM-GO-NIL.
;; - Quoting is done by %QUOTE (same as QUOTE) exclusively.
(defun transpiler-simple-expand-compose (tr)
  (compose
      (fn funcall (transpiler-literal-conversion tr) _)
      #'backquote-expand
      #'compiler-macroexpand
      (fn transpiler-macroexpand tr _)
	  #'quasiquote-expand
      (fn transpiler-macroexpand tr _)
      #'dot-expand))

(defun transpiler-frontend-1 (tr x)
  (funcall (transpiler-simple-expand-compose tr) x))

(defun transpiler-frontend (tr x)
  (transpiler-frontend-2 tr (transpiler-frontend-1 tr x)))
