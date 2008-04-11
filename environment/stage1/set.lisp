;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; SETF macro

;; Assign evaluated value of argument y to variable x.
(defmacro set (x y)
  `(setq ,(eval x) ,y))

(defun %setf-make-symbol (fun)
  (make-symbol (string-concat "%%USETF-" (symbol-name fun))))

(defun %setf-complement (p val)
  (if (atom p)
    (list 'setq p val)
    (let* ((fun (car p))
	   (args (cdr p))
	   (setfun (%setf-make-symbol fun))
	   (funat (eval `(function ,setfun))))
      (if (functionp funat)
	(let ((g (gensym)))
          `(progn
	     (let ((,g ,val))
	       (,setfun ,g ,@args)
	     ,g)))
        (progn
          (print p)
	  (%error "place not settable"))))))

(defun %setf (args)
  (if (not (cdr args))
    (%error "pairs expected"))
    (cons
      (%setf-complement (car args) (cadr args))
      (if (cddr args)
        (%setf (cddr args)))))

(defmacro setf (&rest args)
  (if (not args)
    (%error "arguments expected")
    (if (= 1 (length args))
      `(%%defunsetf ,(car args)) ; Keep for DEFUN argument name.
      `(progn ,@(%setf args)))))

(defun (setf symbol-function) (fun sym)
  (%set-atom-fun sym fun))
