;;;; TRE environment
;;;; Copyright (C) 2005-2006,2010 Sven Klose <pixel@copei.de>
;;;;
;;;; Streams

(defstruct stream
  (handle nil) ; Interpreter file handle.

  fun-in       ; User-defined input function.
  fun-out
  fun-eof

  (last-char	nil)
  (peeked-char	nil)

  (user-detail nil))
