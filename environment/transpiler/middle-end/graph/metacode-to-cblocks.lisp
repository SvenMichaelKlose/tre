;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun reassignment? (fi x)
  (& (%setq? x)
     (funinfo-in-args-or-env? fi (%setq-place x))))

(defun metacode-splitpoint? (fi x)
  (| (vm-jump? x.)
     (number? .x.)
     (reassignment? fi x.)))

(defun copy-until-cblock-end (cb fi x)
  (let result (make-queue)
    (while (& x (not (metacode-splitpoint? fi x)))
           (progn
             (& (reassignment? fi x.)
                (adjoin! (%setq-place x.) (cblock-merged-ins cb)))
             (values (append (queue-list result)
                             (& x (list x.)))
                     .x))
      (enqueue result (copy-tree x.))
      (= x .x))))

(defun metacode-to-cblocks-0 (fi x)
  (& x
     (let cb (make-cblock)
       (with ((copy next) (copy-until-cblock-end cb fi x))
         (= (cblock-code cb) copy)
         (cons cb (metacode-to-cblocks-0 fi next))))))

(defun metacode-to-cblocks (x fi)
  (append (list (make-cblock :ins (funinfo-args fi)))
          (metacode-to-cblocks-0 fi x)
          (list (make-cblock :ins (list '~%ret)))))
