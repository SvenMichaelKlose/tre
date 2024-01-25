(var *tre-path*)
(var *modules-path* ,*modules-path*)

(fn directory (pathname)
  (phparray-list (scandir pathname)))

(fn %force-output (&optional strm))
