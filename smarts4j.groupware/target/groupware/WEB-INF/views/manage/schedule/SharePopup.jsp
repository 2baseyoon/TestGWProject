<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<body>
	<div class="sadmin_pop">
		<table class="sadmin_table">
			<colgroup>
				<col width="20%">
				<col width="*">
			</colgroup>
			<tr>
				<th><spring:message code='Cache.lbl_ShareSpecifier' /></th><!-- 공유 등록자 -->
				<td>
					<input type="hidden" id="SpecifierCode" />
					<input type="hidden" id="SpecifierName" />
					<input type="text" id="SpecifierDisplayName" style="width:100px" readonly="readonly"/>
					<a href="#" id="aSpecifier" class="btnTypeDefault search"  onclick="sharePopup.openOrgMapPopup('S')"></a>
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_ShareTarget' /></th><!-- 공유 대상자 -->
				<td>
					<input type="hidden" id="TargetType"/>
					<input type="hidden" id="TargetCode"/>
					<input type="hidden" id="TargetName"/>
					<input type="text" id="TargetDisplayName" style="width:100px" readonly="readonly"/>
					<a href="#" id="aTarget" class="btnTypeDefault search" onclick="sharePopup.openOrgMapPopup('T')"></a>
                    <input id="startDate" style="width: 100px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate" date_separator=".">
			   	    ~ 				   	   
					<input id="endDate" style="width: 100px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate" date_separator=".">
					<a class="btnTypeDefault" style="float:right" onclick="sharePopup.addShareTarget();"><spring:message code='Cache.btn_Add' /></a><!-- 추가 -->
					<div id="targetDataDiv" class="share_schedule_add_box" style="border: #c4c4c4 1px solid;overflow-y: auto;margin: 5px 0;height: 160px;width: 100%;padding: 5px;">
					</div>
					<div align="right" style="width: 100%">
						<a class="btnTypeDefault" onclick="sharePopup.deleteShareTarget();" ><spring:message code='Cache.btn_delete' /></a><!-- 삭제 -->
					</div>
				</td>
			</tr>
		</table>
		<div class="bottomBtnWrap">
			<a class="btnTypeDefault btnTypeBg" id="btnSave" onclick="sharePopup.saveData();"><spring:message code='Cache.btn_register' /></a><!-- 등록 -->
			<a class="btnTypeDefault btnTypeBg" id="btnDelete" onclick="sharePopup.deleteData();" style="display: none"><spring:message code='Cache.btn_delete' /></a><!-- 삭제 -->
	     	<a onclick="Common.Close();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>                    
		</div>
	</div>
