; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defun read-byte (i)
  (char-code (read-char i)))

(defun read-word (i)
  (+ (read-byte i)
     (<< (read-byte i) 8)))

(defun read-byte-string (i num)
  (list-string (maptimes [read-byte i] num)))

(defun gen-read-array (i reader num)
  (list-array (maptimes [funcall reader i] num)))

(defun read-byte-array (i num)
  (gen-read-array i #'read-byte num))

(defun read-word-array (i num)
  (gen-read-array i #'read-word num))
