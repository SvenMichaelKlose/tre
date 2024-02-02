(def-gensym argument-sym a)

(fn rename-argument (x replacements)
  (& (macro? x)
     (error "Cannot use macro name ~A as an argument name." x))
  (| (assoc-value x replacements :test #'eq)
     x))

(fn add-argument-replacements (lambda-expr replacements)
  (+ (@ [. _ (argument-sym)]
        (argument-expand-names (lambda-name lambda-expr)
                               (lambda-args lambda-expr)))
     replacements))

(fn rename-arguments-lambda (lambda-form replacements)
  (? (get-lambda-funinfo lambda-form)   ; TODO: Check if still required. (pixel)
     lambda-form
     (!= (add-argument-replacements lambda-form replacements)
       (copy-lambda lambda-form
                    :args (rename-arguments-r (lambda-args lambda-form) !)
                    :body (rename-arguments-r (lambda-body lambda-form) !)))))

(define-tree-filter2 rename-arguments-r (x &optional (replacements nil))
  (atom x)
    (rename-argument x replacements)
  (quote? x)
    x
  (any-lambda? x)
    (rename-arguments-lambda x replacements)
  (%slot-value? x)
    `(%slot-value ,(rename-arguments-r .x. replacements) ,..x.))

(fn rename-arguments (x)
  (= *argument-sym-counter* 0)
  (rename-arguments-r x))
