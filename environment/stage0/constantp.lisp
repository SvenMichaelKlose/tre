(%fn constant? (x)
  (member x *constants* :test #'eq))
