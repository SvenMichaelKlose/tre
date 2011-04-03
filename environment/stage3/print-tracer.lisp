;;;;; TRE environment
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defstruct print-info
  (visited (make-hash-table :test #'eq))
  (first-occurences (make-hash-table :test #'eq)))

(defun %print-trace-update (x info)
  (prog1
    (when (href (print-info-visited info) x)
      (setf (href (print-info-first-occurences info) x) t))
    (setf (href (print-info-visited info) x) t)))

(defun %print-trace-cons (x info)
  (unless (%print-trace-update x info)
    (%print-trace x. info)
    (%print-trace .x info)))

(defun %print-trace-array (x info)
  (dotimes (i (length x))
    (%print-trace (aref x i) info)))

(defun %print-trace-atom (x info)
  (when (array? x)
    (unless (%print-trace-update x info)
      (%print-trace-array x info))))

(defun %print-trace (x info)
  (? (cons? x)
     (%print-trace-cons x info)
     (%print-trace-atom x info)))

(defun print-trace (x)
  (let info (make-print-info)
    (%print-trace x info)
    (setf (print-info-visited info) (make-hash-table :test #'eq))
    info))
