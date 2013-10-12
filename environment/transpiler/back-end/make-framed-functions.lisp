;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-var-declarations (fi)
  (unless (transpiler-stack-locals? *transpiler*)
    (mapcan [unless (funinfo-arg? fi _)
		      `((%var ,_))]
	        (funinfo-vars fi))))

(defun funinfo-copiers-to-lexicals (fi)
  (let-when lexicals (funinfo-lexicals fi)
	(let lex-sym (funinfo-lexical fi)
      `((%= ,lex-sym (%make-lexical-array ,(length lexicals)))
        ,@(!? (funinfo-lexical? fi lex-sym)
		    `((%set-vec ,lex-sym ,! ,lex-sym)))
        ,@(mapcan [& (funinfo-lexical? fi _)
				     `((%= ,_ ,(? (transpiler-arguments-on-stack? *transpiler*)
                                     `(%stackarg ,(funinfo-name fi) ,_)
                                     `(%%native ,_))))]
				  (funinfo-args fi))))))

(defun make-framed-function (x)
  (with (fi   (get-lambda-funinfo x)
         name (funinfo-name fi))
    (copy-lambda x
        :body (make-framed-functions
                  `(,@(& (transpiler-needs-var-declarations? *transpiler*)
                         (funinfo-var-declarations fi))
                    ,@(& (transpiler-function-prologues? *transpiler*)
                         `((%function-prologue ,name)))
                    ,@(& (transpiler-lambda-export? *transpiler*)
                         (funinfo-copiers-to-lexicals fi))
                    ,@(lambda-body x)
                    (%function-epilogue ,name))))))

(define-tree-filter make-framed-functions (x)
  (named-lambda? x) (make-framed-function x))
