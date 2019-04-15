(%defvar *definition-printer* #'print)

(%fn print-definition (x)
  (? *print-definitions?*
     (apply *definition-printer* (list x))))
