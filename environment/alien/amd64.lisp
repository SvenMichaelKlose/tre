;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Alien C-call AMD64 supoort

;;;; MACHINE INSTRUCTIONS

(defconstant *AMD64-REGS-DWORD*
  `(EAX ECX EDX EBX ESP EBP ESI EDI))

(defconstant *AMD64-REGS-QWORD*
  `(RAX RCX RDX RBX RSP RBP RSI RDI))

(defconstant *AMD64-REG-ARGUMENTS*
  '(RDI RSI RDX RCX))

(defun amd64-regval (x)
  (or (position x *AMD64-REGS-DWORD*)
      (position x *AMD64-REGS-QWORD*)))

(defun amd64-regval-rex (regval)
  (+ #x48 (if (< 7 regval)
			  1
			  0)))

(defun amd64-mov-reg-const-q (regval val)
  `(,(amd64-regval-rex regval)
	,(+ #xb8 (bit-and regval 7))
    ,@(qword-bytes val)))

(defun amd64-add-rsp-const-d (val)
  `(#x48 #x81 #xc4 ,@(dword-bytes val)))

(defun amd64-c-call (ptr)
  (append (amd64-mov-reg-const-q (amd64-regval 'RAX) ptr)
          (x86-call-eax)))

(defun amd64-c-call-epilogue (num-args)
  (append (amd64-add-rsp-const-d (* 8 num-args))
          (x86-ret)))

;;;; CONFIGURATION

(defun amd64-arg-regval (argnum)
  (amd64-regval (elt *AMD64-REG-ARGUMENTS* argnum)))

(defun amd64-c-call-put-arg (p val argnum)
  (if (< argnum 7)
	  (%put-list p
				 (if (< argnum 4)
		  			 (amd64-mov-reg-const-q (amd64-arg-regval argnum) val)
		  			 (amd64-mov-reg-const-q (+ argnum 4) val)))
      (%put-list (%put-list p (x86-push-const-d val))
			     (x86-push-const-d (>> val 32)))))

(defun make-c-call-target-amd64 ()
  (make-c-call-target
    :put-arg    #'amd64-c-call-put-arg
    :call       #'amd64-c-call
    :epilogue   #'amd64-c-call-epilogue))
