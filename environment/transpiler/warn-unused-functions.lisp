(fn warn-unused-functions ()
  (!= (defined-functions)
    (@ [hremove ! _]
       (+ (hashkeys (used-functions))
          (hashkeys (expander-macros (transpiler-macro-expander)))
          (hashkeys (expander-macros (codegen-expander)))
          *macros*))
    (@ [!= (symbol-name _)
         (| (tail? ! "_TREEXP")
            (head? ! "~")
            (warn "Unused function ~A." _))]
       (hashkeys !))))
