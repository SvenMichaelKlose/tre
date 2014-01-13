;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

,(? (transpiler-cps-transformation? *transpiler*)
    '(progn
       (defvar *exceptions* nil)
       (defvar *exception* nil)

       (declare-cps-exception %catch)
       (declare-cps-wrapper %catch)
       (declare-native-cps-function %catch)

       (defmacro catch (catcher &body body)
         `(progn
            (%catch ~%cont #'(()
                                ,catcher
                                (funcall ~%cont))
                    *exceptions*)
            (prog1 (progn ,@body)
              (pop *exceptions*))))

       (declare-cps-exception throw)
       (declare-cps-wrapper throw)
       (declare-native-cps-function throw)

       (defun throw (continuer x)
         (alet (pop *exceptions*)
           (= *exception* .!)
           (funcall !. x)))))
