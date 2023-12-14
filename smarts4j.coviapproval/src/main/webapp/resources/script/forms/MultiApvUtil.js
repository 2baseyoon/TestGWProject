//에디터 개체 리턴
function getMultiCtrlEditor(pIdx) {
	var oMultiCtrl;
	var idx;

	if(!pIdx) {
		idx = $("#writeTab li.on").attr('idx');
	} else {
		idx = pIdx;
	}
	
	if(isUseHWPEditor()) {
		oMultiCtrl = $('[id=' + g_id + idx + '][doctype=normal]')[0];
		
		if(oMultiCtrl == null) {
			oMultiCtrl = $('[id=' + g_id + idx + 'Frame][doctype=normal]')[0].contentWindow.HwpCtrl;
		}

	} else {
		oMultiCtrl = $('[id=tbContentElement' + idx + ']')[0];
	}
	
	return oMultiCtrl;
}

//필드 간 값 동기화
function syncGovInfo(obj) {
	var iSeq = $(obj).attr("data-seq");
	
	$("#SubTable1 input[name=MULTI_" + $(obj).attr("name") + "]").eq(iSeq).val($(obj).val());
	
	if(iSeq == "1" && $(obj).text() == "") {
		$("#Subject").val($(obj).val());
	}
}


function addTabData(){
	m_initMulti = false;
	var curIdx = $("#writeTab li.on").attr("idx");
	
	HwpCtrl.MoveToField("body", true, true, true);	
	HwpCtrl.SaveAs("test.xml", "PUBDOCBODY", "saveblock;", function (res) {//현재 본문 다운url 
		document.getElementsByName("MULTI_BODYURL")[curIdx].value = res.downloadUrl
	});	
		
	HwpCtrl.GetTextFile("HTML", "saveblock", function(body) {
		var strBODY = Base64.utf8_to_b64(body);
		document.getElementsByName("MULTI_BODY")[curIdx].value = strBODY;
		
		// 전체 선택을 해제
		HwpCtrl.Run("Cancel");
				
	    HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
			var strHWP = Base64.utf8_to_b64(data);
			document.getElementsByName("MULTI_BODY_CONTEXT_HWP")[curIdx].value = strHWP;
	 
			saveCurMultiContext(curIdx);//현 탭 데이터 저장
			addTabClass();
		});
		
	});
}

