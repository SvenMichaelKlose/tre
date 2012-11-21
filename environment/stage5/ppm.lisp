;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defstruct image
  (:constructor %make-image)
  width
  height
  data)

(defun make-image (&key width height)
  (aprog1 (%make-image :width width :height height)
    (= (image-data !) (make-array (* 3 width height)))))

(defun image-pixel (image x y)
  (alet (+ (* 3 y (image-width image))
           (* 3 x))
    (values (aref (image-data image) !)
            (aref (image-data image) (+ 1 !))
            (aref (image-data image) (+ 2 !)))))

(defun (= image-pixel) (image x y r g b)
  (alet (+ (* 3 y (image-width image))
           (* 3 x))
    (= (aref (image-data image) !) r)
    (= (aref (image-data image) (+ 1 !)) g)
    (= (aref (image-data image) (+ 2 !)) b)))

(def-image write-ppm-image (image out)
  (format out "P6~%#tré~%~A ~A~%255~%" width height)
  (dotimes (i (* 3 width height))
    (princ (code-char (aref data i)) out)))
