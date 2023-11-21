(defmacro with-queue-string-while (q pred &body body)
  `(with-queue ,q
     (while ,pred (queue-string ,q)
       ,@body)))

(defvar *xml2lml-read* nil)

(fn xml-error (form &rest args)
  (princ (list-string (reverse *xml2lml-read*)))
  (error (? args
            (apply #'format t form args)
            (funcall #'format t form))))

(fn xml-error-unexpected-eof (in)
  (xml-error "Unexpected end of file."))

(fn xml-special-char? (x)
  (in? x #\< #\> #\/ #\: #\=))

(fn xml-whitespace? (x)
  (& (< x 33)
     (> x 0)))

(fn xml-text-char? (x)
  (not (in? x #\<))); #\&)))

(fn xml-identifier-char? (x)
  (not (| (xml-special-char? x)
          (xml-whitespace? x))))

(fn xml-string-trailing-whitespaces (s)
  (do ((i (-- (length s)) (-- i))
       (n 0 (++ n)))
      ((< i 0) t)
    (| (xml-whitespace? (elt s i))
       (return n))))

(fn xml-peek-char (in)
  (| (peek-char in)
     (xml-error-unexpected-eof in)))

(fn xml-read-char (in)
  (xml-peek-char in)
  (aprog1 (read-char in)
    (push ! *xml2lml-read*)))

(fn xml-optional-char (in ch)
  (& (== (xml-peek-char in) ch)
     (xml-read-char in)))

(fn xml-skip-spaces (in)
  (while (xml-whitespace? (xml-peek-char in)) nil
    (xml-read-char in)))

(fn xml-expect-char (in c)
  (| (== c (xml-read-char in))
     (xml-error "Character '~A' expected." c)))

(fn xml-read-optional-slash (in)
  (xml-optional-char in #\/))

(fn xml-compress-whitespace (in)
  (xml-skip-spaces in)
  #\ )

(fn xml-read-while (in pred)
  (with-queue-string-while q (funcall pred (xml-peek-char in))
    (with (c (xml-read-char in))
      (enqueue q 
        (? (xml-whitespace? c) ; Compress whitespace sequence.
           (xml-compress-whitespace in)
           c)))))

(fn xml2lml-identifier (in)
  (xml-skip-spaces in)
  (| (xml-identifier-char? (xml-peek-char in))
     (xml-error "Identifier name expected."))
  (with-queue-string-while q
    (& (xml-identifier-char? (xml-peek-char in))
       (enqueue q (xml-read-char in)))))

(defvar *xml-unified-strings* nil)

(fn xml-init-tables ()
  (= *xml-unified-strings* (make-hash-table :test #'string==))
  (= *xml2lml-read* nil))

(fn xml-unify-string (s)
  (& s
     (| (href *xml-unified-strings* s)
        (= (href *xml-unified-strings* s) s))))

(fn xml2lml-unify-identifier (in)
  (xml-unify-string (upcase (xml2lml-identifier in))))

(fn charlist-to-octalstring (x)
  (flatten
      (@ [? (< _ 256)
            (+ "\\" (print-octal _ nil))
            (+ "\\u" (print-hexword _ nil))]
         (ensure-list x))))

(fn xml2lml-entity (in)
  (xml-read-char in) ; #\&
  (let e (xml-read-while in [not (== _ #\;)])
    (prog1
      (charlist-to-octalstring (href *xml-entities-hash* e))
      (xml-read-char in))))

(fn xml2lml-text (in)
  (xml-skip-spaces in)
  (let txt (xml-read-while in #'xml-text-char?)
;   (? (== #\& (xml-peek-char in))
;      (+ txt
;          (xml2lml-entity in)
;          (xml2lml-text in))
        txt));)

(fn xml2lml-name (in &optional (pkg nil))
  (let ident (xml2lml-unify-identifier in)
    (when (== (xml-peek-char in) #\:)
      (xml-read-char in)
      (return (values ident (xml2lml-unify-identifier in))))
    (values nil (make-symbol ident pkg))))

(fn xml2lml-quoted-string-r (in quote-char)
  (let c (xml-read-char in)
    (unless (== quote-char c)
      (. (? (== c #\\)
            (xml-read-char in)
            c)
         (xml2lml-quoted-string-r in quote-char)))))

(fn xml2lml-string-symbol (s)
  (unless (string== "" s)
    (? (every [& (alpha-char? _)
                 (lower-case? _)]
              (string-list s))
       (make-symbol (upcase s))
       s)))

(fn xml2lml-quoted-string (in)
  (xml-skip-spaces in)
  (let c (xml-read-char in)
    (| (| (== c #\")
          (== c #\'))
       (xml-error "Quote expected."))
    (list-string (xml2lml-quoted-string-r in c))))

(fn xml2lml-attributes (in)
  (xml-skip-spaces in)
  (& (xml-identifier-char? (xml-peek-char in))
     (with ((ns name) (xml2lml-name in *keyword-package*))
       (xml-expect-char in #\=)
       `(,name ,(xml2lml-string-symbol (xml-unify-string (xml2lml-quoted-string in)))
         ,@(xml2lml-attributes in)))))

