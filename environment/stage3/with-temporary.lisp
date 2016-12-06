; tré – Copyright (c) 2005–2008,2012–2013,2016 Sven Michael Klose <pixel@hugbox.org>

(defmacro with-temporary (place val &body body)
  (with-gensym old-val
    `(with (,old-val ,place)
       (= ,place ,val)
       (prog1
         {,@body}
         (= ,place ,old-val)))))

(defmacro with-temporaries (lst &body body)
  (| lst (error "Assignment list expected."))
  `(with-temporary ,lst. ,.lst.
     ,@(? ..lst
          `((with-temporaries ,..lst ,@body))
          body)))
