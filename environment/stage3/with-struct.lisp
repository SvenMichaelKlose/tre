;;;; TRE environment
;;;; Copyright (C) 2006,2008 Sven Klose <pixel@copei.de>

(defmacro with-struct (typ strct &rest body)
  `(let* (,@(mapcar #'((d)
		                 (let n (%struct-field-name d)
	                       `(,n (,(%struct-getter-symbol typ n) ,strct))))
	                (cdr (assoc typ *struct-defs*))))
     ,@body))
