;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(define-native-js-fun %princ (txt &optional (only-standard-output nil))
  (document.writeln (string txt))
  txt)
