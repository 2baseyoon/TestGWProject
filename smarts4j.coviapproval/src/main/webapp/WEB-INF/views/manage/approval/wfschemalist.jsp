<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_ProcessManage"/></span> <!-- 양식프로세스 관리 -->
	</h2>	
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" >
			<button type="button" class="btnSearchType01" id="icoSearch" onclick="setSchemaGridData();" ><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02" id="DetailSearch">
		<div>
			<div class="selectCalView" style="margin:0;">
				<select class="selectType02 w150p" name="sel_Search" id="sel_Search" >
					<option selected="selected" value="SchemaName"><spring:message code='Cache.lbl_apv_SchemaName'/></option> <!-- 양식프로세스 명칭 -->
					<option value="SchemaDesc"><spring:message code='Cache.lbl_apv_SchemaDesc'/></option> <!-- 양식프로세스 설명 -->	
				</select>
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" />
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="setSchemaGridData();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
    <div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="addSchema(true);"><spring:message code="Cache.btn_Add"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" onclick="Refresh();"></button>
			</div>
		</div>
		<div id="processListGrid" class="tblList"></div>
	</div>
</div>
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	initWFSchemaList();

	function initWFSchemaList(){
		
		// 페이지 개수 변경
		$("#selectPageSize").on('change', function(){
			setGridConfig();
			setSchemaGridData();
		});
		
		// 상세버튼 열고닫기
		$('.btnDetails').off('click').on('click', function(){
			var mParent = $('#DetailSearch');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
			coviInput.setDate();
		});
		
		setGrid();			// 그리드 세팅
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[
		                  {key:'SCHEMA_NAME', label:'<spring:message code="Cache.lbl_apv_SchemaName"/>', width:'100', align:'center',
		                	  formatter:function () {
		      					return "<a class='txt_underline' onclick='updateSchema(true, \""+ this.item.SCHEMA_ID +"\"); return false;'>"+this.item.SCHEMA_NAME+"</a>";
		      				}, sort:"asc"},
		                  {key:'SCHEMA_DESC', label:'<spring:message code="Cache.lbl_apv_SchemaDesc"/>',   width:'200',
		                	  formatter:function () {
		                		  return "<span>"+this.item.SCHEMA_DESC+"</span>";
			      			}},
		                  {key:'DOMAIN_NAME', label:'<spring:message code="Cache.lbl_Domain"/>',   width:'100', align:'center', display:true}
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "processListGrid", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
		
		setSchemaGridData();
	}
	
	//엔터검색
	function cmdSearch(){
		setSchemaGridData();
	}
	
	// data bind
	function setSchemaGridData(){
			
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		
		var DomainId = (confMenu.domainId == "0" ? "" : confMenu.domainId);	// 그룹사공용이면 회사전체 검색
		var sel_Search = isDetail ? $("#sel_Search").val() : "";
		var search = isDetail ? $("#search").val() : "";
		var icoSearch = $("#searchText").val();
		
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
 			ajaxUrl:"/approval/manage/getschemalist.do",
 			ajaxPars:{
 				"DomainID" : DomainId,
				"sel_Search":sel_Search,
				"search":search,
				"icoSearch":icoSearch
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addSchema(pModal){
		parent.Common.open("","schemaDetailPopup","<spring:message code='Cache.lbl_ConfigCreation'/>","/approval/manage/addschemalayerpopup.do?mode=add","1000px","600px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateSchema(pModal, schema_Id){
		parent.Common.open("","schemaDetailPopup","<spring:message code='Cache.lbl_ConfigModify'/>","/approval/manage/addschemalayerpopup.do?mode=modify&id="+schema_Id,"1000px","600px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	function setFirstPageURL(){
		SaveFirstPageURL("/approval/approvaladmin_wfschemalist.do");
	}
</script>