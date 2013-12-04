;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception %princ)

(define-native-js-fun %princ (txt &optional (only-standard-output nil))
  (document.write (string txt))
  txt)
