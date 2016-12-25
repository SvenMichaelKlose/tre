(defun fileurl? (x)     ; TODO: Remove. HEAD? does nicely.
  (string== "file://" (subseq x 0 7)))
