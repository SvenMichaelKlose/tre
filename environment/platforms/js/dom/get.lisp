; tré – Copyright (c) 2008–2014,2016 Sven Michael Klose <pixel@copei.de>

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

; For use in CAROSHI-ELEMENT:ANCESTOR-OR-SELF-IF.
(defun caroshi-ancestor-or-self-if (node pred)
  (ancestor-or-self-if node pred))

(defun ancestor-or-self? (x elm)
  (ancestor-or-self-if x [eq _ elm]))

(defun ancestor-or-self-child-of (parent x)
  (ancestor-or-self-if x [eq parent _.parent-node]))

(defun ancestors-or-self-if (node pred)
  (with-queue elms
    (do-self-and-ancestors (x node (queue-list elms))
	  (& (funcall pred x)
		 (enqueue elms x)))))

(defmacro do-ancestors-unless ((iter start) &body body)
  `(do-ancestors (,iter ,start)
     (& (progn ,@body)
	    (return ,iter))))

(defmacro do-self-and-ancestors-unless ((iter start) &body body)
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
	   (x.get-class))))

(defun get-first-text-node (node)
  (do-self-and-next-siblings (elm node.first-child)
    (case elm.node-type
      3  (return elm)
	  1  (get-first-text-node elm))))
