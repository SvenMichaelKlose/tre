(defun %load-launchfile ()
  (%start-core)
  (awhen *launchfile*
    (load !))
  (read-eval-loop)
  (quit))

(defun dump-system (path)
  (print-note "; Dumping environment to image '~A' ~F" path)
  (sys-image-create path #'%load-launchfile)
  (fresh-line))

(dump-system "image")
