;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-expand-print-dot (x)
  (princ #\.)
  (force-output)
  x)

;; After this pass
;; - Functions are assigned run-time argument definitions
;; - VM-SCOPEs are removed. All code is flat with jump tags.
;; - Peephole-optimisations were performed.
;; - FUNINFOs were updated with number of jump tags in function.
;; - FUNCTION expression contain the names of top-level functions.
(defun transpiler-expand-compose (tr)
  (compose
	  #'transpiler-expand-print-dot
      (fn transpiler-make-named-functions tr _)
      #'transpiler-update-funinfo
      #'opt-places-find-used
      #'opt-peephole
      #'transpiler-quote-keywords
      (fn transpiler-expression-expand tr `(vm-scope ,_))
	  (fn transpiler-prepare-runtime-argument-expansions tr _)))

(defun transpiler-expand (tr x)
  (remove-if #'not
		     (mapcar (fn funcall (transpiler-expand-compose tr) _)
					 x)))

;; After this pass
;; - Functions were inlined.
;; - Nested functions are merged.
;; - Optional: Anonymous functions were exported.
;; - FUNINFO objects were built for all functions.
;; - Accesses to the object in a method are thisified.
(defvar *opt-inline?* t)

(defun transpiler-preexpand-compose (tr)
  (compose
      (fn thisify (transpiler-thisify-classes tr) _)
      (fn transpiler-lambda-expand tr _)
	  #'rename-function-arguments
	  (fn (if *opt-inline?*
			  (opt-inline tr _)
			  _))
      (fn funcall (transpiler-simple-expand-compose tr) _)))

(defun transpiler-preexpand (tr x)
  (mapcan (fn (funcall (transpiler-preexpand-compose tr) (list _)))
	      x))

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
  (transpiler-expand tr (transpiler-preexpand tr forms)))
