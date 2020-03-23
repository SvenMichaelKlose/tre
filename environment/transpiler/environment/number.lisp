(fn number== (x &rest y)
  (every [%%%== x _] y))

(defmacro def-simple-op (op)
  `(fn ,op (&rest x)
     (let n x.
       (@ (i .x n)
         (= n (,($ '%%% op) n i))))))

(progn
  ,@(@ [`(def-simple-op ,_)] '(* / mod)))

(fn number+ (&rest x)
  (let n x.
    (@ (i .x n)
      (= n (%%%+ n i)))))

(defmacro define-generic-transpiler-minus ()
  (let gen-body `(? .x
                    (let n x.
                      (@ (i .x n)
                        (= n (%%%- n i))))
                    (%%%- x.))
    `(progn
       (fn - (&rest x)
         ,gen-body)
       (fn number- (&rest x)
         ,gen-body))))

(define-generic-transpiler-minus)

(defmacro def-generic-transpiler-comparison (name)
  (let op ($ '%%% name)
    `(progn
       (fn ,name (n &rest x)
         (@ (i x t)
           (| (,op n i)
              (return))
           (= n i)))
       (fn ,($ 'character name) (n &rest x)
         (let n (char-code n)
           (@ (i x t)
             (| (,op n (char-code i))
                (return))
             (= n i)))))))

(def-generic-transpiler-comparison ==)
(def-generic-transpiler-comparison <)
(def-generic-transpiler-comparison >)
(def-generic-transpiler-comparison <=)
(def-generic-transpiler-comparison >=)

(fn integer (x)
  (?
    (character? x)  (char-code x)
    (string? x)     (string-integer x)
    (number-integer x)))

(fn << (a b)      (%%%<< a b))
(fn >> (a b)      (%%%>> a b))
(fn bit-or (a b)  (%%%bit-or a b))
(fn bit-and (a b) (%%%bit-and a b))
