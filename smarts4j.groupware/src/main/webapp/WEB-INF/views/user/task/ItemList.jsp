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
		<div id="topDivButton" class="pagingType02 buttonStyleBoxLeft">
			<a id="btnPrevStep" class="bntPrevStep" onclick="clickBtnPrevStep()"><spring:message code='Cache.lbl_Up'/><!-- 위로 --></a>
			<a id="btnFolderAdd" class="bntFolderAdd" onclick="clickBtnFolderAdd()"><spring:message code='Cache.lbl_task_addFolder'/><!-- 폴더추가 --></a>
			<a id="btnTaskAdd" class="bntWorkAdd" onclick="clickBtnTaskAdd()"><spring:message code='Cache.lbl_task_addTask'/><!-- 업무추가 --></a>								
		</div>
		<div class="surveySetting">
			<div id="stateSelect" style="display:inline;" ></div>
			<select id="searchTypeSelect" class="selectType02">
				<option value="Subject"><spring:message code='Cache.lbl_subject'/><!-- 제목 --></option>
				<option value="OwnerName"><spring:message code='Cache.lbl_Owner'/><!-- 소유자 --></option>
			</select>
			<div class="searchBox03 ">
				<span><input id="searchWord" type="text" onkeypress="if (event.keyCode==13){ getFolderItemList(); return false;}" placeholder="<spring:message code='Cache.lbl_task_searchInFolder'/>"><!--폴더 내 검색--><button type="button" class="btnSearchType01" onclick="getFolderItemList();"><spring:message code='Cache.lbl_search'/><!-- 검색 --></button></span>
			</div>
		</div>							
	</div>						
</div>
<div class="cRContBottom mScrollVH ">
	<div class="taskContent">							
		<div class=" cRContBtmTitle">
			<div class="boardTitle">
				<h2 id="folderName"></h2>		
				<div class="boardTitData">
					<select id="sortColumnSelect" class="selectType02" onchange="setSessionStorage('TaskSortColumn','sortColumnSelect'); getFolderItemList();">
						<option value=""><spring:message code='Cache.lbl_task_sortCriterion'/><!-- 정렬기준 --></option>
						<option value="Subject"><spring:message code='Cache.lbl_task_SortName'/><!-- 제목순 --></option>
						<option value="RegistDate"><spring:message code='Cache.lbl_SortReg'/><!-- 등록순 --></option>
					</select>
					<select id="sortDirectionSelect" class="selectType02"  onchange="setSessionStorage('TaskSortDirection', 'sortDirectionSelect'); getFolderItemList();">
						<option value="ASC"><spring:message code='Cache.lbl_Ascending'/><!-- 오름차순 --></option>
						<option value="DESC"><spring:message code='Cache.lbl_Descending'/><!-- 내림차순 --></option>
					</select>
				</div>
			</div>
		</div>
		<div id="itemContainer" class="taskCont">
			<div id="folderDiv" style="display:none">
				<h2 class="lineTitle"><span><spring:message code='Cache.lbl_task_folder'/><!-- 분류 --></span><span id="folderCnt">(0)</span></h2>
				<div id="folderListContainer" class="mt15 taskListCont">
				</div>
			</div>
			<div id="taskDiv" class="mt25" style="display:none">
				<h2 class="lineTitle"><span><spring:message code='Cache.lbl_task_task'/><!-- 업무 --></span><span id="taskCnt">(0)</span></h2>
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
	//# sourceURL=ItemList.jsp
	
	//ready
	init();
	
	function init(){
		
		initTaskData();
		
		chkAuthority();
		
		setControl("folder");
		getFolderItemList();
	}
	

</script>