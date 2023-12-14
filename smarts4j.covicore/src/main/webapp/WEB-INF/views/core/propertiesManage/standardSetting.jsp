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
	 <div class="commContRight">
        <div id="content">
            <div class="cRConTop titType AtnTop">
                <h2 class="title">설정</h2>
            </div>
            <div class="cRContBottom mScrollVH">
                <form id="form1">
                    <div class="sadminContent">
                        <div  class="tabContent active">
                            <table class="sadmin_table company_info">
                                <colgroup>
                                    <col width="10%;">
                                    <col width="25%">
                                    <col width="10%">
                                    <col width="25%">
                                    <col width="10%">
                                    <col width="25%">
                                </colgroup>
                                <tbody>
                                	<tr>
                                		<th>Standard Type</th>
                                		<td colspan="5">
											<c:forEach var="list" items="${standardList}" varStatus="status">
												<div class="radioStyle05">								
													<input type="radio" id="radio_standardType_${list.Code}" name="standardType" value="${list.Code}" <c:if test="${status.index eq '0' }"> checked="checked" </c:if>>
												    <label for="radio_standardType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
											    </div>
											</c:forEach>
                                		</td>
                                	</tr>
                                	<tr>
                                		<th>Context Type</th>
                                		<td colspan="5">
											<c:forEach var="list" items="${contextList}" varStatus="status">
												<div class="radioStyle05">								
													<input type="radio" id="radio_standardType_${list.Code}" name="standardType" value="${list.Code}" <c:if test="${status.index eq '0' }"> checked="checked" </c:if>>
												    <label for="radio_standardType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
											    </div>
											</c:forEach>
                                		</td>
                                	</tr>
                                	<tr>
                                		<th>Infra Type</th>
                                		<td colspan="5">
											<c:forEach var="list" items="${infraList}" varStatus="status">
												<div class="radioStyle05">								
													<input type="radio" id="radio_standardType_${list.Code}" name="standardType" value="${list.Code}" <c:if test="${status.index eq '0' }"> checked="checked" </c:if>>
												    <label for="radio_standardType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
											    </div>
											</c:forEach>
                                		</td>
                                	</tr>
                                    <tr>
                                        <th>IsSaaS</th>
                                        <td>
                                        	<div class="radioStyle05">
                                                <input type="radio" id="radio_isSaaS_" name="isSaaS" value="" checked="checked">
                                                <label for="radio_isSaaS_" style="opacity: 1;">전체</label>
                                            </div>
                                            
                                        	<div class="radioStyle05">
                                                <input type="radio" id="radio_isSaaS_A" name="isSaaS" value="A">
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
                                        
                                        <th>DB Type</th>
                                        <td>
                                        	<div class="radioStyle05">
                                                <input type="radio" id="radio_DBType_" name="dbType" value="" checked="checked">
                                                <label for="radio_DBType_" style="opacity: 1;">전체</label>
                                            </div>
                                        
                                        	<div class="radioStyle05">
                                                <input type="radio" id="radio_DBType_A" name="dbType" value="A">
                                                <label for="radio_DBType_A" style="opacity: 1;">공통</label>
                                            </div>
                                            
                                            <c:forEach var="list" items="${dbList}" varStatus="status">
												<div class="radioStyle05">
	                                                <input type="radio" id="radio_DBType_${list.Code}" name="dbType" value="${list.Code}">
	                                                <label for="radio_DBType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
	                                            </div>
											</c:forEach>
                                        </td>
                                        
                                        <th>WEB/WAS Type</th>
                                        <td>
                                        	<div class="radioStyle05">
                                                <input type="radio" id="radio_wasType_" name="wasType" value="" checked="checked">
                                                <label for="radio_wasType_" style="opacity: 1;">전체</label>
                                            </div>
                                            
                                        	<div class="radioStyle05">
                                                <input type="radio" id="radio_wasType_A" name="wasType" value="A">
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
                                    	<th>Type</th>
                                    	<td>
                                    		<div class="radioStyle05">
											    <input type="radio" id="radio_standardType_" name="type" value="" checked="checked">
											    <label for="radio_standardType_" style="opacity: 1;">전체</label>
											</div>
											
                                    		<div class="radioStyle05">
											    <input type="radio" id="radio_standardType_mutable" name="type" value="mutable">
											    <label for="radio_standardType_mutable" style="opacity: 1;">가변</label>
											</div>
											
											<div class="radioStyle05">
											    <input type="radio" id="radio_standardType_immutable" name="type" value="immutable">
											    <label for="radio_standardType_immutable" style="opacity: 1;">불변</label>
											</div>
                                    	</td>
                                    	<th>Set Key</th>
                                    	<td>
                                    		<input type="text" name="setKey">
                                    	</td>
                                    	<th>Name</th>
                                    	<td>
                                    		<input type="text" name="name">
                                    	</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <div style="width: 100%; height: 50px;">
	                        <div style="float: right; margin-bottom: 10px;">
	                        	<div class="selBox">
	                        		<a id="A3" class="btnTypeDefault" style="" onclick="insert();">등록</a>
	                        		<a id="A3" class="btnTypeDefault" style="" onclick="remove();">삭제</a>
	                                <a id="A3" class="btnTypeDefault" style="" onclick="listSearch();">검색</a>
	                            </div>
	                        </div>
                        </div>
                        
                        <div>
							<div id="gridArea" class="pad10"></div>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
