<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<style type="text/css">
	.contents {
		padding: 2px 30px 0px 30px;
	}
</style>
</head>
<body>
	<div class="divpop_contents">
		<div class='mScrollVH contents'>
			<div class="inPerView type02 active">
				<div>
					<div class="selectCalView">
						<span><spring:message code='Cache.lbl_Contents'/></span>
						<select id="searchType" class="selectType02">
							<option value="A"><spring:message code='Cache.lbl_all'/></option>
							<option value="C"><spring:message code='Cache.lbl_tf_collaboration_name'/></option> <!-- 협업 명 -->
							<option value="P"><spring:message code='Cache.lbl_tf_collaboration_pm'/></option> <!-- 협업  PM -->
							<option value="M"><spring:message code='Cache.lbl_task_performer'/></option> <!-- 수행자 -->
						</select>
						<div class="dateSel type02">
							<input id="searchText" type="text" onkeypress="if(event.keyCode==13) {goSearch(); return false;}">
						</div>
					</div>
					<div>
						<a href="#" id="btnSearch" onclick="goSearch()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a>
					</div>
				</div>	
			</div>
			
			<div id="ListGrid"></div>
			
			<div class="popBtn" style="text-align: center;">
				<a class="ooBtn" href="#" onclick="OK();" ><spring:message code='Cache.lbl_tf_collaboration_link'/></a>
				<a class="owBtn" href="#" onclick="Common.Close();"><spring:message code='Cache.lbl_close'/></a>
			</div>
		</div>
	</div>	
</body>

<script type="text/javascript">
	var tfLinkGrid = new coviGrid();
	
	$(function(){
		init();
	});
	
	function init(){
		setGrid();
	}
	
	function setGrid(){
		setTfGridHeader();
		setTfGridData();
	}
	
	function goSearch(){
		tfLinkGrid.page.pageNo = 1;
		setTfGridData();
	}
	
	function setTfGridHeader(){
		var tfLinkGridHeader = [
			{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
			{key:'CommunityName',  label:"<spring:message code='Cache.lbl_tf_collaboration_name'/>",width:'150',align:'center',display:true,formatter:function () {
				// T/F 팀룸 상세조회
				var CommunityName = this.item.CommunityName=="" ? "-" : this.item.CommunityName;
				var html = "<a onclick='goCommunitySite(\""+this.item.CU_ID+"\"); return false;'>";
					html += CommunityName;
					html += "</a>";
				
				return html; 
			}},
			{key:'TF_PM',  label:"<spring:message code='Cache.lbl_tf_collaboration_pm'/>",width:'100',align:'center',display:true, formatter:function(){
				return String.format("<div title='{0}'>{0}</div>", this.item.TF_PM.replace(/@/gi, ','));
			}},
			{key:'AppStatus', label:'AppStatus',display:false, hideFilter : 'Y'},
			{key:'CU_Code', label:'', align:'center', display:false, hideFilter : 'Y'},
			{key:'MemberCount',  label:"<spring:message code='Cache.lbl_tf_attendance'/>",width:'50',align:'center',display:true},
			{key:'AppStatusName',  label:"<spring:message code='Cache.lbl_ProgressState'/>",width:'50',align:'center',display:true},
			{key:'TF_Period',  label:"<spring:message code='Cache.lbl_Period'/>",width:'150',align:'center',display:true}
		];
		
		tfLinkGrid.setGridHeader(tfLinkGridHeader);
		
		var configObj = {
				targetID : "ListGrid",
				listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
				height:"auto",
				page : {
					pageNo: 1,
					pageSize:10
				},
				paging : true,
				colHead:{},
				body:{
				}
		};
		
		tfLinkGrid.setGridConfig(configObj);
	}
	
	function setTfGridData(){
		var sortColumn = "";
		var sortDicrection  = "";
		
		tfLinkGrid.bindGrid({
			ajaxUrl:"/groupware/layout/selectUserTFGridList.do",
			ajaxPars: {
				"searchWord" : $("#searchText").val(),
				"searchType" : $("#searchType").val(),
			//	"AppStatus" : (g_projectState==""?$("#selectState").val():g_projectState),
			//	"viewType" : "list",
				"sortColumn" : sortColumn,
				"sortDirection" : sortDicrection
			},
			onLoad:function(){
				
			}
		});
	}
	
	function OK(){
		var chkObj = tfLinkGrid.getCheckedList(0);
		opener.inputCollaborationLinkList(chkObj);
		Common.Close();
	}
</script>
</html>
