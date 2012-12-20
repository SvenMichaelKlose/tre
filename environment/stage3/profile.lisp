;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defvar *profile* (make-hash-table :test #'eq))
(defvar *profile-lock* t)

(defun add-profile (name nsec)
  (with-temporary *profile-lock* t
    (= (href *profile* name) (integer+ (| (href *profile* name) 0) nsec))))

(defun add-profile-call (name)
  (with-temporary *profile-lock* t
    (= (href *profile* name) (integer+ (| (href *profile* name) 0) 1))))

(defun clear-profile ()
  (= *profile* (make-hash-table :test #'eq)))

(defmacro with-profile (&body body)
  `(with-temporary *profile-lock* nil
     ,@body))

(defun profile ()
  (sort (filter [cons ._ _.] (hash-alist *profile*)) :test #'((a b) (< a. b.))))
