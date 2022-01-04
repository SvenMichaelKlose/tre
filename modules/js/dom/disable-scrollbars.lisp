(fn disable-scrollbars (&optional (win window))
  (win.document.body.set-style "overflow" "hidden")
  (let doc win.document
    (& doc.body.scroll
       (= doc.body.scroll "no"))))

(fn enable-scrollbars (&optional (win window))
  (win.document.body.set-style "overflow" "visible")
  (let doc win.document
    (& doc.body.scroll
       (= doc.body.scroll "yes"))))
