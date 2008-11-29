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
(defvar *alien-structs* (make-hash-table :test #'string=))

(defun alien-import-get-type-desc (hash desc)
  (gethash (lml-get-attribute desc :type) hash))

(defun alien-import-get-immediate-type (hash typedesc)
  (case (car typedesc)
    (:pointertype
       (string-concat (alien-import-get-type-from-desc hash typedesc) " *"))
	(t (aif (lml-get-attribute typedesc :name)
       !
	   (alien-import-get-type-from-desc hash typedesc)))))

(defun alien-import-add-struct (hash desc)
  (with (struct-name (lml-get-attribute desc :name))
	(prog1
	  struct-name
  	  (unless (gethash struct-name *alien-structs*)
  	    (setf (gethash struct-name *alien-structs*) t)
	    (format t "[")
		(dolist (x (split #\ (trim #\ (lml-get-attribute desc :members))))
		  (with (field (gethash x hash))
			(when (eq :field (car field))
		      (format t " ~A" (alien-import-get-type-from-desc hash field)))))
	    (format t "]")))))

(defun alien-import-get-type (hash tp)
  (case (car tp)
    (:typedef	; Transcend typedefs.
	   (alien-import-get-type-from-desc hash tp))
    (:struct
	   (alien-import-add-struct hash tp)
       (string-concat "struct " (lml-get-attribute tp :name)))
    (t (alien-import-get-immediate-type hash tp))))

(defun alien-import-get-type-from-desc (hash a)
  (when a	; XXX
    (alien-import-get-type hash (alien-import-get-type-desc hash a))))

(defun alien-import-print (descr hash)
  (dolist (x descr)
    (when (eq (car x) :function)
	  (with (fun-name (lml-get-attribute x :name))
	    (unless (gethash fun-name *alien-imported-functions*)
		  (format t "Function ~A (" (lml-get-attribute x :name))
		  (awhen (lml-get-childs x)
		    (dolist (a !)
		      (when (eq (car a) :argument)
			    (format t " (~A) ~A"
						(alien-import-get-type-from-desc hash a)
						(or (lml-get-attribute a :name)
							"unnamed")))))
		  (format t ")~%")
		  (setf (gethash fun-name *alien-imported-functions*) t))))))

(defun alien-import-descr-hash (descr)
  (with (hash (make-hash-table :test #'string=))
    (dolist (x descr hash)
      (awhen (lml-get-attribute x :id)
	    (with (h (case (car x)
				   (:namespace)
				   (t hash)))
		  (when h
	        (setf (gethash ! h) x)))))))

(defun alien-import-process-xml (descr)
  (with (d (lml-get-childs descr))
    (alien-import-print d (alien-import-descr-hash d))))

(defun alien-import (header-path)
  (format t "Importing C header '~A'.~%" header-path)
  (format t "Parsing '~A'...~%" header-path)
  (execve *gccxml-path*
		  `(,*gccxml-path*
			,(string-concat "-fxml=" *alien-xml-tmp*)
			"-I/usr/local/include"
			,header-path)
		  '(("PATH" . "/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/usr/local/X11R6/bin")))
  (format t "Reading metadata...~%")
  (with (descr (xml-parse-file *alien-xml-tmp*))
  	(format t "Building wrapper...~%")
	(alien-import-process-xml descr)
    (unix-sh-rm *alien-xml-tmp*)))
