; tré – Copyright (c) 2016 Sven Michael Klose <pixel@hugbox.org>

(defstruct wavinfo
  file-size
  format-tag
  channels
  sample-rate
  bytes-second
  block-align
  bits
  data-size)

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
    (= (wavinfo-sample-rate !) (read-dword i))
    (= (wavinfo-bytes-second !) (read-dword i))
    (= (wavinfo-block-align !) (read-word i))
    (= (wavinfo-bits !) (read-word i))
    (| (equal "data" (read-chars i 4))
       (error "data signature missing."))
    (= (wavinfo-data-size !) (read-dword i))))
