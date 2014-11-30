;;;;; tré – Copyright (c) 2005,2008–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(%defun %simple-map (func lst)
  (? lst
     (? (cons? lst)
        (apply func (list (car lst)))
        (%simple-map func (cdr lst)))))

(%defun %simple-mapcar (func lst)
  (? lst
     (? (cons? lst)
        (cons (apply func (list (car lst)))
              (%simple-mapcar func (cdr lst))))))

(define-test "%SIMPLE-MAPCAR"
  ((%simple-mapcar #'identity '(1 2 3)))
  '(1 2 3))
