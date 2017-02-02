(fn path-append (dir &rest path-components)
  (@ (x (remove-if #'not path-components) dir)
    (= dir (+ (trim-tail dir "/") "/" (trim x "/")))))
