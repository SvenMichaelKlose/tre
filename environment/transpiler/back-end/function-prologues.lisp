;;;;; tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>

(defun funinfo-var-declarations (fi)
  (unless (transpiler-stack-locals? *current-transpiler*)
    (mapcan (fn unless (funinfo-arg? fi _)
			     `((%var ,_)))
	        (funinfo-env fi))))

(defun funinfo-copiers-to-lexicals (fi)
  (let-when lexicals (funinfo-lexicals fi)
	(let lex-sym (funinfo-lexical fi)
      `((%setq ,lex-sym (%make-lexical-array ,(length lexicals)))
        ,@(awhen (funinfo-lexical? fi lex-sym)
		    `((%set-vec ,lex-sym ,! ,lex-sym)))
        ,@(mapcan (fn & (funinfo-lexical? fi _)
				  	    `((%setq ,_ (%transpiler-native ,_))))
				  (funinfo-args fi))))))

(defun funinfo-function-prologue (fi body)
  (let fi-sym (funinfo-sym fi)
    `(,@(& (transpiler-needs-var-declarations? *current-transpiler*)
	       (funinfo-var-declarations fi))
	  (%function-prologue ,fi-sym)
	  ,@(& (transpiler-lambda-export? *current-transpiler*)
		   (funinfo-copiers-to-lexicals fi))
      ,@body
      (%function-epilogue ,fi-sym))))

(defun make-function-prologues-fun (name fun-expr)
  (let fi (get-lambda-funinfo fun-expr)
    (unless fi
	  (print fun-expr)
	  (error "no funinfo"))
    `(function
	   ,@(awhen name (list !))
	   (,@(lambda-head fun-expr)
  	    ,@(make-function-prologues-0 fi
	          (funinfo-function-prologue fi (lambda-body fun-expr)))))))

(define-tree-filter make-function-prologues-0 (fi x)
  (| (atom x)
     (%quote? x)
     (%transpiler-native? x)
     (%var? x))
    x
  (named-lambda? x)
    (make-function-prologues-fun .x. ..x.)
  (lambda? x) ; XXX Add variables to ignore in subfunctions.
    (make-function-prologues-fun nil x))

(defun make-function-prologues (x)
  (make-function-prologues-0 (transpiler-global-funinfo *current-transpiler*) x))
