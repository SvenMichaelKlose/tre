;;;;; tré – Copyright (c) 2009-2010 Sven Michael Klose <pixel@copei.de>

(defun get-submit-button (form)
  (do-elements-by-tag-name (elm form "input")
	(when (elm.attribute-value? "type" "submit")
	  (return elm))))
