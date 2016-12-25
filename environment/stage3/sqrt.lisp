; XXX experimental!

(defun close-enough? (x y precision)
  (> precision (abs (- x y))))

(defun fixed-point (f start precision)
  (with (iter #'((old new)
				   (? (close-enough? old new precision)
					  new
					  (iter new (f new)))))
	(iter start (f start))))

(defun average (a b)
  (/ (+ a b) 2))

(defun average-damp (f)
  [average (f _) _])

(defun derivative (f precision)
  [/ (- (f (+ _ precision))
        (f _))
     precision])

(defvar *newton-precision* 0.00001)

(defun newton (f &optional (guess 1) (precision *newton-precision*))
  (with (df (derivative f precision))
	(fixed-point [- _ (/ (f _) (df _))]
				 guess
                 precision)))

(defun sqrt (x)
  (newton [- x (* _ _)]))
