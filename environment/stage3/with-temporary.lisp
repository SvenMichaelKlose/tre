;;;;; tré - Copyright (c) 2005-2008,2012 Sven Michael Klose <pixel@copei.de>

(defmacro with-temporary (place val &rest body)
  (with-gensym old-val
    `(with (,old-val ,place)
       (setf ,place ,val)
       (prog1
         (progn
           ,@body)
         (setf ,place ,old-val)))))

(defmacro with-temporaries (lst &rest body)
  (? lst
     `(with-temporary ,lst. ,.lst.
        ,@(? ..lst
             `((with-temporaries ,..lst ,@body))
             body))
     (error "WITH-TEMPORARIES: assignment list expected")))

; XXX tests missing
