;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; EVAL is only here because the transpiler macros
;;;;; need it and therefore we cannot just compile expressions.

(defvar *eval-special-form-handlers* (make-hash-table :test #'eq))

(defmacro defeval (name arg &rest body)
  (when *show-definitions*
    (late-print `(defeval ,name)))
  `(setf (href *eval-special-form-handlers* (quote ,name)) #'((,arg)
                                                               ,@body)))

(defun js-eval-string (x)
  (transpiler-symbol-string *js-transpiler* x))

(defun js-eval-user-function? (x)
  (native-eval (+ "typeof " (js-eval-string (compiled-user-function-name x)) " === \"function\"")))

(defun js-eval-fname-string (x)
  (transpiler-symbol-string *js-transpiler*
                            (? (js-eval-user-function? x)
                               (compiled-user-function-name x)
                               (compiled-function-name *js-transpiler* x))))

(defun %eval-function-expression (x)
  (let fun (native-eval (concat-stringtree "function " (pad (mapcar #'js-eval-string (argument-expand-names 'js-eval-args x.))
                                                             ", ")
                                           "{"
                                                (native-eval (js-eval-fname-string 'eval))
                                                    "(this.source);"
                                           "}"))
    (setf fun.source .x)
    (setf fun.tre-exp #'((&rest args)
                           (apply fun (argument-expand-values 'js-eval-values x. .x))))
    fun))

(defeval function x
  (? (atom x)
     (native-eval (js-eval-fname-string x))
     (%eval-function-expression x)))

(defeval if x
  (with (rec #'((x)
                 (when x
                   (? .x
                      (? (eval x.)
                         (eval .x.)
                         (rec ..x))
                      (eval x.)))))
    (rec x)))

(defun %%%return? (x)
  (and (cons? r)
       (eq '%%%return r.)))

(defun %eval-statements (x)
  (let r nil
    (dolist (i x)
      (setf r (eval i))
      (when (%%%return? r)
        (return r)))))

(defeval progn x
  (%eval-statements .x))

(defeval return-from x
  (list '%%%return 'block x.))

(defeval block statements
  (with (name statements.
         r (%eval-statements x))
      (? (and (%%%return? r.)
              (eq 'block .r.)
              (eq name ..r.))
         nil
         r)))

(defeval go x
  (list '%%%return 'go x.))

(defeval tagbody statements
  (with (rec #'((x)
                 (let r (%eval-statements x)
                   (? (and (%%%return? r)
                           (eq 'go .r.))
                      (rec (cdr (member ..r. statements)))
                      r))))
    (rec statements)))

(defun js-eval-native-symbol (x)
  (+ (js-eval-fname-string 'make-symbol) " (\"" (symbol-name x) "\", null)"))

(defeval quote x
  (native-eval (js-eval-native-symbol x.)))

(defun %eval-expression (x)
  x)

(defun %eval-cons (x)
  (aif (href *eval-special-form-handlers* x.)
       (funcall ! .x)
       (%eval-expression x)))

(defun %eval-symbol (x)
  (native-eval (+ (js-eval-native-symbol x) "." (js-eval-string 'v))))

(defun %eval-atom (x)
  (late-print x)
  (let r (?
           (not x) "null"
           (symbol? x) (%eval-symbol x)
           x)
    (native-eval (? (symbol? r)
                    (js-eval-native-symbol r)
                    r))))

(defun eval (x)
  (format t "Eval ~A" x)
  (let r (? (atom x)
            (%eval-atom x)
            (%eval-cons x))
    (format t "Eval result ~A" r)
    r))
