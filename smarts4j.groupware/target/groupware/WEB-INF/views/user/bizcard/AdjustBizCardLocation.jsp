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
	<div class="layer_divpop ui-draggable popBizCardAddGroup"  id="testpopup_p" style="width:416px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="popContent bizCardCopyMove">
			<div class="rowTypeWrap formWrap">
				<dl>
					<dt><spring:message code='Cache.lbl_SelectDivision' /></dt><!-- 구분 지정 -->
					<dd>
						<span class="radioStyle04">
							<input type="radio" name="rdoDivision" value="P" onchange="rdoDivisionChange(this);" checked="checked" id="rdoDivision_P"/>
							<label for="rdoDivision_P"><span class="mr5"><span></span></span><spring:message code='Cache.lbl_ShareType_Personal' /></label> <!-- 개인 -->
						</span>
						<span class="radioStyle04">
							<input type="radio" name="rdoDivision" value="D" onchange="rdoDivisionChange(this);" id="rdoDivision_D"/> 
							<label for="rdoDivision_D"><span class="mr5"><span></span></span><spring:message code='Cache.lbl_ShareType_Dept' /></label> <!-- 부서 -->
						</span>
						<span class="radioStyle04">
							<input type="radio" name="rdoDivision" value="U" onchange="rdoDivisionChange(this);" id="rdoDivision_U"/> 
							<label for="rdoDivision_U"><span class="mr5"><span></span></span><spring:message code='Cache.lbl_ShareType_Comp' /></label> <!-- 회사 -->
						</span>
					</dd>
				</dl>
				<dl>
					<dt><spring:message code='Cache.lbl_SelectGroup' /></dt><!-- 그룹 지정 -->
					<dd>
						<select name="" class="\ selectType02" id="selGroup_p" style="width: 98%;" onchange="selGroupChange(this)" disabled="disabled">
							<option value=""><spring:message code='Cache.lbl_SelectGroup2' /></option> <!-- 그룹 선택 -->
						</select>
					</dd>
				</dl>
				<dl>
					<dt><spring:message code='Cache.lbl_GroupName'/></dt><!-- 그룹명 -->
		         	<dd>
		         		<input type="text" id="txtNewGroupName_p" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 98%; height: 30px !important;" placeholder="<spring:message code='Cache.lbl_EnterNewGroupName' />">
		     	    </dd>
				</dl>
			</div>
			<div class="popBtnWrap">
				<a href="#" class="btnTypeDefault btnTypeChk" id="btnSave" onclick="CheckValidation();"><spring:message code='Cache.btn_Confirm' /></a><!-- 수정 -->
				<a href="#" class="btnTypeDefault" onclick="javascript:parent.Common.Close('AdjustBizCardLocation');"><spring:message code='Cache.btn_Close'/></a><!-- 취소 -->
			</div>
		</div>
	</div>
</body>
<script>

	var BizCardID = "";
	var Mode = "";
	
	$(function() {
		//viewType 지정 : P(개인), D(부서), U(회사), A(전체)
		$.urlParam = function(name){
			var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
			return results[1] || 0;
		}
		BizCardID = $.urlParam('bizcardid');
		Mode = $.urlParam('mode');
		rdoDivisionChange($('input[name="rdoDivision"]'));
	});
	
	function CheckValidation() {
	    var bReturn = true;
	    
	    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	    
	    if ($("input[type=radio][name=rdoDivision]:checked").length < 1) {
	        Common.Warning("<spring:message code='Cache.msg_SelectDivision'/>", ""); //분류를 지정하세요.
	        bReturn = false;
	    } else if($("#selGroup_p").val() == "") {
	    	Common.Warning("<spring:message code='Cache.msg_SelectGroup'/>", ""); //그룹을 지정하세요.
	        bReturn = false;
	    } else if($("#selGroup_p").val() == "new" && $("#txtNewGroupName_p").val() == "") {
	    	Common.Warning("<spring:message code='Cache.msg_EnterNewGroupName'/>", "");  //새 그룹명을 입력하세요.
	        bReturn = false;
	    }
	
	    if(!bReturn) return false;
	    
	    var GroupID = $("#selGroup_p").val();
	    var GroupName = $("#txtNewGroupName_p").val();
		var TypeCode = $("input[type=radio][name=rdoDivision]:checked").val();
		$.ajaxSetup({
		     async: true
		});
		
		$.ajax({
			url : "/groupware/bizcard/relocateBizCardList.do",
			type : "POST",
			data : {
				"BizCardID":BizCardID,
 				"Mode":Mode,
 				"GroupID":GroupID,
 				"GroupName":GroupName,
 				"TypeCode":TypeCode
			},
			success : function(res) {
				Common.Inform("<spring:message code='Cache.msg_SuccessRegist'/>", 'Information Dialog', function (result) { //정상적으로 등록되었습니다.
					parent.window.location.reload();
				});
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/groupware/bizcard/relocateBizCardList.do", response, status, error);
			}
		});
	}
	
	var rdoDivisionChange = function(obj) {
		var ShareType = $(obj).val();
		
		if($("#selGroup_p").attr('disabled') != undefined) {
			$("#selGroup_p").removeAttr('disabled');
		}
		
		$("#txtNewGroupName_p").parent().parent().css("display", "none");
		$("#selGroup_p").find("option").remove();
		$("#selGroup_p").append('<option value="">' + "<spring:message code='Cache.lbl_SelectGroup2'/>" + '</option>'); //그룹 선택
		$("#selGroup_p").append('<option value="new">' + "<spring:message code='Cache.lbl_newGroup'/>" + '</option>'); //새 그룹
		
		$.ajaxSetup({
		     async: true
		});
		
		$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : ShareType}, function(d) {
			d.list.forEach(function(d) {
				$("#selGroup_p").append('<option value="' + d.GroupID + '">' + d.GroupName + '</option>');
			});
			$("#selGroup_p").append('<option value="none">' + "<spring:message code='Cache.lbl_NoGroup'/>" + '</option>'); //그룹 없음
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/bizcard/getGroupList.do", response, status, error);
		});
	}
	
	var selGroupChange =  function(obj) {
		var selValue = $(obj).val();
		var type = $(obj).attr('id').split('_')[1];
		
		if(selValue == "new") {
			$("#txtNewGroupName_" + type).parent().parent().css("display", "");
			$("div.rowTypeWrap.formWrap").css("padding-bottom", "0px");
		} else {
			$("#txtNewGroupName_" + type).parent().parent().css("display", "none");
			$("div.rowTypeWrap.formWrap").css("padding-bottom", "28px");
		}
	}
</script>