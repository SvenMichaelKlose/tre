(%defun %simple-map (func lst)
  (? lst
     (? (cons? lst)
        (apply func (list lst.))
        (%simple-map func .lst))))

(%defun %simple-mapcar (func lst)
  (? lst
     (? (cons? lst)
        (. (apply func (list lst.))
           (%simple-mapcar func .lst)))))
