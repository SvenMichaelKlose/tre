(fn function|symbol-function (x)
  (? (symbol? x)
     (symbol-function x)
     x))

,(? (| (configuration :save-sources?)
       (configuration :save-argument-defs-only?))
    '(fn function-arguments (x)
       (!? (function|symbol-function x)
           (!? !.__source
               (with-stream-string s !.
                 (read s))
               '(&rest unknown-args))
           '(&rest unknown-args)))
    '(fn function-arguments (x)
       '(&rest unknown-args)))

,(? (configuration :save-sources?)
    '(fn function-body (x)
       (!= (function|symbol-function x)
         (!? !.__source
             (with-stream-string s .!
               (read s)))))
    '(fn function-body (x)))

(fn function-source (x)
  (!= (function|symbol-function x)
    (& !.__source
       `#'(,(function-arguments !)
           ,@(function-body !)))))
