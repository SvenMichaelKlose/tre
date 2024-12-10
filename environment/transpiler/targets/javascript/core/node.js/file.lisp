(defstruct nodejs-file
  fd-block
  fd-stream
  path
  flags
  mode
  (eof? nil))

(fn read-flags? (flags)
  (| (string? flags)
     (error "Flags for opening a file must be a string."))
  (== #\r (elt flags 0)))

(fn %fopen (path flags &optional (mode 438))
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

(fn %fclose (fd)
  (fs.close-sync (nodejs-file-fd-block fd))
  (!= (nodejs-file-fd-stream fd)
    (? (defined? !.end)
       (!.end))))

(fn %force-output (fd)
  (fs.fflush-sync (nodejs-file-fd-block fd)))

(fn %feof (fd)
  (nodejs-file-eof? fd))

(fn %read-char (fd &optional (eof nil))
  (!= ((nodejs-file-fd-stream fd).read)
    (? (| (not !)
          (== 0 !.length))
       eof
       (aref ! 0))))
