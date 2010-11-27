;;;;; TRE compiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun in-cps-mode? ()
  (and (transpiler-continuation-passing-style? *current-transpiler*)                                              
       (not *transpiler-except-cps?*)))

(defun cps-tag-function-name (x xlats tag-xlats)
  (assoc-value (assoc-value x tag-xlats)
               xlats))

(defun cps-cons-function-name (x xlats)
  (or (assoc-value x xlats)
      (progn
        (print x)
        (error "no CPS function name"))))

(defun cps-make-call-to-next (x xlats)
  (if .x
      `(%setq nil (,(cps-cons-function-name .x xlats)))
      `(%setq nil (~%continuer ~%ret))))

(defun cps-function-assignment? (x)
  (and (%setq? x)
       (let v (%setq-value x)
         (and (lambda? v)
              (funinfo-needs-cps? (get-lambda-funinfo v))))))

(defun cps-funcall? (x)
  (and (%setq-funcall? x)
       (with (n (car (%setq-value x)))
              ;n (if (%transpiler-native? v.)
                 ;   (cadr v.)
                  ;  v.))
         (and (not (expander-has-macro? (transpiler-macro-expander *current-transpiler*)
                                                                   (compiled-function-name n)))
              (or (transpiler-cps-function? *current-transpiler* n)
                  (and (transpiler-defined-function *current-transpiler* n)
                       (not (transpiler-cps-exception? *current-transpiler* n))))))))

