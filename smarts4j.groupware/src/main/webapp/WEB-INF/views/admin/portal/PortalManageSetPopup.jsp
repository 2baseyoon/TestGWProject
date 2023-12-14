<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<div>				
	<table class="AXFormTable" >
	  <colgroup>
          <col style="width:85px;"/>
          <col />
          <col style="width:85px;"/>
          <col />
      </colgroup>
	  <tbody>
		<tr>
		  <th><spring:message code="Cache.lbl_PortalManage_03"/><font color="red">*</font></th> <!-- 포탈명칭  -->
		  <td colspan="3">
		  	<input id="portalName" name="portalName" type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width:83%"/> 
		  	<input id="hidNameDicInfo" name="hidNameDicInfo" type="hidden" />
		  	<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="dictionaryLayerPopup();" /> <!-- 다국어 -->
		  </td> 
	    </tr>
	    <tr>
	      <th><spring:message code="Cache.lbl_PortalManage_01"/><font color="red">*</font></th>  <!-- 포탈유형  -->
		  <td><select id="portalTypeSelectBox" name="portalTypeSelectBox" class="AXSelect W100"></select> </td>
	      <th><spring:message code="Cache.lbl_OwnedCompany"/><font color="red">*</font></th>   <!-- 소유회사  -->
		  <td><select id="companySelectBox" name="companySelectBox" class="AXSelect W100" onchange="ddlCompany_OnChange();"></select> </td>
	    </tr>
	    <tr>
	      <th><spring:message code="Cache.lbl_PortalManage_02"/><font color="red">*</font></th> <!-- 레이아웃  -->
		  <td><select id="layoutSelectBox" name="layoutSelectBox" class="AXSelect W100"></select> </td>
	      <th><spring:message code="Cache.lbl_BizSection"/><font color="red">*</font></th> <!-- 업무구분  -->
		  <td><select id="bizSectionSelectBox" name="bizSectionSelectBox" class="AXSelect W100"></select> </td>
	    </tr>
		<tr>
		  <th><spring:message code="Cache.lbl_Theme"/><font color="red">*</font></th> <!--테마-->
		  <td><select id="themeSelectBox" name="themeSelectBox" class="AXSelect W100"></select> </td>
		  <th><spring:message code="Cache.lbl_PriorityOrder"/><font color="red">*</font></th> <!--우선순위 -->
		  <td><input id="sortKey" name="sortKey" type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width:93px;"/></td>
	    </tr>
	   	<tr>
		  <th><spring:message code="Cache.lbl_portal"/><spring:message code="Cache.lbl_Code"/></th> <!--포탈코드-->
		  <td colspan="3">
			  <input id="portalCode" name="portalCode" type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width:93px;"/> 
			  <p class ="explain"><spring:message code="Cache.msg_portalcode_info"/></p>
		  </td>
	    </tr>
		<tr>
		  <th><spring:message code="Cache.lbl_Permissions"/><font color="red">*</font></th> <!--사용권한 -->
		  <td colspan="3">
	  		 <div style="width: 97%;padding: 3px;border:1px solid #ececec;background-color:#f9f9f9;border-radius: 5px;" align="right">
  		 		<input id="add" type="button" value="<spring:message code="Cache.btn_Add"/>" class="AXButtonSmall" onclick="permissionAdd()">
  		 		<input id="del" type="button" value="<spring:message code="Cache.btn_delete"/>" class="AXButtonSmall" onclick="permissionDel()">
             </div>
             <div id="divPermissions" style="width: 98%; height: 134px; overflow: scroll; overflow-x: hidden;">
                <table cellpadding="0" cellspacing="0" id="hTblPermissions" style="width: 100%; font-size: 13px;">
                   <colgroup>
                       <col width="33px" />
                       <col width="150px" />
                       <col />
                       <col width="150px" />
                   </colgroup>
                  <thead id="hThdPermissions"></thead> <!--소유회사 -->
                  <tbody id="hTbdPermissions"></tbody> <!--소유회사 이외 -->
                </table>
             </div>
		  </td>
	    </tr>
		<tr>
		  <th><spring:message code="Cache.lbl_URL"/></th> <!--URL -->
		  <td colspan="3">
		  	<input id="url" name="url" type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width:96%"/> 
		  </td>
	    </tr>
		<tr>
		  <th><spring:message code="Cache.lbl_Description"/></th> <!--설명 -->
		  <td colspan="3">
		  	<textarea id="description" rows="5" style="width: 96%; margin: 0px;  resize:none;" id="desc" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea> 
		  </td>
	    </tr>
	   </tbody>
	</table>
	<div align="center" style="padding-top: 10px">
		<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="savePortal();" class="AXButton red" />
		<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="javascript:Common.Close(); return false;"  class="AXButton" />
	</div>
	
	<div style="display: none;">
        <input type="hidden" id="txtPermissionInfo_Old" /> <!--수정 시 기존 데이터  -->
        <input type="hidden" id="txtPermissionInfo_Del" /> <!--실제 삭제될 데이터  -->
        <input type="hidden" id="txtPermissionInfo" />	<!--저장 될 데이터  -->
    </div>
