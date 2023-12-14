<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %> 
<% String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer(); %>
<!DOCTYPE HTML>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<title>Smart² - SaaS#1</title>
	
	<script>var PARAM_VALID = 'N';</script>
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/simpleAdmin/resources/css/simpleAdmin.css"/>
    <link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXGrid.css<%=resourceVersion%>">
    <link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>">
    <link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>">    
	<link rel="stylesheet" id="themeCSS" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/black.css<%=resourceVersion%>" >
	
	<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/activiti/manageActiviti.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXGrid.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/idle-timer.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.editor.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.comment.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.file.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.menu.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.acl.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.orgchart.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.control.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/Dictionary.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.treetable.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/validation.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/autosize.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/palette-color-picker.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/html2canvas.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXTree.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXInput.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXInputPro.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXMultiSelector.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXValidator.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXSelect.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXTab.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
	
	<style>
		#header>h1 a {
			background: url('/covicore/common/logo/PC_Logo.png.do') no-repeat left
				center
		}

		.commContRight {
			position: absolute;
			top: 0;
			bottom: 0;
			left: 0;
			right: 0;
		}
		
		.l_img1 {
			max-width: 200px;
			max-height: 70px;
		}
	
		.l_img2 {
			max-width: 300px;
			max-height: 52px;
	    }
	
		.l_img3 {
			max-width: 450px;
			max-height: 100px;
		}
	
		.l_img4 {
			max-width: 430px;
			max-height: 250px;
		}
		
		table {
	    	font-size: 13px;
		}
		
		.sadminContent table.sadmin_table thead tr th {
		    position: relative;
		    border-right: 1px solid #ddd;
		    padding: 5px 10px;
		    font-weight: normal;
		    text-align: left;
		    line-height: 1.2;
		    height: 40px;
		    overflow: hidden;
		    text-overflow: ellipsis;
		}
		
		.sadminContent table.sadmin_table tbody tr td {
		    border-right: 1px solid #ddd;
		    padding: 5px 10px;
		    height: 40px;
		    overflow: hidden;
		    text-overflow: ellipsis;
		}
		
		.radioStyle05 {
			margin-left: 0px !important;
			margin-right: 10px;
		}
	</style>
</head>
<body>
	<input type="hidden" name="id">
	<div class="commContRight">
        <div id="content">
            <div class="cRConTop titType AtnTop">
                <h2 class="title">등록/수정</h2>
            </div>
            <div class="cRContBottom mScrollVH">
                <form id="form1">
                    <div class="sadminContent">
                        <div  class="tabContent active">
                            <table class="sadmin_table company_info">
                                <colgroup>
                                    <col width="20%;">
                                    <col width="80%;">
                                </colgroup>
                                <tbody>
                                	<tr>
                                		<th>Standard Type</th>
                                		<td>
                                			<c:forEach var="list" items="${propertiesList}" varStatus="status">
												<div class="radioStyle05">								
													<input type="radio" id="radio_standardType_${list.Code}" name="standardType" value="${list.Code}" <c:if test="${status.index eq '0' }"> checked="checked" </c:if>>
												    <label for="radio_standardType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
											    </div>
											</c:forEach>
                                		</td>
                                	</tr>
                                	<tr>
                                		<th>Type</th>
                                		<td>
                                    		<div class="radioStyle05">
											    <input type="radio" id="radio_type_mutable" name="type" value="mutable" checked="checked">
											    <label for="radio_type_mutable" style="opacity: 1;">가변</label>
											</div>
											
											<div class="radioStyle05">
											    <input type="radio" id="radio_type_immutable" name="type" value="immutable">
											    <label for="radio_type_immutable" style="opacity: 1;">불변</label>
											</div>
                                		</td>
                                	</tr>
                                	<tr>
                                		<th>IsSaaS</th>
                                		<td>
                                        	<div class="radioStyle05">
                                                <input type="radio" id="radio_isSaaS_A" name="isSaaS" value="A" checked="checked">
                                                <label for="radio_isSaaS_A" style="opacity: 1;">공통</label>
                                            </div>
                                            
                                            <div class="radioStyle05">
                                                <input type="radio" id="radio_isSaaS_Y" name="isSaaS" value="Y">
                                                <label for="radio_isSaaS_Y" style="opacity: 1;">Y</label>
                                            </div>
                                            
                                            <div class="radioStyle05">
                                                <input type="radio" id="radio_isSaaS_N" name="isSaaS" value="N" >
                                                <label for="radio_isSaaS_N" style="opacity: 1;">N</label>
                                            </div>
                                		</td>
                                	</tr>
                                	<tr>
                                		<th>DB Type</th>
                                		<td>
                                			<div class="radioStyle05">
                                                <input type="radio" id="radio_DBType_A" name="dbType" value="A" checked="checked">
                                                <label for="radio_DBType_A" style="opacity: 1;">공통</label>
                                            </div>
                                            
                                            <c:forEach var="list" items="${dbList}" varStatus="status">
												<div class="radioStyle05">
	                                                <input type="radio" id="radio_DBType_${list.Code}" name="dbType" value="${list.Code}">
	                                                <label for="radio_DBType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
	                                            </div>
											</c:forEach>
                                		</td>
                                	</tr>
                                	<tr>
                                		<th>WEB/WAS Type</th>
                                		<td>
                                			<div class="radioStyle05">
                                                <input type="radio" id="radio_wasType_A" name="wasType" value="A" checked="checked">
                                                <label for="radio_wasType_A" style="opacity: 1;">공통</label>
                                            </div>
                                            
                                            <c:forEach var="list" items="${wasList}" varStatus="status">
												<div class="radioStyle05">
	                                                <input type="radio" id="radio_wasType_${list.Code}" name="wasType" value="${list.Code}">
	                                                <label for="radio_wasType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
	                                            </div>
											</c:forEach>
                                		</td>
                                	</tr>
                                	<tr>
                                		<th>Set Key</th>
                                    	<td>
                                    		<input type="text" name="setKey">
                                    	</td>
                                    </tr>
                                    <tr>
                                		<th>Set Value</th>
                                    	<td>
                                    		<input type="text" name="setValue">
                                    	</td>
                                    </tr>
                                    <tr>
                                		<th>description</th>
                                    	<td>
                                    		<input type="text" name="description">
                                    	</td>
                                    </tr>
                                    <tr>
                                    	<th>Name</th>
                                    	<td>
                                    		<input type="text" name="name">
                                    	</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <div style="width: 100%; height: 50px; text-align: center;">
						   <div style="float: none; display: inline-block; margin-bottom: 10px;">
						      <div class="selBox">
						         <a id="A3" class="btnTypeDefault" onclick="save();">저장</a>
						         <a id="A3" class="btnTypeDefault" style="" onclick="window.close();">취소</a>
						      </div>
						   </div>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
