(functional member)

(fn member (elm lst &key (test #'eql))
  (do ((i lst .i))
      ((not i))
    (? (~> test elm i.)
       (return i))))
