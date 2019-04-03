(defmacro optimizer-pass (x)
  `[dump-pass 'middleend ',x (,x _)])

(fn optimizer-passes ()
  (compose (optimizer-pass optimize-jumps)
           (optimizer-pass optimize-places)
           (optimizer-pass opt-peephole)
           (optimizer-pass optimize-tags)))

(fn optimize (statements)
  (? *opt-peephole?*
     (with-temporaries (*funinfo* (global-funinfo)
                        *body*    statements)
       (optimize-funinfos (repeat-while-changes (optimizer-passes) statements)))
     statements))

(fn pass-optimize (x)
  (? (enabled-pass? :inject-debugging)
     x
     (optimize x)))

(fn pass-opt-tailcall (x)
  (? (enabled-pass? :inject-debugging)
     x
     (!= (opt-tailcall x)
       (? (equal ! x)
          !
          (optimize !)))))
