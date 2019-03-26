;;;;; Caroshi – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun php-constructor-name (class-name)
  ($ class-name '-constructor))

(defun php-compiled-constructor-name (class-name)
  (compiled-function-name (php-constructor-name class-name)))

(defun php-method-name (class-name name)
  ($ class-name '- name))

(defun php-compiled-method-name (class-name name)
  (compiled-function-name (php-method-name class-name name)))

(defun php-constructor (class-name bases args body)
  (transpiler-add-defined-function *transpiler* class-name args body)
  `(function ,(php-constructor-name class-name)
             (,(. 'this args)
              (let ~%this this
                (%thisify ,class-name ,@body)))))

(define-php-std-macro defclass (class-name args &body body)
  (apply #'generic-defclass #'php-constructor class-name args body))

(define-php-std-macro defmethod (class-name name args &body body)
  (apply #'generic-defmethod class-name name args body))

(define-php-std-macro defmember (class-name &rest names)
  (apply #'generic-defmember class-name names))

(defun php-method-function (class-name x)
  `(function ,(php-method-name class-name x.)
             (,(. 'this .x.)
              (let ~%this this
	            (%thisify ,class-name ,@(| ..x. (list nil)))))))

(defun php-method-functions (class-name cls)
  (awhen (class-methods cls)
	(mapcar [php-method-function class-name _]
            (reverse !))))

(defun php-method (class-name x)
  `("public function " ,x. " " ,(php-argument-list (argument-expand-names 'php-method .x.)) ,*php-newline*
    "{" ,*php-newline*
        ,*php-indent* "return " ,(php-compiled-method-name class-name x.) ,(php-argument-list (argument-expand-names 'php-method-function-call (. 'this .x.))) ,*php-separator*
    "}"))

(defun php-members (class-name cls)
  (awhen (class-members cls)
	(mapcar [`(%%native "var $" ,_. ,*php-separator*)]
            (reverse !))))

(defun php-methods (class-name cls)
  (awhen (class-methods cls)
	(mapcan [php-method class-name _]
            (reverse !))))

(define-php-std-macro finalize-class (class-name)
  (let classes (transpiler-thisify-classes *transpiler*)
    (!? (href classes class-name)
	    `(progn
           (dont-obfuscate is_a)
	       (defun ,($ class-name '?) (x)
	         (& (object? x)
	            (is_a x ,(obfuscated-identifier class-name))
                x))
	       ,(assoc-value class-name *delayed-constructors*)
           ,@(php-method-functions class-name !)
           (%= nil (%%native
                     (%php-class-head ,class-name)
                     ,(alet (argument-expand-names 'php-constructor-function (transpiler-function-arguments *transpiler* class-name))
                        `("public function __construct " ,(php-argument-list !) ,*php-newline*
                          "{" ,*php-newline*
                              ,*php-indent* "return " ,(php-compiled-constructor-name class-name) ,(php-argument-list (. 'this !)) ,*php-separator*
                          "}")) ,*php-newline*
                     ,@(php-members class-name !)
	                 ,@(php-methods class-name !)
                     (%php-class-tail))))
	    (error "Cannot finalize undefined class ~A." class-name))))
