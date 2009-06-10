;;;; XML parser
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>

;;; Macros and functions that don't belong here.

(defmacro with-queue-string-while (q pred &rest body)
  `(with-queue ,q
     (while ,pred (queue-string ,q)
       ,@body)))

;;; Errors.

(defvar *xml2lml-read* nil)

(defun xml-error (form &rest args)
  (princ (list-string (reverse *xml2lml-read*)))
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
  (not (in=? x #\< #\&)))

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
  (let c (read-char in)
	(push! c *xml2lml-read*)
	c))

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

(defun xml2lml-identifier (in)
  "Parse XML identifier string."
  (xml-skip-spaces in)
  (unless (xml-identifier-char? (xml-peek-char in))
    (xml-error "identifier name expected"))
  (with-queue-string-while q
    (when (xml-identifier-char? (xml-peek-char in))
      (enqueue q (xml-read-char in)))))

(defvar *xml-unified-strings* nil)

(defun xml-init-tables ()
  (setq *xml-unified-strings* (make-hash-table :test #'string=))
  (setq *xml2lml-read* nil))

(defun xml-unify-string (s)
  "Unify string."
  (when s
    (or (href *xml-unified-strings* s)
        (setf (href *xml-unified-strings* s) s))))

(defun xml2lml-unify-identifier (in)
  (let i (string-upcase (xml2lml-identifier in))
    (xml-unify-string i)))

(defun xml2lml-entity (in)
  (xml-read-char in) ; #\&
  (let e (xml-read-while in (fn (not (= _ #\;))))
	(prog1
	  (concat-stringtree
		  (mapcar (fn (+ "\\" (print-octal _ nil)))
				  (force-list (href *xml-entities-hash* e))))
	  (xml-read-char in))))

(defun xml2lml-text (in)
  "Read plain text until next tag or end of stream."
  (xml-skip-spaces in)
  (let txt (xml-read-while in #'xml-text-char?)
	(if (= #\& (xml-peek-char in))
		(+ txt
		   (xml2lml-entity in)
		   (xml2lml-text in))
	    txt)))

(defun xml2lml-name (in &optional (pkg nil))
  "Parse name with optional namespace."
  (with (ident (xml2lml-unify-identifier in))
    (if (= (xml-peek-char in) #\:)
        (progn
	      (xml-read-char in)
	      (values ident (xml2lml-unify-identifier in)))
        (values nil (make-symbol ident pkg)))))

(defun xml2lml-quoted-string-r (in quot)
  (with (c (xml-read-char in))
    (unless (= quot c)
      (cons (if (= c #\\)
			    (xml-read-char in)
        	    c)
		    (xml2lml-quoted-string-r in quot)))))

(defun xml2lml-string-symbol (s)
  (unless (string= "" s)
    (if (every (fn (and (alpha-char-p _)
					    (lower-case-p _)))
			   (string-list s))
	    (make-symbol (string-upcase s))
	    s)))

(defun xml2lml-quoted-string (in)
  "Read quoted string."
  (xml-skip-spaces in)
  (let c (xml-read-char in)
    (unless (or (= c #\") (= c #\'))
      (xml-error "quote expected"))
	(list-string (xml2lml-quoted-string-r in c))))

(defun xml2lml-attributes (in)
  "Read single attribute assigment."
  (xml-skip-spaces in)
  (when (xml-identifier-char? (xml-peek-char in))
    (with ((ns name) (xml2lml-name in
									 *keyword-package*))
      (xml-expect-char in #\=)
      `(,name ,(xml2lml-string-symbol
				   (xml-unify-string
					   (xml2lml-quoted-string in)))
		  ,@(xml2lml-attributes in)))))

(defun xml2lml-standard-tag (in)
  (with (closing   (xml-read-optional-slash in)
         (ns name) (xml2lml-name in)
         attrs     (xml2lml-attributes in)
         inline    (xml-read-optional-slash in))
    (when (and inline closing)
      (xml-error "/ at start and end of tag")) ; XXX xml-collect-error
    (unless (= (xml-read-char in) #\>)
      (xml-error "end of tag expected instead of char '~A'" (stream-last-char in)))
	;(xml-issue-collected-errors)
    (values ns name
			(if
			  closing	'closing
			  inline	'inline
			  			'opening)
			attrs)))

(defun xml2lml-version-tag (in)
  (xml-expect-char in #\?)
  (while (not (and (= #\? (xml-read-char in))
				   (= #\> (xml-read-char in))))
	     (xml2lml-toplevel in)))

(defun xml-skip-decl (in)
  (while (not (= #\> (xml-read-char in)))
		 (xml2lml-toplevel in)))

(defun xml-skip-comment (in)
  (while (not (and (= #\- (xml-read-char in))
				   (= #\- (xml-read-char in))
				   (= #\> (xml-read-char in))))
		 (xml2lml-toplevel in)))

(defun xml2lml-comment-or-decl (in)
  (xml-expect-char in #\!)
  (if (and (= #\- (read-char in))
  		   (= #\- (read-char in)))
	  (xml-skip-comment in)
	  (xml-skip-decl in)))

(defun xml2lml-tag (in)
  "Read tag and return xml-node."
  (xml-skip-spaces in)
  (xml-expect-char in #\<)
  (xml2lml-standard-tag in))

(defun xml2lml-list (in this-ns this-name)
  "Parse block tag (until it's closed) or inline tag."
  (xml-skip-spaces in)
  (if (= (xml-peek-char in) #\<)
      (with ((ns name type attrs) (xml2lml-tag in))
	    (case type
	      ('inline
	  	       `((,name ,@attrs) ,@(xml2lml-list in this-ns this-name)))
	      ('closing
	           (unless (and (string= ns this-ns)
				            (string= name this-name))
                 (xml-error "closing tag for ~A:~A where ~A:~A was expected"
			                ns name this-ns this-name)))
	      (t
		       `(,(xml2lml-block in ns name attrs) ,@(xml2lml-list in this-ns this-name)))))
	  `(,(xml2lml-text in) ,@(xml2lml-list in this-ns this-name))))

(defun xml2lml-block (in ns name attrs)
  "Parse block tag (until it's closed) or inline tag."
  `(,name ,@attrs ,@(xml2lml-list in ns name)))

(defun xml2lml-cont-std (in)
  (xml-skip-spaces in)
  (with ((ns name type attrs) (xml2lml-standard-tag in))
	(unless (eq type 'opening)
	  (xml-error "Opening tag expected instead of ~A." type))
	(xml2lml-block in ns name attrs)))

(defun xml2lml-toplevel (in)
  "Parse top-level block tag."
  (xml-skip-spaces in)
  (unless (= #\< (xml-read-char in))
	(error "expected tag instead of text"))
  (if
	(= #\? (xml-peek-char in))
	  (xml2lml-version-tag in)
	(= #\! (xml-peek-char in))
	  (xml2lml-comment-or-decl in)
    (xml2lml-cont-std in)))

;;; Top-level
 
(defun xml2lml (in)
  (xml-init-tables)
  (xml2lml-toplevel in))

(defun xml2lml-file (name)
  (with-open-file in (open name :direction 'input)
    (xml2lml in)))
