;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun cblocks-remove-doubles-1 (blks original x)
  (? x
     (? (equal (%setq-value original)
               (%setq-value x.))
        (progn
          (= (caddr x.) (%setq-place original))
          (print x.)
          (cblocks-remove-doubles-1 blks original .x))
        (cblocks-remove-doubles-1 blks original .x))
     (awhen .blks
       (cblocks-remove-doubles-1 ! original (cblock-code !.)))))

(defun cblocks-remove-doubles-0 (fi blks x)
  (? x
     (? (and (cons? (%setq-value x.))
             (member (car (%setq-value x.)) '(%car %cdr) :test #'eq)
             (every (fn funinfo-in-args-or-env? fi _) (cdr (%setq-value x.))))
        (cblocks-remove-doubles-1 blks x. .x)
        (cblocks-remove-doubles-0 fi blks .x))
     (awhen .blks
       (cblocks-remove-doubles-0 fi ! (cblock-code !.)))))

(defun cblocks-remove-doubles (fi blks)
  (cblocks-remove-doubles-0 fi blks (cblock-code blks.)))