</body>
<script type="text/javascript">
var sharePopup = {
	shareId : CFN_GetQueryString("ShareID"),
	mode : "I",		// I : Insert, U : Update
	initContent:function(){ 
		if(this.shareId == "undefined" || this.shareId == "" || this.shareId == "null"){
			this.mode = "I";
		}else{
			this.mode = "U";
		}
		
		if(this.mode == "U"){
			$("#btnSave").text("<spring:message code='Cache.btn_save'/>");
			$("#btnDelete").show();
			sharePopup.selectShareData();
		}
	},
	selectShareData:function(){// 데이터 조회하기
		$("#targetDataDiv").html("");
		
		$.ajax({
		    url: "/groupware/manage/schedule/getAdminShareData.do",
		    type: "POST",
		    data: {
				"SpecifierCode":this.shareId
			},
		    success: function (res) {
		    	
	            $(res.list).each(function(){
	            	$("#SpecifierCode").val($$(this).attr("SpecifierCode"));
	        		$("#SpecifierName").val($$(this).attr("SpecifierName"));
	        		$("#SpecifierDisplayName").val(CFN_GetDicInfo($$(this).attr("SpecifierName")));
	            	
	            	var targetCode = $$(this).attr("TargetCode").replaceAll(".", "_");
	            	var subTargetCode = $$(this).attr("TargetCode");
	        		var targetName = $$(this).attr("TargetName");

	            	var divInnerHTML = "";
					divInnerHTML += "<div id='targetDiv_"+targetCode+"' style='padding-bottom: 1px; position: relative;'>";
					divInnerHTML += "<input type='checkbox' id='check_"+targetCode+"'>";
					divInnerHTML += "<label for='check_"+targetCode+"' class='ssab_name' name='shareTargetUser' value-data='"+ subTargetCode + "'>"+ targetName + "(" + subTargetCode + ")" + "</label>";
					divInnerHTML += "<input type='hidden' id='Target_"+targetCode+"' value='|"+ targetCode +"|"+ targetName +"'>";
					divInnerHTML += "</div>"
					
					var startDateTime = CFN_TransLocalTime($$(this).attr("StartDate"),"yyyy.MM.dd HH:mm");
					var startDate = startDateTime.split(' ')[0];
					var startTime = startDateTime.split(' ')[1];
					$("#targetDataDiv").append(divInnerHTML);
					$("#startDate").clone().appendTo($("#targetDiv_"+targetCode)).prop("id", "startDate_"+targetCode);
					$("#startDate_"+targetCode).val(startDate).attr("data-time", startTime);
					$("#startDate_"+targetCode).addClass("datePicker");
					$("#startDate_"+targetCode).attr("vali_date_id", "endDate_"+targetCode);
					
					var endDateTime = CFN_TransLocalTime($$(this).attr("EndDate"),"yyyy.MM.dd HH:mm");
					var endDate = endDateTime.split(' ')[0];
					var endTime = endDateTime.split(' ')[1];
					$("#targetDiv_"+targetCode).append("<span class='ssab_tilde'>~</span>");
					$("#endDate").clone().appendTo($("#targetDiv_"+targetCode)).prop("id", "endDate_"+targetCode);
					$("#endDate_"+targetCode).val(endDate).attr("data-time", endTime);
					$("#endDate_"+targetCode).addClass("datePicker");
					$("#endDate_"+targetCode).attr("vali_date_id", "startDate_"+targetCode); 
					
					coviInput.setDate();
	            });
	            
	            if($(res.list).length > 0){
	            	sharePopup.mode = "U";
	            	$("#btnSave").text("<spring:message code='Cache.btn_save'/>");
	            	$("#btnDelete").show();
	            }else{
	            	sharePopup.mode = "I";
	            	$("#btnSave").text("<spring:message code='Cache.btn_register'/>");
	            	$("#btnDelete").hide();
	            }
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getAdminShareData.do", response, status, error);
			}
		});
	},
	openOrgMapPopup:function (strType){
		var orgType = "A1";
		if(strType== "S"){
			_CallBackMethod2 = this.setOrgMapSpecifierData;
		}else{
			_CallBackMethod2 = this.setOrgMapTargetData;
		}
		var option = {
				callBackFunc : "_CallBackMethod2",
		};
		
		coviCmn.openOrgChartPopup("<spring:message code='Cache.lbl_DeptOrgMap'/>", orgType, option);
	},
	// 공유 등록자 데이터 세팅
	setOrgMapSpecifierData : function(data){
		
		var dataObj = $.parseJSON(data);
		
		var userCode = $$(dataObj).find("item").concat().eq(0).attr("AN");
		var userName = $$(dataObj).find("item").concat().eq(0).attr("DN");

		$("#SpecifierCode").val(userCode);
		$("#SpecifierName").val(userName);
		$("#SpecifierDisplayName").val(CFN_GetDicInfo(userName));
		
		sharePopup.shareId = userCode;
		

		
		sharePopup.selectShareData();
	},
	
	// 공유 대상자 데이터 세팅
	setOrgMapTargetData :function(data){
		var dataObj = $.parseJSON(data);
		
		var userCode = $$(dataObj).find("item").concat().eq(0).attr("AN");
		var userName = $$(dataObj).find("item").concat().eq(0).attr("DN") == undefined ? "" : $$(dataObj).find("item").concat().eq(0).attr("DN");
		var userType = $$(dataObj).find("item").concat().eq(0).attr("itemType");
		
		$("#TargetType").val(userType);
		$("#TargetCode").val(userCode);
		$("#TargetName").val(userName);
		$("#TargetDisplayName").val(CFN_GetDicInfo(userName));
	},
	deleteShareTarget:function(){	//삭제하기
		var checkObj = $("input[id^=check_]:checked");
		
		if($(checkObj).length > 0){
			$.each(checkObj, function(){
				var userId = $(this).attr("id").replace("check_", "").replaceAll(".", "\\.");
				$("#targetDiv_"+userId).remove();
			});
			coviInput.setDate();
		}else{
			Common.Warning("<spring:message code='Cache.msg_270'/>");		//삭제할 대상이 없습니다.
		}
	},
	saveData:function(){//저장하기
		var targetDataArr = new Array();
		var specifierCode = $("#SpecifierCode").val();
		var specifierName = $("#SpecifierName").val();
		var gBaseConfigSchedulePersonFolderID = Common.getBaseConfig("SchedulePersonFolderID");
		
		//공유 대상자 데이터 세팅
		$("div[id^=targetDiv_]").each(function(){
			var targetObj = {};
			
			var targetType = $(this).find("input[id^=Target_]").val().split("|")[0];
			var targetCode = $(this).find("input[id^=Target_]").val().split("|")[1];
			<%-- 기입된 사용자 명 중에 괄호가 포함되어 있는 경우에 오작동하여 수정. --%>
			var subTargetCode = $(this).find("label[name=shareTargetUser]").attr("value-data");
			var targetName = $(this).find("input[id^=Target_]").val().split("|")[2];
			var startDate = $(this).find("#startDate_"+targetCode).val().replaceAll('.', '-');
			var startTime = $(this).find("#startDate_"+targetCode).attr('data-time');
			var endDate = $(this).find("#endDate_"+targetCode).val().replaceAll('.', '-');
			var endTime = $(this).find("#endDate_"+targetCode).attr('data-time');
			
			$$(targetObj).append("TargetType", targetType);
			$$(targetObj).append("TargetCode", subTargetCode);
			$$(targetObj).append("TargetName", targetName);
			$$(targetObj).append("StartDate", startDate);
			$$(targetObj).append("EndDate", endDate);
			if(startTime != undefined) $$(targetObj).append("StartTime", startTime);
			if(endTime != undefined) $$(targetObj).append("EndTime", endTime);
			
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
			    url: "/groupware/manage/schedule/saveAdminShareData.do",
			    type: "POST",
			    data: {
			    	"mode":this.mode,
					"TargetDataArr":JSON.stringify(targetDataArr),
					"SpecifierCode":specifierCode,
					"SpecifierName":specifierName
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		Common.Inform("<spring:message code='Cache.msg_117'/>", "Information", function(){
			            	parent.confSchedule.setFolderData();
			            	Common.Close();
			            });
			    	}else if(sharePopup.setCurrentDate('s')){
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
	},
	deleteData:function(){//데이터 삭제하기
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Confirm", function(result){
			if(result){
				var specifierCode = $("#SpecifierCode").val();
				
				$.ajax({
				    url: "/groupware/manage/schedule/deleteAdminShareData.do",
				    type: "POST",
				    data: {
				    	"SpecifierCode":specifierCode
					},
				    success: function (res) {
			            Common.Inform("<spring:message code='Cache.msg_Deleted'/>", "Information", function(){
			            	parent.confSchedule.setFolderData();
			            	Common.Close();
			            });
			        },
			        error:function(response, status, error){
						CFN_ErrorAjax("/groupware/schedule/deleteAdminShareData.do", response, status, error);
					}
				});
			}
		});
		
	},
	addShareTarget:function(){//추가하기
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
			
			// 기간 체크
			sharePopup.setCurrentDate('a');
			
			if(!isDup){
				var divInnerHTML = "";
				divInnerHTML += "<div id='targetDiv_"+targetCode+"' style='padding-bottom: 1px; position: relative;'>";
				divInnerHTML += "<input type='checkbox' id='check_"+targetCode+"'>";
				divInnerHTML += "<label for='check_"+targetCode+"' class='ssab_name' name='shareTargetUser' value-data='"+ subTargetCode + "'>"+ targetDisplayName + "(" + subTargetCode + ")" + "</label>";
				divInnerHTML += "<input type='hidden' id='Target_"+targetCode+"' value='"+targetType+"|"+ targetCode +"|"+ targetName +"'>";
				divInnerHTML += "</div>";
				
				$("#targetDataDiv").append(divInnerHTML);
				
				$("#startDate").clone().appendTo($("#targetDiv_"+targetCode)).prop("id", "startDate_"+targetCode);
				$("#startDate_"+targetCode).addClass("datePicker");
				$("#startDate_"+targetCode).attr("vali_date_id", "endDate_"+targetCode);
				$("#targetDiv_"+targetCode).append("<span class='ssab_tilde'>~</span>");
				$("#endDate").clone().appendTo($("#targetDiv_"+targetCode)).prop("id", "endDate_"+targetCode);
				$("#endDate_"+targetCode).attr("vali_date_id", "startDate_"+targetCode); 
				$("#endDate_"+targetCode).addClass("datePicker");
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
	},
	setCurrentDate:function(mode){ //기간 체크
		var cDate = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
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
		}else if(mode == 's'){ //저장시
			var pickerList = $(".datePicker");
			$.each(pickerList, function(i, item){
				if($(".datePicker:eq("+i+")").val() == ""){
					isTrue = true;
				}
			});
		}
		return isTrue;
	}
}
$(document).ready(function(){
	sharePopup.initContent();
});
	
</script>