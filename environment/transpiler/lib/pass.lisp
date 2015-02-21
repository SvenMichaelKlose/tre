; tré – Copyright (c) 2010–2015 Sven Michael Klose <pixel@hugbox.org>

(defvar *current-pass-input* nil)

(defmacro transpiler-pass (name &rest name-fun-pairs)
  (print-definition `(transpiler-pass ,name))
  (with (cache-var ($ '*pass- name '*)
         init (gensym))
    `(progn
       (defvar ,cache-var nil)
       (defun ,name (,init)
         (= ,cache-var ,init)
         (dolist (i (list ,@(mapcar #'cadr (group name-fun-pairs 2))) ,cache-var)
           (with-global-funinfo
             (= ,cache-var (= (last-pass-result) (funcall i ,cache-var)))))))))

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
                  (print (,fun ,arg))
                  (format t ,(string-concat "; **** end of " (symbol-name name) "~%")))))
            (,fun ,arg))))))
