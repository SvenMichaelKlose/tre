; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defun read-byte (i)
  (alet (read-char i)
    (& ! (char-code !))))

(defun write-byte (x o)
  (princ (? (character? x)
            x
            (code-char x))
         o))

(defun read-byte-string (i num)
  (list-string (maptimes [read-byte i] num)))

(defun gen-read-array (i reader num)
  (list-array (maptimes [funcall reader i] num)))

(defun read-byte-array (i num)
  (gen-read-array i #'read-byte num))

(defun read-word-array (i num)
  (gen-read-array i #'read-word num))
