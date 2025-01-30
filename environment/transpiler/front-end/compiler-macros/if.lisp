(def-compiler-macro ? (&body body)
  (with (tests (group body 2)
         end   (car (last tests)))
    (unless body
      (error "Body is missing."))
    `(cl:cond
       ,@(? .end
            tests
            (+ (butlast tests) (list (. t end)))))))
