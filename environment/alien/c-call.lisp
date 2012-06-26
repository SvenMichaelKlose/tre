;;;;; tré – Copyright (c) 2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(defstruct c-call-target
  put-arg
  call
  epilogue)

(defstruct c-call
  (funptr nil)
  (args nil))

(defun c-call-add-arg (cc value)
  "Add argument type and value to C-CALL."
  (= (c-call-args cc) (append (c-call-args cc) (list value))))

(defun c-call-put-arg (target p val argnum)
  (funcall (c-call-target-put-arg target) p val argnum))

(defun c-call-call (cc target)
  (funcall (c-call-target-call target) (c-call-funptr cc)))

(defun c-call-epilogue (target num-args)
  (funcall (c-call-target-epilogue target) num-args))

(defun c-call-do (cc)
  "Execute C-CALL. See also MAKE-C-CALL and C-CALL-ADD-ARG."
  (with (args (c-call-args cc)
		 code (%malloc-exec 65536) ; XXX
		 p code
		 target (?
				  (in=? *cpu-type* "i386" "i486" "i586" "i686") (make-c-call-target-x86)
				  (in=? *cpu-type* "amd64" "x86_64") (make-c-call-target-amd64)
				  (error "unsupported *CPU-TYPE*")))

	(when (== -1 code)
	  (error "couldn't allocate trampoline"))

	(do ((i (reverse args) (cdr i))
		 (argnum (1- (length args)) (1- argnum)))
		((not i))
	  (= p (c-call-put-arg target p (car i) argnum)))

	(%put-list p (append (c-call-call cc target)
                         (c-call-epilogue target (length args))))

	(alien-call code)
	(%free-exec code 65536))) ; XXX
