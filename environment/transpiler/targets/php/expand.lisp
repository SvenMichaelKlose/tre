;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-php-std-macro (&rest x)
  `(define-transpiler-std-macro *php-transpiler* ,@x))

(define-php-std-macro %defsetq (place &rest x)
  `(%%vm-scope
     (%var ,place)
     (%setq ,place ,@x)
     ((slot-value ,(list 'quote place) 'sf) ,(compiled-function-name-string *current-transpiler* place))))

(define-php-std-macro define-native-php-fun (name args &body body)
  `(%%vm-scope
     ,@(apply #'shared-defun name args (body-with-noargs-tag body))
     (%setq ~%ret nil)))

(transpiler-wrap-invariant-to-binary define-php-std-macro eq 2 eq &)

(define-php-std-macro not (&rest x)
  (funcall #'shared-not x))

(define-php-std-macro defun (name args &body body)
  (with ((fi-sym adef) (split-funinfo-and-args args)
         fun-name (%defun-name name))
    `(%%vm-scope
       ,@(apply #'shared-defun fun-name args
                (? *exec-log*
                   `((%transpiler-native "error_log (\"" ,(symbol-name fun-name) "\")")
                        nil ,@body)
                   body))
       (%setq ~%ret nil)
       ,@(unless (simple-argument-list? adef)
           (with-gensym p
             `((defun ,($ fun-name '_treexp) (,p)
                 ,(compile-argument-expansion-function-body
                      fun-name adef p nil
                      (argument-expand-names 'compile-argument-expansion adef))))))
       (%setq ~%ret nil))))

(define-php-std-macro defmacro (name args &body x)
  (apply #'shared-defmacro name args x))

(define-php-std-macro defvar (name &optional (val '%%no-value))
  (funcall #'shared-defvar name val))

(define-php-std-macro define-external-variable (name)
  (print-definition `(define-external-variable ,name))
  (& (transpiler-defined-variable *current-transpiler* name)
     (redef-warn "redefinition of variable ~A." name))
  (transpiler-add-defined-variable *current-transpiler* name)
  nil)

(define-php-std-macro defconstant (&rest x)
  `(defvar ,@x))

(define-php-std-macro %%u=-car (val x)
  (shared-=-car val x))

(define-php-std-macro %%u=-cdr (val x)
  (shared-=-cdr val x))

(define-php-std-macro make-string (&optional len)
  "")

;; Translate SLOT-VALUE to unquoted variant.
(define-php-std-macro slot-value (place slot)
  `(%slot-value ,place ,(cadr slot)))

(define-php-std-macro bind (fun &rest args)
  `(%bind ,(? (%slot-value? fun)
 			  .fun.
    		  (error "function must be a SLOT-VALUE, got ~A" fun))
		  ,fun))

(defun php-transpiler-make-new-hash (x)
  `(%make-hash-table ,@x))

(defun php-transpiler-make-new-object (x)
  `(%new ,@x))

(define-php-std-macro new (&rest x)
  (unless x
	(error "NEW expects arguments"))
  (unless (& x. (| (symbol? x.) (string? x.)))
    (error "NEW expects first argument to be a non-NIL symbol or string instead of ~A" x.))
  (? (| (keyword? x.) (string? x.))
     (php-transpiler-make-new-hash x)
     (php-transpiler-make-new-object x)))

(define-php-std-macro undefined? (x)
  `(isset ,x))

(define-php-std-macro defined? (x)
  `(not (isset ,x)))

(define-php-std-macro dont-obfuscate (&rest symbols)
  (apply #'transpiler-add-obfuscation-exceptions *current-transpiler* symbols)
  nil)

(define-php-std-macro dont-inline (&rest x)
  (adolist (x)
    (transpiler-add-inline-exception *current-transpiler* !))
  nil)

(define-php-std-macro assert (x &optional (txt nil) &rest args)
  (& *transpiler-assert*
     (make-assertion x txt args)))

(define-php-std-macro %lx (lexicals fun)
  (eval (macroexpand `(with ,(mapcan ^(,_ ',_) .lexicals.)
                        ,fun))))

(define-php-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))

(define-php-std-macro functional (&rest x)
  (print-definition `(functional ,@x))
  (append! *functionals* x)
  nil)

(define-php-std-macro in-package (n)
  (= (transpiler-current-package *js-transpiler*) (& n (make-package (symbol-name n))))
  `(%%in-package ,n))

(define-php-std-macro string-concat (&rest x)
  `(%%%string+ ,@x))

(define-php-std-macro %%%nanotime ()
  '(microtime t))

(define-php-std-macro filter (fun lst)
  (shared-opt-filter fun lst))
