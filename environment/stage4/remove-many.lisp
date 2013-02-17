;;;;; tré – Copyright (c) 2010,2013 Sven Michael Klose <pixel@copei.de>

(defun remove-many (items lst &key (test #'eql))
  (remove-if [member _ items :test test] lst))
