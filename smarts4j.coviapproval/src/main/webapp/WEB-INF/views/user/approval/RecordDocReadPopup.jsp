<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width: 100%" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<div id="searchPage">
				<div style="margin: 18px 0;">
					<select id="searchType" style="width: 100px;">
						<option value="UserName"><spring:message code='Cache.lbl_name'/></option> <!-- 이름 -->
						<option value="DeptName"><spring:message code='Cache.ACC_lbl_deptName'/></option> <!-- 부서명 -->
					</select>
					<input type="text" id="searchWord" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
					<a id="simpleSearchBtn" class="btnTypeDefault btnSearchBlue nonHover" onclick="onClickSearchButton();"><spring:message code='Cache.lbl_apv_search'/></a> <!-- 검색 -->
				</div>
				<div>
					<div id="readerGrid"></div>
				</div>
			</div>
			<div class="bottom">
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_att_close'/></a> <!-- 닫기 -->
			</div>
		</div>
	</div>	
</div>

<script>
	const doc_id = "${doc_id}";
	let ListGrid = new coviGrid();
	
	window.onload = setGrid();
	function setGrid(){
		setGridConfig();
		setReaderListData();
	}
	
	function setGridConfig(){
		const headerData = [
							{key:'UserName', label:'<spring:message code="Cache.lbl_name"/>', width:'100', align:'center',
								formatter:function(){
						    	  	return CFN_GetDicInfo(this.item.UserName);
						    	} 
							}, // 이름
							{key:'UserCode', label:'<spring:message code="Cache.lbl_User_Id"/>', width:'80', align:'center'}, // 사용자ID
							{key:'DeptName', label:'<spring:message code="Cache.lbl_dept"/>', width:'100', align:'center',
								formatter:function(){
						    	  	return CFN_GetDicInfo(this.item.DeptName);
						    	}
							}, // 부서
							{key:'PositionName', label:'<spring:message code="Cache.lbl_JobPosition"/>', width:'100', align:'center',
								formatter:function(){
						    	  	return CFN_GetDicInfo(this.item.PositionName.split('&')[1]);
						    	}
							}, // 직위
							{key:'TitleName', label:'<spring:message code="Cache.lbl_JobTitle"/>', width:'100', align:'center',
								formatter:function(){
						    	  	return CFN_GetDicInfo(this.item.TitleName.split('&')[1]);
						    	}
							}, // 직책
							{key:'LevelName', label:'<spring:message code="Cache.lbl_JobLevel"/>', width:'100', align:'center',
								formatter:function(){
						    	  	return CFN_GetDicInfo(this.item.LevelName.split('&')[1]);
						    	}
							}, // 직급
							{key:'ReadDate', label:'<spring:message code="Cache.lbl_apv_ReadDate"/>', width:'120', align:'center'} // 읽은일시
						];
		
		seriesHeaderData = headerData;
		ListGrid.setGridHeader(headerData);
	
		const configObj = {
			targetID: "readerGrid",
			height: "auto",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", // 개
			body: {},
			page: {
				pageNo: 1,
				pageSize: 10
			},
			paging: true,
		};
		
		ListGrid.setGridConfig(configObj);
	}
	
	function setReaderListData(){
		const searchType = $("#searchType").val();
		const searchWord = $("#searchWord").val();
		
		ListGrid.bindGrid({
			ajaxUrl: "/approval/user/getRecordDocReaderListData.do",
			ajaxPars: {
				"doc_id": doc_id,
				"searchType": searchType,
				"searchWord": searchWord
			},
			onLoad: function(){
				$(".gridBodyTable > tbody > tr > td").css("background", "white");
				$(".AXGrid").css("overflow", "visible");
				coviInput.init();
			}
		});
	}
	
	function onClickSearchButton(){
		ListGrid.page.pageNo = 1;
		setReaderListData();
	}
</script>