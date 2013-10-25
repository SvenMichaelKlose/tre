;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defvar *cps-toplevel?* nil)

(defun cps-call? (x)
  (& (%=-funcall? x)
     (!? (get-funinfo (car (%=-value x)))
         (funinfo-cps? !))))

(defun cps-splitpoint? (x)
  (| (number? x)
     (cps-call? x)
     (%%go? x)
     (%%go-cond? x)))

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
                              `((%= ,! ~%contret)))
                          ,@(butlast _)
                          ,@(alet (car (last _))
                              (?
                                (cps-call? !)  (with (val  (%=-value !)
                                                      name (? (%new? val)
                                                              .val.
                                                              val.)
                                                      args (? (%new? val)
                                                              ..val
                                                              .val))
                                                 (= last-place (%=-place !))
                                                 `((%= nil (,@(? (%new? val)
                                                                    `(%new))
                                                                ,name
                                                                ,(| .names. 'cps-identity)
                                                                ,@args))))
                                (%%go? !)      `((%= nil (,(assoc-value .!. tag-names))))
                                (%%go-cond? !) `((,(? (%%go-nil? !)
                                                      '%%call-nil
                                                      '%%call-not-nil)
                                                   ,..!. ,(assoc-value .!. tag-names) ,.names.))
                                (+ (& ! (list !))
                                   (?
                                     .names                `((%= nil (,.names.)))
                                     (not *cps-toplevel?*) `((%= nil (~%cont ~%ret)))))))))
              (alet (create-funinfo :name   name
                                    :args   args
                                    :body   body
                                    :parent *funinfo*)
                (pop (funinfo-vars !)))
              (pop names)
              (funinfo-var-add *funinfo* name)
              `((function ,name (,args ,@body)))]
            bodies)))

(defun cps-body-without-tag (x)
  (? (number? (car (last x)))
     (butlast x)
     x))

(defun cps-body (x)
  (!? (cps-split-body x)
      (+ (cps-make-funs (carlist !) (cps-tag-names !) (filter #'cps-subfuns (cdrlist !)))
         `((%= nil (,!..))))
      x))

(defun cps-fun (x)
  (with-temporaries (*funinfo*        (get-lambda-funinfo x)
                     *cps-toplevel?*  nil)
    (with-lambda name args body x
      (? (funinfo-cps? *funinfo*)
         (progn
           (format t "; CPS transforming ~A.~%" name)
           (list (copy-lambda x :args (. '~%cont args) :body (cps-body body))
                 `(%= (%slot-value ,name _cps-transformed?) t)))
         (list (copy-lambda x :body (cps-subfuns body)))))))

(defun cps-subfuns (x)
  (when x
    (+ (?
         (named-lambda? x.)  (cps-fun x.)
         (cps-call? x.)      (alet (%=-value x.)
                               `((%= ,(%=-place x.) (,!. cps-identity ,@.!))))
         (list x.))
       (cps-subfuns .x))))

(defun cps (x)
  (with-temporary *cps-toplevel?* t
    (cps-subfuns x)))
