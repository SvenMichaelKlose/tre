;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

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
      #'dot-expand
      (fn funcall (transpiler-preprocessor tr) _)))

(defun transpiler-simple-expand (tr x)
  (mapcan (fn (funcall (transpiler-simple-expand-compose tr) (list _)))
		  x))

(defun transpiler-preexpand-and-expand (tr forms)
  (transpiler-expand tr (transpiler-preexpand tr (transpiler-simple-expand tr forms))))
