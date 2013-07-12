;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(def-head-predicate %%bc-return)

(defun get-bc-value (x)
  (case x. :test #'eq
    '%stack (values (list .x.) ..x)
    '%vec   (with ((vec n) (get-bc-value .x))
              (values `(%vec ,@vec ,n.) .n))
    (values (list x.) .x)))

(defun get-tag-indexes (x)
  (with (indexes (make-queue)
         rec #'((x i)
                  (?
                    (not x)     x
                    (%quote? x) (rec ..x (+ 2 i))
                    (%%tag? x)  (progn
                                  (enqueue indexes (cons .x. i))
                                  (rec ..x i))
                    (rec .x (1+ i)))))
    (rec x 0)
    (queue-list indexes)))

(defun translate-jumps (indexes x)
  (with (get-tag-index [& _ (| (assoc-value _ indexes :test #'==)
                               (error "cannot get bytecode index ~A in ~A" _ indexes))]
         rec #'((x)
                  (?
                    (not x)    x
                    (%%tag? x) (rec ..x)
                    (cons x. (case x. :test #'eq
                               '%quote   (cons .x. (rec ..x))
                               '%%go-nil (with ((cnd n) (get-bc-value ..x))
                                           `(,(get-tag-index .x.),@cnd ,@(rec n)))
                               '%%go     (cons (get-tag-index .x.) (rec ..x))
                               (rec .x))))))
    (rec x)))

(defun make-bytecode-function (fi x)
  `(,(funinfo-name fi)
    ,(funinfo-argdef fi)
    ,(length (funinfo-vars fi))
    ,@(translate-jumps (get-tag-indexes x) x)))

(defun get-next-function (x)
  (cdr (member '%%%bc-fun x :test #'eq)))

(defun copy-until-%bc-return (x)
  (when x
    (?
      (%quote? x)             (cons x. (cons .x. (copy-until-%bc-return ..x)))
      (%stack? x)             (cons .x. (copy-until-%bc-return ..x))
      (not (%%bc-return? x))  (cons x. (copy-until-%bc-return .x)))))

(defun next-%bc-return (x)
  (?
    (not x) x
    (%quote? x)            (next-%bc-return ..x)
    (not (%%bc-return? x)) (next-%bc-return .x)
    .x))

(defun expr-to-code (tr expr)
  (let-when x (get-next-function expr)
    (cons (make-bytecode-function (get-funinfo x. tr) (print (copy-until-%bc-return .....x)))
          (expr-to-code tr (next-%bc-return ..x)))))
