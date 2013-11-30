;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun detect-language ()
  (make-symbol (string-upcase (subseq (| window.navigator.user-language
                                         window.navigator.language)
                                      0 2))))
