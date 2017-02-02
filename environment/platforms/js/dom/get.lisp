(fn ancestor-or-self-if (node pred)
  (do-self-and-ancestors (x node)
    (& (funcall pred x)
	   (return x))))

(fn ancestor-or-self? (x elm)
  (ancestor-or-self-if x [eq _ elm]))

(fn ancestors-or-self-if (node pred)
  (with-queue elms
    (do-self-and-ancestors (x node (queue-list elms))
	  (& (funcall pred x)
		 (enqueue elms x)))))
