;;;; tré – Copyright (c) 2005–2006,2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *default-stream-tabsize* 8)

(defstruct stream
  (handle nil)

  fun-in
  fun-out
  fun-eof

  (last-char	nil)
  (peeked-char	nil)

  (track-input-location?  t)
  (in-id        nil)
  (in-line      1)
  (in-column    1)
  (in-tabsize   *default-stream-tabsize*)

  (track-output-location? nil)
  (out-line     1)
  (out-column   1)

  (user-detail nil))

(defun next-tabulator-column (column size)
  (++ (* size (++ (integer (/ (-- column) size))))))

(defun %stream-track-input-location (str x)
  (when (stream-track-input-location? str)
    (? (string? x)
       (adolist ((string-list x))
         (%stream-track-input-location str !))
       (? (== 10 x)
          (progn
            (= (stream-in-column str) 1)
            (++! (stream-in-line str)))
          (?
            (== 9 x) (= (stream-in-column str) (next-tabulator-column (stream-in-column str) (stream-in-tabsize str)))
            (< 31 x) (++! (stream-in-column str))))))
  x)
