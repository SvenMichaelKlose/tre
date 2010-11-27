;;;;; TRE compiler
;;;;; Copyright (c) 2006-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Compiler-macro expansion.
;;;;;
;;;;; Converts control-flow functions into jumps.
;;;;; VM-GO unconditionally jumps to a tag.
;;;;; VM-GO-NIL jumps to a tag if the first argument is NIL.
;;;;; Both jump types are removed when tree-expanding.
;;;;; VM-SCOPE holds a list of expresions and tags. They are nerged in the next pass.

(defvar *tagbody-replacements*)

(defun compiler-macroexpand-prepost ()
  (setq *tagbody-replacements* nil))

(define-expander 'compiler :pre  #'compiler-macroexpand-prepost
						   :post #'compiler-macroexpand-prepost)

(defmacro define-compiler-macro (&rest x)
  (when *show-definitions*
	(late-print `(define-compiler-macro ,x.)))
  `(define-expander-macro compiler ,@x))

(defun compiler-macroexpand (x)
  (expander-expand 'compiler x))

(define-mapcar-fun vars-to-identity (x)
  (if (atom x)
      `(identity ,x)
      x))

(define-compiler-macro cond (&rest args)
  (with-compiler-tag end-tag
    `(vm-scope
       ,@(mapcan (fn (with-compiler-tag next
                       `(,@(unless (t? _.)
                             `((%setq ~%ret ,_.)
                               (vm-go-nil ~%ret ,next)))
                         ,@(awhen (vars-to-identity ._)
							 `((%setq ~%ret (vm-scope ,@!))))
                         (vm-go ,end-tag)
                         ,next)))
			     args)
       ,end-tag
	   (identity ~%ret))))

;;; TAGBODY tag replacement
;;;
;;; All tags of a tagbody are replaced by compiler-tags to avoid name-clashes
;;; when TAGBODYs are removed. GOs are expanded beforehand
;;; (because macro expansion is done from leave to root), and the
;;; new tags are added to *tagbody-replacements* and used when TAGBODY
;;; is expanded.

(define-compiler-macro go (tag)
  (aif (cdr (assoc tag *tagbody-replacements* :test #'eq))
    `(vm-go ,!)
    (with-compiler-tag g
      (acons! tag g *tagbody-replacements*)
      `(vm-go ,g))))

(define-compiler-macro tagbody (&rest args)
  `(vm-scope
     ,@(mapcar (fn (if (consp _)
		     		   _
		     		   (aif (cdr (assoc _ *tagbody-replacements* :test #'eq))
		       				!
		       				_)))
               args)
     (identity nil)))

(define-compiler-macro progn (&rest body)
  `(vm-scope ,@(aif (vars-to-identity body) ; XXX fscking workaround
					!
					'((identity nil)))))

(define-expander 'compiler-return)
(defvar *blockname* nil)
(defvar *blockname-replacement* nil)

(define-expander-macro compiler-return return-from (block-name expr)
  (if (eq block-name *blockname*)
      `(vm-scope
         (%setq ~%ret ,expr)
         (vm-go ,*blockname-replacement*))
	  `(return-from ,block-name ,expr)))

(define-compiler-macro block (block-name &rest body)
  (if body
	  (with-compiler-tag g
		(with-temporary *blockname* block-name
		  (with-temporary *blockname-replacement* g
            (with (b	 (expander-expand 'compiler-return body)
			       head  (butlast b)
                   tail  (last b)
                   ret   `(vm-scope
                            ,@head
                            ,@(if (vm-jump? tail.)
						          tail
						          `((%setq ~%ret ,@tail)))))
              (nconc ret `(,g (identity ~%ret)))))))
    `(identity nil)))

(define-compiler-macro setq (&rest args)
  `(vm-scope ,@(mapcar (fn `(%setq ,_. ,._.))
                       (group args 2))))

(define-compiler-macro if (&rest body)
  (with (tests (group body 2)
		 end   (car (last tests)))
    `(cond
        ,@(if (= 1 (length end))
			  (append (butlast tests)
					  (list (cons t end)))
			  tests))))
