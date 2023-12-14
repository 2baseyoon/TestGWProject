<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
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
									<input id="folderName" name="folderName" value="${displayName}" type="text" class="HtmlCheckXSS ScriptCheckXSS" style="width: 80%" />
									<input id="hidFolderNameDicInfo" name="hidFolderNameDicInfo" value="${multiDisplayName}" type="hidden" />
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

var nameChange = {
	objectInit : function(){			
		this.addEvent();
	}	,
	addEvent : function(){
		
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
		
		$("#btnSave").on('click', function(){
			if ($.trim($("#folderName").val()) == ""){
				Common.Warning(Common.getDic("WH_msg_enterFolderName"));			//폴더명을 입력하세요
				return false;
			}

			Common.Confirm("<spring:message code='Cache.msg_155' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						type:"POST",
						data:{"folderID":'${folderID}', "displayName":  $("#folderName").val(), "multiDisplayName":  $("#hidFolderNameDicInfo").val()},
						url:"/groupware/contents/updateContentsNameChange.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_37'/>");	//저장되었습니다.
								$(".btnRefresh", parent.document).trigger('click');	//새로고침							
								Common.Close();
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
		
		$("#btnClose").on('click', function(){
			Common.Close();
		});
	}	
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