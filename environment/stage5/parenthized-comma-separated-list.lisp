;;;;; tré – Copyright (c) 2008–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun parenthized-comma-separated-list (x &key (type 'round))
  (with (err #'(() (error type "expected ROUND, CURLY, SQUARE or ANGLE bracket type")))
    `(,(case type
         'round "("
         'curly "{"
         'square "["
         'angle "<"
         (err))
      ,@(comma-separated-list x)
      ,(case type
         'round ")"
         'curly "}"
         'square "]"
         'angle ">"))))
