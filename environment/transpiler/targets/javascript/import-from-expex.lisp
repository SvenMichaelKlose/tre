;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun js-setter-filter (x)
  (& (funinfo-global-variable? *funinfo* .x.)
     (transpiler-add-wanted-variable *transpiler* .x.))
  (list x))

(defun js-argument-filter (x)
  (& (atom x)
     (funinfo-global-variable? *funinfo* x)
     (transpiler-add-wanted-variable *transpiler* x))
  (? (global-literal-function? x)
     `(symbol-function (%quote ,.x.))
     x))
