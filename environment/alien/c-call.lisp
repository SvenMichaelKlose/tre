;;;;; tré – Copyright (c) 2008,2011–2014 Sven Michael Klose <pixel@copei.de>

(defstruct c-call-target
  put-arg
  call
  epilogue)

(defstruct c-call
  (funptr nil)
  (args nil))

(defun c-call-add-arg (cc value)
  (= (c-call-args cc) (append (c-call-args cc) (list value))))

(defun c-call-put-arg (target p val argnum)
  (funcall (c-call-target-put-arg target) p val argnum))

(defun c-call-call (cc target)
  (funcall (c-call-target-call target) (c-call-funptr cc)))

(defun c-call-epilogue (target num-args)
  (funcall (c-call-target-epilogue target) num-args))

(defun cpu-type? (x)
  (string== x *cpu-type*))

(defun cpu-type-x86? ()
  (some #'cpu-type? '("i386" "i486" "i586" "i686")))

(defun cpu-type-amd64? ()
  (some #'cpu-type? '("amd64" "x86_64")))

(defun c-call-do (cc)
  (with (args    (c-call-args cc)
		 code    (%malloc-exec 65536) ; XXX
		 p       code
		 target  (?
                   (cpu-type-x86?)    (make-c-call-target-x86)
                   (cpu-type-amd64?)  (make-c-call-target-amd64)
				   (error "Unsupported *CPU-TYPE*.")))
	(when (== -1 code)
	  (error "Couldn't allocate trampoline."))
	(do ((i (reverse args) (cdr i))
		 (argnum (-- (length args)) (-- argnum)))
		((not i))
	  (= p (c-call-put-arg target p (car i) argnum)))
	(%put-list p (append (c-call-call cc target)
                         (c-call-epilogue target (length args))))
	(alien-call code)
	(%free-exec code 65536))) ; XXX
