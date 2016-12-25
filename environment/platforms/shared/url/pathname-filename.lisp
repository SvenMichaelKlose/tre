(defun pathname-filename (x) ; TODO: Rename to PATH-FILENAME.
  (car (last (path-pathlist x))))
