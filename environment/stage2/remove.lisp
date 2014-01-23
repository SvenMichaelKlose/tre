;;;;; tré – Copyright (c) 2007–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(functional remove)

(defun remove-if (fun x)
  (with-queue q
    (adolist (x (queue-list q))
      (| (funcall fun !)
         (enqueue q !)))))

(defun remove-if-not (fun x)
  (with-queue q
    (adolist (x (queue-list q))
      (& (funcall fun !)
         (enqueue q !)))))

(defun remove (elm x &key (test #'eql))
  (remove-if [funcall test elm _] x))
