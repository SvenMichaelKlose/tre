(var *body*)

(defmacro metacode-walker (name args
                           &key (if-atom nil) (if-cons nil) (if-setq nil)
                                (if-go nil) (if-go-nil nil) (if-go-not-nil nil)
                                (if-named-function nil))
  (with-cons x r args
    (with-gensym v
      `(fn ,name ,args
         (when ,x
           (let ,v (car ,x)
             (+ (?
                  (%native? ,v)
                    (error "%%NATIVE in metacode.")
                  (atom ,v)             ,(| if-atom `(… ,v))
                  ,@(!? if-setq         `((%=? ,v) ,!))
                  ,@(!? if-go           `((%go? ,v) ,!))
                  ,@(!? if-go-nil       `((%go-nil? ,v) ,!))
                  ,@(!? if-go-not-nil   `((%go-not-nil? ,v) ,!))
                  (%comment? ,v)        (… ,v)
                  (named-lambda? ,v)
                    (with-lambda-funinfo ,v
                      (with-temporary *body* (lambda-body ,v)
                        (… (copy-lambda ,v
                               :body ,(| if-named-function
                                         `(,name (lambda-body ,v) ,@r))))))
                  (%collection? ,v)
                    `((%collection (cadr ,v)
                        ,,@(@ [. _. (,name ._)] (cddr ,v))))
                  (not (metacode-statement? ,v))
                    (funinfo-error "METACODE-STATEMENT? is NIL for ~A." ,v)
                  ,(| if-cons `(… ,v)))
                (,name (cdr ,x) ,@r))))))))
