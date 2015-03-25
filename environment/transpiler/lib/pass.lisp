; tré – Copyright (c) 2010–2015 Sven Michael Klose <pixel@hugbox.org>

(defun sloppy-equal (x needle)
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

(defun sloppy-tree-equal (x needle)
  (| (sloppy-equal x needle)
     (& (cons? x)
        (| (sloppy-tree-equal x. needle)
           (sloppy-tree-equal .x needle)))))

(defun dump-pass? (name x)
  (& *transpiler*
     (| (!? (dump-passes?)
            (| (t? !)
               (member name (ensure-list !))))
        (!? (dump-selector)
            (sloppy-tree-equal x !)))))

(defun transpiler-pass (x i)
  (aprog1 (with-global-funinfo (funcall .i x)))
    (when (dump-pass? i. !)
      (? (equal ! (last-pass-result))
         (format t "; Pass ~A outputs no difference to previous dump.~%" i.)
         (format t (+ "~L; **** Dump of pass ~A:~%"
                      "~A"
                      "~L; **** End of ~A.~%")
                   i. ! i.))))

(defmacro transpiler-end (name &rest name-fun-pairs)
  (print-definition `(transpiler-end ,name))
  `(defun ,name (x)
     (| (enabled-end? ,(make-keyword name))
        (return x))
     (& (t? (dump-passes?))
        (format t "~%~L; #### Compiler end ~A~%~%" ',name))
     (@ [with (outpass  (cdr (assoc ,(make-keyword name) (output-passes)))
               out      nil)
          (@ (i
              (list ,@(@ [`(. ,(make-keyword _.) ,._.)]
                         (group name-fun-pairs 2)))
              out)
            (= (last-result) (transpiler-pass _ i))
            (& (eq i. outpass)
               (= out (last-result))))]
        x)))
