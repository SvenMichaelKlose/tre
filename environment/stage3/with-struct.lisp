; tré – Copyright (C) 2006,2008,2012,2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defmacro with-struct (typ strct &body body)
  (alet (assoc-value typ *struct-defs*)
    `(#'((,typ ,@(@ #'%struct-field-name !))
           ,@(@ [%struct-field-name _] !)
           ,@body)
       ,strct ,@(@ [`(,(%struct-accessor-name typ (%struct-field-name _)) ,strct)] !))))
