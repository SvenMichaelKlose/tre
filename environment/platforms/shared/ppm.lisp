(defstruct image
  (:constructor %make-image)
  width
  height
  data)

(fn make-image (&key width height)
  (aprog1 (%make-image :width width :height height)
    (let size (* 3 width height)
      (= (image-data !) (make-array size))
      (dotimes (i size)
        (= (aref (image-data !) i) 0)))))

(def-image image-inside? (image x y)
  (& (<= 0 x)
     (< x width)
     (<= 0 y)
     (< y height)))

(def-image image-pixel (image x y)
  (& (image-inside? image x y)
     (alet (+ (* 3 y width) (* 3 x))
       (values (aref data !)
               (aref data (+ 1 !))
               (aref data (+ 2 !))))))

(def-image (= image-pixel) (rgb image x y)
  (& (image-inside? image x y)
     (with ((r g b) rgb)
       (alet (+ (* 3 y width) (* 3 x))
         (= (aref (image-data image) !) r)
         (= (aref (image-data image) (+ 1 !)) g)
         (= (aref (image-data image) (+ 2 !)) b)))))

(def-image write-ppm-image (image out)
  (format out "P6~%#tré~%~A ~A~%255~%" width height)
  (dotimes (i (* 3 width height))
    (princ (code-char (aref data i)) out)))
