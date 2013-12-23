;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defvar *cps-toplevel?* nil)

(defun cps-call? (x)
  (with (call-from-argument-expander?
             [& (%%native? _)
                (not (transpiler-cps-exception? *transpiler* (real-function-name ._.)))]
         call-of-local-function?
             [funinfo-find *funinfo* _]
         call-of-global-cps-function?
             [& (not (transpiler-cps-exception? *transpiler* _))
                (!? (get-funinfo _)
                    (funinfo-cps? !))])
    (& (%=-funcall? x)
       (alet (car (%=-value x))
         (| (transpiler-native-cps-function? *transpiler* !)
            (call-from-argument-expander? !)
            (call-of-local-function? !)
            (call-of-global-cps-function? !))))))

(defun cps-methodcall? (x)
  (& (%=-funcall? x)
     (%slot-value? (car (%=-value x)))))

(defun cps-splitpoint? (x)
  (| (number? x)
     (cps-call? x)
     (cps-methodcall? x)
     (%%go? x)
     (%%go-cond? x)))

(defvar *cps-function-counter* 0)

(defun cps-split-body (x)
  (filter [. ($ '~CPS (++! *cps-function-counter*)) _]
          (split-if #'cps-splitpoint? x :include? t)))

(defun cps-tag-names (x)
  (with-queue q
    (do ((i x .i))
        ((not i) (queue-list q))
      (!? (car (last (cdr i.)))
          (& (number? !)
             (enqueue q (. ! (| (caadr i)
                                '~%cont))))))))

;(defun cps-tag-names (x)
;  (mapcan [!? (car (last ._))
;              (& (number? !)
;                 (list (. ! _.)))]
;          x))

(defun cps-make-call (x continuer)
  (with (val               (%=-value x)
         constructorcall?  (%new? val)
         name              (? constructorcall?
                              .val.
                              val.)
         args              (? constructorcall?
                              ..val
                              .val))
    `((%= nil (,@(? constructorcall?
                    `(%new))
               ,name ,continuer ,@args)))))

(defun cps-make-methodcall (x continuer)
  (with (val   (%=-value x)
         slot  val.)
    `((%= nil (cps-methodcall ,.slot. ,slot ,continuer ,@.val)))))

(defun cps-make-funs (&key names tag-names bodies)
  (let last-place nil
    (mapcan [with (name  names.
                   args  (? last-place
                            '(~%contret))

                   tag-to-name      [assoc-value ._. tag-names]
                   make-call        [(= last-place (%=-place _))
                                     (cps-make-call _ (| .names. '~%cont))]
                   make-methodcall  [(= last-place (%=-place _))
                                     (cps-make-methodcall _ (| .names. '~%cont))]
                   make-go          [alet (tag-to-name _)
                                      `((%= nil (,! ,@(& (eq '~%cont !)
                                                         `(~%ret)))))]
                   make-cond        [`((,(? (%%go-nil? _)
                                            '%%call-nil
                                            '%%call-not-nil)
                                        ,.._.  ,(tag-to-name _) ,.names.))]

                   body  `(,@(awhen last-place
                               (clr last-place)
                               `((%= ,! ~%contret)))
                           ,@(butlast _)
                           ,@(alet (car (last _))
                               (?
                                 (cps-call? !)        (make-call !)
                                 (cps-methodcall? !)  (make-methodcall !)
                                 (%%go? !)            (make-go !)
                                 (%%go-cond? !)       (make-cond !)
                                 (+ (& !
                                       (not (number? !))
                                       (list !))
                                    (?
                                      .names                `((%= nil (,.names.)))
                                      (not *cps-toplevel?*) `((%= nil (~%cont ~%ret)))))))))
              (alet (create-funinfo :name    name
                                    :args    args
                                    :body    body
                                    :parent  *funinfo*)
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
      (+ (cps-make-funs :names     (carlist !)
                        :tag-names (cps-tag-names !)
                        :bodies    (filter #'cps-subfuns (cdrlist !)))
         `((%= nil (,!..))))
      x))

(defun cps-fun (x)
  (with-temporaries (*funinfo*        (get-lambda-funinfo x)
                     *cps-toplevel?*  nil)
    (with-lambda name args body x
      (?
        (transpiler-native-cps-function? *transpiler* (funinfo-name *funinfo*))
          (list (copy-lambda x :args (. '~%cont args)))
        (funinfo-cps? *funinfo*)
          (list (copy-lambda x :args (. '~%cont args) :body (cps-body body))
                `(%= (%slot-value ,name _cps-transformed?) t))
        (list (copy-lambda x))))))

(defun cps-return-value (x)
  (!? (%=-place x)
      `(cps-toplevel-return-value ,!)
      'cps-identity))

(defun cps-subfuns (x)
  (when x
    (+ (?
         (named-lambda? x.)        (cps-fun x.)
         (& *cps-toplevel?*
            (cps-call? x.))        (cps-make-call x. (cps-return-value x))
         (& *cps-toplevel?*
            (cps-methodcall? x.))  (cps-make-methodcall x. (cps-return-value x))
         (list x.))
       (cps-subfuns .x))))

(defun cps (x)
  (with-temporary *cps-toplevel?* t
    (cps-subfuns x)))
