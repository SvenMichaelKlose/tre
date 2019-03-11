(fn path-append (dir &rest path-components)
  (@ (x (remove-if #'not path-components) dir)
    (= dir (string-concat (| (trim-tail dir "/") "") "/" (trim x "/")))))
