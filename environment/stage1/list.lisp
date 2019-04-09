(functional last)
(fn last (x)
  (? .x
     (last .x)
     x))

(fn %nconc-0 (lsts)
  (& lsts
     (!? lsts.
         {(rplacd (last !) (%nconc-0 .lsts))
          !}
         (%nconc-0 .lsts))))

(fn nconc (&rest lsts)
  (%nconc-0 lsts))

(functional butlast)
(fn butlast (plist)
  (? .plist
     (. plist. (butlast .plist))))

(functional copy-list)
(fn copy-list (x)
  (? (atom x)
     x
     (. x. (copy-list .x))))

(functional nthcdr)
(fn nthcdr (idx x)
  (& x
     (? (zero? idx)
        x
        (nthcdr (-- idx) .x))))

(functional nth)
(fn nth (i x)
  (car (nthcdr i x)))

(functional caar cadr cdar cddr cadar cddar caadar caddr caadr cdddr cdadar caaddr caddar cdddar cddddr cadadr cadaddr cadadar cddadar)

(%defun caar (lst) (car (car lst)))
(%defun cadr (lst) (car (cdr lst)))
(%defun cdar (lst) (cdr (car lst)))
(%defun cddr (lst) (cdr (cdr lst)))
(%defun cadar (lst) (cadr (car lst)))
(%defun cddar (lst) (cddr (car lst)))
(%defun cdadr (lst) (cdar (cdr lst)))
(%defun caddr (lst) (car (cddr lst)))
(%defun caadr (lst) (car (cadr lst)))
(%defun cdddr (lst) (cdr (cdr (cdr lst))))
(%defun cddddr (lst) (cdr (cdr (cdr (cdr lst)))))
(%defun caadar (lst) (car (cadr (car lst))))
(%defun cdadar (lst) (cdr (cadr (car lst))))
(%defun caaddr (lst) (car (caddr lst)))
(%defun caddar (lst) (caddr (car lst)))
(%defun cdddar (lst) (cdddr (car lst)))
(%defun cadadr (lst) (cadr (cadr lst)))
(%defun cadaddr (lst) (cadr (caddr lst)))
(%defun cadadar (lst) (cadr (cadr (car lst))))
(%defun cddadar (lst) (cddr (cadr (car lst))))

(functional copy-tree)

(%defun copy-tree (x)
  (? (atom x)
     x
     (. (copy-tree x.)
        (copy-tree .x))))

(functional ensure-list)

(fn ensure-list (x)
  (? (list? x)
     x
     (list x)))

(defmacro push (elm expr)
  `(= ,expr (. ,elm ,expr)))

(defmacro pop (expr)
  `(let ret (car ,expr)
     (= ,expr (cdr ,expr))
     ret))

(fn pop! (args)
  (let ret args.
    (= args. .args.
       .args ..args)
    ret))

(const *first-to-tenth* '(first second third fourth fifth sixth seventh eighth ninth tenth))

(fn %make-cdr (i)
  (? (== i 0)
     'x
     `(cdr ,(%make-cdr (-- i)))))

(defmacro %make-list-synonyms ()
  `(block nil
     ,@(#'((l i)
            (mapcar #'((name)
                        (push `(block nil
                                 (functional ,name)
                                 (fn ,name (x)
                                   (car ,(%make-cdr i)))
                                 (fn (= ,name) (v x)
                                   (rplaca ,(%make-cdr i) v)))
                              l)
                        (++! i))
                    *first-to-tenth*)
            l)
          nil 0)))

(%make-list-synonyms)

(functional rest)

(fn rest (x) .x)

(fn dynamic-map (func &rest lists)
  (?
    (string? lists.)  (list-string (apply #'mapcar func (mapcar #'string-list lists)))
    (array? lists.)   (list-array (apply #'mapcar func (mapcar #'array-list lists)))
    (apply #'mapcar func lists)))

(fn mapcan (func &rest lists)
  (apply #'nconc (apply #'mapcar func lists)))

(fn member-if (pred &rest lsts)
  (dolist (i lsts)
    (do ((j i .j))
        ((not j))
      (? (funcall pred j.)
         (return-from member-if j)))))

(fn member-if-not (pred &rest lsts)
  (member-if #'((_) (not (funcall pred _))) lsts))

(functional reverse)

(fn reverse (lst)
  (!= nil
    (dolist (i lst !)
      (push i !))))

(functional adjoin)

(fn adjoin (obj lst &rest args)
  (? (apply #'member obj lst args)
     lst
     (. obj lst)))

(defmacro adjoin! (obj &rest place)
  `(= ,place. (adjoin ,obj ,@place)))

(fn list-length (x)
  (let len 0
    (while (cons? x)
           len
      (setq x .x)
      (++! len))))

(fn filter (func lst)
  (let result (. nil nil)
    (dolist (i lst .result)
      (rplaca result
              (cdr (rplacd (| result.
                              result)
                           (list (funcall func i))))))))
