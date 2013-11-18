;;;;; tré – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun table-get-column-header (x)
  (find-if (fn i.has-tag-name? _) (table-get-column x)))

(defun table-get-row-header (x)
  ((table-get-row x).get-first-by-tag "th"))
