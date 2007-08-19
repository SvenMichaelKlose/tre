;;;; nix operating system project
;;;; lisp compiler
;;;; (c) 2005 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous utilities.

(defun enqueue-many (q l)
  (dolist (e l)
    (enqueue q e)))

(defmacro with-cons (a d c &rest body)
  `(let ((,a (car ,c))
         (,d (cdr ,c)))
     ,@body))

(defun print-symbols (forms)
  (dolist (i forms)
    (verbose " ~A" (symbol-name i))))

(defun group (l size)
  (when l
    (cons (subseq l 0 size) (group (subseq l size) size))))

(defun split-if (fun l &key (test-cons nil))
  (labels ((fcall (x)
             (funcall fun (if test-cons x (car x))))
           (rec (i)
             (with (d (cdr i))
               (if d
                   (if (fcall d)
                       (progn
                         (rplacd i nil)
                         (values l d))
                       (rec d))
                   (values l nil)))))
    (if (fcall l)
        (values nil l)
        (rec l))))

(defmacro mvb (v a &rest body)
  `(multiple-value-bind ,v ,a
     ,@body))

(defun remove-if (fun x)
  (when x
    (if (not (funcall fun (car x)))
      (cons (car x) (remove-if fun (cdr x)))
      (remove-if fun (cdr x)))))

(defmacro t? (x)
  `(eq t ,x))
