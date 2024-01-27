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
         (num-cars without-end)   (dot-expand-tail-length without-start)
         f #'((which num x)
               (? (< 0 num)
                  `(,which ,(f which (-- num) x))
                  x)))
    (f 'car num-cars
       (f 'cdr num-cdrs
          (dot-expand (make-symbol (list-string without-end)))))))

(fn no-dot-notation? (x)
  (with (sl (string-list (symbol-name x))
         l  (length sl))
    (& (| (== 1 l)
          (not (position #\. sl)))
       x)))

(fn has-dot-notation? (x)
  (!= (symbol-name x)
    (| (eql #\. (elt ! 0))
       (eql #\. (elt ! (-- (length !)))))))

(fn dot-expand-symbol (x)
  (| (no-dot-notation? x)
     (let sl (string-list (symbol-name x))
       (? (has-dot-notation? x)
          (dot-expand-list sl)
          (let p (position #\. sl)
            `(%slot-value ,(make-symbol (list-string (subseq sl 0 p)))
                          ,(dot-expand-symbol (make-symbol (list-string (subseq sl (++ p)))))))))))

(fn dot-expand (x)
  (?
    (symbol? x)
      (dot-expand-symbol x)
    (cons? x)
      (. (dot-expand x.)
         (dot-expand .x))
    x))

(= *dot-expand* #'dot-expand)
