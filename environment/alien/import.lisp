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

(defun alien-import-print-type (data-type name &key :first t)
  (unless first
	(format t ", "))
  (format t "~A" (force-string data-type))
  (awhen name
    (format t " ~A" (force-string !))))

(defun alien-import-add-struct (hash desc)
  (with (struct-name (lml-get-attribute desc :name))
	(prog1
	  struct-name
  	  (unless (href *alien-structs* struct-name)
  	    (setf (href *alien-structs* struct-name) t)
	    (format t "[")
		(let idx -1
		  (dolist (x (split #\ (trim #\ (lml-get-attribute desc :members))))
			(1+! idx)
		    (with (field (href hash x))
			  (if (eq 'field field.)
		          (alien-import-print-type
					      (alien-import-get-type-from-desc hash field)
						  (lml-get-attribute field :name)
						  :first (= 0 idx))
			      (unless (eq 'constructor field.)
				      (and (print 'XXX)
				           (print field)))))))
	    (format t "]")))))

(defun alien-import-get-type (hash tp)
  (force-string
    (case tp.
      ('typedef	; Transcend typedefs.
	     (alien-import-get-type-from-desc hash tp))
      ('pointertype
         (string-concat (alien-import-get-type-from-desc hash tp) " *"))
      ('struct
	     (alien-import-add-struct hash tp)
         (string-concat "struct " (force-string (lml-get-attribute tp :name))))
      ('arraytype
         (format nil " ~A[~A]"
                 (alien-import-get-type-from-desc hash tp)
                 (1+ (string-integer (force-string (lml-get-attribute tp :max))))))
	  (t (aif (lml-get-attribute tp :name)
       		  !
			  (if (eq 'CVQUALIFIEDTYPE tp.)
	   		      (alien-import-get-type-from-desc hash tp)
			      (and (print tp)
				       "???")))))))

(defun alien-import-get-type-from-desc (hash a)
  (when a	; XXX
    (alien-import-get-type hash (alien-import-get-type-desc hash a))))

(defun alien-import-print (descr hash)
  (dolist (x descr)
    (when (eq x. 'function)
	  (with (fun-name (lml-get-attribute x :name))
	    (unless (href *alien-imported-functions* fun-name)
		  (format t "Function ~A ~A ("
				  (force-string (lml-get-attribute x :name))
				  (alien-import-get-type
					hash
					(href hash (lml-get-attribute x :returns))))
		  (awhen (lml-get-children x)
			(let idx -1
		      (dolist (a !)
				(1+! idx)
		        (when (eq a. 'argument)
			      (alien-import-print-type
					  (alien-import-get-type-from-desc hash a)
					  (lml-get-attribute a :name)
					  :first (= 0 idx))))))
		  (format t ")~%")
		  (setf (href *alien-imported-functions* fun-name) t))))))

(defun alien-import-descr-hash (descr)
  (with (hash (make-hash-table :test #'string=))
    (dolist (x descr hash)
      (awhen (lml-get-attribute x :id)
	    (with (h (case x.
				   ('namespace)
				   (t hash)))
		  (when h
	        (setf (href h !) x)))))))

(defun alien-import-process-xml (descr)
  (let d (lml-get-children descr)
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
  (let descr (xml2lml-file *alien-xml-tmp*)
  	(format t "Building wrapper...~%")
	(alien-import-process-xml descr)
    (unix-sh-rm *alien-xml-tmp*)))
