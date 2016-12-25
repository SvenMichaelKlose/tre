(defbuiltin sh (program &rest arguments)
  (sb-ext:run-program program arguments :pty cl:*standard-output*))

(defbuiltin unix-sh-cp (from to &key (verbose? nil) (recursively? nil))
  (apply #'sh "/bin/cp" `(,@(? verbose?     '("-v"))
                          ,@(? recursively? '("-r"))
                          ,from
                          ,to)))

(defbuiltin unix-sh-mkdir (pathname &key (parents nil))
  (apply #'sh "/bin/mkdir" `(,@(? parents '("-p")) ,pathname)))

(defbuiltin unix-sh-rm (x &key (verbose? nil) (recursively? nil) (force? nil))
  (apply #'sh "/bin/rm" `(,@(? verbose?     '("-v"))
                          ,@(? recursively? '("-r"))
                          ,@(? force?       '("-f"))
                          ,x)))

; TODO Implement NANOTIME.
(defbuiltin nanotime () 0)
