;;;;; tré – Copyright (c) 2009–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro continued (return-values (fun &rest args) &rest body)
  `(,fun
	   #'(,(when return-values
			 (ensure-list return-values))
          ,@body)
	   ,@args))

(defmacro thread (return-values (fun &rest args) &rest body)
  `(,fun
	   #'(,(when return-values
			 (ensure-list return-values))
           (wait #'(() ,@body) 0))
	   ,@args))

(defmacro force-thread-switch (&rest body)
  `(continued nil (wait 0)
     ,@body))

(defmacro continued-dolist (continuer elm init &rest body)
  (with-gensym (sbody srec scont)
    `(#'((,scont)
		   (with (,sbody #'((,continuer ,elm) ,@body)
		    	  ,srec #'((continuer x)
				      		 (when x
					      	   (continued nil (,sbody x.)
						    	 (,srec continuer .x)))))
	   		 (,srec ,scont ,init))))))

(defmacro continued-dolist-cont-0 (continuer local-continuer elm init
										     &rest body)
  (with-gensym (sbody srec )
    `(with (,sbody #'((,local-continuer ,elm) ,@body)
	    	,srec #'((continuer x)
			   		   (? x
					      (thread nil (,sbody x.)
					   	    (,srec continuer .x))
						 (funcall continuer))))
   	   (,srec ,continuer ,init))))

(dont-obfuscate floor)

(defmacro continued-dolist-cont (continuer local-continuer elm init
										   &rest body)
  (with-gensym (lst len top sublst inner-continuer)
    `(with (,lst ,init
            ,len (length ,lst)
            ,top (group ,lst (? (< 50 ,len)
                                (*math.floor (*math.sqrt ,len))
                                ,len)))
       (continued-dolist-cont-0 ,continuer ,inner-continuer ,sublst ,top
         (continued-dolist-cont-0 ,inner-continuer ,local-continuer ,elm ,sublst
           ,@body)))))

(defmacro continued-doarray-cont (continuer local-continuer elm init
										   &rest body)
  `(continued-dolist-cont ,continuer ,local-continuer ,elm
						  (array-list ,init)
						  ,@body))
