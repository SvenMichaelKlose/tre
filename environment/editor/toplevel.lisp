;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel.

(defun ed (&optional name)
  (with (terminal (create-terminal)
         instance (editor-state-create name terminal))
    (editor-redraw instance)
    (while (not (editor-state-quit? instance))
		   nil
      (editor-cmd instance)
	  (force-output))
    (editor-clear-bottom instance)
    (ansi-position 0 (1- (terminal-height terminal)))
    (format t "Quitting...~%")
    (%terminal-normal)
	(force-output)))
