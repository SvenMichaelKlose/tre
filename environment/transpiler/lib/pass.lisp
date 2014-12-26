; tré – Copyright (c) 2010–2014 Sven Michael Klose <pixel@copei.de>

(defvar *current-pass-input* nil)

(defmacro transpiler-pass (name args &rest x)
  (with (cache-var ($ '*pass- name '*)
         init (gensym))
    `(progn
       (defvar ,cache-var nil)
       (defun ,name (,@args ,init)
         (= ,cache-var ,init)
         (dolist (i (list ,@(mapcan [`((with-temporary (current-pass) ,(list 'quote _.)
                                         (? (!? (dump-passes?)
                                                (| (t? !)
                                                   (member ',_. (ensure-list !))))
                                            #'((x)
                                                 (fresh-line)
                                                 (format t ,(string-concat "; **** " (symbol-name _.) "~%"))
                                                 (with-temporary *current-pass-input* x
                                                   (prog1
                                                     (print (funcall ,._. x))
                                                     (format t ,(string-concat "; **** " (symbol-name _.) " (end)~%")))))
                                            ,._.)))]
                                    (group x 2)))
                   ,cache-var)
           (with-global-funinfo
             (= ,cache-var (= (last-pass-result) (funcall i ,cache-var)))))))))
