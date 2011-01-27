;;;;; TRE transpiler
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun reassignment? (fi x)
  (and (%setq? x)
       (funinfo-in-args-or-env? fi (%setq-place x))))

(defun copy-until-cblock-end (cb fi x)
  (let result (make-queue)
    (while (and x
                (not (vm-jump? x.))
                (not (number? .x.))
                (not (reassignment? fi x.)))
           (progn
             (when (reassignment? fi x.)
               (adjoin! (%setq-place x.) (cblock-merged-ins cb)))
             (values (append (queue-list result)
                             (when x
                               (list x.)))
                     .x))
      (enqueue result (copy-tree x.))
      (setf x .x))))

(defun metacode-to-cblocks-0 (fi x)
  (when x
    (let cb (make-cblock)
      (with ((copy next) (copy-until-cblock-end cb fi x))
        (setf (cblock-code cb) copy)
        (cons cb (metacode-to-cblocks-0 fi next))))))

(defun metacode-to-cblocks (x fi)
  (append (list (make-cblock :ins (funinfo-args fi)))
          (metacode-to-cblocks-0 fi x)
          (list (make-cblock :ins (list '~%ret)))))

(defun make-cblock-taglist (x)
  (let tags nil
    (dolist (i x tags)
      (let f (car (cblock-code i))
        (when (number? f)
          (acons! f i tags)
          (setf (cblock-code i) (cdr (cblock-code i))))))))

(defun make-cblock-links (x tags)
  (when x
    (with (cb x.
           l (car (last (cblock-code cb))))
      (?
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
