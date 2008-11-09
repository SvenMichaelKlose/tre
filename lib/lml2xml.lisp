;;;;; TRE environment
;;;;; Copyright (c) 2007-2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LML-to-XML conversion

(defun symbol-string (x)
  (string-downcase (string (symbol-name x))))

(defun lml-attr? (x)
  (and (consp x) (consp (cdr x))
       (atom (first x)) (atom (second x))))

(defun lml2xml-end ()
  (format t ">"))

(defun lml2xml-end-inline ()
  (format t "/>"))

(defun lml2xml-open (x)
  (format t "<~A" (symbol-string (first x))))

(defun lml2xml-close (x)
  (format t "</~A>" (symbol-string (first x))))

(defun lml2xml-atom (x)
  (format t "~A" x))

(defun lml2xml-attr (x)
  (format t " ~A=\"~A\"" (symbol-string (first x)) (symbol-string (second x)))
  (lml2xml-attr-or-body (cddr x)))

(defun lml2xml-body (x)
  (lml2xml-end)
  (mapcar #'lml2xml x))

(defun lml2xml-attr-or-body (x)
  (when x
    (if (lml-attr? x)
        (lml2xml-attr x)
        (lml2xml-body x))))

(defun lml2xml-block (x)
  (lml2xml-attr-or-body (cdr x))
  (lml2xml-close x))

(defun lml2xml-error-tagname (x)
  (error "First element is not a tag name: ~A" x))

(defun lml2xml-expr (x)
  (unless (atom (first x))
    (lml2xml-error-tagname x))
  (lml2xml-open x)
  (if (cdr x)
      (lml2xml-block x)
      (lml2xml-end-inline)))

(defun lml2xml (x)
  (when x
    (if (consp x)
		(lml2xml-expr x)
		(lml2xml-atom x))))
