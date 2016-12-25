; TOOD: Remove this. Was required to make new CL core.

(defun tre-symbol (x)
  (cl:intern (symbol-name x) "TRE"))
