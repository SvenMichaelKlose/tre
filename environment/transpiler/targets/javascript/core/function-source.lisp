; tré - Copyright (c) 2011–2013,2015 Sven Michael Klose <pixel@copei.de>

(defun function|symbol-function (x)
  (? (symbol? x)
     (symbol-function x)
     x))

(defun function-arguments (x)
  (!? (function|symbol-function x)
      (!? !.__source
          (with-stream-string s !.
            (read s))
          '(&rest unknown-args))
      '(&rest unknown-args)))

(defun function-body (x)
  (alet (function|symbol-function x)
    (!? !.__source
        (with-stream-string s .!
          (read s)))))

(defun function-source (x)
  (alet (function|symbol-function x)
    (& !.__source
       `#'(,(function-arguments !)
           ,@(function-body !)))))
