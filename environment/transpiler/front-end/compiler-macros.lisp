(defvar *tagbody-replacements* nil)

(defun init-compiler-macros ()
  (= *tagbody-replacements* nil))

(defvar *compiler-macro-expander* (define-expander 'compiler :pre #'init-compiler-macros))

(defmacro define-compiler-macro (name args &body x)
  (print-definition `(define-compiler-macro ,name ,args))
  `(define-expander-macro *compiler-macro-expander* ,name ,args ,@x))

(defun compiler-macroexpand (x)
  (expander-expand *compiler-macro-expander* x))

(define-compiler-macro cond (&rest args)
  (with-compiler-tag end-tag
    `(%%block
       ,@(mapcan [with-compiler-tag next
                   (when _.
                     `(,@(unless (eq t _.)
                           `((%= ~%ret ,_.)
                             (%%go-nil ,next ~%ret)))
				       ,@(!? (wrap-atoms ._)
				             `((%= ~%ret (%%block ,@!))))
                       (%%go ,end-tag)
                       ,@(unless (eq t _.)
                           (list next))))]
			     args)
       ,end-tag
	   (identity ~%ret))))

(define-compiler-macro progn (&body body)
  (!? body
      `(%%block ,@(wrap-atoms !))))

(define-compiler-macro setq (&rest args)
  `(%%block ,@(@ [`(%= ,_. ,._.)]
                 (group args 2))))

(define-compiler-macro ? (&body body)
  (with (tests (group body 2)
         end   (car (last tests)))
    (unless body
      (error "Body is missing."))
    `(cl:cond
       ,@(? .end
            tests
            (+ (butlast tests) (list (. t end)))))))


;; TAGBODY

(defvar *tagbody-expander* (define-expander 'tagbodyexpand))
(defvar *tagbody-replacements* nil)

(defun tag-replacement (tag)
  (cdr (assoc tag *tagbody-replacements* :test #'eq)))

(defun tagbodyexpand (body)
  (with-temporary *tagbody-replacements* nil
    (@ [? (atom _)
          (acons! _ (make-compiler-tag) *tagbody-replacements*)]
       body)
    `(%%block
       ,@(@ [| (& (atom _)
                   (tag-replacement _))
               _]
            (expander-expand *tagbody-expander* body))
       (identity nil))))

(define-expander-macro *tagbody-expander* go (tag)
  (!? (tag-replacement tag)
      `(%%go ,!)
      (error "Can't find tag ~A in TAGBODY." tag)))

(define-expander-macro *tagbody-expander* tagbody (&body body)
  (tagbodyexpand body))

(define-compiler-macro tagbody (&body body)
  (tagbodyexpand body))


;; BLOCK

(defvar *block-expander* (define-expander 'blockexpand))
(defvar *blocks* nil)

(defun blockexpand (name body)
  (? body
	 (with-compiler-tag end-tag
	   (with-temporary *blocks* (. (. name end-tag) *blocks*)
         (with (b     (expander-expand *block-expander* body)
                head  (butlast b)
                tail  (last b))
           `(%%block
              ,@head
              ,@(? (vm-jump? tail.)
                   tail
                   `((%= ~%ret ,@tail)))
              ,end-tag
              (identity ~%ret)))))
    `(identity nil)))

(define-expander-macro *block-expander* return-from (block-name expr)
  (| *blocks*
     (error "RETURN-FROM outside BLOCK."))
  (!? (assoc block-name *blocks* :test #'eq)
     `(%%block
        (%= ~%ret ,expr)
        (%%go ,.!))
     (error "RETURN-FROM unknown BLOCK ~A." block-name)))

(define-expander-macro *block-expander* block (name &body body)
  (blockexpand name body))

(define-compiler-macro block (name &body body)
  (blockexpand name body))
