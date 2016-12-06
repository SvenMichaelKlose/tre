; tré – Copyright (c) 2014–2016 Sven Michael Klose <pixel@copei.de>

,(? (enabled-pass? :cps)
    '{(defvar *exceptions* nil)
      (defvar *exception* nil)

      (declare-cps-exception %catch)
      (declare-cps-wrapper %catch)
      (declare-native-cps-function %catch)

      (defmacro catch (catcher &body body)
        `{(%catch ~%cont #'(()
                              ,catcher
                              (funcall ~%cont))
                  *exceptions*)
          (prog1 {,@body}
            (pop *exceptions*))})

      (declare-cps-exception throw)
      (declare-cps-wrapper throw)
      (declare-native-cps-function throw)

      (defun throw (continuer x)
        (alet (pop *exceptions*)
          (= *exception* .!)
          (funcall !. x)))})
