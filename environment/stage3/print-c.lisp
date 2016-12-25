(defun %print-object (x str info))

(defun %print-get-args (args def)
  (argument-expand 'print def args :concatenate-sublists? nil
                                   :break-on-errors? nil))
