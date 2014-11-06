;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defstruct dirent
  name
  type
  permissions
  mode
  uid
  gid
  size
  atime
  mtime
  ctime
  symbolic-link?
  original
  list nil)
