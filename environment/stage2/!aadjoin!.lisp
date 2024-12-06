(defmacro !aadjoin! (key init update al &key (test #'equal))
  (with-gensym g-key
    `(with (,g-key ,key)
       (!? (assoc ,g-key ,al :test ,test)
           ,update
           (acons! ,g-key ,init ,al)))))
