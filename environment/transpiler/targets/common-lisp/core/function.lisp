(var *functions* nil)

(defbuiltin function-source (x)
  (cdr (CL:ASSOC x *functions* :TEST #'CL:EQ)))

(defbuiltin =-function-source (v x)
  (error "Can't set function source in the Common Lisp core."))
;(CL:SETF (cdr (CL:ASSOC x *functions* :TEST #'CL:EQ)) v))

(defbuiltin function-bytecode (x) x nil)
