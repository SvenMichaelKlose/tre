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
  (list nil))
