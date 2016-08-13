; tré – Copyright (c) 2014,2016 Sven Michael Klose <pixel@copei.de>

(defvar *debugger-window* nil)
(defvar *debugger-window-style* ,(fetch-file "environment/debugger/style.css"))

(defun open-debugger-window ()
  (unless *debugger-window*
    (= *debugger-window* (window.open "" "debugger" "width=640, height=480, scrollbars=yes"))
    (alet *debugger-window*.document
      (document-extend !)
      (*event-manager*.init-document !)
      (= !.title "tré debugger")
      (lml2dom !.head `(style ,*debugger-window-style*)))))
