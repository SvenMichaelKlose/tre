(functional member)

(fn member (elm lst &key (test #'eql))
  (do ((i lst .i))
      ((not i))
    (? (funcall test elm i.)
       (return-from member i))))

(fn member-if (pred &rest lsts)
  (@ (i lsts)
    (do ((j i .j))
        ((not j))
      (? (funcall pred j.)
         (return-from member-if j)))))

(fn member-if-not (pred &rest lsts)
  (member-if #'((_) (not (funcall pred _))) lsts))
