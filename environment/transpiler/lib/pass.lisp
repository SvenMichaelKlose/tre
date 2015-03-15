; tré – Copyright (c) 2010–2015 Sven Michael Klose <pixel@hugbox.org>

(defvar *current-pass-input* nil)

(defmacro transpiler-pass (name &rest name-fun-pairs)
  (print-definition `(transpiler-pass ,name))
  (with (cache-var ($ '*pass- name '*)
         init (gensym))
        (print
    `(progn
       (defvar ,cache-var nil)
       (defun ,name (,init)
         (when (dump-passes?)
           (fresh-line)
           (format t "; #### ~A ####~%" ',name))
         (= ,cache-var ,init)
         (@ (i (list ,@(@ #'cadr (group name-fun-pairs 2))) ,cache-var)
           (with-global-funinfo
             (= ,cache-var (= (last-pass-result) (funcall i ,cache-var)))))))
    )))

(defmacro def-pass-fun (name arg &body body)
  (print-definition `(def-pass-fun ,name ,arg))
  (with-gensym fun
    `(defun ,name (,arg)
       (with (,fun  #'((,arg) ,@body))
         (? (& *transpiler*
               (!? (dump-passes?)
                (| (t? !)
                   (member ',name (ensure-list !)))))
            (progn
              (fresh-line)
              (format t ,(string-concat "; **** " (symbol-name name) "~%"))
              (with-temporary *current-pass-input* ,arg
                (prog1
                  (with-temporary *always-print-package-names?* t
                    (late-print (,fun ,arg)))
                  (fresh-line)
                  (format t ,(string-concat "; **** end of " (symbol-name name) "~%")))))
            (,fun ,arg))))))
