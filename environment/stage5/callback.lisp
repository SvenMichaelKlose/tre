;;;;; Caroshi – Copyright (c) 2011,2013 Sven Michael Klose <pixel@copei.de>

(defmacro callback (x)
  `(!? ,x
       (funcall !)))
