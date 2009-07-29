(setf *opt-inline?* nil)

,`(defun fnord ()
    ,@*functions-after-stage-1*
    #'reverse #'append #'tree-list #'find #'assoc #'href #'%macroexpand #'position #'mapcan
    #'argument-expand #'lambda-expand #'expression--expand #'place-expand)
