;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun print-cblock (cb)
  (format t "Ins: ~A" (cblock-ins cb))
  (dolist (i (cblock-code cb))
    (late-print i))
  (format t "Outs: ~A~%" (cblock-outs cb)))

(defun print-cblocks (blks)
  (format t "--- CBLOCK ---~%")
  (map #'print-cblock blks))
