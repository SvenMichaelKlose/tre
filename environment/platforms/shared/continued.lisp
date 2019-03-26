;;;;; tré – Copyright (c) 2009–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defmacro continued (return-values (fun &rest args) &body body)
  `(,fun
	   #'(,(when return-values
			 (ensure-list return-values))
           ,@body)
	   ,@args))

(defmacro thread (return-values (fun &rest args) &body body)
  `(,fun
	   #'(,(when return-values
			 (ensure-list return-values))
           (wait #'(() ,@body) 0))
	   ,@args))

(defmacro force-thread-switch (&body body)
  `(continued nil (wait 0)
     ,@body))
