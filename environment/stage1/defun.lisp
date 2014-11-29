;;;; tré – Copyright (c) 2005–2008,2010–2014 Sven Michael Klose <pixel@hugbox.org>

(defvar *function-sources* nil)

(early-defun %defun-arg-keyword (args)
  (let a (car args)
	(let d (& (cdr args)
			  (cadr args))
      (? (%arg-keyword? a)
         (? d
            (? (%arg-keyword? d)
               (error "Keyword ~A follows keyword ~A." d a))
            (error "Unexpected end of argument list after keyword ~A." a))))))

(early-defun %defun-checked-args (args)
  (& args
     (| (%defun-arg-keyword args)
        (cons (car args) (%defun-checked-args (cdr args))))))

(early-defun %defun-name (name)
  (? (symbol? name)
     name
     (? (& (cons? name)
           (eq (car name) '=))
        (make-symbol (string-concat "=-" (string (cadr name))))
;                     (symbol-package (cadr name)))
        (error "Illegal function name ~A. It must be a symbol or of the form (= symbol)." name))))

(defmacro defun (name args &body body)
  (let name (%defun-name name)
    `(block nil
	   (print-definition `(defun ,name ,args))
       (setq *universe* (cons ',name *universe*))
       (%set-atom-fun ,name
           #'(,(%defun-checked-args args)
               (block ,name
                 (block nil
                   ,@(%add-documentation name body)))))
	   (return-from nil ',name))))
