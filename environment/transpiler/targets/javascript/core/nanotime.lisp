(fn nanotime ()     ; TODO: Use MILLISECONDS-SINCE-1970 instead.
  (* 1000 ((new *date).get-time)))
