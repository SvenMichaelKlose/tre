;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun child-of-ancestor-if (node pred)
  (let child node
    (do-self-and-ancestors (x node)
      (& (funcall pred x)
		 (return child))
	  (= child x))))

(defun ancestor-or-self-if (node pred)
  (do-self-and-ancestors (x node)
    (& (funcall pred x)
	   (return x))))

(defun ancestor-or-self? (x elm)
  (ancestor-or-self-if x (fn eq _ elm)))

(defun ancestor-or-self-child-of (parent x)
  (ancestor-or-self-if x (fn eq parent _.parent-node)))

(dont-obfuscate unshift)

(defun ancestors-or-self-if (node pred)
  (with-queue elms
    (do-self-and-ancestors (x node (queue-list elms))
	  (& (funcall pred x)
		 (enqueue elms x)))))

(defmacro do-predicate ((fun iter init) &rest body)
  `(,fun ,init #'((,iter)
					(when ,iter
		 	  		  ,@body))))

(defmacro do-ancestors-unless ((iter start) &rest body)
  `(do-ancestors (,iter ,start)
     (& (progn ,@body)
	    (return ,iter))))

(defmacro do-self-and-ancestors-unless ((iter start) &rest body)
  `(do-self-and-ancestors (,iter ,start)
     (& (progn ,@body)
	    (return ,iter))))

(defun ancestor-or-self-with-i-d (node)
  (do-self-and-ancestors-unless (x node)
	(& (element? x)
	   (x.get-id))))

(defun ancestor-or-self-with-class (node)
  (do-self-and-ancestors-unless (x node)
	(& (element? x)
       (x.has-attribute "class"))))

(defun ancestor-or-self-with-class-of (node classes)
  (do-self-and-ancestors-unless (x node)
	(& (element? x)
       (dolist (c (ensure-list classes))
         (& (member c (x.get-classes) :test #'string==)
            (return x))))))

(defun ancestor-with-tag-name (node name)
  (do-ancestors-unless (x node)
	(x.has-tag-name? name)))

(defun ancestor-or-self-with-tag-name (node name)
  (do-self-and-ancestors-unless (x node)
	(x.has-tag-name? name)))

(defun ancestor-or-self-name (x)
  (awhen (ancestor-or-self-if x (fn _.read-attribute "name"))
	(!.read-attribute "name")))

(defun get-first-text-node (node)
  (do-self-and-next-siblings (elm node.first-child)
    (case elm.node-type
      3  (return elm)
	  1  (get-first-text-node elm))))

(mapcar-macro x
	'(-tag -class "")
  (let n ($ '-by x '-name)
    `(defun ,($ 'dom-get-first n) (doc name )
	   (aref ((slot-value doc ',($ 'get-elements n)) name)
			 0))))

(mapcar-macro x
	'(tag class)
  (let n ($ '-by- x '-name)
    `(defun ,($ 'dom-get-last n) (doc name )
	   (let-when vec ((slot-value doc ',($ 'get-elements n)) name)
	     (let len (length vec)
		   (unless (== 0 len)
	         (aref vec (-- len))))))))
