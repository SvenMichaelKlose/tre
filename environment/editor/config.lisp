;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration.

(defvar *editor-config*)

(defun editor-conf-add (name val)
  (acons! name val *editor-config*))

(defun editor-conf (name)
  (cdr (assoc name *editor-config*)))

(editor-conf-add 'tabstop 4)
(editor-conf-add 'color-text-foreground (ansi-color 'white t))
(editor-conf-add 'color-text-background (ansi-color 'black))
