(defun peek-byte (i)
  (alet (peek-char i)
    (& ! (char-code !))))

(defun read-byte (i)
  (alet (read-char i)
    (& ! (char-code !))))

; TODO: Flexible endianess.

(defun read-word (i)
  (+ (| (read-byte i)
        (return))
     (<< (| (read-byte i)
            (return))
         8)))

(defun read-dword (i)
  (+ (| (read-word i)
        (return))
     (<< (| (read-word i)
            (return))
         16)))

(defun write-byte (x o)
  (princ (code-char x) o))

(defun write-word (x o)
  (write-byte (bit-and x #xff) o)
  (write-byte (>> x 8) o))

(defun write-dword (x o)
  (write-word (bit-and x #xffff) o)
  (write-word (>> x 16) o))

(defun read-byte-string (i num)
  (list-string (maptimes [read-byte i] num)))

(defun gen-read-array (i reader num)
  (list-array (maptimes [funcall reader i] num)))

(defun read-byte-array (i num)
  (gen-read-array i #'read-byte num))

(defun read-word-array (i num)
  (gen-read-array i #'read-word num))
