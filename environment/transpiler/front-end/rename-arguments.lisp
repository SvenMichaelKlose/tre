(def-gensym argument-sym a)

(fn rename-argument (replacements x)
  (& (macro? x)
     (error "Cannot use macro name ~A as an argument name." x))
  (| (assoc-value x replacements :test #'eq)
     x))

(fn add-argument-replacements (replacements lambda-form)
  (+ (@ [. _ (argument-sym)]
        (expanded-lambda-args lambda-form))
     replacements))

(fn rename-arguments-lambda (replacements lambda-form)
  (? (get-lambda-funinfo lambda-form)   ; TODO: Check if still required. (pixel)
     lambda-form
     (!= (add-argument-replacements replacements lambda-form)
       (copy-lambda lambda-form
                    :args (rename-arguments-r ! (lambda-args lambda-form))
                    :body (rename-arguments-r ! (lambda-body lambda-form))))))

(define-tree-filter rename-arguments-r (replacements x)
  (atom x)          (rename-argument replacements x)
  (quote? x)        x
  (any-lambda? x)   (rename-arguments-lambda replacements x)
  (%slot-value? x)  `(%slot-value ,(rename-arguments-r replacements .x.)
                                  ,..x.))

(fn rename-arguments (x)
  (= *argument-sym-counter* 0)
  (rename-arguments-r nil x))
