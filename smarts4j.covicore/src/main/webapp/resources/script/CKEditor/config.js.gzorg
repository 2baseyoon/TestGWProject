/**
 * @license Copyright (c) 2003-2019, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

CKEDITOR.editorConfig = function( config ) {
	
	config.resize_enabled = false;
	
	// Adding drag and drop image upload.
	config.extraPlugins = 'uploadimage';
	config.uploadUrl = '/covicore/ckeditor/uploadFile.do';

    // Configure your file manager integration. This example uses CKFinder 3 for PHP.
	config.filebrowserBrowseUrl = '/covicore/ckeditor/uploadFile.do';
	config.filebrowserImageBrowseUrl = '/covicore/ckeditor/uploadFile.do?type=Images';
	config.filebrowserUploadUrl = '/covicore/ckeditor/uploadFile.do?command=QuickUpload&type=Files';
	config.filebrowserImageUploadUrl = '/covicore/ckeditor/uploadFile.do?command=QuickUpload&type=Images';

	// default CSS
	config.contentsCss = '/HtmlSite/smarts4j_n/covicore/resources/css/common.css';
	
	//https://ckeditor.com/latest/samples/toolbarconfigurator/index.html#basic
	config.toolbar = [
		{ name: 'document', items: [ 'Source', '-', '-', 'NewPage', '-', 'Print', '-', '-' ] },
		{ name: 'clipboard', items: [ 'Cut', 'Copy', '-', '-', '-', '-', 'Undo', 'Redo' ] },
		{ name: 'editing', items: [ 'Find', 'Replace', '-', 'SelectAll', '-', '-' ] },
		/*{ name: 'forms', items: [ 'Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField' ] },*/
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'CopyFormatting', 'RemoveFormat' ] },
		'/',
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl', '-' ] },
		{ name: 'links', items: [ 'Link', 'Unlink', '-' ] },
		{ name: 'insert', items: [ 'Image', '-', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar', 'PageBreak', '-' ] },
		'/',
		{ name: 'styles', items: [ '-', 'Format', 'Font', 'FontSize' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'tools', items: [ 'Maximize', '-' ] },
		{ name: 'about', items: [ 'About' ] }
	];

};
