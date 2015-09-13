; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defun c-identifier-char? (x)
  (| (<= #\a x #\z)
     (<= #\A x #\Z)
     (<= #\0 x #\9)
     (in=? x #\_ #\. #\$ #\#)))
