(fn init-compiler-macros ()
  (= *tagbody-replacements* nil))

(var *compiler-macro-expander* (define-expander 'compiler
                                                :pre #'init-compiler-macros))

(defmacro def-compiler-macro (name args &body x)
  (print-definition `(def-compiler-macro ,name ,args))
  `(def-expander-macro *compiler-macro-expander* ,name ,args ,@x))

(fn compiler-macroexpand (x)
  (expander-expand *compiler-macro-expander* x))
