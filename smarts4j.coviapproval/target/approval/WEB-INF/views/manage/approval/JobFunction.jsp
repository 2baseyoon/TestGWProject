<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_apv_chargedocSet'/></h2>
	<div class="searchBox02">
		<span><input id="searchInputSimple" type="text" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}"><button type="button" id="simpleSearchBtn" class="btnSearchType01" onclick="searchConfig(this);"><spring:message code="Cache.btn_search"/></button></span><a href="#" class="btnDetails active" onclick="DetailDisplay(this);"><spring:message code="Cache.lbl_apv_detail"/></a>
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<!-- 검색영역 -->
	<div id="DetailSearch" class="inPerView type02 sa02 active">
		<div>
			<div class="selectCalView" style="margin:0;">
				<select id="JobFunctionType" name="JobFunctionType" class="selectType02 w120p">
				</select>
				<select class="selectType02 w120p" id="JobFunctionSearchType" name="JobFunctionSearchType" >
					<option value="JobFunctionName"><spring:message code="Cache.lbl_apv_BizDocName" /></option><!-- 업무함 명칭 -->
					<option value="JobFunctionCode"><spring:message code="Cache.lbl_apv_BizDocCode" /></option><!-- 업무함 코드 -->
					<option value="ChargerName"><spring:message code="Cache.lbl_apv_AdminName" /></option>
					<option value="ChargerCode"><spring:message code="Cache.lbl_apv_AdminID" /></option>	
				</select>
				<input type="text" id="JobFunctionSearch" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" />
			</div>
			<a href="#" id="search" name="search" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	
	<div class="sadminContent">
		<!-- 상단버튼 영역 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="addConfig(); return false;"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount" onchange="searchConfig();">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				<button class="btnRefresh" type="button" onclick="Refresh();"></button>
			</div>
		</div>
		<div id="GridView" class="tblList"></div>
	</div>
	<input type="hidden" id="hidden_JobFunctionID" value=""/>
	<input type="hidden" id="hidden_JobFunctionName" value=""/>
