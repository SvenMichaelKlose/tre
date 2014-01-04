;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun cps-marker (name)
  (& (transpiler-cps-transformation? *transpiler*)
     (every [not (transpiler-cps-exception? *transpiler* _)]
            (. name (funinfo-names *funinfo*)))))

;;;; INLINING

(defun lambda-expand-make-inline-body (stack-places values body)
  `(%%block
	 ,@(mapcar #'((stack-place init-value)
				    `(%= ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (lambda-call)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed args vals)))
      (funinfo-var-add-many *funinfo* a)
      (lambda-expand-r (lambda-expand-make-inline-body a v body)))))


;;;; EXPORT

(define-gensym-generator closure-name ~closure-)

(defun lambda-export (x)
  (with (name    (closure-name)
         args    (lambda-args x)
         body    (lambda-body x)
         new-fi  (create-funinfo :name   name
                                 :args   args
                                 :body   body
                                 :parent *funinfo*
                                 :cps?   (cps-marker name)))
    (funinfo-make-scope-arg new-fi)
    (transpiler-add-exported-closure *transpiler* `((defun ,name ,args ,@body)))
    `(%%closure ,name)))


;;;; PASSTHROUGH

(defun lambda-expand-r-unexported-lambda (x)
  (!? (get-funinfo (lambda-name x))
      (with-temporary *funinfo* !
        (copy-lambda x :body (lambda-expand-r (lambda-body x))))
      (with (name    (| (lambda-name x)
                        (funinfo-sym))
             args    (? (& (not (transpiler-cps-transformation? *transpiler*))
                           (transpiler-native-cps-function? *transpiler* name))
                        (. '~%cont (lambda-args x))
                        (lambda-args x))
             new-fi  (create-funinfo :name   name
                                     :args   args
                                     :body   (lambda-body x)
                                     :parent *funinfo*
                                     :cps?   (cps-marker name)))
        (funinfo-var-add *funinfo* name)
        (with-temporary *funinfo* new-fi
          (copy-lambda x :name name :args args :body (lambda-expand-r (lambda-body x)))))))


;;;; TOPLEVEL

(defun lambda-expand-expr (x)
  (& (%set-atom-fun? x)
     (lambda? ..x.)
     (funinfo-add-local-function-args *funinfo* .x. (lambda-args ..x.)))
  (?
    (lambda-call? x)   (lambda-call-embed x)
    (lambda? x)        (? (transpiler-lambda-export? *transpiler*)
                          (lambda-export x)
                          (lambda-expand-r-unexported-lambda x))
    (named-lambda? x)  (lambda-expand-r-unexported-lambda x)
    (lambda-expand-r x)))

(defun lambda-expand-r (x)
  (?
    (atom x)   x
    (atom x.)  (listprop-cons x x. (lambda-expand-r .x))
    (listprop-cons x (lambda-expand-expr x.)
	                 (lambda-expand-r .x))))

(defun lambda-expand (x)
  (with-global-funinfo
    (lambda-expand-r x)))
