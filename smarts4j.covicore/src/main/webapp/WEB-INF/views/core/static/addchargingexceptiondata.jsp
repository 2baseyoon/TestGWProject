<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script>
	$(document).ready(function(){
		coviInput.setDate();
		
		//테스트용 데이터
		//$("#add_username").val("yu2mi");
		//$("#add_username").attr("readonly", "true");			//조직도에서 UR_Code값 받아오는 처리
		
		$("#add_company").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "static/getchargingexceptionselectdata.do",
			ajaxPars: {"filter": "selectDomain"},
			ajaxAsync:false
		});
	});

	function addSubmit(formname){
		if(!coviInput.setValidator(formname, " <spring:message code='Cache.msg_ValidationCheck'/>")){
			//document.getElementById(formname).submit();
			return false;
		}else{
			var startDate = $("#add_startdate").val();
			var endDate = $("#add_enddate").val();
			var comment = $("#add_reason").val();
			var dnID = $("#add_company option:selected").val();
			var userCode = $("#add_usercode").val();						//조직도에서 UR_Code값 받아오는 처리
			
			var now = new Date();
			now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now)
			
			$.ajax({
				type:"POST",
				data:{
					"STARTDATE":startDate,
					"ENDDATE":endDate,
					"COMMENT":comment,
					"DN_ID":dnID,
					"UR_Code":userCode,
					"RegID": "gypark",			// 세션값
					"RegDate": now
				},
				url:"static/createchargingexception.do",
				success:function (data) {
					if(data.result == "ok") {
						Common.Inform("<spring:message code='Cache.msg_DeonRegist'/>", "Information Dialog", function(result) {
							Refresh();	
						});
					}
				},
				error:function (error){
					Common.Error(error.message);
				}
			});
		}
	}
	
	function OrgMapLayerPopup(){
		Common.open("","orgmap_pop","조직도 팝업","cmmn/orgmap.do","800px","600px","iframe",true,null,null,true);
	}

	// 조직도 데이터	
	parent._CallBackMethod2 = setOrgMapData;
	
	function setOrgMapData(data){
		var dataObj = new Function(data).apply();
		if(dataObj[0].people.length > 1){
			Common.Inform("<spring:message code='Cache.msg_OrgMapOneDataAlert'/>");
		}else if(dataObj[0].dept.length > 0){
			Common.Inform("<spring:message code='Cache.msg_OrgMapOnlyPeopleAlert'/>");
		}else{
			$("#add_username").val(dataObj[0].people[0].UR_Name);
			$("#add_usercode").val(dataObj[0].people[0].UR_Code);
		}
	}
</script>
<form id="addForm"  name="addForm" >
	<div class="topbar_grid" align="center">
		<table class="AXFormTable">
			<colgroup>
				<col width="20%"/>
				<col width="80%"/>
			</colgroup>
			<tr>
				<th><spring:message code="Cache.lbl_Period"/></th>
				<td style="text-align: left">
					<input type="text" id="add_startdate" style="width: 85px" class="AXInput"/> ~ 
					<input type="text" kind="twindate" date_startTargetID="add_startdate" id="add_enddate" name="<spring:message code="Cache.lbl_Period"/>" style="width: 85px" class="AXInput av-required" />
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_Reason"/></th>
				<td style="text-align: left">
					<input type="text" id="add_reason" style="width: 300px" name="<spring:message code="Cache.lbl_Reason"/>" class="AXInput av-required"/>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_BelongingDNcode"/></th>
				<td style="text-align: left">
					<select id="add_company"  class="AXSelect av-required" name="<spring:message code="Cache.lbl_BelongingDNcode"/>"></select>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_User"/></th>
				<td style="text-align: left">
					<input type="text" id="add_username" style="width: 300px" name="<spring:message code="Cache.lbl_User"/>" class="AXInput av-required" readonly="readonly"/>
					<input type="hidden" id="add_usercode" />
					<input type="button" id="add_selector" value="<spring:message code="Cache.btn_Select"/>" onclick="OrgMapLayerPopup();" class="AXButton"/>
				</td>
			</tr>
		</table>
		<input type="button" value="<spring:message code="Cache.btn_register"/>" onclick="addSubmit('addForm');" class="AXButton" />
	</div>
</form>