;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defvar *show-inlines?* nil)
(defvar *opt-inline-max-levels* 8)
(defvar *opt-inline-max-size* 16)
(defvar *opt-inline-max-repetitions* 0)

(defun opt-inline-inlined-fun (tr x argdef body level current parent)
  `#'(,(argument-expand-names 'opt-inline-import-argexp argdef)
	  ,@(opt-inline-0 tr level current (cons x. parent)
		              (rename-body-tags (transpiler-frontend-1 tr body)))))

(defun opt-inline-args-to-inlined-fun (tr x argdef body level current parent)
  (opt-inline-0 tr level current parent
	            (transpiler-frontend-1 tr (? (& (not argdef) .x)
			                                 .x
			                                 (expex-argument-expand 'opt-inline argdef .x)))))

(defun opt-inline-import (tr x argdef body level current parent)
  (& (not argdef) .x
	 (print (symbol-name x.))
	 (warn "REMINDER: no argument definition for function ~A" argdef))
  (& *show-inlines?*
     (format t "; Inlining function ~A" x.))
  `(,(opt-inline-inlined-fun tr x argdef body level current parent)
	,@(opt-inline-args-to-inlined-fun tr x argdef body level current parent)))

(defun opt-inline-1 (tr level current parent x)
  (with (fun (symbol-function x.)
		 argdef (? (transpiler-defined-function tr x.)
				   (transpiler-function-arguments tr x.)
				   (transpiler-host-function-arguments tr x.))
	     body (| (transpiler-function-body tr x.)
			     (function-body fun)))
	(?
	  (not body) nil
	  (not argdef) x
	  (< *opt-inline-max-repetitions* (count x. parent)) x
  	  (< *opt-inline-max-levels* level) x
	  (< (tree-size body) *opt-inline-max-size*) (opt-inline-import tr x argdef body (1+ level) current parent)
	  x)))

(defun inlineable? (tr x)
  (not (transpiler-inline-exception? tr x)))

(defun opt-inline-0 (tr level current parent x &key (tail? nil))
  (?
	(atom-or-%quote? x) x

	(atom-or-%quote? x.)
	  (cons x. (opt-inline-0 tr level current parent .x :tail? tail?))

	(let f x..
	  (& (not tail? (eq current f))
		 (inlineable? tr f)
		 (| (transpiler-defined-function tr f)
            (& (atom f)
               (function? (symbol-function f))
               (not (builtin? (symbol-function f)))))))
	  (cons (opt-inline-1 tr level current parent x.)
		    (opt-inline-0 tr level current parent .x))

	(lambda? x.)
	  (cons (copy-lambda x. :args (lambda-args x.)
				            :body (opt-inline-0 tr level current parent (lambda-body x.)))
		    (opt-inline-0 tr level current parent .x))

	(cons (opt-inline-0 tr level current parent x.)
		  (opt-inline-0 tr level current parent .x :tail? tail?))))

(defun inlineable-expr? (tr x)
  (not (awhen (get-lambda-funinfo x)
	     (funinfo-ghost !))))

(defun opt-inline-lambda (tr x)
  (copy-lambda x :body (opt-inline-0 tr 0 'no-parent nil (lambda-body x))))

(defun opt-inline (tr x)
  (? (atom x)
	 x
	 (cons (? (& (lambda? x.) (inlineable-expr? tr x.))
			  (opt-inline-lambda tr x.)
			  (opt-inline tr x.))
           (opt-inline tr .x))))
