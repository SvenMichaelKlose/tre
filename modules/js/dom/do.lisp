(macro do-children ((iter parent &optional (result nil)) &body body)
  `(@ (,iter (array-list (slot-value ,parent 'child-nodes)) ,result)
     ,@body))

(macro do-self-and-ancestors ((iter init &optional (result nil)) &body body)
  `(do ((,iter ,init (slot-value ,iter 'parent-node)))
       ((not ,iter) ,result)
     ,@body))
