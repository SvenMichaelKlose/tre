; tré – Copyright (c) 2008–2009,2012,2015 Sven Michael Klose <pixel@copei.de>

(defun little-endianess? (&optional (endianess *endianess*))
  (eq endianess 'little))

(defun big-endianess? (&optional (endianess *endianess*))
  (eq endianess 'big))

(defun value-bytes (val width)
  (with (lst nil)
	(dotimes (x width lst)
	  (= lst (append lst (list (mod val 256))))
	  (= val (>> val 8)))))

(defun dword-bytes (val)
  (value-bytes val 4))

(defun qword-bytes (val)
  (value-bytes val 8))

(defun %put-char (ptr val)
  "Write byte to address."
  (%%set ptr val)
  (++ ptr))

(defun %put-list (ptr x)
  "Write list of bytes to memory. Returns following address."
  (dolist (v x ptr)
	(= ptr (%put-char ptr v))))

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
  (bit-or (<< (bit-and x (+ (* 255 #x10000) #xffff)) 8)))

(defun rotate-dword-byte-left (x)
  (bit-or (<< (shift-dword-byte-left x))
		  (>> x 24)))

(defun %put-dword (ptr x &key (endianess *endianess*))
  "Write 32 bit integer to address. Regards *ENDIANESS*."
;  (when (little-endianess? endianess)
;    (= x (rotate-int-byte-left x)))

  (dotimes (dummy 4 ptr)
	(= ptr (%put-char ptr (bit-and x #xff))
	   x ;(? (little-endianess? endianess)
		     ;(rotate-dword-byte-left x)
		     (>> x 8))));)

(defun %get-dword (ptr)
  (with (v 0)
	(dotimes (x 4)
	  (= v (bit-and (<< v 8) (%%get ptr))
		 ptr (+ ptr 4)))
	v))

(defun %put-dword-list (ptr x &key (null-terminated nil))
  "Write list of dwords to memory. Returns following address."
  (with (n (%put-list ptr (mapcan #'dword-bytes x)))
	(? null-terminated
	   (%put-dword n 0)
	   n)))

(defun %put-pointer-list (ptr x &key (null-terminated nil))
  "Write list of dwords to memory. Returns following address."
  (with (n (%put-list ptr (mapcan #'((y)
									   (value-bytes y *pointer-size*))
								  x)))
	(? null-terminated
	   (%put-list n (value-bytes 0 *pointer-size*))
	   n)))

(defun %put-string (ptr str &key (null-terminated nil))
  (dotimes (x (length str) (? null-terminated
							  (%put-char ptr 0)
							  ptr))
    (= ptr (%put-char ptr (elt str x)))))

(defun binary-truth (x)
  (? x 1 0))

(defun %malloc-string (x &key (null-terminated nil))
  (with (m (%malloc (+ (length x) (binary-truth null-terminated))))
    (%put-string m x :null-terminated null-terminated)
    m))

(defun %free-list (x)
  (@ #'%free x))
