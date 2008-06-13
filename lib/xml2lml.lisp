;;;; XML parser
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>

;;; Macros and functions that don't belong here.

(defun queue-string (q)
  (when (and q (queue-list q))
    (list-string (queue-list q))))

(defmacro with-queue-string-while (q pred &rest body)
  `(with-queue ,q
    (while ,pred (queue-string ,q)
      ,@body)))


;;; Errors.

(defun xml-error (form &rest args)
  (if args
    (error (apply #'format t form args))
    (error (funcall #'format t form))))

(defun xml-error-unexpected-eof (in)
  (xml-error "unexpected end of file"))


;;; Character functions.

(defun xml-special-char? (x)
  (in=? x #\< #\> #\/ #\: #\=))

(defun xml-whitespace? (x)
  (and (< x 33) (> x 0)))

(defun xml-text-char? (x)
  (not (xml-special-char? x)))

(defun xml-identifier-char? (x)
  (not (or (xml-special-char? x)
		   (xml-whitespace? x))))


;;; String functions

(defun xml-string-trailing-whitespaces (s)
  (do ((i (1- (length s)) (1- i))
       (n 0 (1+ n)))
      ((< i 0) t)
    (unless (xml-whitespace? (elt s i))
      (return n))))


;;; Read functions.

(defun xml-read-char (in)
  (when (end-of-file in)
    (xml-error-unexpected-eof in))
  (princ (read-char in)))

(defun xml-peek-char (in)
  (when (end-of-file in)
    (xml-error-unexpected-eof in))
  (peek-char in))

(defun xml-optional-char (in ch)
  (when (= (xml-peek-char in) ch)
    (xml-read-char in)))

(defun xml-skip-spaces (in)
  (while (xml-whitespace? (xml-peek-char in)) nil
    (xml-read-char in)))

(defun xml-expect-char (in c)
  (unless (= c (xml-read-char in))
    (xml-error "character '~A' expected" c)))

(defun xml-read-optional-slash (in)
  "Read slash from stream or do dothing."
  (xml-optional-char in #\/))

(defun xml-compress-whitespace (in)
  (xml-skip-spaces in)
  #\ )

(defun xml-read-while (in pred)
  "Read characters from input stream until pred returns T."
  (with-queue-string-while q (funcall pred (xml-peek-char in))
    (with (c (xml-read-char in))
      (enqueue q 
        (if (xml-whitespace? c) ; Compress whitespace sequence.
	        (xml-compress-whitespace in)
	        c)))))

(defun xml-parse-identifier (in)
  "Parse XML identifier string."
  (xml-skip-spaces in)
  (unless (xml-identifier-char? (xml-peek-char in))
    (xml-error "identifier name expected"))
  (with-queue-string-while q
    (when (xml-identifier-char? (xml-peek-char in))
      (enqueue q (xml-read-char in)))))

(setq *xml-unified-strings* nil)

(defun xml-init-tables ()
  (setq *xml-unified-strings* (make-hash-table :test #'string=)))

(defun xml-unify-string (s)
  "Unify string."
  (when s
    (or (gethash s *xml-unified-strings*)
        (setf (gethash s *xml-unified-strings*) s))))

(defun xml-parse-unify-identifier (in)
  (let ((i (string-upcase (xml-parse-identifier in))))
    (xml-unify-string i)))

(defun xml-parse-text (in)
  "Read plain text until next tag or end of stream."
  (xml-skip-spaces in)
  (xml-read-while in #'xml-text-char?))

(defun xml-parse-name (in)
  "Parse name with optional namespace."
  (with (ident (xml-parse-unify-identifier in))
    (if (= (xml-peek-char in) #\:)
        (progn
	      (xml-read-char in)
	      (values ident (xml-parse-unify-identifier in)))
        (values nil ($ ident)))))

(defun xml-parse-quoted-string-r (in quot)
  (with (c (xml-read-char in))
    (unless (= quot c)
      (cons (if (= c #\\)
			    (xml-read-char in)
        	    c)
		    (xml-parse-quoted-string-r in quot)))))

(defun xml-parse-quoted-string (in)
  "Read quoted string."
  (xml-skip-spaces in)
  (with (c (xml-read-char in))
    (unless (or (= c #\") (= c #\'))
      (xml-error "quote expected"))
	(list-string (xml-parse-quoted-string-r in c))))

(defun xml-parse-attributes (in)
  "Read single attribute assigment."
  (xml-skip-spaces in)
  (when (xml-identifier-char? (xml-peek-char in))
    (with ((ns name) (xml-parse-name in))
      (xml-expect-char in #\=)
      `(,name ,(xml-unify-string (xml-parse-quoted-string in))
		,@(xml-parse-attributes in)))))

(defun xml-parse-standard-tag (in)
  (with (closing   (xml-read-optional-slash in)
         (ns name) (xml-parse-name in)
         attrs     (xml-parse-attributes in)
         inline    (xml-read-optional-slash in))
    (when (and inline closing)
      (xml-error "/ at start and end of tag")) ; XXX xml-collect-error
    (unless (= (xml-read-char in) #\>)
      (xml-error "end of tag expected instead of char '~A'" (stream-last-char in)))
	;(xml-issue-collected-errors)
    (values ns name
			(cond
			  (closing	'closing)
			  (inline	'inline)
			  (t		'opening))
			attrs)))

(defun xml-parse-tag (in)
  "Read tag and return xml-node."
  (xml-skip-spaces in)
  (xml-expect-char in #\<)
  (xml-parse-standard-tag in))

(defun xml-parse-list (in this-ns this-name)
  "Parse block tag (until it's closed) or inline tag."
;(format t "xml-parse-list: ~A ~A~%" this-ns this-name)
  (xml-skip-spaces in)
  (if (= (xml-peek-char in) #\<)
      (with ((ns name type attrs) (xml-parse-tag in))
	    (case type
	      ('inline
	  	       `((,name) ,@(xml-parse-list in this-ns this-name)))
	      ('closing
	           (unless (and (string= ns this-ns)
				            (string= name this-name))
                 (xml-error "closing tag for ~A:~A where ~A:~A was expected"
			                ns name this-ns this-name)))
	      (t
		       `(,(xml-parse-block in ns name attrs) ,@(xml-parse-list in this-ns this-name)))))
	  `(,(xml-parse-text in) ,@(xml-parse-list in this-ns this-name))))

(defun xml-parse-block (in ns name attrs)
  "Parse block tag (until it's closed) or inline tag."
;(format t "xml-parse-block: ~A ~A" name attrs)
  `(,name ,@attrs ,@(xml-parse-list in ns name)))

(defun xml-parse-toplevel (in)
  "Parse top-level block tag."
  (with ((ns name type attrs) (xml-parse-tag in))
	(unless (eq type 'opening)
	  (xml-error "Opening tag expected instead of ~A." type))
	(xml-parse-block in ns name attrs)))


;;; Top-level
 
(defun xml-parse (in)
  (xml-init-tables)
  (xml-parse-toplevel in))

(defun xml-parse-file (name)
  (with-open-file in (open name :direction input)
    (xml-parse in)))

(defun xml-test ()
  (print (xml-parse-file "xschema.xml")))