function addTabHTMLData(){
	var idx = 1;
	var curIdx = $("#writeTab li.on").attr("idx");
	var strHTML = "";
	if (getInfo("Request.templatemode") == "Write") {
		
		if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("xfree", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("xfree", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
        	strHTML = document.getElementById("tbContentElement" + (idx)).HtmlValue;
        } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
        	strHTML = document.getElementById("tbContentElement" + (idx)).GetBodyValue();
        } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
        	strHTML = document.getElementById("tbContentElement" + (idx)).value;
        } else if (editortype.is('textarea')) {
        	strHTML = document.getElementById("tbContentElement" + (idx)).value;
        } else if (editortype.is('dext5')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("dext5", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("dext5", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('cheditor')) {
        	strHTML = document.getElementById('cheditorFrame').contentWindow.myeditor.getContents();
        } else if (editortype.is('synap')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("synap", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("synap", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('ck')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("ck", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("ck", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('webhwpctrl')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("webhwpctrl", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("webhwpctrl", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('covieditor')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("covieditor", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("covieditor", 'tbContentElement' + (idx));
        	}
        }
		
		strHTML = Base64.utf8_to_b64(strHTML);
	}else{
		
		if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
			strHTML = Base64.b64_to_utf8(formJson.BodyData.SubTable1[idx-1].MULTI_BODY_CONTEXT_HTML);
		} else if(getInfo('ExtInfo.UseWebHWPEditYN') == "Y") {
			strHTML = Base64.b64_to_utf8(formJson.BodyContext.tbContentElement);
		} else if (typeof formJson.BodyContext.tbContentElement["#cdata-section"] != 'undefined') {
			strHTML = formJson.BodyContext.tbContentElement["#cdata-section"];
		} else if (typeof formJson.BodyContext.tbContentElement != 'undefined') {
			strHTML = formJson.BodyContext.tbContentElement;
		} else {
			strHTML = "error at setEditor().";
        }
	}
	
	document.getElementsByName("MULTI_BODY_CONTEXT_HTML")[curIdx].value = strHTML;

	saveCurMultiContext(curIdx);//현 탭 데이터 저장

	addTabClass();
}

function deleteTabHTMLData(){
		var strHTML;
		var curIdx = $("#writeTab li.on").attr("idx");
		var idx = 1;
		
		if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("xfree", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("xfree", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
        	strHTML = document.getElementById("tbContentElement" + (idx)).HtmlValue;
        } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
        	strHTML = document.getElementById("tbContentElement" + (idx)).GetBodyValue();
        } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
        	strHTML = document.getElementById("tbContentElement" + (idx)).value;
        } else if (editortype.is('textarea')) {
        	strHTML = document.getElementById("tbContentElement" + (idx)).value;
        } else if (editortype.is('dext5')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("dext5", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("dext5", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('cheditor')) {
        	strHTML = document.getElementById('cheditorFrame').contentWindow.myeditor.getContents();
        } else if (editortype.is('synap')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("synap", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("synap", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('ck')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("ck", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("ck", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('webhwpctrl')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("webhwpctrl", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("webhwpctrl", 'tbContentElement' + (idx));
        	}
        } else if (editortype.is('covieditor')) {
        	if(m_sReqMode == "preview") { // 미리보기 예외처리
        		strHTML = coviEditor.getBody("covieditor", 'tbContentElement' + (idx), true);
        	} else {
        		strHTML = coviEditor.getBody("covieditor", 'tbContentElement' + (idx));
        	}
        }
		
		strHTML = Base64.utf8_to_b64(strHTML);
		
		document.getElementsByName("MULTI_BODY_CONTEXT_HTML")[curIdx].value = strHTML;
 
		saveCurMultiContext(curIdx);//현 탭 데이터 저장
		delTabClass();
}

function changeTabData(idx, initval){
	m_initMulti = false;
	var curIdx = $("#writeTab li.on").attr("idx");
	
	if(CFN_GetQueryString("isMobile") == "Y" || _mobile) {
		changeTab(idx, initval);
	} else if (isUseHWPEditor()){
		HwpCtrl.MoveToField("body", true, true, true);
		HwpCtrl.SaveAs("test.xml", "PUBDOCBODY", "saveblock;", function (res) {//현재 본문 다운url 
			document.getElementsByName("MULTI_BODYURL")[curIdx].value = res.downloadUrl
		});	
		
		HwpCtrl.GetTextFile("HTML", "saveblock", function(body) {
			var strBODY = Base64.utf8_to_b64(body);			
			document.getElementsByName("MULTI_BODY")[curIdx].value = strBODY;
			
			// 전체 선택을 해제
			HwpCtrl.Run("Cancel");
			
		    HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
				var strHWP = Base64.utf8_to_b64(data);
				document.getElementsByName("MULTI_BODY_CONTEXT_HWP")[curIdx].value = strHWP;
		 
				saveCurMultiContext(curIdx);//현 탭 데이터 저장
				changeTab(idx, initval)
			});
		});
	} else {
		var strHTML = "";
		if (getInfo("Request.templatemode") == "Write") {
			
			if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
	        	if(m_sReqMode == "preview") { // 미리보기 예외처리
	        		strHTML = coviEditor.getBody("xfree", 'tbContentElement1', true);
	        	} else {
	        		strHTML = coviEditor.getBody("xfree", 'tbContentElement1');
	        	}
	        } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
	        	strHTML = document.getElementById("tbContentElement1").HtmlValue;
	        } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
	        	strHTML = document.getElementById("tbContentElement1").GetBodyValue();
	        } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
	        	strHTML = document.getElementById("tbContentElement1").value;
	        } else if (editortype.is('textarea')) {
	        	strHTML = document.getElementById("tbContentElement1").value;
	        } else if (editortype.is('dext5')) {
	        	if(m_sReqMode == "preview") { // 미리보기 예외처리
	        		strHTML = coviEditor.getBody("dext5", 'tbContentElement1', true);
	        	} else {
	        		strHTML = coviEditor.getBody("dext5", 'tbContentElement1');
	        	}
	        } else if (editortype.is('cheditor')) {
	        	strHTML = document.getElementById('cheditorFrame').contentWindow.myeditor.getContents();
	        } else if (editortype.is('synap')) {
	        	if(m_sReqMode == "preview") { // 미리보기 예외처리
	        		strHTML = coviEditor.getBody("synap", 'tbContentElement1', true);
	        	} else {
	        		strHTML = coviEditor.getBody("synap", 'tbContentElement1');
	        	}
	        } else if (editortype.is('ck')) {
	        	if(m_sReqMode == "preview") { // 미리보기 예외처리
	        		strHTML = coviEditor.getBody("ck", 'tbContentElement1', true);
	        	} else {
	        		strHTML = coviEditor.getBody("ck", 'tbContentElement1');
	        	}
	        } else if (editortype.is('webhwpctrl')) {
	        	if(m_sReqMode == "preview") { // 미리보기 예외처리
	        		strHTML = coviEditor.getBody("webhwpctrl", 'tbContentElement1', true);
	        	} else {
	        		strHTML = coviEditor.getBody("webhwpctrl", 'tbContentElement1');
	        	}
	        } else if (editortype.is('covieditor')) {
	        	if(m_sReqMode == "preview") { // 미리보기 예외처리
	        		strHTML = coviEditor.getBody("covieditor", 'tbContentElement1', true);
	        	} else {
	        		strHTML = coviEditor.getBody("covieditor", 'tbContentElement1');
	        	}
	        }
			
			strHTML = Base64.utf8_to_b64(strHTML);
			
			document.getElementsByName("MULTI_BODY_CONTEXT_HTML")[curIdx].value = strHTML;
	 
			saveCurMultiContext(curIdx);//현 탭 데이터 저장
		}else{
			
			if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
				strHTML = Base64.b64_to_utf8(formJson.BodyData.SubTable1[idx-1].MULTI_BODY_CONTEXT_HTML);
			} else if(getInfo('ExtInfo.UseWebHWPEditYN') == "Y") {
				strHTML = Base64.b64_to_utf8(formJson.BodyContext.tbContentElement);
			} else if (typeof formJson.BodyContext.tbContentElement["#cdata-section"] != 'undefined') {
				strHTML = formJson.BodyContext.tbContentElement["#cdata-section"];
			} else if (typeof formJson.BodyContext.tbContentElement != 'undefined') {
				strHTML = formJson.BodyContext.tbContentElement;
			} else {
				strHTML = "error at setEditor().";
	        }
		}

		changeTab(idx, initval);
	}
}


function deleteTabData(){
	m_initMulti = false;
	
	HwpCtrl.MoveToField("body", true, true, true);
	HwpCtrl.GetTextFile("HTML", "saveblock", function(body) {
		var strBODY = Base64.utf8_to_b64(body);
		var curIdx = $("#writeTab li.on").attr("idx");
		document.getElementsByName("MULTI_BODY")[curIdx].value = strBODY;
		
		// 전체 선택을 해제
		HwpCtrl.Run("Cancel");
		
	    HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
			var strHWP = Base64.utf8_to_b64(data);
			document.getElementsByName("MULTI_BODY_CONTEXT_HWP")[curIdx].value = strHWP;
	 
			saveCurMultiContext(curIdx);//현 탭 데이터 저장
			delTabClass();
		});
	});
}

//탭 추가
function addTabClass(doctype, initval){
	var containerID = $("#writeTab li").length;
	if ((!editortype.is('dext5') || $('#tbContentElement'+containerID+'Frame').attr("editorloaded") == "Y") || getInfo("ExtInfo.UseEditYN")=="Y" || containerID < 2){
		var maxtab = Common.getBaseConfig("MultiDraftMaxCount");
		var tabTitle = "";
		var hwpTemplate = "draft_Template";
		
		if (getInfo("Request.templatemode") == "Write") {
			if(doctype == "audit"){ // 일상감사 검토서
				if($("#writeTab li[doctype=audit]").length > 0){
					//Common.Warning("검토서가 이미 추가되었습니다.");
					return false;
				}
			} else if(doctype == "opinion"){ // 일상감사 의견서
				if($("#writeTab li[doctype=opinion]").length > 0){
					//Common.Warning("의견서가 이미 추가되었습니다.");
					return false;
				}
			}
		}
	
		if(doctype == null) {
			doctype = 'normal';
		}
		
		if($("#writeTab li").length < maxtab){
			if (isGovMulti()) {
				if (initval != "init" && !getIsGovMultiHWPEditorLoad() && !($('#tbContentElement'+containerID+'Frame').attr("editorloaded") == "Y")
					&& getInfo("ExtInfo.UseEditYN") !="Y") {
					Common.Warning('아직 에디터가 로드되지 않았습니다. 잠시만 기다려주세요.');
					return false;
				}
			}
			
			$("#writeTab li").attr('class','');
			var idx = $("#writeTab li").length + 1;
	
			switch(doctype){
					case "normal" : tabTitle = idx + Common.getDic("lbl_an"); hwpTemplate = "draft_Template"; break;
				case "audit" : tabTitle = "검토서"; hwpTemplate = "review_Template"; break;
				case "opinion" : tabTitle = "의견서"; hwpTemplate = "opinion_Template"; break;
			}
			
			var html = "";
				html = "<li class='on' idx='" + idx + "' style='width: 45px;' doctype='" + doctype + "'><a onclick='javascript:changeTabData(" + idx + ");' style='line-height:35px;'>" + tabTitle + "</a></li>"
			$("#writeTab").append(html);
			
			$("#ContentsLine").append("<div id='divWebEditorContainer" + idx + "' data-element-type='editor' idx='" + idx + "'></div>");
			$("#AttFileInfoList_Multi td").append("<div id='AttFileInfo" + idx + "'></div>");
				
				var $SubjectDiv = $("<div>").attr("id", "Subject" + idx);
				var $SubjectInput = $("<input>").attr({"type":"text","class":"input-required pattern-active pattern-required-active","name":"TITLE","data-seq":idx})
												.css({"width":"98%","height":"25px"}).on('change',function() {
													syncGovInfo(this);
												});
				$SubjectDiv.append($SubjectInput);
				$("#SubjectInfoList_Multi #SubjectInfoItem_Multi").append($SubjectDiv);
				
				$("#ReceiveLine_Multi td").append("<div id='RecLine" + idx + "'></div>");
				
			$("#tblFileList").append("<tbody id='fileInfo" + idx + "' style='background-color:white;'><tr id='trFileInfoBox" + idx + "' style='height:99%'><td colspan='4'><div class='dragFileBox'><span class='dragFile'>icn</span>" + Common.getDic("lbl_DragFile") + "</div></td></tr></tbody>");
			$("#divFileSelect").append("<input type='file' multiple name='FileSelect" + idx + "' id='FileSelect" + idx + "' onchange='javascript:FileSelect_onchangeMulti();' style='opacity:0;'/>");
	
			$("#DocLinkInfoList_Multi td").append("<div id='DocLinkInfo" + idx + "'></div>");
			
			$("#RecordInfoList_Multi td").append("<div id='RecordInfo" + idx + "'></div>");
				
			var multirowIdx = idx - 1;
			if($(".multi-row")[multirowIdx] == null && getInfo("Request.templatemode") == "Write"){
				$('#btn_new_add').click();
				if ($(".multi-row input[name=MULTI_DOC_TYPE]")[multirowIdx] != undefined) $(".multi-row input[name=MULTI_DOC_TYPE]")[multirowIdx].value = doctype;
			}
			
			// 문서유통 일반에디터
			if (isGovMulti() && getInfo("ExtInfo.UseEditYN")=="Y") {
				// 수신
				var $DocRecLineDiv = $("<div>").attr("id", "DocRecLine" + idx);
				var $DocRecLineInput = $("<input>").attr({"type":"text","name":"DOC_RECLINE","readonly":"readonly","data-seq":idx})
												.css({"width":"99%","border":"hidden"}).on('change',function() {
													syncGovInfo(this);
												});
				$DocRecLineDiv.append($DocRecLineInput);
				$("#DocRecLineList_Multi #DocRecLineItem_Multi").append($DocRecLineDiv);
				
				// 제목
				var $SubjectDiv = $("<div>").attr("id", "Title" + idx);
				var $SubjectInput = $("<input>").attr({"type":"text","name":"TITLE","data-seq":idx})
												.css({"width":"99%","border":"hidden"}).on('change',function() {
													syncGovInfo(this);
												});
				$SubjectDiv.append($SubjectInput);
				$("#TitleList_Multi #TitleItem_Multi").append($SubjectDiv);
				
				// 전화번호
				var $DocRecLineDiv = $("<div>").attr("id", "DocPhoneNum" + idx);
				var $DocRecLineInput = $("<input>").attr({"type":"text","name":"TELEPHONE","data-seq":idx})
												.css({"width":"99%"}).on('change',function() {
													syncGovInfo(this);
												});
				$DocRecLineDiv.append($DocRecLineInput);
				$("#DocPF_Multi #DocPNumItem_Multi").append($DocRecLineDiv);
				
				// 팩스번호
				var $DocRecLineDiv = $("<div>").attr("id", "DocFaxNum" + idx);
				var $DocRecLineInput = $("<input>").attr({"type":"text","name":"FAX","data-seq":idx})
												.css({"width":"99%"}).on('change',function() {
													syncGovInfo(this);
												});
				$DocRecLineDiv.append($DocRecLineInput);
				$("#DocPF_Multi #DocFNumItem_Multi").append($DocRecLineDiv);
				
				// 홈페이지
				var $DocRecLineDiv = $("<div>").attr("id", "DocHomePage" + idx);
				var $DocRecLineInput = $("<input>").attr({"type":"text","name":"HOMEURL","data-seq":idx})
												.css({"width":"99%"}).on('change',function() {
													syncGovInfo(this);
												});
				$DocRecLineDiv.append($DocRecLineInput);
				$("#DocHPList_Multi #DocHPItem_Multi").append($DocRecLineDiv);
				
				// 이메일
				var $DocRecLineDiv = $("<div>").attr("id", "DocEmail" + idx);
				var $DocRecLineInput = $("<input>").attr({"type":"text","name":"EMAIL","data-seq":idx})
												.css({"width":"99%"}).on('change',function() {
													syncGovInfo(this);
												});
				$DocRecLineDiv.append($DocRecLineInput);
				$("#DocHPList_Multi #DocEmailItem_Multi").append($DocRecLineDiv);
				
				// 우편번호
				var $DocRecLineDiv = $("<div>").attr("id", "DocZipCode" + idx);
				var $DocRecLineInput = $("<input>").attr({"type":"text","name":"ZIPCODE","data-seq":idx})
												.css({"width":"99%"}).on('change',function() {
													syncGovInfo(this);
												});
				$DocRecLineDiv.append($DocRecLineInput);
				$("#DocZCList_Multi #DocZCItem_Multi").append($DocRecLineDiv);
				
				//주소
				var $DocRecLineDiv = $("<div>").attr("id", "DocAddress" + idx);
				var $DocRecLineInput = $("<input>").attr({"type":"text","name":"ADDRESS","data-seq":idx})
												.css({"width":"99%"}).on('change',function() {
													syncGovInfo(this);
												});
				$DocRecLineDiv.append($DocRecLineInput);
				$("#DocAddressList_Multi #DocAddressItem_Multi").append($DocRecLineDiv);
			}
			
			if(initval != "init" && isUseHWPEditor()) {
				LoadEditor("divWebEditorContainer" + idx, idx, hwpTemplate, doctype);
			}
			l_aObjFileListMultiArr[idx-1] = new Array();
		
			changeTab(idx, initval);
		
		} else {
			
		}
	
		if(getInfo("Request.mode") == "REDRAFT") {
			$(".tabLine").hide();
		}
	}
}

//탭  세팅
function delTabClass(){
	if($("#writeTab li").length > 1){
		var idx = $("#writeTab li").length;
		$("#writeTab li[idx=" + idx + "]").remove();
		$('[id=Subject' + idx + ']').remove();
		$("#divWebEditorContainer" + idx).remove();
		$('[id=AttFileInfo' + idx + ']').remove();
		$("#fileInfo" + idx).remove();
		$('[id=DocLinkInfo' + idx + ']').remove();
		
		// 문서유통 일반에디터
		if (isGovMulti() && getInfo("ExtInfo.UseEditYN")=="Y") {
			// 수신
			$('div[id^=DocRecLine' + idx +']').remove();
			// 제목
			$('div[id^=Title' + idx +']').remove();
			// 전화번호
			$('div[id^=DocPhoneNum' + idx +']').remove();
			// 팩스번호
			$('div[id^=DocFaxNum' + idx +']').remove();
			// 홈페이지
			$('div[id^=DocHomePage' + idx +']').remove();
			// 이메일
			$('div[id^=DocEmail' + idx +']').remove();
			// 우편번호
			$('div[id^=DocZipCode' + idx +']').remove();
			//주소
			$('div[id^=DocAddress' + idx +']').remove();
			//웹에디터
			$('div [id^=divWebEditorContainer' + idx +']').remove();
		}
		
		$('#btn_new_del').click();
		l_aObjFileListMultiArr[idx-1] = null;
		
		// 안 삭제에 따라 에디터 로드 여부 값도 삭제
		if (typeof (g_IsGovMultiEditorLoad) != undefined) g_IsGovMultiEditorLoad.pop();
			
		changeTab(idx - 1);
		
		// 저장되어 있는 subTable 정보가 있는 경우 삭제
		if (formJson.BodyData && formJson.BodyData.SubTable1 && formJson.BodyData.SubTable1.length > 0) {
			// 가장 마지막 안 정보 삭제
			formJson.BodyData.SubTable1.pop();
		}
	}
}

function delOpinion(){
	//if($("#writeTab li").length > 1){
		var idx = $('li[doctype=opinion]').attr('idx');
		if(idx != null){
			$("#writeTab li[idx=" + idx + "]").remove();
			$("#divWebEditorContainer" + idx).remove();
			$('[id=AttFileInfo' + idx + ']').remove();
			$('[id=Subject' + idx + ']').remove();
			$("#fileInfo" + idx).remove();
			
			$('#btn_new_del').click();
			l_aObjFileListMultiArr[idx-1] = null;
			changeTab(idx - 1);
		}
	//}
}

function changeTab(idx, initval){
	$("#writeTab li").attr('class','');
	$("#writeTab li[idx=" + idx + "]").attr('class','on');
	
	if(CFN_GetQueryString("isMobile") == "Y" || _mobile) {
	
	} else if(isUseHWPEditor()){ // 웹한글기안기
		if($('div[id=divWebEditorContainer' + m_firstIDx + '] > iframe').length == 0) {
				LoadEditor("divWebEditorContainer" + m_firstIDx, m_firstIDx, $('div[id=divWebEditorContainer' + m_firstIDx + ']').attr("hwpTemplate"), $('div[id=divWebEditorContainer' + m_firstIDx + ']').attr("doctype"));
		}		
	}
	
//	if(initval == "init"){ 
//		$('div[id=divWebEditorContainer' + idx + ']').removeAttr("style");
//		$('div [id^=divWebEditorContainer]').hide();
//		
//		if($('div[id=divWebEditorContainer' + m_firstIDx + '] > iframe').length == 0) {
//			LoadEditor("divWebEditorContainer" + m_firstIDx, m_firstIDx, $('div[id=divWebEditorContainer' + m_firstIDx + ']').attr("hwpTemplate"), $('div[id=divWebEditorContainer' + m_firstIDx + ']').attr("doctype"));
//		}		
//	}
	//$('div[id^=divWebEditorContainer]').hide();
	$('div[id=divWebEditorContainer' + idx + ']').show();
	$('div[id^=AttFileInfo]').hide();
	$('div[id=AttFileInfo' + idx + ']').show();
	$('div[id^=Subject]').hide();
	$('div[id=Subject' + idx + ']').show();
	$('div[id^=RecLine]').hide();
	$('div[id=RecLine' + idx + ']').show();			
	$('tbody[id^=fileInfo]').hide();
	$('tbody[id=fileInfo' + idx + ']').show();
	$('div[id^=DocLinkInfo]').hide();
	$('div[id=DocLinkInfo' + idx + ']').show();
	$('div[id^=RecordInfo]').hide();
	$('div[id=RecordInfo' + idx + ']').show();
	
	// 문서유통 일반에디터
	if (isGovMulti() && getInfo("ExtInfo.UseEditYN")=="Y") {
		// 수신
		$('div[id^=DocRecLine]').hide();
		$('div[id=DocRecLine' + idx + ']').show();
		// 제목
		$('div[id^=Title]').hide();
		$('div[id=Title' + idx + ']').show();
		// 전화번호
		$('div[id^=DocPhoneNum]').hide();
		$('div[id=DocPhoneNum' + idx + ']').show();
		// 팩스번호
		$('div[id^=DocFaxNum]').hide();
		$('div[id=DocFaxNum' + idx + ']').show();
		// 홈페이지
		$('div[id^=DocHomePage]').hide();
		$('div[id=DocHomePage' + idx + ']').show();
		// 이메일
		$('div[id^=DocEmail]').hide();
		$('div[id=DocEmail' + idx + ']').show();
		// 우편번호
		$('div[id^=DocZipCode]').hide();
		$('div[id=DocZipCode' + idx + ']').show();
		//주소
		$('div[id^=DocAddress]').hide();
		$('div[id=DocAddress' + idx + ']').show();
	}
	
	

	/*
	 * iframe 하나로 합침
	// 웹 한글기안시 패스 (웹 한글기안은 기초설정 값에 따라 처리 되지 않는다.)
	if (!isUseHWPEditor()) {
		if (editortype.is('dext5') && getInfo("Request.templatemode") == 'Write' && idx > 1 && $("#writeTab li").length != idx){ //dext5, 등록 및 편집시
			document.getElementById('tbContentElement'+idx+'Frame').contentWindow.DEXT5.show('tbContentElement'+idx);
		}
		if (editortype.is('keditor') && getInfo("Request.templatemode") == 'Write' && idx > 1 && $("#writeTab li").length != idx){ //keditor, 등록 및 편집시
			document.getElementById('tbContentElement'+idx+'Frame').contentWindow.RAONKEDITOR.show('tbContentElement'+idx);
		}
	}
	*/
	
	if ((CFN_GetQueryString("isMobile") == "Y" || _mobile) && isUseHWPEditor()){
		SetBodyMultiGovMobile(idx);
	} else if (getInfo("Request.templatemode") != "Read") {
		if (isGovMulti()) {
			// 결재유형 값 세팅
			if(($('[name=MULTI_APV_RECEIVER_TYPE]').eq(idx) && (!formJson.BodyData.SubTable1 || !formJson.BodyData.SubTable1[idx-1])) || getInfo("Request.mode") == "TEMPSAVE"){
				$('#ApvReceiverTypeSelect').val($('[name=MULTI_APV_RECEIVER_TYPE]').eq(idx).val());
			} else {
				$('#ApvReceiverTypeSelect').val(formJson.BodyData.SubTable1[idx-1].MULTI_APV_RECEIVER_TYPE);
			}
			if ($('#ApvReceiverTypeSelect').val() == "else") {
				$('#btRecieveMulti').show();
			} else {
				$('#btRecieveMulti').hide();
			}
			// 발신명의 값 세팅
			if(($('[name=MULTI_SENDER_MASTER]').eq(idx) && (!formJson.BodyData.SubTable1 || !formJson.BodyData.SubTable1[idx-1])) || getInfo("Request.mode") == "TEMPSAVE"){
				$('#SenderMasterSelect').val($('[name=MULTI_SENDER_MASTER]').eq(idx).val());
			} else {
				$('#SenderMasterSelect').val(formJson.BodyData.SubTable1[idx-1].MULTI_SENDER_MASTER);
			}
			
			// 다안기안 + 문서유통 + 웹에디터 
			if(getInfo("ExtInfo.UseEditYN")=="Y"){
				// 수신
				if(($('[name=MULTI_DOC_RECLINE]').eq(idx) && (!formJson.BodyData.SubTable1 || !formJson.BodyData.SubTable1[idx-1])) || getInfo("Request.mode") == "TEMPSAVE"){
					$('#DocRecLine'+(idx-1)).children().val($('[name=MULTI_DOC_RECLINE]').eq(idx-1).val());
				} else {
					$('#DocRecLine'+(idx-1)).children().val(formJson.BodyData.SubTable1[idx-1].MULTI_DOC_RECLINE);
				}
				// 제목
				if(($('[name=MULTI_TITLE]').eq(idx) && (!formJson.BodyData.SubTable1 || !formJson.BodyData.SubTable1[idx-1])) || getInfo("Request.mode") == "TEMPSAVE"){
					$('#Subject'+(idx-1)).children().val($('[name=MULTI_TITLE]').eq(idx-1).val());
				} else {
					$('#Subject'+(idx-1)).children().val(formJson.BodyData.SubTable1[idx-1].MULTI_TITLE);
				}
			}
			
		} else {
			if(($('[name=MULTI_RECEIVER_TYPE]').eq(idx-1) && (!formJson.BodyData.SubTable1 || !formJson.BodyData.SubTable1[idx-1])) || getInfo("Request.mode") == "TEMPSAVE"){
				$('#RecieveSelect').val($('[name=MULTI_RECEIVER_TYPE]').eq(idx-1).val());
			} else {
				$('#RecieveSelect').val(formJson.BodyData.SubTable1[idx-1].MULTI_RECEIVER_TYPE);
			}
		}
		
		//탭변경시 데이터 바인딩, ysyi
		if (isUseHWPEditor()){
			if(m_initMulti == false){
				m_initMulti = true;
			    var strBody =Base64.b64_to_utf8(document.getElementsByName("MULTI_BODY_CONTEXT_HWP")[idx].value);
				    HwpCtrl.SetTextFile(strBody, "HWPML2X", "", function (result) {
	
				    drawApvLineHWP();			     
					// 웹 한글기안 에디터 로드 세팅 종료
					setGovMultiEditorLoadEnd(result.HwpCtrl.Impl.idx);
		    	}, {"HwpCtrl":HwpCtrl});		
			}	
		}else{
			 var strBody =Base64.b64_to_utf8(document.getElementsByName("MULTI_BODY_CONTEXT_HTML")[idx].value);
			 setEditorBody(strBody);
		}
    } else {
		//탭변경시 데이터 바인딩, ysyi
		if(isUseHWPEditor()){
			// 웹 한글기안기
			if(m_initMulti == false){
    			m_initMulti = true;
	    	    var strBody =Base64.b64_to_utf8(formJson.BodyData.SubTable1[idx-1].MULTI_BODY_CONTEXT_HWP);
				    HwpCtrl.SetTextFile(strBody, "HWPML2X", "", function (result) {
		    		 drawApvLineHWP();
					// 웹 한글기안 에디터 로드 세팅 종료
					setGovMultiEditorLoadEnd(result.HwpCtrl.Impl.idx);
	    	   }, {"HwpCtrl":HwpCtrl});
    		}
		}else{
			// 일반에디터
			var strBody = Base64.b64_to_utf8(formJson.BodyData.SubTable1[idx-1].MULTI_BODY_CONTEXT_HTML).toString();
			$('#tbContentElement1').html(strBody);
		}
    }
    docLinks.init(idx);
}

function RecieveTypeChange(){
	var idx = $("#writeTab li.on").attr('idx');
	var oMultiCtrl = getMultiCtrlEditor();
	
	$('[name=MULTI_RECEIVER_TYPE]').eq(idx).val($('#RecieveSelect').val());

	$('#btRecieveIn, #btRecieveOut, #spanSender, #spanEtcSender').hide();
	
	if($('#RecieveSelect').val() == "Out"){
		$('#btRecieveOut').show();
		oMultiCtrl.PutFieldText('sendername', '코비젼대표이사장');
	} else if($('#RecieveSelect').val() == "In") {
		$('#btRecieveIn').show();
		oMultiCtrl.PutFieldText('sendername', getInfo('AppInfo.dpnm')+'장');
	} else {
		//$('#spanEtcSender').show();
		$('#spanSender').show();
		oMultiCtrl.PutFieldText('sendername', " ");
	}
}

function setReciever(obj){
	var gbn = "";
	if(obj.id == "btRecieveIn"){
		gbn = "In";
	} else if(obj.id == "btRecieveOut") {
		gbn = "Out";
	} else {
		gbn = "Etc";
	}

	if(gbn == "Etc"){
		if($('#spanEtcReceiver').css('display') == 'none'){
			$('#spanEtcReceiver').show();
		} else {
			$('#spanEtcReceiver').hide();
		}
	} else {
		var sUrl = "/approval/multiReceiveline.do?gbn="+gbn;
		var iHeight = 580; 
		var iWidth = 1110;
		
		CFN_OpenWindow(sUrl, "", iWidth, iHeight, "fix");	
	}
}

//다안기안 수신처 지정
function setRecieverMulti(){
	var idx = $("#writeTab li.on").attr('idx');
	
	var gbn = "In";
	var sUrl = "../multiReceiveline.do?gbn="+gbn+"&g_idx="+idx;
	var iHeight = 580; 
	var iWidth = 1110;
		
	// 2022-11-22 문서유통일때 처리
	if (isGovMulti()) {
		const receiveType = document.getElementsByName("MULTI_RECEIVE_TYPE")[idx].value;
		document.getElementById('RECEIVEGOV_NAMES').value = '';
		document.getElementById('ReceiveNames').value = '';
		
		if (receiveType == 'inreceive') {
			// 대내수신
			document.getElementById('ReceiveNames').value = document.getElementsByName('MULTI_RECEIVENAMES')[idx].value;
		} else if (receiveType == 'outelecdoc') {
			// 대외전자
			document.getElementById('RECEIVEGOV_NAMES').value = document.getElementsByName('MULTI_RECEIVENAMES')[idx].value;
		}
		
		sUrl = "/approval/ReceiveManagerPopup.do?AllCompany=Y&multiidx="+idx;
		iHeight = 645;
		iWidth = 1110;
	}
	
	CFN_OpenWindow(sUrl, "", iWidth, iHeight, "fix");
}

/* 기초코드(발신명의)를 불러오기 */
function getSenderList() {
    // 그룹코드와 비사용중인 코드를 제외한 모든 코드를 가져옴.
    var oCodeList = Common.getBaseCode("DocSenderList");
    var Len = oCodeList.CacheData.length;
    var vCodeName = oCodeList.CacheData[0].Code;

    $("select[id=SenderSelect] option").remove();

    $("select[id=SenderSelect]").eq(0).append("<option value=''>" + Common.getDic("lbl_selection") + "</option>");
    for (var i = 0; i < Len; i++) {
        $("select[id=SenderSelect]").append("<option value='" + oCodeList.CacheData[i].Code + "'>" + oCodeList.CacheData[i].CodeName + "</option>");
    }
}

function SetEtcReceiver(obj){ 
	if(obj == null) return false;
	var idx = $("#writeTab li.on").attr('idx');
	
    var HwpCtrl = document.getElementById(g_id + idx);
	if(HwpCtrl == null) {
		HwpCtrl = document.getElementById(g_id + idx + "Frame").contentWindow.HwpCtrl;
	}
	
    var receiver =obj.value; 

    if(receiver.indexOf(',') > -1){
    	HwpCtrl.PutFieldText('recipient_single', "수신자참조");
    	HwpCtrl.PutFieldText('recipient_mul', receiver);
    	HwpCtrl.PutFieldText('recipient', "수신자");
    } else {
    	HwpCtrl.PutFieldText('recipient_single', receiver);
    	HwpCtrl.PutFieldText('recipient_mul', " ");
    	HwpCtrl.PutFieldText('recipient', " ");
    }
    HwpCtrl.PutFieldText('sendername', '코비젼대표이사장');
    
	$('[name=MULTI_RECEIVER_TYPE]').eq(idx).val("Etc");
	$('[name=MULTI_RECEIVENAMES]').eq(idx).val("receiver");
	$('[name=MULTI_RECEIPTLIST]').eq(idx).val("receiver");
	
	$("#ReceiveNames").val("");
	$("#ReceiptList").val("");
	$(obj).val("");
	
	$('#spanEtcReceiver').hide();
}

function SetSender(obj){
	var idx = $("#writeTab li.on").attr('idx');
	
    var HwpCtrl = document.getElementById(g_id + idx);
	if(HwpCtrl == null) {
		HwpCtrl = document.getElementById(g_id + idx + "Frame").contentWindow.HwpCtrl;
	}

	var sendercode = "";
	var sendername = ""; 
	if(obj.tagName == "SELECT"){
		sendercode = obj.value;
		sendername = (obj.value == "" ? (HwpCtrl.GetFieldText("recipient_single") == "내부결재" ? " " : getInfo('AppInfo.dpnm')+'장') : obj.options[obj.selectedIndex].text);
	} else if(obj.tagName == "INPUT"){
		sendername = obj.value;
	}
	if(sendercode == "Dept"){
		sendername = getInfo('AppInfo.dpnm')+'장';
	} else if (sendercode == "Empty"){
		sendername = " ";
	} else 	if(sendercode != "" && sendername == "감사"){
		sendername = getSenderInfo(sendercode);
	}
    HwpCtrl.PutFieldText('sendername', sendername);
	$('#spanSender').hide();
}

function getSenderInfo(sendercode){
	var sendername;
    try {
    	$.ajax({
    		async : false,
    		url:"getSenderInfo.do", 
    		data:  {
				"titlecd" : sendercode
			},
    		type:"post",
    		success:function (res) {
    			if(res.status == "SUCCESS"){
    				sendername = res.list[0].deptname + ' ' + res.list[0].displayname;
    			}
    		},
    		error:function(response, status, error){
				CFN_ErrorAjax("getSenderInfo.do", response, status, error);
			}
    	});
    } catch (e) {
        Common.Error(e.message);
    }
    return sendername;
}

// --------------------------------------------- 첨부파일 컨트롤 -------------------------------------------------------
/**
 * 1. 개발지원에 있는 첨부파일 컨트롤 HTML 사용
 * 2. 스크립트단은 아래 함수들로 실행됨
 * 3. 서버단에서는 개발지원에 있는 submit 함수를 이용해서 컨트롤에서 Request에 있는 MultipartFile 로 받아서 처리.
 * 4. 컨트롤에서는 FileUtil.fileUpload 함수이용해서 첨부파일 저장
 */

var l_aObjFileListMulti = [];
var l_aObjFileListMultiArr = new Array(parseInt(Common.getBaseConfig("MultiDraftMaxCount") == "" ? 0 : Common.getBaseConfig("MultiDraftMaxCount")));
l_aObjFileListMultiArr[0] = new Array();

// 파일추가 버튼
function AddFileMulti() {
	var idx = $("#writeTab li.on").attr('idx');
	// Iframe FileControl의 파일추가 버튼 클릭
	document.getElementById("FileSelect" + idx).click();
	l_aObjFileListMulti = l_aObjFileListMultiArr[idx];
}

//Iframe의 파일 컨트롤 값이 입력될때(파일 선택 시)
function FileSelect_onchangeMulti() {
	var idx = $("#writeTab li.on").attr('idx');
    // 파일 선택 시 파일명 중복 검사
    var nLength = document.getElementById("FileSelect" + idx).files.length;
    var oFileInfo = document.getElementById("FileSelect" + idx).files;
    var bCheck = false;
    var aObjFiles = [];
    var oldFileList = $('#fileInfo' + idx + ' [name=chkFile]');
    var configLimitSize = 10; //Common.getBaseConfig("FileUploadLimitSize");
    var fileSizeLimit = configLimitSize*1024*1024;
    
    var overSize = false;
    $(oFileInfo).each(function(idx, item){
    	if(item.size > fileSizeLimit){
    		overSize = true;
    	}
    });
    
    if(overSize){
    	Common.Warning(configLimitSize+"MB 이하의 파일만 업로드 가능합니다.");
    	return false;
    }
    
    if (oldFileList.length == 0) {
        readfilesMulti(document.getElementById("FileSelect" + idx).files, idx);
        SetFileInfoMulti(document.getElementById("FileSelect" + idx).files, idx);
    } else {
        for (var i = 0; i < nLength; i++) {
			for (var j = 0; j < oldFileList.length; j++) {
				if (oFileInfo[i].name == oldFileList[j].value.split(':')[1]) { // 중복됨
					bCheck = true;
					Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
					break;
				} else { // 중복안됨
					bCheck = false;
				}
			}
            if (!bCheck) {
                aObjFiles.push(oFileInfo[i]);
            }
        }
        readfilesMulti(aObjFiles, idx);
        SetFileInfoMulti(aObjFiles, idx);
    }
}

// onDragEnter Event
function onDragEnterMulti(event) {
	event.preventDefault();
}

// onDragOver Event
function onDragOverMulti(event) {
	event.preventDefault();
}

// Drop Event
function onDropMulti(event) {
	var idx = $("#writeTab li.on").attr('idx');
	var aTempList = event.dataTransfer.files;
	var aObjFileList = new Array();

	event.stopPropagation();
	event.preventDefault();

	//폴더 타입의 파일 제거
	for (var i = 0; i < aTempList.length; i++) {
		if (aTempList[i].name.indexOf('.') > -1 && aTempList[i].size != 0 && aTempList[i].size != 4096) {
			aObjFileList.push(aTempList[i]);
		}
	}

	// 파일 선택 시 파일명 중복 검사
	var nLength = aObjFileList.length;
	var oFileInfo = aObjFileList;
	var bCheck = false;
	var aObjFiles = [];
	var oldFileList = $('#fileInfo' + idx + ' [name=chkFile]');
    var configLimitSize = 10; //Common.getBaseConfig("FileUploadLimitSize");
    var fileSizeLimit = configLimitSize*1024*1024;
    
    var overSize = false;
    $(oFileInfo).each(function(idx, item){
    	if(item.size > fileSizeLimit){
    		overSize = true;
    	}
    });
    
    if(overSize){
    	Common.Warning(configLimitSize+"MB 이하의 파일만 업로드 가능합니다.");
    	return false;
    }

	if (oldFileList.length == 0) {
		readfilesMulti(aObjFileList, idx);
		SetFileInfoMulti(aObjFileList, idx);
	} else {
		for (var i = 0; i < nLength; i++) {
			for (var j = 0; j < oldFileList.length; j++) {
				if (oFileInfo[i].name == oldFileList[j].value.split(':')[1]) { // 중복됨
					bCheck = true;
					Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
					break;
				} else { // 중복안됨
					bCheck = false;
				}
			}
			if (!bCheck) {
				aObjFiles.push(oFileInfo[i]);
			}
		}
		readfilesMulti(aObjFiles, idx);
		SetFileInfoMulti(aObjFiles, idx);
	}
}

// 파일정보 배열(l_aObjFileListMulti)에 추가
function readfilesMulti(files, idx) {
	for (var i = 0; i < files.length; i++) {
		l_aObjFileListMultiArr[idx-1].push(files[i]);
	}
}

// 파일 정보 히든필드에 셋팅
function SetFileInfoMulti(pObjFileInfo, idx) {
	var aObjFileInfo = new Array();
	aObjFileInfo = pObjFileInfo;
	var sFileInfo = "";
	var sFileInfoTemp = "";
	var nLength = aObjFileInfo.length;
	for (var i = 0; i < nLength; i++) {
		sFileInfo += aObjFileInfo[i].name + ":" + aObjFileInfo[i].size + ":" + "NEW" + ":" + "0" + ":" + "|";

		// hidFileSize 값 셋팅
		sFileInfoTemp += aObjFileInfo[i].name + ":" + aObjFileInfo[i].name.split(',')[aObjFileInfo[i].name.split(',').length - 1] + ":" + aObjFileInfo[i].size + "|";
	}

	// 목록에 바인딩
	DrawTableMulti(pObjFileInfo, idx);
}

// 첨부파일 정보 Row 추가
function DrawTableMulti(fileInfo, idx) {
	var aObjFileInfo = new Array();
	aObjFileInfo = fileInfo;
	var sFileInfo = "";

	for (var l = 0; l < aObjFileInfo.length; l++) {
		var sExtension = aObjFileInfo[l].name.split('.')[aObjFileInfo[l].name.split('.').length - 1];
		var sFileName = aObjFileInfo[l].name;
		var sFileSize = aObjFileInfo[l].size;
		var sFileType = "";
		sFileInfo += sFileName + ":" + sExtension + ":" + sFileSize + "|"; //":" + sFilePath +
	}

	var l_selObj = document.getElementById("fileInfo" + idx);
	var l_arrFile = "";
	if (sFileInfo != "" && sFileInfo != undefined)
		l_arrFile = sFileInfo.split("|"); // 새 파일 정보
	if (l_arrFile != "" && l_arrFile.length > 0) {
		$("#trFileInfoBox" + idx).hide();
	}
	if (l_arrFile != "") {
		if (l_selObj.rows[l_selObj.rows.length - 1].innerHTML.indexOf("colspan") > -1)
			l_selObj.deleteRow(l_selObj.rows.length - 1); //기본 줄이 있을 경우 제거처리
		for (var i = 0; i < l_arrFile.length - 1; i++) {
			var l_arrDetail = l_arrFile[i].split(':');
			var l_oRow = l_selObj.insertRow(l_selObj.rows.length);

			var l_oCell_1 = l_oRow.insertCell(l_oRow.cells.length);
			l_oCell_1.innerHTML = '<input name="chkFile" type="checkbox" value="' +'_0' + ':' + l_arrDetail[0] + ':NEW' + '" class="input_check">'; //+ l_arrDetail[3]

			var l_oCell_2 = l_oRow.insertCell(l_oRow.cells.length);
			l_oCell_2.innerHTML += '<span class=' + setFileIconClassMulti(l_arrDetail[1]) + '>파일첨부</span>';

			var l_oCell_3 = l_oRow.insertCell(l_oRow.cells.length);
			l_oCell_3.innerHTML = l_arrDetail[0];

			var l_oCell_4 = l_oRow.insertCell(l_oRow.cells.length);
			l_oCell_4.innerHTML += ConvertFileSizeUnitMulti(l_arrDetail[2]);
			l_oCell_4.className = "t_right";

			l_selObj.appendChild(l_oRow); //상단에서 객체 insertRow로 이미 추가됨
		}
	}
	setFormAttachFileInfoMulti(idx);
}

// 부모창의 파일삭제 버튼 클릭 시 선택한 파일 제거
function DeleteFileMulti() {
	var idx = $("#writeTab li.on").attr('idx');
	var l_selObj = document.getElementById("fileInfo" + idx);
	//var l_chk = document.getElementsByName("chkFile");
    var l_chk = $('#fileInfo' + idx + ' [name=chkFile]');
	document.getElementById("hidDeletFiles").value = "";

	if (l_chk.length <= 0) {
		return;
	}

	for (var i = l_chk.length - 1; i > -1; i--) {
		if (l_chk[i].checked) {
			document.getElementById("hidDeletFiles").value += l_chk[i].value.split(":")[1] + "|"; // 선택한 파일명

			if (l_chk[i].value.split(":")[2] == "OLD") {
				document.getElementById("hidDeleteFile").value += l_chk[i].value.split(":")[1] + "|";
			}

			l_selObj.deleteRow(i);
			if (l_selObj.rows.length < 1) {
				var l_oRow = l_selObj.insertRow(l_selObj.rows.length);
				l_oRow.setAttribute("id", "trFileInfoBox" + idx);
				l_oRow.setAttribute("height", "99%");

				var l_oCell_1 = l_oRow.insertCell(l_oRow.cells.length);
				l_oCell_1.innerHTML = '<td><div class="dragFileBox"><span class="dragFile">icn</span>' + Common.getDic("lbl_DragFile") + '</div></td>';
				l_oCell_1.setAttribute("colspan", "4");
				l_selObj.appendChild(l_oRow); //상단에서 객체 insertRow로 이미 추가됨
			}
		}
	}

	// 삭제한 파일
	var sDeletFiles = document.getElementById("hidDeletFiles").value.split("|");
	var nLength = sDeletFiles.length;
	l_aObjFileListMulti = l_aObjFileListMultiArr[idx-1];

	for (var i = 0; i < nLength - 1; i++) {
		for (var j = 0; j < l_aObjFileListMultiArr[idx-1].length; j++) {
			if (sDeletFiles[i] == l_aObjFileListMultiArr[idx-1][j].name) {
				l_aObjFileListMultiArr[idx-1].splice(j, 1);
				break;
			}
		}
	}

	var sFileInfo = "";
	var sFileInfoTemp = "";
	for (var i = 0; i < l_aObjFileListMulti.length; i++) {
		sFileInfo += l_aObjFileListMulti[i].name + ":" + l_aObjFileListMulti[i].size + ":NEW:0:|";
		sFileInfoTemp += l_aObjFileListMulti[i].name + ":" + l_aObjFileListMulti[i].name.split('.')[l_aObjFileListMulti[i].name.split('.').length - 1] + ":" + l_aObjFileListMulti[i].size + "|";
	}
	document.getElementById("hidFileSize").value = sFileInfoTemp;

	var idx = $("#writeTab li.on").attr('idx');
	//수정 부분 강제 change
	if (_ie) {
		var temp_input = $(document.getElementById("FileSelect" + idx));
		temp_input.replaceWith(temp_input.val('').clone(true));
	} else {
		document.getElementById("FileSelect" + idx).value = "";
	}
	$("#FileSelect" + idx).change();
}

function setFormAttachFileInfoMulti(idx, bPlain) {
	var strOldAttachFileInfo = $('#SubTable1 .multi-row').find('[name=MULTI_ATTACH_FILE]')[idx-1].value;
	var oldAttachFileInfoLength = 0;
	var oldAttachFileInfoArr = new Array();
	var formAttachFileInfoObj = {};
	var objArr = new Array();
	var fileSeq = 0;

	if (strOldAttachFileInfo != "" && strOldAttachFileInfo != undefined && strOldAttachFileInfo != "undefined") {
		oldAttachFileInfoLength = $$(strOldAttachFileInfo).json().FileInfos.length;
		oldAttachFileInfoArr = $$(strOldAttachFileInfo).json().FileInfos;
	}

	var fileInfos = (strOldAttachFileInfo != "" && strOldAttachFileInfo != undefined && strOldAttachFileInfo != "undefined") ? $.parseJSON(strOldAttachFileInfo).FileInfos : "";

	if ($("#fileInfo" + idx + " [name=chkFile]").length > 0) {
		$("#fileInfo" + idx + " [name=chkFile]").each(function(i, checkObj) {
			var obj = {};
			var strArrObj = $(checkObj).val().split(":");
			
			if (strArrObj[2] == "OLD" || strArrObj[2] == "REUSE") {
				$(fileInfos).each(function(j, oldObj) {
					// 유지되는 파일은 파일정보를 그대로 가진다.
					if (oldObj.SavedName == strArrObj[3]) {
						if(!bPlain) oldObj.FileName = encodeURIComponent(oldObj.FileName); // 미리보기시 인코딩 안함
						objArr.push(oldObj);
						fileSeq++;
					}
				});
			} else if (strArrObj[2] == "NEW") {
				var strFormInstID = getInfo("FormInstanceInfo.FormInstID") == undefined ? "" : getInfo("FormInstanceInfo.FormInstID");
				
				$$(obj).append("ID", strFormInstID + "_" + fileSeq);
				$$(obj).append("FileName", (bPlain ? strArrObj[1] : encodeURIComponent(strArrObj[1]))); // 미리보기시 인코딩 안함
				$$(obj).append("Type", strArrObj[2]);
				$$(obj).append("AttachType", strArrObj[4]); //webhard or normal
				$$(obj).append("UserCode", getInfo("AppInfo.usid"));
				if(strArrObj.length > 6) $$(obj).append("OriginID", strArrObj[6]); // edms 원파일 fileid
				
				if(strArrObj[4] == "webhard"){
					$$(obj).append("SavedName", strArrObj[3]); 
				}
				
				objArr.push(obj);
			}
		});
	}

	if (objArr.length > 0) {
		$$(formAttachFileInfoObj).append("FileInfos", objArr);
		$('#SubTable1 .multi-row').find('[name=MULTI_ATTACH_FILE]')[idx-1].value = JSON.stringify($$(formAttachFileInfoObj).json());
	} else {
		$("#AttachFileInfo").val("");
		$('#SubTable1 .multi-row').find('[name=MULTI_ATTACH_FILE]')[idx-1].value = "";
	}
}

function clearDeleteFrontMulti() {
	document.getElementById("hidDeleteFront").value = "";
}

//파일 아이콘 class 타입 구별
function setFileIconClassMulti(extention) {
	var strReturn = "";

	if (extention == "xls" || extention == "xlsx") {
		strReturn = "exCel";
	} else if (extention == "jpg" || extention == "JPG" || extention == "png" || extention == "PNG" || extention == "bmp") {
		strReturn = "imAge";
	} else if (extention == "doc" || extention == "docx") {
		strReturn = "woRd";
	} else if (extention == "ppt" || extention == "pptx") {
		strReturn = "pPoint";
	} else if (extention == "txt") {
		strReturn = "teXt";
	} else {
		strReturn = "etcFile";
	}

	return strReturn;
}

// 파일 사이즈의 값 변환
function ConvertFileSizeUnitMulti(pSize) {
	var nSize = 0;
	var sUnit = "Byte";

	nSize = pSize;
	if (nSize >= 1024) {
		nSize = nSize / 1024;
		sUnit = "KB";
	}
	if (nSize >= 1024) {
		nSize = nSize / 1024;
		sUnit = "MB";
	}
	if (nSize >= 1024) {
		nSize = nSize / 1024;
		sUnit = "GB";
	}
	if (nSize >= 1024) {
		nSize = nSize / 1024;
		sUnit = "TB";
	}
	var sReturn = (Math.round(nSize) + (Math.round(nSize) - nSize)).toFixed(1) + sUnit;
	return sReturn;
}
//--------------------------------------------- 첨부파일 컨트롤 끝 ------------------------------------------------------- 

// 읽기모드일 경우 화면에 첨부목록 화면 세팅
function formDisplaySetFileInfoMulti() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		var MultiTabCnt = JSON.stringify(formJson.BodyData.SubTable1.length);
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var fileInfoHtml = "";
			var fileInfos = "";
			if(item.MULTI_ATTACH_FILE != null && item.MULTI_ATTACH_FILE != "" && item.MULTI_ATTACH_FILE != "undefined"){
				//var multiAttachFile = Base64.b64_to_utf8(item.MULTI_ATTACH_FILE.replace(/\"/gi, '').replace(/\\\\/gi, ''));
				
				fileInfos = typeof(item.MULTI_ATTACH_FILE) == "string" ? $.parseJSON(item.MULTI_ATTACH_FILE).FileInfos : item.MULTI_ATTACH_FILE.FileInfos;
			}
	
			if (fileInfos != undefined && fileInfos.length > 0) {
				$("#trFileInfoBox").hide();
				var formIdx = "";
				$(fileInfos).each(function(i, fileInfoObj) {
					var className = setFileIconClass($$(fileInfoObj).attr("Extention"));
					formIdx = $$(fileInfoObj).attr("ObjectID");
					if (MultiTabCnt == 1 ) formIdx = 1;
					fileInfoHtml += "<dl class='excelData'><dt>";
					
					fileInfoHtml += "<a onclick='MultiattachFileDownLoadCall("+ (formIdx-1) + ", "+ i + ")' >";
					fileInfoHtml += "<span class='" + className + "'>파일첨부</span>";
					fileInfoHtml += "<span class='fileName'>"+$$(fileInfoObj).attr("FileName")+"</span>";
					fileInfoHtml += "<span class='fileSize'>(" + ConvertFileSizeUnit($$(fileInfoObj).attr("Size")) + ")</span>";
					fileInfoHtml += "</a>";
					
					fileInfoHtml += "</dt>";
					if (CFN_GetQueryString("listpreview") != "Y") {
						fileInfoHtml += "<dd>";
						fileInfoHtml += "<a class='previewBtn fRight' href='javascript:void(0);' onclick='attachFilePreview(\"" + $$(fileInfoObj).attr("FileID").trim() + "\",\"" + $$(fileInfoObj).attr("FileToken") + "\",\"" + $$(fileInfoObj).attr("Extention") + "\");'>" + Common.getDic("lbl_preview") + "</a>";
						fileInfoHtml += "</dd>";
					}
					fileInfoHtml += "</dl>";
				});
				
				$("#AttFileInfo" + formIdx).html(fileInfoHtml);
				if(formIdx != undefined){
					$("#TIT_ATTFILEINFO" + formIdx).html(Common.getDic("lbl_apv_AddFile") + "<br/><a class='totDownBtn' href='javascript:void(0);' onclick='Common.downloadAll(" + fileInfos + ");' href='javascript:void(0);'>" + Common.getDic("lbl_download_all") + "</a>");
				}
			}
		});
	}
}

