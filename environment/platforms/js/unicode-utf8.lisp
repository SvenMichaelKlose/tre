; tré – Copyright (c) 2009,2013,2016 Sven Michael Klose <pixel@copei.de>

(defun unicode-utf8 (x) (unescape (encode-u-r-i-component x)))
(defun utf8-unicode (x) (decode-u-r-i-component (escape x)))
