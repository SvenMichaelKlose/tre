;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Alien interface.

(defun alien-import (header-path)
  (exec "/usr/local/bin/gccxml" ("-fxml=test.xml" "-I/usr/local/include" header-path)
		'(("PATH" . "/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/usr/local/X11R6/bin"))))
