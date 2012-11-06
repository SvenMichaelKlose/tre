;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

;; After this pass
;; - Functions are inlined.
;; - Nested functions are merged.
;; - Optional: Anonymous functions were exported.
;; - FUNINFO objects are built for all functions.
;; - Accesses to the object in a method are thisified.
(transpiler-pass transpiler-frontend-2 (tr)
    fake-expression-expand    [(transpiler-expression-expand tr (make-packages _))
                               _]
    lambda-expand             [transpiler-lambda-expand tr _]
    rename-function-arguments #'rename-function-arguments
    opt-inline                [? *opt-inline?*
                                 (opt-inline tr _)
	                             _]
    thisify                   [thisify (transpiler-thisify-classes tr) _])

;; After this pass
;; - All macros are expanded.
;; - Expression blocks are kept in VM-SCOPE expressions, which is a mix
;;   of BLOCK and TAGBODY.
;; - Conditionals are implemented with VM-GO and VM-GO-NIL.
;; - Quoting is done by %QUOTE (same as QUOTE) exclusively.
(transpiler-pass transpiler-frontend-1 (tr)
    literal-conversion        [funcall (transpiler-literal-conversion tr) _]
    backquote-expand          #'backquote-expand
    compiler-macroexpand      #'compiler-macroexpand
    transpiler-macroexpand-2  [transpiler-macroexpand tr _]
    quasiquote-expand         #'quasiquote-expand
    transpiler-macroexpand-1  [? (transpiler-dot-expand? tr)
                                 (transpiler-macroexpand tr _)
                                 _]
    dot-expand                [? (transpiler-dot-expand? tr)
                                 (dot-expand _)
                                 _]
    file-input                #'identity)

(defun transpiler-frontend-0 (tr x)
  (transpiler-frontend-2 tr (transpiler-frontend-1 tr x)))

(defun transpiler-frontend (tr x)
  (mapcan [transpiler-frontend-0 tr (list _)] x))

(defun transpiler-frontend-file (tr file)
  (format t "(LOAD \"~A\")~%" file)
  (force-output)
  (transpiler-frontend tr (read-file-all file)))
