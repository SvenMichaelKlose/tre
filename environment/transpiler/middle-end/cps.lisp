; tré – Copyright (c) 2013–2016 Sven Michael Klose <pixel@copei.de>

(defvar *cps-toplevel?* nil)

(defun call-from-argument-expander? (x)
  (& (%%native? x)
     (alet (real-function-name .x.)
       (| (native-cps-function? !)
          (not (cps-exception? (real-function-name !)))))))

(defun call-to-non-cps-from-expander? (x)
  (& (%=-funcall? x)
     (alet (car ..x.)
       (& (%%native? !)
          (cps-exception? (real-function-name .!.))))))

(defun call-to-non-cps-from-expander (x)
  (with-gensym g
    (funinfo-var-add *funinfo* g)
    `((%= ,g ,..x.)
      (%= nil (%cps-step ~%cont ,g)))))

(defun call-of-global-cps-function? (name)
  (& (not (cps-exception? name))
     (!? (get-funinfo name)
         (funinfo-cps? !))))

(defun call-of-local-function? (name)
  (funinfo-find *funinfo* name))

(defun cps-call? (x)
  (& (%=-funcall? x)
     (alet (alet ..x.
             (? (%new? !)
                .!.
                !.))
       (| (native-cps-function? !)
          (call-from-argument-expander? !)
          (call-of-local-function? !)
          (call-of-global-cps-function? !)))))

(defun cps-methodcall? (x)
  (& (%=-funcall? x)
     (%slot-value? (car ..x.))))

(defun native-cps-funcall? (x)
  (& (%=-funcall? x)
     (native-cps-function? (alet (car ..x.)
                             (? (%%native? !)
                                (real-function-name .!.)
                                !)))))

(defun cps-splitpoint? (x)
  (| (number? x)
     (cps-call? x)
     (cps-methodcall? x)
     (%%go? x)
     (%%go-cond? x)))

(defvar *cps-function-counter* 0)

(defun cps-split-body (x)
  (@ [. ($ '~CPS (++! *cps-function-counter*)) _]
     (split-if #'cps-splitpoint? x :include? t)))

(defun cps-tag-names (x)
  (with-queue q
    (do ((i x .i))
        ((not i) (queue-list q))
      (!? (car (last (cdr i.)))
          (& (number? !)
             (enqueue q (. ! (| (caadr i)
                                '~%cont))))))))

(defun cps-make-call (x continuer)
  (with (val               ..x.
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
  (with (val   ..x.
         slot  val.)
    `((%= nil (cps-methodcall ,.slot. ,slot ,continuer ,@.val)))))

(defun cps-make-funs (&key names tag-names bodies)
  (let last-place nil
    (mapcan [with (name  names.
                   args  (? last-place
                            '(~%contret))

                   tag-to-name      [assoc-value ._. tag-names]
                   make-call        [(= last-place ._.)
                                     (cps-make-call _ (| .names. '~%cont))]
                   make-methodcall  [(= last-place ._.)
                                     (cps-make-methodcall _ (| .names. '~%cont))]
                   make-go          [alet (tag-to-name _)
                                      `((%= nil (%cps-step ,! ,@(& (eq '~%cont !)
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
                                 (call-to-non-cps-from-expander? !) (call-to-non-cps-from-expander !)
                                 (cps-call? !)        (make-call !)
                                 (cps-methodcall? !)  (make-methodcall !)
                                 (%%go? !)            (make-go !)
                                 (%%go-cond? !)       (make-cond !)
                                 (+ (& (not (number? !))
                                       (list !))
                                    (?
                                      .names                `((%= nil (%cps-step ,.names.)))
                                      (not *cps-toplevel?*) `((%= nil (%cps-step ~%cont ~%ret)))))))))
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

(defun cps-body-0 (x)
  (mapcan [? (named-lambda? _)
             (cps-fun _)
             (list _)]
          x))

(defun cps-body (x)
  (!? (cps-split-body x)
      (+ (cps-make-funs :names     (carlist !)
                        :tag-names (cps-tag-names !)
                        :bodies    (@ #'cps-body-0 (cdrlist !)))
         `((%= nil (,!..))))
      x))

(defun cps-add-this (x)
  (funinfo-var-add *funinfo* '~%this)
  (. '(%= ~%this this)
     x))

(defun cps-body-with-this (x)
  (? (& (funinfo-toplevel? *funinfo*)
        (tree-find '~%this x))
     (cps-add-this x)
     x))

(defun in-cps-wrapper? ()
  (!? (funinfo-topmost *funinfo*)
      (cps-wrapper? (funinfo-name !))))

(defun cps-fun (x)
  (with-lambda-funinfo x
    (with-lambda name args body x
      (?
        (eq 'apply (funinfo-name *funinfo*))
          (list (copy-lambda x :args (. '~%cont args)))
        (native-cps-function? (funinfo-name *funinfo*))
          (list (copy-lambda x :args (. '~%cont args) :body (cps-passthrough body)))
        (funinfo-cps? *funinfo*)
          (with-temporary *cps-toplevel?* nil
            (list (copy-lambda x :args (. '~%cont args)
                                 :body (cps-body-with-this (cps-body body)))
                  `(%= (%slot-value ,name _cps-transformed?) t)))
        (list (copy-lambda x :body (+ (unless (in-cps-wrapper?)
                                        '((%= (%global *cps-step?*) (%%%+ (%global *cps-step?*) 1))))
                                      (cps-passthrough (cps-body-with-this body))
                                      (unless (in-cps-wrapper?)
                                        '((%= (%global *cps-step?*) (%%%- (%global *cps-step?*) 1)))))))))))

(defun cps-return-value (x)
  (!? .x.
      `(cps-toplevel-return-value ,!)
      'cps-identity))

(defun cps-passthrough (x)
  (with-temporary *cps-toplevel?* t
    (mapcan [pcase _
              native-cps-funcall?  (let v .._.
                                     `((%= nil (,v. ,(cps-return-value _) ,@.v))))
              cps-call?            (cps-make-call _ (cps-return-value _))
              cps-methodcall?      (cps-make-methodcall _ (cps-return-value _))
              named-lambda?        (cps-fun _)
              (list _)]
            x)))

(defun cps (x)
  (cps-passthrough x))
