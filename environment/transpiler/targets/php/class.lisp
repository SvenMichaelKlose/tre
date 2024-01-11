(fn php-constructor-name (class-name)
  ($ class-name '-constructor))

(fn php-compiled-constructor-name (class-name)
  (compiled-function-name (php-constructor-name class-name)))

(fn php-method-name (class-name name)
  ($ class-name '- name))

(fn php-compiled-method-name (class-name name)
  (compiled-function-name (php-method-name class-name name)))

(fn php-constructor (class-name unused-base args body)
  (add-defined-function class-name args body)
  `(function ,(php-constructor-name class-name)
             (,(. 'this args)
              (let ~%this this
                (%thisify ,class-name
                  (macrolet ((super (&rest args)
                              `((%%native "parent::__construct" ,,@args))))
                    ,@body))))))

(def-php-transpiler-macro defclass (class-name args &body body)
  (generic-defclass #'php-constructor class-name args body))

(def-php-transpiler-macro defmethod (class-name name args &body body)
  (generic-defmethod class-name name args body))

(def-php-transpiler-macro defmember (class-name &rest names)
  (generic-defmember class-name names))

(fn php-method-function (class-name x)
  `(function ,(php-method-name class-name x.)
             (,(. 'this .x.)
              (let ~%this this
                (%thisify ,class-name ,@(| ..x. (list nil)))))))

(fn php-method-functions (class-name cls)
  (awhen (class-methods cls)
    (@ [php-method-function class-name _]
       (reverse !))))

(fn php-method (class-name x)
  `("public function " ,x. " " ,(php-argument-list (argument-expand-names 'php-method .x.)) ,*terpri*
    "{" ,*terpri*
        ,*php-indent* "return " ,(php-compiled-method-name class-name x.) ,(php-argument-list (argument-expand-names 'php-method-function-call (. 'this .x.))) ,*php-separator*
    "}"))

(fn php-members (class-name cls)
  (awhen (class-members cls)
    (@ [`(%%native "var $" ,_. ,*php-separator*)]
       (reverse !))))

(fn php-methods (class-name cls)
  (awhen (class-methods cls)
    (mapcan [php-method class-name _]
            (reverse !))))

(def-php-transpiler-macro finalize-class (class-name)
  (let classes (defined-classes)
    (!? (href classes class-name)
        `(progn
           (fn ,($ class-name '?) (x)
             (& (object? x)
                (is_a x ,(convert-identifier class-name))
                x))
           ,(apply (car (class-constructor-maker !))
                   class-name (class-base !)
                   (cdr (class-constructor-maker !)))
           ,@(php-method-functions class-name !)
           (%= nil (%%native
                     (%php-class-head ,class-name)
                     ,(!= (argument-expand-names 'php-constructor (transpiler-function-arguments *transpiler* class-name))
                        `("public function __construct " ,(php-argument-list !) ,*terpri*
                          "{" ,*terpri*
                              ,*php-indent* "return " ,(php-compiled-constructor-name class-name) ,(php-argument-list (. 'this !)) ,*php-separator*
                          "}")) ,*terpri*
                     ,@(php-members class-name !)
                     ,@(php-methods class-name !)
                     (%php-class-tail))))
        (error "Cannot finalize undefined class ~A." class-name))))
