;;;;; tré – Copyright (c) 2007–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional remove remove-if remove-if-not)

(defun remove-if (fun x)
  (with-queue q
    (adolist (x (queue-list q))
      (| (funcall fun !)
         (enqueue q !)))))

(defun remove-if-not (fun x)
  (remove-if [not (funcall fun _)] x))

(defun remove (elm x &key (test #'eql))
  (remove-if [funcall test elm _] x))
