;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun cblocks-merge-joins (cb)
  (with (global-visited nil
         visit #'((cb visited-blocks)
                      (? (& visited-blocks
                            (member cb visited-blocks :test #'eq))
                         (map (fn adjoin! _ (cblock-merged-ins cb))
                              (intersect (cblock-ins cb)
                                         (cblock-outs visited-blocks.)))
                         (unless (member cb global-visited :test #'eq)
                           (push cb global-visited)
                           (cblock-traverse-next visit cb visited-blocks)))))
    (visit cb nil)))

(defun cblock-rename-value (lst x)
  (| (assoc-value x lst :test #'eq)
     x))

(defun cblock-rename-statement (lst x)
  (? (%quote? (%setq-value x))
     x
     (let v (%setq-value x)
       `(%setq ,(cblock-rename-value lst (%setq-place x))
               ,(? (atom v)
                   (cblock-rename-value lst v)
                   (cons v. (filter (fn cblock-rename-value lst _) .v)))))))

(defun cblock-rename-merged (cb)
  (= (cblock-aliases cb) (filter (fn cons _ (gensym)) (cblock-merged-ins cb)))
  (= (cblock-realnames cb) (pairlist (cdrlist (cblock-aliases cb))
                                     (carlist (cblock-aliases cb))))
  (= (cblock-code cb) (filter (fn cblock-rename-statement (cblock-aliases cb) _) (cblock-code cb))))

(defun cblocks-rename-merged (cb)
  (with (global-visited nil
         visit #'((cb visited-blocks)
                      (? (& visited-blocks (member cb visited-blocks :test #'eq))
                         (cblock-rename-merged cb)
                         (unless (member cb global-visited :test #'eq)
                           (push cb global-visited)
                           (cblock-traverse-next visit cb visited-blocks)))))
    (visit cb nil)))

(defun cblock-unname-merged (cb)
  (= (cblock-code cb) (filter (fn cblock-rename-statement (cblock-realnames cb) _) (cblock-code cb))))

(defun cblocks-unname-merged (cb)
  (with (global-visited nil
         visit #'((cb visited-blocks)
                      (? (& visited-blocks (member cb visited-blocks :test #'eq))
                         (cblock-unname-merged cb)
                         (unless (member cb global-visited :test #'eq)
                           (push cb global-visited)
                           (cblock-traverse-next visit cb visited-blocks)))))
    (visit cb nil)))
