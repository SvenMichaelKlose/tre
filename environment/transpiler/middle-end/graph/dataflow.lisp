;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

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
                      (if (and visited-blocks (member v (cblock-ins cb) :test #'eq))
                          (cblock-distribute-update cb visited-blocks v)
                          (unless (member cb global-visited :test #'eq)
                            (push cb global-visited)
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
