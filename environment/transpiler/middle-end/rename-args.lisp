;;;;; TRE compiler
;;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Apply this only to expanded arguments or keywords are renamed, too.

(defun find-and-add-renamed-doubles (fi args old-replacements vars)
  (let argnames (argument-expand-names 'rename-args args)
    (append (list-aliases (if (transpiler-rename-all-args? *current-transpiler*)
						  	  (if (and fi (funinfo-ghost fi))
								  .argnames
								  argnames)
							  (doubles argnames vars)))
		    old-replacements)))

(defun rename-arg (replacements x)
  (assoc-replace x replacements :test #'eq))

;;; XXX renames top-level keyword arguments?
(defun rename-function-arguments-0 (x &optional (replacements nil) (env nil))
  (if
	(atom x)
	  (rename-arg replacements x)
	(%quote? x)
	  x
	(lambda? x)
	  (with (args (lambda-args x)
			 new-replacements (find-and-add-renamed-doubles (get-lambda-funinfo x)
															args replacements env)
        	 renamed-args (rename-function-arguments-0 args new-replacements env))
        `#'(,@(lambda-funinfo-expr x)
			,renamed-args
		    ,@(rename-function-arguments-0 (lambda-body x)
										     new-replacements
			 							     (append renamed-args env))))
    (%slot-value? x)
      `(%slot-value ,(rename-function-arguments-0 .x. replacements env)
					,..x.)
    (cons (rename-function-arguments-0 x. replacements env)
		  (rename-function-arguments-0 .x replacements env))))

(defun rename-function-arguments-named-function (x)
  `#'(,@(lambda-funinfo-and-args x)
			,@(rename-function-arguments-0 (lambda-body x))))

(defun rename-function-arguments-inside-named-toplevel-functions (x)
  (if (atom x)
	x
    (cons (if (lambda? x.) (rename-function-arguments-named-function x.)
        	  (consp x.)   (rename-function-arguments-inside-named-toplevel-functions x.)
			  x.)
          (rename-function-arguments-inside-named-toplevel-functions .x))))

(defun rename-function-arguments (x)
  (rename-function-arguments-inside-named-toplevel-functions x))
