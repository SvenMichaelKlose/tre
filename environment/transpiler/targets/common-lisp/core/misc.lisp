;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun quit (&optional exit-code)
  (sb-ext:quit :unix-status exit-code))

(defun nanotime () 0)                                                                                                                                        
