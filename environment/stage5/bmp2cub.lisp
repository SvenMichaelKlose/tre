;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun bmp2cub-read-slices (files)
  (with (num-slices (length files)
         slices (make-array num-slices)
         i 0)
    (dolist (n files slices)
      (format t "Reading slice ~A..." i)
      (force-output)
      (with ((slice w h) (read-bmp-array n))
        (setf (aref slices i) slice)
        (format t "O.K.~%"))
      (1+! i))))

(defun bmp2cub-make-cub-data (slices x y z width)
  (let data (make-queue)
    (dotimes (iz 16 (queue-list data))
      (let slice (aref slices (+ z iz))
        (dotimes (iy 16)
          (dotimes (ix 16)
            (enqueue data (%%get (+ slice (* (+ y iy) width) x ix)))))))))

(defun cubs-on-axis (x)
  (integer (/ x 16)))

(defun bmp2cub (files width height)
  (let slices (bmp2cub-read-slices files)
    (dotimes (z (cubs-on-axis (length slices)))
      (dotimes (y (cubs-on-axis height))
        (dotimes (x (cubs-on-axis width))
          (let cubname (format nil "~A-~A-~A.cub" z y x)
            (format t "Making ~A..." cubname)
            (let cubdata (bmp2cub-make-cub-data slices (* 16 x) (* y 16) (* z 16) width)
              (with-open-file out (open cubname :direction 'output)
                (dolist (i cubdata)
                  (princ (code-char i) out))))
            (format t "O.K.~%")))))))
