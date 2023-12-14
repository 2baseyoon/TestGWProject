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
	<h2 class="title"><spring:message code='Cache.lbl_ComTableSetting'/></h2> <!-- 공통 테이블 설정 -->
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
				<select class="selectType02 w90p" name="sel_IsUse" id="sel_IsUse" >
					<option selected="selected" value=""><spring:message code='Cache.lbl_Whole'/></option> <!-- 전체 -->
					<option value="Y"><spring:message code='Cache.lbl_UseY'/></option> <!-- 사용 -->
					<option value="N"><spring:message code='Cache.lbl_UseN'/></option> <!-- 미사용 -->
				</select>
				<select class="selectType02 w120p" id="srch_Type" name="srch_Type" >
					<option value="ComTableName"><spring:message code="Cache.lbl_ComTableName" /></option><!-- 테이블명 -->
					<!-- <option value="JobFunctionCode"><spring:message code="Cache.lbl_ExecQuery" /></option>  --><!-- 실행쿼리 > base64로 저장하면서 검색 제거 -->
					<option value="Description"><spring:message code="Cache.lbl_Description" /></option><!-- 설명 -->
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
				<a class="btnTypeDefault btnPlusAdd" onclick="goComTableManagePop(); return false;"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->
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
				  		  {key:'ComTableID', label:'ID', width:'50', align:'center'}, // ID
						  {key:'CompanyName', label:'<spring:message code="Cache.lbl_Domain"/>', width:'100', align:'center', // 도메인
							  formatter:function(){
				                  return CFN_GetDicInfo(this.item.CompanyName);
				          }}, 
		                  {key:'ComTableName', label:'<spring:message code="Cache.lbl_ComTableName"/>', width:'150', align:'left', // 테이블명
				        	  formatter:function(){
				        		  return "<a class='txt_underline'>"+CFN_GetDicInfo(this.item.ComTableName) + "</a>";
				          }}, 
			              {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', width:'250', align:'left', sort:false}, // 설명 
			              {key:'IsUse', label:'<spring:message code="Cache.lbl_ComIsUse"/>', width:'50', align:'center' // 사용여부
		                	  , formatter:function(){
		                		  if(this.item.IsUse=='N') return '<spring:message code="Cache.lbl_UseN"/>'; // 미사용
		                		  else return '<spring:message code="Cache.lbl_UseY"/>'; // 사용
		                	  }
		                  },
			              {key:'SortKey', label:'<spring:message code="Cache.lbl_Sort"/>', width:'50', align:'center'  ,sort:"asc"}, // 정렬
		                  {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>', width:'100', align:'center' // 수정일
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.ModifyDate)}
		                  }, 
		                  {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'100', align:'center', // 등록자
		                	  formatter:function(){
				                  return CFN_GetDicInfo(this.item.RegisterName);
				          }}, 
			      		  {key:'QueryText',  label:'<spring:message code="Cache.lbl_ExecQuery"/>', width:'120', align:'center', sort:false, // 실행쿼리
			      			  formatter:function () {
			      				  var sClass = (this.item.QueryText) ? "btnTypeDefault" : "btnTypeDefault txt-red";
		                		  return "<a class='" + sClass + "'><spring:message code='Cache.lbl_SetExecQuery'/></a>"; // 쿼리설정
		                	  }
			      		  }, 
		                  {key:'ComFieldCnt', label:'<spring:message code="Cache.lbl_ComField"/>', width:'120', align:'center', sort:false , // 필드
		                	  formatter:function () {
		                		  var sClass = (this.item.ComFieldCnt != "0") ? "btnTypeDefault" : "btnTypeDefault txt-red";
		                		  return "<a class='" + sClass + "'><spring:message code='Cache.lbl_ComFieldMapping'/></a>"; // 필드매핑
		                	  }
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
				    	if(itemName == 'ComTableName'){
				    		goComTableManagePop("Edit", this.item.ComTableID, CFN_GetDicInfo(this.item.ComTableName), this.item.CompanyCode);
				    	}else if(itemName == 'QueryText'){
				    		goComTableQueryPop(this.item.ComTableID, CFN_GetDicInfo(this.item.ComTableName));
				    	}else if(itemName == 'ComFieldCnt'){
				    		var isQueryText = (this.item.QueryText) ? true : false;
				    		goComTableFieldPop(this.item.ComTableID, CFN_GetDicInfo(this.item.ComTableName), isQueryText);
				    	}
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
 			ajaxUrl:"/covicore/manage/getComTableManageList.do",
 			ajaxPars: {
 				"CompanyCode":$("#hidden_domain_val").val(), //confMenu.domainId,
 				"IsUse":isDetail ? $("#sel_IsUse").val() : "",
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
	
	// 공통 테이블 추가/수정 팝업
	function goComTableManagePop(pType, comTableID, comTableName, companyCode){		
		// pType = Edit , undefined(Add)
		var sTitle = "";
		var sUrl = "";
		var sHeight = "430px";
		if(pType == "Edit"){
			sTitle = "<spring:message code='Cache.lbl_ComTableSetting'/>|||" + comTableName; // 공통 테이블 설정
			sUrl = "/covicore/manage/goComTableManagePop.do?type=Edit&id=" + comTableID + "&companyCode="+companyCode;
			sHeight = "470px";
		}else{
			sTitle = "<spring:message code='Cache.lbl_ComTableSetting'/>"; // 공통 테이블 설정
			sUrl = "/covicore/manage/goComTableManagePop.do?type=Add&id=&companyCode="+$("#hidden_domain_val").val();
		}
		
		var objPopup = Common.open("","setComTableManage",sTitle,sUrl,"550px",sHeight,"iframe",true,null,null,true);
	}
		
	// 쿼리설정 팝업
	function goComTableQueryPop(comTableID, comTableName){		
		var objPopup = Common.open("","setComExecQuery","<spring:message code='Cache.lbl_SetExecQuery'/>|||" + comTableName // 쿼리설정
				,"/covicore/manage/goComTableQueryPop.do?id=" + comTableID
				,"1100px","800px","iframe",true,null,null,true);
	}
	
	// 필드매핑 팝업
	function goComTableFieldPop(comTableID, comTableName, isQueryText){		
		var objPopup;
		if(isQueryText){
			objPopup = Common.open("","setComFields","<spring:message code='Cache.lbl_ComFieldMapping'/>|||" + comTableName // 필드매핑
					,"/covicore/manage/goComTableFieldPop.do?id=" + comTableID
					,"1100px","800px","iframe",true,null,null,true);
		}else{
			Common.Warning(Common.getDic("msg_valid_query")); // 쿼리를 먼저 설정 해주세요.
		}
	}
		
		
</script>