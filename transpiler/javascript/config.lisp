;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defun js-setf-functionp (x)
  (or (%setf-functionp x)
      (assoc x (transpiler-function-args *js-transpiler*))))

(defun js-transpiler-make-label (x)
  (format nil "case ~A:~%" (transpiler-symbol-string *js-transpiler* x)))

(defun make-javascript-transpiler (obfuscate?)
  (create-transpiler
	:std-macro-expander 'js-alternate-std
	:macro-expander 'javascript
	:setf-functionp #'js-setf-functionp
	:separator (format nil ";~%")
	:unwanted-functions '(cons car cdr make-hash-table map symbolp ;error
						  string-concat
						  number+ + number- -
						  ;$
						  href %%usetf-href %%usetf-elt
						  wait
						  new %new %slot-value %%usetf-%slot-value ; environment/oo/ducktype.lisp
						 )
	:obfuscate? obfuscate?

	:obfuscation-exceptions
	  '(function
		fun hash class

		; JavaScript core
		apply length push shift unshift

		; DOM
		document cursor style element 
		client-left client-top
		scroll-left scroll-top
		offset-left offset-top
		offset-width offset-height
		offset-parent
		page-x page-y
		body
		window open title close

		node-name
		node-type
		node-value
		tag-name
		child-nodes
		first-child
		has-child-nodes
		last-child
		next-sibling
		parent-node
		previous-sibling
		source-index
		data
		attributes
		name
		value
		document-element

		append-child
		clone-node
		insert-before
		remove-child
		replace-child
		append-data
		delete-data
		insert-data
		replace-data
		substring-data
		create-attribute
		get-attribute-node
		get-attribute
		has-attribute	; not in IE
		has-attributes	; not in IE
		remove-attribute
		remove-attribute-node
		set-attribute
		set-attribute-node
		contains	; not in FF
		create-document
		create-document-fragment
		get-elements-by-name ; only FF and Safari
		has-feature
		is-supported ; not in IE
		item
		normalize
		owner-document
		split-text

		create-element
		create-text-node
		get-element-by-id
		get-element-by-class-name
		get-element-by-tag-name
		query-selector-all

		get-computed-style
		default-view
		width
		heigth

		; Event
		client-x client-y
		add-event-listener
		attach-event
		dispatch-event
		remove-event-listener
		detach-event
		prevent-default
		stop-propagation
		type button char-code key-code target
		cancel-bubble return-value)

	:identifier-char?
	  #'((x)
		  (or (and (>= x #\a) (<= x #\z))
		  	  (and (>= x #\A) (<= x #\Z))
		  	  (and (>= x #\0) (<= x #\9))
			  (in=? x #\_ #\. #\$ #\#)))
	:make-label
	  #'js-transpiler-make-label))

(defvar *js-transpiler* (make-javascript-transpiler nil))
(defvar *js-separator* (transpiler-separator *js-transpiler*))
