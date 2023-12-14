//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems: {
    }
};

var localLang_en = {
    localLangItems: {
    }
};

var localLang_ja = {
    localLangItems: {
    }
};

var localLang_zh = {
    localLangItems: {
    }
};
var idx = "${idx}";									 

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
	if (getInfo("Request.templatemode") == "Read" || getInfo("Request.mode") == "APPROVAL") {
		$('#formBox').css("margin-top", "-20px");
	} else {
		$('#formBox').css("margin-top", "-45px");
	}
	
	//$('#AttFileInfoList').hide();
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
	$('#MainTable').hide();
	$('#SubTable1').hide();
	$('#tblFormSubject').hide();

	// 재기안시에 반송
    if(getInfo("Request.mode") == "REDRAFT" && getInfo("Request.gloct") == "DEPART") {
		$("#btRejectOut").show();
    }

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
    	
    	var divLen = $$($.parseJSON(XFN_ChangeOutputValue(document.getElementById("APVLIST").value))).find("steps").find("division").valLength();
    	
    	if(formJson.Request.isMobile != "Y" && (divLen == 1 || formJson.Request.mode == "REDRAFT"))
    		displayDocInfo();
    	
    	if(document.getElementById("docInfoTB") != null &&divLen > 1) {
    		document.getElementById("docInfoTB").style.display = "none";
    		$("#ORIGINATION_CHECK_rec").parent().attr("style","display:none;");
    	}

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        /*
    	if(formJson.BodyData.SubTable1 != null){
    		$(formJson.BodyData.SubTable1).each(function(i, item){
    			if(i != 0){
    				addTabClass(item.MULTI_DOC_TYPE);
    			}
    		});
    	}
    	*/
        if (JSON.stringify(formJson.BodyData) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'R');            
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
        }
        if(formJson.Request.readtype != "preview") {
        	formDisplaySetFileInfoMulti();
        }
        formDisplaySetDocLinkInfoMulti();
        
        if(formJson.Request.mode == "REDRAFT" || formJson.Request.mode == "RECAPPROVAL") {
        	if(formJson.Request.mode == "REDRAFT") {
        		$("#buttonDist").show();
        		if($("#RECORD_SUBJECT_rec").val() != ''){
	        		var RecordObj = JSON.parse($("#RECORD_SUBJECT_rec").val());
					if(getInfo("Request.mode") == "REDRAFT") {
						$("#RELEASE_CHECK_rec").val($("#RELEASE_CHECK_rec").find('input:checked').val());
						document.getElementsByName("MULTI_RELEASE_CHECK_rec")[1].value = $("#RELEASE_CHECK_rec").find('input:checked').val();
						document.getElementsByName("MULTI_RECORD_SUBJECT_rec")[1].value = RecordObj.RecordSubject;
						document.getElementsByName("MULTI_RECORD_CLASS_NUM_rec")[1].value = RecordObj.RecordClassNum;
						document.getElementsByName("MULTI_REGIST_CHECK_rec")[1].value = RecordObj.RegistCheck;
						document.getElementsByName("MULTI_KEEP_PERIOD_rec")[1].value = RecordObj.KeepPeriod;
						document.getElementsByName("MULTI_SECURE_LEVEL_rec")[1].value = RecordObj.SecureLevel;
						document.getElementsByName("MULTI_SPECIAL_RECORD_rec")[1].value = RecordObj.SpecialRecord;
						document.getElementById("RECORD_CLASS_NUM").value = RecordObj.RecordClassNum;
					}
        		}
        	}
        	$(".tabLine").hide();
        }
        /*if($$($.parseJSON(document.getElementById("APVLIST").value)).find("step").concat().find("comment").length > 0 && getInfo("Request.mode") != "REDRAFT"){
        	$(".icnView").click();
        }*/
       
        /*if(formJson.Request.gloct == "COMPLETE"){
        	var sendInfo = false;
        	if(formJson.BodyContext.SubTable1 != undefined){
        		$(formJson.BodyContext.SubTable1).each(function(){
        			if(this.MULTI_RECEIVER_TYPE == "Out" && this.MULTI_RECEIVENAMES != ""){
        				sendInfo = true;
        				return false;
        			}
        		});
        	}
        	if(sendInfo && getInfo('AppInfo.usid') == getInfo('FormInstanceInfo.InitiatorID')){
            	$('#btSendRequset').show();	
        	}
        }
        if(formJson.Request.gloct == "STANDBY"){
        	//window.setTimeout("$('#btSendRequset').show();", 5000);
        	$('#btStamp, #btSendApprove').show();	
        }*/
					  
//		//뷰어처리
//        if(getInfo("Request.callMode") == "HWP" || getInfo("Request.govstate") == "SENDWAIT"){
//            // 에디터 처리
//            LoadEditorHWP_Multi("divWebEditorContainer1", 1);
//            $('#hwpPreview').hide();
//            $("#divWebEditorContainer1").show();
//        }else{
//	        var url = Common.getBaseConfig("MobileDocConverterURL") + "?fid=hwpPreview"+getInfo("FormInstanceInfo.FormInstID")+"&fileType=URL&convertType=1&filePath=" + encodeURIComponent("" + location.protocol + "//" + location.host + "/covicore/common/hwpPreviewDown.do?formInstID="+getInfo("FormInstanceInfo.FormInstID")+"&userCode=" + encodeURIComponent(Common.getSession("UR_Code"))) + "&sync=true&force=false";
//	        $('#hwpPreview').show();
//	        $('#IframePreviewHwp').attr("src", url);
//	        $("#divWebEditorContainer1").hide();
//        }
        
        setReadModeHWP();
        
        //cllee - 배포용 문서 만들기 위해 문서 오픈시 에디터 로드
    	//LoadEditorHWP_Multi("divWebEditorContainer1", 1);
    }
    else {
        if (_ie || formJson.ExtInfo.UseWebHWPEditYN == "Y") {
        } else {
            alert("해당 브라우져는 한글기안 작성기능을 지원하지 않습니다.\nInternet Explorer를 이용해주세요.");
            top.close();
        }
        
        //발신명의 select box 세팅
    	getSenderList();
    	//문서정보 값 셋팅
    	
    	
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        if (JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'W');            

			$(formJson.BodyData.SubTable1).each(function(idx, item){
				if(formJson.BodyData.SubTable1[idx] != null && formJson.BodyData.SubTable1[idx].MULTI_ATTACH_FILE != ""){
					$('#SubTable1 .multi-row').find('[name=MULTI_ATTACH_FILE]')[idx].value = JSON.stringify(formJson.BodyData.SubTable1[idx].MULTI_ATTACH_FILE);
				}
			});

        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'W', { minLength: 1 });
        }
        
        // 에디터 처리
    	LoadEditorHWP_Multi("divWebEditorContainer1", 1);
        /*
        if (formJson.Request.gloct != "DRAFT") {
        	if(formJson.BodyData.SubTable1 != null){
        		$(formJson.BodyData.SubTable1).each(function(i, item){
        			if(i != 0){
        				addTabClass(item.MULTI_DOC_TYPE);
        			}
        		});
        	}
        }
*/
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            //document.getElementById("INITIATOR_TEL").value = getInfo("ustp");
            //document.getElementById("INITIATOR_FAX").value = getInfo("usfx");
            //document.getElementById("INITIATOR_EMAIL").value = getInfo("usem");
            
            document.getElementById("DRAFTER_ID").value = getInfo("AppInfo.usid");
            document.getElementById("DRAFTER_NAME").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("DRAFTER_DEPT").value = getInfo("AppInfo.dpid");
            document.getElementById("DRAFTER_DEPTNM").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
        }
    }
    
    // 수신부서 화면표시 (수신지정된 안건만 표시함) Start
    if(getInfo('ProcessInfo.SubKind') == "R"){
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
				//$("#divWebEditorContainer1").remove();
			} else {
		    	//changeTab((idx+1));
			}
		});
    } else {
    	//changeTab(1);
    }

    // 수신부서 화면표시 (수신지정된 안건만 표시함) End
}

