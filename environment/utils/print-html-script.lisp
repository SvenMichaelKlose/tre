(fn print-html-script (out script &key (title nil)
                                       (no-cache? nil)
                                       (copyright nil) (copyright-href nil)
                                       (external-script nil)
                                       (external-stylesheets nil)
                                       (internal-stylesheet nil)
                                       (body nil))
  (with-default-stream o out *standard-output*
    (format o "<!doctype html>~%")
    (lml2xml `(html
                (head
                  (title ,title)
                  (meta :charset "utf-8")
                  ,@(& no-cache?
                       `((meta :http-equiv "pragma" :content "no-cache")))
                  ,@(& (| copyright
                          copyright-href)
                       `((link :rel "copyright"
                               ,@(!? copyright
                                     `(:title ,(escape-string !)))
                               ,@(!? copyright-href
                                     `(:href  ,(escape-string !))))))
                  ,@(!? external-stylesheets
                        (+@ [`(link :rel "stylesheet" :type "text/css"
                                    :href ,_)]
                            (ensure-list !)))
                  ,@(!? internal-stylesheet
                        `((style ,!)))
                  ,@(!? external-script
                        (+@ [`((script :src ,_ ""))]
                            (ensure-list !))))
                (body
                  ,@body
                  (script ,script)))
             o)))

(fn keyword-copiers (&rest x)
  (+@ [list (make-keyword _) (make-symbol (symbol-name _))] x))

(fn make-html-script (pathname script &key (title nil)
                                           (no-cache? nil)
                                           (copyright nil) (copyright-href nil)
                                           (external-script nil)
                                           (external-stylesheets nil)
                                           (internal-stylesheet nil)
                                           (body nil))
  (with-output-file o pathname
    (print-html-script o script ,@(keyword-copiers :title :no-cache?
                                                   :copyright :copyright-href
                                                   :external-script
                                                   :external-stylesheets
                                                   :internal-stylesheet
                                                   :body))))
