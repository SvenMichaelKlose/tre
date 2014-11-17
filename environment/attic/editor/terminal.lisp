;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Terminal info.

(defstruct terminal
  width
  height)

(defun create-terminal ()
  (ansi-reset)
  (with ((w h) (ansi-dimensions))
    (%terminal-raw)
    (make-terminal :width w :height h)))
