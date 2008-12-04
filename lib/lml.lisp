;;;;; TRE environment
;;;;; Copyright (C) 2006-2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LML function library

(defun string-or-cons? (expr)
  (or (stringp expr) (consp expr)))

;;;; LML utilities

(defun lml-get-children (x)
  (when (consp x)
    (if (consp x.)
        x
        (lml-get-children .x))))

(defun lml-get-attribute (x name)
  (when x
    (unless (consp x.)
      (if (eq name x.)
          (second x)
          (lml-get-attribute .x name)))))

(defun lml-child? (expr)
  (string-or-cons? expr))

;(defun concat-attrs (expr attrs)
;  (when (not (stringp (cadr expr)))
;    (error "expected string for attribute value"))
;  (enqueue attrs (first expr) (second expr))
;  (collect-attrs (cddr expr)))

;(defun collect-attrs (expr attrs)
;  (when expr
;    (if (not (lml-child? expr))
;	    (concat-attrs expr attrs)
;	    expr)))

;(defun lml-attrs-and-childs (expr)
;  (with-queue attrs
;    (with (childs (collect-attrs expr attrs))
;      (values (queue-list attrs) childs))))

;(defmacro with-lml-expr ((name attrs childs) expr &body body)
;  (with-gensym g
;    `(with (,g ,expr
;	        ,name (first ,g))
;       (multiple-value-bind (,attrs ,childs) (lml-attrs-and-childs ,g)
;	,@body))))

;;;; LML to XML conversion

(defun print-inline (out name attrs)
  (print-tag out name :inline attrs))

(defun print-block (out name attrs childs)
  (print-tag out name :opening attrs)
  (dolist (c childs)
    (if (stringp c)
	    (write-string c out)
	    (lml-to-xml out c)))
  (print-tag out name :closing))

(defun print-list (out lst)
  (mapcar (fn lml-to-xml out x) lst))

(defun lml-to-xml (out expr)
  "Convert LML expression or list to well-formed XML."
  (when (and expr (consp expr))
    (if (consp (first expr))
	    (print-list out expr)
	    (with-lml-expr (name attrs childs) expr
	      (if childs
	          (print-block out name attrs childs)
	          (print-inline out name attrs))))))

;;;; Template evaluation

;(defun map-attrs-to-vars (attrs)
;  (group attrs 2))

;(defun eval-lml-template (tpl &optional (vars nil))
;  "Evaluuate LML template element with its attributes assigned to variables
;   of the same names. Variable !childs will contain the unevaluated list
;   of child elements."
;  (when tpl
;    (if (consp tpl.)
;	    (mapcar #'eval-lml-template tpl.)
;	    (with-lml-expr (name attrs childs) tpl
;	      (eval `(let* (,@(append (map-attrs-to-vars attrs)
;				                  `(!childs (eval-lml-template ,childs))))
;		           ,tpl))))))
