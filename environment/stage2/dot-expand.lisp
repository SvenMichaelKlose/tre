(fn dot-expand-make-expr (which num x)
  (? (< 0 num)
     `(,which ,(dot-expand-make-expr which (-- num) x))
     x))

(fn dot-expand-head-length (x &optional (num 0))
  (? (eql #\. x.)
     (dot-expand-head-length .x (++ num))
     (values num x)))

(fn dot-expand-tail-length (x &optional (num 0))
  (? (eql #\. (car (last x)))
     (dot-expand-tail-length (butlast x) (++ num))
     (values num x)))

(fn dot-expand-list (x)
  (with ((num-cdrs without-start) (dot-expand-head-length x)
         (num-cars without-end)   (dot-expand-tail-length without-start))
    (dot-expand-make-expr 'car num-cars
                          (dot-expand-make-expr 'cdr num-cdrs
                                                (dot-expand (make-symbol (list-string without-end)))))))

(fn dot-position (x)
  (position #\. x :test #'character==))

(fn no-dot-notation? (x)
  (with (sl  (string-list (symbol-name x))
         l   (length sl))
    (| (== 1 l)
       (not (dot-position sl)))))

(fn has-dot-notation? (x)
  (!= (symbol-name x)
    (| (eql #\. (elt ! 0))
       (eql #\. (elt ! (-- (length !)))))))

(fn dot-expand-conv (x)
  (? (no-dot-notation? x)
     x
     (let sl (string-list (symbol-name x))
       (? (has-dot-notation? x)
          (dot-expand-list sl)
          (let p (dot-position sl)
            `(%slot-value ,(make-symbol (list-string (subseq sl 0 p)))
                          ,(dot-expand-conv (make-symbol (list-string (subseq sl (++ p)))))))))))

(fn dot-expand (x)
  (?
    (symbol? x)  (dot-expand-conv x)
    (cons? x)    (. (dot-expand x.)
                    (dot-expand .x))
    x))

(= *dot-expand* #'dot-expand)
