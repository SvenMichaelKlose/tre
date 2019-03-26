; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defbuiltin sys-image-create (pathname fun)
  (sb-ext:save-lisp-and-die pathname
                            :toplevel (lambda ()
                                        (cl:funcall fun))))

(defbuiltin %start-core ()
  (setq *launchfile* (cadr (| sb-ext:*posix-argv*
;                             #+SBCL sb-ext:*posix-argv*
;                             #+LISPWORKS system:*line-arguments-list*
;                             #+CMU extensions:*command-line-words*
                             nil))))
