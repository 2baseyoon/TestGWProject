//***********************************************************************************************************************************************************************************************/
//******************** 양식 파일 내 결재선 함수 정리 시작 *****************************************************************************************************************************************/

var strwidth = "79"; //테이블형 결재선 한 테이블의 넓이(초기값)
var g_commentAttachList = [];
var g_DisplayJobType = Common.getBaseConfig("ApprovalLine_DisplayJobType") || "title"; // 직책, 직급, 직위 중 결재선에 표시될 타입 설정 (직책 : title, 직급 : level, 직위 : position)

function initApvList() {
	// 연속결재에서 결재선 셋팅후 승인/반려 기 체크된 건은 해당 결재선으로 표시한다.
	if (CFN_GetQueryString("bserial") == "true") {
		var selectedItem = parent.$(".AppSelect_on", "#approvalList,#checkedList").data('item');
		if(parent.serial.isChecked(selectedItem)){
			document.getElementById("APVLIST").value = selectedItem.apvList;
			//return;
		}
	}
    //회수문서 및 임시저장 문서 재사용 시 부서코드/부서명/회사코드 최종본 반영 위해 수정 by sunny 2006.12. 양식쪽 일괄작업 어려움 공통함수 부분에서처리함
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
        try { document.getElementById("InitiatorUnitID").value = getInfo("AppInfo.dpid_apv"); } catch (e) { }
        try { document.getElementById("InitiatorUnitName").value = getInfo("AppInfo.dpdn_apv"); } catch (e) { }
        try { document.getElementById("EntCode").value = getInfo("AppInfo.etid"); } catch (e) { }
    }

    if ('' != document.getElementById("APVLIST").value) {
		// 문서내 결재선 사용
		if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
			document.querySelector('div.approver_info').style.display = '';
			addInApvLine.setInit();
		}
    	m_oApvList = $.parseJSON(XFN_ChangeOutputValue(document.getElementById("APVLIST").value));
        var ApvLines = __setInlineApvList(m_oApvList);
        drawFormApvLinesAll(ApvLines);
    }

    //관련업무 내용 추가
    try { if (parent.rel_activityid != "") { getTaskID(parent.rel_activityname + ";" + parent.rel_activityid); } } catch (e) { coviCmn.traceLog(e); }
}

/* ====================================
 * 결재선 템플릿 지원(ATS) 추가 함수
 *====================================*/
function __getTotalDataObject(){

	return {
	  "useTable": ["AppLine"],
	  "tables": {
		"AppLine": {},
		"LApvLine": [],
		"RApvLine": [],  
		"AppLineListType": [],
		"AssistLine": {},
		"AuditLine": []
	  }
	}

}

function __getLineDataObject(){
	return {
	  "displayNo" : "", //화면에 표시될 순번
	  "isInnerLine" : "N", //내부 결재선 여부
	  "apvKind" : "", //담당, 결재, 합의, 감사...   
	  "name" : "",
	  "dept" : "",
	  "title" : "",      
	  "signImage" : "", //서명 이미지경로
	  "signState" : "",
	  "date" : "",
	  "state" : "", //승인, 반려...
	  "originApprover" : "",
	  "comment": "",
	  "event" : [],
	  "code": ""
	}
}

function __getTableDataObject(tableType){
	if(tableType === 'LApvLine') {
		return {
		  "tableTitle": "신청",    
		  "lineData": [],
		  "display": "N", //결재선 영역 표시여부
		  "target": "#LApvLine",
		  "usedItem": ["title","signImage","signState","date"]
		}
	} else if(tableType === 'RApvLine') {
		return {
		  "tableTitle": "수신",    
		  "lineData": [],
		  "display": "N", //결재선 영역 표시여부
		  "target": "#RApvLine",
		  "usedItem": ["title","signImage","signState","date"]
		}
	} else if(tableType === 'AppLineListType') {
		return {
		  "tableTitle": "",    
		  "tableHeader": {
			  "displayNo" : "", //화면에 표시될 순번
			  "apvKind" : "", //담당, 결재, 합의, 감사...   
			  "name" : "",
			  "dept" : "",  
			  "state" : "", //승인, 반려...
			  "date" : "",
			  "comment" : ""
		  },      
		  "lineData": [],
		  "display": "N", //결재선 영역 표시여부
		  "target": "#AppLineListType",
		  "usedItem": ["displayNo", "apvKind",	"name", "dept", "state", "date", "comment"]
		}
	} else if(tableType === 'AssistLine') {
		return {
		  "tableTitle": "",     
		  "tableHeader": {
			"type" : "",
			"dept" : "",      
			"name" : "",
			"date" : "",
			"comment": ""
		  },           
		  "lineData": [],
		  "display": "N", //결재선 영역 표시여부
		  "target": "#AssistLine",
		  "usedItem": ["type", "dept", "name", "date", "comment"]
		}
	} else if(tableType === 'AuditLine') {
		return {
		  "tableTitle": "감사,준법",    
		  "lineData": [],
		  "display": "N", //결재선 영역 표시여부
		  "target": "#AuditAppLine,#AuditRApvLine",
		  "usedItem": ["title","signImage","signState","date"]
		}
	} else {
		return {
		  "lineData": [],
		  "tableTitle": "결재",
		  "display": "Y",
		  "target": "#AppLine",    
		  "usedItem": ["title","signImage","signState","date"]	
		}
	}
}
//@tdo          Json 테이블 객체
//@showlist     콤마 구분자의 표시 테이블, 
//@hidelist     콤마 구분자의 숨김 테이블 
/*
function __setDisplay(tdo, showlist, hidelist){
    var shows = tdo['showTable'];
    var hides = tdo['hideTable'];
    
	if(typeof showlist !== 'undefined' && showlist.trim() !== '') {
	    var arrShow = showlist.split(',');
		for(var i=0; i<arrShow.length; i++){
			__setDisplayType(shows, arrShow[i], true);
			__setDisplayType(hides, arrShow[i], false);
		}
	}

	if(typeof hidelist !== 'undefined' && hidelist.trim() !== '') {
	    var arrHide = hidelist.split(',');
		for(var j=0; j<arrHide.length; j++){
			__setDisplayType(shows, arrHide[j], false);
			__setDisplayType(hides, arrHide[j], true);
		}
	}
}*/
/*
function __setQuickDisplay(tdo, isList) {
	if(isList==='v'){
		tdo['showTable'] = ['AppLineListType'];
		tdo['hideTable'] = ['AppLine','AssistLine'];
	}else{
		tdo['showTable'] = ['AppLine', 'AssistLine'];
		tdo['hideTable'] = ['AppLineListType'];
	}
}
*/

function __getQuickDisplay(tdo) {
    
    tdo['useTable'] = []; //사용 테이블 목록 초기화
        
    if(tdo.tables.AssistLine.hasOwnProperty('lineData') && tdo.tables.AssistLine.lineData.length > 0 ) {
        tdo['useTable'].push('AssistLine');
    }else{
        delete tdo.tables.AssistLine;
    }
    
    if(tdo.tables.AppLine.hasOwnProperty('lineData') && tdo.tables.AppLine.lineData.length > 0 ) {
        tdo['useTable'].push('AppLine');
    }else{
        delete tdo.tables.AppLine;
    }
    
    if(tdo.tables.LApvLine.length > 0 ) {
        tdo['useTable'].push('LApvLine');
    }else{
        delete tdo.tables.LApvLine;
    }
    
    if(tdo.tables.RApvLine.length > 0 ) {
        tdo['useTable'].push('RApvLine');
    }else{
        delete tdo.tables.RApvLine;
    }
    
    if(tdo.tables.AppLineListType.length > 0 ) {
        tdo['useTable'].push('AppLineListType');
    }else{
        delete tdo.tables.AppLineListType;
    }

    if(tdo.tables.AuditLine.length > 0 ) {
        //tdo['useTable'].push('AuditLine'); // useTable에 넣지 않고 AppLine,RApvLine 단계에서 별도로 그려줌
    }else{
        delete tdo.tables.AuditLine;
    }
}

function __setDisplayType(arr, item, isDisplay){
    if(isDisplay){
        if(arr.indexOf(item) < 0) {
            arr.push(item);
        }
    }else{
        var i = arr.indexOf(item);
        if(i != -1) {
        	arr.splice(i, 1);
        }
    }
}

function __initApvListCols(hDisplay, fDisplay, sTableType){
	var __table = __getTableDataObject('RApvLine');
	if(sTableType) __table = __getTableDataObject(sTableType);
	var __line = __getLineDataObject();
	
	__table.tableTitle = hDisplay;
	__line.signImage = fDisplay;
	
	__table.lineData.push(__line);
	
	return __table;
}

/* ====================================
 * 결재선 템플릿 지원(ATS) 데이터 반환 함수 : 
 *====================================*/

function __setInlineApvList(oApvList, apvlist) {
    if (oApvList == null) {//IE8.0대비
        if (document.getElementById("APVLIST") == undefined) {
            oApvList = null;
            __setInlineApvList(oApvList);
            return;
        }
        else {
        	if(CFN_GetQueryString("CLSYS") == "account") {
        		if(accountCtrl.getInfo != undefined)
        			accountCtrl.getInfo("APVLIST_").val(document.getElementById("APVLIST").value);
        	}
        	
            m_oApvList = JSON.parse(document.getElementById("APVLIST").value);
            oApvList = m_oApvList;
        }
    }
    var __debug = true;
    var __apvlist;
    if (getInfo("SchemaContext.scApvLineType.value") == "2" && __debug === true) {
        try {
			if(document.getElementById("AppLineListType")){
				document.getElementById("AppLineListType").innerHTML = ""; 
			}
		} catch (e) { 
			coviCmn.traceLog(e); 
		}
        __apvlist = __displayApvList(oApvList, apvlist);
    } else {
        __apvlist = __displayApvListCols(oApvList);
        try {
            document.getElementById("AppLine").style.display = "none";
            document.getElementById("AssistLine").style.display = "none";
            document.getElementById("AppLineListType").style.display = "";
        } catch (e) {
			coviCmn.traceLog(e);
        }
    }
    
    if(location.href.indexOf("/account/") < 0) {
	    displayCCInfo($$(oApvList));
	    if (document.getElementById("RecLine") != null) { document.getElementById("RecLine").innerHTML = initRecList(); }
	    
	    if (formJson.BodyContext.RECEIVEGOV_INFO != "" && formJson.BodyContext.RECEIVEGOV_INFO != undefined) {   //대외수신처
	    	$("#DistReceiveLine").show();
	    	$("#RECEIVEGOV_INFO").text();
	    	$("#tblDistDocProperties").show();
	    }
	    
    }
    
    return __apvlist;
}

function SelectRecordinfo(){
    try {
     	$.ajax({
     		url:"govDocs/selectGovRecordDocInfo.do",
     		data: {
     			"processID": getInfo("ProcessInfo.ProcessID"),
     			"FormInstID": getInfo("FormInstanceInfo.FormInstID")
     		},
     		type:"post",
     		dataType : "json",
     		success:function (data) {
     			if(data.status == "SUCCESS" && data.list.RECORDSUBJECT != undefined){
					$("#RecordDocInfo").show();
			    	$("#recordSubject").val(data.list.RECORDSUBJECT);		
   			}
     		},
     		error:function(response, status, error){
 				CFN_ErrorAjax("selectGovRecordDocInfo.do", response, status, error);
 			}
     	});
		} catch (e) {
			Common.Error(e.message);
		}
}

//결재라인
function __displayApvList(oApvList, apvlist) {
    var $$_elmRoot, $$_elmList, $$_elmVisible;
    var noDisplay = 0;
    var appLength = 0;
    var boolDisplayAssist = true;
    var boolDisplayAudit = true;
	var __tdo= __getTotalDataObject();
	var __tdo2={};
	var apvStatus;
	
	__tdo2.useTable = [];

	oApvList = $.parseJSON(XFN_ChangeOutputValue(JSON.stringify(oApvList)));
    $$_elmRoot = $$(oApvList).find("steps");
    apvStatus = $$_elmRoot.attr("status");

	//결재선 없음
    if (!$$_elmRoot.exist()) {
		__getQuickDisplay(__tdo);
		return __tdo;
	}
  
	var division_length = $$_elmRoot.find("division").valLength();
	$$_elmRoot.find("division").concat().each(function (i, $$_element) {
		
		var __applinetable = __getTableDataObject();
		var __leftapplinetable = __getTableDataObject('LApvLine');
		var __rightapplinetable = __getTableDataObject('RApvLine');
		var __rightapplinetables = [];
		var __applinelisttype = __getTableDataObject('AppLineListType');
		var __applinelisttypes = [];
		var __assistlinetable = __getTableDataObject('AssistLine');
		

		var useRightTableOption = (getInfo("SchemaContext.scPRec.isUse") == "Y" //   우측 결재선이 있는 스키마
			|| getInfo("SchemaContext.scPRecEnt.isUse") == "Y"
			|| getInfo("SchemaContext.scPRecReg.isUse") == "Y"
			|| getInfo("SchemaContext.scDRec.isUse") == "Y"
			|| getInfo("SchemaContext.scDRecEnt.isUse") == "Y"
			|| getInfo("SchemaContext.scDRecReg.isUse") == "Y"
			|| getInfo("SchemaContext.scChgr.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrEnt.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrReg.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrOU.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrOUReg.isUse") == "Y"
			//|| getInfo("SchemaContext.scChgrPerson.isUse") == "1"
		);

		var bLeftTableLineExist = useRightTableOption; //좌측 결재선 영역 존재
		var bRightTableLineExist = useRightTableOption; //우측 결재선 영역 존재

		//$$_elmList, $$_elmVisible
		if (i == 0) {			
			$$_elmList = $$_element.find("step[routetype='approve'][name!='reference'] > ou > person,step[routetype='approve'][name!='reference']  > ou > role ");
			// Jsoner($$) 에서 find("A,B") 처럼 콤마로 조건을 넣으면, 기존 순서에 상관없이 A조건 먼저 넣고 그 뒤로 B조건을 넣으므로 순서가 변경됨 --> role이 있는경우는 루프돌며 하나씩 추가시켜서 순서 유지
			if($$_element.find("step[routetype='approve'][name!='reference']  > ou > role ").length > 0){
				let tmpList = [];
				$$_element.find("step[routetype='approve'][name!='reference'] > ou").concat().each(function(idx,$$item){
					if($$item.find("person").length > 0) tmpList = tmpList.concat($$item.find("person").jsoner());
					if($$item.find("role").length > 0) tmpList = tmpList.concat($$item.find("role").jsoner());
				});
				$$_elmList = new Jsoner(tmpList, $$_element.root);
			}
			$$_elmVisible = $$_element.find("step[routetype='approve'][name!='reference'] > ou > role:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[kind='conveyance'])");  //전달 person도 제외에 체크
		} else {
			// CP는 담당자에게 문서 도착 시, routetype 이 approve로 변경되지 않음.
			// step의 routetype 체크 로직 변경
			var sRecList = "step[routetype='receive'][name!='reference']  > ou > role,step[routetype='receive'][name!='reference']  > ou > person ";
			var sRecVisibleList = "step[routetype='receive'][name!='reference'] > ou > role:has(taskinfo[visible='n']),step[routetype='receive'][name!='reference'] > ou > person:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[kind='conveyance'])";
			
			sRecList += ", step[routetype='approve'][name!='reference']  > ou > role,step[routetype='approve'][name!='reference']  > ou > person ";
			sRecVisibleList += ", step[routetype='approve'][name!='reference'] > ou > role:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[kind='conveyance'])";
			
			$$_elmList = $$_element.find(sRecList); //(person|role)			
			$$_elmVisible = $$_element.find(sRecVisibleList);  //전달 person도 제외에 체크
			
			/*$$_elmList = $$_element.find("step[routetype='receive'][name!='reference']  > ou > role,step[routetype='receive'][name!='reference']  > ou > person "); //(person|role)
			$$_elmVisible = $$_element.find("step[routetype='receive'][name!='reference'] > ou > role:has(taskinfo[visible='n']),step[routetype='receive'][name!='reference'] > ou > person:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[kind='conveyance'])");  //전달 person도 제외에 체크
			if ($$_elmList.length == 0) {
				$$_elmList = $$_element.find("step[routetype='approve'][name!='reference']  > ou > role, step[routetype='approve'][name!='reference']  > ou > person"); //(person|role)
				$$_elmVisible = $$_element.find("step[routetype='approve'][name!='reference'] > ou > role:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[kind='conveyance'])");  //전달 person도 제외에 체크
			}*/
		}
		/* 2020.04.09 dgkim 대결 시 결재자가 5명인데 +1 되서 테이블형태가 아닌 목록형태로 나옴 수정  */
		var step_count =   $$_elmList.pack.jsoner.length; //$$_elmList.valLength();
		appLength = step_count - $$_elmVisible.valLength();
		if (i === 0 && appLength > tableLineMax) {
			__tdo2 = __displayApvListCols(oApvList);
			boolDisplayAssist = false;
			boolDisplayAudit = false;
		}
		var sOUName = "";

		//--------------------------------------------------------------------/
		//   우측(수신처) 결재선이 있는 스키마                             
		//--------------------------------------------------------------------/

		if (useRightTableOption) {
			var aOUName = [];
			
			if(apvStatus != "completed") {
				if (getInfo("SchemaContext.scChgr.isUse") == "Y" || getInfo("SchemaContext.scChgrEnt.isUse") == "Y" || getInfo("SchemaContext.scChgrReg.isUse") == "Y") {
					var sJFID = getJFID();
					if(sJFID) {
						var scChgrV = sJFID.split("^");
						for (var k = 0; k < scChgrV.length; k++) {
							aOUName.push(scChgrV[k].split("@")[1]);
						}
					}
				}
				
				if (getInfo("SchemaContext.scChgrOU.isUse") == "Y" || getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y" || getInfo("SchemaContext.scChgrOUReg.isUse") == "Y") {
					var scChgrOU = getChargeOU();
					if(scChgrOU){
						var scChgrOUV = scChgrOU.split("^");
						for (var k = 0; k < scChgrOUV.length; k++) {
							aOUName.push(scChgrOUV[k].split("@")[1]);
						}
					}
				}

				//chargeperson으로 개발 s --------------
				 if (getInfo("SchemaContext.scChgrPerson.isUse") == "Y") {
					//var scChgrPersonV = getChargePerson().split("^");
					//for (var k = 0; k < scChgrPersonV.length; k++) {
					//    aOUName.push(scChgrPersonV[k].split("@")[1]);
					//}
				}
			}

			//--------------------------------------------------------------------/
			//   수신 결재선 사용 & division 이 2개 이상                             
			//--------------------------------------------------------------------/

			if (division_length > 1) {
				//첫번째 division의 경우
				if (i == 0 && appLength <= tableLineMax) {
					if(bLeftTableLineExist){
						__leftapplinetable = __getRequestApvList($$_elmList, $$_elmVisible, "", false, Common.getDic("btn_apv_approval2"));
					} else { 
						__applinetable = __getRequestApvList($$_elmList, "", true, Common.getDic("btn_apv_approval2"));
					}
				}  else if (i > 0) { //두번째 이상 division 의 경우
					sOUName = $$_element.attr("ouname");
					try { if (sOUName == null) { sOUName = $$_element.find("step>ou").attr("name"); } } catch (e) { coviCmn.traceLog(e); }
					//담당부서/담당업무뿌려주기    		
					
					if (i == 1) {  // 2번째 division
						if (bRightTableLineExist) {
							if (step_count > 0) {
								__rightapplinetable = __getRequestApvList($$_elmList, $$_elmVisible, "", true, Common.getDic("btn_apv_managedept"), true);
							} else {
								__rightapplinetable = __initApvListCols(Common.getDic("btn_apv_managedept"), CFN_GetDicInfo(sOUName));
							}
						} else {
							__applinetable = __getRequestApvList($$_elmList, "", true, $$_element.attr("ouname"));
						}
					} else { // 3번째 이상division (i >= 2)
						if (bRightTableLineExist) {
							// n단 결재시(n개 수신부서) 기안시점에 결재방에 그려지지 않아서
							if (step_count > 0) {
								__rightapplinetable = __getRequestApvList($$_elmList, $$_elmVisible, "", true, Common.getDic("btn_apv_managedept"), true);
							} else {
								__rightapplinetable = __initApvListCols(Common.getDic("btn_apv_managedept"), CFN_GetDicInfo(sOUName));
							}
						} else {
							__applinetable = __getRequestApvList($$_elmList, "", true, CFN_GetDicInfo($$_element.attr("ouname")));
						}
					}

				   if (division_length - 1 < aOUName.length && division_length - 1 == i) {
					   if(__rightapplinetable) __rightapplinetables.push(__rightapplinetable);
						//담당부서/담당업무뿌려주기
						for (var kk = i - noDisplay; kk < aOUName.length; kk++) {                               
							__rightapplinetable =  __initApvListCols( Common.getDic("btn_apv_managedept"), CFN_GetDicInfo(aOUName[kk]) );
							__rightapplinetables.push(__rightapplinetable); //복수 우측 테이블
						}
					}
				}

			//--------------------------------------------------------------------/
			//   수신 결재선 사용 & division 이 1개                             
			//--------------------------------------------------------------------/
			} else {

				if (appLength <= tableLineMax) {
					if(bLeftTableLineExist){
						__leftapplinetable = __getRequestApvList($$_elmList, $$_elmVisible, "", false, Common.getDic("btn_apv_approval2"));
					}  else { 
						__applinetable = __getRequestApvList($$_elmList, "", true, CFN_GetDicInfo($$_element.attr("ouname")));
					}
				}

				//담당부서/담당업무뿌려주기
				for (var kk = 0; kk < aOUName.length; kk++) {
					__applinelisttype = __getTableDataObject('AppLineListType');
					
					// 허용 결재선 숫자보다 지정한 결재선이 클경우 추가
					if (appLength > tableLineMax) {                                
						__applinelisttype.tableHeader['apvKind'] = Common.getDic("lbl_apv_Approved");
						__applinelisttype.tableHeader['name'] = Common.getDic("lbl_apv_username");
						__applinelisttype.tableHeader['dept'] = Common.getDic("lbl_dept");
						__applinelisttype.tableHeader['signImage'] = Common.getDic("lbl_sign") ;
						__applinelisttype.tableHeader['date'] = Common.getDic("lbl_apv_date");
						__applinelisttype.tableHeader['state'] = Common.getDic("lbl_ApprovalState");
						__applinelisttype.tableHeader['originApprover'] = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
						__applinelisttype.usedItem = ['apvKind','name','dept','signImage','date','state','originApprover']; //표시항목
						
						var __linedata = __getLineDataObject();
						__linedata['apvKind'] = '';
						__linedata['name'] = ''; // ou name
						__linedata['dept'] = CFN_GetDicInfo(aOUName[kk]);
						__linedata['signImage'] = ''; 
						__linedata['date'] = '';
						__linedata['state'] = '';
						__linedata['originApprover'] = '';
						
						__applinelisttype.lineData.push(__linedata);
						__applinelisttypes.push(__applinelisttype);  //복수 리스트 결재선
						
					} else {                
						__rightapplinetable = __initApvListCols( Common.getDic("btn_apv_managedept"), CFN_GetDicInfo(aOUName[kk]) );
						__rightapplinetables.push(__rightapplinetable); //복수 우측 결재선
					}
				}
			}
		//--------------------------------------------------------------------/
		//   수신 결재선이 없는 스키마                             
		//--------------------------------------------------------------------/
		} else { //--------------------------------------
			if (division_length === 1) {
				if (typeof tableLineMax === 'undefined' || appLength <= tableLineMax) {
					
                    if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_HWP_MULTI") {
                    	getRequestApvListDraft_V1($$_elmList, $$_elmVisible, "", false, Common.getDic("btn_apv_approval2"));
                    }
                    
					__applinetable = __getRequestApvList($$_elmList, $$_elmVisible, "", false, Common.getDic("btn_apv_approval2"));
				}
			} else if (division_length === 2) {
				if (i == 0){
					if (appLength <= tableLineMax) {
						__leftapplinetable = __getRequestApvList($$_elmList, $$_elmVisible, "", false, Common.getDic("btn_apv_approval2"));
					}
				} else if (i == 1) {
					
                    if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_HWP_MULTI") {
                        getRequestApvListDraftRec_V1($$_elmList, $$_elmVisible, "", false, Common.getDic("btn_apv_approval2"));
                    }
                    
					// 배포일때는 결재방에 수신처로 표시되도록
					if (getInfo("SchemaContext.scIPub.isUse") == "Y" || getInfo("SchemaContext.scGRec.isUse") == "Y") {
						__rightapplinetable = __getRequestApvList($$_elmList, $$_elmVisible, "", true, Common.getDic("btn_apv_recvedept"));
					} else {
						__rightapplinetable = __getRequestApvList($$_elmList, $$_elmVisible, "", true, Common.getDic("btn_apv_managedept")); 
					}
				}
			}
		}

		if(__tdo2.useTable.indexOf('AppLineListType') > -1 ) __applinelisttype = __tdo2.tables['AppLineListType'];

		//기본 결재선
		if(__applinetable.lineData.length > 0) __tdo.tables.AppLine = __applinetable;
		//좌측 결재선
		if(__leftapplinetable.lineData.length > 0) __tdo.tables.LApvLine.push(__leftapplinetable);
		
		//우측 결재선
		if(Array.isArray(__rightapplinetables) && __rightapplinetables.length > 0){
			__tdo.tables.RApvLine = __tdo.tables.RApvLine.concat(__rightapplinetables);
		} else if(__rightapplinetable.lineData.length > 0 && __tdo.tables.AppLineListType.length == 0) { // 리스트형인 경우 rapvline 그리지 않음
			__tdo.tables.RApvLine.push(__rightapplinetable);
		}
		//리스트 타입 결재선
		if(__tdo.tables.AppLineListType.length == 0) { // 중복방지
			if(Array.isArray(__applinelisttype) && __applinelisttype.length > 0){
				__tdo.tables.AppLineListType = __tdo.tables.AppLineListType.concat(__applinelisttype);
			} else if(__applinelisttype.lineData.length > 0) { 
				__tdo.tables.AppLineListType.push(__applinelisttype);
			}
		}
	});
	
	var _approvalLine = $.parseJSON(getInfo("ApprovalLine"));
	var $$_elmComment = $$(_approvalLine).find("division > step > ou > person > taskinfo > comment, division > step > ou > role > taskinfo > comment");
	if ((bgetCommentView && $$_elmComment.length > 0 && getInfo("Request.templatemode") == "Read") || (formJson.SchemaContext.scComment != undefined && getInfo("Request.templatemode") == "Read")) {
		if (!m_print && !apvlist) getCommentView(_approvalLine);
	}
	
	if (boolDisplayAssist) {
		var __assistlinetable;
		//합의출력
		if(getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_HWP_MULTI") {
			displayAssistDraft_V1($$_elmRoot);			
		} 
		
		if(__tdo2.useTable.indexOf('AssistLine') > -1) {
			__assistlinetable = __tdo2.tables['AssistLine'];
		} else {
			__assistlinetable = __displayAssist($$_elmRoot);
		}
		__tdo.tables.AssistLine = __assistlinetable;
		
	}
	
	//감사자 출력
	if(boolDisplayAudit){
		
		var $$_elmList_audit, $$_elmList_audit_law; //개인감사, 개인준법
        var $$_elmList_audit_dept, $$_elmList_audit_law_dept; //부서감사, 부서준법
        var $$_elmVisible_audit, $$_elmVisible_audit_law;
        var $$_elmVisible_audit_dept, $$_elmVisible_audit_law_dept;
		
		$$_elmList_audit = $$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit'] > ou > person");
        $$_elmList_audit_law = $$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_law'] > ou > person");
        $$_elmList_audit_dept = $$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_dept'] > ou > person");
        $$_elmList_audit_law_dept = $$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_law_dept'] > ou > person");

        $$_elmVisible_audit = $$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit'] > ou > person:has(taskinfo[visible='n'])");
        $$_elmVisible_audit_law = $$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_law'] > ou > person:has(taskinfo[visible='n'])");
        $$_elmVisible_audit_dept = $$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_dept'] > ou > person:has(taskinfo[visible='n'])");
        $$_elmVisible_audit_law_dept = $$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_law_dept'] > ou > person:has(taskinfo[visible='n'])");
        
		//개인감사
        if ($$_elmList_audit.length > 0) {
            try { __tdo.tables.AuditLine.push(__getRequestApvList($$_elmList_audit, $$_elmVisible_audit, "", false, Common.getDic("lbl_apv_person_audit3"), false, "AuditLine")); } catch (e) { coviCmn.traceLog(e); }
        }
        //개인준법
        if ($$_elmList_audit_law.length > 0) {
            try { __tdo.tables.AuditLine.push(__getRequestApvList($$_elmList_audit_law, $$_elmVisible_audit_law, "", false, Common.getDic("lbl_apv_person_audit"), false, "AuditLine")); } catch (e) { coviCmn.traceLog(e); }
        }
        //부서감사
        if ($$_elmList_audit_dept.length > 0) {
            try { __tdo.tables.AuditLine.push(__getRequestApvList($$_elmList_audit_dept, $$_elmVisible_audit_dept, "", false, Common.getDic("lbl_apv_dept_audit3"), false, "AuditLine")); } catch (e) { coviCmn.traceLog(e); }
        }
        else {
            if ($$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_dept'] > ou").length != 0) {
				try { __tdo.tables.AuditLine.push(__initApvListCols(Common.getDic("lbl_apv_dept_audit3"), CFN_GetDicInfo($$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_dept'] > ou").attr("name")), "AuditLine")); } catch (e) { coviCmn.traceLog(e); }
            }
        }
        //부서준법
        if ($$_elmList_audit_law_dept.length > 0) {
            try { __tdo.tables.AuditLine.push(__getRequestApvList($$_elmList_audit_law_dept, $$_elmVisible_audit_law_dept, "", false, Common.getDic("lbl_apv_dept_audit"), false, "AuditLine")); } catch (e) { coviCmn.traceLog(e); }
        }
        else {
			if ($$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_law_dept'] > ou").length != 0) {
				try { __tdo.tables.AuditLine.push(__initApvListCols(Common.getDic("lbl_apv_dept_audit"), CFN_GetDicInfo($$_elmRoot.find("division").concat().eq(0).find("> step[routetype='audit'][name='audit_law_dept'] > ou").attr("name")), "AuditLine")); } catch (e) { coviCmn.traceLog(e); }
            }
        }
		
	}
	
	//참조자 출력
	//함수 외부로 이동

	__getQuickDisplay(__tdo);

	return __tdo;

}

/*수신처, 발신처 부서 결재선 표현*/
function __getRequestApvList($$_elmList, $$_elmVisible, sMode, bReceive, sApvTitle, bDisplayCharge, sTableType) {//신청서html
    var $$_elm, $$_elmTaskInfo, $$_elmReceive, $$_elmApv;
    var strDate;
    var j = 0;
    var Apvlines = "";
    var ApvPOSLines = ""; //부서명 or 발신부서,신청부서,담당부서,수신부서 등등 으로 표기<tr>
    var ApvTitleLines = "";
    var ApvSignLines = ""; //결재자 사인이미지 들어가는 부분<tr>
    var ApvApproveNameLines = ""; //결재자 성명 및 contextmenu 및 </br>붙임 후 결재일자 표기<tr>
    var ApvDateLines = ""; //사용안함
    var ApvCmt = "<tr>";
    var strColTD = $$_elmList.valLength() - ($$_elmVisible === '' ? 0 : $$_elmVisible.valLength());
    //var strwidth = String(document.getElementById("LApvLine").clientWidth / strColTD); //(document.getElementById("AppLine").clientWidth) / tableLineMax;
    var idx = 0;
    var cntDPLine = tableLineMax;
    var  LastApv,LastApvName,LastDate;

	var __tabledata = __getTableDataObject(sTableType);

    $$_elmList.concat().each(function (i, $$_elm) {

		var __linedata = __getLineDataObject();

        $$_elmTaskInfo = $$_elm.find("> taskinfo");
        if($$_elmTaskInfo.concat().length > 1) $$_elmTaskInfo = $$_elm.find(">taskinfo"); // 준법/감사 부서 ou>taskinfo person>taskinfo 존재
        
        //전달, 후열은 결재방에 제외
        if ($$_elmTaskInfo.attr("kind") != 'conveyance' && $$_elmTaskInfo.attr("kind") != 'bypass') {
            //자동결재선에 따라 부서표시 수정부분 추가
            if (i == 0) {

				if (bReceive) { //담당부서 결재선
                    if (sApvTitle != "") {
						__tabledata.tableTitle =  sApvTitle == undefined ? Common.getDic("lbl_apv_management") + "<br>" + Common.getDic("lbl_dept") : sApvTitle; 
					}
                } else {
					if (sApvTitle != "") {
						__tabledata.tableTitle =  sApvTitle == undefined ? Common.getDic("lbl_apv_request2") + "<br>" + Common.getDic("lbl_dept") : sApvTitle; 
					}
                }
            }
            if (((bDisplayCharge && i == 0) || ($$_elmTaskInfo.attr("visible") != "n")) && ($$_elmTaskInfo.attr("rejectee") != "y")) //결재선 숨기기한 사람 숨기기
            {
                var temp_charge = "";
                if ($$_elmTaskInfo.attr("kind") == 'charge') {
                    if (bReceive && $$_elmList.valLength() == 1) {
                        temp_charge = Common.getDic("lbl_apv_charge");	//"담당"
                    }
                    else {
                        temp_charge = Common.getDic("lbl_apv_charge_apvline");	//"기안"
                    }
					__linedata['title'] = temp_charge;
                }
                else {
                    var sTitle = "";
                    try {
                        /*
                        sTitle = $$_elm.attr("title"); // != undefined ? $$_elm.attr("title") : "";                        
                        if (getLngLabel(sTitle, true) == "") sTitle = $$_elm.attr("position") != undefined ? $$_elm.attr("position") : ""; 
						*/
						
						g_DisplayJobType && (sTitle = $$_elm.attr(g_DisplayJobType))
						
                        //&로 구분된 부분 ; 로 변경
                        if (sTitle && 13 > sTitle.toString().split(';').length) {
                            sTitle = getLngLabel(sTitle.toString().replace(/&/g, ';'), true);
                        }
                        else {
                            sTitle = getLngLabel(sTitle, true);
                        }
                        
                        if($$_elm.nodename() === "role"){
                        	 sTitle = Common.getDic("lbl_apv_charge");	//"담당"
                        }
                    } catch (e) {
                        /*if ($$_elm.nodeName == "role") {
                            // 개인 진행함에서 수신부서 Title이 수신부서명 끝에 2자리 밖에 나오지 않으므로 수정함..
                            sTitle = Common.getDic("lbl_apv_charge");	//"담당"
                        }*/
                        coviCmn.traceLog(e);
                    }
                    if (sTitle == Common.getDic("lbl_apv_charge_person")) {	
                        sTitle = Common.getDic("lbl_apv_charge");	//"담당"
                    }
					__linedata['title'] = sTitle;
                }

                strDate = $$_elmTaskInfo.attr("datecompleted");
                if (strDate == null && $$_elmTaskInfo.attr("result") != "reserved") {   //보류도 결재방에 표시
                    strDate = "";
                    ApvCmt += "&nbsp;";
                }
                else {
                    var $$_assistcmt = $$_elm.find("taskinfo > comment");
//                    if ($$_assistcmt.exist()) {
//                        aryComment[i] = $$_assistcmt.attr();
//                    } else {
//                        aryComment[i] = "";
//                    }

                    // 수신,발신처 있을경우의 문서 이관시 '의견' 란 링크 삭제
                    if (m_oFormMenu.m_CmtBln == false) { ApvCmt += (!$$_assistcmt.exist()) ? "&nbsp;" : Common.getDic("gLabel_comment"); }
                    /*else
                    { ApvCmt += (!$$_assistcmt.exist()) ? "&nbsp;" : "<a href=\'#\' onclick=\'viewComment(\"" + i + "\")\'>" + Common.getDic("gLabel_comment") + "</a>"; }*/
                }

                var sCode = "";
                var $$_elmtemp;
                if ($$_elm.nodename() == "role")
                    try { sCode = $$_elm.find("person").attr("code"); $$_elmtemp = $$_elm.find("person"); } catch (e) { coviCmn.traceLog(e); }
                else
                    sCode = $$_elm.attr("code");

                var $$_elmname = ($$_elmtemp) ? $$_elmtemp : $$_elm;

                var bRejected = false;
                if ($$_elmTaskInfo.attr("result") == "rejected") {
                    bRejected = true;
                }

				switch ($$_elmTaskInfo.attr("kind")) {
                    case "authorize":
                        ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) + "<br /><font size='2'>(" + Common.getDic("lbl_apv_authorize") + ")</font>" : ((bRejected) ? interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind")) : __getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, true, $$_elmTaskInfo.attr("result"), true));
                        ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name")) + " " + Common.getDic("lbl_apv_authorize");
                        ApvDateLines = (strDate == "") ? "&nbsp;" : formatDate(strDate, "H");
                        LastApv = "/";
                        LastApvName = CFN_GetDicInfo($($$_elmname).attr("name")) + interpretResult($$_elmTaskInfo.attr("result")) + "<br />";
                        LastDate = formatDate(strDate);
                        break;
                    case "substitute":
                    	//원결재자 표시가 안되서 수정
                        ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) + "<br /><font size='2'>(" + Common.getDic("lbl_apv_substitue") + ")</font>" : ((bRejected) ? interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind")) : "<font size='2'>(원) " + CFN_GetDicInfo($$_elmList.concat().eq(i+1).attr("name")) + "<br />" + CFN_GetDicInfo($$_elm.attr("name")) + "</font>");

                        ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name")) + " " + Common.getDic("lbl_apv_substitue");
                        ApvDateLines = (strDate == "") ? "&nbsp;" : formatDate(strDate, "H");
                        LastApv = "";
                        LastApvName = "";
                        LastDate = "";
                        break;
                    case "skip":
                        ApvSignLines = "/";
                        ApvApproveNameLines = "&nbsp;";
                        ApvDateLines = "&nbsp;";
                        break;
                    case "bypass":
                        ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) + "<br /><font size='2'>(" + Common.getDic("lbl_apv_bypass") + ")</font>" : __getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, true, $$_elmTaskInfo.attr("result"), true);
                        ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name")) + " " + Common.getDic("lbl_apv_bypass");
                        ApvDateLines = (strDate == "") ? "&nbsp;" : formatDate(strDate, "H");
                        break; //"후열"
                    case "review":
                        ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) + "<br /><font size='2'>(" + Common.getDic("lbl_apv_review") + ")</font>" : __getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, true, $$_elmTaskInfo.attr("result"), true);
                        ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name")) + " " + Common.getDic("lbl_apv_review");
                        ApvDateLines = (strDate == "") ? "&nbsp;" : formatDate(strDate, "H");
                        break;
                    case "charge":
                        //담당 수신자 대결 S ---------------------------------------------
                        var isDuptyCheck = false;
                        var orgIndex = -1;
                        try {
                        	if(bReceive) {
                            	if ('bypass' == $$_elmTaskInfo.parent().parent().find('taskinfo').eq(1).attr('kind')) {
                                    isDuptyCheck = true;
                                } else {
	                        		for(var i = 0; i < $$_elmList.length; i++){
	                                	if ('bypass' == $$_elmList.eq(i).find('taskinfo').attr('kind') && '원결재자' == $$_elmList.eq(i).parent().parent().attr("name")) {
	                                    	isDuptyCheck = true;
		                                    orgIndex = i;
		                                }
	    	                    	} 
	                        	}
                        	}
                        }
                        catch (e) {
                            coviCmn.traceLog(e);
                        }

                        if (isDuptyCheck) {     //대결 표시
                            //원결재자 표시가 안되서 수정
                            ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) + "<br />(" + Common.getDic("lbl_apv_substitue") + ")" : ((bRejected) ? interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind")) : "(원) " + CFN_GetDicInfo($$_elmList.concat().eq((orgIndex < 0 ? i+1 : orgIndex)).attr("name")) + "<br />" + CFN_GetDicInfo($$_elm.attr("name")));
                            ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name")) + " " + Common.getDic("lbl_apv_substitue");
                            ApvDateLines = (strDate == "") ? "&nbsp;" : formatDate(strDate, "H");
                            LastApv = "";
                            LastApvName = "";
                            LastDate = "";
                        }
                        else {  //담당 수신자 대결 E ---------------------------------------------
                        	if ($$_elmTaskInfo.attr("result") == "reserved") {
                                ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name")) + " " + interpretResult($$_elmTaskInfo.attr("result"));
                            }
                            else {
                            	ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name"));
                            }
                        	
                            ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) : ((bRejected) ? interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind")) : __getSignUrl(sCode, (($$_elmTaskInfo.attr("customattribute1") == undefined) ? "stamp" : $$_elmTaskInfo.attr("customattribute1")), $$_elm.attr("name"), strDate, true, $$_elmTaskInfo.attr("result"), true));
                            ApvDateLines = (strDate == "") ? "&nbsp;" : formatDate(strDate, "H");
                        }
                        break;
                    default:
                        ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) : ((bRejected) ? interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind")) : __getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, true, $$_elmTaskInfo.attr("result"), true));
                        ApvApproveNameLines = strDate == "" ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name")) + (bRejected ? "&nbsp;" : " " + interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind")));
                        ApvDateLines = (strDate == "") ? "&nbsp;" : formatDate(strDate, "H"); //결재방 내 공백이 조회되는 현상
                }
				__linedata['signImage'] = ApvSignLines;
				__linedata['signState'] = ApvApproveNameLines;
				__linedata['date'] = ApvDateLines;
				__linedata['comment'] = ($$_elmTaskInfo.attr("comment") =="") ? "&nbsp;" : $$_elmTaskInfo.attr("comment");
				__linedata['code'] = sCode;

                ApvPOSLines = "";
                ApvTitleLines = "";
                ApvSignLines = "";
                ApvApproveNameLines = "";
                ApvDateLines = "";
                
                //감사인 경우 최종 결재자만 보여줌
                if ($$_elm.parent().parent().attr("routetype") == "audit") {
                	__tabledata.lineData = [];
					__tabledata.lineData.push(__linedata);
                }else{
                	__tabledata.lineData.push(__linedata);
                }
                idx++;
            }
        }
    });

	return __tabledata;

}

