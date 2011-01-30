;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

;; Define macro that is expanded _before_ standard macros.
(defmacro define-php-std-macro (&rest x)
  `(define-transpiler-std-macro *php-transpiler* ,@x))

(define-php-std-macro %defsetq (place &rest x)
  `(progn
     (%var ,place)
     (%setq ,place ,@x)))

(define-php-std-macro define-native-php-fun (name args &rest body)
  (apply #'shared-essential-defun (%defun-name name) args (body-with-noargs-tag body)))

(define-php-std-macro defun (name args &rest body)
  (with ((fi-sym adef) (split-funinfo-and-args args)
         fun-name (%defun-name name))
    `(%%vm-scope
       ,(apply #'shared-essential-defun fun-name args
               (? *exec-log*
                  `((%transpiler-native "echo \"" ,(string-concat (symbol-name fun-name)
                                                                  *php-newline*) "<br>\"")
                       nil ,@body)
                  body))
       ,@(unless (simple-argument-list? adef)
           (with-gensym p
             `((defun ,($ fun-name '_treexp) (,p)
                 ,(compile-argument-expansion-function-body
                      fun-name adef p nil
                      (argument-expand-names 'compile-argument-expansion adef)))))))))

(define-php-std-macro defmacro (&rest x)
  (apply #'shared-defmacro '*php-transpiler* x))

(define-php-std-macro defvar (name val)
  (let tr *php-transpiler*
    (when *show-definitions*
      (late-print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (error "variable ~A already defined" name))
    (transpiler-add-defined-variable tr name)
    `(%setq ,name ,val)))

(define-php-std-macro make-string (&optional len)
  "")

;; Translate SLOT-VALUE to unquoted variant.
(define-php-std-macro slot-value (place slot)
  `(%slot-value ,place ,(second slot)))

;; XXX Can't we do this in one macro?
(define-php-std-macro bind (fun &rest args)
  `(%bind ,(? (%slot-value? fun)
 			  .fun.
    		  (error "function must be a SLOT-VALUE, got ~A" fun))
		  ,fun))

;; X-browser MAKE-HASH-TABLE.
(defun php-transpiler-make-new-hash (x)
  `(make-hash-table
	 ,@(mapcan (fn (list (? (and (not (string? _.))
								 (eq :class _.))
						    "class" ; IE6 wants this.
							_.)
						 (second _)))
			   (group x 2))))

;; Translate arguments for call to native 'new' operator.
(defun php-transpiler-make-new-object (x)
  `(%new (%transpiler-native ,x.) ,@.x))

;; Make object if first argument is not a keyword, or string.
(define-php-std-macro new (&rest x)
  (unless x
	(error "NEW expects arguments"))
  (? (or (keyword? x.)
		 (string? x.))
	 (php-transpiler-make-new-hash x)
	 (php-transpiler-make-new-object x)))

;; Iterate over array.
(define-php-std-macro doeach ((var seq &rest result) &rest body)
  (with-gensym (evald-seq idx)
    `(with (,evald-seq ,seq)
	   (when ,evald-seq
	     (dotimes (,idx (%slot-value ,evald-seq length) ,@result)
	       (with (,var (aref ,evald-seq ,idx))
             ,@body))))))

(define-php-std-macro php-type-predicate (name &rest types)
  `(defun ,name (x)
     (when x
	   ,(? (< 1 (length types))
       	   `(or ,@(mapcar (fn `(%%%= (%php-typeof x) ,_)) types))
           `(%%%= (%php-typeof x) ,types.)))))

(define-php-std-macro href (hash key)
  `(aref ,hash ,key))

(define-php-std-macro undefined? (x)
  `(= "undefined" (%php-typeof ,x)))

(define-php-std-macro defined? (x)
  `(not (= "undefined" (%php-typeof ,x))))

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