</body>

<script type="text/javascript">
	var listGrid = new coviGrid();
	
	$(document).ready(function () {
		listGrid.setGridHeader([
			{	
				key:'chk',					
				label:'chk',		
				width:'20',		
				align:'center',
				formatter:'checkbox'
			},
			{
			    key: "id",
			    label: "id",
			    width: "100",
			    align: "center",
			    formatter: function() {
			    	return `<div style="cursor: pointer; height: 100%; width: 100%; color: #0088ff;" onclick="update(${'${this.item.id}'});"><strong>${'${this.item.id}'}</strong></div>`;
			    }
			},
			{
			    key: "standardtype",
			    label: "Standard Type",
			    width: "150",
			    align: "center"
			},
			{
			    key: "type",
			    label: "Type",
			    width: "150",
			    align: "center"
			},
			{
			    key: "isSaaS",
			    label: "Is SaaS",
			    width: "150",
			    align: "center"
			},
			{
			    key: "dbtype",
			    label: "Database Type",
			    width: "150",
			    align: "center"
			},
			{
			    key: "wasType",
			    label: "Web Application Server Type",
			    width: "150",
			    align: "center"
			},
			{
			    key: "setkey",
			    label: "Set Key",
			    width: "150",
			    align: "center"
			},
			{
			    key: "setvalue",
			    label: "Set Value",
			    width: "150",
			    align: "center"
			},
			{
			    key: "description",
			    label: "Description",
			    width: "150",
			    align: "left"
			},
			{
			    key: "name",
			    label: "Name",
			    width: "150",
			    align: "center"
			}
		]);
		
		listGrid.setGridConfig({
			targetID : "gridArea",
			height: "400",
			paging: false,
			sort: false,
		});
		
		listSearch();
	});
	
	function listSearch() {
		listGrid.bindGrid({
			ajaxUrl: "/covicore/standardSetting/list.do",
			ajaxPars: {
				standardType: $('input[name="standardType"]:checked').val(),
				isSaaS: $('input[name="isSaaS"]:checked').val(),
				dbType: $('input[name="dbType"]:checked').val(),
				wasType: $('input[name="wasType"]:checked').val(),
				type: $('input[name="type"]:checked').val(),
				setKey: $('input[name="setKey"]').val(),
				name: $('input[name="name"]').val()
			}
		});
	}
	
	function insert() {
		var popupUrl = "/covicore/standardSettingPopup.do";
		
		var popupWidth = 1000;
		var popupHeight = 700;

		var screenLeft = window.screenLeft || window.screenX;
		var screenTop = window.screenTop || window.screenY;
		var screenWidth = window.innerWidth || document.documentElement.clientWidth || window.screen.width;
		var screenHeight = window.innerHeight || document.documentElement.clientHeight || window.screen.height;
		var left = screenLeft + (screenWidth - popupWidth) / 2;
		var top = screenTop + (screenHeight - popupHeight) / 2;

		var popupWindow = window.open(popupUrl, "standardSettingPopup", "width=" + popupWidth + ",height=" + popupHeight + ",left=" + left + ",top=" + top);

		if (!popupWindow) {
		    alert("팝업 차단 기능이 활성화되어 있습니다.");
		}
	}
	
	function update(id) {
		var popupUrl = "/covicore/standardSettingPopup.do?id=" + id;
		
		var popupWidth = 1000;
		var popupHeight = 700;

		var screenLeft = window.screenLeft || window.screenX;
		var screenTop = window.screenTop || window.screenY;
		var screenWidth = window.innerWidth || document.documentElement.clientWidth || window.screen.width;
		var screenHeight = window.innerHeight || document.documentElement.clientHeight || window.screen.height;
		var left = screenLeft + (screenWidth - popupWidth) / 2;
		var top = screenTop + (screenHeight - popupHeight) / 2;

		var popupWindow = window.open(popupUrl, "standardSettingPopup", "width=" + popupWidth + ",height=" + popupHeight + ",left=" + left + ",top=" + top);

		if (!popupWindow) {
		    alert("팝업 차단 기능이 활성화되어 있습니다.");
		}
	}
	
	function remove() {
		var chks = listGrid.getCheckedList(0);
		
		if (chks.length == 0) {
			alert("선택된 항목이 존재하지 않습니다.");
			return;
		}
		
		let request = chks.map(function(item) { return item.id; });
		
		let options = {
			headers: new Headers({
				"Content-type": "application/json"
			}),
			url: "/covicore/standardSetting/delete.do",
			method: "DELETE",
			body: JSON.stringify(request)
		}
		
		fetch(options.url, options)
			.then((response) => response.json().then((json) => {
				if (json.status == "success") {
					listSearch();
				}
				if (json.status == "fail") {
					alert("삭제에 실패했습니다.");
				}
			}));
	}
</script>