;;;;; TRE environment
;;;;; Copyright (C) 2005-2006,2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Local functions

(defmacro labels (fdefs &rest body)
  `(#'(,(mapcar #'first fdefs)
	   ,@(mapcar (fn `(%set-atom-fun ,(first _)
	       				#'(,(second _)
	           				(block ,(first _)
	             			  ,@(cddr _)))))
				   fdefs)
	   ,@body)
	  ,@(mapcar (fn) fdefs)))
