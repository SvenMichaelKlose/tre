(fn defined-or-wanted? (x)
  (| (defined-function x)
     (defined-variable x)
     (wanted-function? x)
     (wanted-variable? x)
     (codegen-macro? x)))

(fn alien-package? (x)
  (in? (package-name (symbol-package x)) "COMMON-LISP" "SB-EXT"))

(fn can-import-function? (x)
  (& (symbol? x)
     (fbound? x)
     (not (builtin? (symbol-function x))
          (alien-package? x)
          (defined-or-wanted? x))))

(fn add-wanted-function (x)
  (when (can-import-function? x)
    (= (href (wanted-functions-hash) x) t)
    (push x (wanted-functions))
    (developer-note "Scheduled #'~A for import.~%" x))
  x)

(fn add-wanted-functions (x)
  (@ (i x x)
    (add-wanted-function i)))

(fn can-import-variable? (x)
  (& (import-variables?)
     (import-from-host?)
     x
     (symbol? x)
     (not (funinfo-find *funinfo* x)
          (defined-or-wanted? x))
     (| (host-variable? x)
        (assoc x *constants* :test #'eq))))

(fn add-wanted-variable (x)
  (when (can-import-variable? x)
    (= (href (wanted-variables-hash) x) t)
    (push x (wanted-variables))
    (developer-note "Scheduled ~A for import.~%" x))
  x)

(fn import-closures ()
  (& (closures)
     (append (frontend (pop (closures)))
             (import-closures))))

(fn import-wanted-functions ()
  (awhen (wanted-functions)
    (= (wanted-functions) nil)
    (developer-note "Importing functions ~A…~%" !)
    (frontend (+@ [unless (defined-function _)
                    `((fn ,_ ,(host-function-arguments _)
                       ,@(host-function-body _)))]
                  !))))

(fn import-wanted-variables ()
  (awhen (wanted-variables)
    (= (wanted-variables) nil)
    (developer-note "Importing variables ~A…~%" !)
    (frontend (+@ [unless (defined-variable _)
                   `((var ,_ ,(assoc-value _ *variables* :test #'eq)))]
                  !))))

(fn import-from-host ()
  (when (import-from-host?)
    (with-temporary (configuration :save-argument-defs-only?) nil
      (with (funs      (import-wanted-functions)
             closures  (import-closures)
             vars      (import-wanted-variables))
        (& (| funs closures vars)
           (append vars (import-from-host) closures funs))))))
