;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defvar *show-inlines?* nil)
(defvar *opt-inline-max-levels* 1)
(defvar *opt-inline-min-size* 16)
(defvar *opt-inline-max-size* 32)
(defvar *opt-inline-max-repetitions* 0)
(defvar *opt-inline-max-small-repetitions* 0)

(defun opt-inline-import (tr x argdef body level current parent)
  (when (and (not argdef) .x)
	(print (symbol-name x.))
	(warn "REMINDER: no argument definition for function ~A" argdef))
  (when (eq t *show-inlines?*)
    (format t "; Inlining function ~A" x.))
  `(#'(,(argument-expand-names 'opt-inline-import-argexp argdef)
	   ,@(opt-inline-0 tr level current (cons x. parent)
		     (rename-body-tags
			     (transpiler-simple-expand tr body))))
          ,@(opt-inline-0 tr level current parent
		        (transpiler-simple-expand tr
  					(if (and (not argdef) .x)
					  	.x
			            (argument-expand-compiled-values 'opt-inline argdef .x))))))

(defun opt-inline-1 (tr level current parent x)
  (with (fun (symbol-function x.)
		 argdef (if (transpiler-defined-function tr x.)
					(transpiler-function-arguments tr x.)
					(function-arguments fun))
	     body (or (transpiler-function-body tr x.)
				  (function-body fun)))
	(if
	  (not body)
	    nil
	  ; XXX Need local function info, but we don't yet have any function info
	  ; where they could be looked up.
	  ; Problem: We can't just move the inliner past LAMBDA-EXPAND.
	  (not argdef)
	  	x
	  (< (tree-size body) *opt-inline-min-size*)
	     (if (< *opt-inline-max-small-repetitions* (count x. parent))
			 x
			 (opt-inline-import tr x argdef body level current parent))
	  (< *opt-inline-max-repetitions* (count x. parent))
		x
  	  (< *opt-inline-max-levels* level)
  	    x
	  (< (tree-size body) *opt-inline-max-size*)
		(opt-inline-import tr x argdef body (1+ level) current parent)
	  x)))

(defun inlineable? (tr x)
  (not (or (expander-has-macro? (transpiler-macro-expander tr) x)
		   (transpiler-dont-inline? tr x))))

(defun opt-inline-0 (tr level current parent x)
  (if
	(atom-or-quote? x)
	  x

	(atom-or-quote? x.)
	  (cons x.
			(opt-inline-0 tr level current parent .x))

	(let f (first x.)
	  (and (not (eq current f))
		   (inlineable? tr f)
		   (or (transpiler-defined-function tr f)
			   (and (atom f)
					(functionp (symbol-function f))
			 	    (not (builtinp f))))))
	  (cons (opt-inline-1 tr level current parent x.)
		    (opt-inline-0 tr level current parent .x))
	(lambda? x.)
	  (cons `#'(,@(lambda-funinfo-expr x.)
				 ,(lambda-args x.) ;,(opt-inline-0 tr level current parent (print (lambda-args x.)))
				   ,@(opt-inline-0 tr level current parent (lambda-body x.)))
		    (opt-inline-0 tr level current parent .x))
	(cons (opt-inline-0 tr level current parent x.)
		  (opt-inline-0 tr level current parent .x))))

(defun inlineable-expr? (tr x)
  (not (let-when fi (get-lambda-funinfo x)
	     (funinfo-ghost fi))))

; Only inline inside named top-level functions.
(defun opt-inline-lambda (tr x)
  `#'(,@(lambda-funinfo-and-args x)
            ,@(opt-inline-0 tr 0 'no-parent nil (lambda-body x))))

; Only inline inside named top-level functions.
(defun opt-inline-r (tr x)
  (if (atom x)
	  x
	  (cons (if (and (lambda? x.)
					 (inlineable-expr? tr x.))
			    (opt-inline-lambda tr x.)
			    (opt-inline-r tr x.))
            (opt-inline-r tr .x))))

(defun opt-inline (tr x)
;  (if (transpiler-named-functions? tr)
	  (opt-inline-r tr x))
;	  (opt-inline-0 tr 0 nil nil x)))
