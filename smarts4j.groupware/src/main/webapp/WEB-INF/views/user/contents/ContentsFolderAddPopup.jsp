<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	
	<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104;">
		<div class="" style="overflow:hidden; padding:0;">
			<div class="ATMgt_popup_wrap">
				<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<td class="ATMgt_T_th" >
								<spring:message code='Cache.lbl_apv_folderName'/>
							</td>
							<td>
								<div class="ATMgt_T"><div class="ATMgt_T_l">
									<input id="folderName" name="folderName" value="" type="text" class="HtmlCheckXSS ScriptCheckXSS" style="width: 80%" />
									<input id="hidFolderNameDicInfo" name="hidFolderNameDicInfo" value="" type="hidden" />
									<input type="button" id="dicBtn" class="AXButton" value="<spring:message code='Cache.lbl_MultiLang2'/>" />
								</div></div>
								
							</td>
						</tr>	
					</tbody>	
				</table>
				<div class="bottom" style="margin-top: 20px;">
					<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_Save'/></a>
					<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
				</div>
			</div>				
		</div>
	</div>
</body>
<script type="text/javascript">
var folderID = "${folderID}";
var bizSection = "Board";
var domainID = Common.getSession("DN_ID");
var mode = "create";

var nameChange = {
	objectInit : function(){			
		this.addEvent();
	}	,
	addEvent : function(){
		
		$("#selectMenuID").coviCtrl(
			"setSelectOption",
			"/groupware/board/manage/selectManageMenuList.do",
			{"domainID": domainID, "bizSection": bizSection},
			"<spring:message code='Cache.lbl_selectMenu'/>", // 메뉴 선택
			""
		).val("");
		
		selectBoardConfig(); // 폴더 옵션 조회
		
		// 다국어
		$("#dicBtn").off("click").on("click", function(){
			openDictionaryPopup();
		});
		
		$("#folderName").on("change", function(){
			var sDictionaryInfo = '';
			switch (Common.getSession("lang").toUpperCase()) {
		        case "KO": sDictionaryInfo = this.value + ";;;;;;;;;"; break;
		        case "EN": sDictionaryInfo = ";" + this.value + ";;;;;;;;"; break;
		        case "JA": sDictionaryInfo = ";;" + this.value + ";;;;;;;"; break;
		        case "ZH": sDictionaryInfo = ";;;" + this.value + ";;;;;;"; break;
		        case "E1": sDictionaryInfo = ";;;;" + this.value + ";;;;;"; break;
		        case "E2": sDictionaryInfo = ";;;;;" + this.value + ";;;;"; break;
		        case "E3": sDictionaryInfo = ";;;;;;" + this.value + ";;;"; break;
		        case "E4": sDictionaryInfo = ";;;;;;;" + this.value + ";;"; break;
		        case "E5": sDictionaryInfo = ";;;;;;;;" + this.value + ";"; break;
		        case "E6": sDictionaryInfo = ";;;;;;;;;" + this.value; break;
		    }
		    document.getElementById("hidFolderNameDicInfo").value = sDictionaryInfo
		});
		
		//저장
		$("#btnSave").on('click', function(){
			if ($.trim($("#folderName").val()) == ""){
				Common.Warning(Common.getDic("WH_msg_enterFolderName"));			//폴더명을 입력하세요
				return false;
			}
			
			var paramObject = new Object();
			paramObject["displayName"] = $("#folderName").val();
			paramObject["multiDisplayName"] = $("#hidFolderNameDicInfo").val();		//다국어 입력항목
			paramObject["memberOf"] = folderID;	//최상위폴더일 경우 NULL처리 그외는 MemberOf에 folderID가 설정됨.
			paramObject["folderType"] = folderID!=''?"Folder":"Root";	//최상위폴더, 폴더 만 사용
			
			//컨텐츠 앱 생성시 추가
			paramObject["isContens"] = "Y";
			paramObject["useUserForm"] = "Y";
			
			Common.Confirm("<spring:message code='Cache.msg_155' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						type:"POST",
						data: paramObject,
						url:"/groupware/contents/saveFolderAdd.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_37'/>");	//저장되었습니다.
								parent.location.reload();
							}
							else{
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						},
						error:function (request,status,error){
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
						}
					});
				}
			});	
		});
		
		//닫기
		$("#btnClose").on('click', function(){
			Common.Close();
		});
	}	
}

var selectBoardConfig = function(){
	$.ajax({
		type: "POST",
		url: "/groupware/admin/selectBoardConfig.do",
		dataType: 'json',
		async: false,
		data: {
			"folderID": folderID,
			"domainID": domainID
		},
		success: function(data){
			var config = data.config;
			
			g_isRoot = (config.FolderType === "Root");
			$("#hidMemberOf").val(config.MemberOf);
			//$("#folderType").val(config.FolderType);
			
			//조회된 정보로 화면에 이벤트 셋팅
			for(var key in config) {
				//Use로 시작되는 항목은 전부 체크박스 처리
				if (/^Use/.test(key)) {
					config[key] == "Y" ? $("#chk" + key).prop('checked', true) : $("#chk" + key).prop('checked', false);
				} else if (/^Is/.test(key)) {
					//is로 시작되는 항목은 전부 selectbox처리
					$("#select" + key).val(config[key] + "");
				} else {
					$("#txt" + key).val(config[key]);
				}
			}
			
			$("#selectMenuID").val(config.MenuID).prop("disabled", true);
			
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/admin/selectBoardConfig.do", response, status, error);
		}
	});
}

var openDictionaryPopup = function(){
	var option = {
		lang : lang,
		hasTransBtn : 'true',
		allowedLang : 'ko,en,ja,zh',
		useShort : 'false',
		dicCallback : "folderNameDic_CallBack",
		popupTargetID : 'DictionaryPopup',
		init : "folderNameDicInit"
	};
	
	coviCmn.openDicLayerPopup(option,"DictionaryPopup");
}

var folderNameDicInit = function(){
	var value;
	
	if($('#hidFolderNameDicInfo').val() == ''){
		value = $('#folderName').val();
	}else{
		value = $('#hidFolderNameDicInfo').val();
	}
	
	return value;
}

var folderNameDic_CallBack = function(data){
	$('#folderName').val(data.KoFull);
	$('#hidFolderNameDicInfo').val(coviDic.convertDic(data));
	Common.close("DictionaryPopup");
}

$(document).ready(function(){
	nameChange.objectInit();
});

</script>