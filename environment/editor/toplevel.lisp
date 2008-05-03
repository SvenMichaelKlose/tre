;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel.

(defun ed (&optional name)
  (when (or name (not *editor-state*))
    (editor-state-create name))
  (create-terminal)
  (editor-redraw)
  (loop
    (editor-cmd)
    (awhen (editor-state-quit *editor-state*)
	  (editor-clear-bottom)
      (ansi-position 0 (1- (terminal-height *terminal*)))
	  (format t "Quitting...~%")
	  (%terminal-normal)
	  (return-from editor nil))
	(force-output)))
