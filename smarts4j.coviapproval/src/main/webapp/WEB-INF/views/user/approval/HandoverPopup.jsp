<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:450px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents" id="docManageAddArea">
		<div class="popContent" style="position:relative;">
			<div class="middle">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 40%;">
						<col style="width: 60%;">
					</colgroup>
					<tbody>
						<tr>
							<th><spring:message code='Cache.lbl_beforeChangeUser' /></th> <!-- 변경전 사용자 -->
							<td style="padding: 5px;">
								<input type="text" id="beforeUser" readonly>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_afterChangeUser' /></th> <!-- 변경후 사용자 -->
							<td style="padding: 5px;">
								<input type="text" id="afterUser" readonly>
								<button class="btnTblSearch" style="background-color: white; display: inline-block;" onclick="orgChartPopup('after');"><spring:message code='Cache.lbl_afterChangeUser' /></button>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.lbl_handover' /></a> <!-- 인계 -->
				<a id="btnClose" class="btnTypeDefault"><spring:message code='Cache.btn_apv_cancel' /></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>

<script>
	var FormInstId = CFN_GetQueryString("FormInstId") == "undefined" ? "" : CFN_GetQueryString("FormInstId");
	var FormInstBoxId = CFN_GetQueryString("FormInstBoxId") == "undefined" ? "" : CFN_GetQueryString("FormInstBoxId");

	$(document).ready(function(){
		$("#beforeUser").attr("urcode", Common.getSession("UR_Code"));
		$("#beforeUser").val(Common.getSession("UR_Name"));
		
		$("#btnClose").on("click", function(){parent.Common.close("onClickHandoverPopup");});
		
		$("#btnSave").on("click", function(){
			var beforeUserCode = $("#beforeUser").attr("urcode");
			var beforeUserName = $("#beforeUser").val();
			var afterUserCode = $("#afterUser").attr("urcode");
			var afterUserName = $("#afterUser").val();
			
			if(afterUserName == null || afterUserName == "" || afterUserCode == null || afterUserCode == ""){
				Common.Inform("<spring:message code='Cache.msg_selectAfterChangeUser'/>"); // 변경후 사용자를 선택해주세요.
				return false;
			}
			
			if(beforeUserCode == afterUserCode){
				Common.Inform("<spring:message code='Cache.msg_sameBeforeAndAfterUser'/>"); // 변경전 사용자와 변경후 사용자가 같습니다.
				return false;
			}
			
			$.ajax({
				url: "/approval/user/updateHandoverUser.do",
				type: "POST",
				data: {
					"FormInstId": FormInstId,
					"FormInstBoxId": FormInstBoxId,
					"UserCode": afterUserCode
				},			
				success: function(data){			
					Common.Inform(data.message, "Information", function(result){
						if(result){
							parent.Common.close("onClickHandoverPopup");
							parent.Refresh();
						}	
					});
				},
				error: function(response, status, error){
					Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
				}
			});
		});
	});
	
	function orgChartPopup(mode){
		parent.Common.open("", "orgcharPopup", "<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?type=B1&treeKind=Dept&allCompany=Y&callBackFunc=callBackOrgChartPopup", "1060px", "585px", "iframe", true, null, null, true);			
		parent.callBackOrgChartPopup = function(result){
			var result		= JSON.parse(result).item[0];
			var urName		= CFN_GetDicInfo(result.DN, Common.getSession("lang"));
			
			$("#afterUser").attr("urcode", result.UserCode);
			$("#afterUser").val(urName);
		}
	}
</script>