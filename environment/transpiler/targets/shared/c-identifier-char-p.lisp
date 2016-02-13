; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@hugbox.org>

(defun c-identifier-char? (x)
  (| (character<= #\a x #\z)
     (character<= #\A x #\Z)
     (character<= #\0 x #\9)
     (in-chars? x #\_ #\. #\$ #\#)))
