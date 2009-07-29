(setf *opt-inline?* nil)

,`(defun fnord ()
    ,@*functions-after-stage-2*
	#'argument-expand #'lambda-expand #'expression--expand #'place-expand)
