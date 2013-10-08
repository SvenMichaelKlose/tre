;;;;; tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

;;; Macros and functions that don't belong here.

(defmacro with-queue-string-while (q pred &rest body)
  `(with-queue ,q
     (while ,pred (queue-string ,q)
       ,@body)))

;;; Errors.

(defvar *xml2lml-read* nil)

(defun xml-error (form &rest args)
  (princ (list-string (reverse *xml2lml-read*)))
  (error (? args
         (apply #'format t form args)
         (funcall #'format t form))))

(defun xml-error-unexpected-eof (in)
  (xml-error "Unexpected end of file."))

;;; Character functions.

(defun xml-special-char? (x)
  (in=? x #\< #\> #\/ #\: #\=))

(defun xml-whitespace? (x)
  (& (< x 33) (> x 0)))

(defun xml-text-char? (x)
  (not (in=? x #\<))); #\&)))

(defun xml-identifier-char? (x)
  (not (| (xml-special-char? x)
		  (xml-whitespace? x))))

;;; String functions

(defun xml-string-trailing-whitespaces (s)
  (do ((i (-- (length s)) (-- i))
       (n 0 (++ n)))
      ((< i 0) t)
    (unless (xml-whitespace? (elt s i))
      (return n))))

;;; Read functions.

(defun xml-read-char (in)
  (when (end-of-file? in)
    (xml-error-unexpected-eof in))
  (let c (read-char in)
	(push c *xml2lml-read*)
	c))

(defun xml-peek-char (in)
  (when (end-of-file? in)
    (xml-error-unexpected-eof in))
  (peek-char in))

(defun xml-optional-char (in ch)
  (when (== (xml-peek-char in) ch)
    (xml-read-char in)))

(defun xml-skip-spaces (in)
  (while (xml-whitespace? (xml-peek-char in)) nil
    (xml-read-char in)))

(defun xml-expect-char (in c)
  (unless (== c (xml-read-char in))
    (xml-error "Character '~A' expected." c)))

(defun xml-read-optional-slash (in)
  (xml-optional-char in #\/))

(defun xml-compress-whitespace (in)
  (xml-skip-spaces in)
  #\ )

(defun xml-read-while (in pred)
  (with-queue-string-while q (funcall pred (xml-peek-char in))
    (with (c (xml-read-char in))
      (enqueue q 
        (? (xml-whitespace? c) ; Compress whitespace sequence.
	       (xml-compress-whitespace in)
	       c)))))

(defun xml2lml-identifier (in)
  (xml-skip-spaces in)
  (unless (xml-identifier-char? (xml-peek-char in))
    (xml-error "Identifier name expected."))
  (with-queue-string-while q
    (when (xml-identifier-char? (xml-peek-char in))
      (enqueue q (xml-read-char in)))))

(defvar *xml-unified-strings* nil)

(defun xml-init-tables ()
  (setq *xml-unified-strings* (make-hash-table :test #'string==))
  (setq *xml2lml-read* nil))

(defun xml-unify-string (s)
  (& s
     (| (href *xml-unified-strings* s)
        (= (href *xml-unified-strings* s) s))))

(defun xml2lml-unify-identifier (in)
  (xml-unify-string (string-upcase (xml2lml-identifier in))))

(defun charlist-to-octalstring (x)
  (concat-stringtree
	  (filter [? (< _ 256)
				 (+ "\\" (print-octal _ nil))
				 (+ "\\u" (print-hexword _ nil))]
			  (ensure-list x))))

(defun xml2lml-entity (in)
  (xml-read-char in) ; #\&
  (let e (xml-read-while in [not (== _ #\;)])
	(prog1
	  (charlist-to-octalstring (href *xml-entities-hash* e))
	  (xml-read-char in))))

(defun xml2lml-text (in)
  (xml-skip-spaces in)
  (let txt (xml-read-while in #'xml-text-char?)
;	(? (== #\& (xml-peek-char in))
;	   (+ txt
;		   (xml2lml-entity in)
;		   (xml2lml-text in))
	    txt));)

(defun xml2lml-name (in &optional (pkg nil))
  (with (ident (xml2lml-unify-identifier in))
    (? (== (xml-peek-char in) #\:)
       (progn
	     (xml-read-char in)
	     (values ident (xml2lml-unify-identifier in)))
       (values nil (make-symbol ident pkg)))))

(defun xml2lml-quoted-string-r (in quot)
  (let c (xml-read-char in)
    (unless (== quot c)
      (cons (? (== c #\\)
			   (xml-read-char in)
        	   c)
		    (xml2lml-quoted-string-r in quot)))))

(defun xml2lml-string-symbol (s)
  (unless (string== "" s)
    (? (every [& (alpha-char? _)
			     (lower-case? _)]
		      (string-list s))
       (make-symbol (string-upcase s))
       s)))

(defun xml2lml-quoted-string (in)
  (xml-skip-spaces in)
  (let c (xml-read-char in)
    (unless (| (== c #\") (== c #\'))
      (xml-error "Quote expected."))
	(list-string (xml2lml-quoted-string-r in c))))

(defun xml2lml-attributes (in)
  (xml-skip-spaces in)
  (& (xml-identifier-char? (xml-peek-char in))
     (with ((ns name) (xml2lml-name in *keyword-package*))
       (xml-expect-char in #\=)
       `(,name ,(xml2lml-string-symbol (xml-unify-string (xml2lml-quoted-string in)))
         ,@(xml2lml-attributes in)))))

