;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Streams

(defstruct stream
  handle       ; Interpreter file handle.
  fun-in       ; User-defined input function.
  fun-out
  fun-eof
  user-detail

  last-char
  peeked-char)
