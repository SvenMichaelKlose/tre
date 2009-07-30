;;;;; TRE to C transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defvar *opt-inline-max-levels* 2)
(defvar *opt-inline-min-size* 32)
(defvar *opt-inline-max-size* 64)
(defvar *opt-inline-max-repetitions* 0)
(defvar *opt-inline-max-small-repetitions* 2)

(defun tree-size (x &optional (n 0))
  (if (consp x)
	  (+ 1 n (tree-size x.)
		     (tree-size .x))
	  n))

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
	     body (function-body fun))
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

(defun opt-inline-0 (tr level current parent x)
  (if
	(atom x)
	  x
	(atom x.)
	  (cons x. (opt-inline-0 tr level current parent .x))
	(let f (first x.)
	  (and (not (eq current f))
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
	(%quote? x.)
	  (cons x.
		    (opt-inline-0 tr level current parent .x))
	(cons (cons (first x.)
				(opt-inline-0 tr level current parent (cdr x.)))
		  (opt-inline-0 tr level current parent .x))))

(defun opt-inline (tr x)
  (when x
    (if (and (%setq? x.)
             (lambda? (third x.))
			 (not (eq 'c-init (second x.)))
			 (not (let fi (get-lambda-funinfo (third x.))
					(and fi (funinfo-ghost fi)))))
		(let fun (third x.)
          (cons `(%setq ,(second x.)
				    #'(,@(lambda-funinfo-and-args fun)
						  ,@(opt-inline-0 tr 0 (second x.) nil (lambda-body fun))))
				(opt-inline tr .x)))
        (cons x.
              (opt-inline tr .x)))))
