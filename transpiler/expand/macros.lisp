;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; STANDARD MACRO EXPANSION

(defun transpiler-macroexpand (tr x)
  (with-temporary *setf-immediate-slot-value* t
    (with-temporary *setf-functionp* (transpiler-setf-functionp tr)
      (repeat-while-changes
	    (fn expander-expand (transpiler-std-macro-expander tr) _)
		x))))
