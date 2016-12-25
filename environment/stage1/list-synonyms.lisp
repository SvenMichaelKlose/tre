(defconstant *first-to-tenth*
  '(first second third fourth fifth sixth seventh eighth ninth tenth))

(defun %make-cdr (i)
  (? (== i 0)
     'x
     `(cdr ,(%make-cdr (-- i)))))

(defmacro %make-list-synonyms ()
  `(block nil
     ,@(let* ((l nil)
              (i 0))
         (@ #'((name)
           		(push `(block nil
                         (functional ,name)
                         (defun ,name (x)
                           (car ,(%make-cdr i)))
                         (defun (= ,name) (v x)
                           (rplaca ,(%make-cdr i) v)))
                      l)
                (++! i))
            *first-to-tenth*)
         l)))

(%make-list-synonyms)

(functional rest)

(defun rest (x) .x)
