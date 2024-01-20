(fn directory (pathname)
  (array-list (fs.readdir-sync pathname)))
