(fn print-html-script (out script &key (title nil)
                                       (no-cache? nil)
                                       (strict? t)
                                       (copyright-title nil) (copyright-href nil)
                                       (external-script nil)
                                       (external-stylesheets nil)
                                       (internal-stylesheet nil)
                                       (body nil))
  (with-default-stream o out
    (format o (+ (doctype-html-5) "~%"))
    (lml2xml `(html
                (head
                  (title ,title)
                  (meta :http-equiv "Content-Type" :content "text/html; charset=utf-8")
                  ,@(& no-cache?
                       `((meta :http-equiv "pragma" :content "no-cache")))
                  ,@(& (| copyright-title
                          copyright-href)
                       `((link :rel "copyright"
                               ,@(!? copyright-title
                                     `(:title ,(escape-string !)))
                               ,@(!? copyright-href
                                     `(:href  ,(escape-string !))))))
                  ,@(!? external-stylesheets
                        (mapcan [`(link :rel "stylesheet" :type "text/css" :href ,_)]
                                (ensure-list !)))
                  ,@(!? internal-stylesheet
                        `((style ,!)))
                  ,@(!? external-script
                        (mapcan [`((script :src ,_ ""))] (ensure-list !))))
                (body
                  ,@body
                  (script :type "text/javascript"
                    "<!--"
                    ,@(& strict?
                         `("\"use strict\";"))
                    ,script
                    "//-->")))
             o)))

(fn make-html-script (pathname script &key (title nil)
                                           (no-cache? nil)
                                           (strict? t)
                                           (copyright-title nil) (copyright-href nil)
                                           (external-script nil)
                                           (external-stylesheets nil)
                                           (internal-stylesheet nil)
                                           (body nil))
  (with-output-file o pathname
    (print-html-script o script ,@(keyword-copiers :title :no-cache? :strict?
                                                   :copyright-title :copyright-href
                                                   :external-script
                                                   :external-stylesheets
                                                   :internal-stylesheet
                                                   :body))))
