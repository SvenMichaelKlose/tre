;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; UN*X shell commands

(defun unix-sh-rm (file)
  (exec "/bin/rm" (list file)))

(defun unix-sh-mv (from to)
  (exec "/bin/mv" (list from to)))

(defun unix-sh-cp (from to &key (recursively? nil))
  (exec "/bin/cp" (append (when recursively?
							   (list "-r"))
							 (list from to))))

(defun unix-sh-mkdir (path &key (parents nil))
  (exec "/bin/mkdir" (append (when parents
							   (list "-p"))
							 (list path))))

(defun unix-sh-chmod (flags path &key (recursively nil))
  (exec "/bin/chmod" (append (when recursively
							   (list "-R"))
							 (list flags path))))

(defun unix-sh-chown (user group path &key (recursively nil))
  (exec "/usr/sbin/chown" (append (when recursively
							        (list "-R"))
							      (list (string-concat user ":" group)
										path))))
