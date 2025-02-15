(var *blocks* nil)

(def-compiler-macro block (name &body body)
  (? body
     (with-metacode-tag end-tag
       (with-temporary *blocks* (. (. name end-tag) *blocks*)
         (with (b    (compiler-macroexpand body)
                head (butlast b)
                tail (car (last b)))
           `(%block
              ,@head
              ,@(? (some-%go? tail)
                   (list tail)
                   `((%= ,*return-symbol* ,tail)))
              ,end-tag
              (identity ,*return-symbol*)))))
    `(identity nil)))

(def-compiler-macro return-from (block-name expr)
  (| *blocks*
     (error "RETURN-FROM outside BLOCK."))
  (!? (assoc block-name *blocks* :test #'eq)
     `(%block
        (%= ,*return-symbol* ,expr)
        (%go ,.!))
     (error "RETURN-FROM unknown BLOCK ~A." block-name)))
