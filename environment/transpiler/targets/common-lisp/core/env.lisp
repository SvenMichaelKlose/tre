(defbuiltin getenv (name)
  (sb-ext:posix-getenv name))
