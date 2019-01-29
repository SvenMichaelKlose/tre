(fn multiple-value-bind-0 (forms gl body)
  (? forms
     (with-gensym gn
       `((let* ((,forms. (car ,gl))
                ,@(& .forms
                     `((,gn ,(? *assert?*
                                `(| (cdr ,gl)
                                    (%error "Not enough VALUES."))
                                `(cdr ,gl))))))
           ,@(multiple-value-bind-0 .forms gn body))))
     body))

(defmacro multiple-value-bind (forms expr &body body)
  (with-gensym (g gl)
    `(let* ((,g   ,expr)
            (,gl  (cdr ,g)))
       ,@(& *assert?*
            `((unless (eq (car ,g) *values-magic*)
                (error "VALUES expected instead of ~A." ,g))))
       ,@(multiple-value-bind-0 forms gl body))))
