(%defvar *definition-printer* #'print)

(%defun print-definition (x)
  (? *print-definitions?*
     (apply *definition-printer* (list x))))
