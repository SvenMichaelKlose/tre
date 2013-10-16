;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun metacode-function-name (x)
  (?
    (global-literal-function? x)  .x.
    (%%closure? x)                .x.
    (cons? x)                      x.
    x))
