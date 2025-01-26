(metacode-walker count-tags (x)
    :if-%tag
      (progn
        (++! (funinfo-num-tags *funinfo*))
        (… x.)))
