;;;;; tré – Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defstruct editor-state
  (x 0)
  (y 0)
  (line-offset 0)
  (column-offset 0)
  (name nil)
  (text nil)
  (quit? nil)
  (mode nil)
  terminal)

(defun editor-io-line (n)
  (when (== 0 (mod n 10))
  	(ansi-column 0)
  	(ansi-bold)
  	(princ n)
  	(force-output)))

(defun editor-state-create (name terminal)
  (make-editor-state
	  :name name
	  :text (make-text-container :lines (& name (editor-read name)))
	  :terminal terminal))
