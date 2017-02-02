(define-gensym-generator argument-sym a)

(fn list-aliases (x)
  (when x
    (. (. x. (argument-sym))
       (list-aliases .x))))

(fn rename-argument (replacements x)
  (| (assoc-value x replacements :test #'eq)
     x))

(fn rename-arguments-lambda (replacements x)
  (? (get-lambda-funinfo x)
     x
     (alet (+ (list-aliases (expanded-lambda-args x)) replacements)
	   (copy-lambda x :args (rename-arguments-0 ! (lambda-args x))
                      :body (rename-arguments-0 ! (lambda-body x))))))

(define-tree-filter rename-arguments-0 (replacements x)
  (atom x)          (rename-argument replacements x)
  (quote? x)        x
  (any-lambda? x)   (rename-arguments-lambda replacements x)
  (%slot-value? x)  `(%slot-value ,(rename-arguments-0 replacements .x.)
				                  ,..x.))

(fn rename-arguments (x)
  (= *argument-sym-counter* 0)
  (rename-arguments-0 nil x))
