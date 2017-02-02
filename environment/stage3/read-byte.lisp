(fn peek-byte (i)
  (alet (peek-char i)
    (& ! (char-code !))))

(fn read-byte (i)
  (alet (read-char i)
    (& ! (char-code !))))

; TODO: Flexible endianess.

(fn read-word (i)
  (+ (| (read-byte i)
        (return))
     (<< (| (read-byte i)
            (return))
         8)))

(fn read-dword (i)
  (+ (| (read-word i)
        (return))
     (<< (| (read-word i)
            (return))
         16)))

(fn write-byte (x o)
  (princ (code-char x) o))

(fn write-word (x o)
  (write-byte (bit-and x #xff) o)
  (write-byte (>> x 8) o))

(fn write-dword (x o)
  (write-word (bit-and x #xffff) o)
  (write-word (>> x 16) o))

(fn read-byte-string (i num)
  (list-string (maptimes [read-byte i] num)))

(fn gen-read-array (i reader num)
  (list-array (maptimes [funcall reader i] num)))

(fn read-byte-array (i num)
  (gen-read-array i #'read-byte num))

(fn read-word-array (i num)
  (gen-read-array i #'read-word num))
