;;;;; tré – Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defstruct class
  (members nil)
  (methods nil)
  (parent nil))

(defun class-add-method (cls name code)
  (acons! name code (class-methods cls)))

(defun class-change-method (cls name code)
  (= (assoc-value name (class-methods cls)) code))

(defun class-method (cls name)
  (assoc-value name cls))

(defun class-add-member (cls name)
  (push (list name t) (class-members cls)))
