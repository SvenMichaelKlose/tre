;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defvar *body*)

(defun metacode-statement? (x)
  (| (in? x. '%setq '%set-vec '%var '%function-prologue '%function-epilogue '%function-return '%%tag)
	 (vm-jump? x)
     (%%call-nil? x)))

(defmacro metacode-walker (name args &key (if-atom nil)
					  	    	          (if-cons nil)
					  	    	          (if-setq nil)
					  	    	          (if-go nil)
					  	    	          (if-go-nil nil)
					  	    	          (if-go-not-nil nil)
									      (if-named-function nil))
  (with-cons x r args
    (with-gensym v
      `(defun ,name ,args
         (when ,x
           (let ,v (car ,x)
             (+ (?
                  (atom ,v)             ,(| if-atom `(list ,v))
                  ,@(!? if-setq         `((%setq? ,v) ,!))
                  ,@(!? if-go           `((%%go? ,v) ,!))
                  ,@(!? if-go-nil       `((%%go-nil? ,v) ,!))
                  ,@(!? if-go-not-nil   `((%%go-not-nil? ,v) ,!))
                  (%%call-nil? ,v)      (list ,v)
                  (%%call-not-nil? ,v)  (list ,v)
                  (named-lambda? ,v)    (with-temporary *funinfo* (get-lambda-funinfo ,v)
                                          (list (copy-lambda ,v :body ,(| if-named-function `(,name (lambda-body ,v) ,@r)))))

                  (not (metacode-statement? ,v))
                     (error "Metacode statement expected instead of ~A." ,v)

                  ,(| if-cons `(list ,v)))
                (,name (cdr ,x) ,@r))))))))
