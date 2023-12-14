<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_SignManage"/></span> <!-- 서명 관리 -->
	</h2>
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" >
			<button type="button" class="btnSearchType01" id="icoSearch" onclick="searchConfig();" ><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02" id="DetailSearch">
		<div>
			<div class="selectCalView" style="margin:0;">
				<!-- <select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select> -->
				<select class="selectType02 w120p" name="sel_Search" id="sel_Search" >
					<option value="UR_Name"><spring:message code="Cache.lbl_USER_NAME_01"/></option>
					<option value="DEPT_Name"><spring:message code="Cache.NumberFieldType_DeptName"/></option>					
					<option value="UR_Code"><spring:message code="Cache.lbl_User_Id"/></option>	
				</select>
				
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(1); return false;}" /> <!-- cmdSearch() -->
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig(1);"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize" onchange="setGridConfig();searchConfig();">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="baseconfiggrid"></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
		<input type="hidden" id="hidden_worktype_val" value=""/>
	</div>
</div>
		
<script type="text/javascript">
	var EntCode;

	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	initSignManager();

	function initSignManager(){
		setControl(); // 초기 셋팅
		setGrid();			// 그리드 세팅
	}
	
	// 초기 셋팅
	function setControl(){ 
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
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
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
		                  {key:'DEPT_Name', label:'<spring:message code="Cache.NumberFieldType_DeptName"/>', width:'200', align:'left', sort:"asc"},
		                  {key:'UR_Code',  label:'<spring:message code="Cache.lbl_User_Id"/>', width:'100', align:'center'},
		                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_User"/>', width:'100', align:'center'},
		                  {key:'JobTitleName',  label:'<spring:message code="Cache.lbl_JobTitle"/>', width:'100', align:'center'},
		                  {key:'JobLevelName',  label:'<spring:message code="Cache.lbl_UserProfile_04"/>', width:'100', align:'center'},
		                  {key:'USER_SIGN',  label:'<spring:message code="Cache.lbl_Sign_Reg"/>', width:'150', align:'center'}
		             ];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();			
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "baseconfiggrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			body:{
				 onclick: function(){
					    updateConfig(true, this.item.UR_Code)
					 }			
			}
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// 리스트 조회
	function searchConfig(flag){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		var EntCode = $("#hidden_domain_val").val(); 		
		var sel_Search = isDetail ? $("#sel_Search").val() : "";
		var search = isDetail ? $("#search").val() : "";	
		var icoSearch = $("#searchText").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/manage/getSignList.do",
				ajaxPars: {
					"EntCode":EntCode,				
					"sel_Search":sel_Search,
					"search":search,
					"icoSearch":icoSearch
				},
				onLoad:function(){
					$("#hidden_domain_val").val(EntCode);
					//아래 처리 공통화 할 것
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    	myGrid.fnMakeNavi("myGrid");
				}
		});
	}	

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){
		parent.Common.open("","updatebaseconfig"
					,"<spring:message code='Cache.lbl_apv_Regisign'/>|||<spring:message code='Cache.lbl_apv_sign_msg'/>"
					,"/approval/manage/goSignManagerSetPopup.do?mode=modify&key="+configkey+"&domain="+$("#hidden_domain_val").val()
					,"500px","300px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	
</script>