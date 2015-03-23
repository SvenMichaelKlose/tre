; tré – Copyright (c) 2010–2015 Sven Michael Klose <pixel@hugbox.org>

(defvar *current-pass-input* nil)

(defmacro transpiler-pass (name &rest name-fun-pairs)
  (print-definition `(transpiler-pass ,name))
  (with (cache-var ($ '*pass- name '*)
         init (gensym))
    `(progn
       (defvar ,cache-var nil)
       (defun ,name (,init)
         (when (t? (dump-passes?))
           (fresh-line)
           (format t "; #### ~A ####~%" ',name))
         (= ,cache-var ,init)
         (@ (i (list ,@(@ #'cadr (group name-fun-pairs 2))) ,cache-var)
           (with-global-funinfo
             (= ,cache-var (= (last-pass-result) (funcall i ,cache-var)))))))))

(defun dump-pass? (name)
  (& *transpiler*
     (!? (dump-passes?)
         (| (t? !)
            (member name (ensure-list !))))))

(defmacro def-pass-fun (name arg &body body)
  (print-definition `(def-pass-fun ,name ,arg))
  (with-gensym fun
    `(defun ,name (,arg)
       (with (,fun  #'((,arg) ,@body))
         (unless (dump-pass? ',name)
           (return (,fun ,arg)))
         (fresh-line)
         (format t ,(string-concat "; **** " (symbol-name name) "~%"))
         (prog1
           (with-temporary *current-pass-input* ,arg
             (late-print (,fun ,arg)))
           (fresh-line)
           (format t ,(string-concat "; **** end of " (symbol-name name) "~%")))))))
