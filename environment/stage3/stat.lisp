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
  (let original (readlink pathname)
    (when (& original (not (file-exists? original)))
      (return (make-dirent :type 'symbolic-link
                           :original original)))
    (alet (%stat pathname)
      (& (number? !)
         (error (%strerror !)))
      (make-dirent :type            (elt *stat-types* (>> ..!. 12))
                   :permissions     (bit-and (>> ..!. 6) 511)
                   :mode            ..!.
                   :uid             ....!.
                   :gid             .....!.
                   :size            .......!.
                   :atime           ..........!.
                   :mtime           ...........!.
                   :ctime           ............!.
                   :symbolic-link?  (? original t nil)
                   :original        original))))
