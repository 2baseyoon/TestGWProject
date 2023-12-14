<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<script type="text/javascript">
	var callbackFunc = CFN_GetQueryString("callback");
	var lang = Common.getSession("lang");
	var resourceGrid = new coviGrid();

	$(document).ready(function (){
		setSelectBox();  	// 검색 조건 select box 바인딩
		setGrid();			// 그리드 세팅			
	});
	
	
	// 헤더 설정
	var headerData =[	            
	                  {key:'FolderID',  label:'ID', width:'10', align:'center', sort:'desc'},	   /*ID*/
	                  {key:'DomainName',  label:'<spring:message code="Cache.lbl_OwnedCompany"/>', width:'15', align:'center',		/*소유회사 */
	                	  formatter:function(){
	                		  return CFN_GetDicInfo(this.item.DomainName,lang);
	                  }},     
	                  {key:'ResourceName',  label:'<spring:message code="Cache.lbl_Res_Name"/>', width:'35', align:'center',			  /*자원명*/
	                	  formatter:function(){
	                		  return CFN_GetDicInfo(this.item.ResourceName,lang);
	                  }},   
	                  {key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register"/>', width:'15', align: 'center',     /*등록자*/
	                	  formatter:function(){
	                		  return CFN_GetDicInfo(this.item.RegisterName,lang);
	                  }}, 
	                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'25', align:'center', 
	                	  formatter: function(){
	                		  return CFN_TransLocalTime(this.item.RegistDate);
                		  }
	                  }          /*등록일*/ 
		      		];
	
	
	function setSelectBox(){
		coviCtrl.renderDomainAXSelect(
				"domainSelectBox",
				"ko",
				"searchConfig",
				"",
				""
			);
	}
	
	//그리드 세팅
	function setGrid(){
		resourceGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
				targetID : "resourceGrid",
				height:"auto",
				page : {
					pageNo:1,
					pageSize:5
				},
				body:{
					onclick : function(idx,obj){
						// 해당 자원이 이미 공유되었는지 확인.
						$.ajax({
							type:"POST"
							, url : "/groupware/resource/checkDuplicateShareResource.do"
							, data : {
								"folderID" : obj.FolderID
								, "domainID" : parent.$("#leftDomainSelectBox").val()
								}
							, success : function(data) {
								if (data.status=='SUCCESS') {
									if (data.cnt > 0) {
										Common.Warning("<spring:message code='Cache.lbl_apv_already_add'/>"); // 이미 추가되어있습니다.
										return;
									} else {
										returnResource(obj);
									}
								} else {
									Common.Warning("<spring:message code='Cache.msg_apv_030'/>");  /*오류가 발생했습니다. */
								}
							}
							, error : function(response, status, error){
								CFN_ErrorAjax("/groupware/resource/checkDuplicateShareResource.do", response, status, error);
							}
							
						});
					}
				}
			};
		
		resourceGrid.setGridConfig(configObj);
	}

	//그리드 바인딩
	function searchConfig(){		
		resourceGrid.bindGrid({
				ajaxUrl:"/groupware/resource/getShareResourceList.do",
				ajaxPars: {
					"domainID": $("#domainSelectBox").val(),
					"searchWord":$("#search").val()	
				}
		});
		
		$("#resourceGrid").find("table").css("font-size", "13px");
	}	
	
	
 	function returnResource(obj){
 		var retVal = obj.FolderID +"|"+ obj.ResourceName + "|" + obj.MultiDisplayName;
 		
 		XFN_CallBackMethod_Call("divResourceInfo",callbackFunc,  retVal);
 		parent.Common.close('findSharedResource');
 	}
	
</script>
<form id="form1">
    <div style="width:100%;">
		<div id="topitembar02" class="topbar_grid">
			<!--소유회사-->
			<spring:message code="Cache.lbl_OwnedCompany"/>&nbsp;
			<select id="domainSelectBox" class="AXSelect W100"></select>
			&nbsp;&nbsp;&nbsp;
			<spring:message code="Cache.lbl_Res_Name"/>&nbsp;
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="AXInput" />&nbsp;
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig();" class="AXButton"/><!--검색 -->
		</div>	
		<div id="resourceGrid"></div>
		<div class="pop_btn2" align="center" style="margin-top: 20px;">
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="parent.Common.close('findSharedResource');"  class="AXButton" />                    
	    </div>     
	</div>
</form>