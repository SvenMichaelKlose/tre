(var *body*)

(defmacro metacode-walker (name (x &rest r)
                           &key (if-atom nil)
                                (if-cons nil)
                                (if-%= nil)
                                (if-%tag nil)
                                (if-%go nil)
                                (if-%go-nil nil)
                                (if-%go-not-nil nil)
                                (if-conditional-%go nil)
                                (if-named-function nil))
  (with-gensym v
    `(fn ,name ,(. x r)
       (when ,x
         (let ,v (car ,x)
           (+ (?
                (%native? ,v)
                  (error "%NATIVE in metacode.")
                (atom ,v)
                  ,(| if-atom `(… ,v))
                ,@(!? if-%=
                      `((%=? ,v) ,!))
                ,@(!? if-%tag
                      `((%tag? ,v) ,!))
                ,@(!? if-%go
                      `((%go? ,v) ,!))
                ,@(!? if-%go-nil
                      `((%go-nil? ,v) ,!))
                ,@(!? if-%go-not-nil
                      `((%go-not-nil? ,v) ,!))
                ,@(!? if-conditional-%go
                      `((conditional-%go? ,v) ,!))
                (%comment? ,v)
                  (list ,v)
                (named-lambda? ,v)
                    (with-temporary *body* (lambda-body ,v)
                      (list (do-lambda ,v
                                :body ,(| if-named-function
                                          `(,name (lambda-body ,v) ,@r)))))
                (%collection? ,v)
                  (list (append (list '%collection (cadr ,v))
                                (@ [. '%inhibit-macro-expansion (. ._.  (,name .._))]
                                   (cddr ,v))))
                (not (metacode-statement? ,v))
                  (funinfo-error "Not a metacode statement: ~A" ,v)
                ,(| if-cons
                    `(list ,v)))
              (,name (cdr ,x) ,@r)))))))
