;;;;; TRE compiler
;;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>

(defun rename-arg (replacements x)
  (assoc-replace x replacements
				 :test #'eq))

(defun doubles (a b)
  (when b
    (if (member b. a)
        (cons b. (doubles a .b))
        (doubles a .b))))

(defun list-aliases (x)
  (when x
    (cons (cons x. (gensym))
          (list-aliases .x))))

(defun find-and-add-renamed-doubles (vars old-replacements args)
  (append (list-aliases (doubles args vars))
		  old-replacements))

(defun rename-double-function-args (x &optional (replacements nil) (env nil))
  (if
	(atom x)
	  (rename-arg replacements x)
	(%quote? x)
	  x
	(lambda? x) ; XXX Add variables to ignore in subfunctions.
	  (with (args (lambda-args x)
			 new-replacements (find-and-add-renamed-doubles args
														    replacements
														    env)
        	 renamed-args (rename-double-function-args args new-replacements env))
        `#'(,@(lambda-funinfo-expr x)
			,renamed-args
		    ,@(rename-double-function-args (lambda-body x)
										   new-replacements
			 							   (append renamed-args env))))
    (%slot-value? x)
      `(%slot-value ,(rename-double-function-args .x. replacements env)
					,..x.)
    (cons (rename-double-function-args x. replacements env)
		  (rename-double-function-args .x replacements env))))
