;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun draw-signal (signal &key (x-offset 0) (y-offset 0))
  (with (img (make-image :width (length signal) :height 256)
         x   0)
    (dolist (j signal img)
      (& (<= 0 j)
         (dotimes (y j)
           (= (image-pixel img x y) (values 0 255 0))))
       (++! x))))