// 읽기모드일 경우 화면에 연결문서 목록 세팅
function formDisplaySetDocLinkInfoMulti() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docLinkInfos = "";
			if(item.MULTI_LINK_DOC != null && item.MULTI_LINK_DOC != "" && item.MULTI_LINK_DOC != "undefined"){
				docLinkInfos = item.MULTI_LINK_DOC;
			}
	
			if (docLinkInfos != undefined && docLinkInfos != "") {
				if(document.getElementsByName("MULTI_LINK_DOC").length > 1) {
					document.getElementsByName("MULTI_LINK_DOC")[idx+1].value = docLinkInfos;
				}
				docLinks.init(idx+1);
			}
		});
	}
}


//읽기모드일 경우 화면에 제목 목록 세팅
function formDisplaySetSubjectnfoMulti() {
	$("#tblFormSubjectMulti").show();
	
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docSubject = "";
			
			if(item.MULTI_TITLE != null && item.MULTI_TITLE != "" && item.MULTI_TITLE != "undefined"){
				docSubject = item.MULTI_TITLE.replace(/&#39;/gi, "\'"); //
			}
	
			if(document.getElementsByName("MULTI_TITLE").length > 1) {
				document.getElementsByName("MULTI_TITLE")[idx+1].value = docSubject;
			}
			
			G_displaySpnSubjectInfoMulti(idx+1);
		});
	}
}

