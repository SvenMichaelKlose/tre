; tré – Copyright (c) 2005–2015 Sven Michael Klose <pixel@hugbox.org>

; !!! This is just preparing the launch of
; !!! "environment/transpiler/targets/common-lisp" and
; !!! "makefiles/boot-common.lisp".

(defun tre-expansions (x)
  (quote-expand (quasiquote-expand (macroexpand (dot-expand x)))))
(defun expr2cl (x)                 (make-lambdas (tre-expansions x)))
(defun file2cl (pathname)          (expr2cl (read-file pathname)))
(defun files2cl (&rest pathnames)  (. 'progn (mapcan #'file2cl pathnames)))

(defun generate-cl-core ()
  (with-output-file o "cl/generated-from-environment.lisp"
    (adolist (`((in-package :tre-parallel)
                ,@(expr2cl (cdr (read-file "cl/user.lisp")))
                ,@(files2cl "environment/stage0/functional.lisp"
                            "environment/stage0/print-definition.lisp"
                            "environment/stage0/quasiquote.lisp"
                            "environment/stage0/primitive-lib.lisp"
                            "environment/stage1/funcall.lisp"
                            "environment/stage1/cons.lisp"
                            "environment/stage1/equal.lisp"
                            "environment/stage1/comparison-c.lisp"
                            "environment/stage1/predicates.lisp"
                            "environment/stage1/nconc.lisp"
                            "environment/stage1/append.lisp"
                            "environment/stage1/queue.lisp"
                            "environment/stage1/math.lisp"
                            "environment/stage1/fn.lisp"
                            "environment/stage1/butlast.lisp"
                            "environment/stage2/values.lisp"
                            "environment/stage2/range.lisp"
                            "environment/stage2/char.lisp"
                            "environment/stage2/char-predicates.lisp"
                            "environment/stage2/string.lisp"
                            "environment/stage2/list-symbol.lisp"
                            "environment/stage2/subseq.lisp"
                            "environment/stage2/subseq-c.lisp"
                            "environment/stage2/search-sequence.lisp"
                            "environment/stage2/dot-expand.lisp"
                            "environment/stage3/memorized-number.lisp"
                            "environment/stage3/terpri.lisp"
                            "environment/stage3/line.lisp"
                            "environment/stage3/stream.lisp"
                            "environment/stage3/read-char.lisp"
                            "environment/stage3/default-stream.lisp"
                            "environment/stage3/string-stream.lisp"
                            "environment/stage3/stream-stream.lisp"
                            "environment/stage3/open.lisp"
                            "environment/stage3/princ.lisp"
                            "environment/stage4/split.lisp"
                            "environment/stage3/read-number.lisp"
                            "environment/stage3/read.lisp"
                            "cl/load.lisp")))
    (unless (eq 'progn !)
      (late-print ! o)))))

(generate-cl-core)
