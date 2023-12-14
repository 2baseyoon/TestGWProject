<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<style>
	#GridView .txt-red{
		color:red;
		font-weight:bold;
	}
</style>

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_dl_ExtTableManage'/></h2> <!-- 연동시스템 테이블 설정 -->
	<div class="searchBox02">
		<span>
			<input id="searchText" type="text">
			<button type="button" id="icoSearch" class="btnSearchType01"><spring:message code="Cache.btn_search"/></button>
		</span>
		<a href="#" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<!-- 검색영역 -->
	<div id="DetailSearch" class="inPerView type02 sa02">
		<div>
			<div class="selectCalView" style="margin:0;">
				<select class="selectType02 w150p" id="srch_Type" name="srch_Type" >
					<option value="SystemCode"><spring:message code="Cache.lbl_dl_SystemName" /></option><!-- 연동 시스템 코드 -->
					<option value="DataTableName"><spring:message code="Cache.lbl_dl_DataTableName" /></option><!-- 데이터 테이블명 -->
					<option value="MultiTableName"><spring:message code="Cache.lbl_dl_MultiTableName" /></option><!-- 멀티로우 테이블명 -->
					<option value="FormPrefix"><spring:message code="Cache.lbl_dl_FormPrefix" /></option><!-- 양식키 -->
					<option value="Description"><spring:message code="Cache.lbl_dl_Description" /></option><!-- 설명 -->
				</select>
				<input type="text" id="srch_Text" />
			</div>
			<a href="#" id="btnSearch" name="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a> <!-- 검색 -->
		</div>
	</div>
	
	<div class="sadminContent">
		<!-- 상단버튼 영역 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="goDraftLegacySystemManagePop(); return false;"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				<button id="btnRefresh" class="btnRefresh" type="button"></button> <!-- 새로고침 -->
			</div>
		</div>
		<div id="GridView" class="tblList"></div>
	</div>
	
	<input type="hidden" id="hidden_domain_val" value=""/>
	
</div>
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	var objPopup;
	initComTable();
	
	function initComTable(){	
		setControl();		// 컨트롤 및 이벤트 셋팅
		setGrid();			// 그리드 세팅	
	}
	
	// Select box 및 이벤트 바인드
	function setControl(){
		
		// 이벤트
		$("#searchText, #srch_Text").on('keydown', function(){ // 엔터검색
			if(event.keyCode == "13"){
				cmdSearch(); //$('#icoSearch').trigger('click');
			}
		});
		$("#icoSearch, #btnSearch").on('click', function(){ // 버튼검색
			searchConfig();
		});
		$("#selectPageSize").on('change', function(){ // 페이징변경
			//setGridConfig();
			searchConfig();
		});
		$("#btnRefresh").on('click', function(){ // 새로고침
			Refresh();
		});
		$('.btnDetails').off('click').on('click', function(){ // 상세버튼 열고닫기
			var mParent = $('#DetailSearch');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
			//$(".contbox").css('top', $(".content").height());
			//coviInput.setDate();
		});
		
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[		
						{key:'SystemCode', label:'<spring:message code="Cache.lbl_dl_SystemName"/>', width:'200', align:'left', // 연동 시스템 코드
							formatter:function () {
	            				return '<div class="tblLink" title="'+this.item.SystemCode+ '">'+this.item.SystemCode+'</div>';	            		 	
	            		 	}}, 
						{key:'ConnectionPoolName', label:'<spring:message code="Cache.lbl_dl_PoolName"/>', width:'150', align:'left',	// 연동시스템 DB Pool
	            		 	formatter:function () {
	            				return '<div class="tblLink" title="'+this.item.ConnectionPoolName+ '">'+this.item.ConnectionPoolName+'</div>';	            		 	
	            		 	}}, 
						{key:'DataTableName', label:'<spring:message code="Cache.lbl_dl_DataTableName"/>', width:'200', align:'left',	// 데이터 테이블명
	            		 	formatter:function () {
	            				return '<div class="tblLink" title="'+this.item.DataTableName+ '">'+this.item.DataTableName+'</div>';	            		 	
	            		 	}}, 
						{key:'MultiTableName', label:'<spring:message code="Cache.lbl_dl_MultiTableName"/>', width:'200', align:'left',	// 멀티로우 테이블명
	            		 	formatter:function () {
	            				return '<div class="tblLink" title="'+this.item.MultiTableName+ '">'+this.item.MultiTableName+'</div>';	            		 	
	            		 	}}, 
						{key:'FormPrefix', label:'<spring:message code="Cache.lbl_dl_FormPrefix"/>', width:'200', align:'left',	// 양식키
	            		 	formatter:function () {
	            				return '<div class="tblLink" title="'+this.item.FormPrefix+ '">'+this.item.FormPrefix+'</div>';	            		 	
	            		 	}}, 
						{key:'Description', label:'<spring:message code="Cache.lbl_dl_Description"/>', width:'300', align:'left', sort:false,	// 설명
	            		 	formatter:function () {
	            				return '<div class="tblLink" title="'+this.item.Description+ '">'+this.item.Description+'</div>';	            		 	
	            		 	}}, 
	            		{key:'ModifierName', label:'<spring:message code="Cache.lbl_apv_modiuser"/>', width:'100', align:'center', sort:false, // 수정자
							formatter:function(){return CFN_GetDicInfo(this.item.ModifierName)}
						},
						{key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>', width:'150', align:'center', sort:"desc", // 수정일
							formatter:function(){return CFN_TransLocalTime(this.item.ModifyDate)}
						} 
			      	];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();	
		searchConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "GridView",
			height:"auto",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",			
			page : {
				pageNo: 1,
				pageSize: 10
			},	
			paging : true,
			//notFixedWidth:3,
			colHead:{},
			body:{
				 onclick: function(){				    
				    	var itemName = myGrid.config.colGroup[this.c].key;
				    	goDraftLegacySystemManagePop("Edit", this.item.LegacyID);
					 }			
			}
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// 리스트 조회
	function searchConfig(){
		//searchText
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		myGrid.page.pageNo = 1;
		myGrid.page.pageSize = $("#selectPageSize").val();
		myGrid.bindGrid({
 			ajaxUrl:"/approval/legacy/getDraftLegacySystemList.do",
 			ajaxPars: {
 				"SearchType":isDetail ? $("#srch_Type").val() : "",
 				"SearchText":isDetail ? $("#srch_Text").val() : "",
 				"icoSearch":$("#searchText").val()
 			},
 			onLoad:function(){
 			}
		});
	}
	
	//엔터검색
	function cmdSearch(){
		searchConfig();
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	// 추가/수정 팝업
	function goDraftLegacySystemManagePop(pType, legacyID){		
		// pType = Edit , undefined(Add)
		var sTitle = "<spring:message code='Cache.lbl_dl_ExtTableManage'/>"; // 연동시스템 테이블 설정
		var sUrl = "";
		if(pType == "Edit") sUrl = "/approval/legacy/goDraftLegacySystemManagePop.do?type=Edit&id=" + legacyID;
		else sUrl = "/approval/legacy/goDraftLegacySystemManagePop.do?type=Add&id=";
		
		var objPopup = Common.open("","setLegacySystem",sTitle,sUrl,"650px","710px","iframe",true,null,null,true);
	}
		
</script>