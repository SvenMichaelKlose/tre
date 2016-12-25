(dont-obfuscate
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
	get-elements-by-class-name
	get-elements-by-tag-name
	query-selector-all

	get-computed-style
	default-view
	width
	heigth)

(dont-obfuscate
	class id
	html xmlns xml lang
	head
	body
	title
	meta http-equiv name content
	link rel type href
	h1 h2 h3 h4 h5
	table thead tbody th tr td colspan rowspan
	ul ol li
	span div i p a
	img src alt
	br hr
	style
	form action method
	input type name value
	textarea cols rows)
