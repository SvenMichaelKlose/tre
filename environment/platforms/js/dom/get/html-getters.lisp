;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(mapcar-macro _
    '(html head title link ielink
      body
      ul ol li
      form input textarea select option
      a img)
  `(define-element-getters :name ,($ _ '-element) :tag ,(string-downcase (symbol-name _))))