</div>

<script  type="text/javascript">

//# sourceURL=PortalManageSetPopup.jsp
var _intIndex = 0;
var aStrDictionary = Common.getDicAll(["lbl_ACL_Allow","lbl_ACL_Denial","lbl_User","lbl_company","lbl_group"]);

var portalID = CFN_GetQueryString("portalID") == 'undefined'? 0 : CFN_GetQueryString("portalID"); //수정이나 복사시 portalID
var mode = CFN_GetQueryString("mode") == 'undefined'? '' : CFN_GetQueryString("mode"); // copy or add or modify
var lang = Common.getSession("lang");

// ready
init();

function init(){
	
	setPopUpSelectBox(); //select box 컨트롤 바인딩
		
	if(portalID!=0){
		setPortalData(portalID); //수정이나 복사 시 데이터 셋팅
	}else{
		ddlCompany_OnChange();
	}
}

//수정이나 복사의 경우 데이터 조회
function setPortalData(portalID){
	$.ajax({
		type:"POST",
		url:"/groupware/portal/getPortalData.do",
		data:{
			"portalID":portalID
		},
		success:function(portalData){
			permissionAdd_CallBack(JSON.stringify(portalData.data));
			settingInput(portalData.data.portal);
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/portal/getPortalData.do", response, status, error);
		}
	});
}

//다국어 설정 팝업
function dictionaryLayerPopup(){
	var option = {
			lang : lang,
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh,lang1,lang2',
			useShort : 'false',
			dicCallback : 'dicCallback',
			popupTargetID : 'setMultiLangData',
			init : 'dicInit'
	};
	
	var url = "";
	url += "/covicore/control/calldic.do?lang=" + option.lang;
	url += "&hasTransBtn=" + option.hasTransBtn;
	url += "&useShort=" + option.useShort;
	url += "&dicCallback=" + option.dicCallback;
	url += "&allowedLang=" + option.allowedLang;
	url += "&popupTargetID=" + option.popupTargetID;
	url += "&init=" + option.init;
	
	Common.open("","setMultiLangData","<spring:message code='Cache.lbl_MultiLangSet' />",url,"400px","280px","iframe",true,null,null,true);
}

//다국어 세팅 함수
function dicInit(){
	if(document.getElementById("hidNameDicInfo").value == ''){
		value = document.getElementById('portalName').value;
	}else{
		value = document.getElementById("hidNameDicInfo").value;
	}
	
	return value;
}

//다국어 콜백 함수
function dicCallback(data){
	$("#hidNameDicInfo").val(coviDic.convertDic(data));
	if(document.getElementById('portalName').value == ''){
		document.getElementById('portalName').value = CFN_GetDicInfo(coviDic.convertDic(data),lang);
	}
	
	Common.Close("setMultiLangData");
}


function setPopUpSelectBox(){
	$.ajax({
		type:"POST",
		url:"/groupware/portal/getSelectBoxData.do",
		async:false, 
		success:function(data){
			$("#layoutSelectBox").bindSelect({
				options: data.layoutList,
			});
			
			$("#themeSelectBox").bindSelect({
				options: data.themeList,
			});
		}
	});
	
	coviCtrl.renderCompanyAXSelect("companySelectBox",lang,false,"","",'');
	
	coviCtrl.renderAXSelect("BizSection,PortalType","bizSectionSelectBox,portalTypeSelectBox",	lang,	"", 	"", 	"");
}

