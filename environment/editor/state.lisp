;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

;;;; Editor state.

(defstruct editor-state
  x
  y
  line-offset
  column-offset
  name
  text
  quit)

(defvar *editor-state*)

(defun editor-io-line (n)
  (when (= 0 (mod n 10))
  	(ansi-column 0)
  	(ansi-bold)
  	(princ n)
  	(force-output)))

(defvar *text*)

(defun editor-state-create (name)
  (setf *text*
			(make-text-container
			  :x 0 :y 0
		      :lines (and name (editor-read name)))
		*editor-state*
        	(make-editor-state
          	  :x 0 :y 0 :line-offset 0 :column-offset 0 :name name
		      :quit nil
		      :text *text*)
		(editor-state-quit *editor-state*) nil))
