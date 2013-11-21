;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro do-classes ((iterator element &optional result) &rest body)
  `(dolist (,iterator ((slot-value ,element 'get-classes)) ,result)
	 ,@body))

(defmacro do-elements ((step iter elm &optional (ret nil)) &rest body)
  `(iterate ,iter ,step ,elm ,ret
     (& (document? ,iter)
        (return nil))
     ,@body))

(defmacro do-node-tree ((iterator root &optional (result nil)) &rest body)
  (with-gensym (vbody rec x)
    `(with (,vbody #'((,iterator)
                       ,@body)
            ,rec #'((,x)
                     (do-children (,iterator ,x)
                        (& (element? ,iterator)
                           (,rec ,iterator))
                        (,vbody ,iterator))))
       (,rec ,root)
       ,result)))

(defmacro do-element-tree ((iterator root &optional (result nil)) &rest body)
  `(do-node-tree (,iterator ,root ,result)
     (when (element? ,iterator)
       ,@body)))

(defmacro do-ancestors ((iter elm &optional (ret nil)) &rest body)
  `(do-elements ((parent-node ,iter) ,iter (parent-node ,elm) ,ret)
	 ,@body))

(defmacro do-self-and-ancestors ((iter elm &optional (ret nil)) &rest body)
  `(do-elements ((parent-node ,iter) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-self-and-previous-siblings ((iter elm &optional (ret nil)) &rest body)
  `(do-elements ((slot-value ,iter 'previous-sibling) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-previous-siblings ((iter elm &optional (ret nil)) &rest body)
  `(do-self-and-previous-siblings (,iter (slot-value ,elm 'previous-sibling) ,ret)
	 ,@body))

(defmacro do-self-and-next-siblings ((iter elm &optional (ret nil)) &rest body)
  `(do-elements ((slot-value ,iter 'next-sibling) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-next-siblings ((iter elm &optional (ret nil)) &rest body)
  `(do-self-and-next-siblings (,iter (slot-value ,elm 'next-sibling) ,ret)
	 ,@body))

(defmacro do-children ((iter parent &optional (result nil)) &rest body)
  `(dolist (,iter (array-list (slot-value ,parent 'child-nodes)) ,result)
     ,@body))
