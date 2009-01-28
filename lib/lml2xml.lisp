;;;;; TRE environment
;;;;; Copyright (c) 2007-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LML-to-XML conversion

(defun lml-attr? (x)
  (and (consp x) (consp .x)
       (atom x.) (atom (second x))))

(defun lml2xml-end (s)
  (format s ">"))

(defun lml2xml-end-inline (s)
  (format s "/>"))

(defun lml2xml-open (s x)
  (format s "<~A" (lml-attr-string x.)))

(defun lml2xml-close (s x)
  (format s "</~A>" (lml-attr-string x.)))

(defun lml2xml-atom (s x)
  (format s "~A" x))

(defun lml2xml-attr (s x)
  (format s " ~A=\"~A\""
			(lml-attr-string x.)
			(if (stringp (second x))
				(second x)
				(lml-attr-string (second x))))
  (lml2xml-attr-or-body s (cddr x)))

(defun lml2xml-body (s x)
  (lml2xml-end s)
  (mapcar (fn lml2xml s _) x))

(defun lml2xml-attr-or-body (s x)
  (when x
    (if (lml-attr? x)
        (lml2xml-attr s x)
        (lml2xml-body s x))))

(defun lml2xml-block (s x)
  (lml2xml-attr-or-body s .x)
  (lml2xml-close s x))

(defun lml2xml-error-tagname (x)
  (error "First element is not a tag name: ~A" x))

(defun lml2xml-expr (s x)
  (unless (atom x.)
    (lml2xml-error-tagname x))
  (lml2xml-open s x)
  (if (cdr x)
      (lml2xml-block s x)
      (lml2xml-end-inline s)))

(defun lml2xml (s x)
  (when x
    (if (consp x)
		(lml2xml-expr s x)
		(lml2xml-atom s x))))
