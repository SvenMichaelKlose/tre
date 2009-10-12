;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defvar *opt-inline-max-levels* 3)
(defvar *opt-inline-min-size* 32)
(defvar *opt-inline-max-size* 64)
(defvar *opt-inline-max-repetitions* 0)
(defvar *opt-inline-max-small-repetitions* 0)

(defun opt-inline-import (tr x argdef body level current parent)
  (format t "; Inlining function ~A" x.)
  `(#'(,(argument-expand-names 'opt-inline argdef)
	   ,@(opt-inline-0 tr
					   level
					   current
					   (cons x. parent)
					   (rename-body-tags
					       (transpiler-simple-expand tr body))))
      ,@(transpiler-simple-expand tr
			(argument-expand-compiled-values 'opt-inline argdef .x))))

(defun opt-inline-1 (tr level current parent x)
  (with (fun (symbol-function x.)
		 argdef (if (transpiler-defined-function tr x.)
					(transpiler-function-arguments tr x.)
					(function-arguments fun))
	     body (or (transpiler-function-body tr x.)
				  (function-body fun)
				  (error "no body for function ~A" x.)))
	(if
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
	(atom x)
	  x
	(or (atom x.)
		(%quote? x.))
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
	  (cons `#'(,@(lambda-funinfo-and-args x.)
				   ,@(opt-inline-0 tr level current parent (lambda-body x.)))
		    (opt-inline-0 tr level current parent .x))
	(cons (cons (first x.)
				(opt-inline-0 tr level current parent (cdr x.)))
		  (opt-inline-0 tr level current parent .x))))

(defun inlineable-expr? (tr x)
  (not (or (transpiler-inline-exception? tr (second x))
           (let-when fi (get-lambda-funinfo (third x))
		     (funinfo-ghost fi)))))

(defun opt-inline (tr x)
  (if (atom x)
	  x
	  (cons (if (and (%setq? x.)
       				 (lambda? (third x.)))
				(if (inlineable-expr? tr x.)
                    (let fun (third x.)
				      `(%setq ,(second x.)
				          #'(,@(lambda-funinfo-and-args fun)
						        ,@(opt-inline-0 tr 0 (second x.) nil
								      (lambda-body fun)))))
        	      	x.)
			    (opt-inline tr x.))
            (opt-inline tr .x))))
