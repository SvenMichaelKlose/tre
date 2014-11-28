;;;;; tré - Copyright (C) 2006,2008,2012,2014 Sven Michael Klose <pixel@hugbox.org>

(defmacro with-struct (typ strct &body body)
  (alet (assoc-value typ *struct-defs*)
    `(let* ((,typ ,strct)
            ,@(mapcar [let n (%struct-field-name _)
	                    `(,n (,(%struct-getter-symbol typ n) ,strct))]
                      !))
       ,@(mapcar [%struct-field-name _] !)
       ,@body)))
