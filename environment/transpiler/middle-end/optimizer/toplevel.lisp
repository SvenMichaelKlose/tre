;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun optimizer-passes ()
  (compose #'optimize-jumps
           #'optimize-places
           #'opt-peephole
           #'optimize-tags))

(defun optimize (statements)
  (? *opt-peephole?*
     (with-temporaries (*funinfo* (transpiler-global-funinfo *transpiler*)
                        *body*    statements)
       (aprog1
         (repeat-while-changes (optimizer-passes) statements)
         (optimize-funinfos !)))
     statements))
