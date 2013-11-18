;;;;; tré – Copyright (c) 2010 Sven Michael Klose <pixel@copei.de>

(defmacro do-classes ((iterator element &optional result) &rest body)
  `(dolist (,iterator ((slot-value ,element 'get-classes)) ,result)
	 ,@body))