//비공개 사유
function ShowPublicActionHelp() {
    var sTitle = "HELP";
    var sUrl2 = "form/goSecOptionHelpPopup.do";
    var iHeight = 530; var iWidth = 830;
 

    var nLeft = (screen.width - iWidth) / 2;
    var nTop = (screen.height - iHeight) / 2;
    var sWidth = iWidth.toString() + "px";
    var sHeight = iHeight.toString() + "px";
    var sLeft = nLeft.toString() + "px";
    var sTop = nTop.toString() + "px";

    CFN_OpenWindow(sUrl2, "", iWidth, iHeight, "resize");
}
var getOriginationList ="";
var selOptIsDefault ="";

function initSetData(mode){//초기 값 셋팅
	//부서코드
	initdoccode();
	
	if(sessionObjFormMenu.DEPTID.indexOf("HYUNV_") != '-1'){
		var strDeptId = sessionObjFormMenu.DEPTID.split("HYUNV_")[1];
		var subSDeptId =  strDeptId.substring(0,2);
		
		if(mode != "TEMPSAVE") {
			$("#originationH_Data").val(JSON.stringify(getOriginationList[selOptIsDefault]));
			var resData = JSON.parse($("#originationH_Data").val());
			document.getElementsByName("MULTI_ORIGINATION_CHECK")[1].value = getOriginationList[selOptIsDefault].SEND_ID;
			document.getElementsByName("MULTI_originationH_Data")[1].value = $("#originationH_Data").val();
			$("#RELEASE_CHECK").val($("#RELEASE_CHECK").find('input:checked').val());
			document.getElementsByName("MULTI_RELEASE_CHECK")[1].value = $("#RELEASE_CHECK").find('input:checked').val();
			$("#RECEIVE_CHECK").val($("#RECEIVE_CHECK").find('input:checked').val());
			document.getElementsByName("MULTI_RECEIVE_CHECK")[1].value = $("#RECEIVE_CHECK").find('input:checked').val();
			HwpCtrl.PutFieldText("publication", "공개");
			HwpCtrl.PutFieldText('fax', " ");
			HwpCtrl.PutFieldText('homepage', Common.getBaseConfig("HYU_Hompage"));
			HwpCtrl.PutFieldText("telephone",  Common.GetObjectInfo("UR",getInfo("AppInfo.usid"), "PHONENUMBER").PHONENUMBER);
			HwpCtrl.PutFieldText('email', getInfo('AppInfo.ussip'));
			HwpCtrl.PutFieldText("symbol", " ");
			HwpCtrl.MoveToField("chief", true, true, false);
			HwpCtrl.PutFieldText("chief", $("#ORIGINATION_CHECK option:selected").text());//기관장명
			HwpCtrl.MoveToField("headcampaign", true, true, false);
			HwpCtrl.PutFieldText("headcampaign", resData.CAMPAIGN_T);//캠페인 상
			HwpCtrl.MoveToField("organ", true, true, false);
			HwpCtrl.PutFieldText("organ", Common.getBaseConfig("HYU_organ"));//기관명
			if(subSDeptId =="FH"){//한양대학교 
				HwpCtrl.PutFieldText('zipcode', Common.getBaseConfig("HYU_PostNum"));
				HwpCtrl.PutFieldText('address', Common.getBaseConfig("HYU_Address") + " " + sessionObjFormMenu.DEPTNAME);
			}else{//subSDeptId =="FY" 한양대학교 에리카
				HwpCtrl.PutFieldText('zipcode', Common.getBaseConfig("HYUERICA_PostNum"));
				HwpCtrl.PutFieldText('address', Common.getBaseConfig("HYUERICA_Address") + " " + sessionObjFormMenu.DEPTNAME);
			}
			//기록물철
			if($("#RECORD_SUBJECT").val() != ""){
				var RecordObj = JSON.parse($("#RECORD_SUBJECT").val());
				document.getElementsByName("MULTI_RECORD_SUBJECT")[1].value = RecordObj.RecordSubject;
				document.getElementsByName("MULTI_RECORD_CLASS_NUM")[1].value = RecordObj.RecordClassNum;
				document.getElementsByName("MULTI_REGIST_CHECK")[1].value = RecordObj.RegistCheck;
				document.getElementsByName("MULTI_KEEP_PERIOD")[1].value = RecordObj.KeepPeriod;
				document.getElementsByName("MULTI_SECURE_LEVEL")[1].value = RecordObj.SecureLevel;
				document.getElementsByName("MULTI_SPECIAL_RECORD")[1].value = RecordObj.SpecialRecord;
				document.getElementById("RECORD_CLASS_NUM").value = RecordObj.RecordClassNum;
			}
			
			if(mode == "REUSE"){
	    		HwpCtrl.PutFieldText("isStamp", " ");
	    		HwpCtrl.PutFieldText("chief_sign", " "); // 이미지 삽입 전 공백 삽입(이미지만 삽입시 출력/미리보기시 이미지 사라짐)
	    		HwpCtrl.PutFieldText("seal", " "); // 이미지 삽입 전 공백 삽입(이미지만 삽입시 출력/미리보기시 이미지 사라짐)
	    		
	    		HwpCtrl.PutFieldText("docnumber", " ");
	    		HwpCtrl.PutFieldText("enforcedate", " ");
	    		HwpCtrl.PutFieldText('receiptnumber', " ");
	    		HwpCtrl.PutFieldText('receiptdate', " ");
	    		HwpCtrl.PutFieldText("sealsign", " ");
	    		
	    		HwpCtrl.PutFieldText("recipient", " ");
	    		HwpCtrl.PutFieldText("recipients", " ");		
	    		HwpCtrl.PutFieldText("hrecipients", " ");
	    		
	    		document.getElementById("ReceiveNames").value = "";
	    		document.getElementsByName("MULTI_RECEIPTLIST")[1].value = "";
	    		document.getElementsByName("MULTI_RECEIVENAMES")[1].value = "";
	    		document.getElementById("RECEIVEGOV_NAMES").value = "";
	    		document.getElementsByName("MULTI_RECEIVEGOV_INFO")[1].value = "";
	    		document.getElementsByName("MULTI_RECEIVEGOV_INFO_Data")[1].value = "";
			}
		}else {
			$("#originationH_Data").val(JSON.stringify(formJson.BodyContext.SubTable1.MULTI_originationH_Data));
			var resData = JSON.parse($("#originationH_Data").val());
			document.getElementsByName("MULTI_ORIGINATION_CHECK")[1].value = formJson.BodyContext.SubTable1.MULTI_originationH_Data.SEND_ID;
			document.getElementsByName("MULTI_originationH_Data")[1].value = $("#originationH_Data").val();
			
			$("#RELEASE_CHECK").val(formJson.BodyContext.SubTable1.MULTI_RELEASE_CHECK);
			document.getElementsByName("MULTI_RELEASE_CHECK")[1].value = formJson.BodyContext.SubTable1.MULTI_RELEASE_CHECK;
			
			$("#RECEIVE_CHECK").val(formJson.BodyContext.SubTable1.MULTI_RECEIVE_CHECK);
			document.getElementsByName("MULTI_RECEIVE_CHECK")[1].value = formJson.BodyContext.SubTable1.MULTI_RECEIVE_CHECK;
			if($("#RELEASE_CHECK").val() == "1"){
				HwpCtrl.PutFieldText("publication", "공개");			
			}else if($("#RELEASE_CHECK").val() == "3"){
				HwpCtrl.PutFieldText("publication", "비공개");			
			}
			
			document.getElementsByName("MULTI_DOC_TYPE")[1].value = "normal";
			document.getElementsByName("MULTI_MANUAL_APV")[1].value = formJson.BodyContext.SubTable1.MULTI_MANUAL_APV;
			document.getElementsByName("MULTI_RECEIPTLIST")[1].value = document.getElementById("ReceiptList").value;
			document.getElementsByName("MULTI_RECEIVENAMES")[1].value = document.getElementById("ReceiveNames").value;
			document.getElementsByName("MULTI_RECEIVEGOV_INFO")[1].value = formJson.BodyContext.SubTable1.MULTI_RECEIVEGOV_INFO;
			document.getElementsByName("MULTI_RECEIVEGOV_INFO_Data")[1].value = formJson.BodyContext.SubTable1.MULTI_RECEIVEGOV_INFO_Data;
			
			
			HwpCtrl.PutFieldText('fax', formJson.BodyContext.SubTable1.MULTI_originationH_Data.FAX);
			HwpCtrl.PutFieldText('address', formJson.BodyContext.SubTable1.MULTI_originationH_Data.ADDRESS + " " + sessionObjFormMenu.DEPTNAME);
			HwpCtrl.PutFieldText('homepage', formJson.BodyContext.SubTable1.MULTI_originationH_Data.HOMEPAGE);
			HwpCtrl.PutFieldText("telephone",  Common.GetObjectInfo("UR",getInfo("AppInfo.usid"), "PHONENUMBER").PHONENUMBER);
			HwpCtrl.PutFieldText('email', getInfo('AppInfo.ussip'));
			HwpCtrl.PutFieldText("headcampaign", formJson.BodyContext.SubTable1.MULTI_originationH_Data.CAMPAIGN_T);//캠페인 상
			HwpCtrl.PutFieldText("chief", formJson.BodyContext.SubTable1.MULTI_originationH_Data.NAME);//기관장명
			HwpCtrl.PutFieldText("organ", formJson.BodyContext.SubTable1.MULTI_originationH_Data.OUNAME);//기관명
			//HwpCtrl.PutFieldText("symbol", formJson.BodyContext.SubTable1.MULTI_originationH_Data.SYMBOL);
			HwpPutImg(resData);
		
			//기록물철
			if($("#RECORD_SUBJECT").val() != ""){
				var RecordObj = JSON.parse($("#RECORD_SUBJECT").val());
				document.getElementsByName("MULTI_RECORD_SUBJECT")[1].value = RecordObj.RecordSubject;
				document.getElementsByName("MULTI_RECORD_CLASS_NUM")[1].value = RecordObj.RecordClassNum;
				document.getElementsByName("MULTI_REGIST_CHECK")[1].value = RecordObj.RegistCheck;
				document.getElementsByName("MULTI_KEEP_PERIOD")[1].value = RecordObj.KeepPeriod;
				document.getElementsByName("MULTI_SECURE_LEVEL")[1].value = RecordObj.SecureLevel;
				document.getElementsByName("MULTI_SPECIAL_RECORD")[1].value = RecordObj.SpecialRecord;
				document.getElementById("RECORD_CLASS_NUM").value = RecordObj.RecordClassNum;
			}
		}
	}
}

