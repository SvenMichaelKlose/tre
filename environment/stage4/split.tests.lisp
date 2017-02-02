(define-test "SPLIT works on string"
  ((let x (split #\/ "foo/bar")
	 (& (string== "foo" x.)
	    (string== "bar" .x.)
	    (not ..x))))
  t)

(define-test "SPLIT works on string with gaps"
  ((let x (split #\/ "file:///home/pixel/foo//bar")
     x
	 t))
  t)
