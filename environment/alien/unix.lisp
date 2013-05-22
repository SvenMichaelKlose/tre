;;;;; tré – Copyright (c) 2008,2013 Sven Michael Klose <pixel@copei.de>

(defun unix-sh-rm (file &key (recursively? nil) (force? nil))
  (exec "/bin/rm" (+ (& recursively? (list "-r"))
					 (& force?       (list "-f"))
					 (list file))))

(defun unix-sh-mv (from to)
  (exec "/bin/mv" (list from to)))

(defun unix-sh-cp (from to &key (recursively? nil))
  (exec "/bin/cp" (+ (& recursively?  (list "-r"))
				     (list from to))))

(defun unix-sh-mkdir (path &key (parents nil))
  (exec "/bin/mkdir" (+ (& parents (list "-p"))
					    (list path))))

(defun unix-sh-chmod (flags path &key (recursively nil))
  (exec "/bin/chmod" (+ (& recursively (list "-R"))
						(list flags path))))

(defun unix-sh-chown (user group path &key (recursively nil))
  (exec "/usr/sbin/chown" (+ (& recursively (list "-R"))
							 (list (string-concat user ":" group) path))))
