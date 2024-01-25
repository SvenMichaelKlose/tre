(var *tre-path*)

(fn directory (pathname)
  (phparray-list (scandir pathname)))

(fn %force-output (&optional strm))
