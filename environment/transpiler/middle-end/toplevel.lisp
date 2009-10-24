;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-expand-print-dot (x)
  (princ #\.)
  (force-output)
  x)

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
      (fn transpiler-lambda-expand tr _)
	  #'rename-function-arguments
	  (fn (if *opt-inline?*
			  (opt-inline tr _)
			  _))
      (fn thisify (transpiler-thisify-classes tr) _)))

(defun transpiler-preexpand (tr x)
  (mapcan (fn (funcall (transpiler-preexpand-compose tr) (list _)))
	      x))
