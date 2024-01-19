(defbuiltin getenv (name)
  (sb-ext:posix-getenv name))

(defbuiltin arguments ()
  *POSIX-ARGV*)
