(defbuiltin sys-image-create (pathname fun)
  (SB-EXT:SAVE-LISP-AND-DIE pathname
                            :TOPLEVEL (lambda ()
                                        (CL:FUNCALL fun))))

(defbuiltin %start-core ()
  (CL:USE-PACKAGE :tre)
  (setq *launchfile* (cadr (| SB-EXT:*POSIX-ARGV*
;                             #+SBCL SB-EXT:*POSIX-ARGV*
;                             #+LISPWORKS SYSTEM:*LINE-ARGUMENTS-LIST*
;                             #+CMU EXTENSIONS:*COMMAND-LINE-WORDS*
                             nil))))
