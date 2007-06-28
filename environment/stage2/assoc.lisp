;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Associative lists

(defun assoc (key lst &key test)
  (when (consp lst)
    (dolist (i lst)
      (if (consp i)
	(if (funcall (or test eql) key (car i))
	  (return (cdr i)))
	(error "not a pair")))))

(defun assoc-cons (key lst &key test)
  (when (consp lst)
    (dolist (i lst)
      (if (consp i)
	(if (funcall (or test eql) key (car i))
	  (return i))
	(error "not a pair")))))

(defun (setf assoc) (new-value key lst &key test)
  (when (consp lst)
    (dolist (i lst)
      (if (consp i)
	(when (funcall (or test eql) key (car i))
          (rplacd i new-value)
	  (return new-value))
	(error "not a pair")))))

(defun acons (key val lst)
  "Prepend key/value pair to associative list."
  (cons (cons key val) lst))

(defmacro acons! (key val place)
  "Destructively prepend key/value pair to associative list."
  `(setf ,place (acons ,key ,val ,place)))

(defun copy-alist (lst)
  "Copy associative list."
  (let ((new nil))
    (do ((i lst (cdr lst)))
        ((endp i) new)
      (setf end (append! end (cons (car i) (cdr i)))))))
