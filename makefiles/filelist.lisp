(format t "environment/main.lisp~%")
(filter [format t "environment/~A~%" _] (reverse (carlist *environment-filenames*)))
(quit)
