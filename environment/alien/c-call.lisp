;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Automatically generated C call wrappers.

(defstruct c-call
  (funptr nil)
  (args nil))

(defun c-call-add-arg (c-call type value)
  "Add argument type and value to C-CALL."
  (setf (c-call-args c-call)
  		(push (cons type value) (c-call-args c-call))))

(defun c-call-do (c-call)
  "Execute C-CALL. See also MAKE-C-CALL and C-CALL-ADD-ARG."
  (with (args (c-call-args c-call)
		 code (%malloc (+ 32 (* (length args) 4)))
		 p (list-memory code '(1 2 3 4 5 6)))

	(dolist (a args)
	  (setf p (%put-int p (car a) (cdr a))))

	(setf p (%put *i386-call* p)
		  p (%put-ptr (c-call-funptr c-call) p)
		  p (list-memory p '(1 2 3 4 5)))
	(alien-call code)))
