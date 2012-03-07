;;;;; tré - Copyright (c) 2005-2006,2008-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(defmacro labels (fdefs &body body)
  `(#'(,(mapcar #'first fdefs)
	   ,@(mapcar (fn `(%set-atom-fun ,(car _)
	       				#'(,(cadr _)
	           				(block ,(car _)
	             			  ,@(cddr _)))))
				   fdefs)
	   ,@body)
	  ,@(mapcar (fn) fdefs)))
