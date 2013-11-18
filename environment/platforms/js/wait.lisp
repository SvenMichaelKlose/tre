;;;;; tré – Copyright (c) 2008,2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate clear-timeout set-timeout)

(defun wait (fun millisecs)
  (with (timeout-id nil
		 our-fun    #'(()
				         (window.clear-timeout timeout-id)
					     (funcall fun)))
    (= timeout-id (window.set-timeout our-fun millisecs))))
