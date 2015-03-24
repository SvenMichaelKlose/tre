; tré – Copyright (c) 2010–2015 Sven Michael Klose <pixel@hugbox.org>

(defun dump-pass? (name)
  (& *transpiler*
     (!? (dump-passes?)
         (| (t? !)
            (member name (ensure-list !))))))

(defmacro transpiler-pass (name &rest name-fun-pairs)
  (print-definition `(transpiler-pass ,name))
  (with-gensym (buf init)
    `(defun ,name (,init)
       (when (t? (dump-passes?))
         (format t "~L; #### ~A ####~%" ',name))
       (let ,buf ,init
         (@ (i (list ,@(@ [`(. ,(make-keyword _.) ,._.)]
                          (group name-fun-pairs 2))))
           (when (enabled-pass? i.)
             (when (dump-pass? i.)
               (format t "~L; **** ~A output:~%" i.))
             (= ,buf (with-global-funinfo (funcall .i ,buf)))
             (= (last-pass-result) ,buf)
             (when (dump-pass? i.)
               (late-print ,buf)
               (format t "~L; **** end of ~A~%" i.))))
         ,buf))))
