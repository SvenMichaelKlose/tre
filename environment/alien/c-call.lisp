;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Alien C-calls

(defstruct c-call-target
  put-arg
  call
  epilogue)

(defstruct c-call
  (funptr nil)
  (args nil))

(defun c-call-add-arg (cc value)
  "Add argument type and value to C-CALL."
  (setf (c-call-args cc) (append (c-call-args cc) (list value))))

(defun c-call-put-arg (target p val argnum)
  (funcall (c-call-target-put-arg target) p val argnum))

(defun c-call-call (cc target)
  (funcall (c-call-target-call target) (c-call-funptr cc)))

(defun c-call-epilogue (target num-args)
  (funcall (c-call-target-epilogue target) num-args))

(defun c-call-do (cc target)
  "Execute C-CALL. See also MAKE-C-CALL and C-CALL-ADD-ARG."
  (with (args (c-call-args cc)
		 code (%malloc-exec 1024) ; XXX
		 p code)

	(do ((i args (cdr i))
		 (argnum 0 (1+ argnum)))
		((not i))
	  (setf p (c-call-put-arg target p (car i) argnum)))

	(%put-list p (append (c-call-call cc target)
                         (c-call-epilogue target (length args))))

	(alien-call code)
	(%free-exec code 1024)))
