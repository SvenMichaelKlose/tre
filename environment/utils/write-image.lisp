(fn %load-launchfile ()
  (%start-core)
  (!= (getenv "TRE_PATH")
    (= *tre-path* !))
  (= *modules-path* (+ *tre-path* "/modules/"))
  (!? *launchfile*
      (load !))
  (read-eval-loop)
  (quit))

(fn dump-system (path)
  (print-note "Dumping environment to image '~A' ~%" path)
  (sys-image-create path #'%load-launchfile))
