;;;;; nix operating system project
;;;;; lisp compiler
;;;;; Copyright (C) 2006 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Compiler-macro expansion

(defvar *compiler-macros*)
(defvar *tagbody-replacements*)
(defvar *blockname-replacements*)

(defmacro define-compiler-macro (name args body)
  `(acons! ',name #'(lambda ,args ,@(macroexpand body)) *compiler-macros*))

(defun compiler-macrop (expr)
  (assoc expr *compiler-macros*))

(defun compiler-macrocall (fun expr)
  (apply (assoc fun *compiler-macros*) expr))

(defun compiler-macroexpand (expr)
  (setq *macrop-diversion* #'compiler-macrop
	*macrocall-diversion* #'compiler-macrocall
        *tagbody-replacements* nil
        *blockname-replacements* nil)
  (prog1
    (%macroexpand (%macroexpand expr)) ; Twice for SETQ expansion.
    (setq *tagbody-replacements* nil
          *blockname-replacements* nil)))

(define-mapcar-fun vars-to-identity (x)
  (if (atom x)
    `(identity ,x)
    x))

(define-compiler-macro cond (&rest args)
  (with-queue form
    (with-gensym cond-end
      (dolist (expr args)
        (with-gensym next-expr
          (unless (t? (first expr))
            (enqueue-many form
              `((setq ~%ret ,(first expr))
                (vm-go-nil ~%ret ,next-expr))))
          (enqueue-many form
            `((setq ~%ret (vm-scope ,@(vars-to-identity (cdr expr))))
              (vm-go ,cond-end)
              ,next-expr))))
      `(vm-scope
	 ,@(queue-list form)
         ,cond-end
	 (identity ~%ret)))))

;;; TAGBODY tag replacement
;;;
;;; All labels of a tagbody are replaced by gensyms to avoid name-clashes
;;; when TAGBODYs are removed. Since GOs are be expanded before, the
;;; new labels are added to *tagbody-replacements* and used when TAGBODY
;;; is expanded.

(define-compiler-macro go (label)
  (aif (assoc label *tagbody-replacements*)
    `(vm-go ,!)
    (with-gensym g
      (acons! label g *tagbody-replacements*)
      `(vm-go ,g))))

(define-compiler-macro tagbody (&rest args)
  `(vm-scope
     ,@(mapcar #'(lambda (x)
 	           (if (consp x)
		     x
		     (aif (assoc x *tagbody-replacements*)
		       !
		       x)))
               args)
     (identity nil)))

(define-compiler-macro progn (&rest body)
  `(vm-scope ,@(vars-to-identity body)))

(defun lookup-create-gensym (block-name)
  (aif (assoc block-name *blockname-replacements*)
    !
    (with-gensym g
      (acons! block-name g *blockname-replacements*)
      g)))

(define-compiler-macro return-from (block-name expr)
  `(vm-scope
     (setq ~%ret ,expr)
     (vm-go ,(lookup-create-gensym block-name))))

(define-compiler-macro block (block-name &rest body)
  (let* ((head (butlast body))
         (tail (last body))
         (ret `(vm-scope
                 ,@head
                 (setq ~%ret ,@tail)))
         (bname (assoc block-name *blockname-replacements*)))
    (if bname
      (nconc ret (list bname) '((identity ~%ret)))
      (nconc ret '((identity ~%ret))))))

(define-compiler-macro setq (&rest args)
  `(vm-scope ,@(mapcar #'(lambda (x)
                           `(%setq ,(first x) ,(second x)))
                       (group args 2))))
