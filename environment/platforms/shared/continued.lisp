(defmacro continued (return-values (fun &rest args) &body body)
  `(,fun
	   #'(,(when return-values
			 (ensure-list return-values))
           ,@body)
	   ,@args))
