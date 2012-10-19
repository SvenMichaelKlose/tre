;;;;; tré - Copyright (C) 2006,2008,2012 Sven Michael Klose <pixel@copei.de>

(defmacro with-struct (typ strct &body body)
  `(let* ((,typ ,strct)
          ,@(mapcar [let n (%struct-field-name _)
	                  `(,n (,(%struct-getter-symbol typ n) ,strct))]
	                (assoc-value typ *struct-defs*)))
     ,@body))
