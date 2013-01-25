;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defmacro defvar-native (&rest x)
  (print-definition `(defvar-native ,@x))
  (+! (transpiler-predefined-symbols *transpiler*) x)
  nil)
