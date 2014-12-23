;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *default-listprop* nil)

(defun cpr (x) x nil)
(defun rplacp (v x) x v)

(defun filter (fun x) (cl:mapcar fun x))
(defun %nconc (&rest x) x (apply #'cl:nconc x))
(defun append (&rest x) x (apply #'cl:nconc (cl:mapcar #'cl:copy-list x)))
