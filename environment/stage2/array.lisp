(functional copy-array)
(fn copy-array (arr)
  (do ((ret (make-array))
       (i 0 (++ i)))
      ((== i (length arr)) ret)
    (= (aref ret i) (aref arr i))))

(functional array-list)
(fn array-list (x)
  (let result (make-queue)
    (adotimes ((length x) (queue-list result))
      (enqueue result (aref x !)))))

(fn maparray (fun hash)
  (with-queue q
    (dotimes (i (length hash) (queue-list q))
      (enqueue q (funcall fun (aref hash i))))))
