;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Standard streams

(defun make-standard-stream ()
  (make-stream :fun-in #'((str) (%read-char nil))
	       :fun-out #'((c str) (%princ c nil))
	       :fun-eof #'((str) (%feof nil))))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input* (make-standard-stream))
