;;;;; tré – Copyright (c) 2005–2006,2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defmacro labels (fdefs &body body)
  `(#'(,(mapcar #'first fdefs)
	   ,@(mapcar #'((_)
                      `(%set-atom-fun ,(car _)
                                      #'(,(cadr _)
                                           (block ,(car _)
                                             ,@(cddr _)))))
                 fdefs)
      ,@body)
    ,@(mapcar [] fdefs)))
