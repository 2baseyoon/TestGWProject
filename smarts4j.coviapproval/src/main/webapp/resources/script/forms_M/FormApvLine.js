//***********************************************************************************************************************************************************************************************/
//******************** 양식 파일 내 결재선 함수 정리 시작 *****************************************************************************************************************************************/

var strwidth = "79"; //테이블형 결재선 한 테이블의 넓이(초기값)
var g_commentAttachList = [];

function initApvList() {
    //회수문서 및 임시저장 문서 재사용 시 부서코드/부서명/회사코드 최종본 반영 위해 수정 by sunny 2006.12. 양식쪽 일괄작업 어려움 공통함수 부분에서처리함
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
        try { document.getElementById("InitiatorUnitID").value = getInfo("AppInfo.dpid_apv"); } catch (e) { }
        try { document.getElementById("InitiatorUnitName").value = getInfo("AppInfo.dpdn_apv"); } catch (e) { }
        try { document.getElementById("EntCode").value = getInfo("AppInfo.etid"); } catch (e) { }
    }

    if ('' != document.getElementById("APVLIST").value) {
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
		"AssistLine": {}  
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
	  "event" : []
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
			  "signImage" : "", //서명 이미지경로
			  "date" : "",
			  "state" : "", //승인, 반려...
			  "originApprover" : ""
		  },      
		  "lineData": [],
		  "display": "N", //결재선 영역 표시여부
		  "target": "#AppLineListType",
		  "usedItem": ["displayNo", "apvKind",	"name", "dept", "signImage", "state", "date", "originApprover"]
		}
	} else if(tableType === 'AssistLine') {
		return {
		  "tableTitle": "",     
		  "tableHeader": {
			"dept" : "",      
			"name" : "",
			"date" : "",
			"comment": ""
		  },           
		  "lineData": [],
		  "display": "N", //결재선 영역 표시여부
		  "target": "#AssistLine",
		  "usedItem": ["dept", "name", "date", "comment"]
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

function __initApvListCols(hDisplay, fDisplay){
	var __table = __getTableDataObject('RApvLine');
	var __line = __getLineDataObject();
	
	__table.tableTitle = hDisplay;
	__line.signImage = fDisplay;
	
	__table.lineData.push(__line);
	
	return __table;
}

/* ====================================
 * 결재선 템플릿 지원(ATS) 데이터 반환 함수 : 
 *====================================*/

function __setInlineApvList(oApvList) {
    if (oApvList == null) {//IE8.0대비
        if (document.getElementById("APVLIST") == undefined) {
            oApvList = null;
            __setInlineApvList(oApvList);
            return;
        }
        else {
            m_oApvList = JSON.parse(document.getElementById("APVLIST").value);
            oApvList = m_oApvList;
        }
    }
    var __debug = true;
    if (getInfo("SchemaContext.scApvLineType.value") == "2" && __debug === true) {
        try { document.getElementById("AppLineListType").innerHTML = ""; } catch (e) { coviCmn.traceLog(e); }
        var __apvlist = __displayApvList(oApvList);
    } else {
        var __apvlist = __displayApvListCols(oApvList);
        try {
            document.getElementById("AppLine").style.display = "none";
            document.getElementById("AssistLine").style.display = "none";
            document.getElementById("AppLineListType").style.display = "";
        } catch (e) {
			coviCmn.traceLog(e);
        }
    }
    displayCCInfo($$(oApvList));
    if (document.getElementById("RecLine") != null) { document.getElementById("RecLine").innerHTML = initRecList(); }
    
    return __apvlist;
}

//결재라인
function __displayApvList(oApvList) {
    var $$_elmRoot, $$_elmList, $$_elmVisible;
    var Apvlines = "";
    var noDisplay = 0;
    var appLength = 0;
    var boolDisplayAssist = true;
	var __tdo= __getTotalDataObject();
	var __tdo2={};
	__tdo2.useTable = [];

	oApvList = $.parseJSON(XFN_ChangeOutputValue(JSON.stringify(oApvList)));
    $$_elmRoot = $$(oApvList).find("steps");

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
		var __assistlinetable = __getTableDataObject('AssistLine');
		

		var useRightTableOption = (getInfo("SchemaContext.scPRec.isUse") == "Y"  //   우측 결재선이 있는 스키마
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

		var step_count = $$_elmList.valLength();
		appLength = step_count - $$_elmVisible.valLength();
		if (i === 0 && appLength > tableLineMax) {
			__tdo2 = __displayApvListCols(oApvList);
			boolDisplayAssist = false;
		}
		var sOUName = "";

		//--------------------------------------------------------------------/
		//   우측(수신처) 결재선이 있는 스키마                             
		//--------------------------------------------------------------------/

		if (useRightTableOption) {

			var aOUName = [];
			if (getInfo("SchemaContext.scChgr.isUse") == "Y" || getInfo("SchemaContext.scChgrEnt.isUse") == "Y" || getInfo("SchemaContext.scChgrReg.isUse") == "Y") {
				var scChgrV = getJFID().split("^");
				for (var k = 0; k < scChgrV.length; k++) {
					aOUName.push(scChgrV[k].split("@")[1]);
				}
			}
			 if (getInfo("SchemaContext.scChgrOU.isUse") == "Y" || getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y" || getInfo("SchemaContext.scChgrOUReg.isUse") == "Y") {
				var scChgrOUV = getChargeOU().split("^");
				for (var k = 0; k < scChgrOUV.length; k++) {
					aOUName.push(scChgrOUV[k].split("@")[1]);
				}
			}

			//chargeperson으로 개발 s --------------
			 if (getInfo("SchemaContext.scChgrPerson.isUse") == "Y") {
				//var scChgrPersonV = getChargePerson().split("^");
				//for (var k = 0; k < scChgrPersonV.length; k++) {
				//    aOUName.push(scChgrPersonV[k].split("@")[1]);
				//}
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
								__rightapplinetable = __initApvListCols(Common.getDic("initApvListCols"), CFN_GetDicInfo(sOUName));
							}
						} else {
							__applinetable = __getRequestApvList($$_elmList, "", true, CFN_GetDicInfo($$_element.attr("ouname")));
						}
					}

				   if (division_length - 1 < aOUName.length && division_length - 1 == i) {
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

	//감사자 출력
	$$_elmList = $$_elmRoot.find("division > step[routetype='audit'] > ou > person");
	$$_elmVisible = $$_elmRoot.find("division > step[routetype='audit'] > ou > person:has(taskinfo[visible='n'])");
	var sAdtLine = "";
	if ($$_elmList.length > 0) {
		try { sAdtLine = __getRequestApvList($$_elmList, $$_elmVisible, "", false, "감사"); } catch (e) { coviCmn.traceLog(e); }
	}

	var $$_elmComment = $$_elmRoot.find("division > step > ou > person > taskinfo > comment, division > step > ou > role > taskinfo > comment");
	if ((bgetCommentView && $$_elmComment.length > 0 && getInfo("Request.templatemode") == "Read")) {
		if (m_print == false) getCommentView($$_elmRoot);
	}
	if (boolDisplayAssist) {
		//합의출력
		if(getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_HWP_MULTI") {
			displayAssistDraft_V1($$_elmRoot);			
		} 
		var __assistlinetable;
		if(__tdo2.useTable.indexOf('AssistLine') > -1) {
			__assistlinetable = __tdo2.tables['AssistLine'];
		} else {
			__assistlinetable = __displayAssist($$_elmRoot);
		}
		__tdo.tables.AssistLine = __assistlinetable;
		
	}
	//참조자 출력
	//함수 외부로 이동

	__getQuickDisplay(__tdo);

	return __tdo;

}

/*수신처, 발신처 부서 결재선 표현*/
function __getRequestApvList($$_elmList, $$_elmVisible, sMode, bReceive, sApvTitle, bDisplayCharge) {//신청서html
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

	var __tabledata = __getTableDataObject();
	
	var LastApv="",LastApvName="",LastDate="";

    $$_elmList.concat().each(function (i, $$_elm) {

		var __linedata = __getLineDataObject();

        $$_elmTaskInfo = $$_elm.find("taskinfo");

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
                        sTitle = $$_elm.attr("title"); // != undefined ? $$_elm.attr("title") : "";
                        if(sTitle==undefined && $$_elm.nodename() == "role"){
                        	 sTitle = Common.getDic("lbl_apv_charge");	//"담당"
                        }else if(sTitle==undefined){
                        	sTitle = "";
                        }
                        
                        if (getLngLabel(sTitle, true) == "") sTitle = $$_elm.attr("position") != undefined ? $$_elm.attr("position") : ""; 

                        //&로 구분된 부분 ; 로 변경
                        if (13 > sTitle.toString().split(';').length) {
                            sTitle = getLngLabel(sTitle.toString().replace(/&/g, ';'), true);
                        }
                        else {
                            sTitle = getLngLabel(sTitle, true);
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
                    if ($$_assistcmt.exist()) {
                        aryComment[i] = $$_assistcmt.attr();
                    } else {
                        aryComment[i] = "";
                    }

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
                        try {
                            if ('bypass' == $$_elmTaskInfo.parent().parent().find('taskinfo').eq(1).attr('kind')) {
                                isDuptyCheck = true;
                            }
                        }
                        catch (e) {
                            coviCmn.traceLog(e);
                        }

                        if (isDuptyCheck) {     //대결 표시
                            //원결재자 표시가 안되서 수정
                            ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) + "<br />(" + Common.getDic("lbl_apv_substitue") + ")" : ((bRejected) ? interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind")) : "(원) " + CFN_GetDicInfo($($$_elmList).get(i + 1).attr("name")) + "<br />" + CFN_GetDicInfo($$_elm.attr("name")));
                            ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name")) + " " + Common.getDic("lbl_apv_substitue");
                            ApvDateLines = (strDate == "") ? "&nbsp;" : formatDate(strDate, "H");
                            LastApv = "";
                            LastApvName = "";
                            LastDate = "";
                        }
                        else {  //담당 수신자 대결 E ---------------------------------------------
                            ApvSignLines = (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) : ((bRejected) ? interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind")) : __getSignUrl(sCode, (($$_elmTaskInfo.attr("customattribute1") == undefined) ? "stamp" : $$_elmTaskInfo.attr("customattribute1")), $$_elm.attr("name"), strDate, true, $$_elmTaskInfo.attr("result"), true));
                            ApvApproveNameLines = (strDate == "") ? "&nbsp;" : CFN_GetDicInfo($$_elm.attr("name"));
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

                ApvPOSLines = "";
                ApvTitleLines = "";
                ApvSignLines = "";
                ApvApproveNameLines = "";
                ApvDateLines = "";

                //감사인 경우 최종 결재자만 보여줌
                if ($$_elm.parent().parent().attr("routetype") == "audit") {
					Apvlines = tempApvLine;
					__tabledata.lineData = [];
					__tabledata.lineData.push(__linedata);
                } else {
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
			__tabledata.usedItem = ['apvKind','name','dept','signImage','date','state']; //표시항목

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
    var strDate, strFieldName, strwidth, strColTD, LastDate='';

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
         __linedatas = [],
         ApvKind = "",
         LastApvName="",
         LastApv="";

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

                // todo: MP기준으로 소스 맞춰야 함. 부서합의 등 오류 발생
                
                $$_elmTaskInfo = $$_stepou.find("person > taskinfo");
                if($$_elmTaskInfo.length == 0) { //아직 부서 내 기안이 진행되지 않았을 경우
                	$$_elmTaskInfo = $$_stepou.find("taskinfo");
                	ApvSignLines = sessionObjFormMenu.USERNAME;
                }
                else if($$_elmTaskInfo.length > 1) { //현재 결재할 사용자
                	$$_elmTaskInfo = $$_stepou.find("person > taskinfo[status='pending']"); 
                	if($$_elmTaskInfo.length == 0) { //부서협조 완료
                		$$_elmTaskInfo = $$_stepou.find("person > taskinfo[status='completed']"); 
                		$$_elmTaskInfo = $$_elmTaskInfo.eq($$_elmTaskInfo.length-1);
                		sCode = $$_elmTaskInfo.parent().attr('code');
                	}
                }
                	
                
                
				//-- strDate
                strDate = $$_elmTaskInfo.attr("datecompleted");
                
                if (strDate == null) {
                    strDate = ""; 
					ApvCmt = "";
                }

				//-- Apvdecide
                if ($$_stepou.parent().attr("routetype") == "consult" && $$_stepou.parent().attr("allottype") == "serial") { Apvdecide = Common.getDic("lbl_apv_DeptConsent"); }	//"부서합의"
                else if ($$_stepou.parent().attr("routetype") == "consult" && $$_stepou.parent().attr("allottype") == "parallel") { Apvdecide = Common.getDic("lbl_apv_DeptConsent_2"); }	//"부서합의(병렬)"
                else if ($$_stepou.parent().attr("routetype") == "assist" && $$_stepou.parent().attr("allottype") == "serial") { Apvdecide = Common.getDic("lbl_apv_DeptAssist"); }	//"부서협조"
                else if ($$_stepou.parent().attr("routetype") == "assist" && $$_stepou.parent().attr("allottype") == "parallel") { Apvdecide = Common.getDic("lbl_apv_DeptAssist2"); }	//"부서협조(병렬)"                
                else if ($$_stepou.parent().attr("routetype") == "audit") { Apvdecide = Common.getDic("lbl_apv_audit"); }			//"감사"
                else if ($$_stepou.parent().attr("routetype") == "audit" && $$_stepou.parent().attr("name") == "audit_dept") { Apvdecide = Common.getDic("lbl_apv_dept_audit"); } //부서준법
                else if ($$_stepou.parent().attr("name") == "ExtType") { Apvdecide = Common.getDic("lbl_apv_ExtType"); }	//"심의" -> 특이기능
               
			   //-- ApvSignLines ~ ApvVisible
                ApvSignLines = ApvSignLines == "&nbsp;" ? CFN_GetDicInfo($$_elmTaskInfo.parent().attr("name")) : ApvSignLines;
                ApvSign += (strDate == "") ? "" : getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), ApvSignLines, strDate, true, $$_elmTaskInfo.attr("result"), true, "list");
                ApvState = interpretResult($$_elmTaskInfo.attr("result"), "", $$_elmTaskInfo.attr("kind"));
                ApvDept = CFN_GetDicInfo($$_stepou.attr("name"));
                ApvDateLines = "";
                ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
                ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				ApvVisible = ( strDate == "" && $$_elmTaskInfo.attr("datereceived") != "" ) ? "T" : "F";
				
				__linedata['apvKind'] = Apvdecide;
				__linedata['displayNo'] = cnt;
				__linedata['name'] = ApvSignLines; // person name
				__linedata['dept'] = ApvDept; // ou name
				__linedata['signImage'] = ApvSign; 
				__linedata['title'] = sTitle;
				__linedata['decide'] = Apvdecide;
				__linedata['date'] = ApvDateLines;
				__linedata['state'] = ApvState;
				__linedata['originApprover'] = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
				__linedata['innerApvList'] = __getInnerApvListCols($$_stepou, ApvVisible, cnt);

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
        //unittype이 개인
        } else if ($$_step.attr("unittype") == "person") {

            $$_personsOrRoles = $$_step.find("ou > person,role").concat();
            
            for (var i = 0; i < $$_personsOrRoles.length; i++) {
                ApvSignLines = "&nbsp;";      //결재자 이름
                ApvCmt = "&nbsp;";            //사용자 코멘트 
                OriginApprover = "&nbsp;";    //원결재자
                sTitle = "&nbsp;";            //직책
                var sCode = "";           //사용자 아이디

                var $$_personOrRole = $$_personsOrRoles.eq(i);
                if (!$$_personOrRole.exist()) break;  // 더이상 노드가 없으면 빠져나감

                var $$_personOrRoleTaskinfo = $$_personOrRole.find("taskinfo");
				var __linedata = __getLineDataObject();

				var bMakeColList = ($$_personOrRoleTaskinfo.attr("kind") != 'conveyance' && $$_personOrRoleTaskinfo.attr("kind") != 'bypass' && $$_personOrRoleTaskinfo.attr("visible") != "n" && $$_personOrRoleTaskinfo.attr("kind") != 'skip');
				if (!bMakeColList) continue;

				//-- sTitle
				try {
					sTitle = getLngLabel($$_personOrRole.attr("position"), true);
				} catch (e) {
					if ($$_personOrRole.nodename() == "role") {
						sTitle = CFN_GetDicInfo($$_personOrRole.attr("name"));
					}
				}
				
				//-- strDate, ApvCmt
				strDate = $$_personOrRoleTaskinfo.attr("datecompleted");
				if (strDate == null) {
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
				ApvKind = interpretKind($$_personOrRoleTaskinfo.attr("kind"), $$_personOrRoleTaskinfo.attr("result"), $$_step.attr("routetype"), $$_step.attr("allottype"), $$_step.attr("name"));

				if ($$_steps.length == (iStep + 1)) {
					ApvKind = "Approve";
				}

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

				__linedatas.splice(0, 0, __linedata); //신규 항목을 맨 앞에 위치-jwk

				cnt++;

            } //persons_or_roles 루프 종료

        } //unitype=person 분기 종료
    }

    return __linedatas; // array
	
	//결재유형별 결재정보 생성
	function getLinesByKind($$_personOrRoleTaskinfo, $$_personOrRole, sCode, strDate, LastDate){
		var ApvSignLines=ApvState=ApvDept=ApvSign=ApvDateLines=ApvApproveNameLines=LastApv=LastApvName='';

		switch ($$_personOrRoleTaskinfo.attr("kind")) {
			case "authorize":
				ApvSignLines += CFN_GetDicInfo($$_personOrRole.attr("name"));
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
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
				ApvSign = (strDate == "") ? "&nbsp;" : getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				LastApv = getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), false);
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
				ApvSign = (strDate == "") ? "&nbsp;" : getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDateLines = "";
				ApvDateLines += (LastDate == "") ? Common.getDic("lbl_apv_bypass") : LastDate; //m_oFormMenu.gLabel_bypass : LastDate; //"후열"
				ApvApproveNameLines += (LastApvName == "") ? Common.getDic("lbl_apv_bypass") : LastApvName; //m_oFormMenu.gLabel_bypass : LastApvName; //"후열"
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				break; //"후열"
			case "review":
				ApvSignLines += CFN_GetDicInfo($$_personOrRole.attr("name"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				break;
			case "charge":
				ApvSignLines += CFN_GetDicInfo($$_personOrRole.attr("name"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				break;
			case "consent":
				ApvSignLines += CFN_GetDicInfo($$_personOrRole.attr("name"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "APV");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				break;
			default:
				ApvSignLines += (strDate == "") ? CFN_GetDicInfo($$_personOrRole.attr("name")) : getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), false);
				ApvState = interpretResult($$_personOrRoleTaskinfo.attr("result"), "", $$_personOrRoleTaskinfo.attr("kind"));
				ApvDept = CFN_GetDicInfo($$_personOrRole.attr("ouname"));
				ApvSign = (strDate == "") ? "&nbsp;" : getSignUrl(sCode, $$_personOrRoleTaskinfo.attr("customattribute1"), $$_personOrRole.attr("name"), strDate, false, $$_personOrRoleTaskinfo.attr("result"), true, "list");
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
    $$_elmList = $$_oApvStepList.find("step[unittype='person'] > ou > person,step[unittype='role'] > ou > person,step[unittype='person'] > ou > person,step[unittype='role'] > ou > role ").concat();

    var ApvPOSLines = "";
    var Apvdecide = ""; 				//대결,후열 등을 표시
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
	var __linedatas = [];
	var ApvKind="";

    // 사람일 경우 for 문 시작	
    $$_elmList.each(function (i, $$_elm) {
	    var __linedata = __getLineDataObject();
	
        ApvSignLines = "&nbsp;";      //결재자 이름
        ApvCmt = "&nbsp;";            //사용자 코멘트 
        OriginApprover = "&nbsp;";    //원결재자
        sTitle = "&nbsp;";            //직책
        sCode = "";           //사용자 아이디
        ApvKind = "";

        $$_elmTaskInfo = $$_elm.find("taskinfo");

        if ($$_elmTaskInfo.attr("visible") == "n" || $$_elmTaskInfo.attr("kind") == 'skip') {
			return; //건너 뜀
        }

		try {
			sTitle = getLngLabel($$_elm.attr("title"), true);
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
				LastApv = getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, false, $$_elmTaskInfo.attr("result"), false);
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
			case "charge":
				//기안자 //"결 재"
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
				ApvSignLines += (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) : getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, false, $$_elmTaskInfo.attr("result"), false);
				ApvState = interpretResult($$_elmTaskInfo.attr("result"));
				ApvDept = CFN_GetDicInfo($$_elm.attr("ouname"));
				ApvDateLines = "";
				ApvDateLines += (strDate == "") ? "&nbsp;" : formatDate(strDate, "D");
				ApvApproveNameLines += "&nbsp;&nbsp;&nbsp;&nbsp;" + ApvDateLines;
				//ApvKind = interpretResult($$_elmTaskInfo.getAttribute("result"));
		}

		__linedata['apvKind'] = ApvKind;	
		__linedata['displayNo'] = parentCnt + "-" + cnt;
		__linedata['name'] = ''; // person name
		__linedata['dept'] = ApvDept;
		__linedata['signImage'] = ApvSignLines;
		__linedata['signState'] = ApvSign;
		__linedata['title'] = sTitle;
		//__linedata['decide'] = Apvdecide; //사용안하는 것으로 보임
		__linedata['date'] = ApvDateLines;
		__linedata['state'] = ApvState;
		__linedata['originApprover'] = OriginApprover;
		__linedata['displayLine'] = DeptState == "T" ? 'Y': 'N'; //**** 신규 추가항목

		//의견
		__linedata['comment'] = (ApvCmt == "" || ApvCmt == "&nbsp;")  ? '' : ApvCmt;
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
	
    var $$_persons, $$_ous, iPersonOrOuCount;
    var strDate, __lastTitle, __lastCmt, __lastResult;
	var __tabledata = __getTableDataObject('AssistLine');

    $$_persons = $$_elmRoot.find("division").concat().find("> step[routetype='consult'][unittype='person'] > ou > person, >step[routetype='assist'][unittype='person'] > ou > person").concat();
    $$_ous = $$_elmRoot.find("division").concat().find("> step[routetype='consult'][unittype='ou'] > ou, > step[routetype='assist'][unittype='ou'] > ou").concat(); //부서협조		
    iPersonOrOuCount = $$_persons.length + $$_ous.length;

	//데이터 없으면 종료
    if (iPersonOrOuCount === 0) {
		__tabledata.lineData = [];
		__tabledata.display = 'N';
		return __tabledata;
	}

	__tabledata.tableHeader.dept = Common.getDic("lbl_dept"); //1번째 컬럼
	__tabledata.tableHeader.name = Common.getDic("lbl_apv_username"); //2번째 컬럼
	__tabledata.tableHeader.date = Common.getDic("lbl_apv_approvdate"); //3번째 컬럼
	__tabledata.tableHeader.comment = Common.getDic("lbl_apv_comment"); //4번째 컬럼

	//개인합의
	$$_persons.each(function (index, $$_person) {
		// 전달의 경우 화면 표시하지 않음
		if ($$_person.find("taskinfo").attr("kind") == 'conveyance') {
			return false;
		}
		
		var sCode="", sTitle = "";

		if ($$_person.nodename() == "role") {
			try { sCode = $$_person.find("person").attr("code"); } catch (e) { coviCmn.traceLog(e); }
			try { sTitle = CFN_GetDicInfo($$_person.attr("name")); } catch (e) { coviCmn.traceLog(e); }
		} else {
			sCode = $$_person.attr("code");
			sTitle = CFN_GetDicInfo($$_person.attr("name")) + " " + getLngLabel($$_person.attr("position"), true);
		}

		var $$_personTaskinfo = $$_person.find("taskinfo");
		var __personlinedata = __getLineDataObject();

		if ($$_personTaskinfo.attr("visible") != "n") {
			strDate = $$_personTaskinfo.attr("datecompleted");
			if (strDate == null) { strDate = ""; }
			var $$_assistcmt = $$_person.find("taskinfo > comment"); //문서창 상단에서 협조자의 의견이 잘리지 않도록 수정함.

			switch ($$_personTaskinfo.attr("kind")) {
				/*기존 소스에서 $(elmTaskInfo).kind 접근하므로, 무조건 undefined 값이 넘어오는 것으로 추측 = > X */
			case "substitute":
				__lastTitle = CFN_GetDicInfo($$_person.attr("name"));
				__lastCmt = ($$_assistcmt.text() == null) ? "&nbsp;" : $$_assistcmt.text().replace(/\n/g, "<br />");
				__lastResult = strDate == "" ? "&nbsp;" : formatDate(strDate) + " " + interpretResult($$_personTaskinfo.attr("result"));
				break;
			case "bypass":
				__personlinedata.dept = CFN_GetDicInfo($$_person.attr("ouname"));
				__personlinedata.name = sTitle + "<br>(" + Common.getDic("lbl_apv_substitue") + ")" + __lastTitle + "</td>";
				__personlinedata.date = __lastResult;
				__personlinedata.comment = __lastCmt;
				
				__tabledata.lineData.push(__personlinedata);
				break; //"후열"
			default:
				__personlinedata.dept = CFN_GetDicInfo($$_person.attr("ouname"));
				__personlinedata.name = sTitle;
				__personlinedata.date = strDate == "" && $$_personTaskinfo.attr("result") != "reserved" ? "&nbsp;" : formatDate(strDate) + " " + interpretResult($$_personTaskinfo.attr("result"));
				//__personlinedata.comment = $$_assistcmt.text() == null ? "&nbsp;" : $$_assistcmt.text().replace(/\n/g, "<br />");
				__personlinedata.comment = ($$_assistcmt.text() == null ? "&nbsp;" : Base64.utf8_to_b64(Base64.b64_to_utf8($$_assistcmt.text()).replace(/\n/g, "<br />")));
				
				__tabledata.lineData.push(__personlinedata);
				break;
			}
		}
	});

	//부서합의
	$$_ous.each(function (index, $$_ou) {

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
		if ($$_ou.find("taskinfo").eq(0).attr("visible") != "n") {
			__oulinedata.dept = CFN_GetDicInfo($$_ou.attr("name"));
			__oulinedata.name = __oulinedata.date = __oulinedata.comment = '&nbsp;';
			
			$$_ou.find("person").has(">taskinfo[visible!='n']").concat().each(function (p, $$_person) {
				var __sub_personlinedata = __getLineDataObject();

				strDate = $$_person.find("taskinfo").attr("datecompleted");
				if (strDate == null) { strDate = ""; }

				if ($$_person.find("taskinfo").attr("kind") == "review") {    // [2015-12-10] gypark 부서합의 후결일 경우
					__sub_personlinedata.name = CFN_GetDicInfo($$_person.attr("name")) + "&nbsp;<b>(후결)<b>" ;
				} else {
					__sub_personlinedata.name = CFN_GetDicInfo($$_person.attr("name")) ;
				}
				
				__sub_personlinedata.date = strDate == "" ? "&nbsp;" : formatDate(strDate) + " " + interpretResult($$_person.find("taskinfo").attr("result"));

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
	});
	__tabledata.display = 'Y';

	return __tabledata;
}

function __getSignUrl(apvid, signtype, apvname, sDate, bDisplayDate, sResult, breturn, sDisplayType) {
    var rtn = "";
    var url = window.location.href;
    var arr = url.split("/");
    var result = arr[0] + "//" + arr[2]
    
    var __basedomain = result; //document.location.protocol+ "//" + _HostName + ":8080";

    if (sDisplayType != null && sDisplayType == "list") {
        if (sDate != "") {
            if (signtype != "" && signtype != null && signtype != "undefined") {
                 rtn = signtype == "stamp" ? CFN_GetDicInfo(apvname) :  __basedomain + mobile_comm_getimg(g_BaseImgURL + signtype);
            } else {
                rtn = bDisplayDate == false ? Common.getDic("lbl_apv_sign_none") : CFN_GetDicInfo(apvname); //  + '<br>' + formatDate(sDate);
            }
        }
    } else {
        if (!breturn) {
            rtn = CFN_GetDicInfo(apvname);
        } else if (sDate != "") {
			if (signtype != "" && signtype != null && signtype != "undefined") {
				rtn = signtype == "stamp" ? CFN_GetDicInfo(apvname) : __basedomain + mobile_comm_getimg(g_BaseImgURL + signtype);
			} else {
				rtn = bDisplayDate == false ? Common.getDic("lbl_apv_sign_none") : CFN_GetDicInfo(apvname);
			}
        }
    }
	return rtn;
}

//**** 템플릿팅 수정전 함수 ****: 시작

function displayCCInfo($$_elmRoot) {
    var $$_ccInfos = $$_elmRoot.find("ccinfo");
    var sSendccInfos = "";
    var sRecccInfos = "";

    if ($$_ccInfos.length > 0) {
        $$_ccInfos.concat().each(function (index, $$_ccInfo) {
            var sList = "";
            var sBelongTo = $$_ccInfo.attr("belongto");
            var $$_ccList = $$_ccInfo.children();
            var ccListIndex = 0;
            var $$_cc = $$_ccList.eq(ccListIndex); ccListIndex++;
            var cc_maxlimit = 100;
            while ($$_cc.exist() && ccListIndex < cc_maxlimit) {
                if ($$_cc.children().exist()) $$_cc = $$_cc.children(0);
                if ($$_cc.nodename() == "person") {
                    sList += (sList.length > 0 ? ";" : "") + CFN_GetDicInfo($$_cc.attr("ouname")) + " " + getLngLabel($$_cc.attr("title"), true) + " " + CFN_GetDicInfo($$_cc.attr("name"));
                } else if ($$_cc.nodename() == "ou") {
                    if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_HWP_MULTI") {
                        sList += (sList.length > 0 ? ";" : "") + CFN_GetDicInfo($$_cc.attr("name")) + "장";
                    } else {
                        sList += (sList.length > 0 ? ";" : "") + CFN_GetDicInfo($$_cc.attr("name"));
                    }
                } else if ($$_cc.nodename() == "group") {
                    sList += (sList.length > 0 ? ";" : "") + CFN_GetDicInfo($$_cc.attr("name"));
                }

                $$_cc = $$_ccList.eq(ccListIndex); ccListIndex++;
            }
            $("#RecCC").parent().parent().css({ "display": "none" });
            switch (sBelongTo) {
                case "global": CC.innerHTML = sList; break;
                case "sender":
                    sSendccInfos += (sSendccInfos.length > 0 ? ";" : "") + sList;
                    document.getElementById("SendCC").innerHTML = sSendccInfos;
                    break;
                case "receiver":
                    $("#RecCC").parent().parent().css({ "display": "" });
                    sRecccInfos += (sRecccInfos.length > 0 ? ";" : "") + sList;
                    document.getElementById("RecCC").innerHTML = sRecccInfos;
                    break;
            }
        });
        //참조자 목록 보이기 처리

        try { document.getElementById("CCLine").style.display = ""; } catch (e) { coviCmn.traceLog(e); }
    } else {
        try { document.getElementById("CCLine").style.display = "none"; } catch (e) { coviCmn.traceLog(e); }
    }
}

//배포처 목록 조회
function initRecList() {
    if (getInfo("SchemaContext.scIPub.isUse") == "Y" && getInfo("SchemaContext.scIPub.value") != "" && getInfo("Request.templatemode") == "Write" && document.getElementById("ReceiveNames").value == "") {
        var strIPub = getInfo("SchemaContext.scIPub.value");
        document.getElementById("ReceiveNames").value = strIPub.split("||")[0];
        document.getElementById("ReceiptList").value = strIPub.split("||")[1];
    }
    var szReturn = '';
    var aRec = document.getElementById("ReceiveNames").value.split(";");
    var Include = "";
    for (var i = 0; i < aRec.length; i++) {
        if (aRec[i] != "") {
            if (aRec[i].split(":")[3] == "Y") {
                Include = "(" + Common.getDic("lbl_apv_recinfo_td2") + ")";
            }
            szReturn += (szReturn != '' ? ", " : "") + (getLngLabel(aRec[i].split(":")[2], false, "^")) + Include;
            Include = "";
        }
    }
    // [2019-02-12 MOD] 수신처 없는 경우에도 테이블 조회되는 현상 처리
    if (szReturn != ""){
    	document.getElementById("ReceiveLine").style.display = "";
    }else{
    	document.getElementById("ReceiveLine").style.display = "none";
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


    // 사람일 경우 for 문 시작	
    $$_elmList.each(function (i, $$_elm) {
        ApvSignLines = "&nbsp;";      //결재자 이름
        ApvCmt = "&nbsp;";            //사용자 코멘트 
        OriginApprover = "&nbsp;";    //원결재자
        sTitle = "&nbsp;";            //직책
        sCode = "";           //사용자 아이디
        ApvKind = "";

        $$_elmTaskInfo = $$_elm.find("taskinfo");

        if ($$_elmTaskInfo.attr("visible") != "n") {
            if ($$_elmTaskInfo.attr("kind") != 'skip') {
                try {
                    sTitle = getLngLabel($$_elm.attr("title"), true);
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
                        LastApv = getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, false, $$_elmTaskInfo.attr("result"), false);
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
                        ApvSignLines += (strDate == "") ? CFN_GetDicInfo($$_elm.attr("name")) : getSignUrl(sCode, $$_elmTaskInfo.attr("customattribute1"), $$_elm.attr("name"), strDate, false, $$_elmTaskInfo.attr("result"), false);
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

function getSignUrl(apvid, signtype, apvname, sDate, bDisplayDate, sResult, breturn, sDisplayType) {
    var rtn = "";
    var strWidth = "60px";
    var strHeight = "50px";

    if (sDisplayType != null && sDisplayType == "list") {
        if (sDate != "") {
            if (signtype != "" && signtype != null && signtype != "undefined") {
                if (signtype == "stamp") {
                    return CFN_GetDicInfo(apvname);
                }
                else {
                	var port = "";
                	if(document.location.port != "") port = ":" + document.location.port;
                    rtn += "<img src='" + document.location.protocol + "//" + _HostName + port + g_BaseImgURL + signtype + "' border=0 style='height:30px'>";
                }
            } else {
                rtn += (bDisplayDate == false) ? Common.getDic("lbl_apv_sign_none") : CFN_GetDicInfo(apvname); //  + '<br>' + formatDate(sDate);
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
                    	var port = "";
                    	if(document.location.port != "") port = ":" + document.location.port;
                        rtn += "<img src='" + document.location.protocol + "//" + _HostName + port + g_BaseImgURL + signtype + "' border=0 style='width:" + strWidth + ";height:" + strHeight + "'>";
                    }
                } else {
                    rtn += (bDisplayDate == false) ? Common.getDic("lbl_apv_sign_none") : CFN_GetDicInfo(apvname); //  + '<br>' + formatDate(sDate);
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
        if (strresult == "completed") { sKind = Common.getDic("lbl_apv_Approved");		/*gLabel_apv;*/ } 		//"승인"
        if (strresult == "reviewed") { sKind = Common.getDic("lbl_apv_Approved");		/*gLabel_apv;*/ } 		//"승인"
        if (strresult == "rejected") { sKind = Common.getDic("lbl_apv_reject");		 } 	//"반려"
        if (strresult == "agreed") { sKind = Common.getDic("lbl_apv_agree");		/*gLabel_agree;*/ } 			//"합의"
        if (strresult == "disagreed") { sKind = Common.getDic("lbl_apv_disagree");		/*gLabel_disagree;*/ } //"이의"
        if (strresult == "reserved") { sKind = Common.getDic("lbl_apv_hold");		/*gLabel_hold;*/ } 			//"보류"
        if (strresult == "bypassed") { sKind = Common.getDic("lbl_apv_bypass");		/*gLabel_bypass;*/ } 		//"후열"
    }
    return sKind;
}


function interpretKind(strkind, strresult, routetype, allottype, name) {
    var sKind;
    switch (strkind) {
        case "normal": sKind = "Review"; break; //"결재"
        case "charge": sKind = "Draft"; break; //"담당"
        case "authorize": sKind = m_oFormMenu.gLabel_authorize; break; 	//"전결"
        case "review": sKind = m_oFormMenu.gLabel_review; break; 		//"후결"
        case "consent": sKind = m_oFormMenu.gLabel_consent; break; 		//""
        case "substitute": sKind = m_oFormMenu.gLabel_substitue; break; 	//"대결"
        case "bypass": sKind = m_oFormMenu.gLabel_bypass; break; 		//"후열"
        case "confirm": sKind = m_oFormMenu.gLabel_confirm; break; //"확인"
        case "reference": sKind = m_oFormMenu.gLabel_reference; break; //"확인"
        case "skip": sKind = "--"; break;
        case "consult": sKind = "consult"; break;
    }
    //normal일 경우 세부설정
    if (strkind == "normal") {
        if (routetype == "assist") {
            sKind = m_oFormMenu.gLabel_assist;
            sKind = "consult";
            //            }
        } else if (routetype == "audit") {
            //결재선에서 넘어온 이름을 그대로 사용
            if (name == "audit") {
                sKind = m_oFormMenu.gLabel_audit; //감사;
            } else {
                sKind = m_oFormMenu.gLabel_person_audit1; //준법감시;
            }

        } else if (name == "ExtType") {
            sKind = m_oFormMenu.gLabel_ExtType;
        }
    } else {
        if ((strresult == "rejected") && (strkind != "normal")) {
            sKind = sKind + ((getInfo("FormInfo.BodyType") == "HWP") ? " " + m_oFormMenu.gLabel_reject : "<br>" + m_oFormMenu.gLabel_reject);
        } else if ((strresult == "rejected") && (strkind == "normal")) {
            sKind = m_oFormMenu.gLabel_reject; //"반려"
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
    var dtDate = XFN_TransDateServerFormat(CFN_TransLocalTime(formatDateCVT(sDate)));
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

	if($("#CommentList").html() == ""){
		ParseComments.parse(elmRootCom);
		var comments = ParseComments.comment();
		ParseComments.render();
	
		if(comments.CommentListRec.length != 0 && comments.CommentListRec[0].data.length > 0)
			$("h3#tableTitle").show();
		
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
}

function viewComment() {
    doButtonAction($("#btCommentView")[0]);
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
        src_mode : getInfo("Request.mode"), //m_oInfoSrc_mode,
        isViewComment : ('' != this.extcmt),
        CommentListId : '#CommentList',
        CommentListRecId : '#CommentListRec'
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
    for(var i=0; i< oData.CommentListRec.length; i++){
	    var htmlFixed = TemplateEngine(tplFixed, oData['CommentListRec'][i]);
	    
	    var htmlDynamic = '';
	    var oDataItemS = oData['CommentListRec'][i]['data'];
	    for(var j=oDataItemS.length-1; j>=0; j--){
	        var oDataItem = oDataItemS[j];
	        htmlDynamic += TemplateEngine(tplDynamic, oDataItem);
	    }
	
	    var oFixed = $(htmlFixed).appendTo($(conf.CommentListId));
	    $('.tpl-dynamic-container', oFixed).html(htmlDynamic);
    }
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
	var comment =  Base64.b64_to_utf8(elm.text());
	if(comment != ""){
	    var Comment = getCommentObj();
	    var sCommentTR ="";
	    //var comment = elm.text();
	
	    Comment.type = '결재문서의견';
	    Comment.person = getDic(elm.parent().parent().attr("name")) + "("+ getApvResult(elm.parent().attr("result"), elm.parent().attr("kind")) +  ")";
	    Comment.personId = elm.parent().parent().attr("code");
	
	    var sTimezoneDate = "";
	    if(elm.parent().attr("datecompleted") == null) {
	      if(elm.attr("datecommented") != null) sTimezoneDate = elm.attr("datecommented");
	      Comment.date = docs.formatDate(sTimezoneDate, 'CMT');
	    } else { 
	      if(elm.parent().attr("datecompleted") != null) sTimezoneDate = elm.parent().attr("datecompleted");
	      Comment.date = docs.formatDate(sTimezoneDate, 'CMT');
	    }
	    Comment.comment = replaceLinefeed(comment);
	    
	    if(elm.parent().find("comment_fileinfo").length > 0) {
	    	g_commentAttachList.push(elm.parent().find("comment_fileinfo").json());
	    	
	    	Comment.comment_fileinfo = elm.parent().find("comment_fileinfo").json();
		    Comment.comment_icon = "<div class=\"fClip\" style=\"display: inline-block; float: none; height: 16px;\"><a class=\"mClip\" onclick='openFileList_comment(this,"+i+")'><spring:message code='Cache.lbl_attach'/></a></div>"; // 의견 첨부 다운로드
	    }
	    else {
	    	g_commentAttachList.push({});
	    	
	    	Comment.comment_fileinfo = [];
	    	Comment.comment_icon = "";
	    }
	    	    
	    ret.push(Comment);
	}
  });
}

return ret;
}

var getApvResult = function(apv_result, apv_kind){
	var returnStr = "";

	switch(apv_result){
		case "completed": returnStr = Common.getDic("lbl_apv_Approved");			//승인
			break;
		case "agreed" : returnStr = Common.getDic("lbl_apv_agree");				//동의
			break;
		case "rejected": returnStr = Common.getDic("lbl_apv_reject");				//반려
			break;
		case "disagreed": returnStr = Common.getDic("lbl_apv_disagree");		//거부
			break;
		case "reserved": returnStr = Common.getDic("lbl_apv_hold");				//보류
			break;
		case "rejectedto": returnStr = Common.getDic("lbl_apv_rejectedto");		//지정반려
			break;
		default:
			if(apv_kind == "review") {
				returnStr = Common.getDic("lbl_apv_Confirm");		//후결
			}
			break;
	}
	
	return returnStr;
}

//추가의견 
var getAdditionalComment =  function(m_oCMT){
var ret = [];

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

  var newname = prefix + '(추가)';
  //var newid = "";											// TODO 추가의견 person ID 세팅 필요
  var insertdate = $$(jsonerObj).find("addComment").attr('InsertDate');
  var commenttext = $$(jsonerObj).find("addComment").attr('Comment');
  CommentSub.type = '추가의견';
  CommentSub.person = newname;
  CommentSub.date = docs.formatDate(insertdate, 'CMT');
  CommentSub.comment = commenttext.replace(/\n/g,"<br />");
  if($$(jsonerObj).find("addComment").attr('Comment_fileinfo').length > 0) {
	  CommentSub.comment_fileinfo = $$(jsonerObj).find("addComment").attr('Comment_fileinfo');
	  g_commentAttachList.push(CommentSub.comment_fileinfo);
  } else {
	  CommentSub.comment_fileinfo = [];
	  g_commentAttachList.push({});  
  }
  CommentSub.personId = $$(jsonerObj).find("addComment").attr('UserCode');
  ret.push(CommentSub);

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
	  var $$_comment = elmdiv.find("step > ou > person > taskinfo > comment").concat();		//[visible!='n']
	  var generalComments = getGeneralComment($$_comment);
	  
	  CommentRows = CommentRows.concat(generalComments);
	  //CommentRows = generalComments;
	
	  if (div == 0){
	    /*if((conf.src_mode == "COMPLETE" || isViewComment ) && conf.extcmt != undefined) {       
	      m_oCMT = JSON.parse(conf.extcmt);
	      var AComments = getAdditionalComment(m_oCMT);
	      CommentRows = CommentRows.concat(AComments);
	    }*/
	    Comments.title = '기안부서';
	    Comments.data = CommentRows;
	    CommentLists.CommentList.general = Comments;
	
	    if((conf.src_mode == "COMPLETE" && conf.feedback == "1") && conf.feedback != undefined){
	      m_oCMT =  JSON.parse(conf.feedbackcmt);
	      CommentLists.CommentList.feedback = getFeedbackComment(m_oCMT);
	    }
	
	  } else {
	    Comments.title = '수신부서';
	    Comments.data = CommentRows;
	    CommentLists.CommentListRec.push(Comments);
	  }
	});
	
	// 추가의견
	if(conf.src_mode == "COMPLETE" && typeof(m_addComment) != "undefined") {
		var m_oCMT = JSON.parse(m_addComment);
		var AComments = getAdditionalComment(m_oCMT);
		$.each(AComments, function(k,v) {
			CommentLists.CommentList.general.data.push(v);
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


/* 결재선 HTML */
function drawFormApvLinesAll(apvLines){
	// 그려진 결재선 초기화
	$("div#divFormApvLines").html("");
	
	var tempFrozen = $("script#frozen").html();
	$("div#divFormApvLines").html(tempFrozen);
	
	var useTable = $$(apvLines).find(">useTable"); 
	
	$$(useTable).concat().each(function(i, obj){
		var objParamData= $$(apvLines).find("tables>"+$$(obj).json());
		
		if($$(obj).json() == "AppLine")
		{
			$("#FormApvLines").show();
			$("td#AppLine").show();
			drawFormAppLine(objParamData);
		}else if($$(obj).json() == "LApvLine" || $$(obj).json() == "RApvLine")		//좌측 및 우측 결재선
		{
			$("#FormApvLines").show();
			$("td#"+$$(obj).json()).show();
			drawFormApvLine(objParamData, $$(obj).json());
		}else if($$(obj).json() == "AppLineListType")								//리스트 타입 결재선
		{
			$("div#AppLineListType").show();
			drawFormAppLineListType(objParamData);
		}else if($$(obj).json() == "AssistLine")									//합의 결재선
		{
			$("div#AssistLine").show();
			drawFormAssistLine(objParamData);
		}
		if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_HWP_MULTI") {
			$("#FormApvLines").hide();
			$("td#AppLine").hide();
			$("td#"+$$(obj).json()).hide();
			$("div#AppLineListType").hide();
			$("div#AssistLine").hide();
		}
	});
}

function drawFormAppLine(apvLines){
	var htmlArea = $("table#FormApvLines").find("td#AppLine");
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
			$("table#tableAppLine"+(i+1)).addClass("mt10");
		}
		
		var apvlineTable = $("table#tableAppLine"+(i+1));
		
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
			$(apvlineTable).find("colgroup").append("<col style='width:100px;'>");
		// lineData 수만큼 table width
		$(apvlineTable).css("width", lineData.length*100 + 40);
		
		// usedItem 수만큼 tableTitle rowspan
		$(apvlineTable).find("#AppLineTitle").attr("rowspan", usedItem.length);
		
		$(usedItem).each(function(i, strItem){
			var strTD = "";
			if(strItem == "signImage")						// 서명일 경우 별도의 css class
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
							strTD += "<img style='max-width: 100%; height: auto;' src="+$$(lineDataObj).attr(strItem)+" alt=''>";
						else
							strTD += $$(lineDataObj).attr(strItem);
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
				$(apvlineTable).find("#AppLineTitle").after(strTD);
			}else{
				$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
			}
		});
		
	});
}

// 왼쪽 오른쪽 결재선
function drawFormApvLine(apvLines, alignType){
	var htmlArea = $("table#FormApvLines").find("td#"+alignType);
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
			$("table#table"+alignType+(i+1)).addClass("mt10");
		}
		
		var apvlineTable = $("table#table"+alignType+(i+1));
		
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
			$(apvlineTable).find("colgroup").append("<col style='width:100px;'>");
		// lineData 수만큼 table width
		$(apvlineTable).css("width", lineData.length*100 + 40);
		
		// usedItem 수만큼 tableTitle rowspan
		$(apvlineTable).find("#"+alignType+"Title").attr("rowspan", usedItem.length);
		
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
							strTD += "<img style='max-width: 100%; height: auto;' src="+$$(lineDataObj).attr(strItem)+" alt=''>";
						else
							strTD += $$(lineDataObj).attr(strItem);
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
				$(apvlineTable).find("#"+alignType+"Title").after(strTD);
			}else{
				$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
			}
		});
		
	});
}

// 리스트 타입의 결재선
function drawFormAppLineListType(apvLines){
	var htmlArea = $("div#AppLineListType");
	var appLineListTypeHTML = $("div#AppLineListType").html();
	
	$$(apvLines).concat().each(function(i, obj){
		
		if($(htmlArea).find("div").attr("id") == undefined)
		{
			$(htmlArea).find("div").attr("id", "AppLineListType"+(i+1));
		}else				// 테이블이 여러개일 경우
		{
			$(htmlArea).append(appLineListTypeHTML);
			$(htmlArea).find("div").last().attr("id", "AppLineListType"+(i+1));
		}
		
		$("div#AppLineListType"+(i+1)).find("span#tableTitle").html($$(obj).attr("tableTitle"));
		var apvlineTable = $("div#AppLineListType"+(i+1)).find("table");
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
			$$(usedItem).concat().each(function(i, strItem){
				var lineDataObjVal = $$(lineDataObj).attr(strItem.json());
				if(strItem.json() == "comment" && lineDataObjVal != "&nbsp;"){
					strTD += "<td>";
					strTD += Base64.b64_to_utf8(lineDataObjVal);			// 의견 데이터 decoding
					strTD += "</td>";
				}else{
					strTD += "<td>";
					strTD += lineDataObjVal;
					strTD += "</td>";
				}
			});
			$(apvlineTable).find("tbody").append("<tr>"+strTD+"</tr>");
		});
	});
}

// 합의자
function drawFormAssistLine(apvLines){
	var htmlArea = $("div#AssistLine");
	var appLineListTypeHTML = $("div#AssistLine").html();
	
	$$(apvLines).concat().each(function(i, obj){
		
		if($(htmlArea).find("div").attr("id") == undefined)
		{
			$(htmlArea).find("div").attr("id", "AssistLine"+(i+1));
		}else				// 테이블이 여러개일 경우
		{
			$(htmlArea).append(appLineListTypeHTML);
			$(htmlArea).find("div").last().attr("id", "AssistLine"+(i+1));
		}
		
		var apvlineTable = $("div#AssistLine"+(i+1)).find("table");
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
						strTD += $$(lineDataObj).attr("dept");
						strTD += "</td>";
					}
					$$(usedItem).concat().each(function(i, strItem){
						var innerApvListObjVal = $$(innerApvListObj).attr(strItem.json());
						if(strItem.json() != "dept"){
							if(strItem.json() == "comment" && innerApvListObjVal != "&nbsp;"){
								strTD += "<td>";
								strTD += Base64.b64_to_utf8(innerApvListObjVal);			// 의견 데이터 decoding
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



