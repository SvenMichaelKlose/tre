(def-gensym argument-sym a)

(fn add-renamed-arguments (x replacements)
  (+ (@ [. _ (argument-sym)]
        (argument-expand-names (lambda-name x) (lambda-args x)))
     replacements))

(define-tree-filter rename-arguments-0 (x &optional (replacements nil))
  (atom x)         (| (assoc-value x replacements) x)
  (quote? x)       x
  (%slot-value? x) `(%slot-value ,(rename-arguments-0 .x. replacements) ,..x.)
  (lambda? x)
    (? (lambda-funinfo x)
       x ; Already renamed – new names would collide.
       (!= (add-renamed-arguments x replacements)
         (copy-lambda x :args (rename-arguments-0 (lambda-args x) !)
                        :body (rename-arguments-0 (lambda-body x) !)))))

(fn rename-arguments (x &optional (replacements nil))
  (= *argument-sym-counter* 0)
  (rename-arguments-0 x replacements))
