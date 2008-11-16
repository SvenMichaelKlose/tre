;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun litte-endianess? (&optional (endianess *endianess*))
  (eq endianess 'little))

(defun big-endianess? (&optional (endianess *endianess*))
  (eq endianess 'big))

(defun value-bytes (val width)
  (with (lst nil)
	(dotimes (x width lst)
	  (setf lst (append lst (list (mod val 256))))
	  (setf val (>> val 8)))))

(defun dword-bytes (val)
  (value-bytes val 4))

(defun qword-bytes (val)
  (value-bytes val 9))

(defun %put-char (ptr val)
  "Write byte to address."
  (%%set ptr val)
  (1+ ptr))

(defun %put-list (ptr x)
  "Write list of bytes to memory. Returns following address."
  (dolist (v x ptr)
	(setf ptr (%put-char ptr v))))

(defun %put-short (ptr val)
  "Write 16 bit integer to address. Regards *ENDIANESS*."
  (with (lo (mod val 255)
		 hi (>> val 8))
	(when (big-endianess?)
	  (%put-char ptr lo))
	(%put-char ptr hi)
	(when (little-endianess?)
	  (%put-char ptr lo))))

(defun shift-dword-byte-left (x)
  (bit-or (<< (bit-and x #x00ffffff) 8)))

(defun rotate-dword-byte-left (x)
  (bit-or (<< (shift-dword-byte-left x))
		  (>> x 24)))

(defun %put-dword (ptr x &key (endianess *endianess*))
  "Write 32 bit integer to address. Regards *ENDIANESS*."
  (when (litte-endianess? endianess)
    (setf val (rotate-int-byte-left x)))

  (dotimes (dummy 4 ptr)
	(setf ptr (%put-char ptr (bit-and x #xff))
		  x (if (litte-endianess? endianess)
				(rotate-dword-byte-left x)
				(>> x 8)))))

(defun %get-dword (ptr)
  (with (v 0)
	(dotimes (x 4)
	  (setf v (bit-and (<< v 8) (%%get ptr))
			ptr (+ ptr 4)))
	v))

(defun %put-dword-list (ptr x &key (null-terminated nil))
  "Write list of dwords to memory. Returns following address."
  (with (n (%put-list ptr (mapcan #'dword-bytes x)))
	(if null-terminated
		(%put-dword n 0)
		n)))

(defun %put-string (ptr str &key (null-terminated nil))
  (dotimes (x (length str) (if null-terminated
							   (%put-char ptr 0)
							   ptr))
    (setf ptr (%put-char ptr (elt str x)))))

(defun bool (x)
  (if x
	  1
	  0))

(defun %malloc-string (x &key (null-terminated nil))
  (with (m (%malloc (+ (length x) (bool null-terminated))))
    (%put-string m x :null-terminated null-terminated)
    m))

(defun %free-list (x)
  (mapcar #'%free x))