(defun cps-constructorcall? (x)
  (and (%setq-funcall? x)
       (eq '%new (car (%setq-value x)))
       (let n (cadr (%setq-value x))
         (or (transpiler-cps-function? *current-transpiler* n)
             (and (transpiler-defined-function *current-transpiler* n)
                  (not (transpiler-cps-exception? *current-transpiler* n)))))))

(defun cps-apply? (x)
  (and (%setq-funcall? x)
       (eq 'apply (car (%setq-value x)))))

(defun cps-methodcall? (x)
  (and (%setq? x)
       (consp (%setq-value x))
       (%slot-value? (car (%setq-value x)))))

;(defun cps-foureign-funcall? (x)
;  (and (%setq-funcall? x)
;       (let n (car (%setq-value x))
;         (and (not (%transpiler-native? n))
;              (or (and (atom n)
;                       (not (transpiler-defined-function *current-transpiler* n))
;                       (not (transpiler-cps-function? *current-transpiler* n))
;                       (not (expander-has-macro? (transpiler-macro-expander *current-transpiler*)
;                                                 (compiled-function-name n))))
;                  (and (%slot-value? n)
;                       (eq 'window .n.)
;                       (print n)))))))

(defun cps-foureign-funcall? (x)
  (and (%setq-funcall? x)
       (eq 'cps-wrap (car (%setq-value x)))))

;(defun cps-foureign-funcall (fi x)
;  (with (replacements nil
;         some-replaced? nil
;         new-args (mapcar (fn (if (transpiler-cps-function? *current-transpiler* _)
;                                  (with-gensym (g arg v1 v2)
;                                    (setq some-replaced? t)
;                                    (funinfo-env-add fi g)
;                                    (funinfo-env-add fi v1)
;                                    (funinfo-env-add fi v2)
;                                    (append! replacements
;                                             `((%setq ,g
;                                                      ,(copy-lambda
;                                                          `#'((&rest ,arg)
;                                                               (%setq ,v2 (cons ,_
;                                                                               ,arg))
;                                                               (%setq ,v1 (cons #'cps-return-dummy
;                                                                               ,v2))
;                                                               (%setq nil (apply ,v1)))
;                                                          :info (make-funinfo
;                                                                    :env (list v1)
;                                                                    :parent fi
;                                                                    :args (list arg))))))
;                                    g)
;                                  _))
;                          (cdr (%setq-value x))))
;    (let r `(,@replacements
;             (%setq ,(%setq-place x) (,(car (%setq-value x)) ,@new-args)))
;      (when some-replaced?
;        (print r))
;      r)))

(defun cps-foureign-funcall (fi x)
  (with-gensym (arg v1 v2)
    `((%setq ,(%setq-place x)
             ,(copy-lambda
                  `#'((&rest ,arg)
                      (%setq ,v2 (cons ,(cadr (%setq-value x)) ,arg))
                      (%setq ,v1 (cons #'cps-return-dummy ,v2))
                      (%setq nil (apply ,v1)))
                  :info (make-funinfo
                            :env (list v1)
                            :parent fi
                            :args (list arg)))))))

(defun cps-split-make-continuer (fi x xlats)
  (aif (%setq-place x.)
       (copy-lambda
           `#'((_)
                (%setq ,(%setq-place x.) _)
                ,(cps-make-call-to-next x xlats))
           :args '(_)
           :info (make-funinfo :args '(_)
           :parent fi))
       (cps-cons-function-name .x xlats)))

(defun cps-split-funcall-0 (fi x xlats args)
  `((%setq nil (,(car (%setq-value x.))
                ,@args))))

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
         tag-no-cps (make-compiler-tag)
         tag-end (make-compiler-tag))
    (with-gensym g
      `((vm-go-nil (%slot-value ,method tre-cps) ,tag-no-cps)
        ,@(cps-split-funcall fi x xlats)
        (vm-go ,tag-end)
        ,tag-no-cps
        ,x.
        ,(cps-make-call-to-next x xlats)
        ,tag-end))))

(defun cps-split-constructorcall-0 (fi x continuer-expr)
  `((%setq nil (%new ,(cadr (%setq-value x.))
                    ,continuer-expr
                    ,@(cddr (%setq-value x.))))))

(defun cps-split-constructorcall (fi x xlats)
  (cps-split-constructorcall-0 fi x (cps-split-make-continuer fi x xlats)))

(defun cps-split (fi x xlats tag-xlats &key (first? t))
  (if
    (cps-apply? x.)
      (cps-split-apply fi x xlats)
    (cps-methodcall? x.)
      (cps-split-methodcall fi x xlats)
    (cps-constructorcall? x.)
      (cps-split-constructorcall fi x xlats)
    (cps-funcall? x.)
      (cps-split-funcall fi x xlats)
    (cps-foureign-funcall? x.)
      (cps-foureign-funcall fi x.)
    (vm-go? x.)
      `((%setq nil (,(cps-tag-function-name (second x.) xlats tag-xlats))))
    (vm-go-nil? x.)
      `((vm-call-nil ,(second x.)
                     ,(cps-tag-function-name (third x.) xlats tag-xlats)
                     ,(cps-cons-function-name .x xlats)))))

(defun cps-splitpoint-expr? (x)
  (or (cps-apply? x)
      (cps-funcall? x)
      (cps-foureign-funcall? x)
      (cps-methodcall? x)
      (cps-constructorcall? x)
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

(defun cps-make-functions (fi continuer x xlats tag-xlats)
  (when x
    (with (chunk (cps-body fi continuer x xlats tag-xlats)
           body (butlast chunk)
           next (caar (last chunk)))
      `((%setq ,(assoc-value x xlats)
               ,(copy-lambda `#'(()
                                  ,@body)
                             :info (make-funinfo :parent fi
                                                 :args nil)))
        ,@(cps-make-functions fi continuer next xlats tag-xlats)))))

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
                        (lambda-args x))
         fi (get-lambda-funinfo x))
    (setf (funinfo-args fi) new-args)
    (copy-lambda x
        :args new-args
        :body (with (body (cps-filter (lambda-body x))
                     xlats (cps-get-xlats body)
                     tag-xlats (cps-get-tag-xlats body))
                (funinfo-env-add fi '~%cps-this)
                `(,@(mapcar (fn `(%var ,_)) (cdrlist xlats))
                  (%setq ~%cps-this this)
                  ,@(cps-make-functions (get-lambda-funinfo x) continuer body xlats tag-xlats)
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
  (eq 'this x)
    (list '~%cps-this)
  (cps-function-assignment? x)
    (cps-function-assignment x))

(defun cps-make-dummy-continuer (place parent-fi)
  (copy-lambda `#'((_)
                    (%setq ,place _))
               :args '(_)
               :info (make-funinfo :args '(_)
                                   :parent parent-fi)))

(defun cps-toplevel-constructorcall (x)
  (with (constructor (cadr (%setq-value x))
         tag-no-cps (make-compiler-tag)
         tag-end (make-compiler-tag))
    (with-gensym g
      `((vm-go-nil (%slot-value ,constructor tre-cps) ,tag-no-cps)
        ,@(cps-split-constructorcall-0 *global-funinfo* (list x)
              (cps-make-dummy-continuer (%setq-place x) *global-funinfo*))
        (vm-go ,tag-end)
        ,tag-no-cps
        ,x
        ,tag-end))))

(defun cps-toplevel-funcall (x)
  `((%setq nil (,(car (%setq-value x))
                ,(cps-make-dummy-continuer (%setq-place x) *global-funinfo*)
                ,@(cdr (%setq-value x))))))

(defun cps-toplevel-methodcall (x)
  (with (method (car (%setq-value x))
         tag-no-cps (make-compiler-tag)
         tag-end (make-compiler-tag))
    (with-gensym g
      `((vm-go-nil (%slot-value ,method tre-cps) ,tag-no-cps)
        ,@(cps-toplevel-funcall x)
        (vm-go ,tag-end)
        ,tag-no-cps
        ,x
        ,tag-end))))

(define-concat-tree-filter cps-toplevel (x)
  (or (%quote? x)
      (%transpiler-native? x)
      (%var? x))
    (list x)
  (cps-methodcall? x)
    (cps-toplevel-methodcall x)
  (cps-constructorcall? x)
    (cps-toplevel-constructorcall x)
  (cps-funcall? x)
    (cps-toplevel-funcall x)
  (cps-function-assignment? x)
    (cps-function-assignment x)
  (cps-foureign-funcall? x)
    (cps-foureign-funcall *global-funinfo* x))

(defun cps (x)
  (cps-toplevel x))
