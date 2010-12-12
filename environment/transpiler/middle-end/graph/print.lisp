;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun print-cblock (cb)
  (format t "Ins: ~A" (cblock-ins cb))
  (format t "Merged ins: ~A" (cblock-merged-ins cb))
  (when (cblock-next cb)
    (format t "Unconditional next.~%"))
  (when (cblock-conditional-next cb)
    (format t "Conditional next.~%"))
  (dolist (i (cblock-code cb))
    (late-print i))
  (format t "Outs: ~A~%" (cblock-outs cb))
  cb)

(defun print-cblocks (blks)
  (format t "--- CBLOCK ---~%")
  (map #'print-cblock blks)
  blks)
