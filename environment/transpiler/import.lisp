(fn defined-or-wanted? (x)
  (| (defined-function x)
     (defined-variable x)
     (wanted-function? x)
     (wanted-variable? x)
     (transpiler-macro *transpiler* x)))

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

(fn import-exported-closures ()
  (& (exported-closures)
     (append (frontend (pop (exported-closures)))
             (import-exported-closures))))

(fn import-wanted-functions ()
  (awhen (wanted-functions)
    (= (wanted-functions) nil)
    (developer-note "Importing functions ~A…~%" !)
    (frontend (mapcan [unless (defined-function _)
                        `((fn ,_ ,(host-function-arguments _)
                           ,@(host-function-body _)))]
                      !))))

(fn import-wanted-variables ()
  (awhen (wanted-variables)
    (= (wanted-variables) nil)
    (developer-note "Importing variables ~A…~%" !)
    (frontend (mapcan [unless (defined-variable _)
                       `((var ,_ ,(assoc-value _ *variables* :test #'eq)))]
                      !))))

(fn import-from-host ()
  (when (import-from-host?)
    (with-temporary (configuration :save-argument-defs-only?) nil
      (with (funs      (make-queue)
             closures  (make-queue)
             vars      (make-queue)
             r         #'(()
                           (with (f  (import-wanted-functions)
                                  c  (import-exported-closures)
                                  v  (import-wanted-variables))
                             (& f (enqueue funs f))
                             (& c (enqueue closures c))
                             (& v (enqueue vars v))
                             (& (| f c v)
                                (r)))))
        (r)
        (append (apply #'append (queue-list vars))
                (apply #'append (queue-list closures))
                (apply #'append (queue-list funs)))))))

(fn current-scope? (x)
  (member x (funinfo-names *funinfo*) :test #'eq))

(fn import-add-used (x)
  (| (current-scope? x)
     (add-used-function x))
  x)
