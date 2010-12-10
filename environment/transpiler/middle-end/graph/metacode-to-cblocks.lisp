;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

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
                (cblock-conditional-place cb) .l.)
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
  (with (visit #'((cb visited-blocks)
                    (unless (member cb visited-blocks :test #'eq)
                      (if (and visited-blocks
                               (member v (cblock-ins cb) :test #'eq))
                          (cblock-distribute-update cb visited-blocks v)
                          (let visited-and-this (cons cb visited-blocks)
                            (awhen (cblock-conditional-next cb)
                              (visit ! visited-and-this))
                            (awhen (cblock-next cb)
                              (visit ! visited-and-this)))))))
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
