(functional remove)

(defun remove-if (fun x)
  (? (array? x)
     (list-array (remove-if fun (array-list x)))
     (with-queue q
       (adolist (x (queue-list q))
         (| (funcall fun !)
            (enqueue q !))))))

(defun remove-if-not (fun x)
  (? (array? x)
     (list-array (remove-if-not fun (array-list x)))
     (with-queue q
       (adolist (x (queue-list q))
         (& (funcall fun !)
            (enqueue q !))))))

(defun remove (elm x &key (test #'eql))
  (remove-if [funcall test elm _] x))
