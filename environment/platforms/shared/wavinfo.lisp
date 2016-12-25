(defstruct wavinfo
  file-size
  format-tag
  channels
  rate
  bytes-second
  (block-align 1)
  bits
  data-size)

(def-wavinfo write-wavinfo (wavinfo size o)
  (princ "RIFF" o)
  (alet (with-string-stream o
          (alet (with-string-stream o
                  (write-word format-tag o)
                  (write-word channels o)
                  (write-dword rate o)
                  (write-dword (/ (* rate bits) 8) o)
                  (write-word block-align o)
                  (write-word bits o))
            (princ "WAVEfmt " o)
            (write-dword (length !) o)
            (princ ! o)))
    (write-dword (+ 16 (length !) size) o)
    (princ ! o))
  (princ "data" o)
  (write-dword size o))

(defun read-wavinfo (i)
  (aprog1 (make-wavinfo)
    (| (equal "RIFF" (read-chars i 4))
       (error "RIFF signature missing."))
    (= (wavinfo-file-size !) (read-dword i))
    (| (equal "WAVEfmt " (read-chars i 8))
       (error "'WAVEfmt ' signature missing."))
    (read-dword i) ; Rest of header size.
    (= (wavinfo-format-tag !) (read-word i))
    (= (wavinfo-channels !) (read-word i))
    (= (wavinfo-rate !) (read-dword i))
    (= (wavinfo-bytes-second !) (read-dword i))
    (= (wavinfo-block-align !) (read-word i))
    (= (wavinfo-bits !) (read-word i))
    (| (equal "data" (read-chars i 4))
       (error "data signature missing."))
    (= (wavinfo-data-size !) (read-dword i))))
