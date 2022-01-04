(fn session-create ()
  (session_start))

(fn session-has-item? (name)
  (& (read-session name)
     t))

(fn read-session (name)
  (? (%aref-defined? *_session* name)
     (%aref *_session* name)))

(fn write-session (name val)
  (=-%aref val *_session* name))
