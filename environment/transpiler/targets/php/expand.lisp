;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

;; Define macro that is expanded _before_ standard macros.
(defmacro define-php-std-macro (&rest x)
  `(define-transpiler-std-macro *php-transpiler* ,@x))

;; (FUNCTION symbol | lambda-expression)
;; Add symbol to list of wanted functions or obfuscate arguments of
;; LAMBDA-expression.
(define-php-std-macro function (name &optional (x 'only-name))
  `(function ,name ,@(unless (eq 'only-name x)
					   (list x))))

(defun php-assert-body (x)
  (if (and (not *transpiler-assert*) ; XXX should be removed by optimizer anyway
           (stringp x.))
      .x
      x))

;; (DEFUN ...)
;;
;; XXX Assign function to symbol
;; XXX This could be generic.
(defun php-essential-defun (name args &rest body)
  (when *show-definitions*
    (late-print `(defun ,name ,@(awhen args (list !)))))
  (with (n (%defun-name name)
		 asserted-body (php-assert-body body)
		 tr *php-transpiler*
		 (fi-sym a) (split-funinfo-and-args args))
    (transpiler-add-function-args tr n a)
    (transpiler-add-function-body tr n (remove 'no-args
											   asserted-body
											   :test #'eq))
	(transpiler-add-defined-function tr n)
    `(function ,n (,@(awhen fi-sym
					   `(%funinfo ,!))
				   ,a
   		           ,@asserted-body))))

(define-php-std-macro define-native-php-fun (name args &rest body)
  (apply #'php-essential-defun name args body))

(define-php-std-macro defun (&rest args)
  (apply #'php-essential-defun args))

(define-php-std-macro defmacro (name &rest x)
  (when *show-definitions*
    (late-print `(defmacro ,name ,(awhen x. (list !)))))
  (eval (macroexpand `(define-php-std-macro ,name ,@x)))
  nil)

(define-php-std-macro defvar (name val)
  (let tr *php-transpiler*
    (when *show-definitions*
      (late-print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (error "variable ~A already defined" name))
    (transpiler-add-defined-variable tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(define-php-std-macro make-string (&optional len)
  "")

;; Translate SLOT-VALUE to unquoted variant.
(define-php-std-macro slot-value (place slot)
  `(%slot-value ,place ,(second slot)))

;; XXX Can't we do this in one macro?
(define-php-std-macro bind (fun &rest args)
  `(%bind ,(if (%slot-value? fun)
 			 (second fun)
    		 (error "function must be a SLOT-VALUE, got ~A" fun))
		  ,fun))

;; X-browser MAKE-HASH-TABLE.
(defun php-transpiler-make-new-hash (x)
  `(make-hash-table
	 ,@(mapcan (fn (list (if (and (not (stringp _.))
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
  (if (or (keywordp x.)
		  (stringp x.))
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

;; Make type predicate function.
(define-php-std-macro php-type-predicate (name &rest types)
  `(defun ,name (x)
     (when x
	   ,(if (< 1 (length types))
       		`(or ,@(mapcar (fn `(%%%= (%php-typeof x) ,_))
						   types))
            `(%%%= (%php-typeof x) ,types.)))))

(define-php-std-macro href (hash key)
  `(aref ,hash ,key))

(define-php-std-macro undefined? (x)
  `(= "undefined" (%php-typeof ,x)))

(define-php-std-macro defined? (x)
  `(not (= "undefined" (%php-typeof ,x))))

; XXX generic function instead of append!
(define-php-std-macro dont-obfuscate (&rest symbols)
  (apply #'transpiler-add-obfuscation-exceptions
		 *php-transpiler* symbols)
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
