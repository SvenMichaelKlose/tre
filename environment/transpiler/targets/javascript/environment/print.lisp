;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(dont-inline print)

(defun print (x &optional (str *standard-output*))
  (with-default-stream s str
    (%late-print x s)))

(dont-inline force-output)

(defun force-output (&optional (str *standard-output*)))
