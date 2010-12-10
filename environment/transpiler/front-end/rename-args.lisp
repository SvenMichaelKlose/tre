;;;;; TRE compiler
;;;;; Copyright (c) 2005-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Apply this only to expanded arguments or keywords are renamed, too.

(defun find-and-add-renamed-doubles (fi old-replacements vars args)
  (let argnames (argument-expand-names 'rename-args args)
    (append (list-aliases (if (transpiler-rename-all-args? *current-transpiler*)
						  	  (if (and fi (funinfo-ghost fi))
								  .argnames
								  argnames)
							  (intersect argnames vars)))
		    old-replacements)))

(defun rename-arg (replacements x)
  (assoc-replace x replacements :test #'eq))

(defun rename-function-arguments-r (replacements env x)
  (with (args (lambda-args x)
		 new-replacements
		   (find-and-add-renamed-doubles (get-lambda-funinfo x)
										 replacements env args)
       	 renamed-args
		   (rename-function-arguments-0 new-replacements env args))
	(copy-lambda x
		:args renamed-args
		:body (rename-function-arguments-0 new-replacements
		 							       (append renamed-args env)
										   (lambda-body x)))))

;;; XXX renames top-level keyword arguments?
(define-tree-filter rename-function-arguments-0 (replacements env x)
  (atom x)
    (rename-arg replacements x)
  (%quote? x)
    x
  (lambda? x)
    (rename-function-arguments-r replacements env x)
  (%slot-value? x)
    `(%slot-value ,(rename-function-arguments-0 replacements env .x.)
				  ,..x.))

(defun rename-function-arguments-named-function (x)
  (copy-lambda x
	  :body (rename-function-arguments-0 nil nil (lambda-body x))))

(defun rename-function-arguments-inside-named-toplevel-functions (x)
  (if (atom x)
	x
    (cons (if (lambda? x.)
			    (if (transpiler-rename-toplevel-function-args? *current-transpiler*)
					(rename-function-arguments-r nil nil x.)
					(rename-function-arguments-named-function x.))
        	  (consp x.)
			    (rename-function-arguments-inside-named-toplevel-functions x.)
			  x.)
          (rename-function-arguments-inside-named-toplevel-functions .x))))

(defun rename-function-arguments (x)
  (rename-function-arguments-inside-named-toplevel-functions x))
