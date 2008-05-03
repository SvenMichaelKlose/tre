;;;; TRE environment
;;;; Copyright (c) Sven Klose <pixel@copei.de>

(defun %put (ptr val)
  "Write byte to address."
  (%%set ptr val)
  (1+ ptr))

(defun %put-int (ptr val)
  "Write 16 bit integer to address. Regards *ENDIANESS*."
  (with (lo (mod val 255)
		 hi (>> val 8))
	(when (eq *endianess* 'big)
	  (%put ptr lo))
	(%put ptr hi)
	(when (eq *endianess* 'little)
	  (%put ptr lo))))

(defun list-memory (ptr lst)
  "Write list of bytes to memory."
  (dolist (v lst)
	(setf ptr (%put ptr v))))

;; Get standard C library's malloc() and free().
(with (libc (alien-dlopen *LIBC-PATH*)
	   alien-malloc (alien-dlsym libc "malloc")
	   alien-free (alien-dlsym libc "free"))

  (defun %malloc (size)
	"Allocate raw memory block. Free with %FREE."
    (alien-call-1 alien-malloc size))

  (defun %free (ptr)
	"Free %MALLOCed memory block."
    (alien-call-1 alien-free ptr))

  (alien-dlclose libc))
