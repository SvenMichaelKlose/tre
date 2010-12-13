;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defmacro cblock-traverse-next (fun cb visited-blocks)
  (with-gensym visited-and-this
    `(let ,visited-and-this (cons ,cb ,visited-blocks)
       (awhen (cblock-next ,cb)
         (,fun ! ,visited-and-this))
       (awhen (cblock-conditional-next ,cb)
         (,fun ! ,visited-and-this)))))

(defun copy-until-cblock-end (x)
  (let result (make-queue)
    (while (and x
                (not (vm-jump? x.))
                (not (numberp .x.)))
           (values (append (queue-list result)
                           (when x
                             (list x.)))
                   .x)
      (enqueue result (copy-tree x.))
      (setf x .x))))

(defun metacode-to-cblocks-0 (x)
  (when x
    (with ((copy next) (copy-until-cblock-end x))
      (cons (make-cblock :code copy)
            (metacode-to-cblocks-0 next)))))

(defun metacode-to-cblocks (x fi)
  (append (list (make-cblock :ins (funinfo-args fi)))
          (metacode-to-cblocks-0 x)
          (list (make-cblock :ins (list '~%ret)))))

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
                (cblock-conditional-place cb) .l.
                (cblock-next cb) .x.)
        (setf (cblock-next cb) .x.))
      (when (vm-jump? l)
        (setf (cblock-code cb) (butlast (cblock-code cb))))
      (make-cblock-links .x tags))))

(defun cblock-collect-ins (x fi)
  (dolist (cb x)
    (let ins nil
      (dolist (i (reverse (cblock-code cb)))
        (remove! (%setq-place i) ins)
        (map (fn adjoin! _ ins)
             (let v (%setq-value i)
               (if (atom v)
                   (when (funinfo-in-args-or-env? fi v)
                     (list v))
                   (mapcan (fn when (and (atom _)
                                         (funinfo-in-args-or-env? fi _))
                                (list _))
                           .v)))))
      (append! (cblock-ins cb) ins))))

(defun cblock-distribute-update (cb visited-blocks v)
  (adjoin! v (cblock-outs (car (last visited-blocks))))
  (dolist (i (butlast visited-blocks))
    (adjoin! v (cblock-ins i))
    (adjoin! v (cblock-outs i)))
  (adjoin! v (cblock-ins cb)))

(defun cblock-distribute-var (cb v)
  (with (global-visited nil
         visit #'((cb visited-blocks)
                    (unless (member cb visited-blocks :test #'eq)
                      (if (and visited-blocks
                               (member v (cblock-ins cb) :test #'eq))
                          (cblock-distribute-update cb visited-blocks v)
                          (unless (member cb global-visited :test #'eq)
                            (push! cb global-visited)
                            (cblock-traverse-next visit cb visited-blocks))))))
    (visit cb nil)))

(defun cblock-distribute-ins-and-outs (cb fi)
  (dolist (v (cblock-ins cb))
    (when (funinfo-in-args-or-env? fi v)
      (cblock-distribute-var cb v)))
  (dolist (statement (cblock-code cb))
    (let v (%setq-place statement)
      (when (funinfo-in-args-or-env? fi v)
        (cblock-distribute-var cb v)))))

(defun cblocks-distribute-ins-and-outs (blks fi)
  (map (fn cblock-distribute-ins-and-outs _ fi) blks))

(defun cblocks-merge-joins (cb)
  (with (global-visited nil
         visit #'((cb visited-blocks)
                      (if (and visited-blocks
                               (member cb visited-blocks :test #'eq))
                          (setf (cblock-merged-ins cb) (intersect (cblock-ins cb)
                                                                  (cblock-outs visited-blocks.)))
                          (unless (member cb global-visited :test #'eq)
                            (push! cb global-visited)
                            (cblock-traverse-next visit cb visited-blocks)))))
    (visit cb nil)))

(defun cblock-rename-value (lst x)
  (or (assoc-value x lst :test #'eq)
      x))

(defun cblock-rename-statement (lst x)
  (if (%quote? (%setq-value x))
      x
      (let v (%setq-value x)
        `(%setq ,(cblock-rename-value lst (%setq-place x))
                ,(if (atom v)
                     (cblock-rename-value lst v)
                     (cons v.
                           (mapcar (fn cblock-rename-value lst _) .v)))))))

(defun cblock-rename-merged (cb)
  (setf (cblock-aliases cb) (mapcar (fn cons _ (gensym)) (cblock-merged-ins cb)))
  (setf (cblock-realnames cb) (pairlist (cdrlist (cblock-aliases cb))
                                        (carlist (cblock-aliases cb))))
  (setf (cblock-code cb) (mapcar (fn cblock-rename-statement (cblock-aliases cb) _) (cblock-code cb))))

(defun cblocks-rename-merged (cb)
  (with (global-visited nil
         visit #'((cb visited-blocks)
                      (if (and visited-blocks
                               (member cb visited-blocks :test #'eq))
                          (cblock-rename-merged cb)
                          (unless (member cb global-visited :test #'eq)
                            (push! cb global-visited)
                            (cblock-traverse-next visit cb visited-blocks)))))
    (visit cb nil)))

(defun cblocks-remove-doubles-1 (blks original x)
  (if x
      (if (equal (%setq-value original)
                 (%setq-value x.))
          (progn
            (setf (third x.) (%setq-place original))
            (print x.)
            (cblocks-remove-doubles-1 blks original .x))
          (cblocks-remove-doubles-1 blks original .x))
      (awhen .blks
        (cblocks-remove-doubles-1 ! original (cblock-code !.)))))

(defun cblocks-remove-doubles-0 (blks x)
  (if x
      (if (and (consp (%setq-value x.))
               (member (car (%setq-value x.)) '(%car %cdr) :test #'eq))
          (cblocks-remove-doubles-1 blks x. .x)
          (cblocks-remove-doubles-0 blks .x))
      (awhen .blks
        (cblocks-remove-doubles-0 ! (cblock-code !.)))))

(defun cblocks-remove-doubles (blks)
  (cblocks-remove-doubles-0 blks (cblock-code blks.)))

(defun cblock-unname-merged (cb)
  (setf (cblock-code cb) (mapcar (fn cblock-rename-statement (cblock-realnames cb) _) (cblock-code cb))))

(defun cblocks-unname-merged (cb)
  (with (global-visited nil
         visit #'((cb visited-blocks)
                      (if (and visited-blocks
                               (member cb visited-blocks :test #'eq))
                          (cblock-unname-merged cb)
                          (unless (member cb global-visited :test #'eq)
                            (push! cb global-visited)
                            (cblock-traverse-next visit cb visited-blocks)))))
    (visit cb nil)))
