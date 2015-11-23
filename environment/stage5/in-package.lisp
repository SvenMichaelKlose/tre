; tré - Copyright (c) 2012,2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defmacro in-package (x)
  (cl:in-package (symbol-name x)))
