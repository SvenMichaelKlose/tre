;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun shared-mapcar (fun &rest lsts)
  `(,(if (= 1 (length lsts))
         'filter
         'mapcar)
        ,fun ,@lsts))
