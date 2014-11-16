;;;;; tré – Copyright (c) 2010–2012,2014 Sven Michael Klose <pixel@copei.de>

(defun detect-language ()
  (make-symbol (upcase (subseq (| window.navigator.user-language
                                  window.navigator.language)
                               0 2))))
