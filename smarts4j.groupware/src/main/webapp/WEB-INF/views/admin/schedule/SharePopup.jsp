<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/admin/scheduleAdmin.js<%=resourceVersion%>" ></script>
<body>
	<div>
		<table class="AXFormTable">
			<colgroup>
				<col width="20%">
				<col width="80%">
			</colgroup>
			<tr>
				<th><spring:message code='Cache.lbl_ShareSpecifier' /></th><!-- 공유 등록자 -->
				<td>
					<input type="hidden" id="SpecifierCode" />
					<input type="hidden" id="SpecifierName" />
					<input type="text" id="SpecifierDisplayName" style="width:80px" class="AXInput" readonly="readonly"/>
					<a id="aSpecifier" onclick="scheduleAdmin.openOrgMapPopup(this)">
                        <img width="21" height="18" style="vertical-align: middle; cursor: pointer;" alt="search" src="<%=cssPath %>/covicore/resources/images/covision/btn_org.gif">
                    </a>
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_ShareTarget' /></th><!-- 공유 대상자 -->
				<td>
					<input type="hidden" id="TargetType" class="AXInput" />
					<input type="hidden" id="TargetCode" class="AXInput" />
					<input type="hidden" id="TargetName" class="AXInput" />
					<input type="text" id="TargetDisplayName" style="width:80px" class="AXInput" readonly="readonly"/>
					<a id="aTarget" onclick="scheduleAdmin.openOrgMapPopup(this)">
                        <img width="21" height="18" style="vertical-align: middle; cursor: pointer;" alt="search" src="<%=cssPath %>/covicore/resources/images/covision/btn_org.gif">
                    </a>
                    &nbsp;&nbsp;&nbsp;
                    <input class="AXInput" id="startDate" style="width: 95px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate">
			   	    ~ 				   	   
					<input class="AXInput" id="endDate" style="width: 95px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate">
					&nbsp;<input type="button" class="AXButton" value="<spring:message code='Cache.btn_Add' />" onclick="addShareTarget();"><!-- 추가 -->
					
					<div id="targetDataDiv" class="share_schedule_add_box" style="border: #c4c4c4 1px solid;overflow-y: auto;margin: 5px 0;height: 160px;width: 380px;padding: 5px;">
					</div>
					<div align="right" style="width: 392px">
						<input type="button" class="AXButton" value="<spring:message code='Cache.btn_delete' />" onclick="deleteShareTarget();" /><!-- 삭제 -->
					</div>
				</td>
			</tr>
		</table>
		<br>
		<div align="center">
			<input type="button" class="AXButton red" id="btnSave" value="<spring:message code='Cache.btn_register' />" onclick="saveData();"/><!-- 등록 -->
			<input type="button" class="AXButton red" id="btnDelete" value="<spring:message code='Cache.btn_delete' />" onclick="deleteData();" style="display: none"/><!-- 삭제 -->
			<input type="button" class="AXButton" value="<spring:message code='Cache.btn_Close' />" onclick="Common.Close();"/><!-- 닫기 -->
		</div>
	</div>
