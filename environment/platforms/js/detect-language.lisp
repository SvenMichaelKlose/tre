(defun detect-language ()
  (make-symbol (upcase (subseq (| window.navigator.user-language
                                  window.navigator.language)
                               0 2))))
