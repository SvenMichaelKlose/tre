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

(defun cps-function-assignment? (x)
  (and (%setq? x)
       (let v (%setq-value x)
         (and (lambda? v)
              (funinfo-needs-cps? (get-lambda-funinfo v))))))

(defun cps-funcall? (x)
  (and (%setq-funcall? x)
       (let n (car (%setq-value x))
         (or (transpiler-cps-function? *current-transpiler* n)
             (and (transpiler-defined-function *current-transpiler* n)
                  (not (transpiler-cps-exception? *current-transpiler* n))
                  (not (expander-has-macro? (transpiler-macro-expander *current-transpiler*)
                                            (compiled-function-name n))))))))

(defun cps-apply? (x)
  (and (%setq-funcall? x)
       (eq 'apply (car (%setq-value x)))))

(defun cps-methodcall? (x)
  (and (%setq? x)
       (consp (%setq-value x))
       (%slot-value? (car (%setq-value x)))))

(defun cps-split-funcall-0 (fi x xlats args)
  `((%setq nil (,(car (%setq-value x.))
                ,@args))))

(defun cps-split-make-continuer (fi x xlats)
  (aif (%setq-place x.)
       (copy-lambda
           `#'((_)
                (%setq ,(%setq-place x.) _)
                ,(if .x
                     `(%setq nil (,(cps-cons-function-name .x xlats)))
                     `(%setq nil (~%continuer ~%ret))))
           :args '(_)
           :info (make-funinfo :args '(_)
           :parent fi))
       (cps-cons-function-name .x xlats)))

(defun cps-split-funcall (fi x xlats)
  (cps-split-funcall-0 fi x xlats
      `(,(cps-split-make-continuer fi x xlats)
        ,@(cdr (%setq-value x.)))))

(defun cps-split-apply (fi x xlats)
  (with-gensym g
    (funinfo-env-add fi g)
    `((%setq ,g (cons ,(cps-split-make-continuer fi x xlats)
                      ,@(cdr (%setq-value x.))))
      ,@(cps-split-funcall-0 fi x xlats (list g)))))

(defun cps-split-methodcall (fi x xlats)
  (with (method (car (%setq-value x.))
         tag-no-cps (gensym-number)
         tag-end (gensym-number))
    (with-gensym g
      `((vm-go-nil (%slot-value ,method tre-cps) ,tag-no-cps)
        ,@(cps-split-funcall fi x xlats)
        (vm-go ,tag-end)
        ,tag-no-cps
        ,x.
        (%setq nil (,(cps-cons-function-name .x xlats)))
        ,tag-end))))

(defun cps-split (fi x xlats tag-xlats &key (first? t))
  (if
    (cps-apply? x.)
      (cps-split-apply fi x xlats)
    (cps-methodcall? x.)
      (cps-split-methodcall fi x xlats)
    (cps-funcall? x.)
      (cps-split-funcall fi x xlats)
    (vm-go? x.)
      `((%setq nil (,(cps-tag-function-name (second x.) xlats tag-xlats))))
    (vm-go-nil? x.)
      `((vm-call-nil ,(second x.)
                     ,(cps-tag-function-name (third x.) xlats tag-xlats)
                     ,(cps-cons-function-name .x xlats)))))

(defun cps-splitpoint-expr? (x)
  (or (cps-apply? x)
      (cps-funcall? x)
      (cps-methodcall? x)
      (vm-go? x)
      (vm-go-nil? x)))

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
    (cps-splitpoint-expr? x.)
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
      (cps-splitpoint-expr? x.)
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

(defun cps-function-assignment (x)
  `((%setq ,(%setq-place x)
           ,(cps-function (%setq-value x)))
    (%setq (%slot-value ,(%setq-place x) tre-cps) t)))

(define-concat-tree-filter cps-filter (x)
  (or (%quote? x)
      (%transpiler-native? x)
      (%var? x))
    (list x)
  (cps-function-assignment? x)
    (cps-function-assignment x))

(define-concat-tree-filter cps-toplevel (x)
  (or (%quote? x)
      (%transpiler-native? x)
      (%var? x))
    (list x)
  (cps-funcall? x)
    `((%setq nil (,(car (%setq-value x))
                  ,(copy-lambda `#'((_)
                                     (%setq ,(%setq-place x) _))
                                :args '(_)
                                :info (make-funinfo :args '(_)
                                                    :parent *global-funinfo*))
                  ,@(cdr (%setq-value x)))))
  (cps-function-assignment? x)
    (cps-function-assignment x))

(defun cps (x)
  (cps-toplevel x))
