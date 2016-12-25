(defbuiltin %princ (x stream)
  (alet (| stream cl:*standard-output*)
    (?
      (character? x)  (cl:write-byte (cl:char-code x) !)
      (string? x)     (dosequence (i x)
                        (%princ i !))
      (cl:princ x !))))

(defbuiltin %force-output (stream) (cl:force-output stream))

(defbuiltin %fopen (pathname mode)
  (cl:open pathname
           :direction (? (cl:find #\w mode :test #'cl:equal)
                         :output
                         :input)
           :if-exists :supersede
           :element-type '(cl:unsigned-byte 8)))

(defbuiltin %fclose (stream) (cl:close stream))

(defbuiltin %read-char (str)
  (alet (cl:read-byte (| str cl:*standard-input*) nil 'eof)
    (unless (eq ! 'eof)
      (cl:code-char !))))

(defbuiltin file-exists? (pathname)
  (? (cl:probe-file pathname)
     t))
