;;;;; tré – Copyright (c) 2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun common-ancestor (start end)
  (with (wstart (ancestor-or-self-text-editable start)
		 wend	(ancestor-or-self-text-editable end))
	(& wstart wend
       (eq wstart.parent-node wend.parent-node))))

(defun parent-of? (x parent)
  (eq parent x.parent-node))

(defun get-parent-backwards (parent x)
  (? (parent-of? x parent)
	 x
	 (get-parent-backwards
		 parent
	  	 (? x.previous-sibling
		 	x.parent-node.first-child
			x.parent-node))))

(defun get-parent-forwards (parent x)
  (? (parent-of? x parent)
	 x
	 (get-parent-forwards parent x.parent-node)))

(defun get-node-range (start end)
  (cons start
  		(unless (eq start end)
		  (get-node-range start.next-sibling end))))

(dont-obfuscate
	start-container
	end-container
	common-ancestor-container)

(defun range-deepest-nodelist (range)
  (with (start range.start-container
		 end   range.end-container
		 deepest range.common-ancestor-container
		 pstart (get-parent-backwards deepest start)
		 pend   (get-parent-forwards deepest end))
    (get-node-range pstart pend)))
