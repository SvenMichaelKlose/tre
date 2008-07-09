;;;;; nix operating system project
;;;;; lisp compiler
;;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Compiler-macro expansion.
;;;;;
;;;;; Converts control-flow functions into jumps.
;;;;; VM-GO unconditionally jumps to a label.
;;;;; VM-GO-NIL jumps to a label if the first argument is NIL.
;;;;; Both jump types are removed when tree-expanding.
;;;;; VM-SCOPE holds a list of expresions and labels. They are nerged in the next pass.

(defvar *tagbody-replacements*)
(defvar *blockname-replacements*)

(defun compiler-macroexpand-prepost ()
  (setq *tagbody-replacements* nil
        *blockname-replacements* nil))

(define-expander 'compiler #'compiler-macroexpand-prepost
						   #'compiler-macroexpand-prepost)

(defmacro define-compiler-macro (name args body)
  `(define-expander-macro 'compiler ,name ,args ,body))

(defun compiler-macroexpand (x)
  (expander-expand 'compiler x))

(define-mapcar-fun vars-to-identity (x)
  (if (atom x)
      `(identity ,x)
      x))

(define-compiler-macro cond (&rest args)
  (with-queue form
    (with-gensym end-tag
      (dolist (expr args)
        (with-gensym next-expr
          (unless (t? (first expr))
            (enqueue-many form
              `((%setq ~%ret ,(first expr))
                (vm-go-nil ~%ret ,next-expr))))
          (enqueue-many form
            `((%setq ~%ret (vm-scope
							,@(vars-to-identity (cdr expr))))
              (vm-go ,end-tag)
              ,next-expr))))
      `(vm-scope
	     ,@(queue-list form)
      ,end-tag
	  (identity ~%ret)))))

;;; TAGBODY tag replacement
;;;
;;; All labels of a tagbody are replaced by gensyms to avoid name-clashes
;;; when TAGBODYs are removed. GOs are expanded beforehand
;;; (because macro expansion is done from leave to root), and the
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
     ,@(mapcar #'((x)
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
  (or (assoc block-name *blockname-replacements*)
      (with-gensym g
        (acons! block-name g *blockname-replacements*)
        g)))

(define-compiler-macro return-from (block-name expr)
  `(vm-scope
     (%setq ~%ret ,expr)
     (vm-go ,(lookup-create-gensym block-name))))

(define-compiler-macro block (block-name &rest body)
  (if body
      (let* ((head (butlast body))
             (tail (last body))
             (ret  `(vm-scope
                      ,@head
                      ,@(if (vm-jump? (car tail))
						    tail
						    `((%setq ~%ret ,@tail)))))
             (bname (assoc block-name *blockname-replacements*)))
        (if bname
            (nconc ret (list bname) '((identity ~%ret)))
            (nconc ret '((identity ~%ret)))))
    `(identity nil)))

(define-compiler-macro setq (&rest args)
  `(vm-scope ,@(mapcar #'((x)
						    `(%setq ,(first x) ,(second x)))
                       (group args 2))))
