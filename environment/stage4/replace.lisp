(defun replace (old-elm new-elm lst &key (test #'eq))
  (@ [? (funcall test _ old-elm)
        new-elm
        _]
     lst))

(defun replace-tree (old-elm new-elm lst &key (test #'eq))
  (@ [?
       (funcall test _ old-elm)  new-elm
       (cons? _)                 (replace-tree old-elm new-elm _ :test test)
       _]
     lst))
