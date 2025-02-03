(var *environment-pathnames* nil)

(defbuiltin env-load (file-specifier &rest targets)
  (print-definition `(env-load ,file-specifier ,@targets))
  (acons! file-specifier targets *environment-pathnames*)
  (when (| (not targets)
           (member :cl targets))
    (load (+ *environment-path* "/environment/" file-specifier))))
