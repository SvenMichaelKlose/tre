; tré – Copyright (c) 2008–2009,2011–2013,2015 Sven Michael Klose <pixel@copei.de>

(defun c-list (x &key (type 'round))
  (with (err #'(() (error type "Expected ROUND, CURLY, or SQUARE bracket type.")))
    `(,(case type
         'round  "("
         'curly  "{"
         'square "["
         (err))
      ,@(pad x ", ")
      ,(case type
         'round  ")"
         'curly  "}"
         'square "]"))))
