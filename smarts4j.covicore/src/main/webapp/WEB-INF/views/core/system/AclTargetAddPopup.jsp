<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="EUC-KR"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
	.AXPaging {
		width: 20px !important;
	}
	
	.selectSearchBox {
		padding: 12px 0 12px;
		text-align: center;
		font-size: 14px;
	}
	
	.selectSearchBox .btnSearchType01 {
		background: url(/HtmlSite/smarts4j_n/covicore/resources/images/theme/green/bg_survey_pop.png) no-repeat 0 -40px;
		position: absolute;
		top: 1px;
		right: 1px;
		width: 30px;
		height: 31px;
		background-position: 6px -34px;
		cursor: pointer;
	}
	
	.selectSearchBox > span {
		position: relative;
		display: inline-block;
    }
	
	#searchWord {
		padding: 0 6px 0;
		height: 30px;
		border: 1px solid #ddd;
		border-radius: 3px !important;
		box-shadow: none !important;
	}
	
	.btnRefresh {
		border: 1px solid #d7d7d7;
		display: inline-block;
		width: 30px;
		height: 30px;
		border-radius: 2px;
		cursor: pointer;
		transition: box-shadow .3s;
		vertical-align: top;
	}
	
	.btnRefresh, .btnRefresh:hover {
		background: url(/HtmlSite/smarts4j_n/covicore/resources/images/theme/green/bg_survey_pop.png) no-repeat -39px -35px;
	}
</style>

<body>
	<div>
		<div class="selectSearchBox">
			<span class="searchArea">
				<input type="text" id="searchWord"/>
				<a id="searchBtn" class="btnSearchType01"></a>
			</span>
			<button id="refreshBtn" class="btnRefresh" type="button"></button>		
		</div>
		<div style="padding: 15px;">
			<div id="grid"></div>
		</div>
		<div align="center">
			<input type="button" id="addBtn" class="AXButton red" value="<spring:message code="Cache.btn_Add"/>"/> <!-- 추가 -->
			<input type="button" id="closeBtn" class="AXButton" value="<spring:message code="Cache.btn_Close"/>"/> <!-- 닫기 -->
		</div>
	</div>
</body>

<script>
	(function(param){
		
		var grid = new coviGrid();
		
		var setEvent = function(){
			// 추가
			$("#addBtn").off("click").on("click", function(){
				addAclTarget();
			});
			
			// 닫기
			$("#closeBtn").off("click").on("click", function(){
				Common.Close();
			});
			
			// 검색
			$("#searchWord").off("keypress").on("keypress", function(e){
				if (e.keyCode === 13) renderGrid();
			});
			
			$("#searchBtn").off("click").on("click", function(){
				renderGrid();
			});
			
			// 새로고침
			$("#refreshBtn").off("click").on("click", function(){
				renderGrid();
			});
		}
		
		var setGridConfig = function(){
			grid.setGridHeader([
				{key:'chk',			label:'chk', 	width:'3',	align:'center',	hideFilter : 'Y', formatter: 'checkbox'},
				{key:'DisplayName',	label:'Name',	width:'20', align:'left', 	hideFilter : 'Y'},
				{key:'SubjectCode',	label:'Code',	width:'20', align:'left', 	hideFilter : 'Y'}
			]);
			
			grid.setGridConfig({
				targetID: "grid",
				width: "400px",
				height: "auto",
				paging: true,
				page: {
					  pageNo: 1
					, pageSize: 10
				},
				sort: true,
				overflowCell: [],
				body: {}
			});
			
			grid.page.listOffset = 3;
		}
		
		var renderGrid = function(){
			grid.bindGrid({
				ajaxUrl: "/covicore/aclManage/getAddTargetList.do",
				ajaxPars: {
					  aclType: param.aclType
					, domain: param.domain
					, searchText: $("#searchWord").val()
				}
			});
		}
		
		var addAclTarget = function(){
		//	parent.$("#gridAclDiv #AXPaging_end").trigger("click");
			parent.aclManage.addACLRows(grid.getCheckedList(0));
			Common.Close();
		}
		
		var init = function(){
			setEvent();
			setGridConfig();
			renderGrid();
		}
		
		init();
	})({
		  aclType: "${aclType}" // Cm, Dept, JobPosition, JobLevel, JobTitle, Manage, User
		, domain: "${domain}"
	})
</script>