//Section Type 결재타입 
function __displayApvListCols(oApvList) {
    if (getInfo("FormInfo.FormPrefix") != 'WF_FORM_DRAFT' && getInfo("FormInfo.FormPrefix") != 'WF_FORM_COORDINATE' && getInfo("FormInfo.FormPrefix") != 'WF_FORM_MEMO') {
        if (document.getElementById("workrequestdisplay") != undefined) {
            document.getElementById("workrequestdisplay").style.display = "none";
        }
    }
    var elmRoot, elmList, elm, elmTaskInfo, elmReceive, ApvList, emlSkip, elmCmtList; //elmListR, elmR : 다중수신부서 여부를 알기위한 nodes 변수
    var Apvlines = "";
    var strDate, strFieldName, strwidth, strColTD, LastDate;
    var rtnPOSLine, stepList, TaskInfo, writeTaskInfo, rtnConsentLine, ConsentLine;

	var $$_elmRoot, $$__elmList, $$__elm, $$__elmTaskInfo, $$__elmReceive, $$__ApvList, $$__emlSkip, $$__elmCmtList;
	$$_elmRoot = $$(oApvList);

	var __tdo = __getTotalDataObject();
	var __tabledatas = [];
	__tdo.useTable = []; //초기화

    if ($$_elmRoot.exist()) {
        //상단 결재선 그리기 Start
        //  결재선 DTD는 <division divisiontype="...."><step></step></division><division divisiontype="...."><step></step></division>로
        //  구성되어있다. 따라서 n개의 divison을 divisiontype에 따라 결재선에 표시하면 된다.
        $$_elmRoot.find("division").concat().each(function (i, $$_element) {

			var __tabledata = __getTableDataObject('AppLineListType');
			__tabledata.usedItem = ['apvKind','name','dept','state','date','comment']; //표시항목

            TaskInfo = $$_element.attr("divisiontype");
            // 리스트 타입의 경우 합의 결재선을 일반결재자와 합쳐서 표시함.
            /*if (document.getElementById("displayApvList") != null) {
                document.getElementById("displayApvList").style.display = "none";
            } else {
                __tdo.tables.AssistLine = __initApvListCols(Common.getDic("lbl_apv_tit_consent"), "/");	//m_oFormMenu.gLabel_tit_consent, "/");
            }*/

            rtnPOSLine = __getApvListCols($$_element);

			// 테이블타입 결재선과 용어도 맞지 않고 조건도 잘못되어 변경
			//writeTaskInfo ---
			/*
            if (_sc('scPRec') != 'N' || _sc('scDRec') != 'N' && _sc('scIPub') == 'N') { //신청서
                if (TaskInfo == "send") { //신청부서
                    writeTaskInfo = Common.getDic("lbl_apv_reqdept");
                } else if (TaskInfo == "receive") { //처리부서
                    writeTaskInfo = Common.getDic("btn_apv_managedept");
                }
            } else if (_sc('scPRec') == 'N' && _sc('scDRec') == 'N' && _sc('scIPub') != 'N') { //협조문
                if (TaskInfo == "send") { //발의부서
                    writeTaskInfo = Common.getDic("lbl_apv_Propdept");
                } else if (TaskInfo == "receive") { //수신부서
                    writeTaskInfo = Common.getDic("lbl_apv_Acceptdept");
                }
            } else if (_sc('scPRec') == 'N' && _sc('scDRec') == 'N' && _sc('scChgrOU') != 'N') { //담당부서
                if (TaskInfo == "send") { //발의부서
                    writeTaskInfo = Common.getDic("lbl_apv_Propdept");
                } else if (TaskInfo == "receive") { //담당부서
                    writeTaskInfo = Common.getDic("lbl_apv_ChargeDept");
                }
            } else if (_sc('scPRec') == 'N' && _sc('scDRec') == 'N' && _sc('scIPub') == 'N') { //일반결재
                writeTaskInfo = Common.getDic("lbl_apv_approver");
            }
			*/
			if (TaskInfo == "receive") { 
				// 배포일때는 결재방에 수신처로 표시되도록
				if (_sc("scIPub") == "Y" || _sc("scGRec") == "Y") writeTaskInfo = Common.getDic("btn_apv_recvedept"); // 수신처
                else writeTaskInfo = Common.getDic("btn_apv_managedept"); // 처리부서
            } else { // send
				writeTaskInfo = Common.getDic("btn_apv_approval2"); // 결재
			}
			
			__tabledata.tableTitle = writeTaskInfo; //테이블 타이틀
			__tabledata.tableHeader.displayNo = ''; //순번
			__tabledata.tableHeader.apvKind = Common.getDic("lbl_type"); //결재유형 - 담당, 결재, 합의, 감사...   
			__tabledata.tableHeader.name = Common.getDic("lbl_apv_username"); //이름
			__tabledata.tableHeader.dept = Common.getDic("lbl_dept"); //부서
			__tabledata.tableHeader.state = Common.getDic("lbl_Approved"); //결재상태 - 승인, 반려...          
			__tabledata.tableHeader.date = Common.getDic("lbl_apv_date"); //결재일시
			__tabledata.tableHeader.comment = Common.getDic("lbl_apv_comment"); //의견
			__tabledata.lineData = rtnPOSLine;

			__tabledatas.push(__tabledata);
			
        }); 
        
        //if(__tdo.tables.AssistLine.lineData.length > 0)  __tdo.useTable.push('AssistLine');

        __tdo.tables.AppLineListType = __tabledatas;
		__tdo.useTable.push('AppLineListType');

		return __tdo;

    }

	function _sc(opt){
		return getInfo("SchemaContext." + opt + ".isUse");
	}
}

