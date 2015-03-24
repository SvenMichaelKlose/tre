; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(defun thisify-collect-methods-and-members (clsdesc)
  (+ (class-methods clsdesc)
     (class-members clsdesc)
     (!? (class-parent clsdesc)
         (thisify-collect-methods-and-members !))))

(defun thisify-symbol (classdef x exclusions)
  (? (eq 'this x)
     '~%this
     (!? (& classdef
            (not (| (number? x)
                    (string? x))
                 (member x exclusions :test #'eq))
            (assoc x classdef))
         `(%slot-value ~%this ,x)
         x)))

(defun thisify-list-0 (classdef x exclusions)
  (?
	(atom x)          (thisify-symbol classdef x exclusions)
	(quote? x)        x
    (%slot-value? x)  `(%slot-value ,(thisify-symbol classdef .x. exclusions) ,..x.)
	(lambda? x)       (copy-lambda x :body (thisify-list-0 classdef
                                                           (lambda-body x)
                                                           (+ exclusions (lambda-args x))))
    (listprop-cons x
                   (? (%slot-value? x.)
			          `(%slot-value ,(thisify-list-0 classdef (cadr x.) exclusions)
                                    ,(caddr x.))
                      (thisify-list-0 classdef x. exclusions))
                   (thisify-list-0 classdef .x exclusions))))

(defun thisify-list (classes x cls)
  (thisify-list-0 (thisify-collect-methods-and-members (href classes cls)) x nil))

(def-head-predicate %thisify)

(defun thisify (x &optional (classes (thisify-classes)))
  (?
	(atom x)        x
	(%thisify? x.)  (frontend-macroexpansions
                        `((,@(? (enabled-pass? :cps)
                                '(%%block)
                                '(let ~%this this))
                           ,@(| (+ (thisify-list classes (cddr x.) (cadr x.))
			                       (thisify .x classes))
                                '(nil)))))
    (listprop-cons x (thisify x. classes)
                     (thisify .x classes))))
