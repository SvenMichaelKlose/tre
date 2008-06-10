;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun litte-endianess? ()
  (eq *endianess* 'little))

(defun big-endianess? ()
  (eq *endianess* 'big))

(defun %put-char (ptr val)
  "Write byte to address."
  (%%set ptr val)
  (1+ ptr))

(defun %put-short (ptr val)
  "Write 16 bit integer to address. Regards *ENDIANESS*."
  (with (lo (mod val 255)
		 hi (>> val 8))
	(when (big-endianess?)
	  (%put-char ptr lo))
	(%put-char ptr hi)
	(when (little-endianess?)
	  (%put-char ptr lo))))

(defun rotate-int-char-left (x)
  (bit-or (and (<< x 24) #x00ffffff)
		  (and (>> x 24))))

(defun %put-int (ptr val)
  "Write 32 bit integer to address. Regards *ENDIANESS*."
  (when (litte-endianess?)
    (setf val (rotate-int-byte-left val)))

  (dotimes (dummy 4 p)
	(setf p (%put-char p val))
		  val (if (litte-endianess?)
				  (rotate-int-char-left val)
				  (>> val 8))))
	
(defun %put-list (ptr lst)
  "Write list of bytes to memory. Returns following address."
  (dolist (v lst ptr)
	(setf ptr (%put-char ptr v))))

(defun %put-string (ptr str)
  (dotimes (x (length str) (%put-char ptr 0))
    (setf ptr (%put-char ptr (elt str x)))))
