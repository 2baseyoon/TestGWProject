function load_mobile_editor(){
	var m_editorLang = "ko_KR";
    if (window.parent && window.parent.Common) {
        switch(window.parent.Common.getSession("lang")){
            case "en":
                m_editorLang = "en_US";
                break;
            case "ko":
                m_editorLang = "ko_KR";
                break;
            case "ja":
                m_editorLang = "ja";
                break;
            case "zh":
                m_editorLang = "zh_CN";
                //g_editorLang = "zh_TW";
                break;
            default:
                m_editorLang = "ko_KR";
                break;
        }
    }

	tinymce.init({
		selector: 'textarea#board_write_body',
		height: '100%',
		language: m_editorLang,
		menubar: false,
		plugins: 'table image',
		toolbar: 'undo redo | bold italic underline strikethrough forecolor backcolor | fontsize styles fontfamily | table image',
		table_toolbar: "tableprops tabledelete | tableinsertrowbefore tableinsertrowafter tabledeleterow | tableinsertcolbefore tableinsertcolafter tabledeletecol | covitableindent covitableoutdent | covitablealignleft covitablealigncenter covitablealignright covitablealignjustify",
		font_family_formats: "굴림=굴림,Gulim; 굴림체=굴림체,GulimChe; 돋움=돋움,Dotum; 돋움체=돋움체,DotumChe; 바탕=바탕,Batang; 바탕체=바탕체,BatangChe; 궁서=궁서,Gungsuh; 궁서체=궁서체,GungsuhChe; 맑은 고딕=맑은 고딕,malgun gothic; 나눔고딕=나눔고딕,nanum gothic; Andale Mono=andale mono,times; Arial=arial,helvetica,sans-serif; Arial Black=arial black,avant garde; Book Antiqua=book antiqua,palatino; Comic Sans MS=comic sans ms,sans-serif; Courier New=courier new,courier; Georgia=georgia,palatino; Helvetica=helvetica; Impact=impact,chicago; Symbol=symbol; Tahoma=tahoma,arial,helvetica,sans-serif; Terminal=terminal,monaco; Times New Roman=times new roman,times; Trebuchet MS=trebuchet ms,geneva; Verdana=verdana,geneva; Webdings=webdings; Wingdings=wingdings,zapf dingbats",
		file_picker_types: 'image',
		image_description: false,
		images_upload_url: "/covicore/mobileeditor/uploadFile.do",
		relative_urls : false,
        remove_script_host : true,
        convert_urls : false,
    	content_style: 'body { font-size : 10pt; } p { line-height : 1.5; margin-top: 0px; margin-bottom: 0px; }',
  		branding: false
	});

}