function initSetMultiOriginationHData(){
	if(typeof getOriginationList[selOptIsDefault] == "undefined"){
		getOriginationList[selOptIsDefault] = formJson.BodyContext.SubTable1.MULTI_originationH_Data;
		$("#originationH_Data").val(JSON.stringify(getOriginationList[selOptIsDefault]));
		var resData = JSON.parse($("#originationH_Data").val());
		document.getElementsByName("MULTI_originationH_Data")[1].value = $("#originationH_Data").val();
		if(getInfo("Request.editmode") =="Y" && getInfo("Request.mode") == "APPROVAL"){
			$("#ORIGINATION_CHECK option:selected").text(formJson.BodyContext.SubTable1.MULTI_originationH_Data.DISPLAY_NAME);
		}
	}else{
		$("#originationH_Data").val(JSON.stringify(getOriginationList[selOptIsDefault]));
		var resData = JSON.parse($("#originationH_Data").val());
		document.getElementsByName("MULTI_originationH_Data")[1].value = $("#originationH_Data").val();
		if(getInfo("Request.editmode") =="Y" && getInfo("Request.mode") == "APPROVAL"){
			$("#ORIGINATION_CHECK option:selected").text(formJson.BodyContext.SubTable1.MULTI_originationH_Data.DISPLAY_NAME);
		}
	}
}

