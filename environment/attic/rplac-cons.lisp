;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>

(defun rplac-cons (dest what)
  "Replace CAR and CDR of a cons."
  (= (car dest) (car what)
	 (cdr dest) (cdr what)))
