;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-php-std-macro (&rest x)
  `(define-transpiler-std-macro *php-transpiler* ,@x))

(define-php-std-macro %defsetq (place &rest x)
  `(%%vm-scope
     (%var ,place)
     (%setq ,place ,@x)
     ((slot-value ,(list 'quote place) 'sf) ,(compiled-function-name-string *current-transpiler* place))))

(define-php-std-macro define-native-php-fun (name args &rest body)
  `(%%vm-scope
     ,@(apply #'shared-defun (%defun-name name) args (body-with-noargs-tag body))
     (%setq ~%ret nil)))

(transpiler-wrap-invariant-to-binary define-php-std-macro eq 2 eq and)

(define-php-std-macro not (&rest x)
  (? .x
     `(%not (list ,@x))
      `(let ,*not-gensym* t
         (? ,x. (setf ,*not-gensym* nil))
         ,*not-gensym*)))

(define-php-std-macro defun (name args &rest body)
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

(define-php-std-macro defmacro (&rest x)
  (apply #'shared-defmacro x))

(define-php-std-macro defvar (name &optional (val '%%no-value))
  (when (eq '%%no-value val)
    (setf val `',name))
  (let tr *php-transpiler*
    (when *show-definitions*
      (late-print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (redef-warn "redefinition of variable ~A.~%" name))
    (transpiler-add-defined-variable tr name)
    `(%setq ,name ,val)))

(define-php-std-macro defconstant (&rest x)
  `(defvar ,@x))

(define-php-std-macro %%usetf-car (val x)
  (shared-setf-car val x))

(define-php-std-macro %%usetf-cdr (val x)
  (shared-setf-cdr val x))

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
  `(%make-hash-table ,@(mapcan (fn list _. ._.) (group x 2))))

(defun php-transpiler-make-new-object (x)
  `(%new ,x. ,@.x))

(define-php-std-macro new (&rest x)
  (unless x
	(error "NEW expects arguments"))
  (? (or (keyword? x.)
		 (string? x.))
	 (php-transpiler-make-new-hash x)
	 (php-transpiler-make-new-object x)))

(define-php-std-macro php-type-predicate (name &rest types)
  `(defun ,name (x)
     (when x
	   ,(? (< 1 (length types))
       	   `(or ,@(mapcar (fn `(%%%= (%php-typeof x) ,_)) types))
           `(%%%= (%php-typeof x) ,types.)))))

(define-php-std-macro undefined? (x)
  `(isset ,x))

(define-php-std-macro defined? (x)
  `(not (undefined? x)))

(define-php-std-macro dont-obfuscate (&rest symbols)
  (apply #'transpiler-add-obfuscation-exceptions *php-transpiler* symbols)
  nil)

(define-php-std-macro dont-inline (x)
  (transpiler-add-inline-exception *php-transpiler* x)
  nil)

(define-php-std-macro assert (x &optional (txt nil) &rest args)
  (when *transpiler-assert*
    (make-assertion x txt args)))

(define-php-std-macro %lx (lexicals fun)
  (eval (macroexpand `(with ,(mapcan (fn `(,_ ',_)) .lexicals.)
                        ,fun))))

(define-php-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))

(define-php-std-macro functional (&rest x)
  (when *show-definitions*
    (late-print `(functional ,@x)))
  (setf *functionals* (nconc x *functionals*))
  nil)

(define-php-std-macro in-package (n)
  (setf (transpiler-current-package *js-transpiler*) (when n (make-package (symbol-name n))))
  `(%%in-package ,n))

