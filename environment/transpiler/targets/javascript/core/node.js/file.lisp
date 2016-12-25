(defstruct nodejs-file
  fd-block
  fd-stream
  path
  flags
  mode
  (eof? nil))

(defun read-flags? (flags)
  (| (string? flags)
     (error "Flags for opening a file must be a string."))
  (== #\r (elt flags 0)))

(defun %fopen (path flags &optional (mode 438))
  (with (fd-block   (fs.open-sync path flags mode)
         options    (new :mode mode)
         fd-stream  (? (read-flags? flags)
                       (fs.create-read-stream path options)
                       (fs.create-write-stream path options)))
    (make-nodejs-file :fd-block   fd-block
                      :fd-stream  fd-stream
                      :path       path
                      :flags      flags
                      :mode       mode)))

(defun %fclose (fd)
  (fs.close-sync (nodejs-file-fd-block fd))
  (alet (nodejs-file-fd-stream fd)
    (? (defined? !.end)
       (!.end))))

(defun %force-output (fd)
  (fs.fflush-sync (nodejs-file-fd-block fd)))

(defun %feof (fd)
  (nodejs-file-eof? fd))

(defun %read-char (fd)
  (alet ((nodejs-file-fd-stream fd).read)
    (when (| (not !)
             (zero? !.length))
      (= (nodejs-file-eof? fd) t)
      (return))
    (aref ! 0)))
