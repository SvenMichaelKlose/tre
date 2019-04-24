(defbuiltin sys-image-create (pathname fun)
  (sb-ext:save-lisp-and-die pathname
                            :toplevel (lambda ()
                                        (cl:funcall fun))))

(defbuiltin %start-core ()
  (cl:use-package :tre)
  (setq *launchfile* (cadr (| sb-ext:*posix-argv*
;                             #+SBCL sb-ext:*posix-argv*
;                             #+LISPWORKS system:*line-arguments-list*
;                             #+CMU extensions:*command-line-words*
                             nil))))
