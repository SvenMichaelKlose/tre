; tré - Copyright (c) 2011–2013,2016 Sven Michael Klose <pixel@copei.de>

(defun function|symbol-function (x)
  (? (symbol? x)
     (symbol-function x)
     x))

,(? (| (configuration :save-sources?)
       (configuration :save-argument-defs-only?))
    '(defun function-arguments (x)
       (!? (function|symbol-function x)
           (!? !.__source
               (with-stream-string s !.
                 (read s))
               '(&rest unknown-args))
           '(&rest unknown-args)))
    '(defun function-arguments (x)
       '(&rest unknown-args)))

,(? (configuration :save-sources?)
    '(defun function-body (x)
       (alet (function|symbol-function x)
         (!? !.__source
             (with-stream-string s .!
               (read s)))))
    '(defun function-body (x)))

(defun function-source (x)
  (alet (function|symbol-function x)
    (& !.__source
       `#'(,(function-arguments !)
           ,@(function-body !)))))
