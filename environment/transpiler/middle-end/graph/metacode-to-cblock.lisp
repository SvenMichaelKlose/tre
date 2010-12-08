;;;;; TRE transpiler

(defstruct cblock
  (code nil)
  (next nil)
  (conditional-next nil)
  (conditional-place nil))

(defun copy-until-cblock-end (x)
  (let result (make-queue)
    (while (and x
                (not (vm-jump? x.))
                (not (numberp .x.)))
           (values (append (queue-list result)
                           (when x
                             (list x.)))
                   .x)
      (enqueue result x.)
      (setf x .x))))

(defun metacode-to-cblocks (x)
  (when x
    (with ((copy next) (copy-until-cblock-end x))
      (cons (make-cblock :code copy)
            (metacode-to-cblocks next)))))

(defun make-cblock-taglist (x)
  (let tags nil
    (dolist (i x tags)
      (let f (car (cblock-code i))
        (when (numberp f)
          (acons! f i tags)
          (setf (cblock-code i) (cdr (cblock-code i))))))))

(defun make-cblock-links (x tags)
  (when x
    (with (cb x.
           l (car (last (cblock-code cb))))
      (if
        (%%vm-go? l)
          (setf (cblock-next cb) (assoc-value .l. tags :test #'=))
        (%%vm-go-nil? l)
          (setf (cblock-conditional-next cb) (assoc-value ..l. tags :test #'=)
                (cblock-conditional-place cb) .l.)
        (setf (cblock-next cb) .x.))
      (when (vm-jump? l)
        (setf (cblock-code cb) (butlast (cblock-code cb))))
      (make-cblock-links .x tags))))

(defun cblock-to-metacode (x)
  (let tags (mapcar (fn cons _ (make-compiler-tag)) x)
    (mapcan #'((tag cb)
                 (append (list tag)
                         (cblock-code cb)
                         (aif (cblock-conditional-next cb)
                              `((%%vm-go-nil ,(cblock-conditional-place cb)
                                             ,(assoc-value ! tags :test #'eq)))
                              (awhen (assoc-value (cblock-next cb) tags :test #'eq)
                                `((%%vm-go ,!))))))
            (cdrlist tags)
            x)))

(defun middleend-graph-0 (x)
  (let blks (metacode-to-cblocks (lambda-body x))
    (make-cblock-links blks (make-cblock-taglist blks))
      (cblock-to-metacode blks)))

(define-tree-filter middleend-graph (x)
  (named-lambda? x)
	(copy-lambda x
				 :body (middleend-graph-0 x))
  (lambda? x)
	(copy-lambda x
				 :body (middleend-graph-0 x)))
