;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun find-and-add-renamed-doubles (fi old-replacements vars args)
  (let argnames (remove-keywords (argument-expand-names 'rename-args args))
    (append (list-aliases (? (transpiler-rename-all-args? *transpiler*)
						  	 (? (& fi (funinfo-ghost fi))
								.argnames
								argnames)
							 (intersect argnames vars)))
		    old-replacements)))

(defun rename-arg (replacements x)
  (| (assoc-value x replacements :test #'eq) x))

(define-tree-filter rename-function-arguments-0 (replacements env x)
  (atom x)         (rename-arg replacements x)
  (%quote? x)      x
  (lambda? x)      (rename-function-arguments-r replacements env x)
  (%slot-value? x) `(%slot-value ,(rename-function-arguments-0 replacements env .x.)
				                 ,..x.))

(defun rename-function-arguments-r (replacements env x)
  (with (args             (lambda-args x)
		 new-replacements (find-and-add-renamed-doubles (get-lambda-funinfo x) replacements env args)
       	 renamed-args     (rename-function-arguments-0 new-replacements env args))
	(copy-lambda x :args renamed-args
		           :body (rename-function-arguments-0 new-replacements (append renamed-args env) (lambda-body x)))))

(defun rename-function-arguments-named-function (x)
  (copy-lambda x :body (rename-function-arguments-0 nil nil (lambda-body x))))

(defun rename-function-arguments-inside-named-toplevel-functions (x)
  (? (atom x)
	 x
     (cons (? (| (lambda? x.)
                 (named-lambda? x.))
                (? (transpiler-rename-toplevel-function-args? *transpiler*)
				   (rename-function-arguments-r nil nil x.)
				   (rename-function-arguments-named-function x.))
        	  (cons? x.)
                (rename-function-arguments-inside-named-toplevel-functions x.)
			  x.)
           (rename-function-arguments-inside-named-toplevel-functions .x))))

(defun rename-function-arguments (x)
  (rename-function-arguments-inside-named-toplevel-functions x))
