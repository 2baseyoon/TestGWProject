/**
 * 결재선 지정 스크립트
 */
//# sourceURL=ApvlineManager.js

function selectButton(obj){
	//선택된 버튼 text변경 
	$('#btnSelect').attr("value",obj.innerText);
	 
	var btnSelect = document.getElementById("btnSelect");
	$('#btnSelect').attr("onclick","doButtonAction(document.getElementById('"+obj.id+"'))");
	
	btnSelect.click();
	//버튼 리스트 숨김
	$('#dvCommonList').hide();
}

//---------------------------------------------------------------------------------

var standalone_mode = true; //JAL
var m_sApvMode;
var m_oInfoSrc;
var m_oFormMenu;
var m_oFormEditor;
var m_modeless = null;
var m_selectedDistRow = null;
var m_selectedDistRowId = null;
var m_RecDept = '';

JsonQuery.prototype.remove = function(key){
	  var realArray;
	  //obj > json=array > json(object)
	  if(this.invalid()) return this;
	  var jsoners, objects, oParents;
	  //키 삭제
	  if(key !== undefined && key !== ''){

	    var re = new RegExp(/^\d+$/);
	    var isIndex = re.test(key) === true;

	    var keys = [];
	    keys.push(key);

	    this.each(function(i, $$){
	      jsoners = $$.pack.jsoner;
	      if(isIndex){
	        deleteIndex(jsoners[0], key);
	        refreshJsonerLength(jsoners[0]);
	      }else{
	        deleteNode(jsoners, keys);
	      }
	    });
	    
	  } else {
	    //선택항목의 부모노드에서 키를 삭제
	    //삭제후 부모노드를 반환
		var pathArray = [];
	    this.each(function(i, $$){
	      var keys = [];
	      var selfJsoners = $$.pack.jsoner;
	      var lastNodeIndex = getLastNodeIndex(selfJsoners[0].path);
	      if(lastNodeIndex === ''){
	        jsoners = $$.parent().pack.jsoner;
	        keys = getKeys(selfJsoners);
	        deleteNode(jsoners, keys);
	      }else{
	    	jsoners = $$.parentArray().pack.jsoner;
	        realArray = $$.parent().find($$.nodename()).concat();
	        pathArray.push($$.path());
	      }
	    });
	    if(pathArray.length>=1){
	    	deleteArray(jsoners[0],realArray,pathArray);
	    }
	    //jsoners = this.parent().pack.jsoner;
	    //keys = getKeys(this.pack.jsoner);
	    //deleteNode(jsoners, keys);
	  }

	  return (new Jsoner(jsoners, this.root));  

	  function deleteIndex(jsoner, i){
	    jsoner.json.splice(i,1);
		//delete jsoner.json[i];
	  }
	  
	  function deleteArray(jsoners,realArray,pathArray){
		  jsoners.json.splice(0,jsoners.json.length);
		  
		  realArray.concat().each(function(i,obj){
			  if(!pathArray.includes(obj.path())){
				  jsoners.json.push(obj.json());
			  }
		  });
	  }
	  
	  function refreshJsonerLength(jsoner){
	  	if(Array.isArray(jsoner.json)){
	    	jsoner.length = jsoner.json.length;
	    }
	  }

	  function getKeys(jsoners){
	    var keys = [];
	    for(var i=0;i<jsoners.length;i++){
	      keys.push(jsoners[i]['node']);
	    }
	    return keys;
	  }
	  function deleteNode(jsoners, keys){
	    var key;
	    for(var i=0; i<jsoners.length; i++){
	      deleteSingleNode(jsoners[i], keys);
	    }  
	  }
	  function deleteSingleNode(jsoner, keys){
	    for(var j=0; j<keys.length; j++){
	      var key = keys[j];
	      delete jsoner.json[key];
	    }  
	  }
	  function getLastNodeIndex(path){
	    var arrSelfpath = path.split('/');
	    var selfnode = arrSelfpath[arrSelfpath.length-1];
	    if (selfnode.indexOf('[') < 0) return '';  
	    
	    var regExp = /\[([^)]+)\]/;
	    var matches = regExp.exec(selfnode);
	    return matches[1];
	  }
	}

//*페이지 로딩시 버튼 및 결재선 초기화
function initialize() {
	//parent -> opener
    if (openID != "") {//Layer popup 실행
        if ($("#" + openID + "_if", opener.document).length > 0) {
            m_oInfoSrc = $("#" + openID + "_if", opener.document)[0].contentWindow;
        } else { //바닥 popup
            m_oInfoSrc = opener;
        }
    } else {
        m_oInfoSrc = top.opener;
    }
    
    if (m_oInfoSrc == null) {
        m_oInfoSrc = opener.monitorList;
        if (m_oInfoSrc == null) {
            if (opener.location.href.toUpperCase().indexOf("LISTDEPT") > 0) { m_oInfoSrc = parent; }
            else { m_oInfoSrc = parent.ifrDL; }
        }
        m_oFormMenu = m_oInfoSrc;
        m_oFormEditor = m_oInfoSrc;
        m_sApvMode = getInfo("Request.mode")
        if (getInfo("Request.mode") == "READ") { trButton.style.display = "none"; }
    } else {
        m_sApvMode = getInfo("Request.mode");
        if (m_sApvMode == "CFADMIN") {
        	document.getElementById("btnOpen").style.display = "none";
        	document.getElementById("btnClose").style.display = "none";
        	document.getElementById("divApvLineMgrSub").style.display = "none";
        }
        m_oFormMenu = m_oInfoSrc;
        m_oFormEditor = m_oInfoSrc;
    }
    
    if (m_oInfoSrc != null){
    	initButtons(); //list를 그리고 생기는 버튼은 조작할 수 없어서 리스트 그리고 난 후로 위치 변경
    } 
    //changeTab("tPersonDeployList");
    return true;
}

//*버튼 초기화
function initButtons() {
    if (iItemNum < 999) {
        m_RecDept = m_oFormEditor.document.getElementsByName("ST_RECLINEOPD")[iItemNum].value;
    } else {
    	m_RecDept = m_oFormEditor.document.getElementById("RECEIVEGOV_NAMES").value;
    }

    //배포처 size 키우기
    /*if (getInfo("SchemaContext.scIPub.isUse") == "Y") {
        chkAction(mType);
        $("#divtPersonDeployList").attr("style", "display:;");
        if (getInfo("SchemaContext.scGRec.isUse") == "Y") {
            $("#divtDeployList").attr("style", "display:;"); //park
        }
    }*/
    //배포처 size 키우기
    if ((getInfo("SchemaContext.scDeployBtn.isUse") == "N" && getInfo("SchemaContext.scIPub.isUse") == "Y") || getInfo("SchemaContext.scDistribution.isUse") == "Y") {
	if(getInfo('ExtInfo.UseMultiEditYN') == "Y" && window.location.href.toUpperCase().indexOf("MULTIRECEIVELINE") > 0){
    		chkActionMulti(mType);
    	} else {
            chkAction(mType);
    	}
        $("#divtPersonDeployList").attr("style", "display:;");
        if (getInfo("SchemaContext.scGRec.isUse") == "Y") {
            $("#divtDeployList").attr("style", "display:;"); //park
        }
    }

    switch (m_sApvMode) {
	    case "REDRAFT":
	        $("#divtApvLine").attr("style", "display:;");
	        $("#groupTreeDiv").attr("style", "display:none;");//추가
	        $("#btnClose").attr("style", "display:;");
	        $("#divApvLineMgrSub").css({ "display": "block" });
	        break;
	    case "DRAFT":
	    	$("#groupTreeDiv").attr("style", "display:none;");
	    	$("#btnClose").attr("style", "display:;");
	    	$("#divApvLineMgrSub").css({ "display": "block" });
	}
}