//읽기모드일 경우 화면에 수신처 목록 세팅
function formDisplaySetReceiveInfoMulti() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docReceiveInfos = "";//수신자
			
			if(item.MULTI_RECEIVENAMES != "" && item.MULTI_RECEIVENAMES != undefined){
				docReceiveInfos = item.MULTI_RECEIVENAMES;
			}
			
			if(document.getElementsByName("MULTI_RECEIVENAMES").length > 1) {
				document.getElementsByName("MULTI_RECEIVENAMES")[idx+1].value = docReceiveInfos;
			}
			
			G_displaySpnReceiveInfoMulti(idx+1);
		});
	}
}

//읽기모드일 경우 화면에 기록물철 목록 세팅
function formDisplaySetRecordInfoMulti() {
	$("#tblFormSubjectMulti").show();
	
	if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	if($$(m_oApvList).find("steps>division[processID=" + getInfo("ProcessInfo.ProcessID") + "]").attr("divisiontype") == "receive") {
		G_displaySpnRecordInfoMulti("dist");
	} else {
		if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
			$(formJson.BodyData.SubTable1).each(function(idx, item){
				var recordInfos = "";
				if(item.MULTI_RECORD_SUBJECT != null && item.MULTI_RECORD_SUBJECT != "" && item.MULTI_RECORD_SUBJECT != "undefined"){
					recordInfos = item.MULTI_RECORD_SUBJECT;
				}
		
				if (recordInfos) {
					if(document.getElementsByName("MULTI_RECORD_SUBJECT").length > 1) {
						document.getElementsByName("MULTI_RECORD_SUBJECT")[idx+1].value = recordInfos;
					}
					
					G_displaySpnRecordInfoMulti(idx+1);
				}
			});
		}
	}
}

//--------------------------------------------- 일반에디터 문서유통 사용 시 필요 -------------------------------------------------------


// 문서유통 웹에디터 읽기모드일 경우 화면에 수신 목록 세팅
function formDisplaySetDocRecLineList_Multi() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docDocReclineInfos = "";//수신자
			
			if(item.MULTI_DOC_RECLINE != "" && item.MULTI_DOC_RECLINE != undefined){
				docDocReclineInfos = item.MULTI_DOC_RECLINE;
			}
			
			if(document.getElementsByName("MULTI_DOC_RECLINE").length > 1) {
				document.getElementsByName("MULTI_DOC_RECLINE")[idx+1].value = docDocReclineInfos;
			}
			
			G_displaySpnDocReclineInfoMulti(idx+1);
		});
	}
}

// 문서유통 웹에디터 읽기모드일 경우 화면에 제목 목록 세팅
function formDisplaySetSubjectList_Multi() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docSubjectInfos = "";//수신자
			
			if(item.MULTI_TITLE != "" && item.MULTI_TITLE != undefined){
				docSubjectInfos = item.MULTI_TITLE;
			}
			
			if(document.getElementsByName("MULTI_TITLE").length > 1) {
				document.getElementsByName("MULTI_TITLE")[idx+1].value = docSubjectInfos;
			}
			
			G_displaySpnSubjectEditorInfoMulti(idx+1);
		});
	}
}

//문서유통 웹에디터 읽기모드일 경우 화면에 전화번호 목록 세팅
function formDisplaySetPhoneNumList_Multi() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docSubjectInfos = "";//수신자
			
			if(item.MULTI_TELEPHONE != "" && item.MULTI_TELEPHONE != undefined){
				docSubjectInfos = item.MULTI_TELEPHONE;
			}
			
			if(document.getElementsByName("MULTI_TELEPHONE").length > 1) {
				document.getElementsByName("MULTI_TELEPHONE")[idx+1].value = docSubjectInfos;
			}
			
			G_displaySpnPhoneNumEditorInfoMulti(idx+1);
		});
	}
}

//문서유통 웹에디터 읽기모드일 경우 화면에 팩스번호 목록 세팅
function formDisplaySetFaxNumList_Multi() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docSubjectInfos = "";//수신자
			
			if(item.MULTI_FAX != "" && item.MULTI_FAX != undefined){
				docSubjectInfos = item.MULTI_FAX;
			}
			
			if(document.getElementsByName("MULTI_FAX").length > 1) {
				document.getElementsByName("MULTI_FAX")[idx+1].value = docSubjectInfos;
			}
			
			G_displaySpnFaxNumEditorInfoMulti(idx+1);
		});
	}
}

//문서유통 웹에디터 읽기모드일 경우 화면에 홈페이지 목록 세팅
function formDisplaySetHomePageList_Multi() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docSubjectInfos = "";//수신자
			
			if(item.MULTI_TITLE != "" && item.MULTI_HOMEURL != undefined){
				docSubjectInfos = item.MULTI_HOMEURL;
			}
			
			if(document.getElementsByName("MULTI_HOMEURL").length > 1) {
				document.getElementsByName("MULTI_HOMEURL")[idx+1].value = docSubjectInfos;
			}
			
			G_displaySpnHomePageEditorInfoMulti(idx+1);
		});
	}
}

//문서유통 웹에디터 읽기모드일 경우 화면에 이메일 목록 세팅
function formDisplaySetEmailList_Multi() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docSubjectInfos = "";//수신자
			
			if(item.MULTI_EMAIL != "" && item.MULTI_EMAIL != undefined){
				docSubjectInfos = item.MULTI_EMAIL;
			}
			
			if(document.getElementsByName("MULTI_EMAIL").length > 1) {
				document.getElementsByName("MULTI_EMAIL")[idx+1].value = docSubjectInfos;
			}
			
			G_displaySpnEmailEditorInfoMulti(idx+1);
		});
	}
}

//문서유통 웹에디터 읽기모드일 경우 화면에 우편번호 목록 세팅
function formDisplaySetZipCodeList_Multi() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docSubjectInfos = "";//수신자
			
			if(item.MULTI_ZIPCODE != "" && item.MULTI_ZIPCODE != undefined){
				docSubjectInfos = item.MULTI_ZIPCODE;
			}
			
			if(document.getElementsByName("MULTI_ZIPCODE").length > 1) {
				document.getElementsByName("MULTI_ZIPCODE")[idx+1].value = docSubjectInfos;
			}
			
			G_displaySpnZipCodeEditorInfoMulti(idx+1);
		});
	}
}

//문서유통 웹에디터 읽기모드일 경우 화면에 주소 목록 세팅
function formDisplaySetAddressList_Multi() {
	if(getInfo('BodyData.SubTable1') != '' && formJson.BodyData.SubTable1 != undefined){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var docSubjectInfos = "";//수신자
			
			if(item.MULTI_ADDRESS != "" && item.MULTI_ADDRESS != undefined){
				docSubjectInfos = item.MULTI_ADDRESS;
			}
			
			if(document.getElementsByName("MULTI_ADDRESS").length > 1) {
				document.getElementsByName("MULTI_ADDRESS")[idx+1].value = docSubjectInfos;
			}
			
			G_displaySpnAddressEditorInfoMulti(idx+1);
		});
	}
}

//--------------------------------------------- 일반에디터 문서유통 사용 시 필요  끝-------------------------------------------------------


//다안기안용 제목
function G_displaySpnSubjectInfoMulti(idx) {
	if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_TITLE")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(isUseHWPEditor()) {
			var oMultiCtrl = getMultiCtrlEditor();
			
			$(oMultiCtrl)[0].PutFieldText('SUBJECT', $("[name='MULTI_TITLE']").eq(idx).val());
		} else {
			if(document.getElementById("Subject" + idx) != undefined) {
		    	document.querySelector("#Subject" + idx + " input").value = szsubjectinfo;
		    }
		}
	} else {
		if(document.getElementById("Subject" + idx) != undefined) {
	    	document.getElementById("Subject" + idx).innerHTML = szsubjectinfo;
	    }
	}
}

//다안기안용 수신처 표시
function G_displaySpnReceiveInfoMulti(idx) {
	if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szreceiveinfo = "";//수신처
	var szreceiveinfoEx = "";//외부수신처
	var recname="";
	szreceiveinfo = document.getElementsByName("MULTI_RECEIVENAMES")[idx].value;
	
	if(szreceiveinfo!=""){
 	var recarr = szreceiveinfo.split(';');
 	var recnametmp;
 	
 	for(var i=0;i<recarr.length;i++){
 		recnametmp = recarr[i].split(':');
 		recname +=recnametmp[2].split('^')[0]+", ";
 	}
 	
 	recname = recname.slice(0,-2);
	}
	

	 if (szreceiveinfo!="" && szreceiveinfoEx!=undefined){
		 recname += (szreceiveinfoEx != "")?", " + szreceiveinfoEx:szreceiveinfoEx;
	 }
	 else if(szreceiveinfo=="" && szreceiveinfoEx!=undefined){
		 recname +=szreceiveinfoEx;
	 }
	
 if(document.getElementById("RecLine"+idx) != undefined && recname != "") {
 	document.getElementById("RecLine"+idx).innerHTML = recname;
 }
}

