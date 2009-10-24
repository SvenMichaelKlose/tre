;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Stubs for missing file support

(defun open (path &key direction)
  (alert "OPEN is unsupported"))

(defun close (str)
  (%fclose (stream-handle str)))
