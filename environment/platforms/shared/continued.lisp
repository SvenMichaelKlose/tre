;;;;; tré – Copyright (c) 2009–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro thread (return-values (fun &rest args) &rest body)
  `(,fun
	   #'(,(when return-values
			 (ensure-list return-values))
           (wait #'(() ,@body) 0))
	   ,@args))

(defmacro force-thread-switch (&rest body)
  `(continued nil (wait 0)
     ,@body))
