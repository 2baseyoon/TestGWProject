<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>	
	<div class="layer_divpop ui-draggable popBizCardAddGroup" id="testpopup_p" style="width:416px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<!-- <div class="pop_header" id="testpopup_ph">
				<h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">명함 그룹 추가</span></h4><a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a>
			</div> -->
			<div class="popContent">
				<div class="rowTypeWrap formWrap">
					<dl>
						<dt><spring:message code='Cache.lbl_GroupName' /></dt>
						<dd><input type="text" id="txtGroupName" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_EnterGroupName' />" /></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_PriorityOrder' /></dt>
						<dd><input type="number" min="0"  id="txtGroupPriorityOrder" value="0" /></dd>
					</dl>
				</div>
				<div class="popBtnWrap">
					<a onclick="CheckValidation(this);" href="#" id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a>
					<a onclick="CheckValidation(this);" href="#" id="btnModify" class="btnTypeDefault btnTypeChk" style="display: none;"><spring:message code='Cache.btn_Edit' /></a>
					<a onclick="closeLayer();" href="#" id="btnClose" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

  $(function() {
	  
		 if("${mode}" == "modify"){
			$("#btnSave").css("display", "none");
			$("#btnModify").css("display", "");
			
			$.ajaxSetup({
				cache : false
			});
			
			$.getJSON('getGroup.do', {ShareType : '${ShareType}',GroupID : '${GroupID}'}, function(d) {
				d.list.forEach(function(d) {
					$("#txtGroupName").val(d.GroupName);
					$("#txtGroupPriorityOrder").val(d.OrderNO);
				});
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("getGroupList.do", response, status, error);
			});
				
		} 
	}); 
  
	function closeLayer() {
		/* if(g_isCors == "Y") {
			var corsDomain = Common.getBaseConfig("CORSDomain");
			document.location.href = corsDomain + "/WebSite/Portal/WebPart/WorkReport/WebPartClose.aspx";
		} else {
			if(g_mode == "W") { */
				var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
				
				if(isWindowed.toLowerCase() == "true") {
					window.close();
				} else {
					parent.Common.close('CreateBizCardGroupPop');
				}
			/* }
			else if (g_mode == "M")
				document.location.href = "viewWorkReport.do?wrid=" + g_workReportId + "&calid=" + settingObj.calendar.CalID + "&uid=" + settingObj.userCode;
		} */
	};
	
	function CheckValidation(pObj) {
	    var bReturn = true;
	    
	    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	    
	    if ($.trim($("#txtGroupName").val()) == "") {
	        Common.Warning("<spring:message code='Cache.msg_EnterGroupNamer'/>", ""); //그룹명을 입력하세요.
	        bReturn = false;
	    } else if ($.trim($("#txtGroupPriorityOrder").val()) == "") {
	        Common.Warning("<spring:message code='Cache.msg_EnterPriorityNumber'/>", ""); //우선순위를 입력하세요.
	        bReturn = false;
	    } else if (Number($("#txtGroupPriorityOrder").val()) < 0) {
	    	Common.Warning("<spring:message code='Cache.msg_bizcard_doNotEnterNegativePriority'/>", ""); //우선순위에 음수를 입력할 수 없습니다.
	        bReturn = false;
	    }
	
	    if(!bReturn) return false;
		
		$.ajaxSetup({
		     async: true
		});
		
		if(pObj.id == 'btnSave'){
			$.ajax({
				url : "RegistGroup.do",
				type : "POST",
				data : {
					"GroupName" :  $("#txtGroupName").val(),
					"GroupPriorityOrder" :  $("#txtGroupPriorityOrder").val(),
					"ShareType" :  "${ShareType}"
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_SuccessRegist'/>", 'Information Dialog', function (result) { //정상적으로 등록되었습니다.
								parent.window.location.reload();
					        }); 
						} else if(d.result == "FAIL") {
							Common.Warning("<spring:message code='Cache.msg_ErrorRegistBizCardGroup'/>"); //그룹 등록 오류가 발생했습니다.
						} else {
							Common.Warning("<spring:message code='Cache.msg_CantRegistGroupDuplicateName'/>"); //이름이 중복된 그룹은 등록할 수 없습니다.
						}
					} catch(e) {
						coviCmn.traceLog(e);
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("RegistGroup.do", response, status, error);
				}
			});
		} else if(pObj.id == 'btnModify'){
			$.ajax({
				url : "ModifyGroup.do",
				type : "POST",
				data : {
					"GroupName" :  $("#txtGroupName").val(),
					"GroupPriorityOrder" :  $("#txtGroupPriorityOrder").val(),
					"GroupID" : "${GroupID}"
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_SuccessModify'/>", 'Information Dialog', function (result) { //정상적으로 수정되었습니다.
								parent.bizCardGrid.reloadList();
								closeLayer();
					        }); 
						} else if(d.result == "FAIL") {
							Common.Warning("<spring:message code='Cache.msg_ErrorModifyBizCardGroup'/>"); //그룹 수정 오류가 발생했습니다.
						} else {
							Common.Warning("<spring:message code='Cache.msg_CantRegistGroupDuplicateName'/>"); //이름이 중복된 그룹은 등록할 수 없습니다.
						}
					} catch(e) {
						coviCmn.traceLog(e);
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("ModifyGroup.do", response, status, error);
				}
			});
		}
	}
</script>