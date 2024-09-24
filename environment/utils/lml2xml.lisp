(def-head-predicate %exec) ; TODO: Does not belong here.

(fn lml-body (x)
  (& x (? (lml-attr? x)
          (lml-body ..x)
          x)))

(fn lml2xml-end (s)
  (princ ">" s))

(fn lml2xml-end-inline (s)
  (princ "/>" s))

(fn lml2xml-open (s x)
  (princ (string-concat "<" (lml-symbol-string x.)) s))

(fn lml2xml-close (s x)
  (princ (string-concat "</" (lml-symbol-string x.) ">") s))

(fn lml2xml-atom (s x)
  (& x (princ x s)))

(fn lml2xml-attr (s x)
  (princ (string-concat " " (lml-attr-string x.)) s)
  (when .x.
    (princ (string-concat "=\"" (escape-string (string .x.)) "\"") s))
  (lml2xml-attr-or-body s ..x))

(fn lml2xml-body (s x)
  (lml2xml-end s)
  (@ (i x)
    (lml2xml-0 s i)))

(fn lml2xml-attr-or-body (s x)
  (& x
     (? (lml-attr? x)
        (lml2xml-attr s x)
        (lml2xml-body s x))))

(fn lml2xml-block (s x)
  (lml2xml-attr-or-body s .x)
  (lml2xml-close s x))

(fn lml2xml-inline (s x)
  (lml2xml-attr-or-body s .x)
  (lml2xml-end-inline s))

(fn lml2xml-error-tagname (x)
  (error "First element is not a tag name symbol but ~A." x))

(fn lml2xml-expr (s x)
  (| (atom x.)
     (lml2xml-error-tagname x))
  (lml2xml-open s x)
  (? (lml-body .x)
     (lml2xml-block s x)
     (lml2xml-inline s x)))

(fn lml2xml-0 (s x)
  (& x
     (? (cons? x)
        (lml2xml-expr s x)
        (lml2xml-atom s x))))

(fn lml2xml (x &optional (str nil))
  (with-default-stream s str
    (lml2xml-0 s x)))
