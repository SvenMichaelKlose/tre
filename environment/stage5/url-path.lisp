(fn butlast-path-component (x)
  (pathlist-path (pad (butlast (path-pathlist x)) "/")))

(fn url-without-filename (x)
  (? x
     (butlast-path-component x)
     ""))

(fn url-schema (x)
  (car (path-pathlist x)))

(fn url-has-schema? (x)
  (alet (path-pathlist x)
    (& (tail? !. ":")
       (empty-string? .!.))))

(fn url-without-schema (x)
  (? (url-has-schema? x)
     (subseq x (+ 2 (length (url-schema x))))
     x))

(fn url-path (x)
  (pathlist-path (pad (cdr (path-pathlist (url-without-schema x))) "/")))

(fn url-without-path (x)
  (pathlist-path (pad (subseq (path-pathlist x) 0 3) "/")))
