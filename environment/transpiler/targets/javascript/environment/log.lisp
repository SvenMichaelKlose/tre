;;;;; tré - Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(define-native-js-fun %%%log (txt)
  (document.writeln txt)
  txt)
