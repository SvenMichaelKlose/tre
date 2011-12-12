;;;;; tré - Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun transpiler-finalize-sexprs-fun (x)
  (transpiler-finalize-sexprs (lambda-body x)))

(metacode-walker transpiler-finalize-sexprs (x)
    :only-statements?		t
	:copy-function-heads?	t
	:if-atom				`(%%tag ,x)
	:if-function		    (transpiler-finalize-sexprs-fun x))
