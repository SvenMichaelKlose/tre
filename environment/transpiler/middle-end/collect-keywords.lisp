(define-tree-filter collect-keywords (x)
  (keyword? x) 
    (prog1 x
      (codegen-expand `(quote ,x))))    ; TOOD: Should be %QUOTE?. (pixel)
