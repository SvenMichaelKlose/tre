;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;; Set argument definitions for functions in the first part.
(setf (slot-value ,(compiled-function-name not) 'tre-args) '(x))
(setf (slot-value ,(compiled-function-name cons) 'tre-args) '(x y))
(setf (slot-value ,(compiled-function-name symbol) 'tre-args) '(name))