//수정이나 복사 시 조회해서 특정 포탈 데이터를 화면에 셋팅
function settingInput(portal){
	if(mode !='copy'){
		$("#portalName").val(portal.DisplayName);
		$("#hidNameDicInfo").val(portal.MultiDisplayName);
	}
	
	if(mode != 'add'){
		$("#layoutSelectBox").bindSelectDisabled(true)
	}
	
	$("#portalTypeSelectBox").bindSelectSetValue(portal.PortalType);
	$("#companySelectBox").bindSelectSetValue(portal.CompanyCode);
	$("#layoutSelectBox").bindSelectSetValue(portal.LayoutID);
	$("#bizSectionSelectBox").bindSelectSetValue(portal.BizSection);
	$("#themeSelectBox").bindSelectSetValue(portal.ThemeCode);
	$("#sortKey").val(portal.SortKey);
	$("#portalCode").val(portal.PortalCode);
	$("#url").val(portal.URL);
	$("#description").val(portal.Description);
}

//사용 권한 추가 버튼 클릭
function permissionAdd(){
	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=permissionAdd_CallBack&type=D9&openerID=setPortal","1060px","580px","iframe",true,null,null,true);
}

//사용 권한 추가 후 호출
function permissionAdd_CallBack(orgData){
	var isDup = false;
 	var sHTML = "";
    var sObjectType = "";
    var sObjectType_A = "";
    var sCode = "";
    var sDNCode = "";
    var sDisplayName = "";
    var sPermission = "A";
    var bCheck = false;
    
    //oJsonOrgMap.item[0].PO
	var permissionJSON =  $.parseJSON(orgData);
	
  	$(permissionJSON.item).each(function (i, item) {
  		sObjectType = item.itemType
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			sObjectTypeText = aStrDictionary["lbl_User"]; // 사용자
  			sObjectType_A = "UR";
  			sCode = item.AN;//UR_Code
  			sDisplayName = CFN_GetDicInfo(item.DN);
  			sDNCode = item.DN_Code; //DN_Code
  		}else{ //그룹
  			switch(item.GroupType.toUpperCase()){
	  			 case "COMPANY":
	                 sObjectTypeText = aStrDictionary["lbl_company"]; // 회사
	                 sObjectType_A = "CM";
	                 break;
	             case "JOBLEVEL":
	                 //sObjectTypeText = "직급";
	                 //sObjectType_A = "JL";
	                 //break;
	             case "JOBPOSITION":
	                 //sObjectTypeText = "직위";
	                 //sObjectType_A = "JP";
	                 //break;
	             case "JOBTITLE":
	                 //sObjectTypeText = "직책";
	                 //sObjectType_A = "JT";
	                 //break;
	             case "MANAGE":
	                 //sObjectTypeText = "관리";
	                 //sObjectType_A = "MN";
	                 //break;
	             case "OFFICER":
	                 //sObjectTypeText = "임원";
	                 //sObjectType_A = "OF";
	                 //break;
	             case "DEPT":
	                 sObjectTypeText = aStrDictionary["lbl_group"]; // 그룹
	                 //sObjectTypeText = "부서";
	                 sObjectType_A = "GR";
	                 break;
         	}
  		
  			sCode = item.AN
            sDisplayName = CFN_GetDicInfo(item.GroupName);
            sDNCode = item.DN_Code;
  		}
  		
  		 bCheck = false;
  		 //중복 체크
         $("#hThdPermissions").children().each(function () {
             if (($(this).attr("objecttype").toUpperCase() == sObjectType.toUpperCase()) &&
                 ($(this).attr("objectcode") == sCode)) {
                 bCheck = true;
             }
         });
         $("#hTbdPermissions").children().each(function () {
             if (($(this).attr("objecttype").toUpperCase() == sObjectType.toUpperCase()) &&
                 ($(this).attr("objectcode") == sCode)) {
                 bCheck = true;
             }
         });
  		 
  		 
         if (!bCheck) {
             sPermission = "A";
             if (String($(this).attr("Permission")).toUpperCase() == "D") {
                 sPermission = "D"
             }

             sHTML += PermissionRowAdd(_intIndex, sCode, sObjectType, sObjectType_A, sDNCode, sDisplayName, sObjectTypeText, sPermission, "");
             _intIndex++;
         }
 	});
  	
  	$("#hTbdPermissions").append(sHTML);
}

