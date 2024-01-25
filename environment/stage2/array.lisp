(functional array copy-array array-list ensure-array)

(fn list-array (x)
  (with (a    (make-array (length x))
         idx  0)
    (@ (i x a)
      (= (aref a idx) i)
      (++! idx))))

(fn array-list (x)
  (let result (make-queue)
    (adotimes ((length x) (queue-list result))
      (enqueue result (aref x !)))))

(fn array (&rest elms)
  (list-array elms))

(fn copy-array (arr)
  (do ((ret (make-array))
       (i 0 (++ i)))
      ((== i (length arr)) ret)
    (= (aref ret i) (aref arr i))))

(fn maparray (fun hash)
  (with-queue q
    (dotimes (i (length hash) (queue-list q))
      (enqueue q (~> fun (aref hash i))))))

(fn ensure-array (x)
  (& x
     (? (array? x)
        x
        (array x))))
(defmacro doarray ((v seq &rest result) &body body)
  (with-gensym (! idx)
    `(let-when ,! ,seq
       (dotimes (,idx (length ,!) ,@result)
         (let ,v (aref ,! ,idx)
           ,@body)))))
