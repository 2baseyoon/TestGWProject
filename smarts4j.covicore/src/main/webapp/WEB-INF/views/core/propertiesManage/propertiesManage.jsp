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
	<meta name="viewport" content="width=1280">
	<title>서버 설정 리포팅</title>
	
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
		    font-weight: bold;
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
		    white-space:nowrap;
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
                                                <input type="radio" id="radio_isSaaS_Y" name="isSaaS" value="Y" checked="checked">
                                                <label for="radio_isSaaS_Y" style="opacity: 1;">Y</label>
                                            </div>
                                            <div class="radioStyle05">
                                                <input type="radio" id="radio_isSaaS_N" name="isSaaS" value="N" >
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
                            <li id="propertiesTab" class="active" value="propertiesTab" style="height: 30px; line-height: 28px;"><a href="javascript:void();">Properties</a></li>
                            <li id="contextTab" value="contextTab" style="height: 30px; line-height: 28px;"><a href="javascript:void();">Context.xml</a></li>
                            <li id="mailTab" value="mailTab" style="height: 30px; line-height: 28px;"><a href="javascript:void();">Mail 설정</a></li>
                            <li id="infraTab" value="infraTab" style="height: 30px; line-height: 28px;"><a href="javascript:void();">infra</a></li>
                            <li id="eumtalkTab" value="eumtalkTab" style="height: 30px; line-height: 28px;"><a href="javascript:void();">Eumtalk</a></li>
                        </ul>                        

                        <div id="propertiesDiv">
                            <table class="sadmin_table company_info">                                
                                <tbody>
                                    <tr>
                                        <th style="width:200px">Properties type</th>
                                        <td>
                                        	<c:forEach var="list" items="${propertiesList}" varStatus="status">
												<input type="checkbox" id="propertyType_${list.Code}" name="propertyType" value="${list.Code}">&nbsp;<label for="propertyType_${list.Code}">${list.CodeName}</label>&nbsp;
											</c:forEach>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th style="width:200px">조회 대상</th>
                                        <td >
                                            <input type="checkbox" id="reference" value="reference" checked="checked" disabled="disabled" style="background: #fff url('/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_chk_02.png') no-repeat center center !important; background-color: #d9d9d9 !important; color: #999;">&nbsp;<label>Reference (정의된 기준값)</label>&nbsp;
                                            <c:forEach var="list" items="${serverList}" varStatus="status">
                                            	<c:if test="${list.server_ip eq 'Framework'}">
                                            		<input type="checkbox" id="${list.server_ip}" name="serverList" value="${list.server_ip}" checked="checked" disabled="disabled" style="background: #fff url('/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_chk_02.png') no-repeat center center !important; background-color: #d9d9d9 !important; color: #999;">&nbsp;<label for="${list.server_ip}">${list.server_ip} (${list.registdate})</label>&nbsp;
                                            	</c:if>
                                            	<c:if test="${list.server_ip ne 'Framework'}">
                                            		<input type="checkbox" id="${list.server_ip}" name="serverList" value="${list.server_ip}" >&nbsp;<label for="${list.server_ip}">${list.server_ip} (${list.registdate})</label>&nbsp;
                                            	</c:if>
											</c:forEach>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>                                                        
							${propertiesHTML}
						</div>
						
						<div id="contextDiv" style="display: none;">
							${contextHTML}
						</div>
						
						<div id="infraDiv" style="display: none;">                
                           <table class="sadmin_table company_info">                                
                               <tbody>
                                   <tr>
                                       <th style="width:200px">Infra File type</th>
                                       <td>
                                       	<c:forEach var="list" items="${propertiesInfraList}" varStatus="status">
											<input type="radio" id="propertyType_${list.Code}" name="infraType" value="${list.Code}" >&nbsp; <label id="propertyName_${list.Code}">${list.CodeName}</label>&nbsp;
										</c:forEach>
                                       </td>
                                    </tr>
                                    <tr>
                                       <th style="width:200px">선택 파일</th>
                                       <td class="preview">
                                       	<p>파일을 선택해주세요</p>
                                       </td>
                                   </tr>
                               </tbody>
                           </table>
                           <div>
                           <a class="btnTypeDefault" onclick="fileUpload()">파일 선택</a>
                           <a class="btnTypeDefault" onclick="fileDelete()">파일 삭제</a>
						<input type="file" class="infrafile" id="file_uploads" style="cursor: pointer; display:none;"></input>
						</div>
						<br>
						${infraHTML}
						</div>
						
						<div id="mailDiv" style="display: none;">
							<table class="sadmin_table company_info" style=""margin-bottom:20px !important">                                
                                <tbody>
                                    <tr>
                                        <th style="width:200px">Properties type</th>
                                        <td>
                                        	<c:forEach var="list" items="${propertiesListMail}" varStatus="status">
												<input type="radio" id="propertyType_${list.Code}" name="propertyTypeMail" value="${list.CodeName}">&nbsp; <label>${list.CodeName}</label>&nbsp;
											</c:forEach>
                                        </td>
                                    </tr>
                                </tbody>
                                <tbody>
									<tr>
										<th id="codeName" style="width:200px">hosts</th>
										<td>
											<textarea id="mailTextArea" style="width: 100%; height: 150px;" placeholder="파일 전체를 복사해서 입력해주세요."></textarea>
									    </td>
									</tr>
								</tbody>
							</table>
							<span style="font-weight: bold;font-size:16px">
									Service : <label style="color: red;vertical-align:inherit;line-height:130%" id="Mail_service"> Postfix </label> <br>
									Location : <label style="color: red;vertical-align:inherit;line-height:130%" id="Mail_location">  /etc/postfix/ </label> <br>
									Properties type : <label style="color: red;vertical-align:inherit;line-height:130%" id="Mail_type"> main.cf </label> <br>
							</span> <br>
							${mailHTML}
						</div>
						
						<div id="eumtalkDiv" style="display: none;">
	                         <table class="sadmin_table company_info">
	                             <tbody>
	                                 <tr>
	                                     <th style="width:200px">EumTalk File type</th>
	                                     <td>
	                                     	<c:forEach var="list" items="${propertiesEumTalkList}" varStatus="status">
												<input type="radio" id="propertyType_${list.Code}" name="eumtalkType" value="${list.Code}"></input>&nbsp;
												<label id="propertyName_${list.Code}">${list.CodeName}</label>&nbsp;
											</c:forEach>
	                                     </td>
	                                 </tr>
	                                 <tr>
	                                     <th style="width:200px">선택 파일</th>
	                                     <td class="eumtalkPreview">
	                                     		<p>파일을 선택해주세요</p>
	                                     </td>
	                                 </tr>
	                             </tbody>
	                         </table>
	                         <div>
		                          <a class="btnTypeDefault" onclick="eumtalkFileUpload()">파일 선택</a>
		                          <a class="btnTypeDefault" onclick="eumtalkFileDelete()">파일 삭제</a>
							      <input type="file" class="eumtalkFile" id="eumtalk_file_uploads" style="cursor: pointer; display:none;"></input>
							 </div>
							 <br/>
							 <HTML>${eumtalkHTML}</HTML>
						</div>
						
					</div>
                </form>
            </div>
        </div>
    </div>
