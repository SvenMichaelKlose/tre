; tré – Copyright (c) 2008–2010,2012–2016 Sven Michael Klose <pixel@copei.de>

; XXX This doesn't work yet!

(defconstant *alien-xml-tmp* "__alien.tmp")
(defconstant *gccxml-path* "/usr/bin/gccxml")

(defvar *alien-imported-functions* (make-hash-table :test #'string==))
(defvar *alien-structs* (make-hash-table :test #'string==))

(defun alien-import-get-type-desc (hash desc)
  (href hash (lml-get-attribute desc :type)))

(defun alien-import-print-type (data-type name &key (first t))
  (| first (format t ", "))
  (format t "~A" (string data-type))
  (awhen name
    (format t " ~A" (string !))))

(defun alien-import-add-struct (hash desc)
  (with (struct-name (lml-get-attribute desc :name))
	(prog1
	  struct-name
  	  (unless (href *alien-structs* struct-name)
  	    (= (href *alien-structs* struct-name) t)
	    (format t "[")
		(let idx -1
		  (@ (x (split #\  (trim (lml-get-attribute desc :members) " ")))
			(++! idx)
		    (with (field (href hash x))
			  (? (eq 'field field.)
		         (alien-import-print-type (alien-import-get-type-from-desc hash field)
					                      (lml-get-attribute field :name)
					                      :first (== 0 idx))
			     (unless (eq 'constructor field.)
			       (print 'XXX)
			       (print field))))))
	    (format t "]")))))

(defun alien-import-get-type (hash tp)
  (string
    (case tp.
      'typedef	; Transcend typedefs.
	     (alien-import-get-type-from-desc hash tp)
      'pointertype
         (string-concat (alien-import-get-type-from-desc hash tp) " *")
      'struct
         {(alien-import-add-struct hash tp)
          (string-concat "struct " (string (lml-get-attribute tp :name)))}
      'arraytype
         (format nil " ~A[~A]"
                 (alien-import-get-type-from-desc hash tp)
                 (++ (string-integer (string (lml-get-attribute tp :size)))))
	  (? (lml-get-attribute tp :name)
	     (? (eq 'CVQUALIFIEDTYPE tp.)
	   	    (alien-import-get-type-from-desc hash tp)
		    (& (print tp) "???"))))))

(defun alien-import-get-type-from-desc (hash a)
  (when a	; XXX
    (alien-import-get-type hash (alien-import-get-type-desc hash a))))

(defun alien-import-print (descr hash)
  (@ (x descr)
    (& (eq x. 'function)
	   (let fun-name (string (lml-get-attribute x :name))
	     (unless (href *alien-imported-functions* fun-name)
		   (format t "Function ~A ~A ("
				   (string (lml-get-attribute x :name))
				   (alien-import-get-type hash (href hash (lml-get-attribute x :returns))))
		   (awhen (lml-get-children x)
			 (let idx -1
		       (@ (a !)
				 (++! idx)
		         (& (eq a. 'argument)
			        (alien-import-print-type (alien-import-get-type-from-desc hash a) (lml-get-attribute a :name) :first (== 0 idx))))))
		   (format t ")~%")
		   (= (href *alien-imported-functions* fun-name) t))))))

(defun alien-import-descr-hash (descr)
  (with (hash (make-hash-table :test #'string==))
    (@ (x descr hash)
      (awhen (lml-get-attribute x :id)
	    (with (h (case x.
				   'namespace nil
				   hash))
		  (when h
	        (= (href h !) x)))))))

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
