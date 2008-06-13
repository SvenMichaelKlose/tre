;;;; XML parser
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>

;;; Macros and functions that don't belong here.

(defun queue-string (q)
  (when (and q (queue-list q))
    (list-string (queue-list q))))

(defmacro with-queue-string-while (q pred &rest body)
  `(with-queue ,q
    (while ,pred
	   (queue-string ,q)
      ,@body)))

(defun xml-read-char (in)
  (princ (read-char in)))

(defun xml-peek-char (in)
  (peek-char in))

(defun xml-optional-char (in ch)
  (when (= (xml-peek-char in) ch)
    (xml-read-char in)))

(defun xml-node-opening (n)
  (not (or (xml-node-closing n)
	   (xml-node-inline n))))

;;; Error handling

(defun xml-error (form &rest args)
  (if args
    (error (apply #'format nil form args))
    (error (funcall #'format nil form))))

;;; Character functions

(defun xml-special-char? (c)
  (or
    (= c #\<)
    (= c #\>)
    (= c #\/)
    (= c #\:)
    (= c #\=)))

(defun xml-whitespace? (c)
  (and (< c 33) (> c 0)))

(defun xml-text-char? (c)
  (not (= c #\<)))

(defun xml-identifier-char? (c)
  (not (or (xml-special-char? c) (xml-whitespace? c))))

;;; String functios

(defun xml-string-trailing-whitespaces (s)
  (do ((i (1- (length s)) (1- i))
       (n 0 (1+ n)))
      ((< i 0) t)
    (unless (xml-whitespace? (elt s i))
      (return n))))

;;; Read functions

(defun xml-skip-spaces (in)
  (while (xml-whitespace? (xml-peek-char in)) nil
    (xml-read-char in)))

(defun xml-expect-char (in c)
  (unless (= c (xml-read-char in))
    (xml-error "character '~A' expected" c)))

(defun xml-read-optional-slash (in)
  "Read slash from stream or do dothing."
  (xml-optional-char in #\/))

(defun xml-read-while (in pred)
  "Read characters from input stream until pred returns T."
  (with-queue-string-while q
    (funcall pred (xml-peek-char in))
    (let ((c (xml-read-char in)))
      (enqueue q 
        (if (xml-whitespace? c) ; Compress whitespace sequence.
          (progn
	    (xml-skip-spaces in)
	    #\ )
	  c)))))

(defun xml-parse-identifier (in)
  "Parse XML identifier string."
  (xml-skip-spaces in)
  (unless (xml-identifier-char? (xml-peek-char in))
    (xml-error "identifier name expected"))
  (with-queue-string-while q
    (and (not (end-of-file in)) (xml-identifier-char? (xml-peek-char in)))
    (enqueue q (xml-read-char in))))

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
  (let ((ident (xml-parse-unify-identifier in)))
    (if (= (xml-peek-char in) #\:)
      (progn
	(xml-read-char in)
	(values ident (xml-parse-unify-identifier in)))
      (values nil ident))))

(defun xml-parse-quoted-string (in)
  "Read quoted string."
  (xml-skip-spaces in)
  (let ((c (xml-read-char in)))
    (unless (or (= c #\") (= c #\'))
      (xml-error "quote expected"))
    (with-queue q
      (while (not (= c (xml-peek-char in)))
        (xml-read-char in) ; Skip ending quote.
        (queue-string q)
	(when (end-of-file in)
	  (xml-error "unexpected end of file in quoted string"))
	(xml-optional-char in #\\)
        (enqueue q (xml-read-char in))))))

(defun xml-parse-attribute (in)
  "Read single attribute assigment."
  (with ((ns name) (xml-parse-name in))
    (xml-expect-char in #\=)
    (cons (cons ns name) (xml-unify-string (xml-parse-quoted-string in)))))

(defun xml-parse-attributes (in)
  "Read any number of attribute assignments."
  (xml-skip-spaces in)
  (when (xml-identifier-char? (xml-peek-char in))
    (with-queue q
      (while (xml-identifier-char? (xml-peek-char in))
	     (queue-list q)
        (enqueue q (xml-parse-attribute in))
	(xml-skip-spaces in)))))

(defun xml-parse-tag (in)
  "Read tag and return xml-node."
  (xml-skip-spaces in)
  (when (xml-optional-char in #\<)
    (with (closing   (xml-read-optional-slash in)
           (ns name) (xml-parse-name in)
           tag       `(,name ,@(xml-parse-attributes in))
           inline    (xml-read-optional-slash in))
      (unless (= (xml-read-char in) #\>)
        (xml-error "end of tag expected instead of char '~A'" (stream-last-char in)))
      (when (and inline closing)
        (xml-error "/ at start and end of tag"))
      (values tag closing inline))))

(defun xml-parse-list-1 (in node)
  (with ((n opening closing inline) (xml-parse-tag in))
    (if n
        (if inline
            n
            (if closing
                (if (eq (car node) (car n))
                    (return n)
                    (xml-error "closing tag for ~A where ~A is expected"
	                       (xml-node-name n) (xml-node-name node)))
                (setf n (append n (xml-parse-list in n)))))
        (setf n (append n (xml-parse-text in))))))

(defun xml-parse-list (in node)
  "Read child elements of node."
  (loop
    (when (end-of-file in)
      (xml-error "unexpected end of file"))
    (xml-parse-list-1 in node)))

;;; Top-level
 
(defun xml-parse (in)
  (xml-init-tables)
  (aif (xml-parse-tag in)
    (progn
      (when (xml-node-opening !)
        (setf (xml-node-childs !) (xml-parse-list in !)))
      !)
    (xml-parse-text in)))

(defun xml-parse-file (name)
  (with-open-file in (open name :direction input)
    (do ((q (make-queue)))
        ((end-of-file in) (queue-list q))
      (awhen (xml-parse in)
        (enqueue q !)
	(xml-skip-spaces in)))))

(defun xml-test ()
  (print (xml-parse-file "xschema.xml")))
