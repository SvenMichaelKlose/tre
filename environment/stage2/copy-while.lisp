(functional copy-while)

(fn copy-while (pred x)
  (& x
     (funcall pred x.)
     (. x. (copy-while pred .x))))
