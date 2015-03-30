; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(defun defined-or-wanted? (x)
  (| (defined-function x)
     (defined-variable x)
     (wanted-function? x)
     (wanted-variable? x)
     (transpiler-macro *transpiler* x)))

(defun can-import-function? (x)
  (& (symbol? x)
     (fbound? x)
     (not (builtin? (symbol-function x))
          (alien-package? x)
          (defined-or-wanted? x))))
	
(defun add-wanted-function (x)
  (when (can-import-function? x)
    (= (href (wanted-functions-hash) x) t)
    (push x (wanted-functions))
    (print-note "Scheduled #'~A for import.~%" x))
  x)

(defun add-wanted-functions (x)
  (@ (i x x)
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
    (print-note "Scheduled ~A for import.~%" x))
  x)

(defun import-exported-closures ()
  (& (exported-closures)
     (append (frontend (pop (exported-closures)))
             (import-exported-closures))))

(defun import-wanted-functions ()
  (awhen (wanted-functions)
    (= (wanted-functions) nil)
    (print-note "Importing functions ~A.~%" !)
    (frontend (mapcan [unless (defined-function _)
                        `((defun ,_ ,(host-function-arguments _)
                           ,@(host-function-body _)))]
                      !))))

(defun import-wanted-variables ()
  (awhen (wanted-variables)
    (= (wanted-variables) nil)
    (print-note "Importing variables ~A.~%" !)
    (frontend (mapcan [unless (defined-variable _)
                       `((defvar ,_ ,(assoc-value _ *variables* :test #'eq)))]
                      !))))

; XXX: DELAYED-VAR-INITS doesn't belong here.
(defun import-from-host ()
  (when (import-from-host?)
    (with-temporary (configuration :save-argument-defs-only?) nil
      (with (funs      (import-wanted-functions)
             exported  (import-exported-closures)
             vars      (import-wanted-variables))
        (? (| funs exported vars)
           (append funs exported vars (import-from-host))
           (delayed-var-inits))))))

(defun current-scope? (x)
  (member x (funinfo-names *funinfo*) :test #'eq))

(defun import-add-used (x)
  (| (current-scope? x)
     (add-used-function x))
  x)
