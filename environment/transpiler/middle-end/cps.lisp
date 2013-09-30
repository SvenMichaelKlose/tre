;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defvar *cps-toplevel?* nil)

(defun cps-call? (x)
  (& (%setq-funcall? x)
     (transpiler-cps-function? *transpiler* (car (%setq-value x)))))

(defun cps-splitpoint? (x)
  (| (number? x)
     (cps-call? x)
     (%%go? x)
     (%%go-nil? x)))

(defvar *cps-function-counter* 0)

(defun cps-split-body (x)
  (filter [cons ($ '~CPS (++! *cps-function-counter*)) _]
          (split-if #'cps-splitpoint? x :include? t)))

(defun cps-tag-names (x)
  (mapcan [alet (car (last ._))
            (& (number? !)
               (list (cons ! _.)))]
          x))

(defun cps-make-funs (names tag-names bodies)
  (let last-place nil
    (mapcan [with (name names.
                   args (? last-place
                           '(~%contret))
                   body `(,@(awhen last-place
                              (clr last-place)
                              `((%setq ,! ~%contret)))
                          ,@(butlast _)
                          ,@(alet (car (last _))
                              (?
                                (cps-call? !)  (progn
                                                 (= last-place (%setq-place !))
                                                 `((%setq nil (cps-funcall ,(car (%setq-value !))
                                                                           ,.names.
                                                                           ,@(cdr (%setq-value !))))))
                                (%%go? !)      `((%setq nil (,(assoc-value .!. tag-names))))
                                (%%go-nil? !)  `((%%call-nil ,..!. ,(assoc-value .!. tag-names) ,.names.))
                                (+ (& ! (list !))
                                   (?
                                     .names                `((%setq nil (,.names.)))
                                     (not *cps-toplevel?*) `((%setq nil (~%cont ~%ret)))))))))
              (alet (create-funinfo :name   name
                                    :args   args
                                    :body   body
                                    :parent *funinfo*
                                    :cps?   t)
                (pop (funinfo-vars !)))
              (pop names)
              `((function ,name (,args ,@body)))]
            bodies)))

(defun cps-body-without-tag (x)
  (? (number? (car (last x)))
     (butlast x)
     x))

(defun cps-fun (x)
  (with-temporaries (*funinfo*       (get-lambda-funinfo x)
                     *cps-toplevel?* nil)
    (copy-lambda x :args (cons '~%cont (lambda-args x)) :body (cps-0 (lambda-body x)))))

(defun cps-subfuns (x)
  (when x
    (cons (? (named-lambda? x.)
             (cps-fun x.)
             x.)
          (cps-0 .x))))

(defun cps-0 (x)
  (!? (cps-split-body x)
      (+ (cps-make-funs (carlist !) (cps-tag-names !) (filter #'cps-subfuns (cdrlist !)))
         `((%setq fnord (,!..))))
      x))

(defun cps (x)
  (with-temporary *cps-toplevel?* t
    (cps-0 x)))
