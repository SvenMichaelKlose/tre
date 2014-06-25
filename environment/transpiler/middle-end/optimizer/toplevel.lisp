;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun optimizer-passes ()
  (compose #'optimize-jumps
           #'optimize-places
           #'opt-peephole
           #'optimize-tags))

(defun optimize (statements)
  (? *opt-peephole?*
     (with-temporaries (*funinfo* (transpiler-global-funinfo *transpiler*)
                        *body*    statements)
       (optimize-funinfos (repeat-while-changes (optimizer-passes) statements)))
     statements))
