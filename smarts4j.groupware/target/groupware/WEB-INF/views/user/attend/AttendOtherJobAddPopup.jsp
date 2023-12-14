<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style>

	.layer_divpop table,p {font-size:12px}
	.attSel {}

</style>
<body>	
<input type="hidden" id="jobStsSeq" value="${otherJob.JobStsSeq }" />
<div class="layer_divpop" style="width:450px; left:0; top:0; z-index:104;">
	<div class="" style="overflow:hidden; padding:0;">
		<div class="ATMgt_popup_wrap">
			<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
				<tbody>
					<tr>
						<td class="ATMgt_T_th" >
							<spring:message code='Cache.lbl_type'/>
						</td>
						<td>
							<div class="ATMgt_T"><div class="ATMgt_T_l">
								<input type="text" class="tx_status w100" id="jobStsName" value=""/>
							</div>
							<input id="multiDisplayName" name="multiDisplayName" type="hidden" />
				  			<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="dictionaryLayerPopup();" /> <!-- 다국어 -->
						</td>
					</tr>	
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_approval'/></td>
						<td>
							<select class="reqMethod" id="reqMethod" style="width:80px"></select>
						</td>
					</tr>	 
				</tbody> 
			</table>
			<div class="ATMgt_memo_wrap mb20">
				<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Memo'/></td>
							<td><textarea class="ATMgt_Tarea" id="memo">${otherJob.Memo}</textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnOtherJobSave" onclick="saveOtherJob();"><spring:message code='Cache.lbl_n_att_otherjob_add'/></a>
				<a href="#" class="btnTypeDefault" onclick="parent.Common.close('target_pop');"><spring:message code='Cache.lbl_Cancel'/></a>
			</div>
		</div>				
	</div>
</div>
<!-- 기타근무등록 팝업 끝 -->
</body>
<script type="text/javascript">
	$(document).ready(function () {
		init();
	});
	function init(){
		
		//요청 승인 구분
		var opHtml = "";
		var AttendReqMethod = Common.getBaseCode("AttendReqMethod").CacheData;
		for(var i=0;i<AttendReqMethod.length;i++){
			opHtml += "<option value='"+AttendReqMethod[i].Code+"'>"+CFN_GetDicInfo(AttendReqMethod[i].MultiCodeName)+"</option>";
		}
		$(".reqMethod").html(opHtml);

		if("${sts}"=="UPD"){
			$("#jobStatus").val("${otherJob.JobSts}");
			$("#jobStsName").val("${otherJob.JobStsName}");
			$("#multiDisplayName").val("${otherJob.MultiDisplayName}");
			/* $("#memo").val("${otherJob.Memo}");  줄바꿈 문제로 text 직접 적용*/
			$("#reqMethod").val("${otherJob.ReqMethod}");
			//$("#updMethod").val("${otherJob.UpdMethod}");
			//$("#delMethod").val("${otherJob.DelMethod}");
		}

		//add or modify button label checking
		if($("#jobStsSeq").val()!=""){
			$("#btnOtherJobSave").html("<spring:message code='Cache.lbl_n_att_otherjob_sts'/> <spring:message code='Cache.lbl_Modify'/>");
		}
	}
	
	function saveOtherJob(){
		var params = {
			jobStsSeq : $("#jobStsSeq").val()
			,jobStsName : $("#jobStsName").val()
			,multiDisplayName : $("#multiDisplayName").val()
			,memo : $("#memo").val()	
			,validYn : 'Y'
			,reqMethod : $("#reqMethod").val()
		};
		
		if(validCheck()){
			$.ajax({
				type:"POST",
				dataType : "json",
				data: params,
				url:"/groupware/attendAdmin/setOtherJob.do",
				success:function (data) {
					if(data.status =="SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_37'/>.","Information",function(){
							parent.search();
							Common.Close();
						});	
					}else{
						Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
					}
				}
			});
		}
	}
	
	function validCheck(){
		return true;
	}
	
	//다국어 설정 팝업
	function dictionaryLayerPopup(){
		var option = {
				lang : lang,
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh,lang1,lang2',
				useShort : 'false',
				dicCallback : 'dicCallback',
				openerID : CFN_GetQueryString("CFN_OpenLayerName"),
				popupTargetID : 'setMultiLangData',
				init : 'dicInit'
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&openerID=" + option.openerID;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		
		parent.Common.open("","setMultiLangData","<spring:message code='Cache.lbl_MultiLangSet' />",url,"400px","280px","iframe",true,null,null,true);
	}

	//다국어 세팅 함수
	function dicInit(){
		if($("#multiDisplayName").val() == ''){
			value = $("#jobStsName").val();
		}else{
			value = $("#multiDisplayName").val();
		}
		
		return value;
	}

	//다국어 콜백 함수
	function dicCallback(data){
		var jsonData = JSON.parse(data);
		
		$("#multiDisplayName").val(coviDic.convertDic(jsonData));
		if($("#jobStsName").val() == ''){
			document.getElementById('jobStsName').value = CFN_GetDicInfo(coviDic.convertDic(jsonData), lang);
		}
		
		Common.Close("setMultiLangData");
	}
	
	function setMultiCodeName(){
		var sDictionaryInfo = $("#multiDisplayName").val();
		if (sDictionaryInfo == "") {
		      switch (lang.toUpperCase()) {
		          case "KO": sDictionaryInfo = $("#jobStsName").val(";;;;;;;;;"); break;
		          case "EN": sDictionaryInfo = ";" + $("#jobStsName").val(";;;;;;;;"); break;
		          case "JA": sDictionaryInfo = ";;" + $("#jobStsName").val(";;;;;;;"); break;
		          case "ZH": sDictionaryInfo = ";;;" + $("#jobStsName").val(";;;;;;"); break;
		          case "E1": sDictionaryInfo = ";;;;" + $("#jobStsName").val(";;;;;"); break;
		          case "E2": sDictionaryInfo = ";;;;;" + $("#jobStsName").val(";;;;"); break;
		          case "E3": sDictionaryInfo = ";;;;;;" + $("#jobStsName").val(";;;"); break;
		          case "E4": sDictionaryInfo = ";;;;;;;" + $("#jobStsName").val(";;"); break;
		          case "E5": sDictionaryInfo = ";;;;;;;;" + $("#jobStsName").val(";"); break;
		          case "E6": sDictionaryInfo = ";;;;;;;;;" + $("#jobStsName").val(); break;
		       }
		      $("#multiDisplayName").val(sDictionaryInfo);
		}
	}
</script>