//다안기안용 기록물철 표시
function G_displaySpnRecordInfoMulti(idx, pDocInfo) {
	var receiveDocInfo;
	var szsubjectinfo = "";
	
	if(idx != "dist") {
		szsubjectinfo = $("[name='MULTI_RECORD_SUBJECT']").eq(idx).val();
	} else {
		if(pDocInfo) {
			receiveDocInfo = pDocInfo;
			szsubjectinfo = receiveDocInfo.RECORD_SUBJECT;
		} else if(!receiveDocInfo) {
			receiveDocInfo = getReceiveGovDocInfo();
			szsubjectinfo = receiveDocInfo.MULTI_RECORD_SUBJECT;
		}
	}
	
	$("#RecordInfo" + (idx == "dist" ? "1" : idx)).html(szsubjectinfo);
}

//--------------------------------------------- 일반에디터 문서유통 사용 시 필요  시작-------------------------------------------------------

// 문서유통 웹에디터 다안기안용 수신 목록
function G_displaySpnDocReclineInfoMulti(idx) {
	// if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_DOC_RECLINE")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(document.getElementById("DocRecLine" + idx) != undefined) {
	    	document.querySelector("#DocRecLine" + idx + " input").value = szsubjectinfo;
		}
	} else {
		if(document.getElementById("DocRecLine" + idx) != undefined) {
	    	document.getElementById("DocRecLine" + idx).innerHTML = szsubjectinfo;
	    }
	}
}

// 문서유통 웹에디터 다안기안용 제목 목록
function G_displaySpnSubjectEditorInfoMulti(idx) {
	// if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_TITLE")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(document.getElementById("Title" + idx) != undefined) {
	    	document.querySelector("#Title" + idx + " input").value = szsubjectinfo;
	    }
	} else {
		if(document.getElementById("Title" + idx) != undefined) {
	    	document.getElementById("Title" + idx).innerHTML = szsubjectinfo;
	    }
	}
}


//문서유통 웹에디터 다안기안용 전화번호 목록
function G_displaySpnPhoneNumEditorInfoMulti(idx) {
	// if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_TELEPHONE")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(document.getElementById("DocPhoneNum" + idx) != undefined) {
	    	document.querySelector("#DocPhoneNum" + idx + " input").value = szsubjectinfo;
	    }
	} else {
		if(document.getElementById("DocPhoneNum" + idx) != undefined) {
	    	document.getElementById("DocPhoneNum" + idx).innerHTML = szsubjectinfo;
	    }
	}
}

//문서유통 웹에디터 다안기안용 팩스번호 목록
function G_displaySpnFaxNumEditorInfoMulti(idx) {
	// if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_FAX")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(document.getElementById("DocFaxNum" + idx) != undefined) {
	    	document.querySelector("#DocFaxNum" + idx + " input").value = szsubjectinfo;
	    }
	} else {
		if(document.getElementById("DocFaxNum" + idx) != undefined) {
	    	document.getElementById("DocFaxNum" + idx).innerHTML = szsubjectinfo;
	    }
	}
}

//문서유통 웹에디터 다안기안용 홈페이지 목록
function G_displaySpnHomePageEditorInfoMulti(idx) {
	// if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_HOMEURL")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(document.getElementById("DocHomePage" + idx) != undefined) {
	    	document.querySelector("#DocHomePage" + idx + " input").value = szsubjectinfo;
	    }
	} else {
		if(document.getElementById("DocHomePage" + idx) != undefined) {
	    	document.getElementById("DocHomePage" + idx).innerHTML = szsubjectinfo;
	    }
	}
}

//문서유통 웹에디터 다안기안용 이메일 목록
function G_displaySpnEmailEditorInfoMulti(idx) {
	// if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_EMAIL")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(document.getElementById("DocEmail" + idx) != undefined) {
	    	document.querySelector("#DocEmail" + idx + " input").value = szsubjectinfo;
	    }
	} else {
		if(document.getElementById("DocEmail" + idx) != undefined) {
	    	document.getElementById("DocEmail" + idx).innerHTML = szsubjectinfo;
	    }
	}
}

//문서유통 웹에디터 다안기안용 우편번호 목록
function G_displaySpnZipCodeEditorInfoMulti(idx) {
	// if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_ZIPCODE")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(document.getElementById("DocZipCode" + idx) != undefined) {
	    	document.querySelector("#DocZipCode" + idx + " input").value = szsubjectinfo;
	    }
	} else {
		if(document.getElementById("DocZipCode" + idx) != undefined) {
	    	document.getElementById("DocZipCode" + idx).innerHTML = szsubjectinfo;
	    }
	}
}

//문서유통 웹에디터 다안기안용 주소 목록
function G_displaySpnAddressEditorInfoMulti(idx) {
	// if (isGovMulti()) { return; } // 다안기안 + 문서유통일때는 처리 하지 않는다.
	var szsubjectinfo = document.getElementsByName("MULTI_ADDRESS")[idx].value;
	
	if(getInfo("Request.templatemode") == "Write") {
		if(document.getElementById("DocAddress" + idx) != undefined) {
	    	document.querySelector("#DocAddress" + idx + " input").value = szsubjectinfo;
	    }
	} else {
		if(document.getElementById("DocAddress" + idx) != undefined) {
	    	document.getElementById("DocAddress" + idx).innerHTML = szsubjectinfo;
	    }
	}
}

//--------------------------------------------- 일반에디터 문서유통 사용 시 필요  끝-------------------------------------------------------

function MultiattachFileDownLoadCall(tabidx, index) {
	if(formJson.BodyData.SubTable1 != undefined) {
		var fileInfoObj = formJson.BodyData.SubTable1[tabidx].MULTI_ATTACH_FILE;
		
		if(typeof fileInfoObj == "string") {
			fileInfoObj = $.parseJSON(Base64.b64_to_utf8(fileInfoObj));
		}
		
		fileInfoObj = fileInfoObj.FileInfos[index];
		
		Common.fileDownLoad($$(fileInfoObj).attr("FileID"), $$(fileInfoObj).attr("FileName"), $$(fileInfoObj).attr("FileToken"));
	}
}

function checkForm_HWPMulti(){
    var isSenderEmpty = false;
    var isSubjectEmpty = false;
    var isBodyEmpty = false;
    var isSenderCheck = false;
    $('[id^=tbContentElement][doctype=normal]').each(function(idx, item){
    	HwpCtrl = $(item)[0];
		if(HwpCtrl.GetFieldText == undefined) {
			HwpCtrl = $(item)[0].contentWindow.HwpCtrl;
		}
        var sender = HwpCtrl.GetFieldText("sendername");
        var subject = HwpCtrl.GetFieldText("SUBJECT");
        var body = HwpCtrl.GetFieldText("BODY");
        var reciever = HwpCtrl.GetFieldText("recipient_single");
        // 다안기안 + 문서유통일때 처리
		if (isGovMulti()) {
	        sender = HwpCtrl.GetFieldText("chief");
	        subject = HwpCtrl.GetFieldText("doctitle");
	        body = HwpCtrl.GetFieldText("body");
	        //reciever = HwpCtrl.GetFieldText("recipient_single");
		}
	
        if(subject.trim() == ""){
        	isSubjectEmpty = true;
        }
        if(sender.trim() == "" && $(".multi-row input[name=MULTI_RECEIVENAMES]").eq(idx) != null && $(".multi-row input[name=MULTI_RECEIVENAMES]").eq(idx).val() != ""){
        	isSenderEmpty = true;
        }
        if(body == ""){
        	isBodyEmpty = true;
        }
        if(reciever == "내부결재" && sender.trim() != ""){
        	isSenderCheck = true;
        }
    });
    
	if(isSenderEmpty){
	    Common.Warning("발신명의가 입력되지 않았습니다.");
	    return false;
	}
	if(isSenderCheck){
	    Common.Warning("발신명의를 확인해 주시기 바랍니다.");
	    return false;
	}
	if(isSubjectEmpty){
	    Common.Warning("제목이 입력되지 않았습니다.");
	    return false;
	}
	
    if (document.getElementById("FILEATTACH") != null && document.getElementById("FILEATTACH").value == "false") {
        Common.Warning("파일은 최대 3MB까지 업로드 가능합니다.");
        return false;
    }
	
	/*if(isBodyEmpty){ // 이미지만 붙여넣기 하여 기안시 빈값체크됨
	    Common.Warning("본문이 입력되지 않았습니다.");
	    return false;
	}*/
	return true;
}

function checkForm_Multi(){
    var bSuccess = true;
	
    $("[id^=tbContentElement]").each(function(idx, obj){
    	$("#tblMultiDraftInfo > #SubTable1").find(".multi-row").eq(idx).find("input[required]").each(function(j, elm) {
    		if(!$(elm).val().trim()) {
    			Common.Warning(Common.getDic("msg_apv_chkMultiDraftRequired").format((idx + 1), $(elm).attr("title")));
    			bSuccess = false;
    			
    			return false;
    		}
    	});
    	
        if(!bSuccess) {
        	return false;
        }
    });
 
	return bSuccess;
}

function insertChiefsign(HwpCtrl, empno){
	var filePath = "";
	var gfileId = getUserSignInfo(empno);
	var curIdx = $("#writeTab li.on").attr("idx");
	
	if(gfileId != "" && gfileId != null && curIdx != "" && curIdx != null){
		filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(gfileId);
		if(formJson.BodyData.SubTable1 != undefined && formJson.BodyData.SubTable1[curIdx - 1] != undefined) {
			var SubTable1 = formJson.BodyData.SubTable1[curIdx - 1];
			if(SubTable1.MULTI_RECEIVER_TYPE == "In" && SubTable1.MULTI_RECEIVENAMES != null && SubTable1.MULTI_RECEIVENAMES != "") {
				HwpCtrl.PutFieldText("chief_sign", "   ");
				HwpCtrl.MoveToField("chief_sign", true, true, true);
				HwpCtrl.SetTextFile(getFileBinaryData(gfileId,20,20), "HTML", "insertfile",function(data){
					HwpCtrl.MoveToField("body", true, true, false);
					if(data.result) {
						HwpCtrl.PutFieldText("isStamp", "Y");
					} else {
						HwpCtrl.PutFieldText("isStamp", " ");
					}
				});
			}
		}
	}
}

function insertChiefsignMobile(empno){	
	var gfileId = getUserSignInfo(empno);
	var curIdx = $("#writeTab li.on").attr("idx");
	
	if(gfileId != "" && gfileId != null && curIdx != "" && curIdx != null){
		if(formJson.BodyData.SubTable1 != undefined && formJson.BodyData.SubTable1[curIdx - 1] != undefined) {
			var SubTable1 = formJson.BodyData.SubTable1[curIdx - 1];
			if(SubTable1.MULTI_RECEIVER_TYPE == "In" && SubTable1.MULTI_RECEIVENAMES != null && SubTable1.MULTI_RECEIVENAMES != "") {
				$("#chief_sign").html($("<img>", {"src" : mobile_comm_getGlobalProperties("mobile.smart4j.path") 
    				+ mobile_comm_getImgById("", gfileId)}));
			}
		}
	}
}


function getFilePath(fileId) {
	var filePath = "";
	$.ajax({
		url	:"/govdocs/service/getFilePath.do?",
		type: "POST",
		async: false,
		data: {
			fileId : fileId
		},
		success:function (data) {
			filePath = data;
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
		}
	});
	
	return Common.agentFilterGetData("smart4j.path", "P") + filePath;
}

function getFileBinaryData(fileId,width,height) {
	var fileBinaryData = "";
	$.ajax({
		url	:"/govdocs/service/getBianary.do?",
		type: "POST",
		async: false,
		data: {
			fileId : fileId
		},
		success:function (data) {
			fileBinaryData = '<img width='+width+' height='+height+' src="data:image/png;base64,'+ data+ '">'; 
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
		}
	});
	
	return  fileBinaryData;  
}

