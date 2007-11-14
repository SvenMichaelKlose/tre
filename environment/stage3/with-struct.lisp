;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2006 Sven Klose <pixel@copei.de>

(defmacro with-struct (typ strct &rest body)
  `(let (,@(mapcar #'((d)
		                (let ((n (%struct-field-name d)))
	                      `(,n (,(%struct-getter-symbol typ n) ,strct))))
	               (assoc typ *struct-defs*)))
     ,@body))
