;;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

(defvar *tagbody-replacements*)

(defun init-compiler-macros ()
  (= *tagbody-replacements* nil))

(define-expander 'compiler :pre  #'init-compiler-macros)

(defmacro define-compiler-macro (name args &body x)
  (print-definition `(define-compiler-macro ,name ,args))
  `(define-expander-macro compiler ,name ,args ,@x))

(defun compiler-macroexpand (x)
  (expander-expand 'compiler x))

(define-compiler-macro cond (&rest args)
  (with-compiler-tag end-tag
    `(%%block
       ,@(mapcan [with-compiler-tag next
                   (when _.
                     `(,@(unless (t? _.)
                           `((%= ~%ret ,_.)
                             (%%go-nil ,next ~%ret)))
				       ,@(!? (distinguish-vars-from-tags ._)
				             `((%= ~%ret (%%block ,@!))))
                       (%%go ,end-tag)
                       ,@(unless (t? _.)
                           (list next))))]
			     args)
       ,end-tag
	   (identity ~%ret))))

(define-compiler-macro go (tag)
  (!? (cdr (assoc tag *tagbody-replacements* :test #'eq))
      `(%%go ,!)
      (with-compiler-tag g
        (acons! tag g *tagbody-replacements*)
        `(%%go ,g))))

(define-compiler-macro tagbody (&body body)
  `(%%block
     ,@(filter [(? (cons? _)
		           _
		     	   (| (assoc-value _ *tagbody-replacements* :test #'eq)
		       	      _))]
               body)
     (identity nil)))

(define-compiler-macro progn (&body body)
  (!? body
      `(%%block ,@(distinguish-vars-from-tags body))))

(define-expander 'compiler-return)
(defvar *blockname* nil)
(defvar *blockname-replacement* nil)

(define-expander-macro compiler-return return-from (block-name expr)
  (? (eq block-name *blockname*)
     `(%%block
        (%= ~%ret ,expr)
        (%%go ,*blockname-replacement*))
	 `(return-from ,block-name ,expr)))

(define-compiler-macro block (block-name &body body)
  (? body
	 (with-compiler-tag g
	   (with-temporaries (*blockname* block-name
		                  *blockname-replacement* g)
           (with (b     (expander-expand 'compiler-return body)
			      head  (butlast b)
                  tail  (last b)
                  ret   `(%%block
                           ,@head
                           ,@(? (vm-jump? tail.)
						        tail
						        `((%= ~%ret ,@tail)))))
            (append ret `(,g (identity ~%ret))))))
    `(identity nil)))

(define-compiler-macro setq (&rest args)
  `(%%block ,@(filter ^(%= ,_. ,._.) (group args 2))))

(define-compiler-macro ? (&body body)
  (with (tests (group body 2)
		 end   (car (last tests)))
    (unless body
      (error "Body is missing."))
    `(cond
        ,@(? (sole? end)
			 (+ (butlast tests) (list (cons t end)))
			 tests))))

; XXX the expression expansion should be redone from scratch and then it should be able to deal with this.
(defun compress-%%blocks (body)
  (mapcan [? (%%block? _)
             ._
             (list _)]
          body))

(define-compiler-macro %%block (&body body)
   (?
     .body            `(%%block ,@(compress-%%blocks body))
     (vm-jump? body.) `(%%block ,body.)
     body.            body.))

(define-compiler-macro function (&rest x)
  `(function ,x. ,@(!? .x
                       (compress-%%blocks !))))