</body>
<script type="text/javascript">
	var shareId = CFN_GetQueryString("ShareID");
	var mode = "I";		// I : Insert, U : Update
	
	initContent();
	
	function initContent(){ 
		if(shareId == "undefined" || shareId == "" || shareId == "null"){
			mode = "I";
		}else{
			mode = "U";
		}
		
		if(mode == "U"){
			$("#btnSave").val("<spring:message code='Cache.btn_save'/>");
			$("#btnDelete").show();
			selectShareData();
		}
	};
	
	// 데이터 조회하기
	function selectShareData(){
		$("#targetDataDiv").html("");
		
		$.ajax({
		    url: "/groupware/schedule/getAdminShareData.do",
		    type: "POST",
		    data: {
				"SpecifierCode":shareId
			},
		    success: function (res) {
	            $(res.list).each(function(){
	            	$("#SpecifierCode").val($$(this).attr("SpecifierCode"));
	        		$("#SpecifierName").val($$(this).attr("SpecifierName"));
	        		$("#SpecifierDisplayName").val(CFN_GetDicInfo($$(this).attr("SpecifierName")));
	            	
	        		var targetType = $("#TargetType").val();
	            	var targetCode = $$(this).attr("TargetCode").replaceAll(".", "_");
	            	var subTargetCode = $$(this).attr("TargetCode");
	        		var targetName = $$(this).attr("TargetName");

	            	var divInnerHTML = "";
	            	divInnerHTML += "<div id='targetDiv_"+targetCode+"' style='padding-bottom: 1px; position: relative;'>";
					divInnerHTML += "<input type='checkbox' id='check_"+targetCode+"'>";
					divInnerHTML += "<label for='check_"+targetCode+"' class='ssab_name'>"+ targetName + "(" + subTargetCode + ")" + "</label>";
					divInnerHTML += "<input type='hidden' id='Target_"+targetCode+"' value='"+targetType+"|"+ targetCode +"|"+ targetName +"'>";
					divInnerHTML += "</div>";
					
					$("#targetDataDiv").append(divInnerHTML);
					
					$("#startDate").clone().appendTo($("#targetDiv_"+targetCode)).prop("id", "startDate_"+targetCode);
					$("#startDate_"+targetCode).val($$(this).attr("StartDate"));
					$("#startDate_"+targetCode).addClass("datePicker");
					$("#startDate_"+targetCode).attr("vali_date_id", "endDate_"+targetCode);
					$("#targetDiv_"+targetCode).append("<span class='ssab_tilde'>~</span>");
					$("#endDate").clone().appendTo($("#targetDiv_"+targetCode)).prop("id", "endDate_"+targetCode);
					$("#endDate_"+targetCode).val($$(this).attr("EndDate"));
					$("#endDate_"+targetCode).addClass("datePicker");
					$("#endDate_"+targetCode).attr("vali_date_id", "startDate_"+targetCode); 
					
					coviInput.setDate();
	            });
	            
	            if($(res.list).length > 0){
	            	mode = "U";
	            	$("#btnSave").val("<spring:message code='Cache.btn_save'/>");
	            	$("#btnDelete").show();
	            }else{
	            	mode = "I";
	            	$("#btnSave").val("<spring:message code='Cache.btn_register'/>");
	            	$("#btnDelete").hide();
	            }
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getAdminShareData.do", response, status, error);
			}
		});
	}
	
	//추가하기
	function addShareTarget(){
		var targetType = $("#TargetType").val();
		var targetCode = $("#TargetCode").val().replaceAll(".", "_");
		var subTargetCode = $("#TargetCode").val();
		var targetName = $("#TargetName").val();
		var targetDisplayName = $("#TargetDisplayName").val();
		
		if(targetCode != null && targetCode != undefined && targetCode !=""){
			// 중복 체크
			var isDup = false;
			$("div[id^=targetDiv_]").each(function(){
				var userId = $(this).attr("id");
				if(userId.replace("targetDiv_", "") == targetCode){
					isDup = true;
				}
			});
			
			// 기간체크
			setCurrentDate('a');
			
			if(!isDup){
				var divInnerHTML = "";
				divInnerHTML += "<div id='targetDiv_"+targetCode+"' style='padding-bottom: 1px; position: relative;'>";
				divInnerHTML += "<input type='checkbox' id='check_"+targetCode+"'>";
				divInnerHTML += "<label for='check_"+targetCode+"' class='ssab_name'>"+ targetDisplayName + "(" + subTargetCode + ")" + "</label>";
				divInnerHTML += "<input type='hidden' id='Target_"+targetCode+"' value='"+targetType+"|"+ targetCode +"|"+ targetName +"'>";
				divInnerHTML += "</div>";
				
				$("#targetDataDiv").append(divInnerHTML);
				
				$("#startDate").clone().appendTo($("#targetDiv_"+targetCode)).prop("id", "startDate_"+targetCode);
				$("#startDate_"+targetCode).addClass("datePicker");
				$("#startDate_"+targetCode).attr("vali_date_id", "endDate_"+targetCode);
				$("#targetDiv_"+targetCode).append("<span class='ssab_tilde'>~</span>");
				$("#endDate").clone().appendTo($("#targetDiv_"+targetCode)).prop("id", "endDate_"+targetCode);
				$("#endDate_"+targetCode).addClass("datePicker");
				$("#endDate_"+targetCode).attr("vali_date_id", "startDate_"+targetCode); 
				
				coviInput.setDate();
				
				$("#TargetCode").val("");
				$("#TargetName").val("");
				$("#startDate").val("");
				$("#endDate").val("");
			}else{
				Common.Warning(targetName+"<spring:message code='Cache.msg_AlreadyAdd'/>");		//은(는) 이미 추가 되었습니다
			}
		}else{
			Common.Warning("<spring:message code='Cache.msg_ValidationTargetShare'/>");		//공유 대상자를 지정해주세요
		}
		// 입력데이터 초기화
		$("#TargetDisplayName").val('');
		$("#startDate").val('');
		$("#endDate").val('');
	}
	
	//삭제하기
	function deleteShareTarget(){
		var checkObj = $("input[id^=check_]:checked");
		
		if($(checkObj).length > 0){
			$(checkObj).each(function(){
				var userId = $(this).attr("id").replace("check_", "").replaceAll(".", "\\.");
				$("#targetDiv_"+userId).remove();
			});
			coviInput.setDate();
		}else{
			Common.Warning("<spring:message code='Cache.msg_270'/>");		//삭제할 대상이 없습니다.
		}
	}
	
	//저장하기
	function saveData(){
		var targetDataArr = new Array();
		var specifierCode = $("#SpecifierCode").val();
		var specifierName = $("#SpecifierName").val();
		var registerCode = Common.getSession("UR_Code");
		var gBaseConfigSchedulePersonFolderID = Common.getBaseConfig("SchedulePersonFolderID");
		
		//공유 대상자 데이터 세팅
		$("div[id^=targetDiv_]").each(function(){
			var targetObj = {};
			
			var targetType = $(this).find("input[id^=Target_]").val().split("|")[0];
			var targetCode = $(this).find("input[id^=Target_]").val().split("|")[1];
			var subTargetCode = $(this).text().split("(")[1].split(")")[0];
			var targetName = $(this).find("input[id^=Target_]").val().split("|")[2];
			var startDate = $(this).find("#startDate_"+targetCode).val();
			var endDate = $(this).find("#endDate_"+targetCode).val();
			
			$$(targetObj).append("TargetType", targetType);
			$$(targetObj).append("TargetCode", subTargetCode);
			$$(targetObj).append("TargetName", targetName);
			$$(targetObj).append("StartDate", startDate);
			$$(targetObj).append("EndDate", endDate);
			
			//공유 일정에 대한 권한
			$$(targetObj).append("ObjectID", gBaseConfigSchedulePersonFolderID);		// 내 일정의 FolderID 조회
			$$(targetObj).append("ACL", "_____VR");			// 조회,읽기 권한만
			
			targetDataArr.push(targetObj);
		});
		
		if(targetDataArr.length == 0){
			Common.Warning("<spring:message code='Cache.msg_ValidationTargetShare'/>");			// 공유 대상자를 지정해주세요
			return false;
		}else{
			$.ajax({
			    url: "/groupware/schedule/saveAdminShareData.do",
			    type: "POST",
			    data: {
			    	"mode":mode,
					"TargetDataArr":JSON.stringify(targetDataArr),
					"SpecifierCode":specifierCode,
					"SpecifierName":specifierName,
					"RegisterCode":registerCode
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		Common.Inform("<spring:message code='Cache.msg_117'/>", "Information", function(){
			            	parent.searchListData();
			            	Common.Close();
			            });
			    	}else if(setCurrentDate('s')){
			    		Common.Error("<spring:message code='Cache.CPMail_TargetPeriodIsRequired'/>");		// 기간을 입력하여 주십시오.
			    	}else{
			    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
			    	}
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/saveAdminShareData.do", response, status, error);
				}
			});
		}
	}
	
	//데이터 삭제하기
	function deleteData(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Confirm", function(result){
			if(result){
				var specifierCode = $("#SpecifierCode").val();
				
				$.ajax({
				    url: "/groupware/schedule/deleteAdminShareData.do",
				    type: "POST",
				    data: {
				    	"mode":mode,
				    	"SpecifierCode":specifierCode
					},
				    success: function (res) {
			            Common.Inform("<spring:message code='Cache.msg_Deleted'/>", "Information", function(){
			            	parent.searchListData();
			            	Common.Close();
			            });
			        },
			        error:function(response, status, error){
						CFN_ErrorAjax("/groupware/schedule/deleteAdminShareData.do", response, status, error);
					}
				});
			}
		});
	}
	
	//기간 체크
	function setCurrentDate(mode){
		var cDate = new Date();
		var currentDate = cDate.format("yyyy.MM.dd");
		var isTrue;
		
		if(mode == 'a'){ //추가 시
			if($("#startDate").val() ==''){
				$("#startDate").val(currentDate);
			}
			if($("#endDate").val() ==''){
				$("#endDate").val(currentDate);
			}
			isTrue = true;
		}else if(mode == 's'){ //저장 시
			var pickerList = $(".datePicker");
			$.each(pickerList, function(i, item){
				if($(".datePicker:eq("+i+")").val() == ""){
					isTrue = true;
				}
			});
		}
		return isTrue;
	}
</script>