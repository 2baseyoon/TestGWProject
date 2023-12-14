<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_EasyformClassManage"/></span> <!-- 결재양식 분류 설정 -->
	</h2>	
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" >
			<button type="button" class="btnSearchType01" id="icoSearch" onclick="searchConfig();" ><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02" id="DetailSearch">
		<div>
			<div class="selectCalView" style="margin:0;">
				<select class="selectType02 w150p" name="sel_Search" id="sel_Search" >
					<option selected="selected" value="FormClassName"><spring:message code='Cache.lbl_apv_Name'/></option> <!-- 명칭 -->	
				</select>
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" />
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
    <div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="addConfig(true);"><spring:message code="Cache.btn_Add"/></a>
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
		<div id="GridView1" class="tblList"></div>
	</div>
</div>
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	var objPopup;
	
	initFormClassList();

	function initFormClassList(){
		
		// 페이지 개수 변경
		$("#selectPageSize").on('change', function(){
			setGridConfig();
			searchConfig();
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
		searchConfig();
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정1
		var headerData =[					
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'50', align:'center', sort:"asc"},	                 
		                  {key:'FormClassName', label:'<spring:message code="Cache.lbl_apv_Name"/>', width:'250', align:'left',
		                	formatter:function(){
		                		var setClick = false;
		                		if(this.item.ModifyAcl == "Y"){ setClick = true; }
		                		return "<a class='txt_underline' onclick='updateConfig(true, \""+ this.item.FormClassID +"\", "+setClick+"); return false;'>"+CFN_GetDicInfo(this.item.FormClassName)+"</a>";
		                	}  
		                  },
		                  {key:'EntName',  label:'<spring:message code="Cache.lbl_apv_chage_ent"/>', width:'150', align:'left'},
		                  {key:'DisplayName',  label:'<spring:message code="Cache.lbl_aclTarget"/>', width:'250', align:'left'}
			      		];	
		
		myGrid.setGridHeader(headerData);		
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "GridView1",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",			
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			colHead:{},
			body:{
				 onclick: function(){
					     //toast.push(Object.toJSON({index:this.index, r:this.r, c:this.c, item:this.item}))	
					 }			
			},
			notFixedWidth : 1
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	//엔터검색
	function cmdSearch(){
		searchConfig();
	}
	
	// baseconfig 검색
	function searchConfig(){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		
		var DomainCode = confMenu.domainCode == "ORGROOT" ? "" : confMenu.domainCode;	// 그룹사공용이면 회사전체 검색
		var sel_Search = isDetail ? $("#sel_Search").val() : "";
		var search = isDetail ? $("#search").val() : "";
		var icoSearch = $("#searchText").val();
		
		myGrid.bindGrid({
			ajaxUrl:"/approval/manage/getFormClassList.do",
 			ajaxPars:{
 				"DomainID" : DomainCode,
 				"sel_Search":sel_Search,
				"search":search,
				"icoSearch":icoSearch
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
	
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey, setClick){
		if(setClick){
			objPopup = parent.Common.open("","addFormClass","<spring:message code='Cache.lbl_CateMng'/>|||<spring:message code='Cache.lbl_apv_ClassManage_instruction'/>","/approval/manage/goFormClassPopup.do?mode=modify&configkey="+configkey,"700px","440px","iframe",pModal,null,null,true);
		}else{
			Common.Warning("<spring:message code='Cache.lbl_noAuth'/>");//권한이 없습니다.
		}
		//objPopup.close(); 
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){		
		objPopup = parent.Common.open("","addFormClass","<spring:message code='Cache.lbl_CateMng'/>|||<spring:message code='Cache.lbl_apv_ClassManage_instruction'/>","/approval/manage/goFormClassPopup.do?mode=add","700px","440px","iframe",pModal,null,null,true);
		//objPopup.close(); 
	}
	
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
</script>