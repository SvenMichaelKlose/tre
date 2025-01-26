(var *body*)

(defmacro metacode-walker (name
                           (x &rest r)
                           &key (if-atom nil)
                                (if-cons nil)
                                (if-setq nil)
                                (if-go nil)
                                (if-go-nil nil)
                                (if-go-not-nil nil)
                                (if-go-cond nil)
                                (if-named-function nil))
  (with-gensym v
    `(fn ,name ,(. x r)
       (when ,x
         (let ,v (car ,x)
           (+ (?
                (%native? ,v)
                  (error "%NATIVE in metacode.")
                (atom ,v)            ,(| if-atom `(… ,v))
                ,@(!? if-setq        `((%=? ,v) ,!))
                ,@(!? if-go          `((%go? ,v) ,!))
                ,@(!? if-go-nil      `((%go-nil? ,v) ,!))
                ,@(!? if-go-not-nil  `((%go-not-nil? ,v) ,!))
                ,@(!? if-go-cond     `((%go-cond? ,v) ,!))
                (%comment? ,v)       (list ,v)
                (named-lambda? ,v)
                  (with-lambda-funinfo ,v
                    (with-temporary *body* (lambda-body ,v)
                      (list (copy-lambda ,v
                                :body ,(| if-named-function
                                          `(,name (lambda-body ,v) ,@r))))))
                (%collection? ,v)
                  (list (append (list '%collection (cadr ,v))
                                (@ [. _. (,name ._)]
                                   (cddr ,v))))
                (not (metacode-statement? ,v))
                  (funinfo-error "Not a metacode statement: ~A" ,v)
                ,(| if-cons `(list ,v)))
              (,name (cdr ,x) ,@r)))))))
