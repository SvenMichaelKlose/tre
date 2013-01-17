;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defvar *tagbody-replacements*)

(defun init-compiler-macros ()
  (setq *tagbody-replacements* nil))

(define-expander 'compiler :pre  #'init-compiler-macros)

(defmacro define-compiler-macro (&rest x)
  (print-definition `(define-compiler-macro ,x.))
  `(define-expander-macro compiler ,@x))

(defun compiler-macroexpand (x)
  (expander-expand 'compiler x))

(defun compress-%%vm-scopes (body)
  (mapcan [? (%%vm-scope? _)
             ._
             (list _)]
          body))

(define-compiler-macro cond (&rest args)
  (with-compiler-tag end-tag
    `(%%vm-scope
       ,@(mapcan [with-compiler-tag next
                   `(,@(unless (t? _.)
                         `((%setq ~%ret ,_.)
                           (%%vm-go-nil ~%ret ,next)))
                     ,@(awhen (distinguish-vars-from-tags ._)
				         `((%setq ~%ret (%%vm-scope ,@!))))
                     (%%vm-go ,end-tag)
                     ,next)]
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
  (!? (cdr (assoc tag *tagbody-replacements* :test #'eq))
      `(%%vm-go ,!)
      (with-compiler-tag g
        (acons! tag g *tagbody-replacements*)
        `(%%vm-go ,g))))

(define-compiler-macro tagbody (&rest args)
  `(%%vm-scope
     ,@(filter [(? (cons? _)
		           _
		     	   (| (assoc-value _ *tagbody-replacements* :test #'eq)
		       	      _))]
               args)
     (identity nil)))

(define-compiler-macro progn (&rest body)
  (!? body
      `(%%vm-scope ,@(distinguish-vars-from-tags body))))

(define-expander 'compiler-return)
(defvar *blockname* nil)
(defvar *blockname-replacement* nil)

(define-expander-macro compiler-return return-from (block-name expr)
  (? (eq block-name *blockname*)
     `(%%vm-scope
        (%setq ~%ret ,expr)
        (%%vm-go ,*blockname-replacement*))
	 `(return-from ,block-name ,expr)))

(define-compiler-macro block (block-name &rest body)
  (? body
	 (with-compiler-tag g
	   (with-temporaries (*blockname* block-name
		                  *blockname-replacement* g)
           (with (b     (expander-expand 'compiler-return body)
			      head  (butlast b)
                  tail  (last b)
                  ret   `(%%vm-scope
                           ,@head
                           ,@(? (vm-jump? tail.)
						        tail
						        `((%setq ~%ret ,@tail)))))
            (nconc ret `(,g (identity ~%ret))))))
    `(identity nil)))

(define-compiler-macro setq (&rest args)
  `(%%vm-scope ,@(filter ^(%setq ,_. ,._.) (group args 2))))

(define-compiler-macro ? (&rest body)
  (with (tests (group body 2)
		 end   (car (last tests)))
    (unless body
      (error "?: Body missing"))
    `(cond
        ,@(? (== 1 (length end))
			 (+ (butlast tests) (list (cons t end)))
			 tests))))

(define-compiler-macro %%vm-scope (&rest body)
   (?
     .body            `(%%vm-scope ,@(compress-%%vm-scopes body))
     (vm-jump? body.) `(%%vm-scope ,body.)
     body.            body.))

(define-compiler-macro function (x)
  `(function ,(? (atom x)
                 x
                 (cons x. (compress-%%vm-scopes .x)))))
