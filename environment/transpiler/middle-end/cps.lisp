;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun cps-splitpoint? (x)
  (| (number? x)
     (%setq-funcall? x)
     (%%go? x)
     (%%go-nil? x)
     (named-lambda? x)))

(defun cps-split-body (x)
  (filter [cons (gensym) _]
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
                                (& (%setq-funcall? !)
                                   (| (%slot-value? (car (%setq-value !)))
                                      (transpiler-cps-function? *transpiler* (car (%setq-value !)))))
                                                   (progn
                                                     (= last-place (%setq-place !))
                                                     `((%setq nil (cps-funcall ,(car (%setq-value !))
                                                                               ,.names.
                                                                               ,@(cdr (%setq-value !))))))
                                (%%go? !)          `((%setq nil (,(assoc-value .!. tag-names))))
                                (%%go-nil? !)      `((%%call-nil ,..!. ,(assoc-value .!. tag-names) ,.names.))
                                (+ (list !)
                                   (? .names
                                      `((%setq nil (,.names.)))
                                      `((%setq nil (~%cont ~%ret)))))))))
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
  (with-temporary *funinfo* (get-lambda-funinfo x)
    (copy-lambda x :body (cps (lambda-body x)))))

(defun cps-subfuns (x)
  (when x
    (cons (? (named-lambda? x.)
             (cps-fun x.)
             x.)
          (cps .x))))

(defun cps (x)
  (alet (cps-split-body x)
    (+ (cps-make-funs (carlist !) (cps-tag-names !) (filter (compose #'cps-subfuns
                                                                     #'cps-body-without-tag)
                                                            (cdrlist !)))
       `((%setq nil (,!..))))))
