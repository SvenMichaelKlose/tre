;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(defun chars-integer (chars len)
  (let result 0
    (adotimes (len result)
      (= result (bit-or (<< result 8) (elt chars (- len ! 1)))))))

(defun bmp-magic? (x)
  (| (& (== #\B x.)
        (== #\M .x.))))

(defun read-bmp-array (name &key (verbose? nil))
  (let a (read-binary-file name)
    (| (bmp-magic? a)
       (error "Not a BMP file. It has an incorrect magic."))
    (with (bitmap-offset (chars-integer (nthcdr 10 a) 4)
           header        (nthcdr 14 a)
           width         (chars-integer (nthcdr 4 header) 4)
           height        (chars-integer (nthcdr 8 header) 4)
           bitmap-list   (nthcdr bitmap-offset a)
           bitmap        (%malloc (* width height)))
      (when verbose?
        (format t "File size is: ~A~%" (chars-integer ..a 4))
        (format t "Bitmap offset is: ~A~%" bitmap-offset)
        (format t "Header size is: ~A~%" (chars-integer header 4))
        (format t "Width is: ~A~%" (chars-integer (nthcdr 4 header) 4))
        (format t "Height is: ~A~%" (chars-integer (nthcdr 8 header) 4))
        (format t "Planes: ~A~%" (chars-integer (nthcdr 12 header) 2))
        (format t "Bits per pixel: ~A~%" (chars-integer (nthcdr 14 header) 2))
        (format t "Compression: ~A~%" (chars-integer (nthcdr 16 header) 4)))
      (do ((ptr (1- (* width height)) (integer-1- ptr)))
          ((integer< ptr 0) (values bitmap width height))
        (%%set (+ bitmap ptr) (integer bitmap-list.))
        (= bitmap-list .bitmap-list)))))
