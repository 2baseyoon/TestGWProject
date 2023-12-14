<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var formFieldInfoPopupManager;
	$(document).ready(function(){		
		formFieldInfoPopupManager = new FormFieldInfoPopupManager('<c:out value="${param.FormID}" />');
		formFieldInfoPopupManager.init();
	});
	
	function FormFieldInfoPopupManager (formID) {
		var __formID = formID;
		this.init = function () {
	    	getFormInfo(__formID);
		};
		
	    var getFormInfo = function(FormID){
	    	$.ajax({
	    		url : "/approval/manage/getFormFieldInfo.do",
	    		data : { "formID" : FormID},
	    		method : "POST",
	    		success : function (data) {
					setData(data);
	    		}
	    	});
	    };
	    
	    var setData = function (data) {
	    	$("#CommonFieldWrap").html(data["CommonFieldHtml"]);
	    	$("#BodyFieldWrap").html(data["BodyFieldHtml"]);
	    	
	    	/**
	    	공통
			spParams.put("formPrefix",formPrefix);
			spParams.put("bodyContext",bodyContext);
			spParams.put("formInfoExt",formInfoExt);
			spParams.put("approvalContext",approvalContext);
			spParams.put("preApproveprocsss",preApproveprocsss);
			spParams.put("apvResult",apvResult);
			spParams.put("docNumber",docNumber);
			spParams.put("approverId",approverId);
			//spParams.put("comment",comment);
			spParams.put("formInstID",formInstID);
			spParams.put("apvMode",apvMode);
			spParams.put("processID",processID);
			spParams.put("formHelperContext",formHelperContext);
			spParams.put("formNoticeContext",formNoticeContext);
			spParams.put("domainID",domainID);
			spParams.put("formInstance",formInstance);
	    	*/
	    	/*
	    	$("#CommonFieldWrap").find("[data-type=dField]").each(function () {
	    		if(this.id != '') {
		    		$("table#content > tbody").append("<tr><td style='text-align:center;'>"+ this.getAttribute("data-type") +"</td><td>"+ this.id +"</td></tr>");
	    		}
	    	});
	    	*/
	    	var _commonFields = [];
	    	_commonFields.push({"id": "formPrefix", "data-type" : "공통", "name" : "양식키"});
	    	_commonFields.push({"id": "docNumber", "data-type" : "공통", "name" : "문서번호"});
	    	_commonFields.push({"id": "approverId", "data-type" : "공통", "name" : "결재자UserCode"});
	    	_commonFields.push({"id": "formInstID", "data-type" : "공통", "name" : "formInstID"});
	    	_commonFields.push({"id": "processID", "data-type" : "공통", "name" : "processID"});
	    	_commonFields.push({"id": "apvMode", "data-type" : "공통", "name" : "결재종류"});
	    	_commonFields.push({"id": "apvResult", "data-type" : "공통", "name" : "결재결과"});
	    	_commonFields.push({"id": "domainID", "data-type" : "공통", "name" : "회사아이디"});
	    	_commonFields.push({"id": "SUBJECT", "data-type" : "공통", "name" : "문서제목"});
	    	_commonFields.push({"id": "INITIATORID", "data-type" : "공통", "name" : "기안자UserCode"});
	    	_commonFields.push({"id": "INITIATEDDATE", "data-type" : "공통", "name" : "기안일시"});
	    	for(var idx = 0; idx < _commonFields.length; idx++) {
	    		var info = _commonFields[idx];
	    		$("table#content > tbody").append("<tr><td style='text-align:center;'>"+ info["data-type"] +"</td><td>"+ info["id"] +"</td><td>"+ info["name"] +"</td></tr>");
	    	}
	    	$("#BodyFieldWrap").find("[data-type=mField],[data-type=smField]").each(function () {
	    		if(this.id != '') {
			    	$("table#content > tbody").append("<tr><td style='text-align:center;'>"+ this.getAttribute("data-type") +"</td><td>"+ this.id +"</td><td>양식항목</td></tr>");
	    		}
	    	});
	    	
	    }
	}
</script>
<style>
	.admin-list th{
		text-align: center !important; 
		padding:5px 10px 5px 10px !important;
		height:35px;
	}
	.admin-list th:last-child { border-right:0 !important; }
</style>
<div class="sadmin_pop" style="margin:0px;">
	<div id="formsGrid">
		<div style="display:none;" id="CommonFieldWrap">
		</div>
		<div style="display:none;" id="BodyFieldWrap">
		</div>
		<div>
			<table  id="content" class="sadmin_table sa_menuBasicSetting admin-list">
				<colgroup>
					<col width="20%">
					<col width="30%">
					<col width="50%">
				</colgroup>
				<thead>
				<tr>
					<th>Data Type</th>
					<th>Key</th>
					<th>설명</th>
				</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>
	</div>
</div>