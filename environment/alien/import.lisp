;;;; TRE environment
;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Alien interface.

(defconstant *alien-xml-tmp* "__alien.tmp")
(defconstant *gccxml-path* "/usr/bin/gccxml")

(defvar *alien-imported-functions* (make-hash-table :test #'string=))
(defvar *alien-structs* (make-hash-table :test #'string=))

(defun alien-import-get-type-desc (hash desc)
  (href hash (lml-get-attribute desc :type)))

(defun alien-import-add-struct (hash desc)
  (with (struct-name (lml-get-attribute desc :name))
	(prog1
	  struct-name
  	  (unless (href *alien-structs* struct-name)
  	    (setf (href *alien-structs* struct-name) t)
	    (format t "[")
		(dolist (x (split #\ (trim #\ (lml-get-attribute desc :members))))
		  (with (field (href hash x))
			(if (eq :field field.)
		        (format t " ~A \"~A\""
					    (alien-import-get-type-from-desc hash field)
					    (lml-get-attribute field :name))
			    (unless (eq :constructor field.)
				    (and (print 'XXX)
				         (print field))))))
	    (format t "]")))))

(defun alien-import-get-type (hash tp)
  (case tp.
    (:typedef	; Transcend typedefs.
	   (alien-import-get-type-from-desc hash tp))
    (:pointertype
       (string-concat (alien-import-get-type-from-desc hash tp) " *"))
    (:struct
	   (alien-import-add-struct hash tp)
       (string-concat "struct " (lml-get-attribute tp :name)))
    (:arraytype
       (format nil " ~A[~A]"
               (alien-import-get-type-from-desc hash tp)
               (1+ (string-integer (lml-get-attribute tp :max)))))
	(t (aif (lml-get-attribute tp :name)
       		!
			(if (eq :CVQUALIFIEDTYPE tp.)
	   		    (alien-import-get-type-from-desc hash tp)
			    (and (print tp)
				     "???"))))))

(defun alien-import-get-type-from-desc (hash a)
  (when a	; XXX
    (alien-import-get-type hash (alien-import-get-type-desc hash a))))

(defun alien-import-print (descr hash)
  (dolist (x descr)
    (when (eq x. :function)
	  (with (fun-name (lml-get-attribute x :name))
	    (unless (href *alien-imported-functions* fun-name)
		  (format t "Function ~A ~A ("
				  (lml-get-attribute x :name)
				  (alien-import-get-type
					hash
					(href hash (lml-get-attribute x :returns))))
		  (awhen (lml-get-children x)
		    (dolist (a !)
		      (when (eq a. :argument)
			    (format t " (~A) ~A"
						(alien-import-get-type-from-desc hash a)
						(or (lml-get-attribute a :name)
							"unnamed")))))
		  (format t ")~%")
		  (setf (href *alien-imported-functions* fun-name) t))))))

(defun alien-import-descr-hash (descr)
  (with (hash (make-hash-table :test #'string=))
    (dolist (x descr hash)
      (awhen (lml-get-attribute x :id)
	    (with (h (case x.
				   (:namespace)
				   (t hash)))
		  (when h
	        (setf (href h !) x)))))))

(defun alien-import-process-xml (descr)
  (with (d (lml-get-children descr))
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
  (with (descr (xml2lml-file *alien-xml-tmp*))
  	(format t "Building wrapper...~%")
	(alien-import-process-xml descr)
    (unix-sh-rm *alien-xml-tmp*)))
