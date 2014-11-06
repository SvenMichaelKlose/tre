;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defconstant *stat-types* '(unknown
                            fifo
                            char-special
                            multiplexed-char-special
                            directory
                            named-special
                            block-special
                            multiplexed-block-special
                            regular
                            compressed
                            network-special
                            symbolic-link
                            shadow-indoe
                            socket
                            door
                            whiteout))

(defun stat (pathname)
  (alet (%stat pathname)
    (& (number? !)
       (error (%strerror !)))
    (list (. 'type     (elt *stat-types* (>> ..!. 12)))
          (. 'perm     (bit-and (>> ..!. 6) 511))
          (. 'sticky   (not (zero? (bit-and (>> ..!. 9) 1))))
          (. 'dev      !.)
          (. 'inode    .!.)
          (. 'mode     ..!.)
          (. 'nlink    ...!.)
          (. 'uid      ....!.)
          (. 'gid      .....!.)
          (. 'rdev     ......!.)
          (. 'size     .......!.)
          (. 'blksize  ........!.)
          (. 'blocks   .........!.)
          (. 'atime    ..........!.)
          (. 'mtime    ...........!.)
          (. 'ctime    ............!.))))
