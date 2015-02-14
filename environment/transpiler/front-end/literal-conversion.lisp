; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(def-pass-fun literal-conversion x
  (funcall (literal-converter) x))
