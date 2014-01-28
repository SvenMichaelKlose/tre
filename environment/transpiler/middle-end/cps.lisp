;;;;; tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@copei.de>

(defvar *cps-toplevel?* nil)

(defun call-from-argument-expander? (x)
  (& (%%native? x)
     (alet (real-function-name .x.)
       (| (transpiler-native-cps-function? *transpiler* !)
          (not (transpiler-cps-exception? *transpiler* (real-function-name !)))))))

(defun call-to-non-cps-from-expander? (x)
  (& (%=-funcall? x)
     (alet (car (%=-value x))
       (& (%%native? !)
          (transpiler-cps-exception? *transpiler* (real-function-name .!.))))))

(defun call-to-non-cps-from-expander (x)
  (with-gensym g
    (funinfo-var-add *funinfo* g)
    `((%= ,g ,(%=-value x))
      (%= nil (%cps-step ~%cont ,g)))))

(defun call-of-global-cps-function? (name)
  (& (not (transpiler-cps-exception? *transpiler* name))
     (!? (get-funinfo name)
         (funinfo-cps? !))))

(defun call-of-local-function? (name)
  (funinfo-find *funinfo* name))

(defun cps-call? (x)
  (& (%=-funcall? x)
     (alet (alet (%=-value x)
             (? (%new? !)
                .!.
                !.))
       (| (transpiler-native-cps-function? *transpiler* !)
          (call-from-argument-expander? !)
          (call-of-local-function? !)
          (call-of-global-cps-function? !)))))

(defun cps-methodcall? (x)
  (& (%=-funcall? x)
     (%slot-value? (car (%=-value x)))))

(defun native-cps-funcall? (x)
  (& (%=-funcall? x)
     (transpiler-native-cps-function? *transpiler* (alet (car (%=-value x))
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
                        :bodies    (filter #'cps-body-0 (cdrlist !)))
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
      (transpiler-cps-wrapper? *transpiler* (funinfo-name !))))

(defun cps-fun (x)
  (with-temporary *funinfo* (get-lambda-funinfo x)
    (with-lambda name args body x
      (?
        (eq 'apply (funinfo-name *funinfo*))
          (list (copy-lambda x :args (. '~%cont args)))
        (transpiler-native-cps-function? *transpiler* (funinfo-name *funinfo*))
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
  (!? (%=-place x)
      `(cps-toplevel-return-value ,!)
      'cps-identity))

(defun cps-passthrough (x)
  (with-temporary *cps-toplevel?* t
    (mapcan [?
              (native-cps-funcall? _)  (let v (%=-value _)
                                         `((%= nil (,v. ,(cps-return-value _) ,@.v))))
              (cps-call? _)            (cps-make-call _ (cps-return-value _))
              (cps-methodcall? _)      (cps-make-methodcall _ (cps-return-value _))
              (named-lambda? _)        (cps-fun _)
              (list _)]
            x)))

(defun cps (x)
  (cps-passthrough x))