(fn xml2lml-standard-tag (in)
  (with (closing   (xml-read-optional-slash in)
         (ns name) (xml2lml-name in)
         attrs     (xml2lml-attributes in)
         inline    (xml-read-optional-slash in))
    (& inline closing
       (xml-error "Slash ('/') at start and end of tag.")) ; XXX xml-collect-error
    (| (== (xml-read-char in) #\>)
       (xml-error "End of tag expected instead of char '~A'." (stream-last-char in)))
    ;(xml-issue-collected-errors)
    (values ns name
            (?
              closing   'closing
              inline    'inline
              'opening)
            attrs)))

(fn xml2lml-version-tag (in)
  (xml-expect-char in #\?)
  (while (not (& (== #\? (xml-read-char in))
                 (== #\> (xml-read-char in))))
         (xml2lml-toplevel in)))

(fn xml-skip-decl (in)
  (while (not (== #\> (xml-read-char in)))
         (xml2lml-toplevel in)))

(fn xml-skip-comment (in)
  (while (not (& (== #\- (xml-read-char in))
                 (== #\- (xml-read-char in))
                 (== #\> (xml-read-char in))))
         (xml2lml-toplevel in)))

(fn xml2lml-comment-or-decl (in)
  (xml-expect-char in #\!)
  (? (& (== #\- (read-char in))
        (== #\- (read-char in)))
     (xml-skip-comment in)
     (xml-skip-decl in)))

(fn xml2lml-tag (in)
  (xml-skip-spaces in)
  (xml-expect-char in #\<)
  (xml2lml-standard-tag in))

(fn xml2lml-list (in this-ns this-name)
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

(fn xml2lml-block (in ns name attrs)
  `(,name ,@attrs ,@(xml2lml-list in ns name)))

(fn xml2lml-cont-std (in)
  (xml-skip-spaces in)
  (with ((ns name type attrs) (xml2lml-standard-tag in))
    (| (eq type 'opening)
       (xml-error "Opening tag expected instead of ~A." type))
    (xml2lml-block in ns name attrs)))

(fn xml2lml-toplevel (in)
  (xml-skip-spaces in)
  (| (== #\< (xml-read-char in))
     (error "Expected tag instead of text."))
  (case (xml-peek-char in) :test #'==
    #\?  (xml2lml-version-tag in)
    #\!  (xml2lml-comment-or-decl in)
    (xml2lml-cont-std in)))

(fn xml2lml (in)
  (xml-init-tables)
  (xml2lml-toplevel in))

(fn xml2lml-file (name)
  (with-open-file in (open name :direction 'input)
    (xml2lml in)))
