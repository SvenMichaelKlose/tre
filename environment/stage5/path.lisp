(fn path-append (dir &rest path-components)
  (@ (x (remove-if #'not path-components) dir)
    (= dir (string-concat (| (trim-tail dir "/") "") "/" (trim x "/")))))

(fn path-pathlist (x)
  (split #\/ x))

(fn pathlist-path (x)
  (? x
     (*> #'string-concat (pad x "/"))
     ""))

(fn path-filename (x)
  (car (last (path-pathlist x))))

(fn path-parent (x)
  (!? (butlast (path-pathlist x))
      (pathlist-path !)))   ; Would return "" otherwise.

(fn path-suffix (x)
  (car (last (split #\. x))))
