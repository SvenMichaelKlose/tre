;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defvar *cps-toplevel?* nil)

(defun cps-call? (x)
  (& (%=-funcall? x)
     (alet (car (%=-value x))
       (| (eq 'apply !)
          (& (not (transpiler-cps-exception? *transpiler* x.))
             (| (funinfo-find *funinfo* !)
                (!? (get-funinfo !)
                    (funinfo-cps? !))))))))

(defun cps-splitpoint? (x)
  (| (number? x)
     (cps-call? x)
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

(defun cps-make-funs (&key names tag-names bodies)
  (let last-place nil
    (mapcan [with (name         names.
                   args         (? last-place
                                   '(~%contret))
                   tag-to-name  [assoc-value ._. tag-names]
                   make-call    [with (val               (%=-value _)
                                       constructorcall?  (%new? val)
                                       name              (? constructorcall?
                                                            .val.
                                                            val.)
                                       args              (? constructorcall?
                                                            ..val
                                                            .val))
                                  (= last-place (%=-place _))
                                  (& (member 'cps-identity args)
                                     (error "Function has already been transformed."))
                                  `((%= nil (,@(? constructorcall?
                                                  `(%new))
                                             ,name
                                             ,(| .names. '~%cont)
                                             ,@args)))]
                   make-go      [alet (tag-to-name _)
                                  `((%= nil (,! ,@(& (eq '~%cont !)
                                                     `(~%ret)))))]
                   make-cond    [`((,(? (%%go-nil? _)
                                        '%%call-nil
                                        '%%call-not-nil)
                                    ,.._.  ,(tag-to-name _) ,.names.))]
                   body         `(,@(awhen last-place
                                      (clr last-place)
                                      `((%= ,! ~%contret)))
                                  ,@(butlast _)
                                  ,@(alet (car (last _))
                                      (?
                                        (cps-call? !)   (make-call !)
                                        (%%go? !)       (make-go !)
                                        (%%go-cond? !)  (make-cond !)
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
        (eq 'apply (funinfo-name *funinfo*))
          (list (copy-lambda x :args (. '~%cont args)))
        (funinfo-cps? *funinfo*)
          (list (copy-lambda x :args (. '~%cont args) :body (cps-body body))
                `(%= (%slot-value ,name _cps-transformed?) t))
        (list (copy-lambda x))))))

(defun cps-subfuns (x)
  (when x
    (+ (?
         (named-lambda? x.)  (cps-fun x.)
         (& *cps-toplevel?*
            (cps-call? x.))  (alet (%=-value x.)
                               `((%= nil (,!. ,(!? (%=-place x.)
                                                   `(cps-toplevel-return-value ,!)
                                                   'cps-identity)
                                              ,@.!))))
         (list x.))
       (cps-subfuns .x))))

(defun cps (x)
  (with-temporary *cps-toplevel?* t
    (cps-subfuns x)))
