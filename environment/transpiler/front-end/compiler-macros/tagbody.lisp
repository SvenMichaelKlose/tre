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
