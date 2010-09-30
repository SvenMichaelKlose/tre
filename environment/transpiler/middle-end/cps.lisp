;;;;; TRE compiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun cps-tag-function-name (x xlats tag-xlats)
  (assoc-value (assoc-value x tag-xlats)
               xlats))

(defun cps-cons-function-name (x xlats)
  (or (assoc-value x xlats)
      (progn
        (print x)
        (error "no CPS function name"))))

(defun cps-funcall? (x)
  (and (%setq-funcall? x)
       (transpiler-defined-function *current-transpiler* (car (%setq-value x)))
       (not (transpiler-cps-exception? *current-transpiler* (car (%setq-value x))))
       (not (expander-has-macro? (transpiler-macro-expander *current-transpiler*)
                                 (compiled-function-name (car (%setq-value x)))))))

(defun cps-split (fi x xlats tag-xlats &key (first? t))
  (if
    (cps-funcall? x.)
      `((%setq nil (,(car (%setq-value x.))
                    ,(aif (%setq-place x.)
                          (copy-lambda
                              `#'((_)
                                   (%setq ,(%setq-place x.) _)
                                   (%setq nil (,(cps-cons-function-name .x xlats))))
                              :args '(_)
                              :info (make-funinfo :args '(_)
                                                  :parent fi))
                          (cps-cons-function-name .x xlats))
                    ,@(cdr (%setq-value x.)))))
    (vm-go? x.)
      `((%setq nil (,(cps-tag-function-name (second x.) xlats tag-xlats))))
    (vm-go-nil? x.)
      `((vm-call-nil ,(second x.)
                     ,(cps-tag-function-name (third x.) xlats tag-xlats)
                     ,(cps-cons-function-name .x xlats)))))

(defun cps-body (fi continuer x xlats tag-xlats &key (first? t))
  (if
    (not x)
      (cons nil nil)
    (numberp x.)
      (if first?
          (if .x
              (cps-body fi continuer .x xlats tag-xlats :first? nil)
              `((%setq nil (,continuer ~%ret))
                nil))
          (append `((%setq nil (,(cps-cons-function-name x xlats))))
                  (list (list x))))
    (or (cps-funcall? x.)
        (vm-go? x.)
        (vm-go-nil? x.))
      (append (cps-split fi x xlats tag-xlats :first? first?)
              (list (list .x)))
    (not .x)
       `(,x.
         (%setq nil (,continuer ~%ret))
         nil)
    (cons x.
          (cps-body fi continuer .x xlats tag-xlats :first? nil))))

(defun cps-functions (fi continuer x xlats tag-xlats)
  (when x
    (with (chunk (cps-body fi continuer x xlats tag-xlats)
           body (butlast chunk)
           next (caar (last chunk)))
      `((%setq ,(assoc-value x xlats)
               ,(copy-lambda `#'(()
                                  ,@body)
                             :info (make-funinfo :parent fi
                                                 :args nil)))
        ,@(cps-functions fi continuer next xlats tag-xlats)))))

(defun cps-get-xlats (x &key (first? t))
  (when x
    (if
      (numberp x.)
        (cons (cons x (gensym))
              (cps-get-xlats .x :first? nil))
      (or (cps-funcall? x.)
          (vm-go? x.)
          (vm-go-nil? x.))
        (if first?
            (cons (cons x (gensym))
                  (cons (cons .x (gensym))
                        (cps-get-xlats .x :first? nil)))
            (cons (cons .x (gensym))
                  (cps-get-xlats .x :first? nil)))
      first?
        (cons (cons x (gensym))
              (cps-get-xlats .x :first? nil))
      (cps-get-xlats .x :first? nil))))

(defun cps-get-tag-xlats (x)
  (when x
    (if (numberp x.)
        (cons (cons x. x)
              (cps-get-tag-xlats .x))
        (cps-get-tag-xlats .x))))

(defun cps-function (x)
  (with (continuer '~%continuer
         new-args (cons continuer
                        (lambda-args x)))
    (setf (funinfo-args (get-lambda-funinfo x)) new-args)
    (copy-lambda x
        :args new-args
        :body (with (body (cps-filter (lambda-body x))
                     xlats (cps-get-xlats body)
                     tag-xlats (cps-get-tag-xlats body))
                `(,@(mapcar (fn `(%var ,_)) (cdrlist xlats))
                  ,@(cps-functions (get-lambda-funinfo x) continuer body xlats tag-xlats)
                  (%setq nil (,(cdar xlats))))))))

(define-tree-filter cps-filter (x)
  (or (%quote? x)
      (%transpiler-native? x)
      (%var? x))
    x
  (and (or (named-lambda? x)
           (lambda? x))
       (funinfo-needs-cps? (get-lambda-funinfo x)))
    (cps-function x))

(define-tree-filter cps-toplevel (x)
  (or (%quote? x)
      (%transpiler-native? x)
      (%var? x))
    x
  (cps-funcall? x)
    `(%setq nil (,(car (%setq-value x))
                 ,(copy-lambda `#'((_)
                                    (%setq ,(%setq-place x) _))
                               :args '(_)
                               :info (make-funinfo :args '(_)
                                                   :parent *global-funinfo*))
                 ,@(cdr (%setq-value x))))
  (and (or (named-lambda? x)
           (lambda? x))
       (funinfo-needs-cps? (get-lambda-funinfo x)))
    (cps-function x))

(defun cps (x)
  (cps-toplevel x))
