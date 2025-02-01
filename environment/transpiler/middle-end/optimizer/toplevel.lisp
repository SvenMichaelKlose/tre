(defmacro optimizer-pass (x)
  `[(dump-pass-head 'middleend ',x _)
    (aprog1 (,x _)
      (dump-pass-tail 'middleend ',x !))])

(fn optimizer-passes ()
  (compose (optimizer-pass optimize-jumps)
           (optimizer-pass optimize-places)
           (optimizer-pass opt-peephole)
           (optimizer-pass optimize-tags)
           (optimizer-pass remove-spare-tags)))

(fn optimize (statements)
  (with-temporary *body* statements
    (optimize-funinfos (refine (optimizer-passes) statements))))
