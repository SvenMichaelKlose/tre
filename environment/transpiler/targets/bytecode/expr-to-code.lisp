; tré – Copyright (c) 2012–2016 Sven Michael Klose <pixel@copei.de>

(def-head-predicate %%bc-return)

(defun get-bc-value (x)
  (case x. :test #'eq
    '%stack  (values (list .x.) ..x)
    '%vec    (with ((vec n) (get-bc-value .x))
               (values `(%vec ,@vec ,n.) .n))
    (values (list x.) .x)))

(defun get-tag-indexes (x)
  (with (indexes (make-queue)
         f #'((x i)
                (?
                  (not x)      x
                  (quote? x)   (f ..x (+ 2 i))
                  (%%tag? x)   {(enqueue indexes (. .x. i))
                                (f ..x i)}
                  (f .x (++ i)))))
    (f x 0)
    (queue-list indexes)))

(defun translate-jumps (indexes x)
  (with (tag-index [& ._. (assoc-value ._. indexes :test #'==)]
         f [?
             (not _)     _
             (%%tag? _)  (f .._)
             (. _.
                (case _. :test #'eq
                  'quote        (. ._.
                                   (f .._))
                  '%%go         (. (tag-index _)
                                   (f .._))
                  (? (in? _. '%%go-nil '%%go-not-nil)
                     (with ((cnd n) (get-bc-value .._))
                       `(,(tag-index _) ,@cnd ,@(f n)))
                     (f ._)))]))
    (f x)))

(defun make-bytecode-function (fi x)
  `(,(funinfo-name fi)
    ,(funinfo-argdef fi)
    ,(funinfo-framesize fi)
    ,@(translate-jumps (get-tag-indexes x) x)))

(defun get-next-function (x)
  (cdr (member '%%%bc-fun x :test #'eq)))

(defun copy-until-%bc-return (x)
  (when x
    (?
      (quote? x)              (. x.  (. .x. (copy-until-%bc-return ..x)))
      (%stack? x)             (. .x. (copy-until-%bc-return ..x))
      (not (%%bc-return? x))  (. x.  (copy-until-%bc-return .x)))))

(defun next-%bc-return (x)
  (?
    (not x)                 x
    (quote? x)              (next-%bc-return ..x)
    (not (%%bc-return? x))  (next-%bc-return .x)
    .x))

(defun expr-to-code (tr expr)
  (!? (get-next-function expr)
      (. (make-bytecode-function (get-funinfo !. tr)
                                 (copy-until-%bc-return .!))
         (expr-to-code tr (next-%bc-return ..!)))))
