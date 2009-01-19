;;;;; TRE environment
;;;;; Copyright (c) 2005,2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Simple map functions.

;; Apply function to elements of list.
(%defun %simple-map (func lst)
  (if lst
      (if (consp lst)
          (apply func (list (car lst)))
          (%simple-map func (cdr lst)))))

;; Apply function to elements of list and return new list with results.
(%defun %simple-mapcar (func lst)
  (if lst
      (if (consp lst)
          (cons (apply func (list (car lst)))
                (%simple-mapcar func (cdr lst))))))

(define-test "%SIMPLE-MAPCAR"
  ((%simple-mapcar #'identity '(1 2 3)))
  '(1 2 3))
