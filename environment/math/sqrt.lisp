; TODO: Move to math/?

(fn close-enough? (x y precision)
  (> precision (abs (- x y))))

(fn fixed-point (f start precision)
  (with (iter #'((old new)
                   (? (close-enough? old new precision)
                      new
                      (iter new (f new)))))
    (iter start (f start))))

(fn average (a b)
  (/ (+ a b) 2))

(fn average-damp (f)
  [average (f _) _])

(fn derivative (f precision)
  [/ (- (f (+ _ precision))
        (f _))
     precision])

(var *newton-precision* 0.00001)

(fn newton (f &optional (guess 1) (precision *newton-precision*))
  (with (df (derivative f precision))
    (fixed-point [- _ (/ (f _) (df _))]
                 guess
                 precision)))

(fn sqrt (x)
  (newton [- x (* _ _)]))
