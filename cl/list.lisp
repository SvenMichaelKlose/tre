;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *default-listprop* nil)

(defun cpr (x) x nil)
(defun rplacp (v x) x v)

(defun filter (fun x) (mapcar fun x))
(defun %nconc (&rest x) x (apply #'nconc x))
(defun append (&rest x) x (apply #'nconc (mapcar #'copy-list x)))