function drawApvLineHWP(){
//	$("[id^=tbContentElement][doctype=normal]").each(function(idx, item){
//		HwpCtrl = $(item)[0];
//		if(HwpCtrl.PutFieldText == undefined) {
//			HwpCtrl = $(item)[0].contentWindow.HwpCtrl;
//		}
//		for(var i=0; i <= 8; i++){
//			HwpCtrl.PutFieldText("ap" + i + "_position", " ");
//			HwpCtrl.PutFieldText("apb" + i + "_sign", " ");
//		}
//		for(var j=0; j <= 7; j++){
//			HwpCtrl.PutFieldText("as" + j + "_position", " ");
//			HwpCtrl.PutFieldText("as" + j + "_sign", " ");
//		}
//	});
//
//	if(getInfo("FormInfo.FormPrefix") == "WF_FORM_SB_MULTI_AUDIT_DRAFT"){
//		$("[id^=tbContentElement][doctype=audit]").each(function(idx, item){
//			HwpCtrl = $(item)[0];
//			if(HwpCtrl.PutFieldText == undefined) {
//				HwpCtrl = $(item)[0].contentWindow.HwpCtrl;
//			}
//			for(var i=0; i <= 4; i++){
//				HwpCtrl.PutFieldText("ap" + i + "_position", " ");
//				HwpCtrl.PutFieldText("apb" + i + "_sign", " ");
//			}
//		});
//	}

	m_oApvList = JSON.parse($('#APVLIST').val());//document.getElementById("APVLIST").value
    oApvList = m_oApvList;
    
    var draftDept = "";
    var receiveDept = "";
    var gfileId ="";
    
    if(oApvList.steps == undefined || oApvList.steps.division == null ){
    	return false;
    }
    if(oApvList.steps.division[0] != null && oApvList.steps.division.length > 1){
    	draftDept = oApvList.steps.division[0].step;
    	receiveDept = oApvList.steps.division.filter(arr => arr.divisiontype == "receive")[0].step;
    } else {
    	draftDept = oApvList.steps.division.step;
    }
    
    // 양식프로세스 > 결재유형옵션 > 문서유통 == Y && 양식 > 양식본문정보 > 한글웹기안기 == Y
    if (getInfo("ExtInfo.UseWebHWPEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y") {
    	$("[id^=divWebEditorContainer]:visible > [id^=tbContentElement][doctype=normal]").each(function(idx, item){
		    HwpCtrl = $(item)[0];
			if(HwpCtrl.PutFieldText == undefined) {
				HwpCtrl = $(item)[0].contentWindow.HwpCtrl;
			}
	    	if (HwpCtrl) {
	    		for (var i = 0; i <= 7; i++) { 
		    		HwpCtrl.PutFieldText(`approve-jikwe{{${i}}}`, " ");
		    		HwpCtrl.PutFieldText(`approve-date{{${i}}}`, " ");
		    		HwpCtrl.PutFieldText(`approve-name{{${i}}}`, " ");
		    		
		    		HwpCtrl.PutFieldText(`assist-jikwe{{${i}}}`, " ");
		    		HwpCtrl.PutFieldText(`assist-date{{${i}}}`, " ");
		    		HwpCtrl.PutFieldText(`assist-name{{${i}}}`, " ");
		    		
		    		HwpCtrl.PutFieldText(`receive-jikwe{{${i}}}`, " ");
		    		HwpCtrl.PutFieldText(`receive-date{{${i}}}`, " ");
		    		HwpCtrl.PutFieldText(`receive-name{{${i}}}`, " ");
		    	}
		    	
		    	var draftDeptLength = Array.isArray(draftDept) ? draftDept.length : 1;
		    	
		    	if (Array.isArray(draftDept)) {
			    	/*for (var i = 0; i < draftDept.length; i++) {
			    		HwpCtrl.PutFieldText("jikwe" + (i + 1), CFN_GetDicInfo(draftDept[i].ou.person.position.split(";").splice(1).join(";")));
			    		if (draftDept[i].ou.person.taskinfo.datecompleted) {
			    			var completedDate = new Date(draftDept[i].ou.person.taskinfo.datecompleted);
			    			var formatDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
			    			HwpCtrl.PutFieldText("sign" + (i + 1), formatDate + " " + CFN_GetDicInfo(draftDept[i].ou.person.name));
			    			continue;
			    		}
			    		HwpCtrl.PutFieldText("sign" + (i + 1), CFN_GetDicInfo(draftDept[i].ou.person.name));
			    	}*/
			    	
		    		// 발신
		    		var approve = draftDept.filter(arr => arr.routetype == 'approve');
			    	
			    	for (var i = 0; i < approve.length; i++) {
			    		
			    		// 전달 처리
			    		if(approve[i].ou.person.length>0){
			    			if($$(approve[i].ou).has("person > taskinfo[kind='conveyance']").length > 0){
			    				var conveyanceIdx = $$(approve[i].ou).find("person > taskinfo[kind='conveyance']").last().parent().index();
			    				approve[i].ou.person = approve[i].ou.person[parseInt(conveyanceIdx)+1];
			    			}
			    		}
			    		
			    		var jikwe = CFN_GetDicInfo(approve[i].ou.person.position.split(";").splice(1).join(";"));
			    		var date = approve[i].name;
			    		var name = CFN_GetDicInfo(approve[i].ou.person.name);
			    		
			    		if (approve[i].ou.person.taskinfo.datecompleted) {
			    			var completedDate = new Date(approve[i].ou.person.taskinfo.datecompleted);
			    			var formatDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
			    			
			    			date = formatDate + " " + date;
			    		}
			    		
			    		HwpCtrl.PutFieldText(`approve-jikwe{{${i}}}`, jikwe);
			    		HwpCtrl.PutFieldText(`approve-date{{${i}}}`, date);
			    		HwpCtrl.PutFieldText(`approve-name{{${i}}}`, name);
			    		HwpCtrl.PutFieldText(`approve-sign{{${i}}}`, " ");
			    		
			    		if (approve[i].ou.person.taskinfo.customattribute1) {
			    			// 해당 소스 안되면 아래 소스 사용
			    			// var filePath = getFilePath(approve[i].ou.person.taskinfo.customattribute1);
//			    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(approve[i].ou.person.taskinfo.customattribute1);
//							HwpCtrl.MoveToField(`approve-sign{{${i}}}`, true, false, true);
//                            HwpCtrl.InsertPicture(filePath, true, 1, false, false, 0, 6, 4);
			    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(approve[i].ou.person.taskinfo.customattribute1);
			    			gfileId =approve[i].ou.person.taskinfo.customattribute1;
							m_arrConverImgArr.push({
								TYPE:"APVLINE",
								IMGNAME:`approve-sign{{${i}}}`,
								FILEPATH :filePath,
								WIDTH: 30,
								HEIGHT :20,					
								BINARYDATA :getFileBinaryData(gfileId,30,20)				
							});
			    		}
			    	}
			    	// 협조
				    var asiseq = 0;
			    	var assist = draftDept.filter(arr => arr.routetype == 'assist');
			    	
			    	for (var i = 0; i < assist.length; i++) {
			    		var jikwe = "";
			    		var date = "";
			    		var name = "";
			    		
			    		if(Array.isArray(assist[i].ou)) {
			    			for (var j = 0; j < assist[i].ou.length; j++) {
					    		jikwe = CFN_GetDicInfo(assist[i].ou[j].person.position.split(";").splice(1).join(";"));
					    		date = assist[i].name;
					    		name = CFN_GetDicInfo(assist[i].ou[j].person.name);
					    		
					    		if (assist[i].ou[j].person.taskinfo.datecompleted) {
					    			var completedDate = new Date(assist[i].ou[j].person.taskinfo.datecompleted);
					    			var formatDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
					    			
					    			date = formatDate + " " + date;
					    		}

					    		HwpCtrl.PutFieldText(`assist-jikwe{{${asiseq}}}`, jikwe);
					    		HwpCtrl.PutFieldText(`assist-date{{${asiseq}}}`, date);
					    		HwpCtrl.PutFieldText(`assist-name{{${asiseq}}}`, name);
					    		HwpCtrl.PutFieldText(`assist-sign{{${asiseq}}}`, " ");
					    		
					    		if (assist[i].ou[j].person.taskinfo.customattribute1) {
					    			// 해당 소스 안되면 아래 소스 사용
					    			// var filePath = getFilePath(assist[i].ou[j].person.taskinfo.customattribute1);
//					    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(assist[i].ou[j].person.taskinfo.customattribute1);
//									HwpCtrl.MoveToField(`assist-sign{{${asiseq}}}`, true, false, true);
//		                            HwpCtrl.InsertPicture(filePath, true, 1, false, false, 0, 6, 4);
					    			
					    			var filePath =  Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(assist[i].ou[j].person.taskinfo.customattribute1);
					    			gfileId =assist[i].ou[j].person.taskinfo.customattribute1;
									m_arrConverImgArr.push({
										TYPE:"APVLINE",
										IMGNAME:`assist-sign{{${asiseq}}}`,
										FILEPATH :filePath,
										WIDTH: 30,
										HEIGHT :20,					
										BINARYDATA :getFileBinaryData(gfileId,30,20)				
									});
					    		}
					    		asiseq++;
			    			}
						} else {
				    		jikwe = CFN_GetDicInfo(assist[i].ou.person.position.split(";").splice(1).join(";"));
				    		date = assist[i].name;
				    		name = CFN_GetDicInfo(assist[i].ou.person.name);
				    		
				    		if (assist[i].ou.person.taskinfo.datecompleted) {
				    			var completedDate = new Date(assist[i].ou.person.taskinfo.datecompleted);
				    			var formatDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
				    			
				    			date = formatDate + " " + date;
				    		}

				    		HwpCtrl.PutFieldText(`assist-jikwe{{${asiseq}}}`, jikwe);
				    		HwpCtrl.PutFieldText(`assist-date{{${asiseq}}}`, date);
				    		HwpCtrl.PutFieldText(`assist-name{{${asiseq}}}`, name);
				    		HwpCtrl.PutFieldText(`assist-sign{{${asiseq}}}`, " ");
				    		
				    		if (assist[i].ou.person.taskinfo.customattribute1) {
				    			// 해당 소스 안되면 아래 소스 사용
				    			// var filePath = getFilePath(assist[i].ou.person.taskinfo.customattribute1);
//				    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(assist[i].ou.person.taskinfo.customattribute1);
//								HwpCtrl.MoveToField(`assist-sign{{${asiseq}}}`, true, false, true);
//	                            HwpCtrl.InsertPicture(filePath, true, 1, false, false, 0, 6, 4);
				    			
				    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(assist[i].ou.person.taskinfo.customattribute1);
				    			gfileId =assist[i].ou.person.taskinfo.customattribute1;
								m_arrConverImgArr.push({
									TYPE:"APVLINE",
									IMGNAME:`assist-sign{{${asiseq}}}`,
									FILEPATH :filePath,
									WIDTH: 30,
									HEIGHT :20,					
									BINARYDATA :getFileBinaryData(gfileId,30,20)	
								});
				    		}
				    		asiseq++;
						}
			    	}
			    	// 수신
			    	var receive = receiveDept;

			    	for (var i = 0; i < receive.length; i++) {
			    		
			    		// 전달 처리
			    		if(receive[i].ou.person.length>0){
			    			if($$(receive[i].ou).has("person > taskinfo[kind='conveyance']").length > 0){
			    				var conveyanceIdx = $$(receive[i].ou).find("person > taskinfo[kind='conveyance']").last().parent().index();
			    				receive[i].ou.person = receive[i].ou.person[parseInt(conveyanceIdx)+1];
			    			}
			    		}
			    		
			    		var jikwe = CFN_GetDicInfo(receive[i].ou.person.position.split(";").splice(1).join(";"));
			    		var date = receive[i].name;
			    		var name = CFN_GetDicInfo(receive[i].ou.person.name);
			    		
			    		if (receive[i].ou.person.taskinfo.datereceived) {
			    			var completedDate = new Date(receive[i].ou.person.taskinfo.datereceived);
			    			var formatDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
			    			
			    			date = formatDate + " " + date;
			    		}

			    		HwpCtrl.PutFieldText(`receive-jikwe{{${i}}}`, jikwe);
			    		HwpCtrl.PutFieldText(`receive-date{{${i}}}`, date);
			    		HwpCtrl.PutFieldText(`receive-name{{${i}}}`, name);
			    		HwpCtrl.PutFieldText(`receive-sign{{${i}}}`, " ");
			    		
			    		if (receive[i].ou.person.taskinfo.customattribute1) {
			    			// 해당 소스 안되면 아래 소스 사용
			    			// var filePath = getFilePath(receive[i].ou.person.taskinfo.customattribute1);
//			    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(receive[i].ou.person.taskinfo.customattribute1);
//							HwpCtrl.MoveToField(`receive-sign{{${i}}}`, true, false, true);
//                            HwpCtrl.InsertPicture(filePath, true, 1, false, false, 0, 6, 4);
			    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(receive[i].ou.person.taskinfo.customattribute1);
			    			gfileId =receive[i].ou.person.taskinfo.customattribute1;
							m_arrConverImgArr.push({
								TYPE:"APVLINE",
								IMGNAME:`receive-sign{{${i}}}`,
								FILEPATH :filePath,
								WIDTH: 30,
								HEIGHT :20,					
								BINARYDATA :getFileBinaryData(gfileId,30,20)					
							});
			    		}
			    	}
			    	
		    	} else {
		    		var date = draftDept.name;
		    		var name = CFN_GetDicInfo(draftDept.ou.person.name);
		    		if (draftDept.ou.person.taskinfo.datecompleted) {
		    			var completedDate = new Date(draftDept.ou.person.taskinfo.datecompleted);
		    			var formatDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
		    			
		    			date = formatDate + " " + date;
		    		}
		    		HwpCtrl.PutFieldText("approve-jikwe{{0}}", CFN_GetDicInfo(draftDept.ou.person.position.split(";").splice(1).join(";")));
		    		HwpCtrl.PutFieldText("approve-date{{0}}", date);
		    		HwpCtrl.PutFieldText("approve-name{{0}}", CFN_GetDicInfo(draftDept.ou.person.name));
		    		
		    		if (draftDept.ou.person.taskinfo.customattribute1) {
		    			// 해당 소스 안되면 아래 소스 사용
		    			// var filePath = getFilePath(draftDept.ou.person.taskinfo.customattribute1);
//		    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(draftDept.ou.person.taskinfo.customattribute1);
//						HwpCtrl.MoveToField("approve-sign{{0}}", true, false, true);
//                        HwpCtrl.InsertPicture(filePath, true, 1, false, false, 0, 6, 4);
		    			
		    			var filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(draftDept.ou.person.taskinfo.customattribute1);
		    			gfileId =draftDept.ou.person.taskinfo.customattribute1;
						m_arrConverImgArr.push({
							TYPE:"APVLINE",
							IMGNAME:`approve-sign{{${i}}}`,
							FILEPATH :filePath,
							WIDTH: 30,
							HEIGHT :20,					
							BINARYDATA :getFileBinaryData(gfileId,30,20)					
						});
		    		}
		    	}
	    	}
			
			ConvertToBinaryToHWP(HwpCtrl);
    	});
    }
    
    $("[id^=divWebEditorContainer]:visible > [id^=tbContentElement][doctype=normal]").each(function(idx, item){
	    HwpCtrl = $(item)[0];
		if(HwpCtrl.PutFieldText == undefined) {
			HwpCtrl = $(item)[0].contentWindow.HwpCtrl;
		}
	    var apvseq = 1;
	    var asiseq = 1;
	    
	    if(formJson.BodyContext.pubdocinfo != undefined && typeof formJson.BodyContext.pubdocinfo.pubFAppvalInfo.approvalinfo.approval != undefined) {
	    	var pubApv = formJson.BodyContext.pubdocinfo.pubFAppvalInfo.approvalinfo.approval;
    		for(var i=0; i<pubApv.length; i++) {
    			HwpCtrl.PutFieldText("jikwe"+(i+1), pubApv[i].signposition);
    			HwpCtrl.PutFieldText("sign"+(i+1), pubApv[i].name);
    		}
	    } else {
	    	//$(oApvList.steps.division.step).each(function(i, apline){
		    $(draftDept).each(function(i, apline){
				if(apline.unittype == "person" && apline.routetype != "assist" && apvseq <= 8){
					//HwpCtrl.GetFieldText("ap" + (apvseq) + "_position");
					HwpCtrl.PutFieldText("ap" + (apvseq) + "_position", apline.ou.person.title.split(';')[1]);
					if(apline.ou.person.taskinfo.datecompleted != null && apline.ou.person.taskinfo.status == "completed"){
						HwpCtrl.PutFieldText("apb" + (apvseq) + "_sign", apline.ou.person.name.split(';')[0]);
						
						if(draftDept.length == (i+1)){
							if(apline.ou.person.taskinfo.status == "completed"){
								var strKind = "";
								var strDate = "";
							    switch (apline.ou.person.taskinfo.kind) {
							        case "substitute": strKind = Common.getDic("lbl_apv_substitue"); break;
							        case "authorize": strKind = Common.getDic("lbl_apv_authorize"); break;
							        case "bypass": strKind = Common.getDic("lbl_apv_bypass"); break;
							        case "review": strKind = Common.getDic("lbl_apv_review"); break;
							        default : strKind = Common.getDic("lbl_apv_sign_approval"); break;
							    }
							    strDate = formatDate(apline.ou.person.taskinfo.datecompleted, 'SB');
								//HwpCtrl.PutFieldText("ap" + (apvseq) + "_type", strKind);
								//HwpCtrl.PutFieldText("ap" + (apvseq) + "_date", strDate);
								HwpCtrl.PutFieldText("apb" + (apvseq) + "_sign", strKind + " " + strDate + String.fromCharCode(0x0D) + apline.ou.person.name.split(';')[0]);
	
								insertChiefsign(HwpCtrl, apline.ou.person.code); // 대내발송 문서일 경우 발신부서장 서명 삽입
							}
						}
					}
					apvseq++;
				} else if(apline.unittype == "person" && apline.routetype == "assist" && asiseq <= 7){
					if(apline.allottype == "parallel"){
						$(apline.ou).each(function(pidx, pitem){
							if(asiseq <= 7){
								HwpCtrl.PutFieldText("as" + (asiseq) + "_position", pitem.person.title.split(';')[1]);
								if(pitem.person.taskinfo.datecompleted != null){
									HwpCtrl.PutFieldText("as" + (asiseq) + "_sign", pitem.person.name.split(';')[0]);
								}
								asiseq++;
							}
						});
					} else {
						HwpCtrl.PutFieldText("as" + (asiseq) + "_position", apline.ou.person.title.split(';')[1]);
						if(apline.ou.person.taskinfo.datecompleted != null){
							HwpCtrl.PutFieldText("as" + (asiseq) + "_sign", apline.ou.person.name.split(';')[0]);
						}
						asiseq++;
					}
				}
			});
	    }
	});
	if(getInfo("FormInfo.FormPrefix") == "WF_FORM_SB_MULTI_AUDIT_DRAFT"){
		$("[id^=tbContentElement][doctype=audit]").each(function(idx, item){
		    HwpCtrl = $(item)[0];
			if(HwpCtrl.PutFieldText == undefined) {
				HwpCtrl = $(item)[0].contentWindow.HwpCtrl;
			}
		    var apvseq = 1;
			$(draftDept).each(function(i, apline){
				if(apline.unittype == "ou" && apline.routetype == "assist" && apline.name == "일상감사" && apvseq <= 4){
					$(apline.ou.person).each(function(j, auditLine){
						HwpCtrl.PutFieldText("ap" + (apvseq) + "_position", auditLine.title.split(';')[1]);
						if(auditLine.taskinfo.datecompleted != null){
							HwpCtrl.PutFieldText("ap" + (apvseq) + "_sign", auditLine.name.split(';')[0]);
							
							//if(oApvList.steps.division.step.length == (i+1)){
								var strKind = "";
								var strDate = "";
							    switch (auditLine.taskinfo.kind) {
						        	case "charge": strKind = "담당"; break;
							        case "authorize": strKind = Common.getDic("lbl_apv_authorize"); break;
							        case "substitute": strKind = Common.getDic("lbl_apv_substitue"); break;
							        case "bypass": strKind = Common.getDic("lbl_apv_bypass"); break;
							        case "review": strKind = Common.getDic("lbl_apv_review"); break;
							        default : strKind = Common.getDic("lbl_apv_sign_approval"); break;
							    }
							    strDate = formatDate(auditLine.taskinfo.datecompleted, 'SB');
								HwpCtrl.PutFieldText("ap" + (apvseq) + "_date", strDate);
							//}
							if(apline.ou.person.length == (j+1)){
								HwpCtrl.PutFieldText("ap" + (apvseq) + "_type", strKind);
								$("[id^=tbContentElement][doctype=normal]").each(function(idx, item){
									HwpCtrl = $(item)[0];
									if(HwpCtrl.PutFieldText == undefined) {
										HwpCtrl = $(item)[0].contentWindow.HwpCtrl;
									}
									HwpCtrl.PutFieldText("audit_pil", "일상감사필");
									HwpCtrl.PutFieldText("audit_date", strDate);
									HwpCtrl.PutFieldText("audit_sign", auditLine.name.split(';')[0]);
								});
							}
						}
						apvseq++;
					});
				}
			});
		});
	}
}

function drawApvLineMobile(){
	m_oApvList = JSON.parse($('#APVLIST').val());
    oApvList = m_oApvList;
    
    var draftDept = "";
    var receiveDept = "";
    var gfileId ="";
    
    if(oApvList.steps == undefined || oApvList.steps.division == null ){
    	return false;
    }
    if(oApvList.steps.division[0] != null && oApvList.steps.division.length > 1){
    	draftDept = oApvList.steps.division[0].step;
    	receiveDept = oApvList.steps.division.filter(arr => arr.divisiontype == "receive")[0].step;
    } else {
    	draftDept = oApvList.steps.division.step;
    }
    
    // 양식프로세스 > 결재유형옵션 > 문서유통 == Y && 양식 > 양식본문정보 > 한글웹기안기 == Y
    if (getInfo("ExtInfo.UseWebHWPEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y") {
		//결재선 초기화
		$("[name$='-jikwe']").html("");
		$("[name$='-date']").html("");
		$("[name$='-name']").html("");
		$("[name$='-sign']").html("");
    	
    	var draftDeptLength = Array.isArray(draftDept) ? draftDept.length : 1;
    	
    	if (Array.isArray(draftDept)) {
    		// 발신
    		var approve = draftDept.filter(arr => arr.routetype == 'approve');
	    	
	    	for (var i = 0; i < approve.length; i++) {
	    		var jikwe = CFN_GetDicInfo(approve[i].ou.person.position.split(";").splice(1).join(";"));
	    		var date = approve[i].name;
	    		var name = CFN_GetDicInfo(approve[i].ou.person.name);
	    		
	    		if (approve[i].ou.person.taskinfo.datecompleted) {
	    			var completedDate = new Date(approve[i].ou.person.taskinfo.datecompleted);
	    			completedDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
	    			
	    			date = completedDate + " " + date;
	    		}
	    		
	    		$("[name='approve-jikwe']").eq(i).text(jikwe);
	    		$("[name='approve-date']").eq(i).text(date);
	    		$("[name='approve-name']").eq(i).text(name);
	    		
	    		if (approve[i].ou.person.taskinfo.customattribute1) {
		    		$("[name='approve-sign']").eq(i).html($("<img>", {"src" : mobile_comm_getGlobalProperties("mobile.smart4j.path") 
	    				+ mobile_comm_getImgById("", approve[i].ou.person.taskinfo.customattribute1)}));
	    		}
	    	}
	    	// 협조
		    var asiseq = 0;
	    	var assist = draftDept.filter(arr => arr.routetype == 'assist');
	    	
	    	for (var i = 0; i < assist.length; i++) {
	    		var jikwe = "";
	    		var date = "";
	    		var name = "";
	    		
	    		if(Array.isArray(assist[i].ou)) {
	    			for (var j = 0; j < assist[i].ou.length; j++) {
			    		jikwe = CFN_GetDicInfo(assist[i].ou[j].person.position.split(";").splice(1).join(";"));
			    		date = assist[i].name;
			    		name = CFN_GetDicInfo(assist[i].ou[j].person.name);
			    		
			    		if (assist[i].ou[j].person.taskinfo.datecompleted) {
			    			var completedDate = new Date(assist[i].ou[j].person.taskinfo.datecompleted);
			    			completedDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
			    			
			    			date = completedDate + " " + date;
			    		}
			    		
			    		$("[name='assist-jikwe']").eq(asiseq).text(jikwe);
			    		$("[name='assist-date']").eq(asiseq).text(date);
			    		$("[name='assist-name']").eq(asiseq).text(name);
			    		
			    		if (assist[i].ou[j].person.taskinfo.customattribute1) {
				    		$("[name='assist-sign']").eq(asiseq).html($("<img>", {"src" : mobile_comm_getGlobalProperties("mobile.smart4j.path") 
			    				+ mobile_comm_getImgById("", assist[i].ou[j].person.taskinfo.customattribute1)}));
			    		}
			    		asiseq++;
	    			}
				} else {
		    		jikwe = CFN_GetDicInfo(assist[i].ou.person.position.split(";").splice(1).join(";"));
		    		date = assist[i].name;
		    		name = CFN_GetDicInfo(assist[i].ou.person.name);
		    		
		    		if (assist[i].ou.person.taskinfo.datecompleted) {
		    			var completedDate = new Date(assist[i].ou.person.taskinfo.datecompleted);
		    			completedDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
		    			
		    			date = completedDate + " " + date;
		    		}
		    		
		    		$("[name='assist-jikwe']").eq(asiseq).text(jikwe);
		    		$("[name='assist-date']").eq(asiseq).text(date);
		    		$("[name='assist-name']").eq(asiseq).text(name);
		    		
		    		if (assist[i].ou.person.taskinfo.customattribute1) {
			    		$("[name='assist-sign']").eq(asiseq).html($("<img>", {"src" : mobile_comm_getGlobalProperties("mobile.smart4j.path") 
		    				+ mobile_comm_getImgById("", assist[i].ou.person.taskinfo.customattribute1)}));
		    		}
		    		asiseq++;
				}
	    	}
	    	// 수신
	    	var receive = receiveDept;

	    	for (var i = 0; i < receive.length; i++) {
	    		var jikwe = CFN_GetDicInfo(receive[i].ou.person.position.split(";").splice(1).join(";"));
	    		var date = receive[i].name;
	    		var name = CFN_GetDicInfo(receive[i].ou.person.name);
	    		
	    		if (receive[i].ou.person.taskinfo.datereceived) {
	    			var completedDate = new Date(receive[i].ou.person.taskinfo.datereceived);
	    			completedDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
	    			
	    			date = completedDate + " " + date;
	    		}
	    		
	    		$("[name='receive-jikwe']").eq(i).text(jikwe);
	    		$("[name='receive-date']").eq(i).text(date);
	    		$("[name='receive-name']").eq(i).text(name);
	    		
	    		if (receive[i].ou.person.taskinfo.customattribute1) {
		    		$("[name='receive-sign']").eq(i).html($("<img>", {"src" : mobile_comm_getGlobalProperties("mobile.smart4j.path") 
	    				+ mobile_comm_getImgById("", receive[i].ou.person.taskinfo.customattribute1)}));
	    		}
	    	}
	    	
    	} else {
    		var date = draftDept.name;
    		var name = CFN_GetDicInfo(draftDept.ou.person.name);
    		if (draftDept.ou.person.taskinfo.datecompleted) {
    			var completedDate = new Date(draftDept.ou.person.taskinfo.datecompleted);
    			completedDate = completedDate.getMonth() + 1 + "/" + completedDate.getDate();
    			
    			date = completedDate + " " + date;
    		}

    		$("[name='approve-jikwe']").eq(0).text(CFN_GetDicInfo(draftDept.ou.person.position.split(";").splice(1).join(";")));
    		$("[name='approve-date']").eq(0).text(date);
    		$("[name='approve-name']").eq(0).text(CFN_GetDicInfo(draftDept.ou.person.name));
    		
    		if (draftDept.ou.person.taskinfo.customattribute1) {
    			$("[name='approve-sign']").eq(i).html($("<img>", {"src" : mobile_comm_getGlobalProperties("mobile.smart4j.path") 
    				+ mobile_comm_getImgById("", draftDept.ou.person.taskinfo.customattribute1)}));
    		}
    	}
    }
    
    var apvseq = 1;
    var asiseq = 1;
    
    if(formJson.BodyContext.pubdocinfo != undefined && typeof formJson.BodyContext.pubdocinfo.pubFAppvalInfo.approvalinfo.approval != undefined) {
    	var pubApv = formJson.BodyContext.pubdocinfo.pubFAppvalInfo.approvalinfo.approval;
		for(var i=0; i<pubApv.length; i++) {
			$("#jikwe" + (i + 1) + "").text(pubApv[i].signposition);
			$("#sign" + (i + 1) + "").text(pubApv[i].name);
		}
    } else {
	    $(draftDept).each(function(i, apline){
			if(apline.unittype == "person" && apline.routetype != "assist" && apvseq <= 8){
    			$("#ap" + apvseq + "_position").text(apline.ou.person.title.split(';')[1]);
				if(apline.ou.person.taskinfo.datecompleted != null && apline.ou.person.taskinfo.status == "completed"){
	    			$("#apb" + apvseq + "_sign").text(apline.ou.person.name.split(';')[0]);
					
					if(draftDept.length == (i+1)){
						if(apline.ou.person.taskinfo.status == "completed"){
							var strKind = "";
							var strDate = "";
						    switch (apline.ou.person.taskinfo.kind) {
						        case "substitute": strKind = Common.getDic("lbl_apv_substitue"); break;
						        case "authorize": strKind = Common.getDic("lbl_apv_authorize"); break;
						        case "bypass": strKind = Common.getDic("lbl_apv_bypass"); break;
						        case "review": strKind = Common.getDic("lbl_apv_review"); break;
						        default : strKind = Common.getDic("lbl_apv_sign_approval"); break;
						    }
						    strDate = formatDate(apline.ou.person.taskinfo.datecompleted, 'SB');
			    			$("#apb" + apvseq + "_sign").text(strKind + " " + strDate + String.fromCharCode(0x0D) + apline.ou.person.name.split(';')[0]);

			    			insertChiefsignMobile(apline.ou.person.code); // 대내발송 문서일 경우 발신부서장 서명 삽입
						}
					}
				}
				apvseq++;
			} else if(apline.unittype == "person" && apline.routetype == "assist" && asiseq <= 7){
				if(apline.allottype == "parallel"){
					$(apline.ou).each(function(pidx, pitem){
						if(asiseq <= 7){
							$("#as" + asiseq + "_position").text(pitem.person.title.split(';')[1]);
							if(pitem.person.taskinfo.datecompleted != null){
								$("#as" + asiseq + "_sign").text(pitem.person.name.split(';')[0]);
							}
							asiseq++;
						}
					});
				} else {
					$("#as" + asiseq + "_position").text(apline.ou.person.title.split(';')[1]);
					if(apline.ou.person.taskinfo.datecompleted != null){
						$("#as" + asiseq + "_sign").text(apline.ou.person.name.split(';')[0]);
					}
					asiseq++;
				}
			}
		});
    }
    
	if(getInfo("FormInfo.FormPrefix") == "WF_FORM_SB_MULTI_AUDIT_DRAFT"){
	    var apvseq = 1;
		$(draftDept).each(function(i, apline){
			if(apline.unittype == "ou" && apline.routetype == "assist" && apline.name == "일상감사" && apvseq <= 4){
				$(apline.ou.person).each(function(j, auditLine){
					$("#ap" + apvseq + "_position").text(auditLine.title.split(';')[1]);
					if(auditLine.taskinfo.datecompleted != null){
						$("#ap" + apvseq + "_sign").text(auditLine.name.split(';')[0]);
						
						var strKind = "";
						var strDate = "";
					    switch (auditLine.taskinfo.kind) {
				        	case "charge": strKind = "담당"; break;
					        case "authorize": strKind = Common.getDic("lbl_apv_authorize"); break;
					        case "substitute": strKind = Common.getDic("lbl_apv_substitue"); break;
					        case "bypass": strKind = Common.getDic("lbl_apv_bypass"); break;
					        case "review": strKind = Common.getDic("lbl_apv_review"); break;
					        default : strKind = Common.getDic("lbl_apv_sign_approval"); break;
					    }
					    strDate = formatDate(auditLine.taskinfo.datecompleted, 'SB');
						$("#ap" + apvseq + "_date").text(strDate);
						if(apline.ou.person.length == (j+1)){
							$("#ap" + apvseq + "_type").text(strKind);
							$("#audit_pil").text("일상감사필");
							$("#audit_date").text(strDate);
							$("#audit_sign").text(auditLine.name.split(';')[0]);
						}
					}
					apvseq++;
				});
			}
		});
	}
}

function InputHWPContentMulti() {
	var idx = $("#writeTab li.on").attr('idx');

	var HwpCtrl = document.getElementById(g_id + idx);
	if(HwpCtrl == null) {
		HwpCtrl = document.getElementById(g_id + idx + "Frame").contentWindow.HwpCtrl;
	}
	HwpCtrl.MoveToField("body", true, true, false);
	HwpCtrl.Run("InsertFile");
}

function OpenDocInfoPopup() {
	//이전 소스
	var sUrl ="";
	var iHeight = 600; 
	var iWidth = 500;	
	
	if(getInfo("FormInfo.FormPrefix")=="WF_FORM_DRAFT_MULTI_TEST"){//기존소스>기안지(다안기안)
		  sUrl = "form/goGovDocInfoWritePopup.do?idx=" + $("#writeTab li.on").attr('idx');
		  iHeight = 600; 
		  iWidth = 500;	
		  	
	}
	else{
		  sUrl = "form/goRecordRefSelectPopup.do?idx=" + $("#writeTab li.on").attr('idx');
		  iHeight = 650; 
		  iWidth = 1500;			  
	}
	
	CFN_OpenWindow(sUrl, "", iWidth, iHeight, "fix");	
}

function OpenDocInfoPopup_Dist() {
	var sUrl = "form/goGovDocInfoWritePopup.do?idx=dist&formInstID=" + getInfo("FormInstanceInfo.FormInstID") + "&processID=" + getInfo("Request.processID") + "&deptCode=" + getInfo("AppInfo.dpid_apv");
	var iHeight = 440; 
	var iWidth = 500;
	
	CFN_OpenWindow(sUrl, "", iWidth, iHeight, "fix");	
}

function setGovDocInfo(pObj) {
	var idx = $("#writeTab li.on").attr('idx');
	
	for(let key in pObj) {
		document.getElementsByName("MULTI_"+key)[idx].value = pObj[key];
	}
	
	G_displaySpnSubjectInfoMulti(idx);
	G_displaySpnRecordInfoMulti(idx);
}

//다안기안 양식 공통 부분
function setMultiBody(){
	if(getInfo('ProcessInfo.SubKind') == "R" || $$(m_oApvList).find("division>step").length > 1){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
	    	var view = false;
			if(formJson.BodyData.SubTable1[idx] != null && formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST != null && formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST != ""){
				var RecList = formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST.split(';');
				for(var i = 0; i < RecList.length; i++){
					if(RecList[i].split('|')[0] == getInfo('AppInfo.dpid')){
						view = true;
						break;
					}
				}
			}
			if(!view){
				$("#writeTab li[idx=" + (idx+1) + "]").remove();
			} else {
		    	changeTab((idx+1));
			}
		});
    } else {
    	changeTab(1);
    }
}

