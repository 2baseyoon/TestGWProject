<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/groupware/resources/script/user/task.js<%=resourceVersion%>"></script>

<div class="cRConTop">
	<div class="cRTopButtons ">							
		<div class="surveySetting">
			<div id="stateSelect" style="display:inline;" ></div>
		</div>							
	</div>						
</div>
<div class="cRContBottom mScrollVH ">
	<div class="taskContent">							
		<div class=" cRContBtmTitle">
			<div class="boardTitle">
				<h2><span id="searchWord"  class="colorTheme"></span><spring:message code='Cache.lbl_SearchResult'/><!-- 검색결과 --></h2>
				<div class="boardTitData">
					<select id="sortColumnSelect" class="selectType02" onchange="setSessionStorage('TaskSortColumn','sortColumnSelect'); getSearchAll();">
						<option value=""><spring:message code='Cache.lbl_task_sortCriterion'/><!-- 정렬기준 --></option>
						<option value="Subject"><spring:message code='Cache.lbl_task_SortName'/><!-- 제목순 --></option>
						<option value="RegistDate"><spring:message code='Cache.lbl_SortReg'/><!-- 등록순 --></option>
					</select>
					<select id="sortDirectionSelect" class="selectType02"  onchange="setSessionStorage('TaskSortDirection', 'sortDirectionSelect'); getSearchAll();">
						<option value="ASC"><spring:message code='Cache.lbl_Ascending'/><!-- 오름차순 --></option>
						<option value="DESC"><spring:message code='Cache.lbl_Descending'/><!-- 내림차순 --></option>
					</select>
				</div>
			</div>
		</div>
		<div id="itemContainer" class="taskCont">
			<div id="folderDiv" style="display:none">
				<h2 class="lineTitle"><span><spring:message code='Cache.lbl_task_folder'/><!-- 분류 --></span><span id="folderCnt"></span></h2>
				<div id="folderListContainer" class="mt15px taskListCont">
				</div>
			</div>
			<div id="taskDiv" class="mt25" style="display:none">
				<h2 class="lineTitle"><span><spring:message code='Cache.lbl_task_task'/><!-- 업무 --></span><span id="taskCnt"></span></h2>
				<div id="taskListContainer" class="taskListCont">
				</div>
			</div>
			<div id="tempTaskDiv" class="mt25" style="display:none;">
				<h2 class="lineTitle"><span><spring:message code='Cache.lbl_TempSave'/><!-- 임시저장 --> <spring:message code='Cache.lbl_task_task'/><!-- 업무 --></span><span id="tempTaskCnt">(0)</span></h2>
				<div id="tempTaskListContainer" class="taskListCont">
				</div>
			</div>				
		</div>				
	</div>
</div>
<script>
	//# sourceURL=AllSearch.jsp
	var searchWord = CFN_GetQueryString("search") == "undefined" ? '' : CFN_GetQueryString("search");
	
	init();
	
	function init(){
		g_isSearch = "Y";
		
		$("#searchWord").text(decodeURIComponent(searchWord));
		personFolderTree.clearFocus();
		shareFolderTree.clearFocus();
		
		setTitleWidth();
		
		setControl("search");
		getSearchAll();
	}

</script>