; tré – Copyright (c) 2005–2006,2008–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(define-shared-std-macro (bc c js php) labels (fdefs &body body)
  `(#'(,(@ #'first fdefs)
	   ,@(@ [`(%set-local-fun ,_.  #'(,._. (block ,_. (block nil ,@.._))))] fdefs)
      ,@body)
    ,@(@ [] fdefs)))
