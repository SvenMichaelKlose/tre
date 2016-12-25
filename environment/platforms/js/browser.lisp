(defun mozilla? ()  (< -1 (navigator.user-agent.index-of "Mozilla")))
(defun webkit? ()   (< -1 (navigator.user-agent.index-of "WebKit")))
(defun opera? ()    (< -1 (navigator.user-agent.index-of "Opera")))
(defun gecko? ()    (< -1 (navigator.user-agent.index-of "Gecko")))
(defun explorer? () (eql "Microsoft Internet Explorer" navigator.app-name))

