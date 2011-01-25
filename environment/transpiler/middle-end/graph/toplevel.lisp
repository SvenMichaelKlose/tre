;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun middleend-graph-0 (x)
  (with (fi (get-lambda-funinfo x)
         blks (metacode-to-cblocks (lambda-body x) fi))
    (make-cblock-links blks (make-cblock-taglist blks))
    (cblock-collect-ins blks fi)
    (cblocks-distribute-ins-and-outs blks fi)
    (cblocks-merge-joins blks.)
    (cblocks-rename-merged blks.)
;    (cblocks-remove-doubles fi blks)
    (cblocks-unname-merged blks.)
    ;(print-cblocks blks)
    (cblock-to-metacode blks)))

(define-tree-filter middleend-graph (x)
  (named-lambda? x)
	(copy-lambda x :body (middleend-graph-0 x))
  (lambda? x)
	(copy-lambda x :body (middleend-graph-0 x)))
