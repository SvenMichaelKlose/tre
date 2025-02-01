(var *block-expander* (define-expander 'blockexpand))
(var *blocks* nil)

(fn blockexpand (name body)
  (? body
     (with-compiler-tag end-tag
       (with-temporary *blocks* (. (. name end-tag) *blocks*)
         (with (b     (expander-expand *block-expander* body)
                head  (butlast b)
                tail  (car (last b)))
           `(%block
              ,@head
              ,@(? (some-%go? tail)
                   (list tail)
                   `((%= ,*return-symbol* ,tail)))
              ,end-tag
              (identity ,*return-symbol*)))))
    `(identity nil)))

(def-expander-macro *block-expander* return-from (block-name expr)
  (| *blocks*
     (error "RETURN-FROM outside BLOCK."))
  (!? (assoc block-name *blocks* :test #'eq)
     `(%block
        (%= ,*return-symbol* ,expr)
        (%go ,.!))
     (error "RETURN-FROM unknown BLOCK ~A." block-name)))

(def-expander-macro *block-expander* block (name &body body)
  (blockexpand name body))

(def-compiler-macro block (name &body body)
  (blockexpand name body))
