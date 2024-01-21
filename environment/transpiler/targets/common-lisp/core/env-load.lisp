(var *environment-path* ".")
(var *environment-filenames* nil)

(defbuiltin env-load (file-specifier &rest targets)
  (print-definition `(env-load ,file-specifier ,@targets))
  (acons! file-specifier targets *environment-filenames*)
  (when (| (not targets)
           (member :cl targets))
    (load (+ *environment-path* "/environment/" file-specifier))))
