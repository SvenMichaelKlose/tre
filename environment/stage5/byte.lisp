; tré – Copyright (c) 2015 Sven Michael Klose <pixel@copei.de>

(defun byte (x)
  (bit-and (? (< x 0)
              (+ 256 x)
              x)
           #xff))

(defun word (x)
  (bit-and (? (< x 0)
              (+ #x10000 x)
              x)
           #xffff))

(defun word-unsigned-int (x)
  (? (< #x7fff x)
     (- x #x10000)
     x))
