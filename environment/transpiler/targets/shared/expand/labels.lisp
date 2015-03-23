; tré – Copyright (c) 2005–2006,2008–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(define-shared-std-macro (c js) labels (fdefs &body body)
  `(#'(,(mapcar #'first fdefs)
	   ,@(mapcar #'((_)
                      `(%set-atom-fun ,_.
                                      #'(,._.
                                           (block ,_.
                                             (block nil
                                               ,@.._)))))
                 fdefs)
      ,@body)
    ,@(mapcar [] fdefs)))
