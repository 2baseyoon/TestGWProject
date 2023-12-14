<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_targetUser"/></span> 
	</h2>
</div>
<div class="cRContBottom mScrollVH">
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" href="#" onclick="addAuthority(true);"><spring:message code="Cache.btn_Add"/></a>
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
		<input type="hidden" id="hidden_useAuthority_val" value=""/>
	</div>
</div>

<script type="text/javascript">

	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	var objPopup;
	
	initPersonDirector();

	function initPersonDirector(){
		setControl();	// 초기 셋팅
		setGrid();			// 그리드 세팅	
	}
	
	// 초기 셋팅
	function setControl(){
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_useAuthority_val").val(Common.getSession("DN_Code"));
		else $("#hidden_useAuthority_val").val(confMenu.domainCode);
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[					
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'40', align:'center' ,sort:"asc"},	                 
		                  {key:'UserName', label:'<spring:message code="Cache.lbl_Specific_User"/>', width:'100', align:'center'},
		                  {key:'TargetName',  label:'<spring:message code="Cache.lbl_apv_Assignmented_Person"/>', width:'400', align:'left'},
		                  {key:'Description', label:'<spring:message code="Cache.lbl_apv_desc"/>', width:'200', align:'left'}	                  
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
					     //toast.push(Object.toJSON({index:this.index, r:this.r, c:this.c, item:this.item}));	
					     updateAuthority(true,this.item.UserCode);					    
					 }			
			}
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// 리스트조회
	function searchConfig(){
		var useAuthority = document.getElementById("hidden_useAuthority_val").value;
	
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
 			ajaxUrl:"/approval/manage/getPersonDirectorList.do",
 			ajaxPars: {
 				"EntCode":useAuthority
 			},
 			onLoad:function(){
 				//아래 처리 공통화 할 것
 				coviInput.setSwitch();
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			}
		});		
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addAuthority(pModal){
		var paramEntCode = $("#hidden_useAuthority_val").val();
		objPopup = parent.Common.open("","addAuthority","<spring:message code='Cache.lbl_addAuthority'/>|||<spring:message code='Cache.lbl_apv_Specific_User_Person_Manage'/>","/approval/manage/goPersonDirectorSetPopup.do?mode=add&paramEntCode="+paramEntCode,"700px","650px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateAuthority(pModal, configkey){	
		var paramEntCode = $("#hidden_useAuthority_val").val();
		objPopup = parent.Common.open("","updateAuthority","<spring:message code='Cache.lbl_updateAuthority'/>|||<spring:message code='Cache.lbl_apv_Specific_User_Person_Manage'/>","/approval/manage/goPersonDirectorSetPopup.do?mode=modify&paramEntCode="+paramEntCode+"&key="+configkey,"700px","650px","iframe",pModal,null,null,true);
	}
	
</script>