//사용권한에 사용자/그룹을 추가하는 HTML을 생성합니다.
function PermissionRowAdd(pStrIndex, pStrCode, pStrObjectType, pStrObjectType_A, pStrDNCode, pStrDisplayName, pStrObjectTypeText, pStrPermission, pStrDisabled) {
    var sHTML = "";
    sHTML += "<tr objectcode=\"" + pStrCode + "\" objecttype=\"" + pStrObjectType + "\" objecttype_a=\"" + pStrObjectType_A + "\" dncode=\"" + pStrDNCode + "\" displayname=\"" + pStrDisplayName + "\" objecttypetext=\"" + pStrObjectTypeText + "\" >";
    sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
    sHTML +=        "<input name=\"chkPermissions\" type=\"checkbox\" class=\"input_check\" " + pStrDisabled + " />";
    sHTML +=    "</td>";
    sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
    if (pStrObjectType == "user") {
        //sHTML +=    "<span style='cursor:hand' onclick=\"XFN_ShowContextMenuConnectUser(event, '" + pStrCode + "', '" + pStrSipAddress + "', '" + pStrMailAddress + "', '" + pStrMobilePhone + "');\">";
        sHTML +=        "<img src=\"/HtmlSite/smarts4j_n/covicore/resources/images/covision/ico_ad02.gif\" />";
        sHTML +=        " " + pStrDisplayName + "</a>";
        //sHTML +=    "</span>";
    }
    else {
        sHTML +=    "<img src=\"/HtmlSite/smarts4j_n/covicore/resources/images/covision/ico_ad01.gif\" />";
        sHTML +=    " " + pStrDisplayName + "</a>";
    }
    sHTML +=    "</td>";
    sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">" + pStrObjectTypeText + "</td>";
    sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
    sHTML +=        "<input id=\"rdoPermissions_" + pStrIndex + "_A\" name=\"rdoPermissions_" + pStrIndex + "\" type=\"radio\" style=\"cursor: pointer;\" class=\"radio_02\" value=\"A\"";
    if (pStrPermission == "A") {
        sHTML += " checked=\"checked\"";
    }
    sHTML += " />";
    sHTML +=        "<label for=\"rdoPermissions_" + pStrIndex + "_A\" style=\"cursor: pointer;\"> " + aStrDictionary["lbl_ACL_Allow"] + "</label>&nbsp;&nbsp;";
    sHTML +=        "<input id=\"rdoPermissions_" + pStrIndex + "_D\" name=\"rdoPermissions_" + pStrIndex + "\" type=\"radio\" style=\"cursor: pointer;\" class=\"radio_02\" value=\"D\"";
    if (pStrPermission != "A") {
        sHTML += " checked=\"checked\"";
    }
    sHTML += " />";
    sHTML +=        "<label for=\"rdoPermissions_" + pStrIndex + "_D\" style=\"cursor: pointer;\"> " + aStrDictionary["lbl_ACL_Denial"] + "</label>";
    sHTML +=    "</td>";
    sHTML += "</tr>";
    return sHTML;
}


//사용권한 삭제 버튼 클릭시 실행되며, 선택된 항목을 목록에서 삭제함.
function permissionDel() {
    if ($("input[name='chkPermissions']:checked").length > 0) {
        Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
            if (result) {
                $("input[name='chkPermissions']:checked").each(function () {
                    txtPermissionInfo_Del_Binding($(this).parent().parent());
                    $(this).parent().parent().remove();
                });
            }
        });
    } else {
        Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
        return;
    }
}


// 삭제할 데이터를 보관함.
function txtPermissionInfo_Del_Binding(pObjTR) {
	var Item = new Object();
	Item.AN =  pObjTR.attr("objectcode");
	Item.ObjectType_A = pObjTR.attr("objecttype_a");
	Item.DN_Code = pObjTR.attr("dncode");
	
	if(document.getElementById("txtPermissionInfo_Del").value == ''){
		var deleteItemInfos = new Object();
		deleteItemInfos.item = Item;
		document.getElementById("txtPermissionInfo_Del").value = JSON.stringify(deleteItemInfos);
	}else{
		var txtDeleteItemInfos = $.parseJSON(document.getElementById("txtPermissionInfo_Del").value);
		$$(txtDeleteItemInfos).append("item",Item);
		document.getElementById("txtPermissionInfo_Del").value = JSON.stringify(txtDeleteItemInfos)
	}
}



