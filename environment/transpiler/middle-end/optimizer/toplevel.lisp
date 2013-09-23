;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun optimize (statements)
  (? *opt-peephole?*
     (with-temporaries (*funinfo* (transpiler-global-funinfo *transpiler*)
                        *body*    statements)
       (repeat-while-changes (compose #'optimize-jumps
                                      #'optimize-places
                                      #'opt-peephole
                                      #'optimize-tags)
                             statements))
     statements))
