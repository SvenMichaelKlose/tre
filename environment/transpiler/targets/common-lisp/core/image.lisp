; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

(defbuiltin sys-image-create (pathname fun)
  (sb-ext:save-lisp-and-die pathname
                            :toplevel (lambda ()
                                        (cl:in-package :tre)
                                        (cl:funcall fun))
                            :purify t))

(defbuiltin %start-core ()
  (setf *launchfile* (cadr (| sb-ext:*posix-argv*
;                             #+SBCL sb-ext:*posix-argv*
;                             #+LISPWORKS system:*line-arguments-list*
;                             #+CMU extensions:*command-line-words*
                             nil))))