</body>

<script type="text/javascript">
	
	document.getElementsByName("id")[0].value = new URLSearchParams(location.search).get("id") || "";
	
	const standardSetting = ${standardSetting};
	
	$(document).ready(function () {
		document.getElementById("radio_standardType_" + standardSetting.standardtype).checked = true;
		document.getElementById("radio_type_" + standardSetting.type).checked = true;
		document.getElementById("radio_isSaaS_" + standardSetting.isSaaS).checked = true;
		document.getElementById("radio_DBType_" + standardSetting.dbtype).checked = true;
		document.getElementById("radio_wasType_" + standardSetting.wasType).checked = true;
		document.getElementsByName("setKey")[0].value = standardSetting.setkey;
		document.getElementsByName("setValue")[0].value = standardSetting.setvalue;
		document.getElementsByName("description")[0].value = standardSetting.description;
		document.getElementsByName("name")[0].value = standardSetting.name;
	});
	
	function save() {
		let request = {
			standardType: $('input[name="standardType"]:checked').val(),
			type: $('input[name="type"]:checked').val(),
			isSaaS: $('input[name="isSaaS"]:checked').val(),
			dbType: $('input[name="dbType"]:checked').val(),
			wasType: $('input[name="wasType"]:checked').val(),
			setKey: $('input[name="setKey"]').val(),
			setValue: $('input[name="setValue"]').val(),
			description: $('input[name="description"]').val(),
			name: $('input[name="name"]').val(),
			id: $('input[name="id"]').val(),
		}
		
		if (validate(request)) {
			return;
		};
		
		let options = {
			headers: new Headers({
				"Content-type": "application/json"
			}),
			url: "/covicore/standardSetting/save.do",
			method: "POST",
			body: JSON.stringify(request)
		}
		
		fetch(options.url, options)
			.then((response) => response.json().then((json) => {
				if (json.status == "success") {
					window.opener.listSearch();
					window.close();
				}
				if (json.status == "fail") {
					if (json.message) {
						alert(json.message);
						return;							
					}
					alert("저장에 실패했습니다.");	
				}
			}));
	}
	
	function validate(request) {
		if (request.standardType == "cx") { // context.xml의 validate 확인  
			if (request.dbType != "A" && request.wasType != "A") {
				alert("context.xml의 경우 DB Type과 WEB/WAS Type 둘 중의 하나는 공통을 선택해야 합니다.");
				return true;
			}
		}
	}
</script>