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
;	  (fn metacode-fblock _)
      (fn if (transpiler-continuation-passing-style? tr)
             (cps _)
             _)
      #'opt-places-remove-unused
      #'opt-places-find-used
      #'opt-peephole
      #'opt-tailcall
      #'opt-peephole
      (fn transpiler-make-named-functions tr _)
      #'transpiler-quote-keywords
      (fn transpiler-expression-expand tr _)))

(defun transpiler-middleend-2 (tr x)
  (remove-if #'not
		     (funcall (transpiler-expand-compose tr) x)))
