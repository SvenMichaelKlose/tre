(fn detect-language ()
  (make-keyword (upcase (subseq (| window.navigator.user-language
                                   window.navigator.language)
                                0 2))))
