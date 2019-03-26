;;;;; Caroshi – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate navigator user-agent index-of app-name)

(defun mozilla? ()  (< -1 (navigator.user-agent.index-of "Mozilla")))
(defun webkit? ()   (< -1 (navigator.user-agent.index-of "WebKit")))
(defun opera? ()    (< -1 (navigator.user-agent.index-of "Opera")))
(defun gecko? ()    (< -1 (navigator.user-agent.index-of "Gecko")))
(defun explorer? () (== "Microsoft Internet Explorer" navigator.app-name))
