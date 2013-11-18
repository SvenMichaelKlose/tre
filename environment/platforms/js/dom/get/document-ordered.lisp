;;;;; tré – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun dom-move-if-up (next end pred x)
  (when x
    (? (funcall pred x)
	   x
       (| (when (element? x)
            (dom-move-if-up next end pred (funcall end x)))
	      (dom-move-if-up next end pred (funcall next x))))))

(defun dom-move-if-down (next end pred x)
  (let-when parent x.parent-node
    (? (funcall pred parent)
	   parent
       (| (awhen (funcall next parent)
            (dom-move-if-up next end pred !))
          (dom-move-if-down next end pred parent)))))

(defun dom-move-if (next end pred x)
  (when x
	(!? (funcall next x)
        (| (dom-move-if-up next end pred !)
           (dom-move-if-down next end pred !))
        (dom-move-if-down next end pred x))))

(defun dom-forward-if (pred x)
  (dom-move-if (fn identity _.next-sibling)
               (fn identity _.first-child)
               pred x))

(defun dom-backward-if (pred x)
  (dom-move-if (fn identity _.previous-sibling)
               (fn identity _.last-child)
               pred x))

(defun find-next-text-node (x)
  (dom-forward-if #'text? x))