//----------------------------------------------
//@param	object	결재선 division 정보
//@return	array		결재선 데이터
//----------------------------------------------
function __getApvListCols($$_oDivision) {

    var $$_elmStep, $$_ous, $$_personsOrRoles, $$_elm, $$_personOrRole, $$_elmTaskInfo, elmListR, elmR; // 2006.01.16 elmListR, elmR : 다중수신부서 여부를 알기위한 nodes 변수
    var strDate, strFieldName, strwidth, strColTD, LastApv,LastApvName,LastDate='';

    var Apvlines = "", 
		 ApvPOSLines = "",
         Apvdecide = "", 				//대결,후열 등을 표시
         ApvState = "",
         ApvSignLines = "",
         ApvSign = "",
         ApvDept = "",
         ApvApproveNameLines = "",
         ApvDateLines = "",
         ApvCmt = "",
         Cmts = "",
         sTitle = "",
         elmAudit,
         OriginApprover = "",
         nextelm,
         cnt = 1,
         ApvVisible,
         __linedatas = [];

    // 지정한 순서대로 표시되지 않아 수정
    //var $$_steps = $$_oDivision.find("step[routetype='approve'],step[routetype='assist'],step[routetype='receive'],step[routetype='consult'],step[routetype='audit']").concat();
    var $$_steps = $$_oDivision.find("step").concat();

    for (var iStep = 0; iStep < $$_steps.length; iStep++) {
        ApvSignLines = "&nbsp;";      //결재자 이름
        ApvCmt = "&nbsp;";            //사용자 코멘트 
        OriginApprover = "&nbsp;";    //원결재자
        sTitle = "&nbsp;";            //직책
        sCode = "";           //사용자 아이디

        var $$_step = $$_steps.eq(iStep);
        if (!$$_step.exist())  break;  // 더이상 노드가 없으면 빠져나감

        $$_ous = $$_step.find("ou").concat();    //부서가져오기
        if ($$_step.attr("unittype") == "ou") {
            ApvSignLines = "&nbsp;";      //결재자 이름
            ApvSign = "&nbsp;"			  //결재자 서명 이미지
            ApvCmt = "&nbsp;";            //사용자 코멘트 
            OriginApprover = "&nbsp;";    //원결재자
            sTitle = "&nbsp;";            //직책
            sCode = "";           		  //사용자 아이디

            //부서일 경우 for문 시작
            for (var iOu = 0; iOu < $$_ous.length; iOu++) {
            	var __linedata = __getLineDataObject();
            	
                var $$_stepou = $$_ous.eq(iOu);
                if (!$$_stepou.exist()) break;  // 더이상 노드가 없으면 빠져나감
                
                $$_elmTaskInfo = $$_stepou.find("person > taskinfo");
                if($$_elmTaskInfo.length == 0) { //아직 부서 내 기안이 진행되지 않았을 경우
                	$$_elmTaskInfo = $$_stepou.find("> taskinfo");
                	//ApvSignLines = sessionObjFormMenu.USERNAME;
                }
                else if($$_elmTaskInfo.length > 1) { //현재 결재할 사용자
                	$$_elmTaskInfo = $$_stepou.find("person > taskinfo[status='pending']"); 
                	if($$_elmTaskInfo.length == 0) { //부서협조 완료
                		$$_elmTaskInfo = $$_stepou.find("person > taskinfo[status='completed']"); 
                		$$_elmTaskInfo = $$_elmTaskInfo.eq($$_elmTaskInfo.length-1);
                		sCode = $$_elmTaskInfo.parent().attr('code');
                	}
                }
                
                if ($$_elmTaskInfo.attr("visible") == "n") continue;
                
                
				//-- strDate
                strDate = $$_elmTaskInfo.attr("datecompleted");
                
                if (strDate == null && $$_elmTaskInfo.attr("result") != "reserved") {
                    strDate = ""; 
					ApvCmt = "";
                }

				//-- Apvdecide
                if ($$_stepou.parent().attr("routetype") == "consult" && $$_stepou.parent().attr("allottype") == "serial") { Apvdecide = Common.getDic("lbl_apv_DeptConsent"); }	//"부서합의"
                else if ($$_stepou.parent().attr("routetype") == "consult" && $$_stepou.parent().attr("allottype") == "parallel") { Apvdecide = Common.getDic("lbl_apv_DeptConsent_2"); }	//"부서합의(병렬)"
                else if ($$_stepou.parent().attr("routetype") == "assist" && $$_stepou.parent().attr("allottype") == "serial") { Apvdecide = Common.getDic("lbl_apv_DeptAssist"); }	//"부서협조"
                else if ($$_stepou.parent().attr("routetype") == "assist" && $$_stepou.parent().attr("allottype") == "parallel") { Apvdecide = Common.getDic("lbl_apv_DeptAssist2"); }	//"부서협조(병렬)"                
                else if ($$_stepou.parent().attr("routetype") == "audit") { 
					if($$_stepou.parent().attr("name") == "audit_dept") Apvdecide = Common.getDic("lbl_apv_dept_audit3"); //부서감사;
					else Apvdecide = Common.getDic("lbl_apv_dept_audit"); //부서준법;
				}
                else if ($$_stepou.parent().attr("name") == "ExtType") { Apvdecide = Common.getDic("lbl_apv_ExtType"); }	//"심의" -> 특이기능
               
			   //-- ApvSignLines ~ ApvVisible
                ApvSignLines = ApvSignLines == "&nbsp;" ? CFN_GetDicInfo($$_elmTaskInfo.parent().attr("name")) : ApvSignLines;
                ApvSign += (strDate == "") ? "" : getSign(sCode, $$_elmTaskInfo.attr("customattribute1"), ApvSignLines, strDate, true, $$_elmTaskInfo.attr("result"), true, "list");
                ApvState = interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind"));
                ApvDept = (ApvSignLines == CFN_GetDicInfo($$_stepou.attr("name")) ? "" : CFN_GetDicInfo($$_stepou.attr("name")));
                ApvDateLines = "";
                ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
                ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				ApvVisible = ( strDate == "" && $$_elmTaskInfo.attr("datereceived") != "" ) ? "T" : "F";
				
				__linedata['apvKind'] = Apvdecide;
				__linedata['displayNo'] = cnt;
				__linedata['name'] = ApvSignLines; // person name
				__linedata['dept'] = ApvDept ; // ou name
				__linedata['signImage'] = ApvSign; 
				__linedata['title'] = sTitle;
				__linedata['decide'] = Apvdecide;
				__linedata['date'] = ApvDateLines;
				__linedata['state'] = ApvState;
				__linedata['code'] = sCode;
				__linedata['originApprover'] = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
				if($$_stepou.find("person").concat().length > 1) { // 다수인 경우
					__linedata['innerApvList'] = __getInnerApvListCols($$_stepou, ApvVisible, cnt);
				}else {
					__linedata['innerApvList'] = "";
				}

				//의견
				__linedata['comment'] = (ApvCmt == "" || ApvCmt == "&nbsp;")  ? '' : ApvCmt;
				__linedata['event'].push({
					"tdIdx" : 1, //이벤트를 발생시킬 <td> 태그의 인덱스: 0부터 시작
					"type" : "onclick", //바인드할 이벤트(html에 삽입될 형태로 구문작성)
					"action" : "deptdisplayApv(\"INDEPT" + cnt + "\")" // 이벤트에 연결할 함수
				});

				__linedatas.splice(0, 0, __linedata); //신규 항목을 맨 앞에 위치-jwk
				cnt++;

            }
        } else if ($$_step.attr("unittype") == "person" || $$_step.attr("unittype") == "role") {
        	//unittype이 개인 혹은 role(부서장결재)
            $$_personsOrRoles = $$_step.find("ou > person,role").concat();
            
            for (var i = 0; i < $$_personsOrRoles.length; i++) {
                ApvSignLines = "&nbsp;";      //결재자 이름
                ApvCmt = "&nbsp;";            //사용자 코멘트 
                OriginApprover = "&nbsp;";    //원결재자
                sTitle = "&nbsp;";            //직책
                var sCode = "";           	  //사용자 아이디

                $$_personOrRole = $$_personsOrRoles.eq(i);
                if (!$$_personOrRole.exist()) break;  // 더이상 노드가 없으면 빠져나감

                var $$_personOrRoleTaskinfo = $$_personOrRole.find(">taskinfo");
				var __linedata = __getLineDataObject();

				var bMakeColList = ($$_personOrRoleTaskinfo.attr("kind") != 'conveyance' && $$_personOrRoleTaskinfo.attr("kind") != 'bypass' && $$_personOrRoleTaskinfo.attr("visible") != "n" && $$_personOrRoleTaskinfo.attr("kind") != 'skip');
				if (!bMakeColList) continue;

				//-- sTitle
				try {
					g_DisplayJobType && (sTitle = $$_personOrRole.attr(g_DisplayJobType))
					sTitle = getLngLabel(sTitle, true);
				} catch (e) {
					if ($$_personOrRole.nodename() == "role") {
						sTitle = CFN_GetDicInfo($$_personOrRole.attr("name"));
					}
				}
				
				//-- strDate, ApvCmt
				strDate = $$_personOrRoleTaskinfo.attr("datecompleted");
				if (strDate == null && $$_personOrRoleTaskinfo.attr("result") != "reserved") {
					strDate = "";
					ApvCmt = "";
				} else {
					var $$_assistcmt = $$_personOrRole.find("taskinfo > comment");
					if ($$_assistcmt.exist()) {
						ApvCmt = $$_assistcmt.text().replace(/\n/g, "<br>");
					}
				}

				Apvdecide = Common.getDic("lbl_apv_normalapprove");	// "결 재"
				//-- sCode
				if ($$_personOrRole.nodename() == "role")
					try { sCode = $$_personOrRole.find("person").attr("code"); } catch (e) { coviCmn.traceLog(e); }
				else
					sCode = $$_personOrRole.attr("code");

				//-- ApvKind
				var ApvKind = interpretKind($$_personOrRoleTaskinfo.attr("kind"), $$_personOrRoleTaskinfo.attr("result"), $$_step.attr("routetype"), $$_step.attr("allottype"), $$_step.attr("name"));

//--- switch 문 수정 : 시작
				var __linesByKind = getLinesByKind($$_personOrRoleTaskinfo, $$_personOrRole, sCode, strDate, LastDate);
				ApvSignLines	= __linesByKind.ApvSignLines;
				ApvState		= __linesByKind.ApvState;
				ApvDept			= __linesByKind.ApvDept;
				ApvSign			= __linesByKind.ApvSign;
				ApvDateLines	= __linesByKind.ApvDateLines;
				ApvApproveNameLines = __linesByKind.ApvApproveNameLines;
				LastApv			= __linesByKind.LastApv;
				LastApvName	= __linesByKind.LastApvName;
				LastDate			= __linesByKind.LastDate;
//--- switch 문 수정 : 완료
				if (ApvCmt == '' || ApvCmt == '&nbsp;') {
					__linedata['comment'] = '&nbsp;';
				} else {
					__linedata['comment'] = '<a><img onclick ="viewComment()" src="/HtmlSite/smarts4j_n/approval/resources/images/Approval/ico_comment.gif" alt="Comment" border="0" /></a>';
				}

				//-- __linedata{}
				__linedata['apvKind'] = ApvKind;	
				__linedata['displayNo'] = '';
				__linedata['name'] = ApvSignLines; // person name
				__linedata['dept'] = ApvDept;
				__linedata['signImage'] = ApvSign;
				__linedata['signState'] = '';
				__linedata['title'] = sTitle;
				__linedata['decide'] = Apvdecide;
				__linedata['date'] = ApvDateLines;
				__linedata['state'] = ApvState;
				__linedata['originApprover'] = OriginApprover;
				__linedata['innerApvList'] = getInnerApvListCols($$_personOrRole, ApvVisible, cnt);
				__linedata['code'] = sCode;

				__linedatas.splice(0, 0, __linedata); //신규 항목을 맨 앞에 위치-jwk

				cnt++;

            } //persons_or_roles 루프 종료

        } //unitype=person 분기 종료
    }

    return __linedatas; // array
	
	//결재유형별 결재정보 생성
	function getLinesByKind($$_personOrRoleTaskinfo, $$_personOrRole, sCode, strDate, LastDate){
		var ApvSignLines=ApvState=ApvDept=ApvSign=ApvDateLines=ApvApproveNameLines=LastApv=LastApvName='';
		var ApvKind;
		switch ($$_personOrRoleTaskinfo.attr("kind")) {
			case "authorize":
				ApvSignLines += CFN_GetDicInfo($$_personOrRole.attr("name"));
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSign(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				LastApv = "/";
				LastApvName = CFN_GetDicInfo($$_personOrRole.attr("name")) + interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				LastDate = formatDate(strDate, "APV");
				//ApvKind = "전결";
				break;
			case "substitute"://대결
				ApvSignLines += CFN_GetDicInfo($$_personOrRole.attr("name")) + "<br />(" + Common.getDic("lbl_apv_substitue") + ")";
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSign(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				LastApv = getSign(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), false);
				LastApvName = CFN_GetDicInfo($$_personOrRole.attr("name")) + interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				LastDate = formatDate(strDate, "APV");
				ApvKind = interpretKind("normal", $$_personOrRoleTaskinfo.attr("result"), $$_personOrRole.parent().parent().attr("routetype"), $$_personOrRole.parent().parent().attr("allottype"), $$_personOrRole.parent().parent().attr("name"));
				break;
			case "skip":
				ApvSignLines += "/";
				ApvDept = getAttribute("/");
				ApvSign = "&nbsp;";
				ApvDateLines = "";
				ApvDateLines += "&nbsp;";
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				break;
			case "bypass":
				ApvSignLines += CFN_GetDicInfo($$_personOrRole.attr("name"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSign(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDateLines = "";
				ApvDateLines += (LastDate == "") ? Common.getDic("lbl_apv_bypass") : LastDate; //m_oFormMenu.gLabel_bypass : LastDate; //"후열"
				ApvApproveNameLines += (LastApvName == "") ? Common.getDic("lbl_apv_bypass") : LastApvName; //m_oFormMenu.gLabel_bypass : LastApvName; //"후열"
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				break; //"후열"
			case "review":
			case "charge":
			case "consent":
				ApvSignLines += CFN_GetDicInfo($$_personOrRole.attr("name"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSign(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				break;
			default:
				ApvSignLines += (strDate == "") ? CFN_GetDicInfo($$_personOrRole.attr("name")) : getSign(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), false);
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSign(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
		}

		return {
			ApvSignLines: ApvSignLines,
			ApvState: ApvState,
			ApvDept: ApvDept,
			ApvSign: ApvSign,
			ApvDateLines: ApvDateLines,
			ApvApproveNameLines: ApvApproveNameLines,
			LastApv: LastApv,
			LastApvName: LastApvName,
			LastDate: LastDate
		}

	}

}

// 가로 내부 결재선
function __getInnerApvListCols($$_oApvStepList, DeptState, parentCnt) {
    var elmRoot, elmStep, $$_elmList, $$_elm, $$_elmTaskInfo, elmReceive, ApvList, emlSkip, elmCmtList, elmListR, elmR; // 2006.01.16 elmListR, elmR : 다중수신부서 여부를 알기위한 nodes 변수
    var Apvlines = "";
    var strDate, strFieldName, strwidth, strColTD, LastDate;
    //$$_elmList = $$_oApvStepList.find("step[unittype='person'] > ou > person,step[unittype='role'] > ou > person,step[unittype='person'] > ou > person,step[unittype='role'] > ou > role ").concat();
    $$_elmList = $$_oApvStepList.find("person").concat();

    var ApvPOSLines = "";
    var Apvdecide = ""; 				//대결,후열 등을 표시
    var ApvState = "";
    var ApvSignLines = "";
    var ApvSign = "";
    var ApvDept = "";
    var ApvApproveNameLines = "";
    var ApvDateLines = "";
    var ApvCmt = "";
    var Cmts = "";
    var sTitle = "";
    var elmAudit;
    var OriginApprover = "";
    var nextelm;
    var cnt = 1;
    var sCode = "";
	var __linedatas = [];
	var  ApvKind = "",LastApv="",LastApvName="";

    // 사람일 경우 for 문 시작	
    $$_elmList.each(function (i, $$_elm) {
	    var __linedata = __getLineDataObject();
	
        ApvSignLines = "&nbsp;";      //결재자 이름
        ApvSign = "&nbsp;"			  //결재자 서명 이미지
        ApvCmt = "&nbsp;";            //사용자 코멘트 
        OriginApprover = "&nbsp;";    //원결재자
        sTitle = "&nbsp;";            //직책
        sCode = "";           //사용자 아이디
        ApvKind = "";

        $$_elmTaskInfo = $$_elm.find(">taskinfo");

        if ($$_elmTaskInfo.attr("visible") == "n" || $$_elmTaskInfo.attr("kind") == 'skip') {
			return; //건너 뜀
        }

		try {
			g_DisplayJobType && (sTitle = $$_elm.attr(g_DisplayJobType))
			sTitle = getLngLabel(sTitle, true);
		} catch (e) {
			if ($$_elm.nodeName == "role") {
				sTitle = CFN_GetDicInfo($$_elm.attr("name"));
			}
		}
		
		strDate = $$_elmTaskInfo.attr("datecompleted");
		if (strDate == null && $$_elmTaskInfo.attr("result") != "reserved") {
			strDate = "";
			ApvCmt = "";
		} else {
			var $$_assistcmt = $$_elm.find("taskinfo > comment");
			if ($$_assistcmt.exist()) {
				ApvCmt = $$_assistcmt.text().replace(/\n/g, "<br>");
			}
		}

		Apvdecide = Common.getDic("lbl_apv_normalapprove");		// "결 재"
		if ($$_elm.tagName == "role")
			try { sCode = $$_elm.find("person").attr("code"); } catch (e) { coviCmn.traceLog(e); }
		else
			sCode = $$_elm.attr("code");

		ApvKind = interpretKind($$_elmTaskInfo.attr("kind"), $$_elmTaskInfo.attr("result"), "", "", Common.getDic("lbl_apv_normalapprove"));

		switch ($$_elmTaskInfo.attr("kind")) {
			case "authorize":
				// "전 결";
				ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
				ApvState = interpretResult($$_elmTaskInfo.attr("result"));
				ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				LastApv = "/";
				LastApvName = CFN_GetDicInfo($$_elm.attr("name")) + interpretResult($$_elmTaskInfo.attr("result"));
				LastDate = formatDate(strDate);
				//ApvKind = "전결";
				break;
			case "substitute":
				//"대 결";
				ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
				ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
				ApvState = interpretResult($$_elmTaskInfo.attr("result"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				LastApv = getSign(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, false, $$_elmTaskInfo.attr("result"), false);
				LastApvName = CFN_GetDicInfo($$_elm.attr("name")) + interpretResult($$_elmTaskInfo.attr("result"));
				LastDate = formatDate(strDate);
				//원결재자 가져오기
				//				            nextelm  = $$_elmList.nextNode();
				//				            OriginApprover = CFN_GetDicInfo(nextelm.getAttribute("name"));
				//ApvKind = "대결";
				break;
			case "skip":
				ApvSignLines += "/";
				ApvDept = getAttribute("/");
				ApvDateLines = "";
				ApvDateLines += "&nbsp;";
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				//ApvKind = $$_elmTaskInfo.getAttribute("kind");
				break;
			case "bypass":
				//"후 열"
				//후열자 이름 넣어주기
				ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
				ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
				ApvState = interpretResult($$_elmTaskInfo.attr("result"));
				ApvDateLines = "";
				ApvDateLines += (LastDate == "") ? m_oFormMenu.gLabel_bypass : LastDate; //"후열"
				ApvApproveNameLines += (LastApvName == "") ? m_oFormMenu.gLabel_bypass : LastApvName; //"후열"
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				//ApvKind = "후열";
				break; //"후열"
			case "review":
				//"후 결"
				ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
				ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
				ApvState = interpretResult($$_elmTaskInfo.attr("result"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				//ApvKind = "후결";						
				break;
			/*case "charge":
				//기안자 //"결 재"
				ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
				ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
				ApvState = interpretResult($$_elmTaskInfo.attr("result"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				//ApvKind = "담당";
				break;*/
			case "consent":
				//Apvdecide = "참조"; 
				ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
				ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
				ApvState = interpretResult($$_elmTaskInfo.attr("result"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				break;
			default:
				ApvSignLines = ApvSignLines == "&nbsp;" ? CFN_GetDicInfo($$_elm.attr("name")) : ApvSignLines;
				ApvSign += (strDate == "") ? "" : getSign(sCode, $$_elmTaskInfo.attr("customattribute1"), ApvSignLines, strDate, true, $$_elmTaskInfo.attr("result"), true, "list");
				ApvState = interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind"));
				ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
				ApvDateLines = "";
                ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				//ApvKind = interpretResult($$_elmTaskInfo.getAttribute("result"));
		}

		__linedata['apvKind'] = ApvKind;	
		__linedata['displayNo'] = parentCnt + "-" + cnt;
		__linedata['name'] = ApvSignLines; // person name
		__linedata['dept'] = ApvDept;
		__linedata['signImage'] = ApvSign;
		__linedata['signState'] = "";
		__linedata['title'] = sTitle;
		//__linedata['decide'] = Apvdecide; //사용안하는 것으로 보임
		__linedata['date'] = ApvDateLines;
		__linedata['state'] = ApvState;
		__linedata['originApprover'] = OriginApprover;
		__linedata['displayLine'] = DeptState == "T" ? 'Y': 'N'; //**** 신규 추가항목
		__linedata['code'] = sCode;

		//의견
		//__linedata['comment'] = (ApvCmt == "" || ApvCmt == "&nbsp;")  ? '' : ApvCmt;
		if (ApvCmt == '' || ApvCmt == '&nbsp;') {
			__linedata['comment'] = '&nbsp;';
		} else {
			__linedata['comment'] = '<a><img onclick ="viewComment()" src="/HtmlSite/smarts4j_n/approval/resources/images/Approval/ico_comment.gif" alt="Comment" border="0" /></a>';
		}
		__linedata['event'].push({
			"tdIdx" : 1, //이벤트를 발생시킬 <td> 태그의 인덱스: 0부터 시작
			"type" : "onclick", //바인드할 이벤트(html에 삽입될 형태로 구문작성)
			"action" : "deptdisplayApv(\"INDEPT" + cnt + "\")" // 이벤트에 연결할 함수
		});

		__linedatas.splice(0, 0, __linedata); //신규 항목을 맨 앞에 위치-jwk

    });
    //사람일 경우 for문 끝

    return __linedatas;
}

////합의출력
function __displayAssist($$_elmRoot) {
    var strDate, __lastTitle, __lastCmt, __lastResult;
	var __tabledata = __getTableDataObject('AssistLine');
	
	var $$_elmList = $$_elmRoot.find("division").concat().find("> step[routetype='consult'] > ou, > step[routetype='assist'] > ou").concat();		

	//데이터 없으면 종료
    if ($$_elmList.length === 0) {
		__tabledata.lineData = [];
		__tabledata.display = 'N';
		return __tabledata;
	}

	__tabledata.tableHeader.type = Common.getDic("lbl_apv_apvType"); //1번째 컬럼
	__tabledata.tableHeader.dept = Common.getDic("lbl_dept"); //2번째 컬럼
	__tabledata.tableHeader.name = Common.getDic("lbl_apv_username"); //3번째 컬럼
	__tabledata.tableHeader.date = Common.getDic("lbl_apv_approvdate"); //4번째 컬럼
	__tabledata.tableHeader.comment = Common.getDic("lbl_apv_comment"); //5번째 컬럼

	$$_elmList.each(function (index, $$_ou) {
		if ($$_ou.parent().attr("unittype") == "person") {
			$$_ou.find("person").concat().each(function (index, $$_person) {
				// 전달의 경우 화면 표시하지 않음
				if ($$_person.find(">taskinfo").attr("kind") == 'conveyance') {
					return false;
				}
				var sCode,sTitle; 
				
				if ($$_person.nodename() == "role") {
					try { sCode = $$_person.find("person").attr("code"); } catch (e) { coviCmn.traceLog(e); }
					try { sTitle = CFN_GetDicInfo($$_person.attr("name")); } catch (e) { coviCmn.traceLog(e); }
				} else {
					sCode = $$_person.attr("code");
					sTitle = CFN_GetDicInfo($$_person.attr("name"));
					g_DisplayJobType && (sTitle += " " + getLngLabel($$_person.attr(g_DisplayJobType), true));
				}

				var $$_personTaskinfo = $$_person.find(">taskinfo");
				var __personlinedata = __getLineDataObject();

				if ($$_personTaskinfo.attr("visible") != "n") {
					strDate = $$_personTaskinfo.attr("datecompleted");
					if (strDate == null) { strDate = ""; }
					var $$_assistcmt = $$_person.find("> taskinfo > comment"); //문서창 상단에서 협조자의 의견이 잘리지 않도록 수정함.
					
					var $$_step = $$_person.parent().parent();
					var dicName = "btn_apv_consultors"; //개인합의
					if($$_step.attr("routetype") == "assist") { dicName = "lbl_apv_assist"; } //개인협조
					if($$_step.attr("allottype") == "parallel") { dicName += "_2"; } //(병렬)			
					__personlinedata.type = Common.getDic(dicName);
					var sOUName = "";

					switch ($$_personTaskinfo.attr("kind")) {
						/*기존 소스에서 $(elmTaskInfo).kind 접근하므로, 무조건 undefined 값이 넘어오는 것으로 추측 = > X */
					case "substitute":
						__lastTitle = CFN_GetDicInfo($$_person.attr("name"));
						__lastCmt = ($$_assistcmt.text() == null) ? "&nbsp;" : $$_assistcmt.text().replace(/\n/g, "<br />");
						__lastResult = strDate == "" ? "&nbsp;" : formatDate(strDate) + " " + interpretResult($$_personTaskinfo.attr("result"));
						break;
					case "bypass":
						if ($$_person.attr("ouname") != null) {
							sOUName = CFN_GetDicInfo($$_person.attr("ouname"));
						}
						__personlinedata.dept = sOUName;
						__personlinedata.name = sTitle + "<br>(" + Common.getDic("lbl_apv_substitue") + ")" + __lastTitle + "</td>";
						__personlinedata.date = __lastResult;
						__personlinedata.comment = __lastCmt;
						__personlinedata.code = sCode == "" ? "&nbsp;" : sCode;
						
						__tabledata.lineData.push(__personlinedata);
						break; //"후열"
					default:
						if ($$_person.attr("ouname") != null) {
							sOUName = CFN_GetDicInfo($$_person.attr("ouname"));
						}
						__personlinedata.dept = sOUName;
						__personlinedata.name = sTitle;
						__personlinedata.date = strDate == "" && $$_personTaskinfo.attr("result") != "reserved" ? "&nbsp;" : formatDate(strDate) + " " + interpretResult($$_personTaskinfo.attr("result"));
						//__personlinedata.comment = $$_assistcmt.text() == null ? "&nbsp;" : $$_assistcmt.text().replace(/\n/g, "<br />");
						__personlinedata.comment = ($$_assistcmt.text() == null ? "&nbsp;" : Base64.utf8_to_b64(Base64.b64_to_utf8($$_assistcmt.text()).replace(/\n/g, "<br />")));
						__personlinedata.code = sCode == "" ? "&nbsp;" : sCode;

						__tabledata.lineData.push(__personlinedata);
						break;
					}
				}
			});
		} else {
			var __oulinedata = __getLineDataObject();

			//부서합의/협조 결재방표시 전체 수정 - 부서만 display , 부서 내 결재자 display

			/* ======================== 부서합의 부서만 보여주기 s ======================== */
			//$$_elmTaskInfo = $$_element.find("taskinfo");
			//var consultStatus = $$_elmTaskInfo.attr("status");
			//if ($$_elmTaskInfo.attr("visible") != "n") {
			//    strDate = $$_elmTaskInfo.attr("datecompleted");
			//    if (strDate == null) { strDate = ""; }

			//    var assistcmt = "";
			//    $$_element.find("person").each(function (p, person) {
			//        if ($$_person.find("taskinfo > comment").text() != null) {
			//            if ($$_person.find("taskinfo > comment").text() != "") {
			//                assistcmt += "<tr><td style='width:55px;border:0px solid #ffffff;'>[" + $$_person.attr("name").split(';')[0] + "]</td><td style='border:0px solid #ffffff;'>" + $$_person.find("taskinfo > comment").text() + "</td></tr>";
			//            }
			//        }
			//    });

			//    if (assistcmt != "") {
			//        assistcmt = "<table cellspacing='0' cellpadding='0' style='width:98%;border:0px solid #ffffff'>" + assistcmt + "</table>";
			//    }

			//    Apvlines += "<tr>";
			//    Apvlines += "<td>" + CFN_GetDicInfo($$_element.attr("name")) + "</td>";
			//    Apvlines += "<td>" + "" + "</td>";

			//    if (consultStatus == "pending") {
			//        Apvlines += "<td>결재 진행 중</td>";
			//    }
			//    else {
			//        Apvlines += "<td>" + ((strDate == "") ? "&nbsp;" : formatDate(strDate) + " " + interpretResult($$_elmTaskInfo.attr("result"))) + "</td>";
			//    }

			//    Apvlines += "<td>" + ((assistcmt == "") ? "&nbsp;" : assistcmt.replace(/\n/g, "<br />")) + "</td>";
			//    Apvlines += "</tr>";
			//}
			/* ======================== 부서합의 부서만 보여주기 e ======================== */

			/* ======================== 부서합의 결재자 모두보여주기 s ======================== */

			var __inner_apvlist = [];
			if ($$_ou.find(">taskinfo").eq(0).attr("visible") != "n") {
				__oulinedata.dept = CFN_GetDicInfo($$_ou.attr("name"));
				__oulinedata.name = __oulinedata.date = __oulinedata.comment = '&nbsp;';
				
				var $$_step = $$_ou.parent();
				var dicName = "lbl_apv_DeptConsent"; //부서합의
				if($$_step.attr("routetype") == "assist") { dicName = "lbl_apv_DeptAssist"; } //부서협조
				if($$_step.attr("allottype") == "parallel") { dicName += "_2"; } //(병렬)			
				__oulinedata.type = Common.getDic(dicName);
				
				var person_substitute = "";
				$$_ou.find("person").has(">taskinfo[visible!='n']").concat().each(function (p, $$_person) {
					var __sub_personlinedata = __getLineDataObject();

					strDate = $$_person.find(">taskinfo").attr("datecompleted");
					if (strDate == null) { strDate = ""; }

					if ($$_person.find(">taskinfo").attr("kind") == "substitute") {
						 person_substitute = CFN_GetDicInfo($$_person.attr("name")) + (g_DisplayJobType && (" " + getLngLabel($$_person.attr(g_DisplayJobType), true))) + "<b>(" + Common.getDic("lbl_apv_substitue") + ")</b><br/>";
	                     return;
					}
					
					if ($$_person.find(">taskinfo").attr("kind") == "review") {    // [2015-12-10] gypark 부서합의 후결일 경우
						__sub_personlinedata.name = CFN_GetDicInfo($$_person.attr("name")) + "&nbsp;<b>(후결)<b>" ;
					} else {
						if (person_substitute != "") {
							__sub_personlinedata.name += person_substitute;
	                        person_substitute = "";
	                    }
						__sub_personlinedata.name += CFN_GetDicInfo($$_person.attr("name")) ;
					}
					
					if ($$_person.find(">taskinfo").attr("kind") == "bypass") {
						var status = $$_person.find(">taskinfo").attr("status");
						__sub_personlinedata.date = strDate == "" ? "&nbsp;" : formatDate(strDate) + " " + interpretResult(status, $$_person.closest("step").attr("routetype"));
					}else{
						__sub_personlinedata.date = strDate == "" ? "&nbsp;" : formatDate(strDate) + " " + interpretResult($$_person.find(">taskinfo").attr("result"), $$_person.closest("step").attr("routetype"));
					}
					
					__sub_personlinedata.code = $$_person.attr("code") == "" ? "&nbsp;" : $$_person.attr("code");

					if ($$_person.find("taskinfo > comment").text() != null && $$_person.find("taskinfo > comment").text() != "") {
						//__sub_personlinedata.comment = $$_person.find("taskinfo > comment").text();
						__sub_personlinedata.comment = Base64.utf8_to_b64(Base64.b64_to_utf8($$_person.find("taskinfo > comment").text()).replace(/\n/g, "<br />"));
					} else {
						__sub_personlinedata.comment = "&nbsp;";
					}

					__inner_apvlist.push(__sub_personlinedata); //행 추가
				});
				
				__oulinedata.innerApvList = __inner_apvlist;
				/* ======================== 부서합의 결재자 모두보여주기 e ======================== */

				__tabledata.lineData.push(__oulinedata);
			}
		}
	});
	
	__tabledata.display = 'Y';

	return __tabledata;
}

function __getSignUrl(apvid, signtype, apvname, sDate, bDisplayDate, sResult, breturn, sDisplayType) {
	var SIGN_MODULE = "ApprovalSign";
    var __basedomain = document.location.origin;
    var rtn = "";    

    if (breturn && sDate) {
        if (signtype && signtype != "undefined") {
			if(signtype == "stamp"){
				rtn = CFN_GetDicInfo(apvname);
			} else {
				if(isNaN(signtype)){
					rtn = __basedomain + coviCmn.loadImage(g_BaseImgURL + signtype);
				} else { // 이전 서명표시를 위해서만 사용, 신규문서와는 무관
					rtn = __basedomain + coviCmn.loadImageId(signtype, SIGN_MODULE);	
				}        		
        	}
        } else {
            rtn = !bDisplayDate ? Common.getDic("lbl_apv_sign_none") : CFN_GetDicInfo(apvname);
        }
    } else if (!breturn) {
        rtn = CFN_GetDicInfo(apvname);
    }
	return rtn;
}

//**** 템플릿팅 수정전 함수 ****: 시작

function displayCCInfo($$_elmRoot) {
    var $$_ccInfos = $$_elmRoot.find("ccinfo");
    var sSendccInfos = "";
    var sRecccInfos = "";

    if ($$_ccInfos.length > 0) {
    	var arrBelongTo = [];
        $$_ccInfos.concat().each(function (index, $$_ccInfo) {
            var sList = "";
            var sBelongTo = $$_ccInfo.attr("belongto");
            arrBelongTo.push(sBelongTo);
            var $$_ccList = $$_ccInfo.children();
            var ccListIndex = 0;
            var $$_cc = $$_ccList.eq(ccListIndex); ccListIndex++;
            var cc_maxlimit = 100;
            while ($$_cc.exist() && ccListIndex < cc_maxlimit) {
                if ($$_cc.children().exist()) $$_cc = $$_cc.children(0);
                if ($$_cc.nodename() == "person") {
                    sList += (sList.length > 0 ? ", " : "") + CFN_GetDicInfo($$_cc.attr("ouname")) + " " + (g_DisplayJobType && (getLngLabel($$_cc.attr(g_DisplayJobType), true) + " ")) + setUserFlowerName($$_cc.attr("code"), CFN_GetDicInfo($$_cc.attr("name")), 'upTdOverflow');
                } else if ($$_cc.nodename() == "ou") {
                    if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_HWP_MULTI") {
                        sList += (sList.length > 0 ? ", " : "") + CFN_GetDicInfo($$_cc.attr("name")) + "장";
                    } else {
                        sList += (sList.length > 0 ? ", " : "") + CFN_GetDicInfo($$_cc.attr("name"));
                    }
                } else if ($$_cc.nodename() == "group") {
                    sList += (sList.length > 0 ? ", "  : "") + CFN_GetDicInfo($$_cc.attr("name"));
                }

                $$_cc = $$_ccList.eq(ccListIndex); ccListIndex++;
            }
            
            switch (sBelongTo) {
                case "global": CC.innerHTML = sList; break;
                case "sender":
                    sSendccInfos += (sSendccInfos.length > 0 ? ", " : "") + sList;
                    break;
                case "receiver":
                    sRecccInfos += (sRecccInfos.length > 0 ? ", " : "") + sList;
                    break;
            }
        });
        
        _func("#RecCC").html("").parent().parent().css({ "display": "none" });
        _func("#SendCC").html("");
        arrBelongTo.filter(function(item, index) { return arrBelongTo.indexOf(item) === index; }).forEach(function(item){
        	switch (item) {
            case "sender":
                _func("#SendCC").html(sSendccInfos);
                if(getInfo("ExtInfo.UseEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y") $("#DocReference").val(sSendccInfos.replace(/<[^>]*>?/g, ''));
                break;
            case "receiver":
                _func("#RecCC").parent().parent().css({ "display": "" });
                _func("#RecCC").html(sRecccInfos);
                if(getInfo("ExtInfo.UseEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y") $("#DocReference").val(sSendccInfos.replace(/<[^>]*>?/g, ''));
                break;
        	}
        });
        //참조자 목록 보이기 처리

        try { _func("#CCLine").show(); } catch (e) { coviCmn.traceLog(e); }
    } else {
        try { _func("#CCLine").hide(); } catch (e) { coviCmn.traceLog(e); }
    }
}

//배포처 목록 조회
function initRecList() {
    if (getInfo("SchemaContext.scIPub.isUse") == "Y" && getInfo("SchemaContext.scIPub.value") != "" && getInfo("Request.templatemode") == "Write" 
    		&& document.getElementById("ReceiveNames").value == "" && document.getElementById("ReceiptList").value == "") {
        var strIPub = getInfo("SchemaContext.scIPub.value");
        _func("#ReceiveNames").val(strIPub.split("||")[0]);
        _func("#ReceiptList").val(strIPub.split("||")[1]);
    }
    var szReturn = '';
    var aRec = _func("#ReceiveNames").val().split(";");
    var Include = "";
    for (var i = 0; i < aRec.length; i++) {
        if (aRec[i] != "") {
            if (aRec[i].split(":")[3] == "Y") {
                Include = "(" + Common.getDic("lbl_apv_recinfo_td2") + ")";
            }
            // 2022-11-11 플라워 네임 적용
			if (typeof (setUserFlowerName) == 'function' && aRec[i].split(':').length == 5) {
				szReturn += (szReturn != '' ? ", " : "") + (setUserFlowerName(aRec[i].split(":")[1], getLngLabel(aRec[i].split(":")[2], false, "^"), 'upTdOverflow')) + Include;
			} else {
				szReturn += (szReturn != '' ? ", " : "") + (getLngLabel(aRec[i].split(":")[2], false, "^")) + Include;
			}
            Include = "";
        }
    }
    // [2019-02-12 MOD] 수신처 없는 경우에도 테이블 조회되는 현상 처리
    if (szReturn != "" && getInfo("ExtInfo.UseMultiEditYN") != "Y"){
    	_func("#ReceiveLine").show();
    }else{
    	_func("#ReceiveLine").hide();
    }
    return szReturn;
}

// JAL-CONVERT : 2016-12-06 : JWK
// 가로 내부 결재선
function getInnerApvListCols($$_oApvStepList, DeptState, parentCnt) {
    var elmRoot, elmStep, $$_elmList, $$_elm, $$_elmTaskInfo, elmReceive, ApvList, emlSkip, elmCmtList, elmListR, elmR; //elmListR, elmR : 다중수신부서 여부를 알기위한 nodes 변수
    var Apvlines = "";
    var strDate, strFieldName, strwidth, strColTD, LastDate;
    $$_elmList = $$_oApvStepList.find("step[unittype='person'] > ou > person,step[unittype='role'] > ou > person,step[unittype='person'] > ou > person,step[unittype='role'] > ou > role ").concat();

    var ApvPOSLines = "";
    var Apvdecide = ""; //대결,후열 등을 표시
    var ApvState = "";
    var ApvSignLines = "";
    var ApvDept = "";
    var ApvApproveNameLines = "";
    var ApvDateLines = "";
    var ApvCmt = "";
    var Cmts = "";
    var sTitle = "";
    var elmAudit;
    var OriginApprover = "";
    var nextelm;
    var cnt = 1;
    var sCode = "";
    var ApvKind = "",LastApv = "",LastApvName ="";


    // 사람일 경우 for 문 시작	
    $$_elmList.each(function (i, $$_elm) {
        ApvSignLines = "&nbsp;";      //결재자 이름
        ApvCmt = "&nbsp;";            //사용자 코멘트 
        OriginApprover = "&nbsp;";    //원결재자
        sTitle = "&nbsp;";            //직책
        sCode = "";           //사용자 아이디
        ApvKind = "";

        $$_elmTaskInfo = $$_elm.find(">taskinfo");

        if ($$_elmTaskInfo.attr("visible") != "n") {
            if ($$_elmTaskInfo.attr("kind") != 'skip') {
                try {
                    g_DisplayJobType && (sTitle = getLngLabel($$_elm.attr(g_DisplayJobType), true));
                } catch (e) {
                    if ($$_elm.nodeName == "role") {
                        sTitle = CFN_GetDicInfo($$_elm.attr("name"));
                    }
                }
                
                strDate = $$_elmTaskInfo.attr("datecompleted");
                if (strDate == null) {
                    strDate = "";
                    ApvCmt = "";
                } else {
                    var $$_assistcmt = $$_elm.find("taskinfo > comment");
                    if ($$_assistcmt.exist()) {
                        ApvCmt = $$_assistcmt.text().replace(/\n/g, "<br>");
                    }
                }

                Apvdecide = Common.getDic("lbl_apv_normalapprove");// "결 재"
                if ($$_elm.tagName == "role")
                    try { sCode = $$_elm.find("person").attr("code"); } catch (e) { coviCmn.traceLog(e); }
                else
                    sCode = $$_elm.attr("code");
                ApvKind = interpretKind($$_elmTaskInfo.attr("kind"), $$_elmTaskInfo.attr("result"), "", "", Common.getDic("lbl_apv_normalapprove"));


                switch ($$_elmTaskInfo.attr("kind")) {
                    case "authorize":
                        // "전 결";
                        ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
                        ApvState = interpretResult($$_elmTaskInfo.attr("result"));
                        ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
                        ApvDateLines = "";
                        ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
                        ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
                        LastApv = "/";
                        LastApvName = CFN_GetDicInfo($$_elm.attr("name")) + interpretResult($$_elmTaskInfo.attr("result"));
                        LastDate = formatDate(strDate);
                        //ApvKind = "전결";
                        break;
                    case "substitute":
                        //"대 결";
                        ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
                        ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
                        ApvState = interpretResult($$_elmTaskInfo.attr("result"));
                        ApvDateLines = "";
                        ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
                        ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
                        LastApv = getSign(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, false, $$_elmTaskInfo.attr("result"), false);
                        LastApvName = CFN_GetDicInfo($$_elm.attr("name")) + interpretResult($$_elmTaskInfo.attr("result"));
                        LastDate = formatDate(strDate);
                        //원결재자 가져오기
                        //				            nextelm  = $$_elmList.nextNode();
                        //				            OriginApprover = CFN_GetDicInfo(nextelm.getAttribute("name"));
                        //ApvKind = "대결";
                        break;
                    case "skip":
                        ApvSignLines += "/";
                        ApvDept = getAttribute("/");
                        ApvDateLines = "";
                        ApvDateLines += "&nbsp;";
                        ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
                        //ApvKind = $$_elmTaskInfo.getAttribute("kind");
                        break;
                    case "bypass":
                        //"후 열"
                        //후열자 이름 넣어주기
                        ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
                        ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
                        ApvState = interpretResult($$_elmTaskInfo.attr("result"));
                        ApvDateLines = "";
                        ApvDateLines += (LastDate == "") ? m_oFormMenu.gLabel_bypass : LastDate; //"후열"
                        ApvApproveNameLines += (LastApvName == "") ? m_oFormMenu.gLabel_bypass : LastApvName; //"후열"
                        ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
                        //ApvKind = "후열";
                        break; //"후열"
                    case "review":
                        //Apvdecide = m_oFormMenu.gLabel_review; //"후 결"
                        //ApvSignLines += (strDate=="")?m_oFormMenu.gLabel_review: getSignUrl(sCode,$$_elmTaskInfo.getAttribute("customattribute1"),$$_elm.getAttribute("name"),strDate,false)+interpretResult($$_elmTaskInfo.getAttribute("result")); // "후결"
                        //ApvSignLines += (strDate=="")?m_oFormMenu.gLabel_review: getSignUrl(sCode,$$_elmTaskInfo.getAttribute("customattribute1"),$$_elm.getAttribute("name"),strDate,false); // "후결"
                        ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
                        ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
                        ApvState = interpretResult($$_elmTaskInfo.attr("result"));
                        ApvDateLines = "";
                        ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
                        ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
                        //ApvKind = "후결";						
                        break;
                    case "charge":
                        //Apvdecide = gLabel_apv;  //기안자 //"결 재"
                        ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
                        ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
                        ApvState = interpretResult($$_elmTaskInfo.attr("result"));
                        ApvDateLines = "";
                        ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
                        ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
                        //ApvKind = "담당";
                        break;
                    case "consent":
                        //Apvdecide = "참조"; 
                        ApvSignLines += CFN_GetDicInfo($$_elm.attr("name"));
                        ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
                        ApvState = interpretResult($$_elmTaskInfo.attr("result"));
                        ApvDateLines = "";
                        ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate);
                        ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
                        break;
                    default:
                        //합의
                        ApvSignLines += (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) : getSign(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, false, $$_elmTaskInfo.attr("result"), false);
                        ApvState = interpretResult($$_elmTaskInfo.attr("result"));
                        ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
                        ApvDateLines = "";
                        ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "D");
                        ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
                        //ApvKind = interpretResult($$_elmTaskInfo.getAttribute("result"));
                }

                if (DeptState == "T") //내부결재 진행중에만 보이기
                {
                    if (ApvCmt == "" || ApvCmt == "&nbsp;") {
                        ApvPOSLines = "<tr id='INDEPT" + parentCnt + "' style='font-family: Arial, Dotum;font-size: 12px;color: #142460; text-align: left; letter-spacing: -0.3pt; text-decoration: none;'><td style='background-color:#f5ebe1; color:#142460;'>" + parentCnt + "-" + cnt + "</td><td style='background:#FFFFFF;font-size:9pt;' height='20'>" + ApvDept + "</td>" + "<td style='background:#FFFFFF;font-size:9pt;' >" + ApvSignLines + "</td><td style='background:#FFFFFF;font-size:9pt;' >" + sTitle
	                                   + "<td style='background:#FFFFFF;font-size:9pt;'>" + ApvKind + "</td><td style='background:#FFFFFF;font-size:9pt;' height='20'>" + ApvState + "</td>" + "</td><td style='background:#FFFFFF;font-size:9pt;' >" + ApvDateLines + "</td><td style='background:#FFFFFF;font-size:9pt;'>" + OriginApprover + "</td></tr>" + ApvPOSLines;
                        cnt++;
                    }
                    else {
                        ApvPOSLines = "<tr id='INDEPT" + parentCnt + "' style='font-family: Arial, Dotum;font-size: 12px;color: #142460; text-align: left; letter-spacing: -0.3pt; text-decoration: none;'><td style='background-color:#f5ebe1; color:#142460;'>" + parentCnt + "-" + cnt + "</td><td style='background:#FFFFFF;font-size:9pt;' height='20'>" + ApvDept + "</td>" + "<td style='background:#FFFFFF;font-size:9pt;' >" + ApvSignLines + "</td><td style='background:#FFFFFF;font-size:9pt;' >" + sTitle
	                                   + "<td style='background:#FFFFFF;font-size:9pt;'>" + ApvKind + "</td><td style='background:#FFFFFF;font-size:9pt;' height='20'>" + ApvState + "</td>" + "</td><td style='background:#FFFFFF;font-size:9pt;' >" + ApvDateLines + "</td><td style='background:#FFFFFF;font-size:9pt;'>" + OriginApprover + "</td></tr>" + "<tr id='INDEPT" + parentCnt + "' ><td style='background:#FFFFFF;font-size:9pt;' align='left' height='20' colspan='8' style='padding-left:10px'> " + ApvCmt + "</td></tr>" + ApvPOSLines;
                        cnt++;
                    }
                } else {
                    if (ApvCmt == "" || ApvCmt == "&nbsp;") {
                        ApvPOSLines = "<tr id='INDEPT" + parentCnt + "' style='font-family: Arial, Dotum;font-size: 12px;color: #142460; text-align: left; letter-spacing: -0.3pt; text-decoration: none;display:none;'><td style='background-color:#f5ebe1; color:#142460;'>" + parentCnt + "-" + cnt + "</td><td style='background:#FFFFFF;font-size:9pt;' height='20'>" + ApvDept + "</td>" + "<td style='background:#FFFFFF;font-size:9pt;' >" + ApvSignLines + "</td><td style='background:#FFFFFF;font-size:9pt;' >" + sTitle
	                                   + "<td style='background:#FFFFFF;font-size:9pt;'>" + ApvKind + "</td><td style='background:#FFFFFF;font-size:9pt;' height='20'>" + ApvState + "</td>" + "</td><td style='background:#FFFFFF;font-size:9pt;' >" + ApvDateLines + "</td><td style='background:#FFFFFF;font-size:9pt;'>" + OriginApprover + "</td></tr>" + ApvPOSLines;
                        cnt++;
                    }
                    else {
                        ApvPOSLines = "<tr id='INDEPT" + parentCnt + "' style='font-family: Arial, Dotum;font-size: 12px;color: #142460; text-align: left; letter-spacing: -0.3pt; text-decoration: none;display:none;'><td style='background-color:#f5ebe1; color:#142460;'>" + parentCnt + "-" + cnt + "</td><td style='background:#FFFFFF;font-size:9pt;' height='20'>" + ApvDept + "</td>" + "<td style='background:#FFFFFF;font-size:9pt;' >" + ApvSignLines + "</td><td style='background:#FFFFFF;font-size:9pt;' >" + sTitle
	                                   + "<td style='background:#FFFFFF;font-size:9pt;'>" + ApvKind + "</td><td style='background:#FFFFFF;font-size:9pt;' height='20'>" + ApvState + "</td>" + "</td><td style='background:#FFFFFF;font-size:9pt;' >" + ApvDateLines + "</td><td style='background:#FFFFFF;font-size:9pt;'>" + OriginApprover + "</td></tr>" + "<tr id='INDEPT" + parentCnt + "' style='display:none'  ><td style='background:#FFFFFF;font-size:9pt;' align='left' height='20' colspan='8' style='padding-left:10px'> " + ApvCmt + "</td></tr>" + ApvPOSLines;
                        cnt++;
                    }
                }

            }
        }
    });
    //사람일 경우 for문 끝

    return ApvPOSLines;
}
//함수명이 작업중 잘린것 같아 찾아서 변경함.
//function tdisplayApv(displayId) 
function deptdisplayApv(displayId) {
    if (displayId != "") {
        if (document.getElementById(displayId).style.display == "") {
            document.getElementById(displayId).style.display = "none";
            document.getElementById("span_" + displayId).innerHTML = "▲";

        } else {
            document.getElementById(displayId).style.display = "";
            document.getElementById("span_" + displayId).innerHTML = "▼";
        }
    }
}

function getSign(apvid, signtype, apvname, sDate, bDisplayDate, sResult, breturn, sDisplayType) {
    var rtn = "";
    var strWidth = "60px";
    var strHeight = "50px";
    var SIGN_MODULE = "ApprovalSign";
    var __basedomain = document.location.origin;
    var signUrl;

    if (sDisplayType != null && sDisplayType == "list") {
        if (sDate != "") {
            if (signtype != "" && signtype != null && signtype != "undefined") {
                if (signtype == "stamp") {
                    return CFN_GetDicInfo(apvname);
                }
                else {
					if(isNaN(signtype)){ // 이전 서명표시를 위해서만 사용, 신규문서와는 무관
						signUrl = __basedomain + coviCmn.loadImage(g_BaseImgURL + signtype);
					} else {
						signUrl = __basedomain + coviCmn.loadImageId(signtype, SIGN_MODULE);	
					}
                    rtn = "<img src='" + signUrl + "' border=0 style='height:30px'>";
                }
            } else {
                rtn += (!bDisplayDate) ? Common.getDic("lbl_apv_sign_none") : CFN_GetDicInfo(apvname); //  + '<br>' + formatDate(sDate);
            }
        }
        return rtn;
    } else {
        if (!breturn) {
            return CFN_GetDicInfo(apvname);
        } else {
            if (sDate != "") {
                //                if (sResult == "authorized") {
                //                    rtn = "<div style='width:100%; text-align:left; font-size:11px; font-style:nomal;'>" + m_oFormMenu.gLabel_authorize + "</div>";
                //                    strWidth = "40px";
                //                    strHeight = "30px";
                //                } else if (sResult == "substituted") {
                //                    rtn = "<div style='width:100%; text-align:left; font-size:11px; font-style:nomal;'>" + m_oFormMenu.gLabel_substitue + "</div>";
                //                    strWidth = "40px";
                //                    strHeight = "30px";
                //                }

                if (signtype != "" && signtype != null && signtype != "undefined") {
                    if (signtype == "stamp") {
                        return CFN_GetDicInfo(apvname);
                    }
                    else {
						if(isNaN(signtype)){ // 이전 서명표시를 위해서만 사용, 신규문서와는 무관
							signUrl = __basedomain + coviCmn.loadImage(g_BaseImgURL + signtype);
						} else {
							signUrl = __basedomain + coviCmn.loadImageId(signtype, SIGN_MODULE);	
						}
                        rtn += "<img src='" + signUrl + "' border=0 style='width:" + strWidth + ";height:" + strHeight + "'>";
                    }
                } else {
                    rtn += (!bDisplayDate) ? Common.getDic("lbl_apv_sign_none") : CFN_GetDicInfo(apvname); //  + '<br>' + formatDate(sDate);
                }
                return rtn;
            } else { return rtn; }
        }
    }
}

function getPresence(szpersoncode, szid, szsipaddress) {
    var szreturn = ""
    if (getInfo("Request.mobileyn") == "Y") {
    } else {
        if (!m_print) {
            if (bPresenceView) {
                szreturn = "<span>";
                szreturn += "<img src='/HtmlSite/smarts4j_n/covicore/resources/images/covision/Unknown.gif'  style='border-width:0px;' align='absmiddle'  covimode='imgctxmenu' onload='";
                szreturn += "	IMNRC(\"" + ((szsipaddress != null) ? szsipaddress : szpersoncode + m_oFormMenu.gMailSuffix) + "\", this);' id=\"ctl00_ContentPlaceHolder1_GridView1_ctl" + randomPIndex() + "_presence\" />";
                szreturn += "	</span>&nbsp;";
            }
            else {
                szreturn = "&nbsp;";
            }
        }
    }
    return szreturn;
}

//MS Presence
function randomPIndex() {
    var ranNum;
    ranNum = Math.floor(coviCmn.random() * 100000);
    return ranNum;
}

function interpretResult(strresult, szExtType, szkind) {
    var sKind = "";
    if (szExtType == "ExtType") {
        if (strresult == "rejected") { sKind = Common.getDic("lbl_apv_ExtType_agree");	}	//특이기능승인	//"반려"
        if (strresult == "agreed") { sKind = Common.getDic("lbl_apv_ExtType_disagree"); }		//특이기능반려	//"합의"
        if (strresult == "disagreed") { sKind = Common.getDic("lbl_apv_ExtType_agree"); }		//특이기능승인	//"이의"	    
    } else {
        if (strresult == "authorized") { sKind = Common.getDic("lbl_apv_Approved");		/*gLabel_apv;*/ } 		//"승인"
        if (strresult == "substituted") { sKind = Common.getDic("lbl_apv_Approved");		/*gLabel_apv;*/ } 		//"승인"
        //담당업무 미결 및 진행함 승인 후에도 '기안'으로 나와서 수정함
        if (strresult == "completed") {
        	if (szExtType == "consult") {
                sKind = Common.getDic("lbl_apv_agree");                               //"동의"
            }
            else {
                sKind = Common.getDic("lbl_apv_Approved");                             //"승인"
            }
        }
        if (strresult == "reviewed") { sKind = Common.getDic("lbl_apv_Approved");		/*gLabel_apv;*/ } 		//"승인"
        if (strresult == "rejected") { 
        	if (szExtType == "consult") {
                sKind = Common.getDic("lbl_apv_disagree");                            //"거부"
            }
            else {
                sKind = Common.getDic("lbl_apv_reject");                             //"반려"
            }
        }
        if (strresult == "agreed") { sKind = Common.getDic("lbl_apv_agree");		/*gLabel_agree;*/ } 			//"합의"
        if (strresult == "disagreed") { sKind = Common.getDic("lbl_apv_disagree");		/*gLabel_disagree;*/ } //"이의"
        if (strresult == "reserved") { sKind = Common.getDic("lbl_apv_hold");		/*gLabel_hold;*/ } 			//"보류"
        if (strresult == "bypassed") { sKind = Common.getDic("lbl_apv_bypass");		/*gLabel_bypass;*/ } 		//"후열"
    }
    return sKind;
}


function interpretKind(strkind, strresult, routetype, allottype, name) {
    var sKind = strkind;
    switch (strkind) {
        case "normal": sKind = Common.getDic("lbl_apv_app"); break; //"결재"
        case "charge": sKind = Common.getDic("lbl_apv_charge"); break; //"담당"
        case "authorize": sKind = Common.getDic("lbl_apv_authorize"); break; 	//"전결"
        case "review": sKind = Common.getDic("lbl_apv_review"); break; 		//"후결"
        case "consent": sKind = Common.getDic("lbl_apv_tit_consent"); break; 		//"합의"
        case "substitute": sKind = Common.getDic("lbl_apv_substitue"); break; 	//"대결"
        case "bypass": sKind = Common.getDic("lbl_apv_bypass"); break; 		//"후열"
        case "confirm": sKind = Common.getDic("lbl_apv_Confirm"); break; //"확인"
        case "reference": sKind = Common.getDic("lbl_apv_cc"); break; //"참조"
        case "skip": sKind = "--"; break;
        case "consult": 
			if(allottype == "parallel") sKind = Common.getDic("lbl_apv_PersonConsent");  //개인합의(병렬)
			else sKind = Common.getDic("lbl_apv_consent");  //"개인합의" // allottype=serial
			break; 		
    }
    //normal일 경우 세부설정
    if (strkind == "normal") {
		switch(routetype){
			//case "approve": sKind = Common.getDic("lbl_apv_app"); break; //"결재"
			case "assist":
				if(allottype == "parallel") sKind = Common.getDic("lbl_apv_assist_2"); // 개인협조(병렬)
				else sKind = Common.getDic("lbl_apv_assist"); // 개인협조 // allottype=serial
				break;
			case "audit":
				if(name == "audit_law") sKind = Common.getDic("lbl_apv_person_audit"); //개인준법;
				else if(name == "audit") sKind = Common.getDic("lbl_apv_person_audit3"); //개인감사;
				else if(name == "audit_law_dept") sKind = Common.getDic("lbl_apv_dept_audit"); //부서준법;
				else if(name == "audit_dept") sKind = Common.getDic("lbl_apv_dept_audit3"); //부서감사;
				break;
			default:
				if (name == "ExtType") {
					sKind = Common.getDic("lbl_apv_ExtType"); // 특이기능
				}
				break;
		}
		
    }
    return sKind;
}


function formatDate(sDate, sMode) {
    /// <summary>
    ///  날짜 형식
    /// &#10; "R" : 2012년 03월 09일
    /// &#10; "D" : 2012-03-09
    /// &#10; "Y" : 2012년 03월 09일 (원래값이 2012.03.09 일때)
    /// &#10; "A" : 201203
    /// &#10; "APV" : 2012-03-09 09:45
    /// &#10; "M" : 2012.03
    /// &#10; else : 2012-03-09
    ///</summary>
    /// <param name="sDate" type="String">날짜</param>
    /// <param name="sMode" type="String">모드(null 가능)</param>
    /// <returns type="String" />
    //타임존 적용
    var dtDate = "";
    //if(sDate > '2019-12-26 12:00:00') { // 결재선은 마이그레이션 불가하여 분기처리 함.
    //if(sDate > Common.getBaseConfig("BaseTimeZone_ApvLine")) {
    // 과거 ~ 2019-12-16, 2020.10.26 19:00 ~ 는 타임존 +9 //// 2019.12.16 ~ 2020.10.26 19:00 까지는 UTC 적용데이터
    if(Common.getBaseConfig("BaseTimeZone_ApvLine") != "" && Common.getBaseConfig("BaseTimeZone_ApvLineTo") != "" && sDate > Common.getBaseConfig("BaseTimeZone_ApvLine") && sDate < Common.getBaseConfig("BaseTimeZone_ApvLineTo")){
    	dtDate = XFN_TransDateServerFormat(CFN_TransLocalTime4GMT9(formatDateCVT(sDate)));
    } else {
    	dtDate = XFN_TransDateServerFormat(CFN_TransLocalTime(formatDateCVT(sDate)));
    }
    
    
    //var dtDate = formatDateCVT(sDate);
    var aRecDate = dtDate.split("-");
    var aRecDate2 = dtDate.split(".");
    if (sMode == "R") { // 2012년 03월 09일
        if (aRecDate.length > 2) { return aRecDate[0] + "년 " + aRecDate[1] + "월 " + aRecDate[2].substring(0, 2) + "일"; } else { return ""; }
    } else if (sMode == "D") {  // 2012-03-09
        if (aRecDate.length > 2) { return aRecDate[0] + "-" + aRecDate[1] + "-" + aRecDate[2].substring(0, 2); } else { return ""; }
    } else if (sMode == "Y") { // 2012년 03월 09일(원래값이 2012.03.09 일때)
        if (aRecDate2.length > 2) { return aRecDate2[0] + "년 " + aRecDate2[1] + "월 " + aRecDate2[2] + "일"; } else { return ""; }
    } else if (sMode == "A") { // 201203
        if (aRecDate.length > 2) { return aRecDate[0] + aRecDate[1]; } else { return ""; }
    } else if (sMode == "APV") {    // 2012-03-09 09:45
        if (aRecDate.length > 2) {
            var dtDate = new Date(dtDate.replace(/-/g, "/").replace(/오후/, "pm").replace(/오전/, "am"));
            return dtDate.getFullYear() + "-" + dblDigit(dtDate.getMonth() + 1) + "-" + dblDigit(dtDate.getDate()) + " " + dblDigit(dtDate.getHours()) + ":" + dblDigit(dtDate.getMinutes());
        } else { return ""; }
    } else if (sMode == "CMT") {
        return XFN_TransDateLocalFormat(dblDigit(dtDate));
    } else if (sMode == "H") {    // 03/09 09:45
        if (aRecDate.length > 2) {
            var dtDate = new Date(dtDate.replace(/-/g, "/").replace(/오후/, "pm").replace(/오전/, "am"));
            return dblDigit(dtDate.getMonth() + 1) + "/" + dblDigit(dtDate.getDate()) + " " + dblDigit(dtDate.getHours()) + ":" + dblDigit(dtDate.getMinutes());
        } else { return ""; }
    } else if (sMode == "S") {  // 2012
        if (aRecDate.length > 2) { return aRecDate[0]; } else { return ""; }
    } else if (sMode == "M") {  // 2012.03
        if (aRecDate.length > 2) { return aRecDate[0] + "." + aRecDate[1]; } else { return ""; }
    } else {//2012-03-09
        if (aRecDate.length > 2) {
            var dtDate = new Date(dtDate.replace(/-/g, "/").replace(/오후/, "pm").replace(/오전/, "am"));
            return aRecDate[0].substring(2, 4) + "/" + aRecDate[1] + "/" + aRecDate[2].substring(0, 2) + " " + dblDigit(dtDate.getHours()) + ":" + dblDigit(dtDate.getMinutes());
        } else { return ""; }
    }
}

function formatDateCVT(sDate) {
    if (sDate == "" || sDate == null)
        return "";
    var szDate = sDate.replace(/-/g, "/").replace(/오후/, "pm").replace(/오전/, "am");
    if (szDate.indexOf("pm") > -1) {
        szDate = szDate.replace("pm ", "");
        var atempPM = szDate.split(" ");
        var tmp = parseInt(atempPM[1].split(":")[0]) + 12;
        if (tmp > 23 && parseInt(atempPM[1].split(":")[1]) > 0) tmp = tmp - 12;
        tmp = dblDigit(tmp);
        var atempPM2 = atempPM[0].split("/");
        szDate = atempPM2[1] + "/" + atempPM2[2] + "/" + atempPM2[0] + " " + tmp + atempPM[1].substring(atempPM[1].indexOf(":"), 10);
    } else {
        szDate = szDate.replace("am ", "");
        var atempAM = szDate.split(" ");
        var atempAM2 = atempAM[0].split("/");
        szDate = atempAM2[1] + "/" + atempAM2[2] + "/" + atempAM2[0] + " " + atempAM[1];
    }
    var dtDate = new Date(szDate);
    return dtDate.getFullYear() + "-" + dblDigit(dtDate.getMonth() + 1) + "-" + dblDigit(dtDate.getDate()) + " " + dblDigit(dtDate.getHours()) + ":" + dblDigit(dtDate.getMinutes()) + ":" + dblDigit(dtDate.getSeconds());
}

function dblDigit(iVal) { return (iVal < 10 ? "0" + iVal : iVal); }

//결재선 의견 접기 펼치기
function Comment_view(comment_id) {
    var objComment_hidden = document.getElementById('comment_hidden_' + comment_id);
    var objComment_view = document.getElementById('comment_view_' + comment_id);
    objComment_hidden.style.display = "none";
    objComment_view.style.display = "";
}

function Comment_hidden(comment_id) {
    var objComment_hidden = document.getElementById('comment_hidden_' + comment_id);
    var objComment_view = document.getElementById('comment_view_' + comment_id);
    objComment_hidden.style.display = "";
    objComment_view.style.display = "none";
}

var sCommentHtml = "";
var bCommentViewFirst = true;
var bgetCommentView = true;


function getCommentView(elmRootCom) {

	try {
		// 의견 읽음 처리
		var sProcessID = "";
		if (getInfo("SchemaContext.scComment.value.scCmtShowType") != "Y") { // 발신/수신 함께 보기 여부
			sProcessID = getInfo("ProcessInfo.ProcessID");
		}
		var sFormInstID = getInfo("FormInstanceInfo.FormInstID");
		
		//미리보기
		if(sProcessID == undefined || sFormInstID == undefined) return;
		
		var oResult = $.ajax({
			type: "POST",
			async: false,
			url: "apvline/getDocCommentList.do",
			data: {
				"FormInstID": sFormInstID,
				"ProcessID": sProcessID
			},
			success: function(data) {
				if (data.result == "ok") {
					return data;
				}
				else {
					Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
				}
			}
		});
	} catch (e) {
		alert(e);
	}

	if (elmRootCom.length <= 0) {
		return;
	}

	if ($("#CommentList").html() == "") {
		ParseComments.parse(elmRootCom);
		var comments = ParseComments.comment();
		ParseComments.render();
				
		/* 2020.04.10 dgkim 수신부서 의견이 있을때, 기안부서 의견은 없는데 양식에 헤더부분이 표시됨 */		
		$("#CommentList .tableStyle:has('#commentTH')").prev().show();
		
		// 양식에서 열었을 경우
		$("#CommentList").find("table").each(function(){
			var thLength = $(this).find("th#commentTH").length;
			$(this).find("th#commentTH").each(function(i, obj){
				if(i==0){
					$(obj).attr("rowspan", 100);
					if(thLength == 1){
						$(obj).parent().css("height", "43px");
					}
				}else{
					$(obj).remove();
				}
			});
		});
	}
	// 의견 입력 유형이 게시형 OR 의견 입력 후 게시형 의경 사용안함으로 옵션이 바뀐 경우(이전에 입력된 댓글은 문서에 조회됨)
	if (getInfo("SchemaContext.scComment.isUse") == "Y" || (oResult.responseJSON != null && oResult.responseJSON.list.length>0)) {
			//결재문서 의견 조회
			//$("#CommentList").html("결재문서 의견 조회");
			getCommentView_Board(oResult);
	}
}

function viewComment() {
    doButtonAction($("#btCommentView")[0]);
}

function getCommentView_Board(oResult) {
	
	var oResult = $.parseJSON(oResult.responseText);
	var sHTML = " <div>";
	sHTML += " <table style=\"border: 1px solid #e3e3e3; margin-top: 50px; \"cellpadding=\"10\">";
	sHTML += " <tbody>";
	sHTML += " <tr>";
	sHTML += " <td>";

//	var sWriterType = getInfo("SchemaContext.scComment.value.rdoscCmt_Approver"); // 작성자가 Approver
	var bReply = false; // 덧글 버튼 표시여부
	var bDelete = false; // 삭제 버튼 표시여부
	var bModify = false; // 수정 버튼 표시여부
	var bProcessing = false; // 진행 중 여부
	var bCompleteAdd = false; // 완료 후 추가 허용 여부
	var bCompleteEdit = false; // 완료 후 변경 허용 여부
	if ((getInfo("Request.loct").toLowerCase() == "complete") &&
		(getInfo("Request.mode").toLowerCase() == "complete")) {
		bProcessing = false;
		// 완료된 문서이면,
		if (getInfo("SchemaContext.scComment.value.scCmtReplyAdd") == "Y") { // 완료 후 추가 허용
			bCompleteAdd = true;
		}
		if (getInfo("SchemaContext.scComment.value.scCmtEdit") == "Y") { // 완료 후 변경 허용
			bCompleteEdit = true;
		}
	}
	else {
		bProcessing = true;
	}

	var sCommentID = "";
	var sStep = "0";
	var sSort = "0";
	var sID = "";
	var oStepIdx = {};
	var sParentStepID = 0;
	$(oResult.list).each(function() {
		var bMyProcess = (this.ProcessID == getInfo("ProcessInfo.ProcessID"));
		sCommentID = this.CommentID;
		sID = sCommentID;
		sStep = this.Step;
		sSort = this.Sort;

		// 각 의견별 덧글 버튼 설정
		bReply = false; // 덧글 버튼 표시여부
		bDelete = false; // 삭제 버튼 표시여부
		bModify = false; // 수정 버튼 표시여부
		if ((bProcessing) || // 결재 진행 중
			(bCompleteEdit)) { // 완료 후 의견 수정 가능
			if (sStep == "0") {
				if (getInfo("SchemaContext.scComment.value.scCmtReplyTo") == "Y") {
					bReply = true;
				}
			}
			else {
				if (getInfo("SchemaContext.scComment.value.scCmtReplyTo") == "Y") {
					bReply = true;
				}
			}
			if (getInfo("SchemaContext.scComment.value.scCmtDelete") == "Y") {
				if (Common.getSession("USERID").toLowerCase() == this.RegistURCode.toLowerCase()) {
					bDelete = true;
				}
			}
			if (getInfo("SchemaContext.scComment.value.scCmtModify") == "Y") {
				if (Common.getSession("USERID").toLowerCase() == this.RegistURCode.toLowerCase()) {
					bModify = true;
				}
			}
		}

		if(sStep == 0){
			oStepIdx = {};
			sParentStepID = 0;
		}else{
			sParentStepID = oStepIdx[sStep-1];
			if(!sParentStepID) sParentStepID = 0;
		}
		oStepIdx[sStep] = sCommentID;
		
		var sCommentType = "";
		var sApprovalState = this.ApprovalState == null ? "" : this.ApprovalState.toLowerCase();
		var sApprovalMode = this.ApprovalMode == null ? "" : this.ApprovalMode.toLowerCase();
		var sCommentFile = this.Comment_fileInfo == null ? "" : this.Comment_fileInfo;
		var _aStrDic = Common.getDicAll("lbl_apv_Approved;lbl_apv_reject;lbl_apv_hold;lbl_apv_Draft;lbl_Comment2;lbl_apv_delete;lbl_apv_edit"); // 승인/반려/보류/기안/덧글/삭제/수정
		switch (sApprovalState) {
			case "approve":
				sCommentType = " <span style=\"color:#4bbde1; border: solid 1px #4bbde1; padding: 2px;\" title=\"(" + sApprovalState + "|" + sApprovalMode + ")\">" + _aStrDic["lbl_apv_Approved"] + "</span>"; // 승인
				break;
				//switch (sApprovalMode) {
				//    case "approval":
				//        sCommentType = "<span style=\"color:#4bbde1; border: solid 1px #4bbde1; padding: 2px;\" title=\"(" + sApprovalState + "|" + sApprovalMode + ")\">승인</span>";
				//        break;
				//    case "draft":
				//    case "pconsult":
				//    case "RECAPPROVAL":
				//    case "REDRAFT":
				//    case "SUBAPPROVAL":
				//    case "SUBREDRAFT":
				//        sCommentType = "<span style=\"color:#4bbde1; border: solid 1px #4bbde1; padding: 2px;\" title=\"(" + sApprovalState + "|" + sApprovalMode + ")\">승인</span>";
				//        break;
				//}
				break;
			case "reject":
				sCommentType = " <span style=\"color:#ff0000; border: solid 1px #ff0000; padding: 2px;\" title=\"(" + sApprovalState + "|" + sApprovalMode + ")\">" + _aStrDic["lbl_apv_reject"] + "</span>"; // 반려
				break;
			case "reserve":
				sCommentType = " <span style=\"color:#0000aa; border: solid 1px #0000aa; padding: 2px;\" title=\"(" + sApprovalState + "|" + sApprovalMode + ")\">" + _aStrDic["lbl_apv_hold"] + "</span>"; // 보류
				break;
			default:
				switch (sApprovalMode) {
					case "draft":
						sCommentType = " <span style=\"color:#009900; border: solid 1px #009900; padding: 2px;\" title=\"(" + sApprovalState + "|" + sApprovalMode + ")\">" + _aStrDic["lbl_apv_Draft"] + "</span>"; // 기안
						break;
				}
				break;
		}

		if (sStep > 0) {
			sHTML += " <div id=\"divReply_" + sID + "\" style=\"padding-left:" + (new Number(sStep) * 15) + "px;\">";
		}
		else {
			sHTML += " <div id=\"divReply_" + sID + "\">";
		}
		sHTML += " <table style=\"width: 100%;border-bottom: 1px dashed #dadada;padding: 0px;\" cellpadding=\"10\">";
		sHTML += " <tbody>";
		sHTML += " <tr>";
		sHTML += " <td style=\"vertical-align:top;\">";
		//        sHTML += " <img src=\"/Images/Images/Board/btn_comm_re.gif\" alt=\"\" class=\"img_align4\">";
		if(sStep == 0){
			sHTML += " <span style=\"font-size:14px;color:#222222;font-weight:bold;\">" + this.RegistURName.split(';')[0] + "(" + CFN_GetDicInfo(this.RegistGRName) + ")</span>";
		}else{
			sHTML += " <span style=\"font-size:14px;color:#222222;font-weight:bold;\">" + "ㄴ" + this.RegistURName.split(';')[0] + "(" + CFN_GetDicInfo(this.RegistGRName) + ")</span>";
		}
		sHTML += " <span style=\"font-size: 12px;\">[" + this.ReplyCount + "]</span>";
		sHTML += " <span style=\"font-size: 12px;\">(" + this.RegistDate + ")</span>";
		if (sCommentType != "") {
			sHTML += sCommentType;
		}
		sHTML += " </td>";
		sHTML += " <td align=\"right\">";
		if (sCommentFile != "") {
			sHTML += " <span style=\"margin-top:-2px;color: #dbdbdb;padding: 0 4px 0 4px;\">I</span>";
			sHTML += " <a onclick=\"void_OpenAttach_OnClick('hidFileInfo_" + sID + "')\"><img src=\"/Images/Images/Common/Btn/icon_00_files.png\" style=\"cursor:pointer;\"></a>";
			sHTML += " <input type=\"hidden\" id=\"hidFileInfo_" + sID + "\" value=\"" + sCommentFile + "\" />";
		}
		if (bReply && this.ReplyCount < 5){
			sHTML += " <span style=\"margin-top:-2px;color: #dbdbdb;padding: 0 4px 0 4px;\">I</span>";
			sHTML += " <span><a href=\"javascript:void(0);\" style=\"font-size: 13px;color: #776;\" onclick=\"onClickBtnCmtReply('" + sCommentID + "', '" + (new Number(sStep) + 1) + "', '" + this.ParentCommentID + "');\">" + _aStrDic["lbl_Comment2"] + "</a></span>"; // 덧글
		}
		if (bDelete && bMyProcess) {
			if (this.ReplyCount == 0) {
				sHTML += " <span style=\"margin-top:-2px;color: #dbdbdb;padding: 0 4px 0 4px;\">I</span>";
				sHTML += " <span><a href=\"javascript:void(0);\" style=\"font-size: 13px;color: #776;\" onclick=\"onClickBtnCmtDelete('" + sCommentID + "', '" + this.ParentCommentID +"', '" + sSort + "', '" + sStep + "', '" + sParentStepID + "');\">" + _aStrDic["lbl_apv_delete"] + "</a></span>";   // 삭제
			}
		}
		if (bModify && bMyProcess) {
			sHTML += " <span style=\"margin-top:-2px;color: #dbdbdb;padding: 0 4px 0 4px;\">I</span>";
			sHTML += " <span><a href=\"javascript:void(0);\" style=\"font-size: 13px;color: #776;\" onclick=\"onClickBtnCmtModify('" + sCommentID + "', '" + sStep + "', '" + this.ParentCommentID + "');\">" + _aStrDic["lbl_apv_edit"] + "</a></span>"; // 수정
		}
		sHTML += " </td>";
		sHTML += " </tr>";
		sHTML += " <tr>";
		sHTML += " <td id=\"tdComment_" + sID + "\" style=\"font-size: 12px;\" colspan=\"2\">" + this.Comment.replace(/</gi, "&lt;") + "</td>";
		sHTML += " </tr>";
		sHTML += " </tbody>";
		sHTML += " </table>";
		sHTML += " </div>";
		sHTML += " <div id=\"divReplyForm_" + sID + "\"></div>";
	});

	var sCommentAddHTML = "";
	if ((bProcessing) || // 결재 진행 중
		(bCompleteAdd)) {// 완료 후 의견 추가 가능
		if (getInfo("SchemaContext.scComment.isUse") == "Y") {
			sCommentAddHTML = string_GetReplyForm("REGIST", "", 0, 0);
		}
	}
	sHTML += sCommentAddHTML;

	sHTML += " </td>";
	sHTML += " </tr>";
	sHTML += " </tbody>";
	sHTML += " </table>";
	sHTML += " </div>";

	// 결재문서 의견 바인딩
	$("#CommentList").html($("#CommentList").html() + sHTML);
}

// 답글 UI HTML
function string_GetReplyForm(pStrType, pStrCommentID, pIntStep, pStrParentCommentID) {
	var sID = pStrCommentID.replace(/-/gi, "");
	var sHTML = " <div style=\"padding-top: 10px;padding-left:" + (pIntStep * 15) + "px;\">";
	sHTML += " <table style=\"width: 100%;\">";
	sHTML += " <tbody>";
	sHTML += " <tr>";
	sHTML += " <td style=\"vertical-align:top;\">";
	//    sHTML += " <img src=\"/Images/Images/Board/btn_comm_re.gif\" alt=\"\" class=\"img_align4\">";
	sHTML += " <span style=\"font-size:14px;color:#222222;font-weight:bold;\">" + "ㄴ" + Common.getSession('USERNAME') + "(" + Common.getSession('DEPTNAME') + ")</span>";
	sHTML += " </td>";
	sHTML += " </tr>";
	sHTML += " <tr>";
	sHTML += " <td>";
	sHTML += " <div>";
	sHTML += " <textarea id=\"txtComment_" + sID + "\" style=\"width:100%;height:50px;box-sizing:border-box;font-size: 12px;\"></textarea>";
	sHTML += " <input type=\"hidden\" id=\"txtCommentID\" value=\"" + pStrCommentID + "\" />";
	sHTML += " </div>";
	sHTML += " </td>";
	sHTML += " </tr>";
	sHTML += " <tr>";
	sHTML += " <td>";
	if (getInfo("scCmt_Attach") == "1") {
		//기능 구현되어 있지 않아 주석 처리
		//sHTML += " <div style=\"float:left;\">";
		//sHTML += " <a href=\"javascript:void_btnCmtAttach_OnClick('" + pStrCommentID + "');\"><em class=\"btn_bs_l\"><span class=\"btn_bs_r\"><strong class=\"txt_btn_bs\">" + Common.getDic("lbl_attach") + "</strong></span></em></a>"; // 첨부
		//sHTML += " </div>";
	}
	sHTML += " <div style=\"float:right;\">";
	sHTML += " <a href=\"javascript:onClickBtnCmtConfirm('" + pStrType + "', '" + pStrCommentID + "', '" + pStrParentCommentID + "');\"><span class=\"blBtn\"><strong>" + Common.getDic("lbl_Confirm") + "</strong></span></a>"; // 확인
	if (pStrType != "REGIST") {
		sHTML += " <a href=\"javascript:void_btnCmtCancel_OnClick('" + pStrCommentID + "');\"><em><span class=\"AXButton\"><strong style=\"font-style: normal;\">" + Common.getDic("lbl_Cancel") + "</strong></span></em></a>"; // 취소
	}
	sHTML += " </div>";
	sHTML += " </td>";
	sHTML += " </tr>";
	sHTML += " </tbody>";
	sHTML += " </table>";

	return sHTML;
}

// 덧글 클릭 시 UI 표시
function onClickBtnCmtReply(pStrCommentID, pIntStep, pStrParentCommentID) {
	var sID = pStrCommentID.replace(/-/gi, "");
	var oReplyForm = $("#divReplyForm_" + sID);
	if (oReplyForm.html() == "") {
		oReplyForm.html(string_GetReplyForm("REPLY", pStrCommentID, pIntStep, pStrParentCommentID));
	}
	oReplyForm.show();
	$("#txtComment_" + sID).focus();
}

// 삭제 클릭 시 처리
function onClickBtnCmtDelete(pStrCommentID, pParentCommentID, sSort, sStep, sStrParentStepID) {
	var oResult = $.ajax({
			type: "POST",
			async: false,
			url: "apvline/delDocComment.do",
			data: {
				"CommentID": pStrCommentID,
				"ParentCommentID" : pParentCommentID,
				"ParentStepID": sStrParentStepID,
				"Sort" : sSort,
				"Step" : sStep
			},
			success: function(data) {
				var _approvalLine = $.parseJSON(getInfo("ApprovalLine"));
				if (data.result == "ok") {
					$("#CommentList").html("");
					getCommentView(_approvalLine);
				}
			},
			error: function(response, status, error) {
				Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
			}
		});
}

// 취소 클릭 시 UI 표시
function void_btnCmtCancel_OnClick(pStrCommentID) {
    var sID = pStrCommentID.replace(/-/gi, "");
    $("#divReplyForm_" + sID).hide();
    $("#divReply_" + sID).show();
}

// 수정 클릭 시 UI 표시
function onClickBtnCmtModify(pStrCommentID, pIntStep, pStrParentCommentID) {
	var sID = pStrCommentID.replace(/-/gi, "");
	var oReplyForm = $("#divReplyForm_" + sID);
	if (oReplyForm.html() == "") {
		oReplyForm.html(string_GetReplyForm("MODIFY", pStrCommentID, pIntStep, pStrParentCommentID));
	}
	oReplyForm.show();
	$("#divReply_" + sID).hide();

	$("#txtComment_" + sID).text($("#tdComment_" + sID).text()).focus();
}

// 등록 클릭 시 UI 표시
function onClickBtnCmtConfirm(pStrType, pStrCommentID, pStrParentCommentID) {
	if(!pStrParentCommentID || pStrParentCommentID == "null") pStrParentCommentID = 0;
	//alert("첨부 처리 필요");
	var sFormInstID = getInfo("FormInstanceInfo.FormInstID");
	var sProcessID = getInfo("ProcessInfo.ProcessID");
	var sComment = $("#txtComment_" + pStrCommentID.replace(/-/gi, "")).val();
	if (sComment == "") {
		Common.Warning(Common.getDic("msg_apv_064"), "", function() { // 의견을 입력하십시요.
			$("#txtComment_" + pStrCommentID.replace(/-/gi, "")).focus();
		});
		return;
	}

	// 알림을 위한 결재문서 정보
	var sApvLine = escape(encodeURIComponent($("#APVLIST").val()));
	var sDSCR = escape(encodeURIComponent(getInfo("pidc")));
	var sFormInfoExt = "<docinfo>";
	sFormInfoExt += "<keepyear><![CDATA[" + getInfo("APPLIED") + "]]></keepyear>";
	sFormInfoExt += "<catname><![CDATA[" + getInfo("DOC_CLASS_NAME") + "]]></catname>";
	sFormInfoExt += "<docsec><![CDATA[" + getInfo("DOC_LEVEL") + "]]></docsec>";
	sFormInfoExt += "</docinfo>";

	sFormInfoExt = escape(encodeURIComponent(sFormInfoExt));

	var oResult = null;
	var oResult = $.ajax({
			type: "POST",
			async: false,
			url: "apvline/setDocComment.do", //댓글 추가 및 수정
			data: {
				"CommentType" : pStrType,
				"CommentID": pStrCommentID,
				"ParentCommentID": pStrParentCommentID,
				"FormInstID": sFormInstID,
				"ProcessID": sProcessID,
				"Comment": sComment,
				"Comment_fileinfo": '',
				"ApprovalMode": '',
				"ApprovalState": '',
				"Initiator" : getInfo("FormInstanceInfo.InitiatorID"),
				"RegistURCode" : Common.getSession("USERID"),
				"RegistURName" : Common.getSession("UR_MultiName"),
				"RegistGRCode" : Common.getSession("ApprovalParentGR_Code"),
				"RegistGRName" : Common.getSession("ApprovalParentGR_Name")
			},
			success: function(data) {
				var _approvalLine = $.parseJSON(getInfo("ApprovalLine"));
				if (data.result == "ok") {
					$("#CommentList").html("");
					getCommentView(_approvalLine);
				}
			},
			error: function(response, status, error) {
				Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
			}
		});
}

//------------------------
//-- 코멘트 추출 함수
//@parameter : json 오브젝트
//@return :     
//var CommentLists = {
//CommentList: { // 기안처 의견
// comments: null,  //일반 의견
// feedback: null   //피드백 의견
//},
//CommentListRec: []   //수신처(복수) 의견
//};


/* 
* HOW-TO
//extract comments from apv list
ParseComments.parse(m_oApvList);

//review comments
console.log(ParseComments.comment());

//render template(optional)
ParseComments.render();
*/
var m_oInfoSrc = window;

var ParseComments = (function () {

var apvlist,
    docs, //현재 윈도우
    getInfo, //결재옵션
    getDic, //프레임워크 딕셔너리 참조
    oComments,
    conf = {};//환경변수
  
var init = function(m_oApvList){
    apvlist = m_oApvList;
    //현재 윈도우
    docs = m_oInfoSrc; 
    getInfo = docs.getInfo; //결재옵션
    getDic = CFN_GetDicInfo; //프레임워크 딕셔너리 참조       

    var c = { //환경변수
        extcmt : $('#extcmt').val(),
        feedback : typeof getInfo !== 'function' ? '' : getInfo("feedback"),
        feedbackcmt : $('#feedbackcmt').val(),
        src_mode : typeof formJson != 'undefined' ? getInfo("Request.mode") : opener.getInfo("Request.mode"), //m_oInfoSrc_mode,
        isViewComment : ('' != this.extcmt),
        CommentListId : '#CommentList',
        CommentListRecId : '#CommentListRec',
    };    
    $.extend( conf, c );
};

var parse = function(m_oApvList, m_addComment){
    init(m_oApvList);
    oComments = parseDivision(apvlist, m_addComment);
}

var comment = function(){
    return oComments;
}

var render = function(o){
    var oData = o !== undefined ? o : oComments;
    var oTpl = $('.tpl-apv-comment').clone();
    var tplDynamic = $('.tpl-dynamic', oTpl).parent().html().replace(/&lt;/g, '<').replace(/&gt;/g, '>'); //row
    oTpl.find(' .tpl-dynamic').remove(); //header
    var tplFixed = oTpl.html().replace(/&lt;/g, '<').replace(/&gt;/g, '>');
    
    // 기안부서
    var htmlFixed = TemplateEngine(tplFixed, oData['CommentList']['general']);
    
    var htmlDynamic = '';
    var oDataItemS = oData['CommentList']['general']['data'];
    for(var i=oDataItemS.length-1; i>=0; i--){
        var oDataItem = oDataItemS[i];
        htmlDynamic += TemplateEngine(tplDynamic, oDataItem);
    }

    var oFixed = $(htmlFixed).appendTo($(conf.CommentListId));
    $('.tpl-dynamic-container', oFixed).html(htmlDynamic);
    
    
    // 수신부서
    var htmlDynamic = '';
    for(var i=0; i< oData.CommentListRec.length; i++){
	    var htmlFixed = TemplateEngine(tplFixed, oData['CommentListRec'][i]);
	    
	    var oDataItemS = oData['CommentListRec'][i]['data'];
	    for(var j=oDataItemS.length-1; j>=0; j--){
	        var oDataItem = oDataItemS[j];
	        htmlDynamic += TemplateEngine(tplDynamic, oDataItem);
	    }
	
	    var oFixed = $(htmlFixed).appendTo($(conf.CommentListId));
    }
    if (oData.CommentListRec.length > 0){ $('.tpl-dynamic-container', oFixed).html(htmlDynamic); }
    //template
    //data
    //TemplateEngine()
};


//=====
var getGeneralComment = function($$_comment){

var ret = [];

if($$_comment.length == 0){
  if (false == conf.isViewComment) {
    if(src_mode != "COMPLETE" || $(m_oCMT).find("Table").length === 0) {
      Comment.comment = 'no-comment'; //등록된 의견이 없습니다
      ret.push(Comment);
    }
  }
} else {
  $$_comment.concat().each(function (i, elm) {
	var comment =  Base64.b64_to_utf8(elm.text()).replaceAll("<", "&lt;").replaceAll(">", "&gt;");
	if(comment != ""){
	    var Comment = getCommentObj();
	    var sCommentTR ="";
	    //var comment = elm.text();
	    var _ouname = elm.parent().parent().attr("name");
	    if (elm.parent().parent().parent().has("role").length > 0 && elm.attr("reservename") != undefined ){
	    	_ouname = elm.attr("reservename");
	    }
	    
	    Comment.type = Common.getDic("lbl_apv_appCom"); // 결재문서의견
	    Comment.person = getDic(_ouname) + "("+ getApvResult(elm.parent().attr("result"), elm.parent().attr("kind"), elm.parent().attr("status")) +  ")";
	    Comment.personId = elm.parent().parent().attr("code");
	
	    var sTimezoneDate = "";
	    
	    
	    if(elm.parent().attr("datecompleted") == null) {
	      if(elm.attr("datecommented") != null) sTimezoneDate = elm.attr("datecommented");	      
	    } else { 
	      if(elm.parent().attr("datecompleted") != null) sTimezoneDate = elm.parent().attr("datecompleted");	      
	    }	    
	    elm.parent().attr("daterejectedto") && ( sTimezoneDate = elm.parent().attr("daterejectedto") );	    
	    Comment.date = docs.formatDate(sTimezoneDate, 'CMT');
	    
	    var rejectedtoFileInfo = elm.parent().parent().parent().parent().parent().find("step > ou > person > taskinfo[result='rejectedto'][daterejectedto='" + elm.parent().attr("daterejectedto") + "'] > comment_fileinfo, step > ou > role > taskinfo[result='rejectedto'][daterejectedto='" + elm.parent().attr("daterejectedto") + "'] > comment_fileinfo").concat();

	    if(elm.parent().find("comment_fileinfo").length > 0 || (rejectedtoFileInfo.length > 0 && (elm.parent().attr("status") == "inactive" || elm.parent().attr("status") == "pending"))) {
	    	if(elm.parent().find("comment_fileinfo").length > 0) {
		    	g_commentAttachList.push(elm.parent().find("comment_fileinfo").json());
		    	
		    	Comment.comment_fileinfo = elm.parent().find("comment_fileinfo").json();
	    	} else {
		    	g_commentAttachList.push(rejectedtoFileInfo.json());
		    	
		    	Comment.comment_fileinfo = rejectedtoFileInfo.json();
	    	}
		    
	    	var fileInfoHtml = "<table style=\"width: 100%;\">";
	    	fileInfoHtml += "<tr style=\"height: 43px;\"><td style=\"border-left: none;border-right: none;border-top: none;\">" + replaceLinefeed(comment) + "</td></tr>";
	    	fileInfoHtml += "	<tr style=\"height: 43px;\">";
	    	fileInfoHtml += "		<td style=\"border-left: none;border-right: none;border-bottom: none;text-indent: -7px;\">";
	    	
	    	$(Comment.comment_fileinfo).each(function (i, obj) {
	    		var fileExt = obj.name.substr(obj.name.lastIndexOf(".")+1);
		    	var className = setFileIconClass(fileExt);
		    
		    	fileInfoHtml += "			<dl class='excelData comment_fileinfo'><dt>";
				fileInfoHtml += "				<a href='javascript:void(0);' onclick='attachFileDownLoadCall_comment(\"" + obj.id + "\", \"" + obj.savedname + "\", \"" + obj.FileToken + "\");' >";
				fileInfoHtml += "					<span class='" + className + "'>" +Common.getDic("btn_apv_attachfile") + "</span>" + obj.name; // 파일첨부
				fileInfoHtml += "				</a></dt>";
				
				if (CFN_GetQueryString("listpreview") != "Y") {
					fileInfoHtml += "<dd>";
					fileInfoHtml += "<a class='previewBtn fRight' href='javascript:void(0);' onclick='attachFilePreview(\"" + obj.id + "\",\"" + obj.FileToken + "\",\"" + fileExt + "\");'>" + Common.getDic("lbl_preview") + "</a>";
					fileInfoHtml += "</dd>";
				}
				fileInfoHtml += "</dl>";
	    	});
	    	fileInfoHtml += "		</td>";
	    	fileInfoHtml += "	</tr>";
	    	fileInfoHtml += "</table>";

	    	Comment.comment = fileInfoHtml;
	    	Comment.td_style = "padding: 0px";
	    }
	    else {
	    	g_commentAttachList.push({});
	    	
	    	Comment.comment_fileinfo = [];
	    	Comment.comment = replaceLinefeed(comment);
	    }
	    ret.push(Comment);
	}
  });
}

return ret;
}

var getApvResult = function(apv_result, apv_kind, apv_status){
	var returnStr = "";

	switch(apv_result){
		case "completed": returnStr = Common.getDic("lbl_apv_Approved");			//승인
			break;
		case "agreed" : returnStr = Common.getDic("lbl_apv_agree");				//동의
			break;
		case "rejected": returnStr = Common.getDic("lbl_apv_reject");				//반려
			break;
		case "disagreed": returnStr = Common.getDic("lbl_apv_disagree");			//거부
			break;
		case "reserved": returnStr = Common.getDic("lbl_apv_hold");				//보류
			break;
		case "rejectedto": returnStr = Common.getDic("lbl_apv_rejectedto");		//지정반려
			break;
		case "substituted": returnStr = Common.getDic("lbl_apv_substitue");  		//[2019-05-08 ADD] gbhwang 대결 시 결과값 누락 처리
		   break;
		default:
			if(apv_kind == "review") {
				returnStr = Common.getDic("lbl_apv_Confirm");		//후결
			}
			if(apv_kind == "normal") { // inactive or pending 인데 의견이 있는 경우 지정반려
				returnStr = Common.getDic("lbl_apv_rejectedto");	//지정반려
			}
			if(apv_kind == "authorize") { 
				returnStr = Common.getDic("lbl_apv_authorize");	// 전결
			}
			break;
	}
	
	return returnStr;
}

//추가의견 
var getAdditionalComment =  function(m_oApvList, m_oCMT){
	var ret = [];
	var lastCommentSeq = -1;
	var processID = typeof formJson != 'undefined' ? getInfo("ProcessInfo.ProcessID") : opener.getInfo("ProcessInfo.ProcessID");
	
	$(m_oCMT).each(function (i, elm) {
	  var CommentSub = getCommentObj();
	  var jsonerObj = {"addComment" : elm};
	  var username = $$(jsonerObj).find("addComment").attr('UserName');
	  var prefix = '', suffix='';
	  if(username.indexOf("@") > -1){
	    prefix = getDic(username.split("@")[0]);
	    suffix = getDic(username.split("@")[1]);
	  } else {
	    prefix = getDic(username);
	    suffix = "&nbsp;";
	  }
	  
	  var divisionType = $$(m_oApvList).find("division").has("taskinfo[status='pending']").attr("divisiontype");
	
	  var kind = $$(jsonerObj).find("addComment").attr('Kind');
	  var mode = $$(jsonerObj).find("addComment").attr('Mode'); // 이관문서 mode값 추가

	  var tempname = "";
	  if(kind == "rejectedtodept") {
		  tempname = "("+Common.getDic("lbl_apv_setschema_scRJTODept")+")"; //부서내반송
		  CommentSub.type = Common.getDic("_Approval_DeptRjtCmt"); //부서내반송 의견 
	  } else if(kind == "redraftwithdraw") {
		  tempname = "("+Common.getDic("_Approval_RedraftWithdraw")+")"; //재기안회수
		  CommentSub.type = Common.getDic("_Approval_redraftwithdrawCmt"); //재기안회수 의견
	  } else if(kind == "lastCCcmtAdd") {
		  tempname = "("+Common.getDic("_Approval_Reference")+")"; //참조
		  CommentSub.type = Common.getDic("_Approval_ReferenceCmt"); //참조의견
		  divisionType = $$(m_oApvList).find("ccinfo").concat().attr("belongto") == "sender" ? "send" : "receive";
	  } else if(kind == "StoreSend") {		// 20230525 이관문서 의견 이관용, 프로젝트 별로 커스텀
		  CommentSub.divisionType = "send";	// send(기안부서)
		  CommentSub.type = Common.getDic("lbl_apv_Approval_comment"); // 결재의견

		  if(mode == "Draft") { // 기안
			tempname = "("+Common.getDic("lbl_apv_Draft")+")";
		  } else if (mode == "Approval") { // 승인
			tempname = "("+Common.getDic("lbl_apv_Approved")+")";
		  } else if (mode == "Reject") { // 반려
			tempname = "("+Common.getDic("lbl_apv_reject")+")";
		  } else if (mode == "Agree") { // 협조
			tempname = "("+Common.getDic("lbl_apv_reject_consent")+")";
		  } else {
			tempname = "("+Common.getDic("lbl_apv_Approved")+")";
		  }     
		  ret.push(CommentSub);	
	  } else if(kind == "StoreReceive") {
		  CommentSub.divisionType = "receive";  // receive(수신부서)
		  CommentSub.type = Common.getDic("lbl_apv_Approval_comment"); // 결재의견

		  if(mode == "Draft") {
			tempname = "("+Common.getDic("lbl_apv_Draft")+")";
		  } else if (mode == "Approval") {
			tempname = "("+Common.getDic("lbl_apv_Approved")+")";
		  } else if (mode == "Reject") {
			tempname = "("+Common.getDic("lbl_apv_reject")+")";
		  } else if (mode == "Agree") {
			tempname = "("+Common.getDic("lbl_apv_reject_consent")+")";
		  } else {
			tempname = "("+Common.getDic("lbl_apv_Approved")+")";
		  }
		  ret.push(CommentSub);
	  } else {
		  tempname = "("+Common.getDic("lbl_Add")+")"; //추가
		  CommentSub.type = Common.getDic("_Approval_AddCmt"); //추가의견
	  }
	  var newname = prefix + tempname;
	  //var newid = "";											// TODO 추가의견 person ID 세팅 필요
	  var insertdate = $$(jsonerObj).find("addComment").attr('InsertDate').substr(0, 19);
	  var commenttext = $$(jsonerObj).find("addComment").attr('Comment');
	  CommentSub.person = newname;
	  CommentSub.date = docs.formatDate(insertdate, 'CMT');

	  if($$(jsonerObj).find("addComment").attr('Comment_fileinfo').length > 0) {
		  CommentSub.comment_fileinfo = $$(jsonerObj).find("addComment").attr('Comment_fileinfo');
		  g_commentAttachList.push(CommentSub.comment_fileinfo);
	  } else {
		  CommentSub.comment_fileinfo = [];
		  g_commentAttachList.push({});  
	  }
	  CommentSub.personId = $$(jsonerObj).find("addComment").attr('UserCode');
	  
	  //추가 의견 첨부파일 미리보기 표시
	  var fileInfoHtml = "<table style=\"width: 100%;\">";
	  	  fileInfoHtml += "<tr style=\"height: 43px;\"><td style=\"border-left: none;border-right: none;border-top: none;\">" +commenttext.replaceAll("<", "&lt;").replaceAll(">", "&gt;").replace(/\n/g,"<br />")+ "</td></tr>";
		  fileInfoHtml += "	<tr style=\"height: 43px;\">";
	   	  fileInfoHtml += "		<td style=\"border-left: none;border-right: none;border-bottom: none;text-indent: -7px;\">";
	    	
	    $(CommentSub.comment_fileinfo).each(function (i, obj) {
	    	var fileExt = obj.name.substr(obj.name.lastIndexOf(".")+1);
		   	var className = setFileIconClass(fileExt);
		    
		   	fileInfoHtml += "			<dl class='excelData comment_fileinfo'><dt>";
			fileInfoHtml += "				<a href='javascript:void(0);' onclick='attachFileDownLoadCall_comment(\"" + obj.id + "\", \"" + obj.savedname + "\", \"" + obj.FileToken + "\");' >";
			fileInfoHtml += "					<span class='" + className + "'>" +Common.getDic("btn_apv_attachfile") + "</span>" + obj.name; // 파일첨부
			fileInfoHtml += "				</a></dt>";
				
			if (CFN_GetQueryString("listpreview") != "Y") {
				fileInfoHtml += "<dd>";
				fileInfoHtml += "<a class='previewBtn fRight' href='javascript:void(0);' onclick='attachFilePreview(\"" + obj.id + "\",\"" + obj.FileToken + "\",\"" + fileExt + "\");'>" + Common.getDic("lbl_preview") + "</a>";
				fileInfoHtml += "</dd>";
			}
			fileInfoHtml += "</dl>";
	    });
	    fileInfoHtml += "		</td>";
	    fileInfoHtml += "	</tr>";
	    fileInfoHtml += "</table>";

	    CommentSub.comment = fileInfoHtml;
	  
	  if(kind == "rejectedtodept" || kind == "redraftwithdraw") {
		  if(conf.src_mode == "REDRAFT" && processID == $$(jsonerObj).find("addComment").attr('ProcessID')) {
			  CommentSub.divisionType = divisionType;
			  if(lastCommentSeq > -1) {
				  ret[lastCommentSeq] = CommentSub;
			  } else {
				  lastCommentSeq = ret.length;
				  ret.push(CommentSub);
			  }
		  }
	  } else if (kind == "lastCCcmtAdd"){
		  CommentSub.divisionType = divisionType;
		  ret.push(CommentSub);
	  } else {
		  if((processID == $$(jsonerObj).find("addComment").attr('ProcessID') 
				  || $$(m_oApvList).find("steps > division[processID='" + $$(jsonerObj).find("addComment").attr('ProcessID') + "']").length > 0)
				  && $$(m_oApvList).find("steps > division[processID='" + $$(jsonerObj).find("addComment").attr('ProcessID') + "']").attr('divisiontype')=='send' ) {
			  CommentSub.divisionType = "send";
			  ret.push(CommentSub);
		  }else if((processID == $$(jsonerObj).find("addComment").attr('ProcessID') 
				  || $$(m_oApvList).find("steps > division[processID='" + $$(jsonerObj).find("addComment").attr('ProcessID') + "']").length > 0)
				  && $$(m_oApvList).find("steps > division[processID='" + $$(jsonerObj).find("addComment").attr('ProcessID') + "']").attr('divisiontype')=='receive' ) {
			  CommentSub.divisionType = "receive";
			  ret.push(CommentSub);
		  }
	  }
	});
	
	return ret; //추가 의견 배열
}

//피드백 의견
var getFeedbackComment =  function(m_oCMT){
var ret = [];
var fbRows = [];
var FBComments = getCommentTableObj();


$$(m_oCMT).find("Table").concat().each(function (i, elm) {
 
  var FBComment = getCommentObj();
  var username = elm.find("[USER_NAME]").attr('USER_NAME');
  var insertdate = elm.find("[INSERT_DATE]").attr('INSERT_DATE');
  var commenttext = elm.find("[COMMENT]").attr('COMMENT');
  
  FBComment.type = getDic(username.split("@")[1]);
  FBComment.person = getDic(username.split("@")[0]);
  FBComment.date = docs.formatDate(insertdate, 'CMT');
  FBComment.comment = replaceLinefeed(commenttext);
  FBComment.personId = '';			// TODO person ID 세팅 필요
  fbRows.push(FBComment);
});

FBComments.title = "Feedback "+docs.gLabel_comment;
FBComments.data = fbRows;

return FBComments; //피드백 의견 테이블 배열
}

//결재의견 파싱
var parseDivision = function(m_oApvList, m_addComment){
	var m_oCMT;
	var CommentLists = {
	  CommentList: {
	    general: null,
	    feedback: null
	  },
	  CommentListRec: []
	};
	
	g_commentAttachList = [];
	$$(m_oApvList).find("division").concat().each(function (div, elmdiv) {			//steps > 
	  var Comments = getCommentTableObj();            
	  var CommentRows = [];
	  var sCommentTemp ="", //역순으로 출력
	      m_oCMT = "",
	      isViewComment = ('' != conf.extcmt);
	
	  //코멘트 개체
	  // 지정반려 의견 표시하지 않도록 수정함.
	  //var $$_comment = elmdiv.find("step > ou > person > taskinfo > comment").concat();		//[visible!='n']
	  var $$_comment = elmdiv.find("step > ou > person > taskinfo[visible!='n'] > comment, step > ou > role > taskinfo[visible!='n'] > comment").concat();		//[visible!='n']
	  var generalComments = getGeneralComment($$_comment);
	  
	  CommentRows = CommentRows.concat(generalComments);
	  //CommentRows = generalComments;
	
	  if (div == 0){
	    /*if((conf.src_mode == "COMPLETE" || isViewComment ) && conf.extcmt != undefined) {       
	      m_oCMT = JSON.parse(conf.extcmt);
	      var AComments = getAdditionalComment(m_oCMT);
	      CommentRows = CommentRows.concat(AComments);
	    }*/
	    Comments.title = Common.getDic("lbl_DraftDept"); //기안부서
	    Comments.data = CommentRows;
	    CommentLists.CommentList.general = Comments;
	
	    if((conf.src_mode == "COMPLETE" && conf.feedback == "1") && conf.feedback != undefined){
	      m_oCMT =  JSON.parse(conf.feedbackcmt);
	      CommentLists.CommentList.feedback = getFeedbackComment(m_oCMT);
	    }
	
	  } else {
	    Comments.title = Common.getDic("lbl_apv_Acceptdept"); //수신부서
	    Comments.data = CommentRows;
	    CommentLists.CommentListRec.push(Comments);
	  }
	});
	
	// 추가의견
	//if(conf.src_mode == "COMPLETE" && typeof(m_addComment) != "undefined") {
	if(typeof(m_addComment) != "undefined") {
		m_oCMT = JSON.parse(m_addComment);
		var AComments = getAdditionalComment(m_oApvList, m_oCMT);
		$.each(AComments, function(k,v) {
			if(v.divisionType == "send") {
				CommentLists.CommentList.general.data.push(v);
			} else {
				if(CommentLists.CommentListRec.length == 0) {
					var Comments = getCommentTableObj();
					Comments.title = Common.getDic("lbl_apv_Acceptdept");
				    Comments.data = [];
				    CommentLists.CommentListRec.push(Comments);
				}
				
				CommentLists.CommentListRec[0].data.push(v);
			}
		});
	}
	
	return CommentLists;
};

//---- 공통함수 : start ----
function getCommentObj(){
return {
  type: '',
  person:'',
  date:'',
  comment: '',
  personId:''
};
}

function getCommentTableObj(){
return {
  title: '',
  data: []
};
}

function replaceLinefeed(s){
return s.replace(/\n/g, '<br />');
}

function TemplateEngine(html, options) {
    var re = /<%(.+?)%>/g,
        reExp = /(^( )?(var|if|for|else|switch|case|break|{|}|;))(.*)?/g,
        cursor = 0,
        result,
        match;
       	
    if(location.href.indexOf("/account/") > 0) {
    	re = /@@{(.+?)}/g;
    }
	var rHtml = [];
    var add = function(line, js) {
		if(js){
			if(!line.match(reExp)){
				rHtml.push(options[line] != undefined ? options[line] : "");	
			}
		}else{
			if(line != ''){
				rHtml.push(line);
			}
		}
      	return add;
    }
    while(match = re.exec(html)) {
      add(html.slice(cursor, match.index))(match[1], true);
      cursor = match.index + match[0].length;
    }
    add(html.substr(cursor, html.length - cursor));
    try {
		result = rHtml.join(""); 
	}
    catch(err) { 
		coviCmn.traceLog("'" + err.message + "'", " in \n\nCode:\n", code, "\n"); 
	}
    return result;
}

//---- common function : end ----

	return {
		parse: parse,
		comment : comment,
		render: render
	};

}());

//탭 구조일 경우 처리
var _func = $;
if($("#tab").css("display") != "none" && $(".l-contents-tabs").css("display") != undefined && $(".l-contents-tabs").css("display") != "none") {
	_func = accountCtrl.getInfoStr;
}

/* 결재선 HTML */
function drawFormApvLinesAll(apvLines){
	// 그려진 결재선 초기화
	_func("div#divFormApvLines").html("");
	
	// 문서 내 결재선 사용
	if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
		$('#ReceiveLine').hide();
		$('#CCLine').hide();
		if (document.getElementById("APVLIST").value != JSON.stringify(m_oApvList)) {
			m_oApvList = JSON.parse(document.getElementById("APVLIST").value);
		}
		addInApvLine.drawFormAppLine();
	} else {
		
		var tempFrozen = _func("script#frozen").html();
		_func("div#divFormApvLines").html(tempFrozen);
			
		var useTable = $$(apvLines).find(">useTable");
		
		$$(useTable).concat().each(function(i, obj){
			var objParamData= $$(apvLines).find("tables>"+$$(obj).json());
			
			if($$(obj).json() == "AppLine")
			{
				_func("#FormApvLines").show();
				_func("td#AppLine").show();
				drawFormAppLine(objParamData);
				drawFormAuditLine($$(apvLines).find("tables>AuditLine"), $$(obj).json(), "AuditAppLine"); // 감사,준법 결재선
			}else if($$(obj).json() == "LApvLine" || $$(obj).json() == "RApvLine")		//좌측 및 우측 결재선
			{
				_func("#FormApvLines").show();
				_func("td#"+$$(obj).json()).show();
				drawFormApvLine(objParamData, $$(obj).json());
				drawFormAuditLine($$(apvLines).find("tables>AuditLine"), $$(obj).json(), "AuditRApvLine"); // 감사,준법 결재선
			}else if($$(obj).json() == "AppLineListType")								//리스트 타입 결재선
			{
				_func("div#AppLineListType").show();
				drawFormAppLineListType(objParamData);
			}else if($$(obj).json() == "AssistLine")									//합의 결재선
			{
				_func("div#AssistLine").show();
				drawFormAssistLine(objParamData);
			}
			
			if(getInfo("SchemaContext.scDistribution.isUse")=="Y" && chkDivRec()) {//문서유통사용 and 수신부서 진행시 결재선 표시
				$('#docInfoTB').css('margin-top','10px');
			}			
			else if(getInfo("SchemaContext.scDistribution.isUse")=="Y" && getInfo("ExtInfo.UseEditYN") != "Y") {
				//form > strApvLineTempl hide
				$("#FormApvLines").hide();
				$("td#AppLine").hide();
				$("td#"+$$(obj).json()).hide();
				$("div#AppLineListType").hide();
				$("div#AssistLine").hide();
				
				//headnaem hide
				$("#headname").hide();
				
				//form > header hide
				$("#tblFormSubject").hide();
				$("#tblDistDocProperties").hide();
				$("#ReceiveLine").hide();
				$("#CCLine").hide();
				$("#tblFormSubject").hide();
				$("#DistReceiveLine").hide();
			}else if (getInfo("ExtInfo.UseWebHWPEditYN") == "Y") {
				$("#FormApvLines").hide();
				$("td#AppLine").hide();
				$("td#"+$$(obj).json()).hide();
				$("div#AppLineListType").hide();
				$("div#AssistLine").hide();
			} else if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_HWP_MULTI") {
				$("#FormApvLines").hide();
				$("td#AppLine").hide();
				$("td#"+$$(obj).json()).hide();
				$("div#AppLineListType").hide();
				$("div#AssistLine").hide();
			}
		});
	}
	
	if(location.href.indexOf("/account/") > 0) {
		var oApvList = m_oApvList;
	    displayCCInfo($$(oApvList));
	    if (_func("#RecLine") != null) { _func("#RecLine").html(initRecList()); }
	}
	
	// 양식프로세스 > 결재유형옵션 > 문서유통 == Y && 양식 > 양식본문정보 > 한글웹기안기 == Y
    if (getInfo("ExtInfo.UseWebHWPEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y") {
    	if (HwpCtrl) {
    		drawApvLineHWP();
    	}
    }
}

function drawFormAppLine(apvLines){
	var htmlArea = _func("table#FormApvLines").find("td#AppLine");
	var apvLineHTML = $(htmlArea).html();
	
	// 테이블 개수만큼 반복
	$$(apvLines).concat().each(function(i, obj){
		
		if($(htmlArea).find("table").attr("id") == undefined)
		{
			$(htmlArea).find("table").attr("id", "tableAppLine"+(i+1));
		}else				// 테이블이 여러개일 경우
		{
			$(htmlArea).append(apvLineHTML);
			$(htmlArea).find("table").last().attr("id", "tableAppLine"+(i+1));
			_func("table#tableAppLine"+(i+1)).addClass("mt10");
		}
		
		var apvlineTable = _func("table#tableAppLine"+(i+1));
		
		//$(apvlineTable).find("colgroup").append("<col style='width:*;'>");
		
		// tableTitle 입력
		$(apvlineTable).find("tbody").append("<tr><th id='AppLineTitle'></th></tr>");
		
		// tableTitle 글자 사이에 <br> 태그 넣기
		var strTableTitle = $$(obj).attr("tableTitle");
		var tempTitle = "";
		
		for(var i=0; i < strTableTitle.length; i++){
			if(i < (strTableTitle.length - 1))
				tempTitle += strTableTitle.charAt(i) + "<br>";
			else
				tempTitle += strTableTitle.charAt(i);
		}
		
		$(apvlineTable).find("#AppLineTitle").html(tempTitle);
		
		// usedItem 에 지정된 item만 그려주기
		var usedItem = $$(obj).attr("usedItem");
		var lineData =  $$(obj).find("lineData").concat();
		
		// lineData 수만큼 table colgroup
		for(var i=0; i<lineData.length; i++)
			$(apvlineTable).find("colgroup").append("<col style='width:88px;'>");
		// lineData 수만큼 table width
		$(apvlineTable).css("width", lineData.length*88 + 30);
		
		// usedItem 수만큼 tableTitle rowspan
		$(apvlineTable).find("#AppLineTitle").attr("rowspan", usedItem.length);
		
		$(usedItem).each(function(i, strItem){
			var strTD = "";
			if(strItem == "signImage"){					// 서명일 경우 별도의 css class
				$$(lineData).concat().each(function(i, lineDataObj){
					// 대성, 선결재 시에는 디폴트 이미지 표시되지 않음.
					if($$(lineDataObj).attr(strItem).indexOf("nosign") > -1) {
						strTD += "<td>";
						strTD += "";
						strTD += "</td>";
					}
					else {
						strTD += "<td class='signArea'>";
						if($$(lineDataObj).attr(strItem).indexOf("http://") > -1 || $$(lineDataObj).attr(strItem).indexOf("https://") > -1)
							strTD += "<img style='max-width: 100%; height: 55px;' src='"+$$(lineDataObj).attr(strItem)+"' alt=''>";
						else
							strTD += $$(lineDataObj).attr(strItem);
						//의견표시
						var commentstr = $$(lineDataObj).find("comment").attr("#text");
						if(typeof commentstr != "undefined" && commentstr != null && commentstr != ""){
							var comment = Base64.b64_to_utf8($$(lineDataObj).find("comment").attr("#text"));
							strTD += '<a class="comment tooltips" href="javascript:void(0);" style="position:absolute; right:1px; bottom:3px;" title="'+comment+'"><span>'+comment+'</span></a>';
						}
						strTD += "</td>";
					}
				});
			}else if(strItem == "signState"){
				$$(lineData).concat().each(function(i, lineDataObj){
					if($$(lineDataObj).attr(strItem)!="&nbsp;" && $$(lineDataObj).attr(strItem)!="" && $$(lineDataObj).attr("code")!="" && $$(lineDataObj).attr("code")!="&nbsp;"){
						strTD += "<td style='overflow: visible;'>";
						strTD += setUserFlowerName($$(lineDataObj).attr("code"), $$(lineDataObj).attr(strItem));	
					}else{
						strTD += "<td>";
						strTD += $$(lineDataObj).attr(strItem);
					}
					strTD += "</td>";
				});
			}else{
				$$(lineData).concat().each(function(i, lineDataObj){
					strTD += "<td>";
					strTD += $$(lineDataObj).attr(strItem);
					strTD += "</td>";
				});
			}
						
			if(i == 0){											// 첫번째의 item은 tableTitle와 같이 보여주기
				$(apvlineTable).find("#AppLineTitle").after(strTD);
			}else{
				$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
			}
		});
		
	});
}

// 왼쪽 오른쪽 결재선
function drawFormApvLine(apvLines, alignType){
	var htmlArea = _func("table#FormApvLines").find("td#"+alignType);
	var apvLineHTML = $(htmlArea).html();
	
	// 왼쪽 및 오른쪽 테이블 개수만큼 반복
	$$(apvLines).concat().each(function(i, obj){
		
		if($(htmlArea).find("table").attr("id") == undefined)
		{
			$(htmlArea).find("table").attr("id", "table"+alignType+(i+1));
		}else				// 왼쪽 및 오른쪽 테이블이 여러개일 경우
		{
			$(htmlArea).append(apvLineHTML);
			$(htmlArea).find("table").last().attr("id", "table"+alignType+(i+1));
			_func("table#table"+alignType+(i+1)).addClass("mt10");
		}
		
		var apvlineTable = _func("table#table"+alignType+(i+1));
		
		//$(apvlineTable).find("colgroup").append("<col style='width:*;'>");
		
		// tableTitle 입력
		$(apvlineTable).find("tbody").append("<tr><th id='"+alignType+"Title'></th></tr>");
		
		// tableTitle 글자 사이에 <br> 태그 넣기
		var strTableTitle = $$(obj).attr("tableTitle");
		var tempTitle = "";
		
		for(var i=0; i < strTableTitle.length; i++){
			if(i < (strTableTitle.length - 1))
				tempTitle += strTableTitle.charAt(i) + "<br>";
			else
				tempTitle += strTableTitle.charAt(i);
		}
		
		$(apvlineTable).find("#"+alignType+"Title").html(tempTitle);
		
		// usedItem 에 지정된 item만 그려주기
		var usedItem = $$(obj).attr("usedItem");
		var lineData =  $$(obj).find("lineData").concat();
		
		// lineData 수만큼 table colgroup
		for(var i=0; i<lineData.length; i++)
			$(apvlineTable).find("colgroup").append("<col style='width:88px;'>");
		// lineData 수만큼 table width
		$(apvlineTable).css("width", lineData.length*88 + 30);
		
		// usedItem 수만큼 tableTitle rowspan
		$(apvlineTable).find("#"+alignType+"Title").attr("rowspan", usedItem.length);
		
		$(usedItem).each(function(i, strItem){
			var strTD = "";
			if(strItem == "signImage"){				// 서명일 경우 별도의 css class
				$$(lineData).concat().each(function(i, lineDataObj){
					// 대성, 선결재 시에는 디폴트 이미지 표시되지 않음.
					if($$(lineDataObj).attr(strItem).indexOf("autoapprove") > -1) {
						strTD += "<td>";
						strTD += "";
						strTD += "</td>";
					}
					else {
						strTD += "<td class='signArea'>";
						if($$(lineDataObj).attr(strItem).indexOf("http://") > -1 || $$(lineDataObj).attr(strItem).indexOf("https://") > -1)
							strTD += "<img style='max-width: 100%; height: 55px;' src='"+$$(lineDataObj).attr(strItem)+"' alt=''>";
						else
							strTD += $$(lineDataObj).attr(strItem);
						//의견표시
						var commentstr = $$(lineDataObj).find("comment").attr("#text");
						if(typeof commentstr != "undefined" && commentstr != null && commentstr != ""){
							var comment = Base64.b64_to_utf8($$(lineDataObj).find("comment").attr("#text"));
							strTD += '<a class="comment tooltips" href="javascript:void(0);" style="position:absolute; right:1px; bottom:3px;" title="'+comment+'"><span>'+comment+'</span></a>';
						}
						strTD += "</td>";
					}
				});
			}else if(strItem == "signState"){
				$$(lineData).concat().each(function(i, lineDataObj){
					if($$(lineDataObj).attr(strItem)!="&nbsp;"  && $$(lineDataObj).attr(strItem)!=""  && $$(lineDataObj).attr("code")!='' && $$(lineDataObj).attr("code")!="&nbsp;"){
						strTD += "<td style='overflow: visible;'>";
						strTD += setUserFlowerName($$(lineDataObj).attr("code"), $$(lineDataObj).attr(strItem));	
					}else{
						strTD += "<td>";
						strTD += $$(lineDataObj).attr(strItem);
					}
					strTD += "</td>";
				});
			}else{
				$$(lineData).concat().each(function(i, lineDataObj){
					strTD += "<td>";
					strTD += $$(lineDataObj).attr(strItem);
					strTD += "</td>";
				});
			}
			if(i == 0){											// 첫번째의 item은 tableTitle와 같이 보여주기
				$(apvlineTable).find("#"+alignType+"Title").after(strTD);
			}else{
				$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
			}
		});
		
	});
}

// 감사,준법
function drawFormAuditLine(auditLines, sPosition, sTarget){
	if(sPosition == "AppLine" || sPosition == "RApvLine"){
		if($$(auditLines).concat().length > 0){
			var sWidht = "";
			if(sPosition == "AppLine") sWidht = "calc(100% - 130px)";
			else if(sPosition == "RApvLine") sWidht = "calc(50% - 130px)";
			
			var htmlArea = _func("table#FormApvLines").find("td#"+sTarget);
			var apvLineHTML = $(htmlArea).html();
				
			_func("table#FormApvLines").find("td#"+sPosition).css("width",sWidht);
			htmlArea.show();
			
			// 테이블 개수만큼 반복
			$$(auditLines).concat().each(function(i, obj){
				
				if($(htmlArea).find("table").attr("id") == undefined)
				{
					$(htmlArea).find("table").attr("id", "table"+sTarget+(i+1));
				}else				// 테이블이 여러개일 경우
				{
					$(htmlArea).append(apvLineHTML);
					$(htmlArea).find("table").last().attr("id", "table"+sTarget+(i+1));
					_func("table#table"+sTarget+(i+1)).addClass("mt10");
				}
				
				var apvlineTable = _func("table#table"+sTarget+(i+1));
				
				//$(apvlineTable).find("colgroup").append("<col style='width:*;'>");
				
				// tableTitle 입력
				$(apvlineTable).find("tbody").append("<tr><th id='"+sTarget+"Title'></th></tr>");
				
				// tableTitle 글자 사이에 <br> 태그 넣기
				var strTableTitle = $$(obj).attr("tableTitle");
				var tempTitle = "";
				
				for(var i=0; i < strTableTitle.length; i++){
					if(i < (strTableTitle.length - 1))
						tempTitle += strTableTitle.charAt(i) + "<br>";
					else
						tempTitle += strTableTitle.charAt(i);
				}
				
				$(apvlineTable).find("#"+sTarget+"Title").html(tempTitle);
				
				// usedItem 에 지정된 item만 그려주기
				var usedItem = $$(obj).attr("usedItem");
				var lineData =  $$(obj).find("lineData").concat();
				
				// lineData 수만큼 table colgroup
				for(var i=0; i<lineData.length; i++)
					$(apvlineTable).find("colgroup").append("<col style='width:88px;'>");
				// lineData 수만큼 table width
				$(apvlineTable).css("width", lineData.length*88 + 30);
				
				// usedItem 수만큼 tableTitle rowspan
				$(apvlineTable).find("#"+sTarget+"Title").attr("rowspan", usedItem.length);
				
				$(usedItem).each(function(i, strItem){
					var strTD = "";
					if(strItem == "signImage")						// 서명일 경우 별도의 css class
						$$(lineData).concat().each(function(i, lineDataObj){
							// 대성, 선결재 시에는 디폴트 이미지 표시되지 않음.
							if($$(lineDataObj).attr(strItem).indexOf("autoapprove") > -1) {
								strTD += "<td>";
								strTD += "";
								strTD += "</td>";
							}
							else {
								strTD += "<td class='signArea'>";
								if($$(lineDataObj).attr(strItem).indexOf("http://") > -1 || $$(lineDataObj).attr(strItem).indexOf("https://") > -1)
									strTD += "<img style='max-width: 100%; height: 55px;' src='"+$$(lineDataObj).attr(strItem)+"' alt=''>";
								else
									strTD += $$(lineDataObj).attr(strItem);
								//의견표시
								var commentstr = $$(lineDataObj).find("comment").attr("#text");
								if(typeof commentstr != "undefined" && commentstr != null && commentstr != ""){
									var comment = Base64.b64_to_utf8($$(lineDataObj).find("comment").attr("#text"));
									strTD += '<a class="comment tooltips" href="javascript:void(0);" style="position:absolute; right:1px; bottom:3px;" title="'+comment+'"><span>'+comment+'</span></a>';
								}
								strTD += "</td>";
							}
						});
					else
						$$(lineData).concat().each(function(i, lineDataObj){
							strTD += "<td>";
							strTD += $$(lineDataObj).attr(strItem);
							strTD += "</td>";
						});
								
					if(i == 0){											// 첫번째의 item은 tableTitle와 같이 보여주기
						$(apvlineTable).find("#"+sTarget+"Title").after(strTD);
					}else{
						$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
					}
				});
				
			});
		}
	}
}

// 리스트 타입의 결재선
function drawFormAppLineListType(apvLines){
	var htmlArea = _func("div#AppLineListType");
	var appLineListTypeHTML = _func("div#AppLineListType").html();
	
	$$(apvLines).concat().each(function(i, obj){
		
		if($(htmlArea).find("div").attr("id") == undefined)
		{
			$(htmlArea).find("div").attr("id", "AppLineListType"+(i+1));
		}else				// 테이블이 여러개일 경우
		{
			$(htmlArea).append(appLineListTypeHTML);
			$(htmlArea).find("div").last().attr("id", "AppLineListType"+(i+1));
		}
		
		_func("div#AppLineListType"+(i+1)).find("span#tableTitle").html($$(obj).attr("tableTitle"));
		var apvlineTable = _func("div#AppLineListType"+(i+1)).find("table");
		var usedItem = $$(obj).find("usedItem");
		var lineData =  $$(obj).find("lineData").concat();
		
		// usedItem 수만큼 table colgroup
		for(var i=0; i<usedItem.length; i++){
			if(i < usedItem.length-1)
				$(apvlineTable).find("colgroup").append("<col style='width:15%'>");
			else
				$(apvlineTable).find("colgroup").append("<col style='width:*'>");
		}
		
		$(apvlineTable).find("colgroup").after("<thead><tr></tr></thead>");
		
		$$(usedItem).concat().each(function(i, strItem){
			var strTH = "";
			strTH = $$(obj).find("tableHeader").attr(strItem.json());
			
			$(apvlineTable).find("thead>tr").append("<th>" +strTH+ "</th>");
		});
		
		$(apvlineTable).append("<tbody></tbody>");
		
		$$(lineData).each(function(i, lineDataObj){
			var strTD = "";
			
			var innerApvListLength = $$(lineDataObj).find("innerApvList").concat().length;
			if(innerApvListLength > 0){
				var innerApvList = $$(lineDataObj).find("innerApvList");
				
				// 부서 합의 내부 결재선이 있을 경우
				$$(innerApvList).concat().each(function(i, innerApvListObj){
					strTD = "";
					if(i == 0){
						strTD += "<td rowspan='"+innerApvListLength+"'>";
						strTD += $$(lineDataObj).attr("apvKind");
						strTD += "</td>";
					}
					$$(usedItem).concat().each(function(j, strItem){
						var innerApvListObjVal = $$(innerApvListObj).attr(strItem.json());
						
						if(strItem.json() != "apvKind"){
							if(strItem.json() == "comment" && innerApvListObjVal != "&nbsp;" && innerApvListObjVal.indexOf("<a><img") < 0){
								strTD += "<td>";
								strTD += Base64.b64_to_utf8(innerApvListObjVal);			// 의견 데이터 decoding
								strTD += "</td>";
							}else if(strItem.json()=="name"){
								if(innerApvListObjVal!="" && innerApvListObjVal!="&nbsp;" && $$(innerApvListObj).attr("code")!="&nbsp;" && $$(innerApvListObj).attr("code")!=""){
									strTD += "<td style='overflow: visible;'>";
									strTD += setUserFlowerName($$(innerApvListObj).attr("code"), innerApvListObjVal);	
								}else{
									strTD += "<td>";
									strTD += innerApvListObjVal;
								}
								strTD += "</td>";
							}else{
								strTD += "<td>";
								strTD += innerApvListObjVal;
								strTD += "</td>";
							}
						}
					});
					$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
				});
			}
			// 부서 및 사용자 합의만 있을 경우 (내부 결재선이 없을 경우)
			else{
				$$(usedItem).concat().each(function(i, strItem){
					var lineDataObjVal = $$(lineDataObj).attr(strItem.json());
					if(strItem.json() == "comment" && lineDataObjVal != "&nbsp;" && lineDataObjVal.indexOf("<a><img") < 0){
						strTD += "<td>";
						strTD += Base64.b64_to_utf8(lineDataObjVal);			// 의견 데이터 decoding
						strTD += "</td>";
					}else if(strItem.json()=="name"){
						if(lineDataObjVal!="&nbsp;" && lineDataObjVal!="" && $$(lineDataObj).attr("code")!="" && $$(lineDataObj).attr("code")!="&nbsp;"){
							strTD += "<td style='overflow: visible;'>";
							strTD += setUserFlowerName($$(lineDataObj).attr("code"), lineDataObjVal);	
						}else{
							strTD += "<td>";
							strTD += lineDataObjVal;
						}
						strTD += "</td>";
					}else{
						strTD += "<td>";
						strTD += lineDataObjVal;
						strTD += "</td>";
					}
				});
				$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
			}
		});
	});
}

// 합의자
function drawFormAssistLine(apvLines){
	var htmlArea = _func("div#AssistLine");
	var appLineListTypeHTML = _func("div#AssistLine").html();
	
	$$(apvLines).concat().each(function(i, obj){
		
		if($(htmlArea).find("div").attr("id") == undefined)
		{
			$(htmlArea).find("div").attr("id", "AssistLine"+(i+1));
		}else				// 테이블이 여러개일 경우
		{
			$(htmlArea).append(appLineListTypeHTML);
			$(htmlArea).find("div").last().attr("id", "AssistLine"+(i+1));
		}
		
		var apvlineTable = _func("div#AssistLine"+(i+1)).find("table");
		var usedItem = $$(obj).find("usedItem");
		var lineData =  $$(obj).find("lineData").concat();
		
		// usedItem 수만큼 table colgroup
		for(var i=0; i<usedItem.length; i++){
			if(i < usedItem.length-1)
				$(apvlineTable).find("colgroup").append("<col style='width:15%'>");
			else
				$(apvlineTable).find("colgroup").append("<col style='width:*'>");
		}
		
		$(apvlineTable).find("colgroup").after("<thead><tr></tr></thead>");
		
		$$(usedItem).concat().each(function(i, strItem){
			var strTH = "";
			strTH = $$(obj).find("tableHeader").attr(strItem.json());
			
			$(apvlineTable).find("thead>tr").append("<th>" +strTH+ "</th>");
		});
		
		$(apvlineTable).append("<tbody></tbody>");
		
		$$(lineData).each(function(i, lineDataObj){
			var strTD = "";
			
			var innerApvListLength = $$(lineDataObj).find("innerApvList").concat().length;
			if(innerApvListLength > 0){
				var innerApvList = $$(lineDataObj).find("innerApvList");
				
				// 부서 합의 내부 결재선이 있을 경우
				$$(innerApvList).concat().each(function(i, innerApvListObj){
					strTD = "";
					if(i == 0){
						strTD += "<td rowspan='"+innerApvListLength+"'>";
						strTD += $$(lineDataObj).attr("type");
						strTD += "</td>";
						strTD += "<td rowspan='"+innerApvListLength+"'>";
						strTD += $$(lineDataObj).attr("dept");
						strTD += "</td>";
					}
					$$(usedItem).concat().each(function(i, strItem){
						var innerApvListObjVal = $$(innerApvListObj).attr(strItem.json());
						if(strItem.json() != "dept" && strItem.json() != "type"){
							if(strItem.json() == "comment" && innerApvListObjVal != "&nbsp;"){
								strTD += "<td>";
								strTD += Base64.b64_to_utf8(innerApvListObjVal);			// 의견 데이터 decoding
								strTD += "</td>";
							}else if(strItem.json()=="name"){
								if(innerApvListObjVal!="" && innerApvListObjVal!="&nbsp;" && $$(innerApvListObj).attr("code")!="&nbsp;" && $$(innerApvListObj).attr("code")!=""){
									strTD += "<td style='overflow: visible;'>";
									strTD += setUserFlowerName($$(innerApvListObj).attr("code"), innerApvListObjVal);	
								}else{
									strTD += "<td>";
									strTD += innerApvListObjVal;
								}
								strTD += "</td>";
							}else{
								strTD += "<td>";
								strTD += innerApvListObjVal;
								strTD += "</td>";
							}
						}
					});
					$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
				});
			}
			// 부서 및 사용자 합의만 있을 경우 (내부 결재선이 없을 경우)
			else{
				$$(usedItem).concat().each(function(i, strItem){
					var lineDataObjVal = $$(lineDataObj).attr(strItem.json());
					if(strItem.json() == "comment" && lineDataObjVal != "&nbsp;"){
						strTD += "<td>";
						strTD += Base64.b64_to_utf8(lineDataObjVal);			// 의견 데이터 decoding
						strTD += "</td>";
					}else if(strItem.json()=="name"){
						if(lineDataObjVal!="&nbsp;" && lineDataObjVal!="" && $$(lineDataObj).attr("code")!="" && $$(lineDataObj).attr("code")!="&nbsp;"){
							strTD += "<td style='overflow: visible;'>";
							strTD += setUserFlowerName($$(lineDataObj).attr("code"), lineDataObjVal);	
						}else{
							strTD += "<td>";
							strTD += lineDataObjVal;
						}
						strTD += "</td>";
					}else{
						strTD += "<td>";
						strTD += lineDataObjVal;
						strTD += "</td>";
					}
				});
				$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
			}
		});
	});
}


//******************** 양식 파일 내 결재선 함수 정리 끝 *******************************************************************************************************************************************/
//***********************************************************************************************************************************************************************************************/


//***********************************************************************************************************************************************************************************************/
//******************** 문서 안 결재선 함수 정리 시작 *****************************************************************************************************************************************/
if (!window.addInApvLine) {
    window.addInApvLine = {};
}

(function(window) {
	const addInApvLine = {
		_ENUM_TYPE: Object.freeze({ APV : 'Apv', REC: 'Rec', BCC: 'BCC', CC: 'CC' }), // 타입 결재(Apv)/수신(Rec)/사전참조(BCC)/참조(CC), Object.freeze를 사용해서 중간에 값이 변경되지 않도록함
		_DupDataCnt: 0, // 중복 건수
		_UpdateDataCnt: 0, // 업데이트 된 건수
		_AutoSearchText: '', // 자동완성 검색어
		_AutoSearchTextObj: null, // 검색 Input
		_AutoSearchPanelObj: null, // 자동완성 검색 결과 영역
		_AutoSearchType: '', // 자동완성 검색타입 결재(Apv)/수신(Rec)/사전참조(BCC)/참조(CC)
		_AutoSearchTimer: null, // 자동완성검색용 타이머
		_AutoSearchSelectedIdx: 0, // 자동완성검색용 선택한 index
		_UserApvTypeOption: '', // 사용자 결재유형 selectbox option 문자열
		_GroupApvTypeOption: '', // 부서 결재유형 selectbox option 문자열
		_EtcLineMoveBeforeObj: {
			type: ''
			, code: ''
			, idx: 0
		}, // 수신/사전참조/참조 이동 전 object
		_AppLineAttribute: {
			apvtype: ''
			, stepName: ''
		    , routetype: ''
		    , allottype: ''
		    , unittype: ''
		    , taskinforesult: ''
		    , taskinfokind: ''
		    , useAuthorize: 'N' // 전결 사용여부
		}, // 결재선 속성
		
		// 결재 유형 selectbox option 생성
		setApvTypeOption: function() {
			const apvKindUsage = Common.getBaseConfig("ApvKindUsage"); // 전결,결재안함,후결,후열 (결재선관리 select박스표시여부)
			addInApvLine._UserApvTypeOption = `<option value="approve-normal">${Common.getDic("lbl_apv_normalapprove")}</option>`; // 결재
			if (apvKindUsage.split(';')[0] == '1') addInApvLine._UserApvTypeOption += `<option value="approve-authorize">${Common.getDic("lbl_apv_normalapprove")}-${Common.getDic("lbl_apv_authorize")}</option>`; // 결재-전결
			if (apvKindUsage.split(';')[2] == '1') addInApvLine._UserApvTypeOption += `<option value="approve-review">${Common.getDic("lbl_apv_normalapprove")}-${Common.getDic("lbl_apv_review")}</option>`; // 결재-후결
			if (getInfo('SchemaContext.scPCoo.isUse') == 'Y') addInApvLine._UserApvTypeOption += `<option value="assist-serial">${Common.getDic("lbl_apv_assist")}</option>`; // 개인협조(순차)
			if (getInfo('SchemaContext.scPCooPL.isUse') == 'Y') addInApvLine._UserApvTypeOption += `<option value="assist-parallel">${Common.getDic("lbl_apv_assist_2")}</option>`; // 개인협조(병렬)
			if (getInfo('SchemaContext.scPAgrSEQ.isUse') == 'Y') addInApvLine._UserApvTypeOption += `<option value="consult-serial">${Common.getDic("lbl_apv_consent")}</option>`; // 개인합의(순차)
			if (getInfo('SchemaContext.scPAgr.isUse') == 'Y') addInApvLine._UserApvTypeOption += `<option value="consult-parallel">${Common.getDic("btn_apv_consultors_2")}</option>`; // 개인합의(병렬)
			
			if (getInfo('SchemaContext.scDCoo.isUse') == 'Y') addInApvLine._GroupApvTypeOption += `<option value="assist-serial">${Common.getDic("lbl_apv_DeptAssist")}</option>`; // 부서협조(순차)
			if (getInfo('SchemaContext.scDCooPL.isUse') == 'Y') addInApvLine._GroupApvTypeOption += `<option value="assist-parallel">${Common.getDic("lbl_apv_DeptAssist2")}</option>`; // 부서협조(병렬)
			if (getInfo('SchemaContext.scDAgrSEQ.isUse') == 'Y') addInApvLine._GroupApvTypeOption += `<option value="consult-serial">${Common.getDic("lbl_apv_DeptConsent")}</option>`; // 부서합의(순차)
			if (getInfo('SchemaContext.scDAgr.isUse') == 'Y') addInApvLine._GroupApvTypeOption += `<option value="consult-parallel">${Common.getDic("lbl_apv_DeptConsent2")}</option>`; // 부서합의(병렬)
		},
		
		// 초기화
		setInit: function() {
			if (getInfo("Request.mode") == 'TEMPSAVE' || getInfo("Request.mode") == 'DRAFT') {
				// 내 결재선 가져오기
				addInApvLine.getPrivateDomainList();
				
				// 결재선 버튼 기능 show
				document.querySelector('div.approver_info').querySelector('h3.apptit_h3').style.display = '';
			}
			
			// 배포(수신처) 사용여부에 따라 숨김해제처리
			if (getInfo('SchemaContext.scIPub.isUse') == 'Y') {
				document.querySelector(`tr.tr_${addInApvLine._ENUM_TYPE.REC}`).style.display = '';
			}
			
			// 사전참조 사용여부에 따라 숨김해제처리
			if (getInfo('SchemaContext.scBeforCcinfo.isUse') == 'Y') {
				document.querySelector(`tr.tr_${addInApvLine._ENUM_TYPE.BCC}`).style.display = '';
			}
			
			// 참조 사용여부에 따라 숨김해제처리
			if (getInfo('SchemaContext.scCC.isUse') == 'Y') {
				document.querySelector(`tr.tr_${addInApvLine._ENUM_TYPE.CC}`).style.display = '';
			}
			
			// 결재 타입 selectbox option
			addInApvLine.setApvTypeOption();
			
			// 검색컨트롤 세팅
			document.querySelectorAll('input[name="txtAddInAutoSearch"]').forEach((txt) => {
				// text box focus in => 선택 style
				txt.addEventListener('focusin', function() {
					// 선택한 타입 저장
					addInApvLine._AutoSearchType = this.dataset.type;
					addInApvLine._AutoSearchTextObj = this;
					addInApvLine._AutoSearchPanelObj = document.querySelector(`div.org_search_user.${addInApvLine._AutoSearchType}`);
					
					// 검색 input class active 제거
					document.querySelectorAll('div.search_org').forEach((div) => { div.classList.remove('active'); });
					
					// 선택한 input class active 추가
					this.closest('div.search_org').classList.toggle('active');
				});
	
				// text box focus out => 검색영역 닫기
				txt.addEventListener('focusout', function() {
					// 검색 input class active 제거
					this.closest('div.search_org').classList.remove('active');
					
					// 자동완성 결과 영역 hide
					addInApvLine.setAutoSearchPanelClose();
					
					// 선택한 타입 제거
					addInApvLine._AutoSearchText = '';
					addInApvLine._AutoSearchTextObj = null;
					addInApvLine._AutoSearchPanelObj = null;
					addInApvLine._AutoSearchType = '';
					addInApvLine._AutoSearchTimer = null;
				});
				
				// tab/backspace/방향키 입력 시 처리
				txt.addEventListener('keydown', function(e) {
					// tab 입력 시 처리
					if ($.trim(addInApvLine._AutoSearchText) != '' && e.keyCode === 9) {
						// 검색 영역이 열려있는 경우 (검색된 데이터가 있는 경우) 선택된(.selected) 행 선택
						if ($(addInApvLine._AutoSearchPanelObj).is(':visible') && addInApvLine._AutoSearchPanelObj.querySelector('ul > li.selected') != null) {
							addInApvLine._AutoSearchText = '';
							addInApvLine.setAutoSearchResultSelect(addInApvLine._AutoSearchPanelObj.querySelector('ul > li.selected'));
						}
						return false;
					}
					
					// backspace 입력 시 처리
					if ($.trim(this.value) == '' && e.keyCode === 8) {
						// 수신, 사전참조, 참조에서 아무값이 없을 때 백 스페이스 클릭 시 바로 앞에 있는 이미 등록된 정보 제거
						if (addInApvLine._AutoSearchType != addInApvLine._ENUM_TYPE.APV) {
							const liList = document.querySelectorAll(`ul.org_select_user.${addInApvLine._AutoSearchType} > li.li_move`);
							const li = liList[liList.length - 1];
							if (li != null) {
								addInApvLine.removeEtcLine(li);
							}
						}
						return false;
					}
					
					// 방향키 입력 시 처리
					if ($(addInApvLine._AutoSearchPanelObj).is(':visible') && (e.keyCode === 38 || e.keyCode === 98 || e.keyCode === 40 || e.keyCode === 104)) {
						const searchLastIdx = addInApvLine._AutoSearchPanelObj.querySelectorAll('ul > li').length - 1; // 결과 총 건수
						let num = 0;
						
						// 위로
						if (e.keyCode === 38 || e.keyCode === 98) {
							if (addInApvLine._AutoSearchSelectedIdx == 0) { num = searchLastIdx; }
							else { num--; }
						} else { // 아래로
							if (addInApvLine._AutoSearchSelectedIdx == searchLastIdx) { num = -searchLastIdx; }
							else { num++; }
						}
						
						// 기존 선택된 영역 해제
						if (addInApvLine._AutoSearchPanelObj.querySelector('ul > li.selected') != null) {
							addInApvLine._AutoSearchPanelObj.querySelectorAll('ul > li')[addInApvLine._AutoSearchSelectedIdx].classList.remove('selected');
							addInApvLine._AutoSearchSelectedIdx = addInApvLine._AutoSearchSelectedIdx + num;
						}
						
						// 선택한 영역 class 추가
						addInApvLine._AutoSearchPanelObj.querySelectorAll('ul > li')[addInApvLine._AutoSearchSelectedIdx].classList.toggle('selected');
						
						// 스크롤 조작
						const positionH = $(addInApvLine._AutoSearchPanelObj.querySelector('ul > li.selected')).position().top; // 선택된 li 현재 위치
						const liHeight = addInApvLine._AutoSearchPanelObj.querySelector('ul > li.selected').clientHeight; // li 객체 높이
						
						if (addInApvLine._AutoSearchSelectedIdx == 0) {
							// 선택한 li가 최 상단일때는 스크롤 가장 위로 옮김
							addInApvLine._AutoSearchPanelObj.scrollTop = 0;
						} else if (addInApvLine._AutoSearchSelectedIdx == searchLastIdx) {
							// 선택한 li가 최 하단일때는 스크롤 가장 아래로 옮김
							addInApvLine._AutoSearchPanelObj.scrollTop = addInApvLine._AutoSearchPanelObj.scrollHeight - addInApvLine._AutoSearchPanelObj.clientHeight; // div 영역 스크롤 높이
						} else if (positionH > 60) {
							// 선택한 li가 스크롤 영역 아래로 내려간 경우 스크롤을 li 높이만큼 더한다. (스크롤을 아래로 내림)
							addInApvLine._AutoSearchPanelObj.scrollTop = addInApvLine._AutoSearchPanelObj.scrollTop + liHeight;
						} else if (positionH < 0) {
							// 선택한 li가 스크롤 영역 위로 올라간 경우 스크롤을 li 높이만큼 뺀다. (단, 가장 하단에 갔다가 올라간 경우 정확히 li 높이만큼 계산이 안되어져있을수 있으므로 추가적으로 계산해준다.)
							addInApvLine._AutoSearchPanelObj.scrollTop = addInApvLine._AutoSearchPanelObj.scrollTop - liHeight + (liHeight + positionH);
						}
						return false;
					}
				});
				
				// 자동완성 검색
				txt.addEventListener('keyup', function(e) {
					// enter 입력 시 처리
					if ($.trim(addInApvLine._AutoSearchText) != '' && e.keyCode === 13) {
						// 검색 영역이 열려있는 경우 (검색된 데이터가 있는 경우) 선택된(.selected) 행 선택
						if ($(addInApvLine._AutoSearchPanelObj).is(':visible') && addInApvLine._AutoSearchPanelObj.querySelector('ul > li.selected') != null) {
							addInApvLine._AutoSearchText = '';
							addInApvLine.setAutoSearchResultSelect(addInApvLine._AutoSearchPanelObj.querySelector('ul > li.selected'));
						}
						return false;
					}
					
					// 방향키 처럼 입력값이 없는 키 입력시 중복 검색 방지
					if (addInApvLine._AutoSearchText == this.value) { return false; }
					
					// 전역변수에 검색어 입력
					addInApvLine._AutoSearchText = $.trim(this.value);
					
					// 검색어는 2자이상
					if (addInApvLine._AutoSearchText.length >= 2) {
						// 키 입력할때마다 ajax 타지 않고 키 입력을 잠시 멈췄을때 마지막 한번만 ajax 태우기 위해 timer 사용 (debouncing) 
						if (addInApvLine._AutoSearchTimer) {
							clearTimeout(addInApvLine._AutoSearchTimer);
						}
						// 키 입력 후 0.3초 뒤에 검색
						addInApvLine._AutoSearchTimer = setTimeout(() => {
							addInApvLine.getAutoSearch();
						}, 300);
    				} else if (addInApvLine._AutoSearchText.length < 2) {
						addInApvLine.setAutoSearchPanelClose();
					}
				});
			});
		},
		
		// 자동완성검색 영역 클리어
		setAutoSearchPanelClose: function() {
			if (addInApvLine._AutoSearchPanelObj) {
				if (!addInApvLine._AutoSearchPanelObj.classList.contains('hide')) addInApvLine._AutoSearchPanelObj.classList.toggle('hide');
				addInApvLine._AutoSearchPanelObj.querySelector('ul').innerHTML = '';
			}
		},
		
		// 자동완성 검색
		getAutoSearch: function() {
			// 검색어가 없거나 2자 미만이면 검색하지 않는다.
			if ($.trim(addInApvLine._AutoSearchText) == '' || $.trim(addInApvLine._AutoSearchText).length < 2) return;

			// 이전 결과 제거
			addInApvLine.setAutoSearchPanelClose();
			
			// 검색옵션
			var searchType = (addInApvLine._AutoSearchType == addInApvLine._ENUM_TYPE.APV ? 'user' : '' );
			
			// 참조사용 개인/부서 체크
			// 앞 : 부서참조  뒤 :개인참조
			if(addInApvLine._AutoSearchType == addInApvLine._ENUM_TYPE.CC){
				// 개인참조만 사용
				if(getInfo('SchemaContext.scCC.value') == 'YN') searchType = 'user';
				// 부서참조만 사용
				if(getInfo('SchemaContext.scCC.value') == 'NY') searchType = 'group';
			}
			
			$.ajax({
				type: 'POST',
				url: 'apvline/getAddInLineAutoSearch.do',
				data: { 'searchText': addInApvLine._AutoSearchText,
						'searchType': searchType
						}, // 결재자는 사용자만 조회, 수신/사전참조/참조는 부서도 조회
				success: function(data) {
					let html = '';
					const regexAllCase = new RegExp(addInApvLine._AutoSearchText.replace(/\\/gi, ''), 'gi'); // 결과값에 검색어와 동일한 텍스트가 있는 경우 highlight 표시용 정규식
					const highLight = `<strong class="keyword">${addInApvLine._AutoSearchText}</strong>`; // highlight style
					
					if (data.result == 'ok') {
						// 검색 결과 있음
						if (data.list.length > 0) {
							data.list.forEach((item) => {
								const dn = CFN_GetDicInfo(item.DN).replace(regexAllCase, highLight);
								const podn = CFN_GetDicInfo(item.PO.split(';')[1]).replace(regexAllCase, highLight);
								const rgdn = CFN_GetDicInfo(item.RGNM).replace(regexAllCase, highLight);
								const em = item.EM.replace(regexAllCase, highLight);
								const type = item.itemType;
								const json = escape(JSON.stringify(item));
								
								if (type == 'user') {
									html += `
									<li data-json="${json}">
										<span>${dn}</span> <span>${podn}</span> <span>${rgdn}</span> <span>${em}</span>
									</li>`;
								} else {
									html += `
									<li data-json="${json}">
										<span></span> <span></span> <span>${dn}</span> <span>${em}</span>
									</li>`;
								}
							});
						}
						
						// 검색 결과 있음
						if (html != '') {
							// 검색 데이터 삽입
							addInApvLine._AutoSearchPanelObj.classList.remove('hide');
							addInApvLine._AutoSearchPanelObj.querySelector('ul').insertAdjacentHTML('afterbegin', html);
							addInApvLine._AutoSearchPanelObj.scrollTop = 0;
							
							// li에 클릭 이벤트 추가
							addInApvLine._AutoSearchPanelObj.querySelectorAll('ul > li').forEach((li, i) => {
								// 최 상단 결과 선택
								if (i == 0) {
									addInApvLine._AutoSearchSelectedIdx = 0;
									li.classList.toggle('selected');
								}
								
								// 마우스 오버시 기존 선택된 li class 제거 후 over한 li에 class 추가
								li.addEventListener('mouseover', function() {
									addInApvLine._AutoSearchPanelObj.querySelectorAll('ul > li').forEach((li) => { li.classList.remove('selected'); });
									addInApvLine._AutoSearchSelectedIdx = 0;
									this.classList.toggle('selected');
								});
								
								// 아무스 아웃시 li class 제거
								li.addEventListener('mouseout', function() {
									this.classList.remove('selected');
								});
								
								// textbox 에 focusout 이벤트가 할당되어 있어 click 이벤트가 안됨. (focusout이 우선시 됨) => mousedown 으로 처리
								li.addEventListener('mousedown', function() {
									// 자동완성 결과선택
									addInApvLine.setAutoSearchResultSelect(this);
								});
							});
						}
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("apvline/getAddInLineAutoSearch.do", response, status, error);
				}
			});
		},
		
		// 자동완성 결과 선택
		// obj : 선택한 검색결과영역 li 객체
		setAutoSearchResultSelect: function(obj) {
			const rtn = `{ "item" : [${unescape(obj.dataset.json)}] }`;
			
			// 검색타입에 따른 처리
			switch (addInApvLine._AutoSearchType) {
				case addInApvLine._ENUM_TYPE.APV: // 결재자 검색
					addInApvLine.addApvLine(rtn, true);
					break;
				case addInApvLine._ENUM_TYPE.REC: // 수신 검색
				case addInApvLine._ENUM_TYPE.BCC: // 사전참조 검색
				case addInApvLine._ENUM_TYPE.CC: // 참조 검색
					// 수신/사전참조/참조 세팅
					addInApvLine.addEtcLine(rtn, addInApvLine._AutoSearchType, true);
					break;
			}
			
			// 자동완성 결과 영역 hide
			addInApvLine.setAutoSearchPanelClose();
					
			// 검색어 삭제
			addInApvLine._AutoSearchTextObj.value = '';
		},
		
		// 결재자 라인 Sortable 설정
		setApvSortable: function(){
			// 결재선 설정
			$('ul.approver_list').sortable({
				// 드래그 앤 드롭 버튼
				handle: '.btn_move',
				// 움직일 목록
				items: $('ul.approver_list li:not(.sortable_fix)'),
				// 드래그 앤 드롭 단위 css 선택자
				connectWith: 'ul.approver_list',
				// 움직이지 못하는 css 선택자
				cancel: 'ul.approver_list .sortable_fix',
				// 부드러운 애니메이션 (boolean or number)
				revert: 100,
				update: function(e, ui) {
					// 순서 재 설정
					addInApvLine.setApvLineReOrder(true);
				}
			}).disableSelection();
		},

		// 수신/사전참조/참조 라인 Sortable 설정
		setEtcSortable: function() {
			// 수신/사전참조, 참조 설정
			$('ul.org_select_user').sortable({
				// 움직일 목록
				items: $('ul.org_select_user li:not(.sortable_fix)'),
				// 드래그 앤 드롭 단위 css 선택자
				connectWith : 'ul.org_select_user',
				// 이동시 마우스 위치
    			cursorAt: { left: 5 },
				// 부드러운 애니메이션 (boolean or number)
				revert: 100,
				placeholder: ' ', // 이동 가이드 라인
				start: function (e, ui) {
					// 이동 가이드 라인
		            ui.placeholder.width(ui.item.width());
		        },
		        update: function(e, ui) {
					const ul = ui.item.closest('ul')[0];
					const type = ul.classList.contains(addInApvLine._ENUM_TYPE.CC) ? addInApvLine._ENUM_TYPE.CC : (ul.classList.contains(addInApvLine._ENUM_TYPE.BCC) ? addInApvLine._ENUM_TYPE.BCC : addInApvLine._ENUM_TYPE.REC);
					
					// input tag 가 항상 가장 마지막에 있어야 한다.
					ul.appendChild(ul.querySelector('li.org_input'));
					
					// 같은 영역에서 자리 변경시에만 처리함. (수신/사전참조/참조 이동시에는 remove, receive에서 처리함) 
					if ($.trim(addInApvLine._EtcLineMoveBeforeObj.type) === type) {
						// 자리 변동 후 정렬 재 지정->사유: 이동 시 중복났을때 cancel 이벤트 적용이 되면서 각 ul 당 한번씩 cancel 이벤트가 일어나버려서 같은 라인에서 이동시킨것 까지 변경됨
						$('ul.org_select_user').sortable('destroy');
						addInApvLine.setEtcSortable();
					}
				},
				remove: function(e, ui) {
					// 이동 시킨 객체 표시
					ui.item[0].classList.toggle('moving');
				},
		        receive: function (e, ui) {
					const datereceived = JSON.parse(unescape(ui.item[0].dataset.json)).datereceived;
					
					// 중복체크 : 중복 체크시킨 객체는 비교 대상에서 제외 :not(.moving)
				    if (addInApvLine.getIsDup(ui.item[0].dataset.code, ui.item.closest('ul')[0].querySelectorAll('li.li_move:not(.moving)'))) {
						$('ul.org_select_user').sortable('cancel');
						Common.Warning(Common.getDic('msg_apv_forminappline_warning01')); // 이미 등록된 임직원/부서입니다.
					} else if (datereceived != undefined && datereceived != '') {
						$('ul.org_select_user').sortable('cancel');
						Common.Warning(Common.getDic('msg_apv_348')); // 이미 받은 문서는 삭제 할 수 없습니다.
					}
					
					// 중복 체크 완료 후 이동 시킨 표시 제거
					ui.item[0].classList.toggle('moving');
					
					// 자리 변동 후 정렬 재 지정->사유: 이동 시 중복났을때 cancel 이벤트 적용이 되면서 각 ul 당 한번씩 cancel 이벤트가 일어나버려서 같은 라인에서 이동시킨것 까지 변경됨
					$('ul.org_select_user').sortable('destroy');
					addInApvLine.setEtcSortable();
		        }
			}).disableSelection();
		},
		
		// 결재선 생성
		drawFormAppLine: function() {
			const division = m_oApvList.steps.division.length > 1 ? m_oApvList.steps.division[0] : m_oApvList.steps.division;
			if (division.divisiontype == 'send') {
				// 기존 결재라인 제거
				document.querySelector('ul.approver_list').querySelectorAll('li.li_apv').forEach((li, i) => {
					if (i > 0) {
						li.remove();
						document.querySelector('ul.al_symbol > li').remove();
					}
				});
				// 결재자 세팅
				let rtn = { 'item': [] };
				if (division.step.length) {
					division.step.forEach((step, i) => {
						if (i > 0) {
							if (step.ou.length) {
								// 병렬인 경우
								step.ou.forEach((ou) => {
									if (ou.person) {
										if (ou.person.length) {
											// 대결인 경우
											if (ou.person[0].taskinfo.kind == 'substitute') {
												const bypass = ou.person.filter(x => x.taskinfo.kind == 'bypass');
												rtn.item.push(addInApvLine.setMakeArrData('user', step, null, ou.person[0], bypass[0].name));
											} else if (ou.person[0].taskinfo.kind == 'conveyance') {
												// 전달인 경우
												const conveyance = ou.person.filter(x => x.taskinfo.result == 'pending' || (x.taskinfo.kind == 'normal' && x.taskinfo.result == 'completed'));
												rtn.item.push(addInApvLine.setMakeArrData('user', step, null, conveyance[0], ''));
											}
										} else {
											// 일반적인 결재
											rtn.item.push(addInApvLine.setMakeArrData('user', step, null, ou.person, ''));
								        }
								    } else {
										rtn.item.push(addInApvLine.setMakeArrData('group', step, ou, null, ''));
								    }
								});
							} else {
							    if (step.ou.person) {
									if (step.ou.person.length) {
										// 대결인 경우
										if (step.ou.person[0].taskinfo.kind == 'substitute') {
											const bypass = step.ou.person.filter(x => x.taskinfo.kind == 'bypass');
											rtn.item.push(addInApvLine.setMakeArrData('user', step, null, step.ou.person[0], bypass[0].name));
										} else if (step.ou.person[0].taskinfo.kind == 'conveyance') {
											// 전달인 경우
											const conveyance = step.ou.person.filter(x => x.taskinfo.result == 'pending' || (x.taskinfo.kind == 'normal' && x.taskinfo.result == 'completed'));
											rtn.item.push(addInApvLine.setMakeArrData('user', step, null, conveyance[0], ''));
										}
									} else {
										// 일반적인 결재
										rtn.item.push(addInApvLine.setMakeArrData('user', step, null, step.ou.person, ''));
							        }
							    } else {
									rtn.item.push(addInApvLine.setMakeArrData('group', step, step.ou, null, ''));
							    }
						    }
					    } else {
							document.querySelector('ul.approver_list > li').querySelector('td.al_name').innerText = CFN_GetDicInfo(step.ou.person.name);
							document.querySelector('ul.approver_list > li').querySelector('td.al_position').innerText = CFN_GetDicInfo(step.ou.person.position.substr(step.ou.person.position.indexOf(';') + 1, step.ou.person.position.length));
							document.querySelector('ul.approver_list > li').querySelector('td.al_dept').innerText = CFN_GetDicInfo(step.ou.name);
							
							// 기안자 기안일자 표시 
							if ($.trim(step.ou.person.taskinfo.datecompleted) != '') {
								document.querySelector('ul.approver_list > li').querySelector('td:last-child').innerText = new Date(step.ou.person.taskinfo.datecompleted.replace(/[.-]/gi, '/')).format('MM/dd HH:mm');
							}
						}
					});
					if (rtn.item.length != 0) {
						addInApvLine.addApvLine(JSON.stringify(rtn), false);
						
						// 결재타입 세팅
						let bNotApvType = false;
						document.querySelector('ul.approver_list').querySelectorAll('li.li_apv').forEach((li, i) => {
							if (i == 0) return;
							const idx = i - 1;
							if ($(li).find('select.myappr').is(':visible')) {
								const sel = $(li).find('select.myappr')[0];
								const val = rtn.item[idx].routetype == 'approve' ? `${rtn.item[idx].routetype}-${rtn.item[idx].taskinfo_kind}` : `${rtn.item[idx].routetype}-${rtn.item[idx].allottype}`;
								if ($(sel).find(`option[value="${val}"]`).length > 0) {
									$(sel).find(`option[value="${val}"]`).prop('selected', true);
								} else {
									bNotApvType = true;
									sel.querySelectorAll('option').forEach((opt) => { opt.remove(); });
								}
							}
						});
						
						if (bNotApvType) {
							Common.Warning(Common.getDic('msg_apv_forminappline_warning02')); // 문서내 결재선은 수신, 부서결재 및 감사, 결재자 참조, 결재자 확인, 사전참조를 사용할 수 없습니다. 삭제하시기 바랍니다.
						}
					}
				} else {
					// 기안자 세팅
					document.querySelector('ul.approver_list > li').querySelector('td.al_name').innerText = CFN_GetDicInfo(division.step.ou.person.name);
					document.querySelector('ul.approver_list > li').querySelector('td.al_position').innerText = CFN_GetDicInfo(division.step.ou.person.position.substr(division.step.ou.person.position.indexOf(';') + 1, division.step.ou.person.position.length));
					document.querySelector('ul.approver_list > li').querySelector('td.al_dept').innerText = CFN_GetDicInfo(division.step.ou.name);
				}
				
				// 수신 세팅
				if (getInfo('SchemaContext.scIPub.isUse') == 'Y') {
					rtn = { 'item': [] };
					document.querySelector(`ul.org_select_user.${addInApvLine._ENUM_TYPE.REC}`).querySelectorAll('li.li_move').forEach((li) => { li.remove(); });
					
					if ($.trim(document.getElementById('ReceiveNames').value) != '') {
						$.trim(document.getElementById('ReceiveNames').value).split(';').forEach((recinfo) => {
						    if (recinfo.split(':')[0] == '1') {
						        rtn.item.push({ 'itemType':'user', 'AN':recinfo.split(':')[1], 'DN': CFN_GetDicInfo(recinfo.split(':')[2].replace(/\^/gi, ';')), 'LV': '', 'TL': '', 'PO': '', 'RG': recinfo.split(':')[4], 'RGNM': recinfo.split(':')[4], 'ETID': '', 'ETNM': '', 'EM': '' });
						    } else {
						        rtn.item.push({ 'itemType':'group', 'AN':recinfo.split(':')[1], 'DN': CFN_GetDicInfo(recinfo.split(':')[2].replace(/\^/gi, ';')), 'RG': recinfo.split(':')[1], 'RGNM': CFN_GetDicInfo(recinfo.split(':')[2].replace(/\^/gi, ';')), 'ETID': '', 'ETNM': '', 'EM': '' });
						    }
						});
						if (rtn.item.length != 0) {
							addInApvLine.addEtcLine(JSON.stringify(rtn), addInApvLine._ENUM_TYPE.REC, false);
						}
					}
				}
				
				// 사전참조 세팅
				if (getInfo('SchemaContext.scBeforCcinfo.isUse') == 'Y') {
					rtn = { 'item': [] };
					document.querySelector(`ul.org_select_user.${addInApvLine._ENUM_TYPE.BCC}`).querySelectorAll('li.li_move').forEach((li) => { li.remove(); });
					
					if (m_oApvList.steps.ccinfo) {
						if (m_oApvList.steps.ccinfo.length) {
							m_oApvList.steps.ccinfo.forEach((ccinfo) => {
								if (ccinfo.beforecc != undefined && ccinfo.beforecc == 'y') {
								    if (ccinfo.ou.person) {
								        rtn.item.push({ 'itemType':'user', 'AN':ccinfo.ou.person.code, 'DN': ccinfo.ou.person.name, 'LV': '', 'TL': '', 'PO': '', 'RG': ccinfo.ou.person.oucode, 'RGNM': ccinfo.ou.person.ouname, 'ETID': '', 'ETNM': '', 'EM': '', 'beforecc': ccinfo.beforecc, 'datereceived': $.trim(ccinfo.datereceived) });
								    } else {
								        rtn.item.push({ 'itemType':'group', 'AN':ccinfo.ou.code, 'DN': ccinfo.ou.name, 'RG': ccinfo.ou.code, 'RGNM': ccinfo.ou.name, 'ETID': '', 'ETNM': '', 'EM': '', 'beforecc': ccinfo.beforecc, 'datereceived': $.trim(ccinfo.datereceived) });
								    }
							    }
							});
						} else {
							const ccinfo = m_oApvList.steps.ccinfo;
							if (ccinfo.beforecc != undefined && ccinfo.beforecc == 'y') {
								if (ccinfo.ou.person) {
							        rtn.item.push({ 'itemType':'user', 'AN':ccinfo.ou.person.code, 'DN': ccinfo.ou.person.name, 'LV': '', 'TL': '', 'PO': '', 'RG': ccinfo.ou.person.oucode, 'RGNM': ccinfo.ou.person.ouname, 'ETID': '', 'ETNM': '', 'EM': '', 'beforecc': ccinfo.beforecc, 'datereceived': $.trim(ccinfo.datereceived) });
							    } else {
							        rtn.item.push({ 'itemType':'group', 'AN':ccinfo.ou.code, 'DN': ccinfo.ou.name, 'RG': ccinfo.ou.code, 'RGNM': ccinfo.ou.name, 'ETID': '', 'ETNM': '', 'EM': '', 'beforecc': ccinfo.beforecc, 'datereceived': $.trim(ccinfo.datereceived) });
							    }
						    }
						}
						if (rtn.item.length != 0) {
							addInApvLine.addEtcLine(JSON.stringify(rtn), addInApvLine._ENUM_TYPE.BCC, false);
						}
					}
				}
				
				// 참조 세팅
				if (getInfo('SchemaContext.scCC.isUse') == 'Y') {
					rtn = { 'item': [] };
					document.querySelector(`ul.org_select_user.${addInApvLine._ENUM_TYPE.CC}`).querySelectorAll('li.li_move').forEach((li) => { li.remove(); });
					
					if (m_oApvList.steps.ccinfo) {
						if (m_oApvList.steps.ccinfo.length) {
							m_oApvList.steps.ccinfo.forEach((ccinfo) => {
								if (ccinfo.beforecc == undefined || ccinfo.beforecc != 'y') {
								    if (ccinfo.ou.person) {
								        rtn.item.push({ 'itemType':'user', 'AN':ccinfo.ou.person.code, 'DN': ccinfo.ou.person.name, 'LV': '', 'TL': '', 'PO': '', 'RG': ccinfo.ou.person.oucode, 'RGNM': ccinfo.ou.person.ouname, 'ETID': '', 'ETNM': '', 'EM': '', 'beforecc': '', 'datereceived': $.trim(ccinfo.datereceived) });
								    } else {
								        rtn.item.push({ 'itemType':'group', 'AN':ccinfo.ou.code, 'DN': ccinfo.ou.name, 'RG': ccinfo.ou.code, 'RGNM': ccinfo.ou.name, 'ETID': '', 'ETNM': '', 'EM': '', 'beforecc': '', 'datereceived': $.trim(ccinfo.datereceived) });
								    }
							    }
							});
						} else {
							const ccinfo = m_oApvList.steps.ccinfo;
							if (ccinfo.beforecc == undefined || ccinfo.beforecc != 'y') {
								if (ccinfo.ou.person) {
							        rtn.item.push({ 'itemType':'user', 'AN':ccinfo.ou.person.code, 'DN': ccinfo.ou.person.name, 'LV': '', 'TL': '', 'PO': '', 'RG': ccinfo.ou.person.oucode, 'RGNM': ccinfo.ou.person.ouname, 'ETID': '', 'ETNM': '', 'EM': '', 'beforecc': '', 'datereceived': $.trim(ccinfo.datereceived) });
							    } else {
							        rtn.item.push({ 'itemType':'group', 'AN':ccinfo.ou.code, 'DN': ccinfo.ou.name, 'RG': ccinfo.ou.code, 'RGNM': ccinfo.ou.name, 'ETID': '', 'ETNM': '', 'EM': '', 'beforecc': '', 'datereceived': $.trim(ccinfo.datereceived) });
							    }
						    }
						}
						if (rtn.item.length != 0) {
							addInApvLine.addEtcLine(JSON.stringify(rtn), addInApvLine._ENUM_TYPE.CC, false);
						}
					}
				}
			}
		},
		
		// 결재선 만들기 위해 필요값 배열로 반환
		// itemType : 타입 user/group
		// step : step 단위 obj
		// ou : 그룹 단위 obj
		// person : 사용자 단위 obj
		// byPassName : 대결 원 결재자 이름
		setMakeArrData: function(itemType, step, ou, person, byPassName) {
			let item = null;
			if (itemType == 'user') {
				item = { 'itemType': 'user'
			        , 'AN': person.code
			        , 'DN': person.name
			        , 'LV': ''
			        , 'TL': ''
			        , 'PO': $.trim(person.position)
			        , 'RG': person.oucode
			        , 'RGNM': person.ouname
			        , 'ETID': ''
			        , 'ETNM': ''
			        , 'EM': ''
			        , 'BP': byPassName
			        , 'date': $.trim(person.taskinfo.datecompleted)
			        , 'allottype': $.trim(step.allottype)
			        , 'routetype': $.trim(step.routetype)
			        , 'taskinfo_kind': $.trim(person.taskinfo.kind)
			        , 'taskinfo_result': $.trim(person.taskinfo.result) };
			} else {
				item = { 'itemType': 'group'
			        , 'AN': ou.code
			        , 'DN': ou.name
			        , 'RG': ou.code
			        , 'RGNM': ou.name
			        , 'ETID': ''
			        , 'ETNM': ''
			        , 'EM': ''
			        , 'date': $.trim(ou.taskinfo.datecompleted)
			        , 'allottype': $.trim(step.allottype)
			        , 'routetype': $.trim(step.routetype)
			        , 'taskinfo_kind': $.trim(ou.taskinfo.kind)
			        , 'taskinfo_result': $.trim(ou.taskinfo.result) };
			}
			return item;
		},
		
		// 결재자 생성
		// rtn : 조직도/자동완성에서 선택한 데이터
		// bChkDup : true-중복체크, false-중복체크하지않음
		addApvLine: function(rtn, bChkDup) {
			const dataObj = document.querySelector('ul.approver_list > li.input_li');
			const symbolObj = document.querySelector('ul.al_symbol > li');
			let html = '';
			
			JSON.parse(rtn).item.forEach((data) => {
				html = addInApvLine.templeteApvLine(data, bChkDup ? document.querySelectorAll('ul.approver_list > li.li_apv') : null);
				if (html != '') {
					dataObj.insertAdjacentHTML('beforebegin', html);
					// 결재선 앞 심볼 이미지 추가
					symbolObj.insertAdjacentHTML('afterend', '<li></li>');
				}
			});
			
			// 변경된 정보가 있으면 다시 Sortable
			if (bChkDup && addInApvLine._DupDataCnt > 0) {
				if (m_sApvMode != 'SUBREDRAFT' && getInfo('SchemaContext.scChkDuplicateApv.isUse') == 'Y') {
					Common.Confirm(Common.getDic('msg_apv_forminappline_confirm01'), 'Confirm', function(result) { // 동일한 임직원/부서가 있습니다. 추가하시겠습니까?
						if (result) {
							// Set Sortable
							addInApvLine.setApvSortable();
							// 순서 재 설정
							addInApvLine.setApvLineReOrder(bChkDup);
						} else {
							// 추가한 라인 제거
							dataObj.previousElementSibling.remove();
						}
					});
				} else {
					Common.Warning(Common.getDic('msg_apv_forminappline_warning03'), 'Warning', function() { // 동일한 임직원/부서가 있습니다.
						// 추가한 라인 제거
						dataObj.previousElementSibling.remove();
						// 결재선 앞 심볼 이미지 제거
						symbolObj.remove();
					});
				}
			} else if (addInApvLine._UpdateDataCnt > 0) {
				// Set Sortable
				addInApvLine.setApvSortable();
				// 순서 재 설정
				addInApvLine.setApvLineReOrder(bChkDup);
			}
			addInApvLine._DupDataCnt = 0;
			addInApvLine._UpdateDataCnt = 0;
		},
		
		// 결재자 삭제
		// obj : 삭제 버튼 클릭한 객체
		removeApvLine: function(obj) {
			// 결재선 삭제
			obj.closest('li').remove();
			// 결재선 앞 심볼 이미지 삭제
			document.querySelector('ul.al_symbol > li').remove();
			// 순서 재 설정
			addInApvLine.setApvLineReOrder(true);
		},
		
		// 결재자 순서 재 설정 및 결재 상태값 체크 (전결처리)
		// bSetAuthorize : 전결처리 여부 true-처리/false-미처리
		setApvLineReOrder: function(bSetAuthorize) {
			document.querySelectorAll('ul.approver_list > li.li_apv').forEach((li, idx) => {
			    let i = 0;
			    const prevLi = li.previousElementSibling;
			    if (prevLi != null && prevLi != undefined) {
				    if (idx > 1 && li.dataset.allottype == 'parallel' && prevLi.dataset.allottype == li.dataset.allottype && prevLi.dataset.routetype == li.dataset.routetype && prevLi.dataset.unittype == li.dataset.unittype) {
				        i =  prevLi.querySelector('td.al_num').innerText;
				    } else {
				        i =  Number(prevLi.querySelector('td.al_num').innerText) + 1;
				    }
				    li.querySelector('td.al_num').innerText = i;
			    }
			});
			
			if (bSetAuthorize) {
				let bSkipped = false;
				document.querySelectorAll('ul.approver_list > li.li_apv').forEach((li) => {
				    // 전결 처리 한 결재가 있는지 확인
				    if (li.dataset.unittype == 'person') {
						if (li.classList.contains('sortable_fix')) {
							// 결재완료 또는 대기중인 상태에서 전결이 있는지 확인
							if (!bSkipped && li.dataset.taskinfokind == 'authorize') {
								bSkipped = true;
							}
						} else {
							// 아직 결재 대기전 상태일때 전결이 있는지 확인
						    if (!bSkipped && li.dataset.taskinfokind == 'authorize') {
								bSkipped = true;
							} else if (!bSkipped && li.dataset.taskinfokind == 'skip') {
								// 전결이후 세팅되어 있다가 전결해제된 경우 처리
								li.querySelector('select.myappr').style.display = '';
								li.querySelector('span.skipped').style.display = 'none';
								li.querySelector('select.myappr').selectedIndex = 0;
								
								addInApvLine._AppLineAttribute.apvtype = li.querySelector('select.myappr > option').value;
								addInApvLine._AppLineAttribute.unittype = li.dataset.unittype;
								addInApvLine._AppLineAttribute.useAuthorize = 'N';
								addInApvLine.setLiAppAtt(li);
							} else if (bSkipped) {
								// 전결 처리 이후건들 처리
								li.querySelector('select.myappr').style.display = 'none';
								li.querySelector('span.skipped').style.display = '';
								li.querySelector('select.myappr').selectedIndex = 0;
								
								addInApvLine._AppLineAttribute.apvtype = li.querySelector('select.myappr > option').value;
								addInApvLine._AppLineAttribute.unittype = li.dataset.unittype;
								addInApvLine._AppLineAttribute.useAuthorize = 'Y';
								addInApvLine.setLiAppAtt(li);
							}
						}
					}
				});
			}
		},
		
		// 결재자 템플릿
		// data : 바인딩할 데이터
		// targetDataObj : 중복 체크 할 대상
		templeteApvLine: function(data, targetDataObj) {
			if (data == undefined || data == null || data == '') return '';
			
			const itemType = data.itemType;
			const code = data.AN;
			const name = itemType == 'user' ? CFN_GetDicInfo(data.DN) : '';
			const jobPositionName = itemType == 'user' && data.PO != '' ? CFN_GetDicInfo(data.PO.split(';')[1]) : '';
			const deptName = itemType == 'user' ? CFN_GetDicInfo(data.RGNM) : CFN_GetDicInfo(data.DN);
			const datecompleted = $.trim(data.date) != '' ? new Date(data.date.replace(/[.-]/gi, '/')).format('MM/dd HH:mm') : '';
			const unittype = itemType == 'user' ? 'person' : 'ou';
			const allottype = $.trim(data.allottype);
			const routetype = $.trim(data.routetype) == '' ? 'approve-normal' : data.routetype;
			const taskinfo_kind = $.trim(data.taskinfo_kind) == '' ? 'normal' : data.taskinfo_kind;
			const taskinfo_result = $.trim(data.taskinfo_result) == '' ? 'inactive' : data.taskinfo_result;
			const bypassName = $.trim(data.BP) == '' ? '' : ` / (${Common.getDic('lbl_apv_original')}) ${CFN_GetDicInfo(data.BP)}`;
			const json = escape(JSON.stringify(data));
			const sel = `<select class="myappr" data-unittype="${unittype}" style="width: auto; ${`${taskinfo_result}` == 'skipped' ? 'display: none' : ''}" onchange="addInApvLine.setApvLineApvType(this);">
							${`${itemType}` == 'user' ? `${addInApvLine._UserApvTypeOption}` : `${addInApvLine._GroupApvTypeOption}`}
						</select>`;
			let templete = '';
			let status = '';
			switch (taskinfo_result) {
				case 'pending':
					status = Common.getDic('lbl_apv_inactive');
					break;
				case 'substituted':
					status = Common.getDic('lbl_apv_substitue');
					break;
				case 'agreed':
					status = Common.getDic('lbl_apv_agree');
					break;
				case 'disagreed':
					status = Common.getDic('lbl_apv_disagree');
					break;
				case 'completed':
					status = Common.getDic('lbl_apv_Approved');
					break;
			}
			
			// 중복체크
			if (addInApvLine.getIsDup(code, targetDataObj)) addInApvLine._DupDataCnt++;
			templete = `
			<li class="${`${taskinfo_result}` == 'inactive' || `${taskinfo_result}` == 'skipped' ? 'li_move' : 'sortable_fix'} li_apv" data-code="${code}" data-json="${json}" data-unittype="${unittype}" data-allottype="${allottype}" data-routetype="${routetype}" data-taskinfokind="${taskinfo_kind}" data-taskinforesult="${taskinfo_result}">
				<table>
					<tbody>
						<tr>
							<td>${`${taskinfo_result}` == 'inactive' || `${taskinfo_result}` == 'skipped' ? '<a class="btn_move"></a>' : ''}</td>
							<td class="al_num"></td>
							<td class="al_status">
								${`${taskinfo_result}` == 'inactive' || `${taskinfo_result}` == 'skipped' ? `${sel}` : `${status}`}
								<span class="skipped" ${`${taskinfo_result}` != 'skipped' ? 'style="display: none"' : ''}>${Common.getDic('lbl_apv_NoApprvl')}</span>
							</td>
							<td class="al_name">${name}${bypassName}</td>
							<td class="al_position">${jobPositionName}</td>
							<td class="al_dept">${deptName}</td>
							<td>${`${taskinfo_result}` == 'inactive' || `${taskinfo_result}` == 'skipped' ? '<a href="javascript:void(0);" class="btn_del" onclick="addInApvLine.removeApvLine(this);"></a>' : (`${taskinfo_result}` == 'substituted' || `${taskinfo_result}` == 'agreed' || `${taskinfo_result}` == 'disagreed' || `${taskinfo_result}` == 'completed' ? `${datecompleted}` : '')}</td>
						</tr>
					</tbody>
				</table>
			</li>`;
			addInApvLine._UpdateDataCnt++;
			return templete;
		},
		
		// 수신/사전참조/참조 생성
		// rtn : 조직도/자동완성에서 선택한 데이터
		// type : Rec-수신, BCC-사전참조, CC-참조
		// bChkDup : true-중복체크, false-중복체크하지않음
		addEtcLine: function(rtn, type, bChkDup) {
			const itemCnt = JSON.parse(rtn).item.length;
			const targetDataObj = document.querySelector(`ul.org_select_user.${type}`);
			let html = '';
			
			JSON.parse(rtn).item.forEach((data) => {
				html = addInApvLine.templeteEtcLine(data, bChkDup ? targetDataObj.querySelectorAll('li.li_move') : null);
				if (html != '') {
					targetDataObj.querySelector('li.org_input').insertAdjacentHTML('beforebegin', html);
				}
			});
			
			// 입력할 데이터 개수와 적용된 개수가 다른경우 => 중복 제외 처리됨.
			if (addInApvLine._UpdateDataCnt != itemCnt) {
				Common.Warning(Common.getDic('msg_apv_forminappline_warning04')); // 이미 등록된 임직원/부서는 제외됩니다.
			}
			
			// 변경된 정보가 있으면 다시 Sortable
			if (addInApvLine._UpdateDataCnt > 0) {
				addInApvLine.setEtcSortable();
				addInApvLine._UpdateDataCnt = 0;
			}
		},
		
		// 수신/사전참조/참조 삭제
		// obj : 삭제 버튼 클릭한 객체
		removeEtcLine: function(obj) {
			const datereceived = JSON.parse(unescape($(obj).closest('li')[0].dataset.json)).datereceived;
			// li 삭제
			if (datereceived == undefined || datereceived == '') {
				obj.closest('li').remove();
			} else {
				Common.Warning(Common.getDic('msg_apv_348')); // 이미 받은 문서는 삭제 할 수 없습니다.
			}
		},
		
		// 중복 체크
		// data : 중복 체크 시킬 데이터
		// targetDataObj : 중복 체크 할 대상
		getIsDup: function(data, targetDataObj) {
			if (targetDataObj == null || targetDataObj.length == 0) return false;
			if (Array.from(targetDataObj).filter(x => x.dataset.code == data).length > 0) return true;
			else return false;
		},
		
		// 수신/사전참조/참조 템플릿
		// data : 바인딩할 데이터
		// targetDataObj : 객체가 있으면 중복 체크 할 대상, 객체가 null 이면 중복체크 하지 않음
		templeteEtcLine: function(data, targetDataObj) {
			if (data == undefined || data == null || data == '') return '';
			
			const itemType = data.itemType;
			// const name = itemType == 'user' ? `${CFN_GetDicInfo(data.RGNM)} ${CFN_GetDicInfo(data.DN)}` : CFN_GetDicInfo(data.DN); // 수신에서 부서명을 가져올수 없어서 참조/수신 둘다 이름만 보여지게 함.
			const name = CFN_GetDicInfo(data.DN);
			const code = data.AN;
			const json = escape(JSON.stringify(data));
			let templete = '';
			
			// 중복체크
			if (!addInApvLine.getIsDup(code, targetDataObj)) {
				templete = `
				<li class="li_move" data-code="${code}" data-json="${json}">${name} <span class="org_user_del" onclick="addInApvLine.removeEtcLine(this);"></span></li>`;
				addInApvLine._UpdateDataCnt++;
			}
			return templete;
		},
		
		// 조직도에서 조회 한 데이터에서 직위, 직급, 직책 값이 "코드&코드명" 으로 되어 있는걸 "코드;코드명" 으로 치환 후 처리
		// data : 조직도에서 받은 xml 데이터
		// type : Apv-결재, Rec-수신, BCC-사전참조, CC-참조
		setOrgDataChange: function(data, type) {
			let rtn = { 'item': [] };
			JSON.parse(data).item.forEach(function(item) {
				if (item.itemType == 'user') {
					// 조직도 데이터와 자동완성 데이터가 맞지 않아 결재선 데이터와 동일하게 &->; 으로 수정
					item.PO = item.PO.split('|')[1] ? item.PO.split('|')[0] + ';' + item.PO.split('|')[1] : item.PO;
					item.LV = item.LV.split('|')[1] ? item.LV.split('|')[0] + ';' + item.LV.split('|')[1] : item.LV;
					item.TL = item.TL.split('|')[1] ? item.TL.split('|')[0] + ';' + item.TL.split('|')[1] : item.TL;
					rtn.item.push({ 'itemType':item.itemType, 'AN':item.AN, 'DN': item.DN, 'LV': item.LV, 'TL': item.TL, 'PO': item.PO, 'RG': item.RG, 'RGNM': item.RGNM, 'ETID': item.ETID, 'ETNM': item.ETNM, 'EM': item.EM });
				} else {
					rtn.item.push({ 'itemType':item.itemType, 'AN':item.AN, 'DN': item.DN, 'RG': item.RG, 'RGNM': item.RGNM, 'ETID': item.ETID, 'ETNM': item.ETNM, 'EM': item.EM });
				}
			});
			data = JSON.stringify(rtn);
			
			switch (type) {
				case addInApvLine._ENUM_TYPE.APV:
					addInApvLine.addApvLine(data, true);
					break;
				case addInApvLine._ENUM_TYPE.REC:
				case addInApvLine._ENUM_TYPE.BCC:
				case addInApvLine._ENUM_TYPE.CC:
					addInApvLine.addEtcLine(data, type, true);
					break;
			}
		},
		
		// 결재선 반환
		// obj : 추가할 사용자/부서 조직 정보
		// bParallel : true-병렬/false-병렬
		setAppLine: function(obj, bParallel) {
			if (addInApvLine._AppLineAttribute.apvtype == 'ccinfo') {
				// 참조
				let oCcinfo = {};
				$$(oCcinfo).attr('belongto', 'sender');
				$$(oCcinfo).attr('senderid', Common.getSession("UR_Code"));
				$$(oCcinfo).attr('sendername', Common.getSession("UR_MultiName"));
				if (obj.datereceived != undefined) {
					$$(oCcinfo).attr('datereceived', obj.datereceived);
				} else {
					$$(oCcinfo).attr('datereceived', '');
				}
				
				// 사전참조
				if (obj.beforecc != undefined) {
					$$(oCcinfo).attr('beforecc', obj.beforecc);
				}
				
				// ou
				let oOu = {};
				$$(oCcinfo).append('ou', oOu);
				$$(oOu).attr('code', obj.RG);
				$$(oOu).attr('name', obj.RGNM);
		
				if (obj.itemType == 'user') {
					let oPerson = {};
					$$(oOu).append('person', oPerson);
					$$(oPerson).attr('code', obj.AN);
					$$(oPerson).attr('name', obj.DN);
		
					$$(oPerson).attr('title', obj.TL);
					$$(oPerson).attr('position', obj.PO);
					$$(oPerson).attr('level', obj.LV);
					$$(oPerson).attr('sipaddress', obj.EM);
		
					$$(oPerson).attr('oucode', obj.RG);
					$$(oPerson).attr('ouname', obj.RGNM);
				}
				return oCcinfo;
			} else if (addInApvLine._AppLineAttribute.apvtype == 'recinfo') {
				// 수신
				let recinfo = '';
				if (obj.itemType == 'user') {
					recinfo = `1:${obj.AN}:${obj.DN.replace(/;/gi, '^')}:X:${obj.RG}`;
				} else {
					recinfo = `0:${obj.AN}:${obj.DN.replace(/;/gi, '^')}:X`;
				}
				return recinfo;
			} else {
				// 일반 결재선
				// 결재선 속성 세팅
				addInApvLine.setAppLineAttribute();
		
				// step
				let oStep = {};
		
				if (!bParallel) {
					$$(oStep).attr('unittype', addInApvLine._AppLineAttribute.unittype);
					$$(oStep).attr('routetype', addInApvLine._AppLineAttribute.routetype);
					if (addInApvLine._AppLineAttribute.allottype != '') {
						$$(oStep).attr('allottype', addInApvLine._AppLineAttribute.allottype);
					}
					$$(oStep).attr('name', addInApvLine._AppLineAttribute.stepName);
					
					let oTaskinto = {};
					if (addInApvLine._AppLineAttribute.routetype == 'consult' || addInApvLine._AppLineAttribute.routetype == 'assist') {
						$$(oStep).append('taskinfo', oTaskinto);
						$$(oTaskinto).attr('status', 'inactive');
						$$(oTaskinto).attr('result', 'inactive');
						$$(oTaskinto).attr('kind', addInApvLine._AppLineAttribute.taskinfokind);
					}
				}
				
				//ou
				let oOu = {};
				$$(oStep).append('ou', oOu);
				$$(oOu).attr('code', obj.RG);
				$$(oOu).attr('name', obj.RGNM);
		
				if (addInApvLine._AppLineAttribute.unittype == 'person') {
					let oPerson = {};
					$$(oOu).append('person', oPerson);
					$$(oPerson).attr('code', obj.AN);
					$$(oPerson).attr('name', obj.DN);
					
					$$(oPerson).attr('position', obj.PO);
					$$(oPerson).attr('title', obj.TL);
					$$(oPerson).attr('level', obj.LV);
		
					$$(oPerson).attr('oucode', obj.RG);
					$$(oPerson).attr('ouname', obj.RGNM);
		
					$$(oPerson).attr('sipaddress', obj.EM);
		
					let oTaskinto = {};
					$$(oPerson).append('taskinfo', oTaskinto);
					$$(oTaskinto).attr('status', addInApvLine._AppLineAttribute.taskinforesult);
					$$(oTaskinto).attr('result', addInApvLine._AppLineAttribute.taskinforesult);
					$$(oTaskinto).attr('kind', addInApvLine._AppLineAttribute.taskinfokind);
				} else {
					let oTaskinto = {};
					$$(oOu).append('taskinfo', oTaskinto);
					$$(oTaskinto).attr('status', 'inactive');
					$$(oTaskinto).attr('result', 'inactive');
					$$(oTaskinto).attr('kind', addInApvLine._AppLineAttribute.taskinfokind);
				}
				return oStep;
			}			
		},
		
		// 결재선 속성 지정
		setAppLineAttribute: function() {
            switch (addInApvLine._AppLineAttribute.apvtype) {
	            case 'approve-normal': // 일반결재
	                addInApvLine._AppLineAttribute.stepName = Common.getDic('lbl_apv_normalapprove');
	                addInApvLine._AppLineAttribute.routetype = 'approve';
	                if (addInApvLine._AppLineAttribute.useAuthorize == 'Y') {
						addInApvLine._AppLineAttribute.taskinfokind = 'skip';
		                addInApvLine._AppLineAttribute.taskinforesult = 'skipped';
					} else {
		                addInApvLine._AppLineAttribute.taskinfokind = 'normal';
		                addInApvLine._AppLineAttribute.taskinforesult = 'inactive';
	                }
	                addInApvLine._AppLineAttribute.allottype = '';
	                break;
                case 'approve-authorize': // 일반결재-전결
	                addInApvLine._AppLineAttribute.stepName = Common.getDic('lbl_apv_normalapprove');
	                addInApvLine._AppLineAttribute.routetype = 'approve';
	                if (addInApvLine._AppLineAttribute.useAuthorize == 'Y') {
						addInApvLine._AppLineAttribute.taskinfokind = 'skip';
		                addInApvLine._AppLineAttribute.taskinforesult = 'skipped';
					} else {
		                addInApvLine._AppLineAttribute.taskinfokind = 'authorize'
		                addInApvLine._AppLineAttribute.taskinforesult = 'inactive';
	                }
	                addInApvLine._AppLineAttribute.allottype = '';
	                break;
                case 'approve-review': // 일반결재-후결
	                addInApvLine._AppLineAttribute.stepName = Common.getDic('lbl_apv_normalapprove');
	                addInApvLine._AppLineAttribute.routetype = 'approve';
	                if (addInApvLine._AppLineAttribute.useAuthorize == 'Y') {
						addInApvLine._AppLineAttribute.taskinfokind = 'skip';
		                addInApvLine._AppLineAttribute.taskinforesult = 'skipped';
					} else {
		                addInApvLine._AppLineAttribute.taskinfokind = 'review';
		                addInApvLine._AppLineAttribute.taskinforesult = 'inactive';
	                }
	                addInApvLine._AppLineAttribute.allottype = '';
	                break;
	            case 'assist-serial': // 협조
	                addInApvLine._AppLineAttribute.stepName = addInApvLine._AppLineAttribute.unittype == 'person' ? Common.getDic('lbl_apv_assist') : Common.getDic('lbl_apv_DeptAssist'); // 개인협조(순차) or 부서협조(순차)
	                addInApvLine._AppLineAttribute.routetype = 'assist';
	                addInApvLine._AppLineAttribute.taskinfokind = 'normal';
	                addInApvLine._AppLineAttribute.taskinforesult = 'inactive';
	                addInApvLine._AppLineAttribute.allottype = 'serial';
	                break;
	            case 'assist-parallel': // 협조(병렬)
	                addInApvLine._AppLineAttribute.stepName = addInApvLine._AppLineAttribute.unittype == 'person' ? Common.getDic('lbl_apv_assist_2') : Common.getDic('lbl_apv_DeptAssist2'); // 개인협조(병렬) or 부서협조(병렬)
	                addInApvLine._AppLineAttribute.routetype = 'assist';
	                addInApvLine._AppLineAttribute.taskinfokind = 'normal';
	                addInApvLine._AppLineAttribute.taskinforesult = 'inactive';
	                addInApvLine._AppLineAttribute.allottype = 'parallel';
	                break;
	            case 'consult-serial': // 합의
	                addInApvLine._AppLineAttribute.stepName = addInApvLine._AppLineAttribute.unittype == 'person' ? Common.getDic('lbl_apv_consent') : Common.getDic('lbl_apv_DeptConsent'); // 개인합의(순차) or 부서합의(순차)
	                addInApvLine._AppLineAttribute.routetype = 'consult';
	                addInApvLine._AppLineAttribute.taskinfokind = 'consult';
	                addInApvLine._AppLineAttribute.taskinforesult = 'inactive';
	                addInApvLine._AppLineAttribute.allottype = 'serial';
	                break;
	            case 'consult-parallel': // 합의(병렬)
	                addInApvLine._AppLineAttribute.stepName = addInApvLine._AppLineAttribute.unittype == 'person' ? Common.getDic('btn_apv_consultors_2') : Common.getDic('lbl_apv_DeptConsent2'); // 개인합의(병렬) or 부서합의(병렬)
	                addInApvLine._AppLineAttribute.routetype = 'consult';
	                addInApvLine._AppLineAttribute.taskinfokind = 'consult';
	                addInApvLine._AppLineAttribute.taskinforesult = 'inactive';
	                addInApvLine._AppLineAttribute.allottype = 'parallel';
	                break;
        	}
		},
		
		// 결재자/수신/사전참조/참조 데이터를 최종적으로 정리한다.
		// bValidation : true-벨리데이션 체크/false-하지않음
		setAppLineData: function(bValidation) {
			// 결재자 데이터처리
			// 결재전 데이터 삭제 (결재하지 않은 인원들 삭제)
			if ($$(m_oApvList).find('steps > division[divisiontype="send"] > step').json().length) {
				let oStep = [];
				$$(m_oApvList).find('steps > division[divisiontype="send"] > step').json().forEach((step, i, o) => {
				    let bDel = false;
					// 병렬 체크
				    if (step.ou.length) {
				        step.ou.some((ou) => {
				            if (ou.person) {
				                if (ou.person.length) {
									// 대결인 경우
									if (addInApvLine.chkInactiveApp(ou.person[0].taskinfo.result)) {
										bDel = true;
									}
									// 전달인 경우
								} else {
									// 일반적인 결재
						            if (addInApvLine.chkInactiveApp(ou.person.taskinfo.result)) {
										bDel = true;
									}
					            }
				            } else {
								if (addInApvLine.chkInactiveApp(ou.taskinfo.result)) {
									bDel = true;
									return true;
								}
				            }
				        });
				    } else {
				        if (step.ou.person) {
							if (step.ou.person.length) {
								// 대결인 경우
								if (addInApvLine.chkInactiveApp(step.ou.person[0].taskinfo.result)) {
									bDel = true;
								}
								// 전달인 경우
							} else {
								// 일반적인 결재
								if (addInApvLine.chkInactiveApp(step.ou.person.taskinfo.result)) {
									bDel = true;
								}
				            }
				        } else {
							if (addInApvLine.chkInactiveApp(step.ou.taskinfo.result)) {
								bDel = true;
							}
				        }
				    }
				    
				    // 결재 하지 않은 인원 삭제 (기안자 제외)
				    if (i != 0 && bDel) {
				    } else {
						oStep.push(step);
					}
				});
				$$(m_oApvList).find('steps > division[divisiontype="send"] > step').remove();
				$$(m_oApvList).find('steps > division[divisiontype="send"]').append('step', oStep);
			}
			
			// 결재선 재 지정
			let bNotApvType = false;
			addInApvLine._AppLineAttribute.apvtype = '';
			addInApvLine._AppLineAttribute.unittype = '';
			addInApvLine._AppLineAttribute.useAuthorize = 'N';
			document.querySelectorAll('ul.approver_list > li.li_move').forEach((li) => {
				// 결재 타입이 없는 결재자는 문서내 결재선 기능에서 사용할 수 없는 결재타입을 지정한 사용자이므로 제외 시킨다.
				if ($(li).find('select.myappr > option').length > 0) {
					let bParallel = false;
					if ($(li).find('select.myappr').val().indexOf('parallel') > -1 && addInApvLine._AppLineAttribute.apvtype == $(li).find('select.myappr').val() && addInApvLine._AppLineAttribute.unittype == $(li).find('select.myappr')[0].dataset.unittype) {
						// 병렬 여부. 이전과 동일한 병렬일때만 병렬처리
						bParallel = true;
					}
					
					addInApvLine._AppLineAttribute.apvtype = li.querySelector('select.myappr').value;
					addInApvLine._AppLineAttribute.unittype = li.dataset.unittype;
					addInApvLine._AppLineAttribute.useAuthorize = li.dataset.taskinfokind == 'skip' ? 'Y' : 'N';
					
					// 결재선 반환
					const retAppData = addInApvLine.setAppLine(JSON.parse(unescape(li.dataset.json)), bParallel);
					// 만든 결재선 추가
					if (bParallel) {
						const lastIdx = $$(m_oApvList).find("division[divisiontype='send'] > step").json().length - 1;
						$$($$(m_oApvList).find("division[divisiontype='send'] > step").json()[lastIdx]).append("ou", retAppData.ou);
					} else {
						$$(m_oApvList).find("division[divisiontype='send']").append("step", retAppData);
					}
				} else if (bValidation) {
					bNotApvType = true;
				}
			});
			
			if (bNotApvType) {
				Common.Warning(Common.getDic('msg_apv_forminappline_warning02')); // 문서내 결재선은 수신, 부서결재 및 감사, 결재자 참조, 결재자 확인을 사용할 수 없습니다. 삭제하시기 바랍니다.
				return false;
			}
						
			// 사전참조/참조 데이터처리
			if (getInfo('SchemaContext.scBeforCcinfo.isUse') == 'Y' || getInfo('SchemaContext.scCC.isUse') == 'Y') {
				addInApvLine._AppLineAttribute.apvtype = 'ccinfo';
				$$(m_oApvList).find('ccinfo').remove();
				if (getInfo('SchemaContext.scBeforCcinfo.isUse') == 'Y') {
					document.querySelectorAll(`ul.org_select_user.${addInApvLine._ENUM_TYPE.BCC} > li.li_move`).forEach((li) => {
						let obj = JSON.parse(unescape(li.dataset.json));
						if (!obj.beforecc) {
							obj.beforecc = 'y';
						}
					    // 결재선 반환
						const retAppData = addInApvLine.setAppLine(obj);
						// 만든 결재선 참조 추가
						$$(m_oApvList).find('steps').append('ccinfo', retAppData);
					});
				}
				
				if (getInfo('SchemaContext.scCC.isUse') == 'Y') {
					document.querySelectorAll(`ul.org_select_user.${addInApvLine._ENUM_TYPE.CC} > li.li_move`).forEach((li) => {
					    // 결재선 반환
						const retAppData = addInApvLine.setAppLine(JSON.parse(unescape(li.dataset.json)));
						// 만든 결재선 참조 추가
						$$(m_oApvList).find('steps').append('ccinfo', retAppData);
					});
				}
			} else {
				$$(m_oApvList).find('ccinfo').remove();
			}
			
			// 수신 데이터처리
			if (getInfo('SchemaContext.scIPub.isUse') == 'Y') {
				addInApvLine._AppLineAttribute.apvtype = 'recinfo';
				document.getElementById('ReceiveNames').value = '';
				document.querySelectorAll(`ul.org_select_user.${addInApvLine._ENUM_TYPE.REC} > li.li_move`).forEach((li) => {
				    // 결재선 반환
					const retAppData = addInApvLine.setAppLine(JSON.parse(unescape(li.dataset.json)));
					// 만든 결재선 수신 추가
					let recinfo = $.trim(document.getElementById('ReceiveNames').value);
					recinfo += (recinfo == '' ? '' : ';') + retAppData;
					document.getElementById('ReceiveNames').value = recinfo;
				});
				
				let sRec0 = '';
		        let sRec1 = '';
		        let sRec2 = '';
		        let recinfo = '';
		        if (document.getElementById('ReceiveNames') != null) {
					recinfo = document.getElementById('ReceiveNames').value;
				}
		        if (recinfo != '') {
		            let aRecDept = recinfo.split(';');
		            for (let i = 0; i < aRecDept.length; i++) {
		                if (aRecDept[i] != '') {
		                    let aRec = aRecDept[i].split(':');
		                    if (aRec[0] == '0') {
		                        if (sRec0 == '') sRec0 += aRec[1] + '|' + aRec[3];
		                        else sRec0 += ';' + aRec[1] + '|' + aRec[3];
		                    } else if (aRec[0] == '1') {
		                        if (sRec1 == '') sRec1 += aRec[1];
		                        else sRec1 += ';' + aRec[1];
		                    } else {
		                        if (sRec2 == '') sRec2 += aRec[1];
		                        else sRec2 += ';' + aRec[1];
		                    }
		                }
		            }
		        }
		        
		        if (document.getElementById('ReceiptList') != null) {
	        		document.getElementById('ReceiptList').value = sRec0 + '@' + sRec1 + '@' + sRec2;
		        }
	        } else {
				document.getElementById('ReceiptList').value = '';
				document.getElementById('ReceiveNames').value = '';
			}
	        document.getElementById('APVLIST').value = JSON.stringify(m_oApvList);
	        
			// 벨리데이션 체크
			if (bValidation) {
				// 개인협조 및 부서협조 체크 마지막 결재선 체크
			    let oLastAppSteps = $$(m_oApvList).find("division>step").concat().has("[routetype=assist']").last();
			    if (oLastAppSteps.length > 0 && parseInt(oLastAppSteps.index()) == $$(m_oApvList).find("division>step").concat().length - 1 && getInfo("SchemaContext.scLastAssistDraft.isUse") != "Y") {
			    	Common.Warning(Common.getDic('msg_apv_setFormRuleErrorMsg'));
			    	return false;
			    }
			    
			    // 개인합의 및 부서합의 체크 마지막 결재선 체크
			    oLastAppSteps = $$(m_oApvList).find("division>step").concat().has("[routetype=consult']").last();
			    if (oLastAppSteps.length > 0 && parseInt(oLastAppSteps.index()) == $$(m_oApvList).find("division>step").concat().length - 1) {
			    	Common.Warning(Common.getDic('msg_apv_setFormRuleErrorMsg'));
			    	return false;
			    }
				
				return true;
			}
		},
		
		// 결재선 체크시 현재 결재자 이후의 결재자 체크
		chkInactiveApp: function (result) {
			let rtn = true;
			switch (result) {
				case "completed":
				case "substituted":
				case "agreed":
				case "disagreed":
				case "pending":
					rtn = false;
					break;
				default:
					rtn = true;
					break;
			}
			return rtn;
		},
		
		// 결재자 결재타입 변경
		// obj : 결재타입 변경한 select box object
		setApvLineApvType: function(obj) {
			const li = obj.closest('li');
			
			if (obj.value == 'approve-authorize') {
				Common.Confirm(Common.getDic('msg_apv_chkAuthorize'), 'Confirm', function(result) { // 전결자가 지정되어있는 경우 이후 결재자는 모두 결재안함으로 변경 됩니다.
					if (result) {
						addInApvLine._AppLineAttribute.apvtype = obj.value;
						addInApvLine._AppLineAttribute.unittype = li.dataset.unittype;
						addInApvLine._AppLineAttribute.useAuthorize = 'N';
						addInApvLine.setLiAppAtt(li);
						
						// 순서 재 설정
						addInApvLine.setApvLineReOrder(true);
					} else {
						obj.selectedIndex = 0;
						obj.onchange();
					}
				});
			} else {
				addInApvLine._AppLineAttribute.apvtype = obj.value;
				addInApvLine._AppLineAttribute.unittype = li.dataset.unittype;
				addInApvLine._AppLineAttribute.useAuthorize = 'N';
				addInApvLine.setLiAppAtt(li);
				
				// 순서 재 설정
				addInApvLine.setApvLineReOrder(true);
			}
		},
		
		// 결재선 li에 결재 옵션 세팅
		// li : 변경할 li 객체
		setLiAppAtt: function(li) {
			addInApvLine.setAppLineAttribute();
			
			li.dataset.allottype = addInApvLine._AppLineAttribute.allottype;
			li.dataset.routetype = addInApvLine._AppLineAttribute.routetype;
			li.dataset.taskinfokind = addInApvLine._AppLineAttribute.taskinfokind;
			li.dataset.taskinforesult = addInApvLine._AppLineAttribute.taskinforesult;
		},
		
		// 조직도 버튼 클릭
		// type : Apv-결재자, Rec-수신, BCC-사전참조, CC-참조
		openApvOrg: function(type) {
			// 조직도 사용
			if (getInfo('SchemaContext.scFormAddInApvLine.value') == 'Y') {
				const callType = type == addInApvLine._ENUM_TYPE.APV ? 'D1' : 'D9'; // 결재선은 1개씩, 수신/사전참조/참조는 멀티 선택
				const popupTit = Common.getDic('lbl_DeptOrgMap');
				const url = `/covicore/control/goOrgChart.do?type=${callType}&treeKind=Group&init=&checkboxRelationFixed=false&callBackFunc=setAddIn${type}Org`;
				CFN_OpenWindow(url,popupTit,'1060','580','');
			} else {
				addInApvLine.setAppLineData();
				
				// 결재선 사용
				const url = '/approval/approvalline.do';
				CFN_OpenWindow(url,'','1100','562','scrollbars=no,toolbar=no,resizable=no');
			}
		},
		
		// 내 결재선 선택
		// obj : select box object
		setMyAppLine: function(obj) {
			if ($.trim(obj.value) == '') return;
			const appLine = JSON.parse(unescape($(obj).find('option:selected')[0].dataset.json));
			const division = m_oApvList.steps.division.length > 1 ? m_oApvList.steps.division[0] : m_oApvList.steps.division;
			
			// 기안자를 복사한다.
			appLine.steps.division.step.push(division.step.length > 1 ? division.step[0] : division.step);
			appLine.steps.division.step.move((appLine.steps.division.step.length - 1), 0);
			
			// 결재선 변경		
			m_oApvList = appLine;
			document.getElementById("APVLIST").value = JSON.stringify(m_oApvList);
			
			// 수신정보 삭제
			document.getElementById('ReceiveNames').value = '';
			document.getElementById('ReceiptList').value = '';
			
			// 결재선 생성
			addInApvLine.drawFormAppLine();
		},
		
		// 내 결재선 버튼 클릭
		openMyAppLine: function() {
			const url = '/approval/approvalline.do?callby=myappline';
			CFN_OpenWindow(url,'','1100','562','scrollbars=no,toolbar=no,resizable=no');
		},
		
		// 내 결재선으로 저장 클릭
		saveMyAppLine: function() {
			addInApvLine.setAppLineData();
			const elmRoot = $$(m_oApvList).find('steps');  
			
			if (elmRoot.children().length < 1) {
				Common.Warning(Common.getDic('msg_apv_052')); // 결재선에서 합의는 최종결재자 전에 위치해야 합니다.\n현 합의자를 결재자 아래로 내려주십시요.
				return false;
			}
			
			if (elmRoot.find('division').concat().length == 1 && elmRoot.find('step').concat().length == 1 && elmRoot.find('step>ou>person').find('taskinfo[kind=charge]').length == 1) {
				Common.Warning(Common.getDic('msg_apv_personDomainDataCheck')); // 기안자만 지정되어 있을 경우, 저장할 수 없습니다.
				return false;
			}
			
			Common.Prompt(Common.getDic('msg_apv_input_privateDomainData'), '', Common.getDic('btn_PersonalApvLine'), function(displayName) { // 저장할 결재선 이름을 입력하세요.
				if (displayName == null) return;
				if (displayName == '') {
					Common.Warning(Common.getDic('msg_apv_276')); // 결재선 이름을 입력하세요.
					return;
				}
				
				// 기안자제거
				let sApvLine = JSON.parse(document.getElementById('APVLIST').value);
				sApvLine.steps.division.step.removeAt(0);
				const sAbstract = addInApvLine.makeAbstract(sApvLine);
				
				Common.Confirm(Common.getDic('msg_apv_343'), 'Confirm', function (result) { // 결재선 중에서 부서와 배포처는 저장되지 않습니다. 저장하시겠습니까?
					if (!result) return;
					$.ajax({
						type:'POST',
						url:'apvline/insertPrivateDomain.do',
						data:{
							'customCategory' : 'APPROVERCONTEXT',
							'displayName' : displayName,
							'ownerID' : Common.getSession("UR_Code"),
							'abstract' : sAbstract,
							'description' : '',
							'privateContext' : JSON.stringify(sApvLine)
						},
						success : function(data){
							if(data.result == 'ok' && data.cnt >= 1) {
								Common.Inform(Common.getDic('msg_apv_331'), 'Inform', function() { // 저장되었습니다.
									addInApvLine.getPrivateDomainList();
								});
							}
						},
						error: function(response, status, error){
							CFN_ErrorAjax('apvline/insertPrivateDomain.do', response, status, error);
						}
					});
				});
			});
		},
		makeAbstract: function(oJson) {
			var len = $$(oJson).find('step').valLength();
			var sAbstract = '';
			$$(oJson).find('step').concat().each(function(i,$$) {    
				if ($$.attr('routetype') == 'consult' && $$.attr('allottype') == 'parallel') {
					sAbstract += addInApvLine.convertKindToSignType($$.find('taskinfo').attr('kind'),'')+'('+$$.find('>ou').valLength()+')'  
				} else {
					sAbstract += $$.find('ou>person').attr('name') + '[' + addInApvLine.convertKindToSignType($$.find('ou>person>taskinfo').attr('kind'),'') + ']';
				}
			
				if (i != len -1) {
					sAbstract += ' - ';
				}
			});
			return sAbstract;
		},
		convertKindToSignType: function(sKind, customattribute2) {
			let sSignType;
			const scustomattribute2 = (customattribute2 == undefined) ? '' : customattribute2;
			switch (sKind) {
				case 'normal':
					sSignType = Common.getDic('lbl_apv_normalapprove'); break;
				case 'consent':
					sSignType = Common.getDic('lbl_apv_investigation'); break;
				case 'authorize':
					sSignType = Common.getDic('lbl_apv_authorize'); break;
				case 'substitute':
					sSignType = Common.getDic('lbl_apv_substitue'); break;
				case 'review':
					sSignType = Common.getDic('lbl_apv_review');  break;
				case 'bypass':
					sSignType = Common.getDic('lbl_apv_bypass');  break;
				case 'charge':
					sSignType = Common.getDic('lbl_apv_charge'); break;
				case 'confidential':
					sSignType = Common.getDic('lbl_apv_Confidential');  break;
				case 'conveyance':
					sSignType = Common.getDic('lbl_apv_forward'); break;
				case 'skip':
					sSignType = Common.getDic('lbl_apv_NoApprvl') + (String(scustomattribute2) == '' ? '' : ' ' + String(scustomattribute2)); break;
				case 'confirm':
					sSignType = Common.getDic('lbl_apv_Confirm'); break;
				case 'reference':
					sSignType = Common.getDic('lbl_apv_share4list'); break;
				default:
					sSignType = ' '; break;
			}
			return sSignType;
		},
		
		// 내 결재선 가져오기
		getPrivateDomainList: function() {
			$.ajax({
				type: 'POST',
				url: 'apvline/getPrivateDomainList.do',
				data: {
					'userID' : Common.getSession("UR_Code")
				},
				success: function(data){
					if (data.result == 'ok') {
						let options = '';
						data.list.forEach((list) => {
							const privateDomainID = list.PrivateDomainDataID;
							const defaultYN = list.DefaultYN;
							const privateContext = list.PrivateContext;
							const displayName = (defaultYN == 'Y') ? (`[${Common.getDic('btn_apv_apvlist_default_y')}]${list.DisplayName}`) : (list.DisplayName);
							const priDivisionType = privateContext.steps.division.divisiontype;
							let priDivisionFlag = false;
							
							if (typeof(getInfo('Request.mode')) != 'undefined') {
								if (getInfo('Request.mode').substring(0,2) == 'RE' && priDivisionType == 'receive') {
									priDivisionFlag = true;
								} else if (getInfo('Request.mode').substring(0,2) != 'RE' && priDivisionType == 'send') {
									priDivisionFlag = true;
								}
							}
							
							if (priDivisionFlag) {
								options += `<option value="${privateDomainID}" data-json="${escape(JSON.stringify(privateContext))}">${`${priDivisionType}` == 'send' ? `[${Common.getDic('lbl_apv_send')}]` : `[${Common.getDic('lbl_apv_receive')}]`} ${displayName}</option>`;
			                }
						});
						
						document.querySelector('h3.apptit_h3').querySelectorAll('select.myappr > option:not(.noData)').forEach((opt) => { opt.remove(); });
						if (options != '') {
							document.querySelector('h3.apptit_h3').querySelector('select.myappr').insertAdjacentHTML('beforeend', options);
						}
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("apvline/getPrivateDomainList.do", response, status, error);
				}
			});
		}
	};
	window.addInApvLine = addInApvLine;
})(window);

// 조직도에서 선택한 정보를 결재자 결재선에 세팅
// rtn : 조직도에서 선택한 데이터
function setAddInApvOrg(rtn) {
	addInApvLine.setOrgDataChange(rtn, addInApvLine._ENUM_TYPE.APV);
}

// 조직도에서 선택한 정보를 수신 결재선에 세팅
// rtn : 조직도에서 선택한 데이터
function setAddInRecOrg(rtn) {
	addInApvLine.setOrgDataChange(rtn, addInApvLine._ENUM_TYPE.REC);
}

// 조직도에서 선택한 정보를 사전참조 결재선에 세팅
// rtn : 조직도에서 선택한 데이터
function setAddInBCCOrg(rtn) {
	addInApvLine.setOrgDataChange(rtn, addInApvLine._ENUM_TYPE.BCC);
}

// 조직도에서 선택한 정보를 참조 결재선에 세팅
// rtn : 조직도에서 선택한 데이터
function setAddInCCOrg(rtn) {
	addInApvLine.setOrgDataChange(rtn, addInApvLine._ENUM_TYPE.CC);
}

// 배열 삭제 (문서 내 결재선 기능에서 사용함)
// idx : 삭제할 Index
Array.prototype.removeAt = function (idx) {
    const o = [];
	this.forEach((a, i) => { if (i != idx) o.push(a); });
    this.clear();
    o.forEach((a) => { this.push(a); });
};

// 배열 순서 변경 (문서 내 결재선 기능에서 사용함)
// targetIdx : 변경하려고 하는 배열의 index 값
// moveIdx : 변경할 배열의 index 값
Array.prototype.move = function (targetIdx, moveIdx) {
	if (targetIdx >= this.length) {
		let k = moveIdx - this.length;
		while ((k--) + 1) {
			this.push(undefined);
		}
	}
	this.splice(moveIdx, 0, this.splice(targetIdx, 1)[0]);
};
//******************** 문서 안 결재선 함수 정리 끝 *******************************************************************************************************************************************/
//***********************************************************************************************************************************************************************************************/

function isTableLineMax(oApvList){
	var bReturn = false;
	var tmpTableLineMax;
	var $$_elmRoot, $$_elmList, $$_elmVisible;
	oApvList = $.parseJSON(XFN_ChangeOutputValue(JSON.stringify(oApvList)));
    $$_elmRoot = $$(oApvList).find("steps");

	var division_length = $$_elmRoot.find("division").valLength();
	var useRightTableOption = ( //   우측 결재선이 있는 스키마
			//getInfo("SchemaContext.scPRec.isUse") == "Y" // 수신자, 수신부서는 사용자가 지정 안할 경우도 있으므로 제외(지정하면 division개수가 2개이상이라서 체크됨)
			//|| getInfo("SchemaContext.scDRec.isUse") == "Y"
			getInfo("SchemaContext.scChgr.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrEnt.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrReg.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrOU.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y"
			|| getInfo("SchemaContext.scChgrOUReg.isUse") == "Y"
			//|| getInfo("SchemaContext.scChgrPerson.isUse") == "1"
		);
	tmpTableLineMax = (division_length > 1 || useRightTableOption) ? (tableLineMax/2) : tableLineMax;
	
	$$_elmRoot.find("division").concat().each(function (i, $$_element) {
		if (i == 0) {			
			$$_elmList = $$_element.find("step[routetype='approve'][name!='reference'] > ou > person,step[routetype='approve'][name!='reference']  > ou > role ");
			$$_elmVisible = $$_element.find("step[routetype='approve'][name!='reference'] > ou > role:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[kind='conveyance'])");  //전달 person도 제외에 체크
		} else {
			// CP는 담당자에게 문서 도착 시, routetype 이 approve로 변경되지 않음.
			// step의 routetype 체크 로직 변경
			var sRecList = "step[routetype='receive'][name!='reference']  > ou > role,step[routetype='receive'][name!='reference']  > ou > person ";
			var sRecVisibleList = "step[routetype='receive'][name!='reference'] > ou > role:has(taskinfo[visible='n']),step[routetype='receive'][name!='reference'] > ou > person:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[kind='conveyance'])";
			
			sRecList += ", step[routetype='approve'][name!='reference']  > ou > role,step[routetype='approve'][name!='reference']  > ou > person ";
			sRecVisibleList += ", step[routetype='approve'][name!='reference'] > ou > role:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[visible='n']),step[routetype='approve'][name!='reference'] > ou > person:has(taskinfo[kind='conveyance'])";
			
			$$_elmList = $$_element.find(sRecList); //(person|role)			
			$$_elmVisible = $$_element.find(sRecVisibleList);  //전달 person도 제외에 체크
		}
		
		var step_count =   $$_elmList.pack.jsoner.length; //$$_elmList.valLength();
		var appLength = step_count - $$_elmVisible.valLength();
		if (appLength > tmpTableLineMax) {
			bReturn = true;
			return false;
		}
	});
	
	return bReturn;
}

// 담당업무 정보 조회/수정 (전결규정에서 담당업무를 셋팅할때 사용)
function getChargeJob(){
	return $("#RuleChargeJob").length > 0 ?  $("#RuleChargeJob").val() : "";
}
function setChargeJob(pChargeJobInfo){
	$("#RuleChargeJob").val(pChargeJobInfo);
}
