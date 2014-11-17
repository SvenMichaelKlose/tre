;;;;; tré – Copyright (c) 2008,2013 Sven Michael Klose <pixel@copei.de>

(defun ed (&optional name)
  (with (terminal (create-terminal)
         instance (editor-state-create name terminal))
    (editor-redraw instance)
    (while (not (editor-state-quit? instance))
		   nil
      (editor-cmd instance)
	  (force-output))
    (editor-clear-bottom instance)
    (ansi-position 0 (-- (terminal-height terminal)))
    (format t "Quitting...~%")
    (%terminal-normal)
	(force-output)))
