;;;; nix operating system project
;;;; list processor environment
;;;; Copyright 2006 (C) Sven Klose <pixel@copei.de>

(defmacro loop (&rest body)
  (let ((tag (gensym)))
    `(tagbody
       ,tag
       ,@body
       (go ,tag))))