function chkdocInfo(obj){
	if(getInfo("Request.templatemode") != "Read" || getInfo("Request.mode") == "REDRAFT"){
		var idx = '1';
		var id = $(obj).attr("id");
		var savedVal = "";
		
		if(id == "RELEASE_CHECK") {//공개여부
			savedVal = $(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK").val(savedVal);
				HwpCtrl.PutFieldText("publication", "공개");
				$("#chk_secrecy").prop("checked", false);
			}else{
				$("#RELEASE_CHECK").val(savedVal);
				HwpCtrl.PutFieldText("publication", "비공개");
				$("#chk_secrecy").prop("checked", "checked");
			}
			document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		else if(id == "RELEASE_CHECK_rec") {//공개여부
			savedVal = $(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK_rec").val(savedVal);
				//HwpCtrl.PutFieldText("publication", "공개");
				$("#chk_secrecy_rec").prop("checked", false);
			}else{
				$("#RELEASE_CHECK_rec").val(savedVal);
				//HwpCtrl.PutFieldText("publication", "비공개");
				$("#chk_secrecy_rec").prop("checked", "checked");
			}
			document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		//else if(id == "MANUAL_APV"){//종이접수공문
		else if(id == "CHK_MANUAL_APV"){
			//savedVal = $(obj).find("input").is(":checked");
			savedVal = $(obj).is(":checked");
			$("#CHK_MANUAL_APV").val(savedVal ? "Y" : "N");
			if(savedVal == true){
				savedVal = 'Y';
				$("#CHK_MANUAL_APV").prop("checked", "checked");
				$("#MANUAL_APV").val("Y");
				$("#RECEIVE_CHECK_indoc").prop("checked","checked");
				document.getElementsByName("MULTI_RECEIVE_CHECK")[idx].value = "indoc";
				$("#btMultiReceive").hide();
				HwpCtrl.PutFieldText("recipient", "내부결재");
				$("#RECEIVE_CHECK_indoc").attr("disabled",true);
				$("#RECEIVE_CHECK_else").attr("disabled",true);
				Common.Warning(Common.getDic("msg_selectPaperScanfile"));//종이접수문서 스캔 파일을 첨부하여 기안해야 합니다.
			}else{
				savedVal = 'N';
				$("#CHK_MANUAL_APV").prop("checked", false);
				$("#MANUAL_APV").val("N");
				$("#RECEIVE_CHECK_else").prop("checked","checked");
				$("#btMultiReceive").show();
				HwpCtrl.PutFieldText("recipient", " ");
				$("#RECEIVE_CHECK_indoc").attr("disabled",false);
				$("#RECEIVE_CHECK_else").attr("disabled",false);
			}
			document.getElementsByName("MULTI_MANUAL_APV")[idx].value = savedVal;
			//$(obj).val(savedVal);
		}
		else if(id == "RECEIVE_CHECK"){
			savedVal= $(obj).find("input:checked").val();
			if(savedVal == "indoc"){//내부결재
				HwpCtrl.MoveToField("recipient", true, true, false);
				HwpCtrl.PutFieldText("hrecipients", " ");
				HwpCtrl.PutFieldText("recipient", "내부결재");
				HwpCtrl.PutFieldText("recipients", " ");
				$("#btMultiReceive").hide();
			}
			else if(savedVal == "else"){//시행발송
				HwpCtrl.PutFieldText("recipient", " ");
				$("#btMultiReceive").show();
			}
			document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
		}	
		//$("#DOC_NO").val(opener.document.getElementById("DocNo").value);
	}
}


function getOriginationname(data, selOpt){
	getOriginationList = data.list;	
	selOptIsDefault = selOpt;
}

function getOriginationname1(obj){
	var hwp_BaseImgURL = Common.getBaseConfig("BackStorage");
	var result = null;
	var hwp_logo = Common.getBaseConfig("StampImage_SavePath") + "HYU.jpg"; 
	
	var idx = '1';
	var id = $(obj).attr("id");
	var value = $(obj).val();
	var savedVal = "";
	
	
	if(sessionObjFormMenu.DEPTID.indexOf("HYUNV_") != '-1'){
		var strDeptId = sessionObjFormMenu.DEPTID.split("HYUNV_")[1];
		var subSDeptId =  strDeptId.substring(0,2);
		
		if(id == "ORIGINATION_CHECK"){
			
			var dataType = getOriginationList[value].DATATYPE;
			
			//21  처장 , 62 팀장
			if(dataType =="V"){
				//if(value == "62"){//팀장
					$("#originationH_Data").val(JSON.stringify(getOriginationList[value]));
					var resData = JSON.parse($("#originationH_Data").val());
					document.getElementsByName("MULTI_"+id)[idx].value = value;
					document.getElementsByName("MULTI_originationH_Data")[1].value = $("#originationH_Data").val();
					
					document.getElementsByName("MULTI_RECEIPTLIST")[1].value = document.getElementById("ReceiptList").value;
					document.getElementsByName("MULTI_RECEIVENAMES")[1].value = document.getElementById("ReceiveNames").value;
					HwpCtrl.PutFieldText('fax', " ");
					
					if(subSDeptId =="FH"){//한양대학교 
						HwpCtrl.PutFieldText('zipcode', Common.getBaseConfig("HYU_PostNum"));
						HwpCtrl.PutFieldText('address', Common.getBaseConfig("HYU_Address") + " " + sessionObjFormMenu.DEPTNAME);
						//getOriginationList[Hdata].ADDRESS = Common.getBaseConfig("HYU_Address") + " " + sessionObjFormMenu.DEPTNAME;
					}else{//subSDeptId =="FY" 한양대학교 에리카
						HwpCtrl.PutFieldText('zipcode', Common.getBaseConfig("HYUERICA_PostNum"));
						HwpCtrl.PutFieldText('address', Common.getBaseConfig("HYUERICA_Address") + " " + sessionObjFormMenu.DEPTNAME);
					}
					
					/*HwpCtrl.PutFieldText('zipcode', Common.getBaseConfig("HYU_PostNum"));
					HwpCtrl.PutFieldText('address', Common.getBaseConfig("HYU_Address") + " " + sessionObjFormMenu.DEPTNAME);*/
					HwpCtrl.PutFieldText('homepage', Common.getBaseConfig("HYU_Hompage"));
					HwpCtrl.PutFieldText("telephone", Common.GetObjectInfo("UR",getInfo("AppInfo.usid"), "PHONENUMBER").PHONENUMBER);
					HwpCtrl.PutFieldText('email', getInfo('AppInfo.ussip'));
					HwpCtrl.PutFieldText("headcampaign", resData.CAMPAIGN_T);//캠페인 상
					HwpCtrl.PutFieldText("chief", $("#ORIGINATION_CHECK option:selected").text());//기관장명
					HwpCtrl.PutFieldText("organ", Common.getBaseConfig("HYU_organ"));//기관명
					HwpCtrl.PutFieldText("symbol", " ");
				/*}else if(value == "21"){
					$("#originationH_Data").val(JSON.stringify(getOriginationList[1]));
					var resData = JSON.parse($("#originationH_Data").val());
					document.getElementsByName("MULTI_"+id)[idx].value = value;
					document.getElementsByName("MULTI_originationH_Data")[1].value = $("#originationH_Data").val();
					
					document.getElementsByName("MULTI_RECEIPTLIST")[1].value = document.getElementById("ReceiptList").value;
					document.getElementsByName("MULTI_RECEIVENAMES")[1].value = document.getElementById("ReceiveNames").value;
					HwpCtrl.PutFieldText('fax', " ");
					HwpCtrl.PutFieldText('address', Common.getBaseConfig("HYU_Address") + " " + sessionObjFormMenu.DEPTNAME);
					HwpCtrl.PutFieldText('homepage', Common.getBaseConfig("HYU_Hompage"));
					HwpCtrl.PutFieldText("telephone", Common.GetObjectInfo("UR",getInfo("AppInfo.usid"), "PHONENUMBER").PHONENUMBER);
					HwpCtrl.PutFieldText('email', getInfo('AppInfo.ussip'));
					HwpCtrl.PutFieldText("headcampaign", resData.CAMPAIGN_T);//캠페인 상
					HwpCtrl.PutFieldText("chief", $("#ORIGINATION_CHECK option:selected").text());//기관장명
					HwpCtrl.PutFieldText("organ", Common.getBaseConfig("HYU_organ"));//기관명
					HwpCtrl.PutFieldText("symbol", " ");
				}*/
			}
			else if(dataType =="T"){
	//			for(var i=0; i < getOriginationList.length; i++){
	//				if(getOriginationList[i].SEND_ID == value){
	//					$("#originationH_Data").val(JSON.stringify(getOriginationList[i]));
	//				}
	//			}
				$("#originationH_Data").val(JSON.stringify(getOriginationList[value]));
				var resData = JSON.parse($("#originationH_Data").val());
				document.getElementsByName("MULTI_"+id)[idx].value = value;
				document.getElementsByName("MULTI_originationH_Data")[1].value = $("#originationH_Data").val();
				
				document.getElementsByName("MULTI_RECEIPTLIST")[1].value = document.getElementById("ReceiptList").value;
				document.getElementsByName("MULTI_RECEIVENAMES")[1].value = document.getElementById("ReceiveNames").value;
				HwpCtrl.PutFieldText("route", document.getElementsByName("MULTI_APV_VIA")[1].value);
				HwpCtrl.PutFieldText("fax", resData.FAX);
				HwpCtrl.PutFieldText("address", resData.ADDRESS);
				HwpCtrl.PutFieldText("homepage", resData.HOMEPAGE);
				HwpCtrl.PutFieldText("telephone", resData.TEL);
				HwpCtrl.PutFieldText("email", resData.EMAIL);
				HwpCtrl.MoveToField("headcampaign", true, true, false);
				HwpCtrl.PutFieldText("headcampaign", resData.CAMPAIGN_T);//캠페인 상
				HwpCtrl.MoveToField("chief", true, true, false);
				HwpCtrl.PutFieldText("chief", resData.NAME);//기관장명
				HwpCtrl.MoveToField("organ", true, true, false);
				HwpCtrl.PutFieldText("organ", resData.OUNAME);//기관명
				//HwpCtrl.PutFieldText("footcampaign", resData.CAMPAIGN_F);//캠페인 하
				HwpPutImg(resData);
			}
			
			$("#SEND_NAME").val($("#ORIGINATION_CHECK option:selected").text()); //접수대기문서정보
		}
	}
}

function SelectRecord(obj){
	var idx = '1';
	var id = $(obj).attr("id");
	var savedVal = $(obj).val();
	
	document.getElementsByName("MULTI_"+id)[idx].value = $("#RECORD_SUBJECT option:selected").text().split(" > ")[3];
	document.getElementsByName("MULTI_RECORD_CLASS_NUM")[idx].value = JSON.parse(savedVal).RecordClassNum;
	document.getElementsByName("MULTI_REGIST_CHECK")[idx].value = JSON.parse(savedVal).RegistCheck;
	document.getElementsByName("MULTI_KEEP_PERIOD")[idx].value = JSON.parse(savedVal).KeepPeriod;
	document.getElementsByName("MULTI_SECURE_LEVEL")[idx].value = JSON.parse(savedVal).SecureLevel;
	document.getElementsByName("MULTI_SPECIAL_RECORD")[idx].value = JSON.parse(savedVal).SpecialRecord;
	document.getElementById("RECORD_CLASS_NUM").value = JSON.parse(savedVal).RecordClassNum;
}

function SelectRecord_rec(obj){
	var idx = '1';
	var id = $(obj).attr("id");
	var savedVal = $(obj).val();
	
	document.getElementsByName("MULTI_"+id)[idx].value = $("#RECORD_SUBJECT_rec option:selected").text().split(" > ")[3];
	document.getElementsByName("MULTI_RECORD_CLASS_NUM_rec")[idx].value = JSON.parse(savedVal).RecordClassNum;
	document.getElementsByName("MULTI_REGIST_CHECK_rec")[idx].value = JSON.parse(savedVal).RegistCheck;
	document.getElementsByName("MULTI_KEEP_PERIOD_rec")[idx].value = JSON.parse(savedVal).KeepPeriod;
	document.getElementsByName("MULTI_SECURE_LEVEL_rec")[idx].value = JSON.parse(savedVal).SecureLevel;
	document.getElementsByName("MULTI_SPECIAL_RECORD_rec")[idx].value = JSON.parse(savedVal).SpecialRecord;
	document.getElementById("RECORD_CLASS_NUM_rec").value = JSON.parse(savedVal).RecordClassNum;
}

function HwpPutImg(resData) {
	//var hwp_BaseImgURL = "http://docsdev.hanyang.ac.kr/GWStorage/e-sign/Approval/Logo/SealImg/7002282_H000191_20141010124847.png" //이미지 테스트url
	var hwp_BaseImgURL = Common.getBaseConfig("BackStorage");
    var hwp_sign = resData.LOGO;
    var result = null;
	HwpCtrl.PutFieldText("logo", " ");
    HwpCtrl.MoveToField("logo", true, false, true);
  	var hwp_HostFullName = document.location.protocol + "//" + document.location.hostname + (document.location.hostname=="localhost"?":"+document.location.port:"");
    var logo_path = hwp_HostFullName + hwp_BaseImgURL + hwp_sign;
   
    HwpCtrl.InsertPicture(logo_path, true, 1, false, false, 0, 17, 17, function(ctrl){
  		if(ctrl){
  		console.log('성공');
  		} else{
  		console.log('실패');
  		}
  		});
    
    result = null;
        
    var hwp_Symbol = resData.SYMBOL;
    var symbol_path = hwp_HostFullName + hwp_BaseImgURL + hwp_Symbol;
    HwpCtrl.PutFieldText("symbol", " ")
    HwpCtrl.MoveToField("symbol", true, false, true);
    HwpCtrl.InsertPicture(symbol_path, true, 1, false, false, 0, 17, 17, function(ctrl){
  		if(ctrl){
  		console.log('성공');
  		} else{
  		console.log('실패');
  		}
  		});
    
    result = null; 
   
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
        // 필수 입력 필드 체크
        if (document.getElementById("FILEATTACH").value == "false") {
            Common.Warning("파일은 최대 3MB까지 업로드 가능합니다.");
            return false;
        }
        
        if(!checkForm_HWPMulti()){
        	return false;
        };
        
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
}

/*//본문 XML로 구성
function makeBodyContext() {    
    var bodyContextObj = {};
    var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("SubTable1", "stField"));
    return bodyContextObj;
}*/

//본문 XML로 구성
function makeBodyContext() {    
    var bodyContextObj = {};
    var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("SubTable1", "stField"));
	
	//대외수신처 + 수기 입력 수신처
	var receiveCodes = [];
	var receiveNames = [];	
	if(document.getElementsByName("MULTI_RECEIVE_CHECK")[1].value == "outpaperdoc") {
		bodyContextObj.BodyContext.receiverName = document.getElementsByName("MULTI_Receivepaper")[1].value;
	}else {
		$("#RECEIVEGOV_NAMES").val().length > 0 && $("#RECEIVEGOV_NAMES").val().split(";").map(function(item,index){
			var size = item.split(':').length;
			receiveCodes = receiveCodes.concat( item.split(':')[1] );
			receiveNames = receiveNames.concat( item.split(':')[size-1] );		
		});
		bodyContextObj.BodyContext.receiver = receiveCodes.join(';');
		//bodyContextObj.BodyContext.receiverName = receiveNames.concat( $("#RECEIVEGOV_TEXT").val().length > 0 ? $("#RECEIVEGOV_TEXT").val().split(";") : [] ).join(',');
		bodyContextObj.BodyContext.receiverName = receiveNames.concat([]).join(',');		
	}
	    
	return bodyContextObj;
}

var callPacker = function(status){	
	try {
		HwpCtrl.MoveToField('body', true, true, true);
		HwpCtrl.SaveAs("test.xml", "PUBDOCBODY", "saveblock;", function (res) {
			//alert(res.downloadUrl);
			
	    	$.ajax({
				url: "/govdocs/service/callPacker.do", // local:govdocs, prd:covigovdocs
				type:"POST",
				data: {
					formInstId 	: formJson.FormInstanceInfo.FormInstID
					,processId 	: formJson.FormInstanceInfo.ProcessID
					,type 		: status || "send"
					,bodyUrl	: res.downloadUrl
					,bodySize	: res.size
					,receiver 		: formJson.BodyContext.SubTable1.MULTI_RECEIVEGOV_INFO.split("^")[1]
					,receiverName 	: formJson.BodyContext.SubTable1.MULTI_RECEIVEGOV_INFO.split("^")[0]
					,uniqueID	: res.uniqueId
				},				
				success:function (data) { 
					data.status === "OK" && Common.Inform("발송되었습니다.","",function(){ 
						$("#btGovDocsSend").hide();
						$("#btGovDocsReSend").hide();
						opener.docFunc.refresh(); 
						window.close();
	                });
				},  
				error:function(response, status, error){ 
	                    Common.Inform("처리 실패하였습니다.", 'Information Dialog', null);
	                }
			});
			
		});
		HwpCtrl.MoveToField('body', true, true, false);

    } catch (e) {
        Common.Error(e.message);
    }	
}

var preview = function(openerObj){		
		
	var bodyContext = getInfo("Request.mode") === "DRAFT" ? opener.makeBodyContext().BodyContext : formJson.BodyContext;	
	
	$.ajax({
		url: "/approval/govDocs/preview.do",
		type:"POST",
		data: {
			bodyContext 		: 	JSON.stringify( { tbContentElementHWP : bodyContext.tbContentElementHWP , via : bodyContext.via } )
			,receiverName 		: 	bodyContext.receiverName
			,approvalContext	: 	getInfo("Request.mode") === "DRAFT" ?  $("#APVLIST",opener.document).val() : JSON.stringify(formJson.ApprovalLine)
			,processSubject		:	formJson.FormInstanceInfo.Subject
			,publicationCode	:	bodyContext.SaveTerm + bodyContext.publicationCode
			,publicationValue	:	bodyContext.publicationValue
			,regNumberCode		:	""
			,docNumber			:	formJson.FormInstanceInfo.DocNo || ""
			,enForceDate		:	formJson.FormInstanceInfo.CompletedDate || ""
			,emailAddress		:	getInfo("AppInfo.ussip")
			,initiatorID		:	getInfo("AppInfo.usid")
			,requestMode		:	getInfo("Request.mode")
		},		
		success:function (data) {
			$("#tbContentElement").empty().append(data.content);			
			getInfo("Request.mode") !== "DRAFT" && $("#divFormApvLines,#btPreView,#btOTrans,#btPrint,#tblFormSubject").hide();
		},
		error:function(response, status, error){ 
			console.log( response ) 
		}
	});
}



//추가발송, 중복발송
function btSend_Click() {
	_CallBackMethod = OrgMap_CallBack;
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod&szObject=&type="+"C9"+"&setParamData=_setParamdata&DisabledYN=Y", "", "1060px", "580px");
}
function OrgMap_CallBack(pStrItemInfo) {
    var oJsonOrgMap = $.parseJSON(pStrItemInfo);
    
    
    var approvalLineObj ={
    	steps : {
    		datecreated : ""	
	   		,division : {
	   			divisiontype	: "send"
	   			,processID : ""
				,name	: coviDic.dicMap.lbl_apv_circulation_sent
				,oucode	: getInfo("AppInfo.dpid_apv")
				,ouname	: getInfo("AppInfo.dpdn_apv")
				,status : "pending"
				,taskinfo : {				
					status 	: "inactive"
	                ,result : "inactive"
	                ,kind 	: "send"
	                ,datereceived : getInfo("AppInfo.svdt_TimeZone")
				}
				,step : {
					unittype : "person"
					,routetype : "approve"
					,name : coviDic.dicMap.lbl_apv_writer
					,ou : {
						code : getInfo("AppInfo.dpid_apv")
						,name : getInfo("AppInfo.dpdn_apv")
						,person : {
							code 		: getInfo("AppInfo.usid")
	                        ,name 		: getInfo("AppInfo.usnm_multi")
	                        ,position 	: getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi")
	                        ,title 		: getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi")
	                        ,level 		: getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi")
	                        ,oucode 	: getInfo("AppInfo.dpid")
	                        ,ouname 	: getInfo("AppInfo.dpnm_multi")
	                        ,sipaddress : getInfo("AppInfo.ussip")
	                        ,taskinfo	: {
	                        	status 	: "inactive"
	                            ,result : "inactive"
	                            ,kind 	: "charge"
	                            ,datereceived : getInfo("AppInfo.svdt_TimeZone")
	                            ,visible : "n"
	                        }
						}
					}
				}    	
	   		}
    	}	
    } 
   
    
    if (oJsonOrgMap != null) {
    	m_oInfoSrc.m_bFrmExtDirty = true; 
    	
    	var objArr_person = new Array();
    	var objArr_ou = new Array();
    	
    	var dataInfo = {};
    	var dataInfoStr = "";
    	var dataContext = m_oInfoSrc.getDefaultJSON();
    	dataContext.FormData = m_oInfoSrc.getFormJSON().FormData;
    	
    	//dataInfo.piid = m_oInfoSrc.getInfo("ProcessInfo.ParentProcessID");    	
    	dataInfo.piid = "0";    	
    	dataInfo.approvalLine = JSON.stringify(approvalLineObj);    	
    	dataInfo.docNumber = m_oInfoSrc.getInfo("FormInstanceInfo.DocNo");
    	dataInfo.context = JSON.stringify(dataContext);
    	
        var strflag = true;

        var oChildren = $$(oJsonOrgMap).find("item");
        $$(oChildren).concat().each(function (i, oChild) {
        	var dataInfo_receiptList = {};
        	
            var cmpoucode = ";" +  $$(oChild).attr("AN") + ";";
            if (m_oInfoSrc.document.getElementById("ReceiptList").value.indexOf(cmpoucode) > -1) {
                strflag = false;
            }
            var currNode = {};
            if ($$(oChild).attr("itemType") == "user") {
            	$$(dataInfo_receiptList).attr("code", $$(oChild).attr("AN"));
            	$$(dataInfo_receiptList).attr("name", $$(oChild).attr("DN"));
            	$$(dataInfo_receiptList).attr("type", "1");
            	$$(dataInfo_receiptList).attr("status", "inactive");
            	
            	objArr_person.push(dataInfo_receiptList);
            } else {
            	$$(dataInfo_receiptList).attr("code", $$(oChild).attr("AN"));
            	$$(dataInfo_receiptList).attr("name", $$(oChild).attr("DN"));
            	$$(dataInfo_receiptList).attr("type", "0");
            	$$(dataInfo_receiptList).attr("status", "inactive");
            	
            	objArr_ou.push(dataInfo_receiptList);
            }
        });
        
        var sMsg = Common.getDic("msg_apv_191");//"해당 항목들을 발송하시겠습니까?"
        if(strflag == false) sMsg = Common.getDic("msg_apv_345");

        //Common.Confirm(sMsg, "Confirmation Dialog", function (result) {
            //if (result) {
            	if(objArr_person.length > 0) { // 사용자
            		dataInfo.receiptList = objArr_person;
            		dataInfo.type = "1";
            		
            		dataInfoStr = JSON.stringify(dataInfo);
            		
            		startDistribution(dataInfoStr);
            	}
            	if(objArr_ou.length > 0) { // 부서
            		dataInfo.receiptList = objArr_ou;
            		dataInfo.type = "0";
            		
            		dataInfoStr = JSON.stringify(dataInfo);
            		
            		//hnkang, 부서 이송(배포) 시 의견 작성 기능 추가
            		var commentYN = true;
            		var sMsg = Common.getDic("msg_apv_send_comment"); //의견을 입력하시겠습니까?
            		
            		//Common.Confirm(sMsg, "Confirmation Dialog", function(result){
            			//if(result){
            				var commentWritePopup = CFN_OpenWindow("/approval/CommentWrite.do", "", 540, 549, "resize");
            				
            				commonWritePopupOnload = function(){
            					dataInfo.context = dataInfo.context.replace("\"IsComment\":\"N\"", "\"IsComment\":\"Y\"");
            					
            					dataInfoStr = JSON.stringify(dataInfo);
            					startDistribution(dataInfoStr);
            				};
            			/*}else{
            				commentYN = false;
            				startDistribution(dataInfoStr);
            			}*/
            		//});
            	}
            	if (objArr_person.length == 0 && objArr_ou.length == 0){
            		Common.Warning(Common.getDic("msg_apv_003"));	
            	}
            //}
        //});
    }
}

function addVisibleAttributeSendPerson() {
	var apvLineObj = $.parseJSON($("#APVLIST").val());	
	var oSendPersonNode = $$(apvLineObj).find("steps>division[divisiontype='send']>step[unittype='person']>ou>person");	
	var elmNextTaskInfo = oSendPersonNode.attr("taskinfo");    
    elmNextTaskInfo["visible"] = "n";	
	$("#APVLIST").val(JSON.stringify(apvLineObj));
}

function ChangePublicAction(dataInfo){
	var seldata = $(dataInfo).val();
	if(seldata == 1){
		$("input[name=SecurityOption1]").prop("checked",false);
		$("input[name=SecurityOption1]").prop("disabled", true);
	}else { 
		$("input[name=SecurityOption1]").prop("disabled",false);
	}
}

function govDocReply(){
    var sUrl = "/approval/approval_Form.do?formID=" + getInfo("FormInfo.FormID") + "&mode=DRAFT&isgovDocReply=Y&senderInfo="+getInfo("BodyContext.sender")+"&govFormInstID="+getInfo("FormInstanceInfo.FormInstID");
    var width = "790";
	if(IsWideOpenFormCheck(getInfo("FormInfo.FormPrefix"))){
		width = "1070";
	}
	if(getInfo("Request.ReplyFlag") == "Y"){
		Common.Confirm("이미 회신한 문서입니다. 다시 회신하시겠습니까?", "Confirmation Dialog", function (result) {
			if(result){
				CFN_OpenWindow(sUrl, "", width, (window.screen.height - 100), "resize", "false");
			}else{ return; }
		});
	}else{
		CFN_OpenWindow(sUrl, "", width, (window.screen.height - 100), "resize", "false");
	}
}

function changeReadType(){
	setInfo("Request.callMode", $("#selReadType option:selected").val());
	setReadModeHWP();
}

function setReadModeHWP(){
	//뷰어처리
	// 22.09.05 HJJ 웹한글기안기로 열리도록 수정
	if(formJson.Request.isMobile != "Y") {
    /*if(getInfo("Request.callMode") == "HWP" 
    	|| getInfo("Request.govstate") == "SENDWAIT" 
    	|| (getInfo("Request.govstate") == "RECEIVEWAIT" && (CFN_GetQueryString("statusCd") == "send" || CFN_GetQueryString("statusCd") == "resend" || CFN_GetQueryString("statusCd") == "distribute") && (typeof formJson.BodyData.SubTable1 == 'undefined' || formJson.BodyData.SubTable1[0].MULTI_BODY_CONTEXT_HWP == ''))){ //[문서유통>접수대기] 최초 수신
    	*/
    	//if($("#divWebEditorContainer1").find("iframe").length <= 0) {
	        // 에디터 처리
	        LoadEditorHWP_Multi("divWebEditorContainer1", 1);
    	//}
    	
        $('#hwpPreview').hide();
        $("#divWebEditorContainer1").show();
        $("#selReadType").hide();
        
        if(getInfo("Request.govstate") == "RECEIVEWAIT" && (CFN_GetQueryString("statusCd") == "send" || CFN_GetQueryString("statusCd") == "resend" || CFN_GetQueryString("statusCd") == "distribute") && (typeof formJson.BodyData.SubTable1 == 'undefined' || formJson.BodyData.SubTable1[0].MULTI_BODY_CONTEXT_HWP == '')) {
        	var temp_id = "tbContentElement1";
        	var temp_webHwpYN = getInfo("ExtInfo.UseWebHWPEditYN");
        	
        	var strBackStorage = "https://docs.hanyang.ac.kr/GWStorage/";	//임시
//        	var strBackStorage = Common.agentFilterGetData("smart4j.path","P") + Common.getBaseConfig("BackStorage");
        	var g_BaseFormURL = strBackStorage + "e-sign/ApprovalForm/HWP/";
        	
        	try {
        		setTimeout(function(){
	    			HwpCtrl = document.getElementById(temp_id);
	                if(HwpCtrl == null && temp_webHwpYN == "Y") {
	                	HwpCtrl = document.getElementById(temp_id + 'Frame').contentWindow.HwpCtrl;
	                }
	    			
	        		HwpCtrl.Open(g_BaseFormURL + "draft_Template" + ".hwp", "HWP", "code:acp;url:true;lock:false;template:true;", function(data){
	            		if(data.result) {
	            			setHwpExternalFieldText();
	            		} else {
	            			Common.Warning("통합 HWP 변환 도중 " + coviDic.dicMap["msg_apv_030"]); //오류가 발생했습니다.
	        				return false;
	            		}
	            	});
	        	}, 3000);
        	} catch(e) {}	
        	
        }
    }else{
        //if(typeof $('#IframePreviewHwp').attr("src") == 'undefined' || typeof $('#IframePreviewHwp').attr("src") == '') {
        	var url = Common.getBaseConfig("MobileDocConverterURL") + "?fid=hwpPreview"+getInfo("FormInstanceInfo.FormInstID")+"&fileType=URL&convertType=1&filePath=" + encodeURIComponent("" + location.protocol + "//" + location.host + "/covicore/common/hwpPreviewDown.do?formInstID="+getInfo("FormInstanceInfo.FormInstID")+"&userCode=" + encodeURIComponent(Common.getSession("UR_Code"))) + "&sync=true&force=false";
        	$('#IframePreviewHwp').attr("src", url);
        //}
        
        $('#hwpPreview').show();
        $("#divWebEditorContainer1").hide();
    }
}

function setHwpExternalFieldText() {
	//setHwpInsertStampImage("logo", formJson.BodyContext.pubdocinfo.pubFLogo);
	//setHwpInsertStampImage("symbol", formJson.BodyContext.pubdocinfo.pubFSymbol);
	//setHwpInsertStampImage("sealsign", formJson.BodyContext.pubdocinfo.pubFSealSrc);
	setHwpInsertStampImage("logo", formJson.BodyContext.pubdocinfo.pubFLogo.replace("/GWStorage/",""));
	setHwpInsertStampImage("symbol", formJson.BodyContext.pubdocinfo.pubFSymbol.replace("/GWStorage/",""));
	setHwpInsertStampImage("sealsign", formJson.BodyContext.pubdocinfo.pubFSealSrc.replace("/GWStorage/",""));
	
	//1. 한글 에디터(HWP)
	//데이터
	
	//내부수신 수신자 값 셋팅
	var recData = formJson.BodyContext.pubdocinfo.pubHRcptInfRec;
	recDataLen = recData.split(",").length;
	if(recDataLen <=1){
		HwpCtrl.PutFieldText("recipient", formJson.BodyContext.pubdocinfo.pubHRcptInfRec);
		HwpCtrl.PutFieldText("recipients", " ");		
		HwpCtrl.PutFieldText("hrecipients", " ");
	}else {
		HwpCtrl.PutFieldText("hrecipients", "수신자:");
		HwpCtrl.PutFieldText("recipient", "수신자 참조");
		HwpCtrl.PutFieldText("recipients", formJson.BodyContext.pubdocinfo.pubHRcptInfRec);		
	}
	HwpCtrl.PutFieldText("headcampaign", formJson.BodyContext.pubdocinfo.pubFCmpHead);
	HwpCtrl.PutFieldText("organ", formJson.BodyContext.pubdocinfo.pubHOrgan);
	HwpCtrl.PutFieldText("route", formJson.BodyContext.pubdocinfo.pubHRcptInfVia);
	HwpCtrl.PutFieldText("doctitle", formJson.BodyContext.pubdocinfo.hTitle);
	HwpCtrl.PutFieldText("docnumber", formJson.BodyContext.pubdocinfo.pubFRegNumberValue);
	HwpCtrl.PutFieldText("enforcedate", formJson.BodyContext.pubdocinfo.pubFEnforceDate);
	HwpCtrl.PutFieldText("receiptnumber", " ");
	HwpCtrl.PutFieldText("receiptdate", " ");
	HwpCtrl.PutFieldText("zipcode", formJson.BodyContext.pubdocinfo.pubFZipCode);
	HwpCtrl.PutFieldText("address", formJson.BodyContext.pubdocinfo.pubFAddress);
	HwpCtrl.PutFieldText("homepage", formJson.BodyContext.pubdocinfo.pubFHomeUrl);
	HwpCtrl.PutFieldText("telephone", (formJson.BodyContext.pubdocinfo.pubFTel==''?' ':formJson.BodyContext.pubdocinfo.pubFTel));
	HwpCtrl.PutFieldText("fax", formJson.BodyContext.pubdocinfo.pubFFax);
	HwpCtrl.PutFieldText("email", formJson.BodyContext.pubdocinfo.pubFEmail);
	HwpCtrl.PutFieldText("publication", formJson.BodyContext.pubdocinfo.pubFPubliValue);
	HwpCtrl.PutFieldText("footcampaign", formJson.BodyContext.pubdocinfo.pubFCmpFoot);
	HwpCtrl.PutFieldText("chief", formJson.BodyContext.pubdocinfo.pubFSenderNm);
	if(typeof formJson.BodyContext.pubdocinfo.pubFAppvalInfo.approvalinfo.approval != 'undefined') {
		var pubApv = formJson.BodyContext.pubdocinfo.pubFAppvalInfo.approvalinfo.approval;
		for(var i=0; i<pubApv.length; i++) {
			HwpCtrl.PutFieldText("jikwe"+(i+1), pubApv[i].signposition);
			HwpCtrl.PutFieldText("sign"+(i+1), pubApv[i].name);
		}
	}

	//본문
	HwpCtrl.MoveToField("body", true, false, false);
	HwpCtrl.SetTextFile(formJson.BodyContext.tbContentElement.replaceAll("\r\n",""), "HTML", "insertfile", function(data){
		if(data.result) {
			updateDocHWP();
		} else {
			Common.Warning("통합 HWP 변환 도중 " + coviDic.dicMap["msg_apv_030"]); //오류가 발생했습니다.
			return false;
		}
	});

	SetHwpEditMode(HwpCtrl, "read");
	
	//2. 본문(SubTable1)
	if(XFORM.multirow.getAllRows("#SubTable1").length <= 0) {
		XFORM.multirow.addRow("#SubTable1");
	}
	
	/*HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
		var strHWP = Base64.utf8_to_b64(data);
		document.getElementsByName("MULTI_BODY_CONTEXT_HWP")[1].value = strHWP;
		formJson.BodyContext.SubTable1.MULTI_BODY_CONTEXT_HWP = strHWP;
		setInfo("BodyContext.SubTable1.MULTI_BODY_CONTEXT_HWP", strHWP);
	});*/
}

function setHwpInsertStampImage(fieldName, imagePath) {
	var hwp_BaseImgURL = Common.getBaseConfig("BackStorage");
	var hwp_HostFullName = document.location.protocol + "//" + document.location.hostname + (document.location.hostname=="localhost"?":"+document.location.port:"");
	var stamp_path = hwp_HostFullName + ((imagePath.toLowerCase().indexOf(hwp_BaseImgURL.toLowerCase()) == 0) ? imagePath : hwp_BaseImgURL + imagePath);
	
	//console.log("stamp_path : " + stamp_path);
	
	HwpCtrl.PutFieldText(fieldName, " ");
	HwpCtrl.MoveToField(fieldName, true, false, true);
	HwpCtrl.Run("Erase");
	HwpCtrl.InsertPicture(stamp_path, true, 1, false, false, 0, 17, 17, function(ctrl){console.log(ctrl ? "성공" : "실패");});
}

function updateDocHWP() {
	try {
//		var strHWP = "";
		HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
			var strHWP = Base64.utf8_to_b64(data);
			
			formJson.BodyContext.SubTable1.MULTI_BODY_CONTEXT_HWP = strHWP;
			
			var params = {
				"FormInstID" : getInfo("FormInstanceInfo.FormInstID"),
				"BodyContext": Base64.utf8_to_b64(JSON.stringify(formJson.BodyContext)),
				"MULTI_BODY_CONTEXT_HWP" : strHWP	
			};
			
			$.ajax({
				type:"POST",
				url : "/approval/govdocs/updateDocHWP.do",
				data : params,
				dataType : "json", // 데이터타입을 JSON형식으로 지정
				async:false,
				success:function(res){
					if(res.result == 'ok'){
						
					} else {
						Common.Error(res.message);
						return false;
					}	
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/govdocs/updateDocHWP.do", response, status, error);
				}
			});
		});
    } catch (e) {
        Common.Error(e.message);
    }
}



function initdoccode() {
	
	var usercode = sessionObjFormMenu.USERID;
	var deptcode = sessionObjFormMenu.DEPTID;
	
	$.ajax({
		type:"POST",
		url : "/approval/user/getdoccode.do",
		data :{ "usercode" : usercode,
			    "deptcode" : deptcode
		},
		async:false,
		success:function(res){
			if(res.list[0].RESERVED1 ==" "){
				document.getElementById("DOCCODE").value = "";	
			}else{
				document.getElementById("DOCCODE").value = res.list[0].RESERVED1;
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getdoccode.do", response, status, error);
		}
	});

}