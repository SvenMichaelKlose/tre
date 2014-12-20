;;;; tré – Copyright (c) 2005–2006,2008–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(defmacro labels (fdefs &body body)
  `(#'(,(mapcar #'first fdefs)
	   ,@(mapcar #'((_)
                      `(%set-atom-fun ,_.
                                      #'(,._.
                                           (block ,_.
                                             ,@.._))))
                 fdefs)
      ,@body)
    ,@(mapcar [] fdefs)))
