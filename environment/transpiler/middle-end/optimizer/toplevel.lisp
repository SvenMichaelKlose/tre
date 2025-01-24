(defmacro optimizer-pass (x)
  `[(dump-pass-head 'middleend ',x)
    (!= (,x _)
      (when (dump-pass-or-end? 'middleend ',x !)
        (print !))
      (dump-pass-tail 'middleend ',x !))])

(fn optimizer-passes ()
  (compose (optimizer-pass optimize-jumps)
           (optimizer-pass optimize-places)
           (optimizer-pass opt-peephole)
           (optimizer-pass optimize-tags)))

(fn optimize (statements)
  (with-global-funinfo
    (with-temporary *body* statements
      (optimize-funinfos (refine (optimizer-passes) statements)))))

(fn pass-opt-tailcall (x)
  (!= (opt-tailcall x)
    (? (equal ! x)
       !
       (optimize !))))
