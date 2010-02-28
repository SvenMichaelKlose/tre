;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun transpiler-expression-expand (tr x)
    (expression-expand (transpiler-expex tr) x))

;; After this pass
;; - Functions are assigned run-time argument definitions
;; - VM-SCOPEs are removed. All code is flat with jump tags.
;; - Peephole-optimisations were performed.
;; - FUNINFOs were updated with number of jump tags in function.
;; - FUNCTION expression contain the names of top-level functions.
(defun transpiler-expand-compose (tr)
  (compose
	  (fn (princ #\.)
		  (force-output)
		  _)
      #'transpiler-update-funinfo
      #'opt-places-remove-unused
      #'opt-places-find-used
      #'opt-peephole
      #'opt-tailcall
      #'opt-peephole
      (fn transpiler-make-named-functions tr _)
      #'transpiler-quote-keywords
      (fn transpiler-expression-expand tr _)
	  (fn transpiler-prepare-runtime-argument-expansions tr _)))

(defun transpiler-middleend-2 (tr x)
  (remove-if #'not
		     (funcall (transpiler-expand-compose tr) x)))

;; After this pass
;; - Functions are inlined.
;; - Nested functions are merged.
;; - Optional: Anonymous functions were exported.
;; - FUNINFO objects are built for all functions.
;; - Accesses to the object in a method are thisified.
(defvar *opt-inline?* t)

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

(defun transpiler-middleend-1 (tr x)
  (funcall (transpiler-preexpand-compose tr) x))
