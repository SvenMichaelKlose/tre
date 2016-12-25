(def-head-predicate %exec)

(defun lml-attr? (x)
  (& (cons? x) (cons? .x)
     (atom x.)
     (keyword? x.)
     (| (atom .x.)
	    (%exec? .x.))))

(defun lml-body (x)
  (& x (? (lml-attr? x)
	      (lml-body ..x)
	      x)))

(defun lml2xml-end (s)
  (princ ">" s))

(defun lml2xml-end-inline (s)
  (princ "/>" s))

(defun lml2xml-open (s x)
  (princ (string-concat "<" (lml-attr-string x.)) s))

(defun lml2xml-close (s x)
  (princ (string-concat "</" (lml-attr-string x.) ">") s))

(defun lml2xml-atom (s x)
  (& x (princ x s)))

(defun lml2xml-attr (s x)
  (princ (string-concat " "
                        (lml-attr-string x.)
                        "=\""
		                (? (string? .x.)
                           .x.
                           (lml-attr-string .x.))
                        "\"")
             s)
  (lml2xml-attr-or-body s ..x))

(defun lml2xml-body (s x)
  (lml2xml-end s)
  (@ (i x)
    (lml2xml-0 s i)))

(defun lml2xml-attr-or-body (s x)
  (& x
     (? (lml-attr? x)
        (lml2xml-attr s x)
        (lml2xml-body s x))))

(defun lml2xml-block (s x)
  (lml2xml-attr-or-body s .x)
  (lml2xml-close s x))

(defun lml2xml-inline (s x)
  (lml2xml-attr-or-body s .x)
  (lml2xml-end-inline s))

(defun lml2xml-error-tagname (x)
  (error "First element is not a tag name symbol but ~A." x))

(defun lml2xml-expr (s x)
  (| (atom x.)
     (lml2xml-error-tagname x))
  (lml2xml-open s x)
  (? (lml-body .x)
     (lml2xml-block s x)
     (lml2xml-inline s x)))

(defun lml2xml-0 (s x)
  (& x
     (? (cons? x)
	    (lml2xml-expr s x)
	    (lml2xml-atom s x))))

(defun lml2xml (x &optional (str nil))
  (with-default-stream s str
	(lml2xml-0 s x)))
