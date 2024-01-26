(var *tre-path*)
(var *modules-path* ,*modules-path*)

(fn directory (pathname)
  (array-list (scandir pathname)))

(fn %force-output (&optional strm))