function setEditorBody(sBody){
	var commonEditorType = Common.getBaseConfig("EditorType");
	var idx = 1;

	try{
		switch (commonEditorType) {
            case editortypes['textarea']:
            	document.getElementById("txtareaBody" + idx).value = sBody;
                break;
            case editortypes['dhtml']: 
            	break;
            case editortypes['tagfree']:
            	document.getElementById('tbContentElement' + idx).HtmlValue = sBody;
                break;
            case editortypes['xfree']:
            	coviEditor.setBody("xfree", 'tbContentElement' + idx, sBody);
            	break;
            case editortypes['tagfreenxfree']:
                if (_ie) {
		                	document.getElementById('tbContentElement' + idx).HtmlValue = sBody;
                    } else {
		                	document.getElementById('xFreeFrame' + idx).contentWindow.tbContentElement.setHtmlValue(sBody);
                }
                break;
            case editortypes['activesquare']:
            	document.tbContentElement.value = sBody;
                break;
            case editortypes['dext5']:
        		coviEditor.setBody("dext5", 'tbContentElement' + idx, sBody);
                break;
            case editortypes['cheditor']:
            	document.getElementById('cheditorFrame' + idx).contentWindow.myeditor.loadContents(sBody);
                break;
            case editortypes['synap']:  
        		coviEditor.setBody("synap", 'tbContentElement' + idx, sBody);
                break;
            case editortypes['ck']:  
        		coviEditor.setBody("ck", 'tbContentElement' + idx, sBody);
                break;
            case editortypes['webhwpctrl']:  
				coviEditor.setBody("webhwpctrl", 'tbContentElement' + idx, sBody);
                break;
            case editortypes['covieditor']:
            	coviEditor.setBody("covieditor", 'tbContentElement' + idx, sBody);
	            break;
            case editortypes['keditor']:
        		coviEditor.setBody("keditor", 'tbContentElement' + idx, sBody);
                break;
        }
    } catch (e) {
		setTimeout("setEditor(" + idx + ")", 100);
    }

}

//1안의 제목을 결재문서 제목으로 사용하도록 처리
function setMultiDraftDocSubject() {
	// 다안기안 + 문서유통일때 처리
	if (isGovMulti() && isUseHWPEditor()) { 
		$("[id^=tbContentElement][id$=Frame]").each(function(idx, item) {
			if (document.getElementsByName('MULTI_TITLE')[idx+1]) {
				//document.getElementsByName('MULTI_TITLE')[idx+1].value = HwpCtrl.GetFieldText("doctitle");
			}
		});
	} else {
		var sSubject = "";
		
		if(isUseHWPEditor()) {
	    	if(getInfo("ExtInfo.UseWebHWPEditYN") == "Y") {
	    		sSubject = $('#tbContentElement1Frame')[0].contentWindow.HwpCtrl.GetFieldText("SUBJECT");	
	        } else {
	        	sSubject = $('#tbContentElement1')[0].GetFieldText("SUBJECT");
	        }
		}else if(getInfo("ExtInfo.UseEditYN") == "Y"){
			// 일반에디터 사용시
			sSubject = $("#Subject").val();
		}else {
			sSubject = $("#SubjectInfoItem_Multi").find("input[name='TITLE']").eq(0).val();
		}
		
		$('#Subject').val(sSubject);
	}
}

