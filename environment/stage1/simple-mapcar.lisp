;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Simple map functions.

;; Apply function to elements of list.
(%defun %simple-map (func lst)
  (cond
    (lst
        (cond
          ((consp lst)
            (apply func (list (car lst)))
            (%simple-map func (cdr lst)))))))

;; Apply function to elements of list and return new list with results.
(%defun %simple-mapcar (func lst)
  (cond
    (lst
      (cond
        ((consp lst)
          (cons (apply func (list (car lst)))
                (%simple-mapcar func (cdr lst))))))))