</div>
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	var objPopup;
	initJobFunction();
	
	function initJobFunction(){	
		// $("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListData.do", {"type" : "ID"});
		/*coviCtrl.renderAXSelect('JobFunctionType', 'JobFunctionType', 'ko', '', '', 'ORGROOT');
		$("#JobFunctionType").bindSelect({
			onchange: function(){
				searchConfig();
			}
		});*/
		//$("#JobFunctionSearchType").bindSelect();
		
		$("#JobFunctionType").find("option").remove();
		var tmpType = Common.getBaseCode("JobFunctionType").CacheData;
		if(tmpType && tmpType.length > 0){
			for(var i=0;i<tmpType.length;i++){
				$("#JobFunctionType").append("<option value='" + tmpType[i].Code + "'>" + CFN_GetDicInfo(tmpType[i].MultiCodeName) + "</option>");
			}
		}
		$("#JobFunctionType").change(function(){
			searchConfig();
		});
		
		// 그리드 세팅
		setGrid();	
		searchConfig();
		
		$("#search,#JobFunctionSearch").keypress(function(e){
			if (e.keyCode==13){
				e.target.id === "JobFunctionSearch" && (cmdSearchforJob());
				e.target.id === "search" && (cmdSearchforMember());
			} 
		});
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정1
		var headerData =[					
						  {key:'EntName', label:'<spring:message code="Cache.lbl_Domain"/>', width:'100', align:'center'},
		                  {key:'JobFunctionName', label:'<spring:message code="Cache.lbl_apv_BizDocName"/>', width:'150', align:'left'
		                	  , formatter:function(){
				                  return CFN_GetDicInfo(this.item.JobFunctionName);
				              }
			              },
		                  {key:'JobFunctionCode',  label:'<spring:message code="Cache.lbl_apv_BizDocCode"/>', width:'150', align:'center'},
		                  {key:'Description', label:'<spring:message code="Cache.lbl_apv_desc"/>', width:'250', align:'left'},
		                  {key:'JobFunctionTypeName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'100', align:'center'},
		                  {key:'IsUse', label:'<spring:message code="Cache.lbl_apv_IsUse"/>', width:'60', align:'center'
		                	  , formatter:function(){
		                		  var IsUse;
		                		  if(this.item.IsUse=='Y'){
		                			  IsUse='<spring:message code="Cache.lbl_apv_formcreate_LCODE13"/>';
		                		  }else if(this.item.IsUse=='N'){
		                			  IsUse='<spring:message code="Cache.lbl_apv_formcreate_LCODE14"/>';
		                		  }
		                		return IsUse;  
		                	  }
		                  },	                 
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'50', align:'center'  ,sort:"asc"},
		                  {key:'InsertDate', label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE15"/>', width:'100', align:'left'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.InsertDate, "yyyy-MM-dd HH:mm:ss")}},
		                  {key:'MemberManage', label:'<spring:message code="Cache.lbl_apv_ChargerManage"/>', width:'85', align:'center', sort:false , 
		                	  formatter:function () {
		                		  return "<a class='btnTypeDefault'><spring:message code='Cache.lbl_apv_ChargerManage'/></a>";
			      		  }},
		                  {key:'JFManage', label:'<spring:message code="Cache.lbl_apv_chargedocSet"/>', width:'115', align:'center', sort:false , 
		                	  formatter:function () {
		                		  return "<a class='btnTypeDefault'><spring:message code='Cache.lbl_apv_chargedocSet'/></a>";
			      		  }}
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();	
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
			colHead:{},
			body:{
				 onclick: function(){				    
				    	var itemName = myGrid.config.colGroup[this.c].key;
				    	if(itemName == 'MemberManage'){
				    		goJobFunctionMember(this.item.JobFunctionID, CFN_GetDicInfo(this.item.BizDocName), this.item.EntCode);
				    	}else if(itemName == 'JFManage'){
				    		updateConfig(this.item.JobFunctionID);
				    	}
					 }			
			}
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// baseconfig 검색
	function searchConfig(){
		//searchInputSimple
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		myGrid.page.pageNo = 1;
		myGrid.page.pageSize = $("#selectPageSize").val();
		myGrid.bindGrid({
 			ajaxUrl:"/approval/manage/getJobFunctionList.do",
 			ajaxPars: {
 				"EntCode":confMenu.domainId,
 				"JobFunctionType":isDetail ? $("#JobFunctionType").val() : "",
 				"SearchType":isDetail ? $("#JobFunctionSearchType").val() : "",
 				"SearchText":isDetail ? $("#JobFunctionSearch").val() : "",
 				"icoSearch":$("#searchInputSimple").val()
 			},
 			onLoad:function(){
 			}
		});
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(configkey){			
		objPopup = parent.Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_apv_chargedocSet'/>|||<spring:message code='Cache.lbl_apv_jfform_title_instruction'/>","/approval/manage/goJobFunctionSetPopup.do?mode=modify&configkey="+configkey,"700px","470px","iframe",true,null,null,true);
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(){		 
		objPopup = parent.Common.open("","addbaseconfig","<spring:message code='Cache.lbl_apv_chargedocSet'/>|||<spring:message code='Cache.lbl_apv_jfform_title_instruction'/>","/approval/manage/goJobFunctionSetPopup.do?mode=add","700px","470px","iframe",true,null,null,true);
	}
	
	// 담당자 목록 팝업 
	function goJobFunctionMember(jobFunctionID, jobFunctionName, entCode){		
		Common.open("","updateJFMember","<spring:message code='Cache.lbl_apv_chargedocSet'/>|||<spring:message code='Cache.lbl_apv_ChargerManage'/>","/approval/manage/goJobFunctionMember.do?mode=modify&key="+jobFunctionID+"&entCode="+entCode,"700px","700px","iframe",true,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	//검색 - 업무함 검색
	function cmdSearchforJob(){
		$("#divMember").hide();
		searchConfig();
	}
	
	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
		$(".contbox").css('top', $(".content").height());
		//coviInput.setDate();
	}
</script>