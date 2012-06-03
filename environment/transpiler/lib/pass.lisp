;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defvar *transpiler-debug-dump* nil)
(defvar *current-pass* nil)
(defvar *last-pass-result* nil)

(defmacro transpiler-pass (name args &rest x)
  (with (cache-var ($ '*pass- name '*)
         init (gensym))
    `(progn
       (defvar ,cache-var nil)
       (defun ,name (,@args ,init)
         (setf ,cache-var ,init)
         (dolist (i (list ,@(mapcan (fn `((with-temporary *current-pass* ,(list 'quote _.)
                                            (setf *last-pass-result*
                                                  (? *transpiler-debug-dump*
                                                     #'((x)
                                                         (format t ,(string-concat "; **** before " (symbol-name _.) "~%"))
                                                           (prog1
                                                             (print (funcall ,._. x))
                                                             (format t ,(string-concat "; **** after " (symbol-name _.) "~%"))
                                                             (force-output)))
                                                     ,._.)))))
                                    (reverse (group x 2))))
                   ,cache-var)
           (setf ,cache-var (funcall i ,cache-var)))))))
