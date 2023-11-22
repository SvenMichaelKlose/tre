(functional rest)
(fn rest (x)
  .x)

(functional last)
(fn last (x)
  (? .x
     (last .x)
     x))

(fn %nconc-0 (lsts)
  (& lsts
     (!? lsts.
         (progn
           (rplacd (last !) (%nconc-0 .lsts))
           !)
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

(functional append)
(fn append (&rest lists)
  (& lists
     (let result nil
       (let l nil
         (dolist (i lists result)
           (& i
              (? l
                 (setq l (last (rplacd l (copy-list i))))
                 (setq result (copy-list i)
                       l (last result)))))))))

(functional caar cadr cdar cddr cadar cddar caadar caddr caadr cdddr cdadar caaddr caddar cdddar cddddr cadadr cadaddr cadadar cddadar)

(fn caar (x) (car (car x)))
(fn cadr (x) (car (cdr x)))
(fn cdar (x) (cdr (car x)))
(fn cddr (x) (cdr (cdr x)))
(fn cadar (x) (cadr (car x)))
(fn cddar (x) (cddr (car x)))
(fn cdadr (x) (cdar (cdr x)))
(fn caddr (x) (car (cddr x)))
(fn caadr (x) (car (cadr x)))
(fn cdddr (x) (cdr (cdr (cdr x))))
(fn cddddr (x) (cdr (cdr (cdr (cdr x)))))
(fn caadar (x) (car (cadr (car x))))
(fn cdadar (x) (cdr (cadr (car x))))
(fn caaddr (x) (car (caddr x)))
(fn caddar (x) (caddr (car x)))
(fn cdddar (x) (cdddr (car x)))
(fn cadadr (x) (cadr (cadr x)))
(fn cadaddr (x) (cadr (caddr x)))
(fn cadadar (x) (cadr (cadr (car x))))
(fn cddadar (x) (cddr (cadr (car x))))

(fn (= car) (val lst) (rplaca lst val) val)
(fn (= cdr) (val lst) (rplacd lst val) val)
(fn (= caar) (val lst) (rplaca (car lst) val) val)
(fn (= cadr) (val lst) (rplaca (cdr lst) val) val)
(fn (= cdar) (val lst) (rplacd (car lst) val) val)
(fn (= cddr) (val lst) (rplacd (cdr lst) val) val)
(fn (= caddr) (val lst) (rplaca (cddr lst) val) val)

(functional copy-tree)
(fn copy-tree (x)
  (? (atom x)
     x
     (. (copy-tree x.)
        (copy-tree .x))))

(functional ensure-list)
(fn ensure-list (x)
  (& x
     (? (list? x)
        x
        (list x))))

(defmacro ensure-list! (x)
  `(= ,x (ensure-list ,x)))

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

(fn dynamic-map (func &rest lists)
  (?
    (string? lists.)  (list-string (apply #'mapcar func (mapcar #'string-list lists)))
    (array? lists.)   (apply #'mapcar func (mapcar #'array-list lists))
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

(functional list-length)
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