// 소유회사 변경시 사용권한에 자동 추가
// 기존 소유회사는 삭제
function ddlCompany_OnChange() {

    var sCode = document.getElementById("companySelectBox").value;
    var sObjectType = "group";
    var sPermission = "A";  // Allow : 허용
    
    $("#hThdPermissions").children().each(function () {
        txtPermissionInfo_Del_Binding($(this));
        $(this).remove();
    });
    $("#hTbdPermissions").children().each(function () {
        if (($(this).attr("objectcode") == sCode) &&
            ($(this).attr("objecttype") == sObjectType)) {
            sPermission = $(this).children("TD:last").children("INPUT[id^=rdoPermissions_]:checked").val();
            txtPermissionInfo_Del_Binding($(this));
            $(this).remove();
        }
    });

    if (document.getElementById("companySelectBox").value == "") {
        return;
    }
    var sDNCode = document.getElementById("companySelectBox").value;
    var sObjectType_A = "CM";
    var sDisplayName = document.getElementById("companySelectBox").options[document.getElementById("companySelectBox").selectedIndex].text
    var sObjectTypeText = aStrDictionary["lbl_company"]; // 회사
    var sHTML = PermissionRowAdd("", sCode, sObjectType, sObjectType_A, sDNCode, sDisplayName, sObjectTypeText, sPermission, "disabled=\"true\"") 
    $("#hThdPermissions").append(sHTML);
}

