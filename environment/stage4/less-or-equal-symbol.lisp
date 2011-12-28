;;;;; Caroshi - Copyright (c) 2011 Sven Michael Klose <pixel@copei.de>

(defun symbol<= (a b)
  (string<= (symbol-name a) (symbol-name b)))
