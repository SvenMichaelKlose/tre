;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defmacro define-js-std-macro (&rest x)
  `(define-transpiler-std-macro *js-transpiler* ,@x))

(define-js-std-macro %defsetq (&rest x)
  `(progn
	 (%var ,x.)
	 (%setq ,@x)))

(defun js-make-function-with-compiled-argument-expansion (x)
  (with-gensym g
    (when (in-cps-mode?)
      (transpiler-add-cps-function *js-transpiler* g))
    (with-lambda-content x fi args body
      `(#'((,g)
	        (setf ,g ,(copy-lambda `(function ,x)
					               :body (body-with-noargs-tag body)))
		    (setf (slot-value ,g 'tre-exp)
                  ,(compile-argument-expansion g args))
		    ,g)
		  nil))))

(define-js-std-macro function (x)
  (if (consp x)
      (with-lambda-content x fi args body
	    (if (or (body-has-noargs-tag? body)
                (simple-argument-list? args))
  		    `(function ,x)
		    (js-make-function-with-compiled-argument-expansion x)))
  	  `(function ,x)))

(defun js-cps-exception (x)
  (unless (in-cps-mode?)
    (transpiler-add-cps-exception *js-transpiler* (%defun-name x))))

(define-js-std-macro define-native-js-fun (name args &rest body)
  (js-cps-exception name)
  (apply #'shared-essential-defun name (%defun-name name) args (body-with-noargs-tag body)))

(define-js-std-macro cps-exception (x)
  (when *show-definitions*
    (print `(cps-exception ,x)))
  (setf *transpiler-except-cps?* x)
  nil)

(define-js-std-macro defun (name args &rest body)
  (with-gensym g
	(with (dname (%defun-name name)
		   n (compiled-function-name dname))
      (js-cps-exception name)
      (when (in-cps-mode?)
        (transpiler-add-cps-function *js-transpiler* dname))
	  (when (transpiler-defined-function *js-transpiler* n)
		(error "Function ~A already defined" name))
      `(progn
		 (%var ,g)
		 (%setq ,g (%unobfuscated-lookup-symbol ,(symbol-name dname) nil))
	     ,(apply #'shared-essential-defun dname n args body)
		 (setf (symbol-function ,g) ,n)))))

(define-js-std-macro defmacro (&rest x)
  (apply #'shared-defmacro '*js-transpiler* x))

(define-js-std-macro defvar (name val)
  (let tr *js-transpiler*
    (when *show-definitions*
      (late-print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (error "variable ~A already defined" name))
    (transpiler-add-defined-variable tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(define-js-std-macro make-string (&optional len)
  "")

(define-js-std-macro slot-value (place slot)
  `(%slot-value ,place ,(second slot)))

(define-js-std-macro bind (fun &rest args)
  `(%bind ,(if (%slot-value? fun)
 			 (second fun)
    		 (error "function must be a SLOT-VALUE, got ~A" fun))
		  ,fun))

(defun js-transpiler-make-new-hash (x)
  `(make-hash-table
	 ,@(mapcan (fn (list (if (and (not (stringp _.))
								  (eq :class _.))
							 "class" ; IE6 wants this.
							 _.)
						 (second _)))
			   (group x 2))))

(defun js-transpiler-make-new-object (x)
  `(%new ,@x))

(define-js-std-macro new (&rest x)
  (unless x
	(error "NEW expects arguments"))
  (if (or (keywordp x.)
		  (stringp x.))
	  (js-transpiler-make-new-hash x)
	  (js-transpiler-make-new-object x)))

(define-js-std-macro doeach ((var seq &rest result) &rest body)
  (with-gensym (evald-seq idx)
    `(let ,evald-seq ,seq
	   (when ,evald-seq
	     (dotimes (,idx (%slot-value ,evald-seq length) ,@result)
	       (let ,var (aref ,evald-seq ,idx)
             ,@body))))))

(define-js-std-macro js-type-predicate (name &rest types)
  `(defun ,name (x)
     (when x
	   ,(if (< 1 (length types))
       		`(or ,@(mapcar (fn `(%%%= (%js-typeof x) ,_))
						   types))
            `(%%%= (%js-typeof x) ,types.)))))

(define-js-std-macro href (hash key)
  `(aref ,hash ,key))

(define-js-std-macro undefined? (x)
  `(= "undefined" (%js-typeof ,x)))

(define-js-std-macro defined? (x)
  `(not (= "undefined" (%js-typeof ,x))))

(define-js-std-macro dont-obfuscate (&rest symbols)
  (when *show-definitions*
    (late-print `(dont-obfuscate ,@symbols)))
  (apply #'transpiler-add-obfuscation-exceptions
		 *js-transpiler* symbols)
  nil)

(define-js-std-macro dont-inline (x)
  (transpiler-add-inline-exception *js-transpiler* x)
  (transpiler-add-dont-inline *js-transpiler* x)
  nil)

(define-js-std-macro assert (x &optional (txt nil) &rest args)
  (when *transpiler-assert*
    (make-assertion x txt args)))

(define-js-std-macro %lx (lexicals fun)
  (eval (macroexpand `(with ,(mapcan (fn `(,_ ',_)) .lexicals.)
                        ,fun))))

(define-js-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))