</body>
<script type="text/javascript">
	$(document).ready(function (){	
		$(":radio[name='propertyTypeMail'][value='Postfix/etc/postfix/main.cf']").attr('checked', true);
		// Ajax 호출 시 Progress
		$.ajaxSetup({
		    beforeSend: function (xhr){
		    	if ($(".divpop_overlay").size() == 0){
			        var overlay = $('<div id="dupe_overlay" class="divpop_overlay" style="position:fixed;z-index:100;top:0px;left:0px;width:100%;height:100%;opacity:0.4;">'+
			        		'<div style="width: 100%; height: 100%;display: table;"><span style="display: table-cell;text-align: center;vertical-align: middle;">'+
			    			'<img src="/covicore/resources/images/covision/loding16.gif" style="background: white;padding: 1em;border-radius: .7em;border: 1px solid #888;">'+
			    			'</span></div>'+
			    			'	</div>');
			        
			        overlay.appendTo(document.body);
		    	}
		    	$(".divpop_overlay").show();
		    },
		    complete : function(xhr){
		    	$('#dupe_overlay').remove();
		    	$(".divpop_overlay").remove();
		    }
		});
		
		$("input[name='propertyTypeMail']:radio").change(function () {
			mail();
			var fullvalue = this.value;
	        var type = fullvalue.split("/").reverse()[0];
	        var service = fullvalue.split("/")[0];
	        var location = fullvalue.substring(service.length, fullvalue.length - type.length);
	        $("#codeName").text(type);
	        $("#Mail_service").text(service);
	        $("#Mail_location").text(location);
	        $("#Mail_type").text(type);
		});
		
		$("#mailTextArea").bind('paste',function(e){
	        var el = $(this);
	        setTimeout(function(){
		        var text = $(el).val();
		        text = text.replace(/ /g,"")
		        $('#mailTextArea').val(text);
	        },100);
		});
		
		// 탭 클릭 이벤트 설정
		$(".tabMenu li").on("click", function(){
			$(".tabMenu li").removeClass("active");
			$(this).addClass("active");
			
			var str = $(this).attr("value");
			
			if(str == "propertiesTab") {
				$("#propertiesDiv").show();
				$("#contextDiv").hide();
				$("#mailDiv").hide();
				$("#infraDiv").hide();
				$("#eumtalkDiv").hide();
			} else if(str == "contextTab") {
				$("#propertiesDiv").hide();
				$("#contextDiv").show();
				$("#mailDiv").hide();
				$("#infraDiv").hide();
				$("#eumtalkDiv").hide();
				context();
			} else if(str == "infraTab") {
				$("#propertiesDiv").hide();
				$("#contextDiv").hide();
				$("#mailDiv").hide();
				$("#infraDiv").show();
				$("#eumtalkDiv").hide();
				infra();
			} else if(str == "eumtalkTab") {
				$("#propertiesDiv").hide();
				$("#contextDiv").hide();
				$("#mailDiv").hide();
				$("#infraDiv").hide();
				$("#eumtalkDiv").show();
				eumtalk();
			} else if(str == "mailTab") {
				$("#propertiesDiv").hide();
				$("#contextDiv").hide();
				$("#mailDiv").show();
				$("#infraDiv").hide();
				$("#eumtalkDiv").hide();
				mail();
			} 
		});
	});
</script>


<script type="text/javascript">
	${propertiesJS}
</script>

<script type="text/javascript">
	${contextJS}
</script>

<script type="text/javascript">
	${mailJS}
</script>

<script type="text/javascript">
	${infraJS}
</script>

<script type="text/javascript">
	${eumtalkJS}
</script>
