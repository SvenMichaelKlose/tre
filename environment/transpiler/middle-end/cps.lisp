;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun cps-tag-function-name (x xlats tag-xlats)
  (assoc-value (assoc-value x tag-xlats)
               xlats))

(defun cps-cons-function-name (x xlats)
  (| (assoc-value x xlats)
     (progn
       (print x)
       (error "no CPS function name"))))

(defun cps-make-call-to-next (x xlats)
  `(%setq nil ,(? .x
                  `(,(cps-cons-function-name .x xlats))
                  '(~%continuer ~%ret))))

(defun cps-function? (n)
  (let tr *transpiler*
    (| (transpiler-cps-function? tr n)
       (& (transpiler-defined-function tr n)
          (not (transpiler-cps-exception? tr n))))))

(defun cps-funcall? (x)
  (& (%setq-funcall? x)
     (let n (car (%setq-value x))
       (& (not (expander-has-macro? (transpiler-codegen-expander tr) (compiled-function-name tr n)))
          (cps-function? n)))))

(defun cps-constructorcall? (x)
  (& (%setq-funcall? x)
     (eq '%new (car (%setq-value x)))
     (cps-function? (cadr (%setq-value x)))))

(defun cps-apply? (x)
  (& (%setq-funcall? x)
     (eq 'apply (car (%setq-value x)))))

(defun cps-methodcall? (x)
  (& (%setq? x)
     (cons? (%setq-value x))
     (%slot-value? (car (%setq-value x)))))

(defun cps-foureign-funcall? (x)
  (%setq-funcall? x))
       ;(eq 'cps-wrap (car (%setq-value x)))))

;(defun cps-foureign-funcall? (x)
;  (& (%setq-funcall? x)
;       (let n (car (%setq-value x))
;         (& (not (%%native? n))
;              (| (& (atom n)
;                       (not (transpiler-defined-function *transpiler* n)
;                            (transpiler-cps-function? *transpiler* n)
;                            (expander-has-macro? (transpiler-codegen-expander *transpiler*)
;                                                 (compiled-function-name *transpiler* n))))
;                  (& (%slot-value? n)
;                       (eq 'window .n.)
;                       (print n)))))))

;(defun cps-foureign-funcall (fi x)
;  (with (replacements nil
;         some-replaced? nil
;         new-args (mapcar [? (transpiler-cps-function? *transpiler* _)
;                             (with-gensym (g arg v1 v2)
;                               (setq some-replaced? t)
;                               (funinfo-var-add fi g)
;                               (funinfo-var-add fi v1)
;                               (funinfo-var-add fi v2)
;                               (append! replacements
;                                        `((%setq ,g ,(copy-lambda
;                                                         `#'((&rest ,arg)
;                                                              (%setq ,v2 (cons ,_ ,arg))
;                                                              (%setq ,v1 (cons #'cps-return-dummy ,v2))
;                                                              (%setq nil (apply ,v1)))
;                                                         :info (make-funinfo
;                                                                   :env (list v1)
;                                                                   :parent fi
;                                                                   :args (list arg))))))
;                               g)
;                             _))
;                          (cdr (%setq-value x))))
;    (let r `(,@replacements
;             (%setq ,(%setq-place x) (,(car (%setq-value x)) ,@new-args)))
;      (& some-replaced? (print r))
;      r)))

(defun cps-foureign-funcall (fi x)
  (with-gensym (arg v1 v2)
    `((%setq ,(%setq-place x)
             ,(copy-lambda `#'((&rest ,arg)
                                (%setq ,v2 (cons ,(cadr (%setq-value x)) ,arg))
                                (%setq ,v1 (cons #'cps-return-dummy ,v2))
                                (%setq nil (apply ,v1)))
                           :info (make-funinfo :env (list v1)
                                               :parent fi
                                               :args (list arg)))))))

(defun cps-split-make-continuer (fi x xlats)
  (!? (%setq-place x.)
      (copy-lambda `#'((_)
                         (%setq ,(%setq-place x.) _)
                         ,(cps-make-call-to-next x xlats))
                   :args '(_)
                   :info (make-funinfo :args '(_) :parent fi))
      (cps-cons-function-name .x xlats)))

(defun cps-split-funcall-0 (fi fun xlats args)
  `((%setq nil (,fun ,@args))))

(defun cps-split-funcall (fi x xlats)
  (cps-split-funcall-0 fi (car (%setq-value x.)) xlats
      `(,(cps-split-make-continuer fi x xlats)
        ,@(cdr (%setq-value x.)))))

(defun cps-split-apply (fi x xlats)
  (with-gensym g
    (funinfo-var-add fi g)
    `((%setq ,g (cons ,(cps-split-make-continuer fi x xlats)
                      ,@(cdr (%setq-value x.))))
      ,@(cps-split-funcall-0 fi 'cps-apply xlats (list g)))))

(defun cps-split-methodcall (fi x xlats)
  (with (method (car (%setq-value x.))
         tag-no-cps (make-compiler-tag)
         tag-end (make-compiler-tag))
    (with-gensym g
      (funinfo-var-add fi g)
      `((%setq ,g (%defined? (%slot-value ,method tre-cps)))
        (%%go-nil ,tag-no-cps ,g)
        (%%go-nil ,tag-no-cps (%slot-value ,method tre-cps))
        ,@(cps-split-funcall fi x xlats)
        (%%go ,tag-end)
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
  (?
    (cps-apply? x.)            (cps-split-apply fi x xlats)
;    (cps-methodcall? x.)       (cps-split-methodcall fi x xlats)
;    (cps-constructorcall? x.)  (cps-split-constructorcall fi x xlats)
    (cps-funcall? x.)          (cps-split-funcall fi x xlats)
;    (cps-foureign-funcall? x.) (cps-foureign-funcall fi x.)
    (%%go? x.)                 `((%setq nil (,(cps-tag-function-name (cadr x.) xlats tag-xlats))))
    (%%go-nil? x.)             `((%%call-nil ,(caddr x.)
                                             ,(cps-tag-function-name (cadr x.) xlats tag-xlats)
                                             ,(cps-cons-function-name .x xlats)))))

(defun cps-splitpoint-expr? (x)
  (| (cps-apply? x)
     (cps-funcall? x)
;     (cps-foureign-funcall? x)
;     (cps-methodcall? x)
;     (cps-constructorcall? x)
     (%%go? x)
     (%%go-nil? x)))

(defun cps-check-funcall (fi x xlats))

(defun cps-body-tag (fi continuer x xlats tag-xlats first? exit-tag)
  (? first?
     (? .x
        (cps-body fi continuer .x xlats tag-xlats :first? nil :exit-tag exit-tag)
        `((%setq nil (,continuer ~%ret))
          ,exit-tag
          nil))
     (append `((%setq nil (,(cps-cons-function-name x xlats))))
              (list (list x)))))

(defun cps-body-splitpoint (fi x xlats tag-xlats first?)
  (append (cps-split fi x xlats tag-xlats :first? first?)
          (list (list .x))))

(defun cps-body-exit (fi continuer x xlats tag-xlats first? exit-tag)
  `(,x.
    (%%go ,exit-tag)
    ,@(cps-body fi continuer .x xlats tag-xlats :first? first? :exit-tag exit-tag)))

(defun cps-body-epilogue (continuer x exit-tag)
  `(,x.
    (%setq nil (,continuer ~%ret))
    ,exit-tag
    nil))

(defun cps-funcall-with-literal-continuer? (x)
  (& (%setq-funcall? x.)
     (member '~%continuer (cdr (%setq-value x.)) :test #'eq)))

(defun cps-body (fi continuer x xlats tag-xlats &key (first? t) exit-tag)
  (?
    (not x)                   (cons nil nil)
    (number? x.)              (cps-body-tag fi continuer x xlats tag-xlats first? exit-tag)
    (cps-splitpoint-expr? x.) (cps-body-splitpoint fi x xlats tag-xlats first?)
    (cps-funcall-with-literal-continuer? x) (cps-body-exit fi continuer x xlats tag-xlats first? exit-tag)
    (not .x)                  (cps-body-epilogue continuer x exit-tag)
    (cons x. (cps-body fi continuer .x xlats tag-xlats :first? nil :exit-tag exit-tag))))

(defun cps-make-functions (fi continuer x xlats tag-xlats)
  (when x
    (with (chunk (cps-body fi continuer x xlats tag-xlats :exit-tag (gensym-number))
           body  (butlast chunk)
           next  (caar (last chunk)))
      `((%setq ,(assoc-value x xlats) ,(copy-lambda `#'(()
                                                         ,@body)
                                                    :info (make-funinfo :parent fi :args nil)))
        ,@(cps-make-functions fi continuer next xlats tag-xlats)))))

(defun cps-get-xlat-simple (x)
  (cons (cons x (gensym))
        (cps-get-xlats .x :first? nil)))

(defun cps-get-xlat-expr (x first?)
  (? first?
     (cons (cons x (gensym))
           (cons (cons .x (gensym))
                 (cps-get-xlats .x :first? nil)))
     (cons (cons .x (gensym))
           (cps-get-xlats .x :first? nil))))

(defun cps-get-xlats (x &key (first? t))
  (when x
    (?
      (number? x.)              (cps-get-xlat-simple x)
      (cps-splitpoint-expr? x.) (cps-get-xlat-expr x first?)
      first?                    (cps-get-xlat-simple x)
      (cps-get-xlats .x :first? nil))))

(defun cps-get-tag-xlats (x)
  (when x
    (? (number? x.)
       (cons (cons x. x) (cps-get-tag-xlats .x))
       (cps-get-tag-xlats .x))))

(defun cps-function (x)
  (with (continuer '~%continuer
         new-args  (cons continuer (lambda-args x))
         fi        (get-lambda-funinfo x))
    (= (funinfo-args fi) new-args)
    (copy-lambda x
        :args new-args
        :body (with (body      (cps-filter (lambda-body x))
                     xlats     (cps-get-xlats body)
                     tag-xlats (cps-get-tag-xlats body))
                (funinfo-var-add fi '~%cps-this)
                `(,@(mapcar ^(%var ,_) (cdrlist xlats))
                  (%setq ~%cps-this this)
                  ,@(cps-make-functions (get-lambda-funinfo x) continuer body xlats tag-xlats)
                  (%setq nil (,(cdar xlats))))))))

(defun %quote-%%native-or-%var? (x)
  (| (%quote? x)
     (%%native? x)
     (%var? x)))

(define-concat-tree-filter cps-filter (x)
  (%quote-%%native-or-%var? x) (list x)
  (eq 'this x) (list '~%cps-this))

(defun cps-make-dummy-continuer (place parent-fi)
  (copy-lambda `#'((_)
                    (%setq ,place _))
               :args '(_)
               :info (make-funinfo :args '(_)
                                   :parent parent-fi)))

(defun cps-toplevel-constructorcall (x)
  (with (constructor (cadr (%setq-value x))
         tag-no-cps  (make-compiler-tag)
         tag-end     (make-compiler-tag)
         fi          (transpiler-global-funinfo *transpiler*))
    (with-gensym g
      (funinfo-var-add fi g)
      `((%setq ,g (%defined? (%slot-value ,constructor tre-cps)))
        (%%go-nil ,tag-no-cps ,g)
        (%%go-nil ,tag-no-cps (%slot-value ,constructor tre-cps))
        ,@(cps-split-constructorcall-0 fi (list x) (cps-make-dummy-continuer (%setq-place x) fi))
        (%%go ,tag-end)
        ,tag-no-cps
        ,x
        ,tag-end))))

(defun cps-toplevel-funcall (x)
  `((%setq nil (,(car (%setq-value x))
                ,(cps-make-dummy-continuer (%setq-place x) (transpiler-global-funinfo *transpiler*))
                ,@(cdr (%setq-value x))))))

(defun cps-toplevel-methodcall (x)
  (with (method     (car (%setq-value x))
         tag-no-cps (make-compiler-tag)
         tag-end    (make-compiler-tag))
    (with-gensym g
      `((%setq ,g (%defined? (%slot-value ,method tre-cps)))
        (%%go-nil ,tag-no-cps ,g)
        (%%go-nil ,tag-no-cps (%slot-value ,method tre-cps))
        ,@(cps-toplevel-funcall x)
        (%%go ,tag-end)
        ,tag-no-cps
        ,x
        ,tag-end))))

(define-concat-tree-filter cps-toplevel (x)
  (%quote-%%native-or-%var? x) (list x)
  (cps-methodcall? x)          (cps-toplevel-methodcall x)
  (cps-constructorcall? x)     (cps-toplevel-constructorcall x)
  (cps-funcall? x)             (cps-toplevel-funcall x)
  (cps-foureign-funcall? x)    (cps-foureign-funcall (transpiler-global-funinfo *transpiler*) x))

(defun cps (x)
  (cps-toplevel x))
