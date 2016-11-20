; tré – Copyright (c) 2008–2011,2013–2014,2016 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *cars* *cdrs* *cprd* *cons-id* a d p sa sd sp)

(defvar *default-listprop* nil)

(defnative cons (x y)
  (new __cons x y))
