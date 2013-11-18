;;;;; tré – Copyright (c) 2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun move-children-to (fun-get fun-put to from)
  (awhile (funcall fun-get from)
          to
    (visible-node-remove-without-listeners-or-callbacks !)
    (funcall fun-put to !)))

(defun move-children (to &optional (from nil))
  (move-children-to (fn identity _.first-child)
                    #'((parent new-child)
                        (parent.append-child new-child))
                    to from))

(defun move-children-behind (to &optional (from nil))
  (move-children-to (fn identity _.first-child)
                    #'((parent new-child)
                        (to.add-after new-child))
                    to (| from to)))

(defun move-children-to-and-remove (fun-get fun-put to from)
  (move-children-to fun-get fun-put to from)
  (from.remove))

(defun move-children-and-remove (to &optional (from nil))
  (move-children to (| from to))
  (from.remove))

(defun move-children-to-front-and-remove (to &optional (from nil))
  (move-children-to-and-remove (fn identity _.last-child)
                               #'((parent new-child)
                                   (parent.add-front new-child))
                               to (| from to)))

(defun move-children-before (to &optional (from nil))
  (unless from
    (= from to))
  (awhile from.first-child nil
    (!.remove-without-listeners)
    (to.add-before !)))

(defun move-children-before-and-remove (to &optional (from nil))
  (move-children-before to from)
  (from.remove))
