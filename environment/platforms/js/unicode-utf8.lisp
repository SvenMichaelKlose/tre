(defun unicode-utf8 (x) (unescape (encode-u-r-i-component x)))
(defun utf8-unicode (x) (decode-u-r-i-component (escape x)))
