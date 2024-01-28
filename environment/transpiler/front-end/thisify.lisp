(fn thisify-collect-methods-and-members (clsdesc)
  (+ (class-methods clsdesc)
     (class-members clsdesc)
     (!? (class-parent clsdesc)
         (thisify-collect-methods-and-members !))))

(fn thisify-symbol (classdef x exclusions)
  (?
    (eq 'this x)
      '~%this
    (string== "GLOBAL" (package-name (symbol-package x)))
      (make-symbol (symbol-name x) "TRE")
    (!? (& classdef
           (not (member x exclusions :test #'eq))
           (assoc x classdef))
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
    (lambda? x)
      (copy-lambda x :body (thisify-list-0 classdef
                                           (lambda-body x)
                                           (+ exclusions (lambda-args x))))
    (. (? (%slot-value? x.)
          `(%slot-value ,(thisify-list-0 classdef (cadr x.) exclusions)
                        ,(caddr x.))
          (thisify-list-0 classdef x. exclusions))
       (thisify-list-0 classdef .x exclusions))))

(fn thisify-list (classes x cls exclusions)
  (thisify-list-0
      (thisify-collect-methods-and-members
          (href classes cls)) x exclusions))

(def-head-predicate %thisify)

(fn thisify (x &optional (classes (defined-classes)) (exclusions nil))
  (?
    (atom x)
      x
    (%thisify? x.)
      (compiler-macroexpand
          (transpiler-macroexpand
              `((let ~%this this
                  ,@(| (+ (thisify-list classes (cddr x.) (cadr x.) exclusions)
                          (thisify .x classes exclusions))
                       '(nil))))))
    (lambda? x.)
      (. (copy-lambda x. :body (thisify (lambda-body x.)
                                        classes
                                        (+ exclusions (lambda-args x.))))
         (thisify .x classes exclusions))
    (. (thisify x. classes exclusions)
       (thisify .x classes exclusions))))
