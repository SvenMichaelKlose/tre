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
                  (atom ,v)             ,(| if-atom `(list ,v))
                  ,@(!? if-setq         `((%=? ,v) ,!))
                  ,@(!? if-go           `((%go? ,v) ,!))
                  ,@(!? if-go-nil       `((%go-nil? ,v) ,!))
                  ,@(!? if-go-not-nil   `((%go-not-nil? ,v) ,!))
                  (%comment? ,v)       (list ,v)
                  (named-lambda? ,v)
                    (with-lambda-funinfo ,v
                      (list (copy-lambda ,v
                                :body ,(| if-named-function
                                          `(,name (lambda-body ,v) ,@r)))))
                  (not (metacode-statement? ,v))
                    (funinfo-error "METACODE-STATEMENT? is NIL for ~A." ,v)
                  ,(| if-cons `(list ,v)))
                (,name (cdr ,x) ,@r))))))))
