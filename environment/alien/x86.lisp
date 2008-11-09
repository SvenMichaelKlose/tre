;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Alien C-call x86 support

;;;; MACHINE INSTRUCTIONS

(defun x86-push-const-dword (val)
  `(#x68 ,@(dword-bytes val)))

(defun x86-mov-eax-const (val)
  `(#xb8 ,@(dword-bytes val)))

(defun x86-call-eax ()
  `(#xff #xd0))

(defun x86-add-esp-const (val)
  `(#x81 #xc4 ,@(dword-bytes val)))

(defun x86-ret ()
  `(#xc3))

;;;; CONFIGURATION

(defun x86-c-call-put-arg (p val argnum)
  (%put-list p (x86-push-const-dword val)))

(defun x86-c-call (ptr)
  (append (x86-mov-eax-const ptr)
		  (x86-call-eax)))

(defun x86-c-call-epilogue (num-args)
  (append (x86-add-esp-const (* 4 num-args)) 
    	  (x86-ret)))

(defun make-c-target-x86 ()
  (make-c-call-target
	:put-arg	#'x86-c-call-put-arg
	:call		#'x86-c-call
	:epilogue	#'x86-c-call-epilogue))
