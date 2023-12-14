<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!DOCTYPE HTML>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<meta name="viewport" content="width=1280">
	<title>Smart² - SaaS#1</title>
	
	<script>var PARAM_VALID = 'N';</script>
    <link rel="stylesheet" type="text/css" href="http://192.168.11.22/HtmlSite/smarts4j_n/simpleAdmin/resources/css/simpleAdmin.css"/>
    <link rel="stylesheet" type="text/css" href="http://192.168.11.22//HtmlSite/smarts4j_n/covicore/resources/css/axisj/arongi/AXGrid.css?ver=20230214_1">
    <link rel="stylesheet" type="text/css" href="http://192.168.11.22//HtmlSite/smarts4j_n/covicore/resources/css/common.css?ver=20230214_1">
    <link rel="stylesheet" type="text/css" href="http://192.168.11.22//HtmlSite/smarts4j_n/covicore/resources/css/covision/Controls.css?ver=20230214_1">    
	<link rel="stylesheet" id="themeCSS" type="text/css" href="http://192.168.11.22//HtmlSite/smarts4j_n/covicore/resources/css/theme/black.css?ver=20230223_3" >
	
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
			/* transition:right .7s; */
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
	</style>
</head>
<body>
    <div class="commContRight">
        <div id="tab" style="display: none;"></div>
        <div id="content">
            <div class="cRConTop titType AtnTop">
                <h2 class="title">서버 설정 리포팅</h2>
                <div style="float: right; margin: 15px 10px 0px 0px;">
                	<a id="chkAllBtn" class="btnTypeDefault" style="" onclick="standardSetting();">설정</a>
                </div>
            </div>
            <div class="cRContBottom mScrollVH">
                <form id="form1">
                    <div class="sadminContent">
                        <div  class="tabContent active">
                            <table class="sadmin_table company_info">
                                <colgroup>
                                    <col width="10%;">
                                    <col width="20%">
                                    <col width="10%">
                                    <col width="20%">
                                    <col width="10%;">
                                    <col width="30%">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th>IsSaaS</th>
                                        <td>
                                            <div class="radioStyle05">
                                                <input type="radio" id="radio_isSaaS_Y" name="radio_isSaaS" value="Y" checked="checked">
                                                <label for="radio_isSaaS_Y" style="opacity: 1;">Y</label>
                                            </div>
                                            <div class="radioStyle05">
                                                <input type="radio" id="radio_isSaaS_N" name="radio_isSaaS" value="N" >
                                                <label for="radio_isSaaS_N" style="opacity: 1;">N</label>
                                            </div>
                                        </td>
                                        
                                        <th>DB Type</th>
                                        <td>
                                        	<c:forEach var="list" items="${dbList}" varStatus="status">
												<div class="radioStyle05">
	                                                <input type="radio" id="radio_DBType_${list.Code}" name="dbType" value="${list.Code}" <c:if test="${status.index eq '0' }"> checked="checked" </c:if>>
	                                                <label for="radio_DBType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
	                                            </div>
											</c:forEach>
                                        </td>
                                        
                                        <th>WEB/WAS Type</th>
                                        <td>
                                        	<c:forEach var="list" items="${wasList}" varStatus="status">
												<div class="radioStyle05">
	                                                <input type="radio" id="radio_wasType_${list.Code}" name="wasType" value="${list.Code}" <c:if test="${status.index eq '0' }"> checked="checked" </c:if>>
	                                                <label for="radio_wasType_${list.Code}" style="opacity: 1;">${list.CodeName}</label>
	                                            </div>
											</c:forEach>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <ul class="tabMenu clearFloat">
                            <li id="propertiesTab" class="active" value="propertiesTab" style="height: 30px; line-height: 28px;"><a href="javascript:void();">서버 설정 파일</a></li>
                            <li id="contextTab" value="contextTab" style="height: 30px; line-height: 28px;"><a href="javascript:void();">context.xml</a></li>
                            <li id="mailTab" value="mailTab" style="height: 30px; line-height: 28px;"><a href="javascript:void();">mail 설정</a></li>
                        </ul>                        

                        <div id="propertiesDiv">
                            <table class="sadmin_table company_info">                                
                                <tbody>
                                    <tr>
                                        <th style="width:200px">Properties type</th>
                                        <td>
                                        	<c:forEach var="list" items="${propertiesList}" varStatus="status">
												<input type="checkbox" id="propertyType_${list.Code}" name="propertyType" value="${list.Code}" >&nbsp; <label>${list.CodeName}</label>&nbsp;
											</c:forEach>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th style="width:200px">조회 대상</th>
                                        <td >
                                            <input type="checkbox" id="checkbox6" name="type2" value="" >&nbsp; <label>Reference (정의된 기준값)</label>&nbsp;
                                            
                                            <c:forEach var="list" items="${serverList}" varStatus="status">
												<input type="checkbox" id="${list.server_ip}" name="serverList" value="${list.server_ip}" >&nbsp; <label>${list.server_ip} (${list.registdate})</label>&nbsp;
											</c:forEach>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            
							<div style="float: right; margin-bottom: 10px;">
	                            <div class="selBox">
	                                <a id="chkAllBtn" class="btnTypeDefault" style="" onclick="BatchCheck(ListGrid);">검색</a><!-- 일괄확인 -->
	                            </div>
	                            <div class="selBox">
	                                <a id="A3" class="btnTypeDefault" style="" onclick="excelDownload();">엑셀저장</a><!-- 일괄확인 -->
	                            </div>
	                        </div>
                            
                            <table class="sadmin_table">
                                <colgroup>
                                   <col width="auto" />
                                   <col width="auto" />
                                   <col width="auto" />
                                   <col width="auto" />
                                   <col width="auto" />
                                   <col width="auto" />
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th>Properties type</th>
                                        <th>Key name</th>
                                        <th>Reference Value</th>
                                        <th>Framwork Value</th>
                                        <th>192.168.56.1</th>
                                        <th>설명</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>globals.properties</td>
                                        <td>quartz.mode</td>
                                        <td>N</td>
                                        <td>N</td>
                                        <td>N</td>
                                        <td> # 스케쥴러 사용여부 (사용여부에 따라 동작안함)</td>
                                    </tr>
                                </tbody>
                            </table> 
						</div>
						
						<div id="infraDiv" style="display: none;">                
                            <table class="sadmin_table company_info">                                
                                <tbody>
                                    <tr>
                                        <th style="width:200px">Properties type</th>
                                        <td>
                                        	<c:forEach var="list" items="${propertiesInfraList}" varStatus="status">
												<input type="checkbox" id="propertyType_${list.Code}" name="propertyType" value="${list.Code}" >&nbsp; <label>${list.CodeName}</label>&nbsp;
											</c:forEach>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th style="width:200px">조회 대상</th>
                                        <td >
                                            <input type="checkbox" id="checkbox6" name="type2" value="" >&nbsp; <label>Reference (정의된 기준값)</label>&nbsp;
                                            
                                            <c:forEach var="list" items="${serverList}" varStatus="status">
												<input type="checkbox" id="${list.server_ip}" name="serverList" value="${list.server_ip}" >&nbsp; <label>${list.server_ip} (${list.registdate})</label>&nbsp;
											</c:forEach>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            
							<div style="float: right; margin-bottom: 10px;">
	                            <div class="selBox">
	                                <a id="chkAllBtn" class="btnTypeDefault" style="" onclick="BatchCheck(ListGrid);">검색</a><!-- 일괄확인 -->
	                            </div>
	                            <div class="selBox">
	                                <a id="A3" class="btnTypeDefault" style="" onclick="excelDownload();">엑셀저장</a><!-- 일괄확인 -->
	                            </div>
	                        </div>
                            
                            <table class="sadmin_table">
                                <colgroup>
                                   <col width="auto" />
                                   <col width="auto" />
                                   <col width="auto" />
                                   <col width="auto" />
                                   <col width="auto" />
                                   <col width="auto" />
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th>Properties type</th>
                                        <th>Key name</th>
                                        <th>Reference Value</th>
                                        <th>Framwork Value</th>
                                        <th>192.168.56.1</th>
                                        <th>설명</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>globals.properties</td>
                                        <td>quartz.mode</td>
                                        <td>N</td>
                                        <td>N</td>
                                        <td>N</td>
                                        <td> # 스케쥴러 사용여부 (사용여부에 따라 동작안함)</td>
                                    </tr>
                                </tbody>
                            </table> 
						</div>
						
						<div id="contextDiv" style="display: none;">
							${contextHTML}
						</div>
						
						<div id="mailDiv" style="display: none;">
							${mailHTML}
						</div>
					</div>
                </form>
            </div>
        </div>
    </div>
</body>
<script type="text/javascript">
	$(document).ready(function (){
		// 탭 클릭 이벤트 설정
		$(".tabMenu li").on("click", function(){
			$(".tabMenu li").removeClass("active");
			$(this).addClass("active");
			
			var str = $(this).attr("value");
			
			if(str == "propertiesTab") {
				$("#propertiesDiv").show();
				$("#contextDiv").hide();
				$("#mailDiv").hide();
			} else if(str == "contextTab") {
				$("#propertiesDiv").hide();
				$("#contextDiv").show();
				$("#mailDiv").hide();
				
				context();
			} else if(str == "mailTab") {
				$("#propertiesDiv").hide();
				$("#contextDiv").hide();
				$("#mailDiv").show();
			}
		});
	});
</script>

<script type="text/javascript">
${contextJS}
</script>