(defun xml2lml-standard-tag (in)
  (with (closing   (xml-read-optional-slash in)
         (ns name) (xml2lml-name in)
         attrs     (xml2lml-attributes in)
         inline    (xml-read-optional-slash in))
    (& inline closing
       (xml-error "`/' at start and end of tag.")) ; XXX xml-collect-error
    (| (== (xml-read-char in) #\>)
       (xml-error "End of tag expected instead of char '~A'." (stream-last-char in)))
	;(xml-issue-collected-errors)
    (values ns name
			(?
			  closing	'closing
			  inline	'inline
			  			'opening)
			attrs)))

(defun xml2lml-version-tag (in)
  (xml-expect-char in #\?)
  (while (not (& (== #\? (xml-read-char in))
			     (== #\> (xml-read-char in))))
	     (xml2lml-toplevel in)))

(defun xml-skip-decl (in)
  (while (not (== #\> (xml-read-char in)))
		 (xml2lml-toplevel in)))

(defun xml-skip-comment (in)
  (while (not (& (== #\- (xml-read-char in))
			     (== #\- (xml-read-char in))
			     (== #\> (xml-read-char in))))
		 (xml2lml-toplevel in)))

(defun xml2lml-comment-or-decl (in)
  (xml-expect-char in #\!)
  (? (& (== #\- (read-char in))
  	    (== #\- (read-char in)))
	 (xml-skip-comment in)
	 (xml-skip-decl in)))

(defun xml2lml-tag (in)
  (xml-skip-spaces in)
  (xml-expect-char in #\<)
  (xml2lml-standard-tag in))

(defun xml2lml-list (in this-ns this-name)
  (xml-skip-spaces in)
  (? (== (xml-peek-char in) #\<)
     (with ((ns name type attrs) (xml2lml-tag in))
       (case type
         'inline
  	          `((,name ,@attrs) ,@(xml2lml-list in this-ns this-name))
         'closing
              (| (& (equal ns this-ns)
			        (equal name this-name))
                 (xml-error "Closing tag for ~A:~A where ~A:~A was expected."
		                    ns name this-ns this-name))
         `(,(xml2lml-block in ns name attrs) ,@(xml2lml-list in this-ns this-name))))
  `(,(xml2lml-text in) ,@(xml2lml-list in this-ns this-name))))

(defun xml2lml-block (in ns name attrs)
  `(,name ,@attrs ,@(xml2lml-list in ns name)))

(defun xml2lml-cont-std (in)
  (xml-skip-spaces in)
  (with ((ns name type attrs) (xml2lml-standard-tag in))
	(unless (eq type 'opening)
	  (xml-error "Opening tag expected instead of ~A." type))
	(xml2lml-block in ns name attrs)))

(defun xml2lml-toplevel (in)
  (xml-skip-spaces in)
  (unless (== #\< (xml-read-char in))
	(error "Expected tag instead of text."))
  (?
	(== #\? (xml-peek-char in))
	  (xml2lml-version-tag in)
	(== #\! (xml-peek-char in))
	  (xml2lml-comment-or-decl in)
    (xml2lml-cont-std in)))

;;; Top-level
 
(defun xml2lml (in)
  (xml-init-tables)
  (xml2lml-toplevel in))

(defun xml2lml-file (name)
  (with-open-file in (open name :direction 'input)
    (xml2lml in)))