// 저장 버튼 클릭시 실행되며, 내용을 저장한 후 화면을 종료합니다.
function savePortal() {
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

    var bReturn = true;
    if (document.getElementById("portalName").value == "") {
        parent.Common.Warning("<spring:message code='Cache.msg_PortalManage_07'/>", "Warning Dialog", function () {     // 포탈명칭을 입력하여 주십시오.
        	document.getElementById("portalName").focus();
        });
        return;
    }

    var aStrSpecialChar = new Array(";", "'", "^");
    var nLength = aStrSpecialChar.length;
    for (var i = 0; i < nLength; i++) {
        if (document.getElementById("portalName").value.indexOf(aStrSpecialChar[i]) >= 0) {
            var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01'/>";  // 특수문자 [{0}]는 사용할 수 없습니다.
            sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
            Common.Warning(sMessage, 'Warning Dialog', function () {
            	document.getElementById("portalName").select();
            });
            return;
        }
    }

    if (document.getElementById("portalTypeSelectBox").value == "PortalType" || document.getElementById("portalTypeSelectBox").value == "") {
        parent.Common.Warning("<spring:message code='Cache.msg_PortalManage_03'/>", "Warning Dialog", function () {     // 포탈유형을 선택하여 주십시오.
            document.getElementById("portalTypeSelectBox").focus();
        });
        return;
    }

    if (document.getElementById("companySelectBox").value == "") {
        parent.Common.Warning("<spring:message code='Cache.msg_PortalManage_05'/>", "Warning Dialog", function () {     // 소유회사를 선택하여 주십시오.
            document.getElementById("companySelectBox").focus();
        });
        return;
    }

    if (document.getElementById("layoutSelectBox").value == "") {
        parent.Common.Warning("<spring:message code='Cache.msg_PortalManage_06'/>", "Warning Dialog", function () {     // 레이아웃을 선택하여 주십시오.
            document.getElementById("layoutSelectBox").focus();
        });
        return;
    }
    
    if (document.getElementById("bizSectionSelectBox").value == "" || document.getElementById("bizSectionSelectBox").value == "BizSection") {
        parent.Common.Warning("<spring:message code='Cache.msg_AllList_03'/>", "Warning Dialog", function () {    /* 업무구분을 선택하여 주십시오. */
            document.getElementById("bizSectionSelectBox").focus();
        });
        return;
    }

    if (document.getElementById("themeSelectBox").value == "") {
        parent.Common.Warning("<spring:message code='Cache.lbl_PlzEnterUrThemeName'/>", "Warning Dialog", function () {    /* 테마명을 입력해주세요 */
            document.getElementById("themeSelectBox").focus();
        });
        return;
    }

    if (document.getElementById("sortKey").value == "") {
        parent.Common.Warning("<spring:message code='Cache.msg_Common_02'/>", "Warning Dialog", function () {           // 우선순위를 입력하여 주십시오.
            document.getElementById("sortKey").focus();
        });
        return;
    }

    var Items = new Object();
   
    var sPermission = "";

    // 소유회사
    $("#hThdPermissions").children().each(function () {
    	var item = new Object();
        sPermission = $(this).children("TD:last").children("INPUT[id^=rdoPermissions_]:checked").val();
        item.type = "group";
        item.objecttype = ConfirmOldNew($(this).attr("objecttype_a"), $(this).attr("dncode"), $(this).attr("objectcode"));
        item.AN =  $(this).attr("objectcode");
        item.ObjectType_A = $(this).attr("objecttype_a");
        item.DN_Code = $(this).attr("dncode");
        item.DisplayName = $(this).attr("displayname");
        item.Permission = sPermission
       	$$(Items).append("item", item);
    });

    // 기타
    $("#hTbdPermissions").children().each(function () {
        sPermission = $(this).children("TD:last").children("INPUT[id^=rdoPermissions_]:checked").val();
    	var item = new Object();
        if ($(this).attr("objecttype").toUpperCase() == "USER") {
        	item.type = "user";
            item.ObjectType = ConfirmOldNew($(this).attr("objecttype_a"), $(this).attr("dncode"), $(this).attr("objectcode"));
            item.AN =  $(this).attr("objectcode");
            item.ObjectType_A = $(this).attr("objecttype_a");
            item.DN_Code = $(this).attr("dncode");
            item.DisplayName = $(this).attr("displayname");
            item.Permission = sPermission
        }
        else {
        	item.type = "group";
            item.ObjectType = ConfirmOldNew($(this).attr("objecttype_a"), $(this).attr("dncode"), $(this).attr("objectcode"));
            item.AN =  $(this).attr("objectcode");
            item.ObjectType_A = $(this).attr("objecttype_a");
            item.DN_Code = $(this).attr("dncode");
            item.DisplayName = $(this).attr("displayname");
            item.Permission = sPermission
        }
    	$$(Items).append("item", item);
    });

    if (JSON.stringify(Items) == '{}') {
        parent.Common.Warning("<spring:message code='Cache.msg_Common_01'/>", "Warning Dialog", function () { });   // 사용권한을 설정하여 주십시오.
        return;
    }
    
    $("#txtPermissionInfo").val(JSON.stringify(Items));

    ConfirmDel();

    var sDictionaryInfo = document.getElementById("hidNameDicInfo").value;
    if (sDictionaryInfo == "") {
        switch (Common.getSession("lang").toUpperCase()) {
            case "KO": sDictionaryInfo = document.getElementById("portalName").value + ";;;;;;;;;"; break;
            case "EN": sDictionaryInfo = ";" + document.getElementById("portalName").value + ";;;;;;;;"; break;
            case "JA": sDictionaryInfo = ";;" + document.getElementById("portalName").value + ";;;;;;;"; break;
            case "ZH": sDictionaryInfo = ";;;" + document.getElementById("portalName").value + ";;;;;;"; break;
            case "E1": sDictionaryInfo = ";;;;" + document.getElementById("portalName").value + ";;;;;"; break;
            case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("portalName").value + ";;;;"; break;
            case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("portalName").value + ";;;"; break;
            case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("portalName").value + ";;"; break;
            case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("portalName").value + ";"; break;
            case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("portalName").value; break;
        }
        document.getElementById("hidNameDicInfo").value = sDictionaryInfo
    }
     
    var url;
    
	if(portalID !=0 && mode!='copy'){			
		url = "/groupware/portal/updatePortalData.do";			
	}else{
		url = "/groupware/portal/insertPortalData.do";
	}
    
	var arrActionData = [];
	var permissionText = $("#txtPermissionInfo").val();
	var permissionDelText = $("#txtPermissionInfo_Del").val();
	
	if(permissionText != ""){
		var permissionJSON = JSON.parse(permissionText);
		$(permissionJSON.item).each(function(idx, obj) {
			var actionData = {
				"SubjectType" : obj.ObjectType_A,
				"SubjectCode" : obj.AN
			}
			
			arrActionData.push(actionData);
		});	
	}
	
	if(permissionDelText != "") {
		var permissionDelJSON = JSON.parse(permissionDelText);
		
		$(permissionDelJSON.item).each(function(idx, obj) {
			var actionData = {
				"SubjectType" : obj.ObjectType_A,
				"SubjectCode" : obj.AN
			}
			
			arrActionData.push(actionData);
		});
	}
	
	
	var aclActionData = JSON.stringify(arrActionData)

	aclActionData = aclActionData == undefined ? "[]" : aclActionData;
    $.ajax({
    	type:"POST",
    	url: url,
    	dataType : 'json',
    	data:{
    		"portalID": portalID, 
    		"mode":mode,//'copy' or ''
    		"portalName": $("#portalName").val(),
    		"dicPortalName": $("#hidNameDicInfo").val(),
    		"companyCode": $("#companySelectBox").val(),
    		"layoutID": $("#layoutSelectBox").val(),
    		"portalType": $("#portalTypeSelectBox").val(),
    		"bizSection": $("#bizSectionSelectBox").val(),
    		"themeCode": $("#themeSelectBox").val(),
    		"sortKey": $("#sortKey").val(),
    		"portalCode": $("#portalCode").val(),
    		"url": $("#url").val(),
    		"description": $("#description").val(),
    		"permission":  $("#txtPermissionInfo").val(),
    		"permissionDel": $("#txtPermissionInfo_Del").val(),
    		"actionData": aclActionData
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			/*저장되었습니다.*/
	    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
					if(parent.portalGrid != undefined){parent.portalGrid.reloadList();}		    			
	    			Common.Close();
	    		});
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
    		}
    	}, 
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    	     CFN_ErrorAjax(url, response, status, error);
    	}
    	
    });
  
}

