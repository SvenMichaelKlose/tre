; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(defvar *can-import-function?* nil)

(defun defined-or-wanted? (x)
  (| (defined-function x)
     (defined-variable x)
     (wanted-function? x)
     (wanted-variable? x)
     (transpiler-macro *transpiler* x)))

(defun can-import-function? (x)
  (& (symbol? x)
     (fbound? x)
     (not (alien-package? x))
     (!? *can-import-function?*
         (funcall ! x)
         t)
     (not (builtin? (symbol-function x))
          (defined-or-wanted? x))))
	
(defun add-wanted-function (x)
  (when (can-import-function? x)
    (= (href (wanted-functions-hash) x) t)
    (push x (wanted-functions))
    (print-note "Scheduled ~A for import from host.~%" x))
  x)

(defun add-wanted-functions (x)
  (dolist (i x x)
    (add-wanted-function i)))

(defun can-import-variable? (x)
  (& (import-variables?)
     (import-from-host?)
     x (symbol? x)
     (not (funinfo-find *funinfo* x)
          (defined-or-wanted? x))
     (| (host-variable? x)
        (assoc x *constants* :test #'eq))))

(defun add-wanted-variable (x)
  (when (can-import-variable? x)
    (= (href (wanted-variables-hash) x) t)
    (push x (wanted-variables))
    (print-note "Scheduled ~A for import from host.~%" x))
  x)

(defun import-exported-closures ()
  (& (exported-closures)
     (+ (frontend (pop (exported-closures)))
        (import-exported-closures))))

(defun import-wanted-function (x)
  (frontend `((defun ,x ,(host-function-arguments x)
                ,@(host-function-body x)))))

(defun import-wanted-functions ()
  (with-queue q
    (awhile (pop (wanted-functions))
            (apply #'+ (queue-list q))
      (| (defined-function !)
         (enqueue q (import-wanted-function !))))))

(defun generate-imported-defvars (x)
  (mapcan [unless (defined-variable _)
            `((defvar ,_ ,(assoc-value _ *variables* :test #'eq)))]
          x))

(defun import-wanted-variables ()
  (awhen (wanted-variables)
    (print-note "Importing variables ~A.~%" !)
    (frontend (generate-imported-defvars !))))

(defun import-from-host ()
  (when (import-from-host?)
    (print-status "Importing variables and named functions from host.~%")
    (with-temporary (configuration :save-argument-defs-only?) nil
      (with (funs     (import-wanted-functions)
             exported (import-exported-closures)
             vars     (import-wanted-variables))
        (? (| funs exported vars)
           (+ funs exported vars (import-from-host))
           (delayed-var-inits))))))

(defun current-scope? (x)
  (member x (funinfo-names *funinfo*) :test #'eq))

(defun import-add-used (x)
  (| (current-scope? x)
     (add-used-function x))
  x)
