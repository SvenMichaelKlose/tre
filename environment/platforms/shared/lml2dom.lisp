;;;;; tré – Copyright (c) 2007–2009,2011 Sven Michael Klose <pixel@copei.de>

(defun lml2dom-exec-function (x)
  (let f .x.
    (? (function? f)
	   f
	   (symbol-function f))))

(defun lml2dom-element (x doc)
  (? (eq (symbol-package x.) (make-package "XUL"))
	 (new xul-element (lml-attr-string x.) :doc doc)
     (new *element (lml-attr-string x.) :doc doc)))

(defun lml2dom-atom (parent x doc)
  (when x
    (let n (new *text-node (xml-entities-to-unicode (princ x nil)) :doc doc)
	  (? parent
		 (parent.add n)
		 n))))

(defun lml2dom-body (parent x doc)
  (dolist (i x)
	(lml2dom parent i :doc doc)))

(defun lml2dom-attr-exec-0 (elm name x)
  (let value ...x.
	(funcall (lml2dom-exec-function x) name (lml2dom-exec-param x) elm value)
	value))

(defun lml2dom-attr-exec (elm name x)
  (? (%exec? x)
	 (lml2dom-attr-exec-0 elm name x)
	 x))

(defun lml2dom-attr (elm x doc)
  (let name (lml-attr-string x.)
    (elm.write-attribute name (lml-attr-value-string (lml2dom-attr-exec elm name .x.)))
    (lml2dom-attr-or-body elm ..x doc)))

(defun lml2dom-attr-or-body (e x doc)
  (? (lml-attr? x)
	 (lml2dom-attr e x doc)
	 (lml2dom-body e x doc)))

(defun lml2dom-expr-1 (parent x doc)
  (let e (lml2dom-element x doc)
	(when parent
	  (parent.add e))
    (lml2dom-attr-or-body e .x doc)
	e))

(defun lml2dom-exec (parent x doc)
  (let children (mapcar (fn lml2dom parent _ :doc doc) ..x)
	(funcall (lml2dom-exec-function x) parent children)
	children))

(defun lml2dom-expr (parent x doc)
  (unless (atom x.)
    (lml2xml-error-tagname x))
  (? (%exec? x)
	 (lml2dom-exec parent x doc)
	 (lml2dom-expr-1 parent x doc)))

(defun lml2dom (parent x &key (doc document))
  (? (cons? x)
     (lml2dom-expr parent x doc)
	 (lml2dom-atom parent x doc)))
