(functional remove)

(fn remove-if (fun x)
  (? (array? x)
     (list-array (remove-if fun (array-list x)))
     (with-queue q
       (@ (i x (queue-list q))
         (| (funcall fun i)
            (enqueue q i))))))

(fn remove-if-not (fun x)
  (? (array? x)
     (list-array (remove-if-not fun (array-list x)))
     (with-queue q
       (@ (i x (queue-list q))
         (& (funcall fun i)
            (enqueue q i))))))

(fn remove (elm x &key (test #'eql))
  (remove-if [funcall test elm _] x))
