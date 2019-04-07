(defmacro optimizer-pass (x)
  `[dump-pass 'middleend ',x (,x _)])

(fn optimizer-passes ()
  (compose (optimizer-pass optimize-jumps)
           (optimizer-pass optimize-places)
           (optimizer-pass opt-peephole)
           (optimizer-pass optimize-tags)))

(fn optimize (statements)
  (with-global-funinfo
    (with-temporary *body* statements
      (optimize-funinfos (repeat-while-changes (optimizer-passes) statements)))))

(fn pass-opt-tailcall (x)
  (!= (opt-tailcall x)
    (? (equal ! x)
       !
       (optimize !))))
