(var *collected-errors* nil)

(fn collect-error (format-string &rest args)
  (push (*> #'format nil format-string args) *collected-errors*))

(fn issue-collected-errors ()
  (when *collected-errors*
    (!= (*> #'+ (@ [+ _ "~%"] *collected-errors*))
      (= *collected-errors* nil)
      (error (format nil !)))))
