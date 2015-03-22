; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

(defvar *functions* nil)

(defbuiltin function-native (x) x)

(defbuiltin function-source (x)
  (cdr (cl:assoc x *functions* :test #'cl:eq)))

(defbuiltin =-function-source (v x)
  (error "Can't set function source in the Common Lisp core."))
;(cl:setf (cdr (cl:assoc x *functions* :test #'cl:eq)) v))

(defbuiltin function-bytecode (x) x nil)
