(def-php-transpiler-macro defclass (class-name args &body body)
  (generic-defclass #'php-constructor class-name args body))

(fn php-constructor-name (class-name)
  ($ class-name '-constructor))

(fn php-compiled-constructor-name (cls)
  (compiled-function-name (php-constructor-name (class-name cls))))

(fn php-constructor (class-name unused-base args body)
  (add-defined-function class-name args body)
  `(function ,(php-constructor-name class-name) (,(. 'this args)
     (let ~%this this
       (%thisify ,class-name
         (macrolet ((super (&rest args)
                     `((%%native "parent::__construct" ,,@args))))
           ,@body))))))

(def-php-transpiler-macro defmember (class-name &rest names)
  (generic-defmember class-name names))

(fn php-members (cls)
  (!? (class-members cls)
    (@ [`(%%native "var $" ,_. ,*php-separator*)] !)))

(def-php-transpiler-macro defmethod (class-name name args &body body)
  (generic-defmethod class-name name args body))

(fn php-method-name (cls name)
  ($ (class-name cls) '- name))

(fn php-compiled-method-name (cls name)
  (compiled-function-name (php-method-name cls name)))

(fn php-method-function (cls x)
  `(function ,(php-method-name cls x.) (,(. 'this .x.)
     (let ~%this this
       (%thisify ,(class-name cls)
         ,@(| ..x. (list nil)))))))

(fn php-method (cls x)
  (!= (argument-expand-names 'php-method .x.)
    `("function " ,x. " " ,(php-argument-list !) ,*terpri*
      "{" ,*terpri*
      ,*php-indent* "return "
          ,(php-compiled-method-name cls x.)
          ,(php-argument-list (argument-expand-names nil (. 'this .x.)))
          ,*php-separator*
      "}")))

(fn php-method-functions (cls)
  (!? (class-methods cls)
    (@ [php-method-function cls _] !)))

(fn php-methods (cls)
  (!? (class-methods cls)
    (mapcan [php-method cls _] !)))

(fn php-class (cls)
  `((%php-class-head ,cls)
    ,(!= (argument-expand-names 'php-constructor
                                (cadr (class-constructor-maker cls)))
       `("function __construct " ,(php-argument-list !) ,*terpri*
       "{" ,*terpri*
       ,*php-indent* "return "
           ,(php-compiled-constructor-name cls)
           ,(php-argument-list (. 'this !))
           ,*php-separator*
       "}")) ,*terpri*
    ,@(php-members cls)
    ,@(php-methods cls)
    (%php-class-tail)))

(def-php-transpiler-macro finalize-class (class-name)
  (let classes (defined-classes)
    (!= (| (href classes class-name)
           (error "Cannot finalize undefined class ~A." class-name))
      `(progn
         (fn ,($ class-name '?) (x)
           (& (object? x)
              (is_a x ,(convert-identifier class-name))
              x))
         ,(apply (car (class-constructor-maker !))
                 class-name (class-base !)
                 (cdr (class-constructor-maker !)))
         ,@(php-method-functions !)
         (%= nil (%%native ,@(php-class !)))))))
