;;;;; tré – Copyright (c) 2006–2009,2012 Sven Michael Klose <pixel@copei.de>

(setq *show-definitions?* t)

(defvar '*variables* nil)
(defvar '*defined-functions* nil)
(defvar '*universe* nil)
(defvar '*keyword-package* nil)
(defvar '*show-definitions?* nil)
(defvar '*environment-path* nil)
(defvar '*endianess* nil)
(defvar '*pointer-size* nil)
(defvar '*cpu-type* nil)
(defvar '*libc-path* nil)
(defvar '*have-environment-tests* nil)

(defun identity (x) x)

(defun copy-tree (x)
  (& x (? (atom x) x
          (cons (copy-tree x.)
           	    (copy-tree .x)))))

(defun last (x)
  (& x (? .x
          (last .x)
          x)))

(defun %nconc (a b)
  (? a
     (progn
       (rplacd (last a) b)
       a)
	 b))
