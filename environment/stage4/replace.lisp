(fn replace (old-elm new-elm lst &key (test #'eql))
  (@ [? (~> test _ old-elm)
        new-elm
        _]
     lst))

(fn replace-tree (old-elm new-elm lst &key (test #'eql))
  (@ [?
       (~> test _ old-elm)
         new-elm
       (cons? _)
         (replace-tree old-elm new-elm _ :test test)
       _]
     lst))
