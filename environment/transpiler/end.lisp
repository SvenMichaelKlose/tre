(fn sloppy-equal (x needle)
  (& (atom x)
     (atom needle)
     (return (eql x needle)))
  (& (cons? x)
     (not needle)
     (return t))
  (& (cons? x)
     (cons? needle)
     (equal x. needle.)
     (sloppy-equal .x .needle)))

(fn sloppy-tree-equal (x needle)
  (| (sloppy-equal x needle)
     (& (cons? x)
        (| (sloppy-tree-equal x. needle)
           (sloppy-tree-equal .x needle)))))

(fn dump-pass? (pass-or-end x)
   (| (!? (dump-passes?)
          (| (eq t !)
             (member pass-or-end (ensure-list !))))
      (!? (dump-selector)
          (sloppy-tree-equal x !))))

(fn dump-pass-or-end? (end pass x)
  (| (dump-pass? pass x)
     (dump-pass? end x)))

(fn dump-pass-head (end pass x)
  (when (dump-pass-or-end? end pass x)
    (format t "; >>>> Dump of ~A/~A:~%"
            (symbol-name end)
            (symbol-name pass))
    (cl:in-package :tre)
    (print x)))

(fn dump-pass-tail (end pass x)
  (when (dump-pass-or-end? end pass x)
    (cl:in-package :tre)
    (? (equal x (last-pass-result))
       (format t "; Nothing changed.~%" pass)
       (print x))
    (format t "~F; <<<< End of ~A/~A.~%"
            (symbol-name end)
            (symbol-name pass))))

(fn transpiler-pass (pass-fun x)
  (with-global-funinfo (~> pass-fun x)))

(fn transpiler-end (end passes x)
  (unless (enabled-end? end)
    (return x))
  (when x
    ; Keep result of dedicated output pass.  More passes may
    ; follow just for user-friendly, early bug detection.
    ; If there's no dedicated output pass, the last one gives
    ; the result.
    (with (outpass         (cdr (assoc end (output-passes)))
           outpass-result  nil)
      (@ (pass passes)
        (when (enabled-pass? pass.)
          (dump-pass-head end pass. x)
          (= x (transpiler-pass .pass x))
          (dump-pass-tail end pass. x)
          (= (last-pass-result) x)
          (& (eq pass. outpass)
             (= outpass-result x))))
      (? outpass
         outpass-result
         x))))

(defmacro define-transpiler-end (end &rest name-function-pairs)
  (!= (group name-function-pairs 2)
    `(fn ,(make-symbol (symbol-name end)) (list-of-exprs)
       (transpiler-end ,end
                       (… ,@(@ [`(. ,@_)]
                               (pairlist (@ #'make-keyword (carlist !))
                                         (cdrlist !))))
                       list-of-exprs))))
