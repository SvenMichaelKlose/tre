;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun path-unix-path (x)
  (? (fileurl? x)
	 (+ "file://" (subseq x 7))
	 x))

(defun path-url (schema x)
  (+ schema "://" path-unix-path x))