// 권한이 추가되어 있는 데이터의 기존/신규 확인
function ConfirmOldNew(pStrObjectType_A, pStrDNCode, pStrCode) {
    var bIsOLD = false;
    // 기존 데이터 확인
    if (document.getElementById("txtPermissionInfo_Old").value != "") {
        $$(document.getElementById("txtPermissionInfo_Old").value).find("item").concat().each(function (i,obj) {
            if (pStrObjectType_A == $$(obj).attr("ObjectType_A")) {
                if ((pStrObjectType_A == "CM") && (pStrDNCode == $$(obj).attr("AN"))) {
                    bIsOLD = true;
                }
                else if (pStrCode == $(this).find("AN").text()) {
                	bIsOLD = true;
                }
            }
        });
    }
    if (bIsOLD) {
        return "OLD";
    }
    else {
        return "NEW";
    }
}

// 삭제할 데이터 확인
function ConfirmDel() {
	var deleteItemInfos = new Object();

    var sObjectType_A = "";
    var sDNCode = "";
    var sCode = "";
    var sTempKey = "";
    var bDelete = false;

    // 삭제 데이터 XML 재 생성: 중복 개체 제거
    var sDelJSON = document.getElementById("txtPermissionInfo_Del").value;
    if(sDelJSON != ''){
	    $$(sDelJSON).find("item").concat().each(function (i,obj) {
	        sObjectType_A = $$(obj).attr("ObjectType_A");
	        sDNCode = $$(obj).attr("DN_Code");
	        sCode = $$(obj).attr("AN");
	        
	        bDelete = true; //삭제 여부 
	        $$(document.getElementById("txtPermissionInfo").value).find("item").concat().each(function () {
	            if (sObjectType_A.toUpperCase() == $(this).find("ObjectType_A").text().toUpperCase()) {
	                if ((sObjectType_A.toUpperCase() == "CM") && (sDNCode == $(this).find("AN").text())) {
	                    bDelete = false;
	                }
	                else if ((sCode == $(this).find("AN").text())) {
	                    bDelete = false;
	                }
	            }
	        });
	        
	        
	        var Item = new Object();
	        
	        if (bDelete) {
	            if (sTempKey.indexOf(";" + sObjectType_A + sCode + sDNCode + ";") < 0) {
	                Item.AN = sCode;
	                Item.ObjectType_A = sObjectType_A;
	                Item.DN_Code = sDNCode;
	                $$(deleteItemInfos).append("item",Item);
	                sTempKey += ";" + sObjectType_A + sCode + sDNCode + ";";
	            }
	        }
	    });
    }
   
    document.getElementById("txtPermissionInfo_Del").value = JSON.stringify(deleteItemInfos);
}




</script>