function getReceiveGovDocInfo() {
	var retValue;
	
	$.ajax({
		url	: "/approval/user/getDocTempInfo.do",
		type: "POST",
		data: {
			"FormInstID" : getInfo("FormInstanceInfo.FormInstID"),
			"ProcessID" : getInfo("Request.processID"),
			"DeptCode" : getInfo("AppInfo.dpid_apv")
		},
    	async:false,
		success:function (data) {
			if(data.status == "SUCCESS" && data.data != 0){
				retValue = data.data.map[0];
			}
		},
		error:function (error){
			Common.Error(Common.getDic("msg_apv_030"));
		}
	});
	
	return retValue;
}


/************************************************** 다안기안 + 문서유통 **************************************************/
/************************************************** 다안기안 + 문서유통 **************************************************/
/************************************************** 다안기안 + 문서유통 **************************************************/
// 다안기안 + 문서유통
// 웹 한글기안 에디터 로드 여부
var g_IsGovMultiEditorLoad = [null]; // idx 0은 그냥 사용하지 않게 null로 초기화

// 다안기안 + 문서유통
// 웹 한글기안 에디터 최초 로드 후 세팅
function initGovMultiEditorDisplay() {
	// 결재 유형 세팅
	setDocInfoHWPDisplay(document.getElementById('ApvReceiverTypeSelect'));
}

// 다안기안 + 문서유통
// 웹 한글기안 에디터 로드 시작
function setGovMultiEditorLoadStart(idx) {
	for (let i = 1; i <= idx; i++) {
		if (i == idx) g_IsGovMultiEditorLoad[idx] = false;
		else if (g_IsGovMultiEditorLoad[idx] == undefined) g_IsGovMultiEditorLoad.push(false);
	}
}

// 다안기안 + 문서유통
// 웹 한글기안 에디터 로드 완료
function setGovMultiEditorLoadEnd(idx) {
	if (g_IsGovMultiEditorLoad[idx] == undefined) g_IsGovMultiEditorLoad.push(true);
	else g_IsGovMultiEditorLoad[idx] = true;
}

// 다안기안 + 문서유통
// 웹 한글기안 에디터 로드 완료 여부
function getIsGovMultiHWPEditorLoad() {
	const idx = getMultiIdx();
	if (g_IsGovMultiEditorLoad[idx] == undefined) return false;
	return g_IsGovMultiEditorLoad[idx];
}

//다안기안 + 문서유통
//웹 에디터 로드 완료 여부
function getIsGovMultiEditorLoad() {
	const idx = getMultiIdx();
	if (g_IsGovMultiEditorLoad[idx] == undefined) return false;
	return g_IsGovMultiEditorLoad[idx];
}
 
// 다안기안 + 문서유통
// 한글문서에 정보 표시
function setDocInfoHWPDisplay(obj) {
	const idx = getMultiIdx();
 
	if (idx != '') {
		HwpCtrl = document.getElementById('tbContentElement' + m_firstIDx);
        if(HwpCtrl == null && webHwpYN == "Y") {
        	HwpCtrl = document.getElementById('tbContentElement' + m_firstIDx + 'Frame').contentWindow.HwpCtrl;
        }
        
		const name = $(obj).attr("name");
		let savedVal = '';
		
		if (name == "RELEASE_CHECK") { // 공개여부
			savedVal = $(obj).val();
			if (savedVal == "1") {
				$("#RELEASE_CHECK").val(savedVal);
				HwpCtrl.PutFieldText("publication", Common.getDic("lbl_apv_open")); // 공개
				$("#chk_secrecy").prop("checked", false);
				$("#TempUseScrecy").val(false);
				$("#RELEASE_CODE").hide();
			} else {
				$("#RELEASE_CHECK").val(savedVal);
				HwpCtrl.PutFieldText("publication", Common.getDic("lbl_Private")); // 비공개
				$("#chk_secrecy").prop("checked", true);
				$("#TempUseScrecy").val(true);
				$("#RELEASE_CODE").show();
			}
		} else if (name == "ApvReceiverTypeSelect") { // 내부결재/시행발송
			savedVal = $(obj).val();
			if (savedVal == "indoc") { // 내부결재
				HwpCtrl.MoveToField("recipient", true, true, false);
				HwpCtrl.PutFieldText("hrecipients", " ");
				HwpCtrl.PutFieldText("recipient", $(obj).find('option:selected').text());
				HwpCtrl.PutFieldText("recipients", " ");
				$("#btRecieveMulti").hide();
			} else if (savedVal == "else") { // 시행발송
				HwpCtrl.PutFieldText("recipient", " ");
				$("#btRecieveMulti").show();
			}
			document.getElementsByName("MULTI_APV_RECEIVER_TYPE")[idx].value = savedVal;
		} else if (name == "SenderMasterSelect") { // 발신명의
			document.getElementsByName("MULTI_SENDER_MASTER")[idx].value = $(obj).val();
			document.getElementsByName("MULTI_STAMP")[idx].value = $.trim($(obj).find('option:selected').attr('data-stamp'));
			document.getElementsByName("MULTI_LOGO")[idx].value = $.trim($(obj).find('option:selected').attr('data-logo'));
			document.getElementsByName("MULTI_SYMBOL")[idx].value = $.trim($(obj).find('option:selected').attr('data-symbol'));
			document.getElementsByName("MULTI_CHIEF")[idx].value = $.trim($(obj).find('option:selected').attr('data-chief'));
			document.getElementsByName("MULTI_CAMPAIGN_T")[idx].value = $.trim($(obj).find('option:selected').attr('data-campaign-t'));
			document.getElementsByName("MULTI_CAMPAIGN_F")[idx].value = $.trim($(obj).find('option:selected').attr('data-campaign-f'));
			document.getElementsByName("MULTI_ORGAN")[idx].value = $.trim($(obj).find('option:selected').attr('data-organ'));
			document.getElementsByName("MULTI_TELEPHONE")[idx].value = $.trim($(obj).find('option:selected').attr('data-tel'));
			document.getElementsByName("MULTI_EMAIL")[idx].value = $.trim($(obj).find('option:selected').attr('data-email'));
			document.getElementsByName("MULTI_ZIPCODE")[idx].value = $.trim($(obj).find('option:selected').attr('data-zip-code'));
			document.getElementsByName("MULTI_ADDRESS")[idx].value = $.trim($(obj).find('option:selected').attr('data-address'));
			document.getElementsByName("MULTI_HOMEURL")[idx].value = $.trim($(obj).find('option:selected').attr('data-homepage'));
			document.getElementsByName("MULTI_FAX")[idx].value = $.trim($(obj).find('option:selected').attr('data-fax'));
			
			var filePath = "";
			var gfileId= "";

			HwpCtrl.PutFieldText("logo", " ");
			if($.trim($(obj).find('option:selected').attr('data-logo')) != "") {
				filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId($.trim($(obj).find('option:selected').attr('data-logo')));
				//HwpCtrl.MoveToField("logo", true, true, true);
	            //HwpCtrl.InsertPicture(filePath, true, 1, false, false, 0, 17, 17);	
				
				gfileId = $.trim($(obj).find('option:selected').attr('data-logo')); 
				m_arrConverImgArr.push({
					TYPE:"ICON",
					IMGNAME:"logo",
					FILEPATH :filePath,
					WIDTH: 70,
					HEIGHT :70,					
					BINARYDATA :getFileBinaryData(gfileId,70,70)				
				});				
				
				
			}

			HwpCtrl.PutFieldText("symbol", " ");
			if($.trim($(obj).find('option:selected').attr('data-symbol')) != "") {
				filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId($.trim($(obj).find('option:selected').attr('data-symbol')));
//				HwpCtrl.MoveToField("symbol", true, false, true);
//	            HwpCtrl.InsertPicture(filePath, true, 1, false, false, 0, 17, 17);
				
				gfileId = $.trim($(obj).find('option:selected').attr('data-symbol')); 
				m_arrConverImgArr.push({
					TYPE:"ICON",
					IMGNAME:"symbol",
					FILEPATH :filePath,
					WIDTH: 70,
					HEIGHT :70,					
					BINARYDATA :getFileBinaryData(gfileId,70,70)					
				});					
			}
			
			HwpCtrl.PutFieldText("sealsign", " ");
			if($.trim($(obj).find('option:selected').attr('data-stamp')) != "") {
				filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId($.trim($(obj).find('option:selected').attr('data-stamp')));
//				HwpCtrl.MoveToField("sealsign", true, false, false);
//		        HwpCtrl.InsertPicture(filePath, true, 1, false, false, 0, 17, 17);
				
				gfileId = $.trim($(obj).find('option:selected').attr('data-stamp'));//fileid
				m_arrConverImgArr.push({
					TYPE:"ICON",
					IMGNAME:"sealsign",
					FILEPATH :filePath,
					WIDTH: 100,
					HEIGHT :100,
					BINARYDATA :getFileBinaryData(gfileId,100,60)					
				});
								
			}
			
			HwpCtrl.PutFieldText("chief", !$.trim($(obj).find('option:selected').attr('data-chief')) ? " " : $.trim($(obj).find('option:selected').attr('data-chief')));
			HwpCtrl.PutFieldText("organ", !$.trim($(obj).find('option:selected').attr('data-organ')) ? " " : $.trim($(obj).find('option:selected').attr('data-organ')));
			HwpCtrl.PutFieldText("telephone", !$.trim($(obj).find('option:selected').attr('data-tel')) ? " " : $.trim($(obj).find('option:selected').attr('data-tel')));
			HwpCtrl.PutFieldText("fax", !$.trim($(obj).find('option:selected').attr('data-fax')) ? " " : $.trim($(obj).find('option:selected').attr('data-fax')));
			HwpCtrl.PutFieldText("homepage", !$.trim($(obj).find('option:selected').attr('data-homepage')) ? " " : $.trim($(obj).find('option:selected').attr('data-homepage')));
			HwpCtrl.PutFieldText("email", !$.trim($(obj).find('option:selected').attr('data-email')) ? " " : $.trim($(obj).find('option:selected').attr('data-email')));
			HwpCtrl.PutFieldText("zipcode", !$.trim($(obj).find('option:selected').attr('data-zip-code')) ? " " : $.trim($(obj).find('option:selected').attr('data-zip-code')));
			HwpCtrl.PutFieldText("address", !$.trim($(obj).find('option:selected').attr('data-address')) ? " " : $.trim($(obj).find('option:selected').attr('data-address')));
			HwpCtrl.PutFieldText("headcampaign", !$.trim($(obj).find('option:selected').attr('data-campaign-t')) ? " " : $.trim($(obj).find('option:selected').attr('data-campaign-t')));
			HwpCtrl.PutFieldText("footcampaign", !$.trim($(obj).find('option:selected').attr('data-campaign-f')) ? " " : $.trim($(obj).find('option:selected').attr('data-campaign-f')));
		
			
			ConvertToBinaryToHWP(HwpCtrl);//이미지 로딩 
		}
	}
}

//다안기안 + 문서유통 + 웹기안기
function setDocInfoDisplay(obj) {
	const idx = getMultiIdx();

	if (idx != '') {
		const name = $(obj).attr("name");
		let savedVal = '';
		
		if (name == "RELEASE_CHECK") { // 공개여부
			savedVal = $(obj).val();
			if (savedVal == "1") {
				$("#RELEASE_CHECK").val(savedVal);
				$("#chk_secrecy").prop("checked", false);
				$("#TempUseScrecy").val(false);
				$("#RELEASE_CODE").hide();
			} else {
				$("#RELEASE_CHECK").val(savedVal);
				$("#chk_secrecy").prop("checked", true);
				$("#TempUseScrecy").val(true);
				$("#RELEASE_CODE").show();
			}
		} else if (name == "ApvReceiverTypeSelect") { // 내부결재/시행발송
			savedVal = $(obj).val();
			if (savedVal == "indoc") { // 내부결재
				document.getElementsByName("MULTI_DOC_RECLINE")[idx].value = '';
				document.getElementsByName('DOC_RECLINE')[idx-1].value = '';
				$("#btRecieveMulti").hide();
				$('#DocRecLineList_Multi').hide();
			} else if (savedVal == "else") { // 시행발송
				$("#btRecieveMulti").show();
			}
			document.getElementsByName("MULTI_APV_RECEIVER_TYPE")[idx].value = savedVal;
		} else if (name == "SenderMasterSelect") { // 발신명의
			document.getElementsByName("MULTI_SENDER_MASTER")[idx].value = $(obj).val();
			document.getElementsByName("MULTI_STAMP")[idx].value = $.trim($(obj).find('option:selected').attr('data-stamp'));
			document.getElementsByName("MULTI_LOGO")[idx].value = $.trim($(obj).find('option:selected').attr('data-logo'));
			document.getElementsByName("MULTI_SYMBOL")[idx].value = $.trim($(obj).find('option:selected').attr('data-symbol'));
			document.getElementsByName("MULTI_CHIEF")[idx].value = $.trim($(obj).find('option:selected').attr('data-chief'));
			document.getElementsByName("MULTI_CAMPAIGN_T")[idx].value = $.trim($(obj).find('option:selected').attr('data-campaign-t'));
			document.getElementsByName("MULTI_CAMPAIGN_F")[idx].value = $.trim($(obj).find('option:selected').attr('data-campaign-f'));
			document.getElementsByName("MULTI_ORGAN")[idx].value = $.trim($(obj).find('option:selected').attr('data-organ'));
						
			// 전화번호
			document.getElementsByName("MULTI_TELEPHONE")[idx].value = $.trim($(obj).find('option:selected').attr('data-tel'));
			document.getElementById("DocPhoneNum"+idx).firstElementChild.value = event.target.options[event.target.selectedIndex].getAttribute("data-tel");
			// 팩스번호
			document.getElementsByName("MULTI_FAX")[idx].value = $.trim($(obj).find('option:selected').attr('data-fax'));
			document.getElementById("DocFaxNum"+idx).firstElementChild.value = event.target.options[event.target.selectedIndex].getAttribute("data-fax");
			// 홈페이지
			document.getElementsByName("MULTI_HOMEURL")[idx].value = $.trim($(obj).find('option:selected').attr('data-homepage'));
			document.getElementById("DocHomePage"+idx).firstElementChild.value = event.target.options[event.target.selectedIndex].getAttribute("data-homepage");
			// 이메일
			document.getElementsByName("MULTI_EMAIL")[idx].value = $.trim($(obj).find('option:selected').attr('data-email'));
			document.getElementById("DocEmail"+idx).firstElementChild.value = event.target.options[event.target.selectedIndex].getAttribute("data-email");
			// 우편번호
			document.getElementsByName("MULTI_ZIPCODE")[idx].value = $.trim($(obj).find('option:selected').attr('data-zip-code'));
			document.getElementById("DocZipCode"+idx).firstElementChild.value = event.target.options[event.target.selectedIndex].getAttribute("data-zip-code");
			// 주소
			document.getElementsByName("MULTI_ADDRESS")[idx].value = $.trim($(obj).find('option:selected').attr('data-address'));
			document.getElementById("DocAddress"+idx).firstElementChild.value = event.target.options[event.target.selectedIndex].getAttribute("data-address");
			
		}
	}
}

// 다안기안 + 문서유통
// 다안기안 선택된 안 index
function getMultiIdx() {
	return $("#writeTab li.on").length > 0 ? $("#writeTab li.on").attr('idx') : "";
}

// 다안기안 + 문서유통
// 발신명의 select box 값 세팅
function setSenderMaster() {
	$.ajax({
		url: "/approval/user/selectGovSenderMasterUpper.do",
		type: "POST",
        data: {
        	deptCode: Common.getSession('DEPTID')
        },
        async: false,
		success: function(data) {
			const senderMaster = data.list;
			senderMaster.forEach(function(item) {
				const option = document.createElement("option");
				option.setAttribute("value", item.SEND_ID);
				option.setAttribute("data-stamp", nullToBlank(item.STAMP));
				option.setAttribute("data-logo", nullToBlank(item.LOGO));
				option.setAttribute("data-symbol", nullToBlank(item.SYMBOL));
				option.setAttribute("data-chief", nullToBlank(item.NAME));
				option.setAttribute("data-organ", nullToBlank(item.OUNAME));
				option.setAttribute("data-tel", nullToBlank(item.TEL));
				option.setAttribute("data-fax", nullToBlank(item.FAX));
				option.setAttribute("data-homepage", nullToBlank(item.HOMEPAGE));
				option.setAttribute("data-email", nullToBlank(item.EMAIL));
				option.setAttribute("data-zip-code", nullToBlank(item.ZIP_CODE));
				option.setAttribute("data-address", nullToBlank(item.ADDRESS));
				option.setAttribute("data-campaign-f", nullToBlank(item.CAMPAIGN_F));
				option.setAttribute("data-campaign-t", nullToBlank(item.CAMPAIGN_T));
				option.innerText = nullToBlank(item.NAME);
				document.getElementById("SenderMasterSelect").appendChild(option);
			});
		},
		error: function(error){
			Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
		}
	});
}
/************************************************** 다안기안 + 문서유통 **************************************************/
/************************************************** 다안기안 + 문서유통 **************************************************/
/************************************************** 다안기안 + 문서유통 **************************************************/