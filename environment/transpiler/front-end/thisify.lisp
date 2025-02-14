; TODO: A DEF-TREE-FILTER should do nicely. (pixel)

(fn thisify-symbol (slots x exclusions)
  (?
    (eq 'this x)
      '~%this
    (string== "GLOBAL" (package-name (symbol-package x)))
      (make-symbol (symbol-name x) "TRE")
    (!? (& slots
           (not (member x exclusions :test #'eq))
           (member x slots))
        `(%slot-value ~%this ,x)
        x)))

(fn thisify-list (x class-name exclusions)
  (fn rec (slots x exclusions)
    (?
      (& x (symbol? x))
        (thisify-symbol slots x exclusions)
      (| (atom x)
         (quote? x))
        x
      (%slot-value? x)
        `(%slot-value ,(thisify-symbol slots .x. exclusions) ,..x.)
      (unnamed-lambda? x)
        (copy-lambda x :body (rec slots
                                  (lambda-body x)
                                  (+ exclusions (lambda-args x))))
      (. (? (%slot-value? x.)
            `(%slot-value ,(rec slots (cadr x.) exclusions)
                          ,(caddr x.))
            (rec slots x. exclusions))
         (rec slots .x exclusions))))
  (rec (@ #'%slot-name
          (class-and-parent-slot-names (href (defined-classes) class-name)))
       x exclusions))

(fn thisify-expr (x exclusions)
  (compiler-macroexpand
      (transpiler-macroexpand
         `((let ~%this this
             ,@(| (+ (thisify-list (cddr x.) (cadr x.) exclusions)
                     (thisify .x exclusions))
                  '(nil)))))))

(def-head-predicate %thisify)

(fn thisify (x &optional (exclusions nil))
  (?
    (atom x)
      x
    (%thisify? x.)
      (thisify-expr x exclusions)
    (unnamed-lambda? x.)
      (. (copy-lambda x. :body (thisify (lambda-body x.)
                                        (+ exclusions (lambda-args x.))))
         (thisify .x exclusions))
    (. (thisify x. exclusions)
       (thisify .x exclusions))))
