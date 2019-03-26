;;;;; tré – Copyright (c) 2005,2008–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

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

(define-test "%SIMPLE-MAPCAR"
  ((%simple-mapcar #'identity '(1 2 3)))
  '(1 2 3))
