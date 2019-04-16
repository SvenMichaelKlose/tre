(fn empty-string? (&rest x)
  (every [& (string? _)
            (string== "" (| (trim _ " " :test #'string==) ""))] x))

(fn empty-string-or-nil? (x)
  (| (not x)
     (& (string? x)
        (string== "" x))))
