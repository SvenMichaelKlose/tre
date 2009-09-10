;;;;; TRE compiler
;;;;; Copyright (C) 2006-2007,2009 Sven Klose <pixel@copei.de>

;;;; DEBUG PRINTERS

(defun print-funinfo (fi)
  (with-funinfo fi
    (format t "Arguments: ~A~%" args)
    (format t "Ghost sym: ~A~%" ghost)
    (format t "Env        ~A~%" env)
    (format t "Lexicals:  ~A~%" lexicals)
    (format t "Lexical sym: ~A~%" lexical)
    (format t "Free vars: ~A~%" free-vars)
    (format t "Used vars: ~A~%" used-env)
    (format t "-~%"))
  fi)

(defun print-funinfo-stack (fi)
  (when fi
    (print-funinfo fi)
    (print-funinfo-stack (funinfo-parent fi)))
  fi)
