(fn %load-launchfile ()
  (%start-core)
  (!? *launchfile*
      (load !))
  (read-eval-loop)
  (quit))

(fn dump-system (path)
  (print-note "Dumping environment to image '~A' ~F" path)
  (sys-image-create path #'%load-launchfile)
  (terpri))

(dump-system "image")
