;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Alien interface.

(defun unix-sh-rm (file)
  (execve "/bin/rm" `("/bin/rm" ,file)))

(defconstant *alien-xml-tmp* "__alien.tmp")
(defconstant *gccxml-path* "/usr/bin/gccxml")

(defun lml-get-childs (x)
  (when (consp x)
	(if (consp (car x))
		x
		(lml-get-childs (cdr x)))))

(defun lml-get-attribute (x name)
  (when x
	(unless (consp (car x))
	  (if (eq name (car x))
		  (second x)
		  (lml-get-attribute (cdr x) name)))))

(defvar *alien-imported-functions* (make-hash-table :test #'string=))

(defun alien-import-descr (descr)
  (dolist (x (lml-get-childs descr))
    (when (eq (car x) :function)
	  (with (fun-name (lml-get-attribute x :name))
	    (unless (gethash fun-name *alien-imported-functions*)
		  (format t "Function ~A (" (lml-get-attribute x :name))
		  (awhen (lml-get-childs x)
		    (dolist (a !)
		      (when (eq (car a) :argument)
			    (format t " ~A" (or (lml-get-attribute a :name)
								    "unnamed")))))
		  (format t ")~%")
		  (setf (gethash fun-name *alien-imported-functions*) t))))))

(defun alien-import (header-path)
  (format t "Importing C header '~A'.~%" header-path)
  (format t "Running gccxml.~%")
  (execve *gccxml-path*
		  `(,*gccxml-path*
			,(string-concat "-fxml=" *alien-xml-tmp*)
			"-I/usr/local/include"
			,header-path)
		  '(("PATH" . "/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/usr/local/X11R6/bin")))
  (format t "Reading gccxml output.~%")
  (with (descr (xml-parse-file *alien-xml-tmp*))
	(alien-import-descr descr)
    (unix-sh-rm *alien-xml-tmp*)))
