;;;;; TRE compiler
;;;;; Copyright (c) 2005-2010 Sven Klose <pixel@copei.de>

(defun funinfo-var-declarations (fi)
  (unless (transpiler-stack-locals? *current-transpiler*)
    (mapcan (fn unless (funinfo-arg? fi _)
				  `((%var ,_)))
	        (funinfo-env fi))))

(defun funinfo-copiers-to-lexicals (fi)
  (let-when lexicals (funinfo-lexicals fi)
	(let lex-sym (funinfo-lexical fi)
      `((%setq ,lex-sym (make-array ,(length lexicals)))
        ,@(awhen (funinfo-lexical? fi lex-sym)
		    `((%set-vec ,lex-sym ,! ,lex-sym)))
        ,@(mapcan (fn when (funinfo-lexical? fi _)
				  	   `((%setq ,_ (%transpiler-native ,_))))
				  (funinfo-args fi))))))

(defun funinfo-function-prologue (fi body)
  (let tags? (< 0 (funinfo-num-tags fi))
    `(,@(when (transpiler-needs-var-declarations? *current-transpiler*)
	      (funinfo-var-declarations fi))
	  ,@(when tags?
		  '((%function-prologue)))
	  ,@(when (transpiler-lambda-export? *current-transpiler*)
		  (funinfo-copiers-to-lexicals fi))
      ,@body
	  ,(if tags?
		 '(%function-epilogue)
		 '(%function-return)))))

(defun make-function-prologues-fun (name fun-expr)
  (let fi (get-lambda-funinfo fun-expr)
    (unless fi
	  (print fun-expr)
	  (error "no funinfo"))
    `(function
	   ,@(awhen name
		   (list !))
	   (,@(lambda-head fun-expr)
  	    ,@(make-function-prologues-0 fi
	          (funinfo-function-prologue fi (lambda-body fun-expr)))))))

(defun make-function-prologues-0 (fi x)
  (if
	(or (atom x)
	    (%quote? x)
		(%transpiler-native? x)
		(%var? x))
	  x

	(lambda? x) ; XXX Add variables to ignore in subfunctions.
      (make-function-prologues-fun nil x)

	(named-function-expr? x)
      (make-function-prologues-fun .x. ..x.)

    (cons (make-function-prologues-0 fi x.)
		  (make-function-prologues-0 fi .x))))

(defun make-function-prologues (x)
  (make-function-prologues-0 *global-funinfo* x))
