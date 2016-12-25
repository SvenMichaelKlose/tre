(defmacro do-classes ((iterator element &optional (result nil)) &body body)
  `(@ (,iterator ((slot-value ,element 'get-classes)) ,result)
	 ,@body))

(defmacro do-elements ((step iter elm &optional (ret nil)) &body body)
  `(iterate ,iter ,step ,elm ,ret
     (& (document? ,iter)
        (return nil))
     ,@body))

(defmacro do-node-tree ((iterator root &optional (result nil)) &body body)
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

(defmacro do-element-tree ((iterator root &optional (result nil)) &body body)
  `(do-node-tree (,iterator ,root ,result)
     (when (element? ,iterator)
       ,@body)))

(defmacro do-ancestors ((iter elm &optional (ret nil)) &body body)
  `(do-elements ((slot-value ,iter 'parent-node) ,iter (parent-node ,elm) ,ret)
	 ,@body))

(defmacro do-self-and-ancestors ((iter elm &optional (ret nil)) &body body)
  `(do-elements ((slot-value ,iter 'parent-node) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-self-and-previous-siblings ((iter elm &optional (ret nil)) &body body)
  `(do-elements ((slot-value ,iter 'previous-sibling) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-previous-siblings ((iter elm &optional (ret nil)) &body body)
  `(do-self-and-previous-siblings (,iter (slot-value ,elm 'previous-sibling) ,ret)
	 ,@body))

(defmacro do-self-and-next-siblings ((iter elm &optional (ret nil)) &body body)
  `(do-elements ((slot-value ,iter 'next-sibling) ,iter ,elm ,ret)
	 ,@body))

(defmacro do-next-siblings ((iter elm &optional (ret nil)) &body body)
  `(do-self-and-next-siblings (,iter (slot-value ,elm 'next-sibling) ,ret)
	 ,@body))

(defmacro do-children ((iter parent &optional (result nil)) &body body)
  `(@ (,iter (array-list (slot-value ,parent 'child-nodes)) ,result)
     ,@body))
