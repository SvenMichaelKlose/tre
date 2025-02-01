(fn integer (x)
  (?
    (character? x)  (char-code x)
    (string? x)     (string-integer x)
    (number-integer x)))

(macrolet
    ((define-operator (name)
       `(fn ,name (&rest x)
          (let n x.
            (@ (i .x n)
              (= n (,($ '% name) n i)))))))
  ,@(@ [`(define-operator ,_)]
       '(* / mod)))

(macrolet
    ((define-binary-operator (name)
       `(fn ,name (a b)
          (,($ '% name) a b))))
  ,@(@ [`(define-binary-operator ,_)]
       '(<< >> bit-or bit-and)))

(fn number+ (&rest x)
  (let n x.
    (@ (i .x n)
      (= n (%+ n i)))))

(macrolet
    ((define-minus ()
       (let gen-body `(? .x
                         (let n x.
                           (@ (i .x n)
                             (= n (%- n i))))
                         (%- x.))
         `(progn
            (fn - (&rest x)
              ,gen-body)
            (fn number- (&rest x)
              ,gen-body)))))
  (define-minus))

(fn number== (x &rest y)
  (every [%== x _] y))

(macrolet
    ((define-char-and-number-comparator (name)
       (let op ($ '% name)
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
                  (= n i))))))))
  (define-char-and-number-comparator ==)
  (define-char-and-number-comparator <)
  (define-char-and-number-comparator >)
  (define-char-and-number-comparator <=)
  (define-char-and-number-comparator >=))
