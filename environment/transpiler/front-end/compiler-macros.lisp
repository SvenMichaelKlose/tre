(var *tagbody-replacements* nil)

(fn init-compiler-macros ()
  (= *tagbody-replacements* nil))

(var *compiler-macro-expander* (define-expander 'compiler
                                                :pre #'init-compiler-macros))

(defmacro def-compiler-macro (name args &body x)
  (print-definition `(def-compiler-macro ,name ,args))
  `(def-expander-macro *compiler-macro-expander* ,name ,args ,@x))

(fn compiler-macroexpand (x)
  (expander-expand *compiler-macro-expander* x))

(def-compiler-macro cond (&rest args)
  (with-compiler-tag end-tag
    `(%block
       ,@(+@ [with-compiler-tag next
               (when _.
                 `(,@(unless (eq t _.)
                       `((%= ,*return-id* ,_.)
                         (%go-nil ,next ,*return-id*)))
                   ,@(!? (wrap-atoms ._)
                         `((%= ,*return-id* (%block ,@!))))
                   (%go ,end-tag)
                   ,@(unless (eq t _.)
                       (list next))))]
             args)
       ,end-tag
       (identity ,*return-id*))))

(def-compiler-macro progn (&body body)
  (!? body
      `(%block
         ,@(wrap-atoms !))))

(def-compiler-macro setq (&rest args)
  `(%block
     ,@(@ [`(%= ,_. ,._.)]
          (group args 2))))

(def-compiler-macro ? (&body body)
  (with (tests (group body 2)
         end   (car (last tests)))
    (unless body
      (error "Body is missing."))
    `(cl:cond
       ,@(? .end
            tests
            (+ (butlast tests) (list (. t end)))))))


;; TAGBODY

(var *tagbody-expander* (define-expander 'tagbodyexpand))
(var *tagbody-replacements* nil)

(fn tag-replacement (tag)
  (cdr (assoc tag *tagbody-replacements* :test #'eq)))

(fn tagbodyexpand (body)
  (with-temporary *tagbody-replacements* nil
    (@ [? (atom _)
          (acons! _ (make-compiler-tag) *tagbody-replacements*)]
       body)
    `(%block
       ,@(@ [| (& (atom _)
                  (tag-replacement _))
               _]
            (expander-expand *tagbody-expander* body))
       (identity nil))))

(def-expander-macro *tagbody-expander* go (tag)
  (!? (tag-replacement tag)
      `(%go ,!)
      (error "Can't find tag ~A in TAGBODY." tag)))

(def-expander-macro *tagbody-expander* tagbody (&body body)
  (tagbodyexpand body))

(def-compiler-macro tagbody (&body body)
  (tagbodyexpand body))


;; BLOCK

(var *block-expander* (define-expander 'blockexpand))
(var *blocks* nil)

(fn blockexpand (name body)
  (? body
     (with-compiler-tag end-tag
       (with-temporary *blocks* (. (. name end-tag) *blocks*)
         (with (b     (expander-expand *block-expander* body)
                head  (butlast b)
                tail  (last b))
           `(%block
              ,@head
              ,@(? (some-%go? tail.)
                   tail
                   `((%= ,*return-id* ,@tail)))
              ,end-tag
              (identity ,*return-id*)))))
    `(identity nil)))

(def-expander-macro *block-expander* return-from (block-name expr)
  (| *blocks*
     (error "RETURN-FROM outside BLOCK."))
  (!? (assoc block-name *blocks* :test #'eq)
     `(%block
        (%= ,*return-id* ,expr)
        (%go ,.!))
     (error "RETURN-FROM unknown BLOCK ~A." block-name)))

(def-expander-macro *block-expander* block (name &body body)
  (blockexpand name body))

(def-compiler-macro block (name &body body)
  (blockexpand name body))
