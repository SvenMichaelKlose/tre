;;;;; tré – Copyright (c) 2005–2008,2012–2014 Sven Michael Klose <pixel@copei.de>

(%defvar *definition-printer* #'print)

(%defun print-definition (x)
  (? *show-definitions?*
     (apply *definition-printer* (list x))))
