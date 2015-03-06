(format t "environment/main.lisp~%")
(@ [format t "environment/~A~%" _]
   (reverse (carlist *environment-filenames*)))
(quit)