function setApvList() {
    //배포처 관련 시작
    if (iItemNum < 999) {
    	top.opener.document.getElementsByName("ST_RECLINEOPD")[iItemNum].value = m_RecDept;
    	top.opener.initGovListMulti_V1(iItemNum);
    } else {
		//대외수신처 정보 셋팅
    	top.opener.document.getElementById("RECEIVEGOV_NAMES").value = m_RecDept;
    	//대내수신처 초기화
    	m_oFormMenu.document.getElementById("ReceiveNames").value = "";

    	var resReceiveGovInfo = "";
    	var ReceiveGovInfoCode = "";
    	var sReceiveGovInfo = "";
    	var ReceiveGovInfo = "";
    	var ReceiveGovKo = "";
    	var receveCnt = m_RecDept.split(":")[0] == "0" ? 13 : 8;

        for (var i = 0; i < m_RecDept.split(";").length; i++) {
            if (m_RecDept.split(";")[i] != '') {
                if (sReceiveGovInfo == "") {
                	ReceiveGovInfo = m_RecDept.split(";")[i].split(":")[receveCnt];
                    ReceiveGovInfoCode = m_RecDept.split(";")[i].split(":")[1];
                    sReceiveGovInfo = ReceiveGovInfo + "^" + ReceiveGovInfoCode;
                    ReceiveGovKo = m_RecDept.split(";")[i].split(":")[receveCnt];
                } else {
                	ReceiveGovInfo = m_RecDept.split(";")[i].split(":")[receveCnt]; 
                	ReceiveGovInfoCode = m_RecDept.split(";")[i].split(":")[1];
                    sReceiveGovInfo += "@ " + ReceiveGovInfo + "^" + ReceiveGovInfoCode;
                    ReceiveGovKo += ", " + m_RecDept.split(";")[i].split(":")[receveCnt]; 
                }
            }
        }
        
		// 다안기안+문서유통시
		if (typeof (m_oFormMenu.isGovMulti()) != 'undefined' && m_oFormMenu.isGovMulti()) {
			m_oFormMenu.document.getElementsByName('MULTI_RECEIVE_TYPE')[g_GovMultiIdx].value = g_GovMultiReceiveType;
			//MULTI_RECEIVENAMES에도 MULTI_RECEIPTLIST형태로 데이터 들어가야함.엔진에서 결재완료시 NAMES 사용
			//m_oFormMenu.document.getElementsByName('MULTI_RECEIVENAMES')[g_GovMultiIdx].value = sReceiveGovInfo;
			m_oFormMenu.document.getElementsByName('MULTI_RECEIVENAMES')[g_GovMultiIdx].value = m_RecDept;
			//m_oFormMenu.document.getElementsByName('MULTI_RECEIPTLIST')[g_GovMultiIdx].value = m_RecDept;
		} else {
			top.opener.document.getElementById('RECEIVEGOV_TYPE').value = "out"; //대외
	        if(top.opener.document.getElementById("RECEIVEGOV_INFO").nodeName == "SPAN") {
	        	top.opener.document.getElementById("RECEIVEGOV_INFO").innerHTML = sReceiveGovInfo;
	        	//top.opener.document.getElementsByName("MULTI_RECEIVEGOV_INFO")[1].value = sReceiveGovInfo;
	        	//top.opener.document.getElementsByName("MULTI_RECEIVEGOV_INFO_Data")[1].value = ReceiveGovKo;
	        } else {
	        	top.opener.document.getElementById("RECEIVEGOV_INFO").value = sReceiveGovInfo;
	        	//top.opener.document.getElementsByName("MULTI_RECEIVEGOV_INFO")[1].value = sReceiveGovInfo;
	        	//top.opener.document.getElementsByName("MULTI_RECEIVEGOV_INFO_Data")[1].value = ReceiveGovKo;
	   		}
        }
    }
    
    if (openID == "L") {
        Common.Close();
    } else if (openID != "" && parent.length > 0) {
    	parent.Common.Close("btLine" + getInfo("FormInstanceInfo.FormInstID"));
    //문서유통 일반에디터 사용
    } else if(getInfo("ExtInfo.UseEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y"){
    	var recData = ReceiveGovKo;
		recDataLen = recData.split(",").length;		
		
		// 다안기안
		if (typeof (m_oFormMenu.isGovMulti()) != 'undefined' && m_oFormMenu.isGovMulti()){
			$("#"+"DocRecLine"+g_GovMultiIdx,top.opener.document).children().val(recData.replace(/<[^>]*>?/g, ''));
			m_oFormMenu.document.getElementsByName('MULTI_DOC_RECLINE')[g_GovMultiIdx].value = recData.replace(/<[^>]*>?/g, '');
		}else if(top.opener.getInfo("SchemaContext.scDistribution.isUse") == "Y"){
			top.opener.document.getElementById('RECEIVEGOV_TYPE').value = "out"; //대외
		}
		
		$("#DocRecLine",top.opener.document).val(recData.replace(/<[^>]*>?/g, ''));
			
		var chkID = top.$("[name='docID'].AXTab.on").attr("id");

		window.parent.window.close();
    //문서유통 한글기안기 사용
	}else {
    	var recData = ReceiveGovKo;
		recDataLen = recData.split(",").length;
		let HwpCtrl = typeof (m_oFormMenu.isGovMulti()) != 'undefined' && m_oFormMenu.isGovMulti() ? top.opener.document.getElementById('tbContentElement' + m_oFormMenu.m_firstIDx + 'Frame').contentWindow.HwpCtrl : top.opener.HwpCtrl; // 다안기안+문서유통시 안 index에 따라 한글에디터 지정
		
		if(recDataLen <=1){
			HwpCtrl.PutFieldText("recipient",ReceiveGovKo )
			HwpCtrl.PutFieldText("recipients", " ");
			HwpCtrl.PutFieldText("hrecipients", " ");
		}
		else{
			HwpCtrl.PutFieldText("hrecipients", "수신자");
			HwpCtrl.PutFieldText("recipient", "수신자 참조");
			HwpCtrl.PutFieldText("recipients",ReceiveGovKo)
		}
			
		var chkID = top.$("[name='docID'].AXTab.on").attr("id");
		//top.opener.document.getElementsByName("MULTI_RECEIVE_CHECK")[1].value = top.$("#"+chkID).attr("value");
		//top.opener.document.getElementsByName("MULTI_RECEIVE_CHECK")[1].value =  $("#"+$("[name='docID'].AXTab.on").attr("id")).attr("value"); 
		window.parent.window.close();
    }
}
function joinAttrs(elmList, sAttrName) {
    if (elmList.length == 0) return "";
    var sJoin = "";
    var elm = elmList.nextNode();
    while (elm != null) {
        sJoin += (sJoin == "" ? "" : ";") + elm.getAttribute(sAttrName);
        elm = elmList.nextNode();
    }
    elmList.reset();
    return sJoin;
}
/*======================================
-- 버튼에 따른 기능 정의
--====================================*/
function doButtonAction(obj) {
    var bSetDirty = false;
    
    switch (obj.id) {
        case "btPersonOUALL":
			bSetDirty = true;
		    addPersonOUALL();
		    break;
		case "btPerson": // 일반결재
			bSetDirty = true;
		    if (m_sApvMode == "CHARGE") {
		        addChargePerson();
		    } else if (m_sApvMode == "REDRAFT") {
		        addReceiptPerson();
		    } else {
		        addPerson();
		    }
		    break;
		case "btReceipt": // 수신처
			bSetDirty = true; addReceipt(); break;
		case "btDistribution": // 대외수신처 추가
			bSetDirty = true; addDistribution(); break;			
		case "btCharge": // 담당자
			bSetDirty = true; addCharge(); break;
		case "btGroup":
			bSetDirty = true; addGroup(); break;
		case "btPAssist": // 개인협조
			bSetDirty = true; addPAssist('serial'); break;
		case "btPAssistPL": // 개인협조(병렬)
			bSetDirty = true; addPAssist('parallel'); break; //병렬협조추가forBK
		case "btDAssist": // 부서협조
			bSetDirty = true; addDAssist('serial'); break;
		case "btDAssistPL": // 부서협조(병렬)
			bSetDirty = true; addDAssist('parallel'); break;
		case "btPConsult": // 개인합의
			bSetDirty = true; addPConsult('serial'); break;
		case "btPConsult2": // 개인합의(병렬)
			bSetDirty = true; addPConsult('parallel'); break;
		case "btDConsult": // 부서합의
			bSetDirty = true; addDConsult('serial'); break;
		case "btDConsult2": // 부서합의(병렬)
			bSetDirty = true; addDConsult('parallel'); break;
		case "btDelete":
			bSetDirty = true; deletePerson(); break;
		case "btUp": // 위로
			bSetDirty = true; moveUpDown("UP"); break;
		case "btDown": // 아래로
			bSetDirty = true; moveUpDown("DOWN"); break;
		case "btCC":
			if (m_bCC) { bSetDirty = true; setCC("global","n"); } break;
		case "btSendCC": // 참조
			if (m_bCC) { bSetDirty = true; setCC("sender","n"); } break;
		case "btRecCC": // 수신참조
			if (m_bCC) { bSetDirty = true; setCC("receiver", "n"); } break;
		case "btSendCCBefor": // 사전참조
		    if (m_bCC) {
		        var deptGubun = "sender";
		        if (m_sApvMode == "REDRAFT" || m_sApvMode == "RECAPPROVAL") {
		            deptGubun = "receiver";
		        }
		        bSetDirty = true; setCC(deptGubun, "y");
			} break;
		case "btSendCCAfter": // 사후참조
		    if (m_bCC) {
		        var deptGubun = "sender";
		        if (m_sApvMode == "REDRAFT" || m_sApvMode == "RECAPPROVAL") {
		            deptGubun = "receiver";
		        }
		        bSetDirty = true; setCC(deptGubun, "n");
			} break;
		case "btDeleteCC":
			bSetDirty = true; deleteCC(); break;
		case "btApplyLine":
			bSetDirty = true; applyLine(); break;
		case "btResetLine":
			resetLine(); break;
		case "btOK": // 확인
			setApvList(); break;
		case "btExit": // 닫기
			if (openID != "" && parent.length > 0) { 
				parent.Common.Close("btLine" + getInfo("FormInstanceInfo.FormInstID")); 
			} else { 
				window.parent.window.close();
			} 
			break;
		case "btRecDept": // 배포추가
			addRecDept(); break;
		case "btDeleteRec":
			delList(); break;
		case "btPlPerson": // 동시결재
			bSetDirty = true; addparallelPerson(); break; //동시결재 추가
		case "btPAudit": // 개인감사
		case "btPAuditLeft": // 개인감사
			bSetDirty = true; addPAudit("audit"); break; //감사 2007.02 by sunny
		case "btPAudit1": // 개인준법
		case "btPAudit1Left": // 개인준법
			bSetDirty = true; addPAudit("audit_law"); break;
		case "btDAudit": // 부서감사
		case "btDAuditLeft": // 부서감사
			bSetDirty = true; addDAudit("audit_dept"); break;
		case "btDAudit1": // 부서준법
		case "btDAudit1Left": // 부서준법
			bSetDirty = true; addDAudit("audit_law_dept"); break; //준법처
		case "btDAuditETC":
			bSetDirty = true; addDAuditETC(); break;
		case "btExtType": // 특이기능
			bSetDirty = true; addExtType(); break;
		case "btPReview": // 개인공람
			bSetDirty = true; addPReview(); break;
		case "btPersonConfirm": // 확인자
			bSetDirty = true; addPersonExt('confirm'); break;
		case "btPersonShare": // 참조자
			bSetDirty = true; addPersonExt('reference'); break;
		case "btDeletePersonOUALL":
			bSetDirty = true; deletePerson(); break;
		case "btDeleteCCALL":
			bSetDirty = true; deleteCC(); break;
		case "btPersonalLineSave":
			personalLine(); break;
		case "btDeleteRecALL":
			delList(); break;
		case "btAssistGroup": // 합의그룹구분
			assistGroup(); break;
		case "btAssistGroupDelete": // 합의그룹전체해제
			deleteAssistGroup(); break;
		case "btUpDeploy":
			bSetDirty = true; moveUpDownDeploy("UP"); break; 
		case "btDownDeploy":
			bSetDirty = true; moveUpDownDeploy("DOWN"); break;
    }
    if (bSetDirty) try { if (m_oFormMenu.contentWindow) { m_oFormMenu.contentWindow.setApvDirty(); } else { m_oFormMenu.setApvDirty(); } } catch (e) { coviCmn.traceLog(e); }
}

var g_szAcceptLang = "ko";

/*************************************************************************
함수명 : containsCharsOnly
기  능 : 특정문자가 존재하는지 체크
인  수 : input, chars - 객체, 찾고자하는 문자
리턴값 : 존재하면 true
**************************************************************************/
function containsCharsOnly(input, chars) {
    for (var inx = 0; inx < input.length; inx++) {
        if (chars.indexOf(input.charAt(inx)) == -1)
            return false;
    }
    return true;
}

/*************************************************************************
함수명 : isNumber
기  능 : 입력값이 숫자인지를 체크
인  수 : input - 입력값
리턴값 : 숫자 true , 숫자외문자 false
**************************************************************************/
function isNumber(input) {
    var chars = "0123456789";
    if (input == "") return false;
    return containsCharsOnly(input, chars);
}

function get_choiseIdOrName(IdName) {
    var tmpValue = "";
    if (m_oFormMenu.contentWindow) {
        tmpValue = m_oFormMenu.contentWindow.document.getElementsByName(IdName)[0].value;
    }
    else {
        tmpValue = m_oFormMenu.children.item(IdName).value;
    }
    return tmpValue;
}
function set_choiseIdOrName(IdName) {
    var tmpobj;
    if (m_oFormMenu.contentWindow) {
        tmpobj = m_oFormMenu.contentWindow.document.getElementsByName(IdName)[0];
    }
    else {
        tmpobj = m_oFormMenu.children.item(IdName);
    }
    return tmpobj;
}

function replaceCR(s) {
    return s.replace(/\n/g, "<br>");
}

function selectDistRow(e) {
    var evt = (window.event) ? window.event : e;
    var oRow;
    oRow = (evt.srcElement) ? evt.srcElement : evt.target;
    if (oRow != null) {
        switchDistSelectedRow(oRow);
    } else {
        m_selectedDistRow = null;
        m_selectedDistRowId = null;
    }

}

function switchDistSelectedRow(oRow) {
    while (oRow != null && oRow.tagName != "TR") {
        oRow = oRow.parentNode;
    }
    if (oRow != null) {
        if (m_selectedDistRow != null) {
            m_selectedDistRow.style.backgroundColor = "#FFFFFF";
        }

        oRow.style.backgroundColor = "#EEF7F9";
        m_selectedDistRow = oRow;
        m_selectedDistRowId = oRow.id;
    }
}

function changeTab(pStrID) {
    $("#divExt").children("li").each(function (i, oLi) {
        if ($(this).attr("id") == "div" + pStrID) {
            if (pStrID == "tApvLine") $(this).attr("class", "app_line_conf_r_tab_on");
            else $(this).attr("class", "app_line_conf_r_tab_on2");
            $("#divdetail" + pStrID).css({ "display": "block" });
            if ($("#divdetail" + pStrID).html().length == 0) {
            }
        }
        else {
            if (oLi.id == "divtApvLine") $(this).attr("class", "app_line_conf_r_tab_off");
            else $(this).attr("class", "app_line_conf_r_tab_off2");
            $("#divdetail" + ($(this).attr("id")).replace("div", "")).css({ "display": "none" });
        }
    });
}
//*개인결재선 보기/닫기
function fnShowApvLineMgr(pStrMode) {
    //사이즈 조정 넣을 것
    if (pStrMode == "open") {//plus -> open
    	$("#groupTreeDiv").css({"display":"none"}); //조직도 트리 숨김
    	$("#btnOpen").css({"display":"none"});	//open 버튼 비활성화
    	$("#btnClose").css({"display":""});	//close 버튼 비활성화
    	$("#divApvLineMgrSub").css({ "display": "" });
    	$("#orgSearchListMessage").css("left","75px");
    	$("#orgTargetDiv").addClass("active");
    } else {
    	$("#groupTreeDiv").css({"display":""}); //조직도 트리 보기게
    	$("#btnOpen").css({ "display": "block" });
    	$("#btnClose").css({ "display": "none" });
    	$("#divApvLineMgrSub").css({ "display": "none" });
    	$("#orgSearchListMessage").css("left","295px");
    	$("#orgTargetDiv").removeClass("active");
    }
}
// 트리, 검색결과에서 같은 데이터 선택시 체크 (결재선 팝업)
function isDupl(obj, mJson, boolKeynameIncluded, itemType) {
	var tar = obj.json(boolKeynameIncluded).item;
	// 트리 관련된 item 제거
	/*for(var x in tar) {
	    if(x == "__index" || x == "open" || x == "display" || x == "pHash" || x == "hash" || x == "__isLastChild" || x == "__subTreeLength") {
	    	delete tar[x];
	    }
	}*/

	var tarList = (itemType == "user") ? mJson.find("selected > user > item").json(boolKeynameIncluded).item : mJson.find("selected > group > item").json(boolKeynameIncluded).item;
	var duplFg = false;	// 중복 Flag
	
	if (typeof(tarList) != "undefined") {
		var tarLen = tarList.length;
		//var tarStr = JSON.stringify(tar);
		
		if (tarLen > 1) {
			$.each(tarList, function(i, v) {
    			//if (JSON.stringify(v) == tarStr) {
				if (v.AN == tar.AN) {
    				duplFg = true;
    			}	            				
			});
		} else {
			//if (JSON.stringify(tarList) == tarStr) {
			if (tarList.AN == tar.AN) {
				duplFg = true;
			}
		}
	}
	
	return duplFg;
}
//배포처 수정 시작
function addRecDept() {
    var $$_m_Json = $$({
       "selected": {
          "to": {},
          "cc": {},
          "bcc": {},
          "user": {},
          "group": {},
          "role": {}
       }
    });
    var sSelectedUserJson = aContentAdd_OnClick();
    var $$_m_JsonExt = $$(sSelectedUserJson);
    //const BOOL_KEYNAME_INCLUDED = true;  //[IE 10 이하  const 사용 오류]
    var BOOL_KEYNAME_INCLUDED = true;				// 선언 이외의 곳에서 값 변경 X

    var bUser = false;
    $$_m_JsonExt.find("Items > item").concat().each(function (i, $$) {
        var $$_json = $$.json(BOOL_KEYNAME_INCLUDED);
        
        // 선택된 데이터 중 중복 되지 않은 데이터만
    	if (!isDupl($$, $$_m_Json, BOOL_KEYNAME_INCLUDED)) {
    		$$_m_Json.find("selected > group ").append($$_json);
    	}
        
    });
    setDistDept($$_m_Json.find("selected"));
}

function delList(obj) {
	var oSelTR;

	if(obj!=undefined && obj !=null){ //개별 삭제 버튼 (row에 위치하는 삭제 버튼을 클릭한 경우
		oSelTR = $(obj).closest('tr')[0];
	}else{
		 oSelTR = getSelectedDistRow();
	}
   
    var sRecDept = "";
    if (oSelTR != null) {
        if (oSelTR.id != null) {
            var aRecDept = m_RecDept.split(";");
            for (var i = 0; i < aRecDept.length; i++) {
                if (aRecDept[i] != "") {
                    if (aRecDept[i].split(":")[1] == oSelTR.id) {
                        aRecDept[i] = "";
                    }
                }
            }
            for (var i = 0; i < aRecDept.length; i++) {
                if (aRecDept[i] != "") sRecDept += ";" + aRecDept[i];
            }
            m_RecDept = sRecDept;
            if (m_RecDept.indexOf(";") == 0) m_RecDept = m_RecDept.substring(1);
        } else {
            if (oSelTR.type == "0") {
                Common.Warning(strMsg_187); //"배포리스트 구분을 조직도를 선택하세요."
            } else {
                Common.Warning(strMsg_188); //"배포리스트 구분을 배포리스트를 선택하세요."
            }
        }
        chkAction(mType);
    }
}

function delAllList(){
    var otbl = document.getElementById("tblrecinfo");
    var tbllength = otbl.rows.length;
    //Table 지우기
    for (var i = 0; i < tbllength - 2; i++) {
        otbl.deleteRow(tbllength - i - 1);
    }
}
function moveUpDownDeploy(str) {

    var tmpTR;
    var tmpIndex;
    var oSelTR = getSelectedDistRow();
    if (oSelTR == null) {
        Common.Warning(Common.getDic("msg_apv_Line_UnSelect"));
        return false;
    }
    if (oSelTR.id != null) {
        var aRecDept = m_RecDept.split(";");
        for (var i = 0; i < aRecDept.length; i++) {
            if (aRecDept[i] != "") {
                if (aRecDept[i].split(":")[1] == oSelTR.id) {
                    if (str == "UP") {
                        if (i > 0) {
                            var sTemp = "";
                            sTemp = aRecDept[i - 1];
                            aRecDept[i - 1] = aRecDept[i];
                            aRecDept[i] = sTemp;
                        }
                    } else {
                        if (i < aRecDept.length - 1) {
                            var sTemp = "";
                            sTemp = aRecDept[i + 1];
                            aRecDept[i + 1] = aRecDept[i];
                            aRecDept[i] = sTemp;
                            i = aRecDept.length;
                        }
                    }
                }
            }
        }
        var sRecDept = "";
        for (var i = 0; i < aRecDept.length; i++) {
            if (aRecDept[i] != "") sRecDept += ";" + aRecDept[i];
        }
        m_RecDept = sRecDept;
        if (m_RecDept.indexOf(";") == 0) m_RecDept = m_RecDept.substring(1);
        chkAction(mType);
        switchDistSelectedRow($("#" + oSelTR.id)[0]);
    }
}

//배포처 추가 
var mType = 0;
var sCheckBoxFormat = "";
var bchkAbsent = false;
function setDistDept($$_oList) {
	
    var aRecDept = m_RecDept.split(";");
    var elmList, emlNode;
    var sRecDept = "";
    var $$_elmList = $$_oList.find("item");
    
    $$_elmList.concat().each(function (i, $$_emlNode) {
    	if($$_emlNode.has("[OUCODE]").length > 0){ //문서유통인지 코드값 존재유무로 확인
	       if (chkDuplicate($$_emlNode.attr("OUCODE"))) {
	            var sDN = $$_emlNode.attr("UCORGFULLNAME");
	            var sType = "0";
	            
	            sRecDept += ";" + sType + ":" + $$_emlNode.attr("OUCODE");
	            sRecDept += ":" + $$_emlNode.attr("OUORDER");
	            sRecDept += ":" + sDN.replace(/;/gi, "^");
	            sRecDept += ":" + $$_emlNode.attr("OU");
	            sRecDept += ":" + $$_emlNode.attr("TOPOUCODE");
	            sRecDept += ":" + $$_emlNode.attr("DN");
	            sRecDept += ":" + $$_emlNode.attr("REPOUCODE");
	            sRecDept += ":" + $$_emlNode.attr("PARENTOUCODE");
	            sRecDept += ":" + $$_emlNode.attr("PARENTOUNAME");
	            sRecDept += ":" + $$_emlNode.attr("OULEVEL");
	            sRecDept += ":" + $$_emlNode.attr("HASSUBOU");
	            
	            sRecDept += ":X";
	            sRecDept += ":" + $$_emlNode.attr("pon") + "(" + $$_emlNode.attr("UCCHIEFTITLE") + ")" ;	        }
    	} else {
            var sType = "1";
            sRecDept += ";" + sType + ":" + $$_emlNode.attr("ORGCD");
            sRecDept += ":" + $$_emlNode.attr("CMPNYNM");
            sRecDept += ":" + $$_emlNode.attr("SENDERNM");
            sRecDept += ":" + $$_emlNode.attr("BIZNO");
            sRecDept += ":" + $$_emlNode.attr("ADRES");
            sRecDept += ":" + $$_emlNode.attr("HASSUBOU");           
            sRecDept += ":X";
            sRecDept += ":" + $$_emlNode.attr("UCCHIEFTITLE");
        }
    });
    
    if (sRecDept != ""){
	    if(m_RecDept.substring(0,1) != sRecDept.substring(1,2) || $("#govReceiveGubun").val() == "gov24") m_RecDept = sRecDept;
	    else m_RecDept += sRecDept;
	    
    if (m_RecDept.indexOf(";") == 0) m_RecDept = m_RecDept.substring(1);
    chkAction(mType);
	}
}

function chkAction(actType) {
    if (m_sApvMode.toUpperCase() != "DEPTLIST" && m_sApvMode.toUpperCase() != "CFADMIN") {
        mType = actType;

        make_selRec();
        if (mType == "2" && selTab != "tDeployList") {
            changeTab("tDeployList");
        }
    }
}

function make_selRec() {
    var otbl = document.getElementById("tblrecinfo");
    var tbllength = otbl.rows.length;
    //Table 지우기
    for (var i = 0; i < tbllength - 2; i++) {
        otbl.deleteRow(tbllength - i - 1);
    }

    var eTR, eTD, aRec;

    var sRec = m_RecDept.split(";");
    if (m_RecDept == "") return;
    for (var i = 0; i < sRec.length; i++) {
        if (sRec[i] != "" && sRec[i] != null) {
            aRec = sRec[i].split(":");
            eTR = otbl.insertRow(otbl.rows.length);
            
            if( aRec[0] == "0"){
	            eTR.setAttribute("id", aRec[1]);
	            eTR.setAttribute("OUCODE", aRec[1]);
	            eTR.setAttribute("OUORDER", aRec[2]);
	            eTR.setAttribute("UCORGFULLNAME", XFN_Replace(aRec[3], "^", ";"));
	            eTR.setAttribute("OU", aRec[4]);
	            eTR.setAttribute("TOPOUCODE", aRec[5]);
	            eTR.setAttribute("DN", aRec[6]);
	            eTR.setAttribute("REPOUCODE", aRec[7]);
	            eTR.setAttribute("PARENTOUCODE", aRec[8]);
	            eTR.setAttribute("PARENTOUNAME", aRec[9]);
	            eTR.setAttribute("OULEVEL", aRec[10]);
	            eTR.setAttribute("HASSUBOU", aRec[11]);
	            eTR.setAttribute("mType", aRec[0]);
	            eTR.setAttribute("mKind", aRec[12]);
	            eTR.setAttribute("PARENTOUUCCHIEFTITLE", aRec[14]);
            } else {
            	eTR.setAttribute("id", aRec[1]);
	            eTR.setAttribute("ORGCD", aRec[1]);
	            eTR.setAttribute("CMPNYNM", aRec[2]);
	            eTR.setAttribute("SENDERNM", aRec[3]);
	            eTR.setAttribute("BIZNO", aRec[4]);
	            eTR.setAttribute("ADRES", aRec[5]);
	            eTR.setAttribute("HASSUBOU", aRec[6]);
	            eTR.setAttribute("mType", aRec[0]);
	            eTR.setAttribute("mKind", aRec[7]);
            }

            $(eTR).bind("mousedown", selectDistRow);

            var strName = aRec[13];
            if(aRec[0] == "1") strName = aRec[8];
            //JAL
            if(standalone_mode) {
                eTD = eTR.insertCell(eTR.cells.length);
                eTD.innerHTML = strName.split('^')[0];
                eTD.height = 20 + "px";
            } else {
                eTD = eTR.insertCell(eTR.cells.length); eTD.innerHTML = m_oFormEditor.getLngLabel(strName, false, "^"); eTD.height = 20 + "px";
            }
            
            if (aRec[0] == "0") {
                eTD = eTR.insertCell(eTR.cells.length);

                if (aRec[12] == "Y") {
                    eTD.innerHTML = "<INPUT id='' Type='Checkbox' class='input_check8' "
                                    + "onclick=\"changeCheckBox('" + aRec[12] + "','" + aRec[1] + "','" + aRec[3] + "')\" style=\"padding-right=15px\" CHECKED>" + Common.GetDic("lbl_apv_recinfo_td2");
                } else if (aRec[12] == "X") {
                } else {
                    if (sCheckBoxFormat.indexOf(";" + aRec[1] + ":") > -1) {
                        eTD.innerHTML = "<INPUT id='' Type='Checkbox' disabled class='input_check8' "
                                    + "onclick=\"changeCheckBox('" + aRec[12] + "','" + aRec[1] + "','" + aRec[3] + "')\" style=\"padding-right=15px\" >" + Common.GetDic("lbl_apv_recinfo_td2");
                    } else {
                        eTD.innerHTML = "<INPUT id='' Type='Checkbox' class='input_check8' "
                                    + "onclick=\"changeCheckBox('" + aRec[12] + "','" + aRec[1] + "','" + aRec[3] + "')\" style=\"padding-right=15px\" >" + Common.GetDic("lbl_apv_recinfo_td2");
                    }
                }

            } else if (aRec[0] == "1") {
                eTD = eTR.insertCell(eTR.cells.length);
                
            } else {
                eTD = eTR.insertCell(eTR.cells.length);
                eTD.innerHTML = "&nbsp;";
            }
            
            //삭제 버튼 추가
            eTD = eTR.insertCell(eTR.cells.length);
            eTD.innerHTML = "<a href='#' class='icnDel' onclick='delList(this)'>"+Common.getDic("btn_apv_delete")+"</a>";
        }
    }
    return;
}

function chkDuplicate(code) {
    var cmpIndex = m_RecDept.indexOf(code);

    //비슷한 부서코드 추가 시 배포목록에 추가 되지않아 수정
    var arr = new Array();
    var check = true;
    if (m_RecDept.replace(/;/g,"").length > 0) {
        var index = m_RecDept.split(";").length;

        for (var i = 0; i < index; i++) {
            //arr.push(m_RecDept.split(";")[i + 2].split(":")[1]);
        	arr.push(m_RecDept.split(";")[i].split(":")[1]);
        }
    }
    if (arr != '') {
        for (var i = 0; i < arr.length; i++) {
            if (arr[i] == code) {
                check = false;
            }
        }

        return check;
    } else {
        if (cmpIndex < 0) { return true; } else { return false; }
    }
}

function XFN_Replace(pString, pStringMode1, pStringMode2) {
    var sReturn = "";
    var aReturn = pString.split(pStringMode1);
    for (var i = 0; i < aReturn.length; i++) {
        if (i > 0) sReturn += pStringMode2;
        sReturn += aReturn[i];
    }
    if (sReturn == "") sReturn = pString;
    return sReturn;
}

function getSelectedDistRow() { return m_selectedDistRow; }

function changeCheckBox(type, code, name) {

    var sRecDept = m_RecDept;

    if (sRecDept.indexOf(code + ":" + name + ":N") > -1) {
        sRecDept = sRecDept.replace(code + ":" + name + ":N", code + ":" + name + ":Y");
    } else {
        sRecDept = sRecDept.replace(code + ":" + name + ":Y", code + ":" + name + ":N");
    }
    m_RecDept = sRecDept;
}
//배포처 수정 끝

var _aStrDic = Common.getDicAll('lbl_SearchEmployees;lbl_SearchDepartment');

//==========================================
// 3열 추가/삭제 버튼
//==========================================

// 추가 버튼 클릭시 실행되며, 화면에 표시중인 목록/트리 중 선택된 항목을 추가합니다.
// 조직도 트리는 축소(-)해도 선택한 항목을 추가하도록 합니다.
// 선택 목록의 전체/추가 항목에 같은 내용을 추가하도록 합니다.
function aContentAdd_OnClick() {
    function makeItem(oThis, arrItem, bTree){
        if (oThis.is(":checked")) {
            var item = oThis.val().replace(/&/g, "&amp;");
            arrItem.push(JSON.parse(item));
            oThis.attr("checked", false);
        }
    }

    var arrItem = [], item;
    // 트리
    $("input[id^='groupTree_treeCheckbox']").each(function () {
        makeItem($(this), arrItem, true);
    });
    
    $("input[id^='groupTree_treeRadio']").each(function () {
        makeItem($(this), arrItem);
    });

    // 검색/자주선택
    if ($("#divSearchDeptList").css("display") != "none") {
        $("input[id^='orgSearchList_dept']").each(function () {
        	makeItem($(this), arrItem);
        });
    }

    var items = {
        Items: { 
            item: arrItem
        }
    };


    return items;
}

//oList --> 조직도 화면에서 리턴값으로 넘어온 xml 데이타
function insertToList(oList) {
    if (m_sSelectedRouteType == 'dist') {
        setDistDept(oList);
        return true;
    }
    var $$_oSrcDoc = $$(oList);
    
    //결재선에 중복 사용자 삽입 방지
    if (m_sSelectedUnitType != "ou" && m_sApvMode != "SUBREDRAFT" && getInfo("SchemaContext.scChkDuplicateApv.isUse") == "Y") {
        $$_oSrcDoc = chkDuplicateApprover($$_oSrcDoc);
    } else if (m_sSelectedRouteType == "ccinfo") {
        $$_oSrcDoc = chkDuplicateApprover($$_oSrcDoc);
    }
    if ($$_oSrcDoc.find("item").length == 0) {
        return false;
    }
    var index = "";

    $$_oSrcDoc.find("item").concat().each(function (i, $$_element) {

        var arrDivision = [];
        var arrDivisionTaskinfo = [];
        if (m_sSelectedDivisionType == "receive" && m_sSelectedRouteType == "receive") {
            var oTBody = document.getElementById("tblApvLine").lastChild;
            if (oTBody.lastChild != null) { //1 - 발신 없으면 말들기
                if ($(oTBody.lastChild).children().eq(dp_apv_no).text() != "1") {
                    var arrDivisionS = [];
                    var arrDivisionTaskinfoS = [];
                    var arrStepS = [];
                    var arrStepTaskinfoS = [];
                    var arrOuS = [];
                    var arrOuTaskinfoS = [];
                    var arrRolePersonS = [];
                    var arrRolePersonTaskinfoS = [];
                    var arrRolePersonTaskinfoCommentS = [];
                    var arrRolePersonTaskinfoCommentLastS = [];
                    var arrRolePersonTaskinfoCommentFileInfoS = [];
                    var arrRolePersonConsultationS = [];

                    arrDivisionS.push("send"); //division_divisiontype
                    arrDivisionS.push("발신"); //division_name
                    arrDivisionS.push(""); //division_oucode
                    arrDivisionS.push(""); //division_ouname

                    arrDivisionTaskinfoS.push("inactive");
                    arrDivisionTaskinfoS.push("inactive");
                    arrDivisionTaskinfoS.push(m_sSelectedDivisionType);
                    arrDivisionTaskinfoS.push("");
                    arrDivisionTaskinfoS.push("");
                    inserthtmlrow("tblApvLine", 1, viewtype, "True", "Division", arrDivisionS, arrDivisionTaskinfoS, arrStepS, arrStepTaskinfoS, arrOuS, arrOuTaskinfoS, arrRolePersonS, arrRolePersonTaskinfoS, arrRolePersonTaskinfoCommentS, arrRolePersonTaskinfoCommentLastS, arrRolePersonTaskinfoCommentFileInfoS, "", arrRolePersonConsultationS);
                }
            }

            var nDivisionNo = 1;
            {//division 번호 가져 오기
                var oTable = document.getElementById("tblApvLine");
                //if (oTable.childNodes.length <= 1) { colgroup 추가로 변경
                if ($(oTable).find('tbody').length <= 0) {
                    oTBody = document.createElement("TBODY");
                } else {
                    oTBody = oTable.lastChild;
                }
                var nTBodyRow = oTBody.childNodes;
                for (var j = 0; j < nTBodyRow.length; j++) {
                    if ($(nTBodyRow[j].childNodes[key_displayonly]).text() == "True") {
                        nDivisionNo++;
                    }
                }

            }
            //수신처 제한 확인
            if (gRequestDivisionLimit == "" || gRequestDivisionLimit == "0") {
                //제한없음
            } else {
                if ((nDivisionNo - 1) > parseInt(gRequestDivisionLimit)) {
                	Common.Warning(Common.getDic("msg_apvDivisionLimit").replace("0", gRequestDivisionLimit)); //허용된 수신처(0)보다 많습니다. 수신처가 제한됩니다.
                    return false;
                }
            }
            var arrDivisionR = [];
            var arrDivisionTaskinfoR = [];
            var arrStepR = [];
            var arrStepTaskinfoR = [];
            var arrOuR = [];
            var arrOuTaskinfoR = [];
            var arrRolePersonR = [];
            var arrRolePersonTaskinfoR = [];
            var arrRolePersonTaskinfoCommentR = [];
            var arrRolePersonTaskinfoCommentLastR = [];
            var arrRolePersonTaskinfoCommentFileInfoR = [];
            var arrRolePersonConsultationR = [];

            arrDivisionR.push("receive"); //division_divisiontype
            arrDivisionR.push(m_sSelectedStepRef); //division_name
            if($$_element.attr("itemType") == "user"){
            	arrDivisionR.push($$_element.attr('RG')); //division_oucode
            	arrDivisionR.push($$_element.attr('RGNM')); //division_ouname
            }
            else{
            	arrDivisionR.push($$_element.attr('AN')); //division_oucode
            	arrDivisionR.push($$_element.attr('DN')); //division_ouname
            }

            arrDivisionTaskinfoR.push("inactive");
            arrDivisionTaskinfoR.push("inactive");
            arrDivisionTaskinfoR.push(m_sSelectedDivisionType);
            arrDivisionTaskinfoR.push("");
            arrDivisionTaskinfoR.push("");


            inserthtmlrow("tblApvLine", nDivisionNo, viewtype, "True", "Division", arrDivisionR, arrDivisionTaskinfoR, arrStepR, arrStepTaskinfoR, arrOuR, arrOuTaskinfoR, arrRolePersonR, arrRolePersonTaskinfoR, arrRolePersonTaskinfoCommentR, arrRolePersonTaskinfoCommentLastR, arrRolePersonTaskinfoCommentFileInfoR, "", arrRolePersonConsultationR);

            arrDivision.push(m_sSelectedDivisionType); //division_divisiontype
            arrDivision.push(m_sSelectedStepRef); //division_name
            if($$_element.attr("itemType") == "user"){
            	arrDivision.push($$_element.attr('RG')); //division_oucode
            	arrDivision.push($$_element.attr('RGNM')); //division_ouname
            }
            else{
            	arrDivision.push($$_element.attr('AN')); //division_oucode
            	arrDivision.push($$_element.attr('DN')); //division_ouname
            }

            arrDivisionTaskinfo.push("inactive");
            arrDivisionTaskinfo.push("inactive");
            arrDivisionTaskinfo.push(m_sSelectedDivisionType);
            arrDivisionTaskinfo.push("");
            arrDivisionTaskinfo.push("");
        } else if (m_sSelectedStepType == "ccinfo") {
            arrDivision.push(m_sSelectedAllotType); //send,receiver
            arrDivision.push(m_sSelectedDivisionType); //befor,after
            arrDivision.push(""); //division_oucode
            arrDivision.push(m_oFormMenu.getInfo("AppInfo.usid")); //senderid
            arrDivision.push(m_oFormMenu.getInfo("AppInfo.usnm_multi")); //sendername
        } else {
            arrDivision.push(m_sSelectedStepType); //division_divisiontype
            arrDivision.push(m_sSelectedStepRef); //division_name
            arrDivision.push($$_element.attr('RG')); //division_oucode
            arrDivision.push($$_element.attr('RGNM')); //division_ouname
        }

        var arrStep = [];
        arrStep.push(m_sSelectedUnitType); //step_unittype
        arrStep.push(m_sSelectedRouteType); //step_routetype
        arrStep.push(m_sSelectedAllotType); //step_allottype
        arrStep.push(m_sSelectedStepRef); //step_name
        arrStep.push(m_sSelectedRuleApvClass); //step_ruleapvclass
        arrStep.push(m_sSelectedRuleApvClassAtt01); //step_ruleapvclassatt01

        var arrStepTaskinfo = null;
        if (m_sSelectedRouteType == "consult" || m_sSelectedRouteType == "assist" || m_sSelectedRouteType == "audit") {
            arrStepTaskinfo = [];
            arrStepTaskinfo.push("inactive"); //step_taskinfo_status
            arrStepTaskinfo.push("inactive"); //step_taskinfo_result
            if (m_sSelectedRouteType == "consult") {
                arrStepTaskinfo.push("consult"); //step_taskinfo_kind
            } else if (m_sSelectedRouteType == "review") {
                arrStepTaskinfo.push("review"); //step_taskinfo_kind
            } else if (m_sSelectedStepRef == "confirm") {
                arrStepTaskinfo.push("confirm"); //step_taskinfo_kind
            } else if (m_sSelectedStepRef == "reference") {
                arrStepTaskinfo.push("reference"); //step_taskinfo_kind
            } else {
                arrStepTaskinfo.push("normal"); //step_taskinfo_kind
            }
            arrStepTaskinfo.push(""); //step_taskinfo_datereceived
            arrStepTaskinfo.push(""); //step_taskinfo_datecompleted
        }
        //동시결재 taskinfo 추가
        if (m_sSelectedRouteType == "approve" && m_sSelectedAllotType == "parallel") {
            arrStepTaskinfo = [];
            arrStepTaskinfo.push("inactive"); //step_taskinfo_status
            arrStepTaskinfo.push("inactive"); //step_taskinfo_result
            if (m_sSelectedRouteType == "consult") {
                arrStepTaskinfo.push("consult"); //step_taskinfo_kind
            } else if (m_sSelectedRouteType == "review") {
                arrStepTaskinfo.push("confirm"); //step_taskinfo_kind
            } else if (m_sSelectedStepRef == "confirm") {
                arrStepTaskinfo.push("confirm"); //step_taskinfo_kind
            } else if (m_sSelectedStepRef == "reference") {
                arrStepTaskinfo.push("reference"); //step_taskinfo_kind
            } else {
                arrStepTaskinfo.push("normal"); //step_taskinfo_kind
            }
            arrStepTaskinfo.push(""); //step_taskinfo_datereceived
            arrStepTaskinfo.push(""); //step_taskinfo_datecompleted
        }

        var arrOu = [];
        var arrOuTaskinfo = [];
        var arrRolePerson = [];
        var arrRolePersonTaskinfo = [];
        var arrRolePersonTaskinfoComment = [];
        var arrRolePersonTaskinfoCommentLast = null;
        var arrRolePersonTaskinfoCommentFileInfo = null;
        var arrRolePersonConsultation  = null;

        var taskType = "RolePerson";
        
        if (m_sSelectedUnitType == "ou") {
            arrOu.push($$_element.attr('AN')); //ou_code
            arrOu.push($$_element.attr('DN')); //ou_name

            arrOuTaskinfo.push("inactive"); //ou_taskinfo_status
            arrOuTaskinfo.push("inactive"); //ou_taskinfo_result
            switch (m_sSelectedRouteType) {
                case "consult":
                    arrOuTaskinfo.push("consult"); //ou_taskinfo_kind
                    break;
                case "review":
                case "confirm":
                    arrOuTaskinfo.push("confirm"); //ou_taskinfo_kind
                    break;
                case "reference":
                    arrOuTaskinfo.push("reference"); //ou_taskinfo_kind
                    break;
                default:
                    arrOuTaskinfo.push("normal"); //ou_taskinfo_kind
            }
            arrOuTaskinfo.push(""); //ou_taskinfo_datereceived
            arrOuTaskinfo.push(""); //ou_taskinfo_datecompleted
            arrOuTaskinfo.push(""); //ou_taskinfo_piid

            arrRolePerson = null;
            arrRolePersonTaskinfo = null;
            arrRolePersonTaskinfoComment = null;
            arrRolePersonTaskinfoCommentLast = null;
            taskType = "Ou";
        } else {
            arrOu.push($$_element.attr('RG')); //ou_code
            arrOu.push($$_element.attr('RGNM')); //ou_name

            arrOuTaskinfo = null;

            arrRolePerson.push(m_sSelectedUnitType); //roleperson_nodetype
            arrRolePerson.push($$_element.attr("AN")); //roleperson_code
            arrRolePerson.push($$_element.attr("DN")); //roleperson_name
            arrRolePerson.push($$_element.attr("po")); //roleperson_position
            arrRolePerson.push($$_element.attr("tl")); //roleperson_title
            arrRolePerson.push($$_element.attr("lv")); //roleperson_level
            arrRolePerson.push($$_element.attr("SG")); //roleperson_oucode
            arrRolePerson.push($$_element.attr("SGNM")); //roleperson_ouname
            arrRolePerson.push($$_element.attr("SIP")); //roleperson_sipaddress

            arrRolePersonTaskinfo.push("inactive"); //roleperson_taskinfo_status
            arrRolePersonTaskinfo.push("inactive"); //roleperson_taskinfo_result

            if (m_sSelectedRouteType == "consult") {
                arrRolePersonTaskinfo.push("consult"); //roleperson_taskinfo_kind
            } else if (m_sSelectedRouteType == "review") {
                arrRolePersonTaskinfo.push("confirm"); //roleperson_taskinfo_kind
            } else if (m_sSelectedStepRef == "confirm") {
                arrRolePersonTaskinfo.push("confirm"); //roleperson_taskinfo_kind
            } else if (m_sSelectedStepRef == "reference") {
                arrRolePersonTaskinfo.push("reference"); //roleperson_taskinfo_kind
            } else if(m_sSelectedStepRef == strlable_charge_approve) { // 담당결재(담당자 지정)
            	arrRolePersonTaskinfo.push("charge"); //roleperson_taskinfo_kind
            } else {
                arrRolePersonTaskinfo.push("normal"); //roleperson_taskinfo_kind
            }

            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_datereceived
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_datecompleted
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_rejectee
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_wiidrejectedto
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_daterejectedto
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_wiid
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_visible
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_customattribute1
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_customattribute2
            arrRolePersonTaskinfo.push(""); //roleperson_taskinfo_mobilegubun  //모바일 결재 여부

            arrRolePersonTaskinfoComment = null;
            arrRolePersonTaskinfoCommentLast = null;
            arrRolePersonTaskinfoCommentFileInfo = null;
            taskType = "RolePerson";
        }
        if (m_sSelectedRouteType == "ccinfo") {
            inserthtmlrowCC("tblccinfo", taskType, arrDivision, arrOu, arrRolePerson);
        } else {
            inserthtmlrow("tblApvLine", index, viewtype, "False", taskType, arrDivision, arrDivisionTaskinfo, arrStep, arrStepTaskinfo, arrOu, arrOuTaskinfo, arrRolePerson, arrRolePersonTaskinfo, arrRolePersonTaskinfoComment, arrRolePersonTaskinfoCommentLast, arrRolePersonTaskinfoCommentFileInfo,"", arrRolePersonConsultation);
        }
    }
	);

    return true;
}

//JAL-소스위치이동
$(window).load(function () {
    //결재선목록처리
    initialize();
});

$(document).mousedown(function(e){
	if($("#dvCommonList").css('display')!='none'){
		var btnList = $("#dvCommonList");
		
		if (!btnList.is(e.target) && btnList.has(e.target).length === 0){
			btnList.css("display","none");
		}
	}
});

var strMsg_187 = Common.getDic("msg_apv_187");
var strMsg_188 = Common.getDic("msg_apv_188");
var gHasPrivateLines = false;
var gRequestDivisionLimit = Common.getBaseConfig("RequestDivisionLimit");
//결재자 선택 관련 종료