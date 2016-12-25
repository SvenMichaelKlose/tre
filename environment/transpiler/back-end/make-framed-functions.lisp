(defun funinfo-var-declarations (fi)
  (unless (stack-locals?)
    (!? (funinfo-vars fi)
        `((%var ,@(remove-if [funinfo-arg? fi _] !))))))

(defun funinfo-copiers-to-scoped-vars (fi)
  (let-when scoped-vars (funinfo-scoped-vars fi)
	(let scope (funinfo-scope fi)
      `((%= ,scope (%make-scope ,(length scoped-vars)))
        ,@(!? (funinfo-scoped-var? fi scope)
		    `((%set-vec ,scope ,! ,scope)))
        ,@(mapcan [& (funinfo-scoped-var? fi _)
				     `((%= ,_ ,(? (arguments-on-stack?)
                                  `(%stackarg ,(funinfo-name fi) ,_)
                                  `(%%native ,_))))]
				  (funinfo-args fi))))))

(defun make-framed-function (x)
  (with (fi   (get-lambda-funinfo x)
         name (funinfo-name fi))
    (copy-lambda x
        :body (make-framed-functions
                  `(,@(& (needs-var-declarations?)
                         (funinfo-var-declarations fi))
                    ,@(& (function-prologues?)
                         `((%function-prologue ,name)))
                    ,@(& (lambda-export?)
                         (funinfo-copiers-to-scoped-vars fi))
                    ,@(lambda-body x)
                    (%function-epilogue ,name))))))

(define-tree-filter make-framed-functions (x)
  (named-lambda? x) (make-framed-function x))
