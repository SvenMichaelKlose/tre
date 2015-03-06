; tré – Copyright (C) 2006,2008,2012,2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defmacro with-struct (typ strct &body body)
  (alet (assoc-value typ *struct-defs*)
    `(let* ((,typ ,strct)
            ,@(@ [let n (%struct-field-name _)
	               `(,n (,(%struct-accessor-name typ n) ,strct))]
                 !))
       ,@(@ [%struct-field-name _] !)
       ,@body)))
