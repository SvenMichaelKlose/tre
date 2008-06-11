;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Automatically generated C call wrappers.

(defstruct c-call
  (funptr nil)
  (args nil))

(defun c-call-add-arg (cc value)
  "Add argument type and value to C-CALL."
  (setf (c-call-args cc) (nconc (c-call-args cc) (list value))))

(defun integer-bytes (x num-bytes)
  (when (> num-bytes 0)
    (cons (bit-and x #xff) (integer-bytes (>> x 8) (1- num-bytes)))))

(defun dword-bytes (x)
  (integer-bytes x 4))

(defun x86-push-const-dword (val)
  `(#x68 ,@(dword-bytes val)))

(defun x86-mov-eax-const (val)
  `(#xb8 ,@(dword-bytes val)))

(defun x86-call (val)
  `(#xe8 ,@(dword-bytes val)))

(defun x86-call-eax ()
  `(#xff #xd0))

(defun x86-add-esp-const (val)
  `(#x81 #xc4 ,@(dword-bytes val)))

(defun x86-ret ()
  `(#xc3))

(defun c-call-epilogue (num-args)
  `(,@(x86-add-esp-const (* 4 num-args)) ,@(x86-ret)))

(defun c-call-put-arg (p val)
  (%put-list p (x86-push-const-dword val)))

(defun c-call-do (cc)
  "Execute C-CALL. See also MAKE-C-CALL and C-CALL-ADD-ARG."
  (with (args (c-call-args cc)
		 code (%malloc 1024)
		 p code)

	(dolist (a (reverse args))
      (setf p (c-call-put-arg p a)))

	(%put-list p (append (x86-mov-eax-const (c-call-funptr cc))
						 (x86-call-eax)
                         (c-call-epilogue (length args))))

	(alien-call code)
	(%free code)))
