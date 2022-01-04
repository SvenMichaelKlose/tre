(document-extend)

(fn fire-event (elm typ)
  (!= (document.create-event "HTMLEvents")
    (!.init-event typ t t)
    (= !.event-name typ)
    (elm.dispatch-event !)))

(fn fire-mousemove-event ()
  (!? *last-hovered*
    (fire-event ! "mousemove")))

(fn fire-document-modified-event (elm)  ; TODO: What's "elm" for?
  (fire-event elm "document-modified"))

(fn fire-text-modified-event (elm)
  (fire-event elm "text-modified"))

(fn force-mousemove-event ()
  (do-wait 1
    (fire-mousemove-event)))

(fn event-left-button? e
  (== e.button 1))

(fn event-right-button? e
  (!= e.button 1))
