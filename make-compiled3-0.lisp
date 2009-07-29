(setf *opt-inline?* nil)

,`(defun fnord ()
    ,@*functions-after-stage-3*
    #'argument-expand #'lambda-expand #'expression--expand #'place-expand)
