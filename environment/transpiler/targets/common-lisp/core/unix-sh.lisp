; tré – Copyright (c) 2015 Sven Michael Klose <pixel@copei.de>

(defbuiltin sh (program &rest arguments)
  (sb-ext:run-program program arguments :pty cl:*standard-output*))

(defbuiltin unix-sh-cp (from to &key (verbose? nil) (recursively? nil))
  (apply #'sh "/bin/cp" `(,@(? verbose?     '("-v"))
                          ,@(? recursively? '("-r"))
                          ,from
                          ,to)))

; TODO Implement NANOTIME.
(defbuiltin nanotime () 0)
