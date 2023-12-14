<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/task.js<%=resourceVersion%>"></script>

<div class="layer_divpop ui-draggable taskPopLayer " id="testpopup_p" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent taskAppointedContent">
			<!--팝업 내부 시작 -->
			<div class="selectSearchBox">
					<span><spring:message code='Cache.lbl_USER_NAME_01'/><!-- 사용자명 --></span>
					<span><input id="searchWord" type="text" onkeypress="if (event.keyCode==13){ setGridConfig(); searchConfig(); return false;}"/><a class="btnSearchType01" onclick="searchConfig(); return false;"></a></span>
					<button class="btnRefresh" type="button" onclick="setGridConfig(); searchConfig(); return false;"></button>					
			</div>	
			<div class="surTargetBtm">					
				<div class="tblList">	
					<div id="userGrid" >
					</div>
				</div>
			</div>
			<div class="bottom">
				<a class="btnTypeDefault btnTypeBg" onclick="setPerformer(); return false;"><spring:message code='Cache.lbl_Confirm'/><!-- 확인 --></a>
				<a class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.lbl_Cancel'/><!-- 취소 --></a>
			</div>
			<!--팝업 내부 끝 -->
		</div>
	</div>
</div>


<script>
	//# sourceURL=ShareUserListPopup.jsp
	var userGrid = new coviGrid();
	var folderID = isNull(CFN_GetQueryString("folderID"), '');
	var callback = isNull(CFN_GetQueryString("callback"), '');
	
	init();
	
	function init(){
		setGrid();			// 그리드 세팅		
		setTimeout(function(){ Common.toResizeDynamic('shareUserList', 'testpopup_p'); }, 400)
	}

	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		userGrid.setGridHeader([	            
		    	                  {key:'chk', label:'chk', width:'5', align:'center', formatter: 'checkbox'}, 
		    	                  {key:'Name',  label:"<spring:message code='Cache.lbl_Coowner'/>", width:'40', align:'center', sort: "asc", addClass:'bodyTdFile',		/*공유자*/
		    	                	  formatter:function(){
		    	                		  return '<div id="btnFlower" class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ this.item.Code +'" data-user-mail="" >' + this.item.Name +'</div>';
		    	                	  }},  
		    	                  {key:'DeptName',  label:"<spring:message code='Cache.lbl_dept'/>", width:'55', align:'center'},     /*부서*/
		    		      		]);
		
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = 
			userGrid.setGridConfig({
			height:"auto",
			targetID : "userGrid",
			page:{
				pageNo:1,
				pageSize:8
			}
		});
	}
	

	//그리드 바인딩
	function searchConfig(){		
		var searchWord = $("#searchWord").val();
		userGrid.bindGrid({
				ajaxUrl:"/groupware/task/getShareUseList.do",
				ajaxPars: {
					"FolderID":folderID,
					"searchWord":searchWord
				}
		});
	}	
	
	function setPerformer(){
		var selectedList = userGrid.getCheckedList(0);
		
		XFN_CallBackMethod_Call("taskSet",callback, JSON.stringify(selectedList));
		parent.Common.close('shareUserList');
	}

</script>