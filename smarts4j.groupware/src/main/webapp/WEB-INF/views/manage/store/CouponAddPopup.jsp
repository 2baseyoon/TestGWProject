<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var paramDomainID = "${param.DomainID}"; 
	
	$(document).ready(function(){
		coviInput.init();
		
		$.ajax({
			type:"POST",
			data:{"codeGroups" : "ST_EVENT_TYPE"},
			url:"/covicore/basecode/get.do",
			async : false,
			success:function (data) {
				if(data.result == "ok" && data.list != undefined){
					$("select#issueType").html("");
					$.each(data.list[0].ST_EVENT_TYPE, function(idx, obj){
						if(obj.IsUse == "Y") {
							$("select#issueType").append("<option value='" + obj.Code + "'>" + obj.CodeName + "</option>");
						}
					})	
				}
			}
		});
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	//저장
	function saveSubmit(){
		//data셋팅	
		var confirmMessage;
			
		var urlSubmit = '/groupware/store/insertAdminCouponData.do';
		
		var alertMsg = "<spring:message code='Cache.msg_EnterTheRequiredValue' />"
		if($("#IssueCnt").val() == "") {
			Common.Inform(alertMsg.replace("{0}", "<spring:message code='Cache.lbl_CouponIssueCnt' />"));
			return;
		}
		if($("#ExpireDate").val() == "") {
			Common.Inform(alertMsg.replace("{0}", "<spring:message code='Cache.lbl_CouponExpireDate' />"));
			return;
		}
		
		var couponType = "${param.CouponType}"; // 쿠폰종류(결재,컨텐츠앱) 
		var issueType = $("#IssueType").val(); // 발행구분
		var issueTypeName = $("#IssueType>option:selected").text();
		var couponIssueCnt = $("#IssueCnt").val();
		var expireDate = $("#ExpireDate").val();
		
		confirmMessage = "<spring:message code='Cache.msg_RUSave' />";
		confirmMessage += "<br/><br/><spring:message code='Cache.lbl_CouponTypeName' /> : " + "${param.CouponTypeName}"; //쿠폰종류
		confirmMessage += "<br/><spring:message code='Cache.lbl_publicationGubun' /> : " + issueTypeName; //발행구분
		confirmMessage += "<br/><spring:message code='Cache.lbl_couponCount' /> : " + couponIssueCnt; //수량
		confirmMessage += "<br/><spring:message code='Cache.lbl_CouponExpireDate' /> : " + expireDate; //유효기간
		
		parent.Common.Confirm(confirmMessage, "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				//insert 호출
				$.ajax({
					type:"POST",
					data:{
						"DomainID" : paramDomainID,	
						"IssueCnt" : couponIssueCnt,
						"IssueType" : issueType,
						"CouponType" : couponType,
						"Memo" : $("#Memo").val(),
						"ExpireDate" : $("#ExpireDate").val().replace(/-/gi, '')
					},
					url:urlSubmit,
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", null, function (){
								parent.myGrid.reloadList();
								Common.Close();
							});			
						}else{
							Common.Inform(data.message, function() {
								return;
							});
							return;
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax(urlSubmit, response, status, error);
					}
				});
			}
		});
	}	
</script>
<div class="sadmin_pop">
	<div>
		<p class="sadmin_txt"><spring:message code='Cache.lbl_CorpName' /> : ${param.CompanyName}</p>
	</div>
	<table class="sadmin_table sa_menuBasicSetting">
		<colgroup>
			<col width="110px;">
			<col width="*">
		</colgroup>
		<tbody>
			<tr>
				<th><spring:message code='Cache.lbl_Gubun' /></th>
				<td>
					<select class="selectType02 w300p" id="IssueType" type="text" >
					</select>
				</td>
			</tr>			
			<tr>
				<th><spring:message code='Cache.lbl_Remark' /></th><!-- 비고 -->
				<td>
					<input class="w300p" id="Memo" name="Memo" type="text" max_length="512" />
				</td>
			</tr>			
			<tr>
				<th><spring:message code='Cache.lbl_CouponIssueCnt' /></th>
				<td>
					<input class="w50p" mode="numberint" num_min="0" max_length="3" id="IssueCnt" type="text" style="text-align:right;" />
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_CouponExpireDate' /></th>
				<td>
					<input class="adDate" style="width:120px;" id="ExpireDate" kind="date" type="text" data-axbind="date" />
				</td>
			</tr>
		</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
	</div>
</div>