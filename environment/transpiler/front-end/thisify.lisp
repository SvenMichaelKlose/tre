(fn collect-slot-names (cls)
  (+ (class-slots cls)
     (!? (class-parent cls)
         (collect-slot-names !))))

(fn thisify-symbol (classdef x exclusions)
  (?
    (eq 'this x)
      '~%this
    (string== "GLOBAL" (package-name (symbol-package x)))
      (make-symbol (symbol-name x) "TRE")
    (!? (& classdef
           (not (member x exclusions :test #'eq))
           (member x classdef))
        `(%slot-value ~%this ,x)
        x)))

(fn thisify-list-0 (classdef x exclusions)
  (?
    (& x (symbol? x))
      (thisify-symbol classdef x exclusions)
    (| (atom x)
       (quote? x))
      x
    (%slot-value? x)
      `(%slot-value ,(thisify-symbol classdef .x. exclusions) ,..x.)
    (unnamed-lambda? x)
      (copy-lambda x :body (thisify-list-0 classdef
                                           (lambda-body x)
                                           (+ exclusions (lambda-args x))))
    (. (? (%slot-value? x.)
          `(%slot-value ,(thisify-list-0 classdef (cadr x.) exclusions)
                        ,(caddr x.))
          (thisify-list-0 classdef x. exclusions))
       (thisify-list-0 classdef .x exclusions))))

(fn thisify-list (classes x class-name exclusions)
  (thisify-list-0 (@ #'%slot-name
                     (collect-slot-names (href classes class-name)))
                  x exclusions))

(fn thisify-expr (x classes exclusions)
  (compiler-macroexpand
      (transpiler-macroexpand
         `((let ~%this this
             ,@(| (+ (thisify-list classes (cddr x.) (cadr x.) exclusions)
                     (thisify .x classes exclusions))
                  '(nil)))))))

(def-head-predicate %thisify)

(fn thisify (x &optional (classes (defined-classes)) (exclusions nil))
  (?
    (atom x)
      x
    (%thisify? x.)
      (thisify-expr x classes exclusions)
    (unnamed-lambda? x.)
      (. (copy-lambda x. :body (thisify (lambda-body x.)
                                        classes
                                        (+ exclusions (lambda-args x.))))
         (thisify .x classes exclusions))
    (. (thisify x. classes exclusions)
       (thisify .x classes exclusions))))
