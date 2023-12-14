<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code="Cache.lbl_approval_manageBizDoc"/></h2>
	<div class="searchBox02">
		<span><input id="searchInputSimple" type="text" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}"><button type="button" id="simpleSearchBtn" class="btnSearchType01" onclick="searchConfig(this);"><spring:message code="Cache.btn_search"/></button></span><a href="#" class="btnDetails active" onclick="DetailDisplay(this);"><spring:message code="Cache.lbl_apv_detail"/></a>
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<!-- 검색영역 -->
	<div id="DetailSearch" class="inPerView type02 sa02 active">
		<div>
			<div class="selectCalView" style="margin:0;">
				<span><spring:message code="Cache.lbl_BizSection" /></span>
				<select id="BizDocType" name="BizDocType" class="selectType02 w120p">
				</select>
				<select class="selectType02 w120p" name="sel_Search" id="sel_Search" >
					<option selected="selected" value="BizDocName"><spring:message code="Cache.lbl_apv_BizDocName"/></option> <!-- 업무함 명칭 -->
					<option value="BizDocCode"><spring:message code="Cache.lbl_apv_BizDocCode"/></option>	<!-- 업무함 코드 -->	
				</select>
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" />
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
		<div id="bizDocGrid" class="tblList"></div>
	</div>	
</div>
<script type="text/javascript">
	var bizDocGrid = new coviGrid();
	bizDocGrid.config.fitToWidthRightMargin = 0;
	var lang = Common.getSession("lang");
	
	//ready 
	initBizDocList();
	
	function initBizDocList(){
		coviCtrl.renderAjaxSelect([{target: "BizDocType",codeGroup: "JobFunctionType"}], '', lang);
		$("#BizDocType").change(function(){
			searchConfig();
		});
		
		selSelectbind();
		setGrid();
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
						  {key:'EntName', label:'<spring:message code="Cache.lbl_Domain"/>', width:'100', align:'center'},
		                  {key:'BizDocName',  label:'<spring:message code="Cache.lbl_apv_BizDocName"/>', width:'115', align:'left'
		                	  , formatter:function(){
				                  return CFN_GetDicInfo(this.item.BizDocName);
			                	}
			              },	                  
		                  {key:'BizDocCode',  label:'<spring:message code="Cache.lbl_apv_BizDocCode"/>', width:'100', align:'center'},
		                  {key:'Description', label:'<spring:message code="Cache.lbl_apv_desc"/>', width:'100', align:'left'},
		                  {key:'BizDocTypeName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'80', align:'center'},
						  {key:'IsUse', label:'<spring:message code="Cache.lbl_apv_IsUse"/>', width:'55', align:'center'
		                	  , formatter:function(){
		                		  var IsUse;
		                		  if(this.item.IsUse=='Y'){
		                			  IsUse='<spring:message code="Cache.lbl_Use"/>';  //사용
		                		  }else if(this.item.IsUse=='N'){
		                			  IsUse='<spring:message code="Cache.lbl_UseN"/>'; //미사용
		                		  }
		                		return IsUse;  
		                	  }
		                  },
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'50', align:'center', sort:"asc"},
		                  {key:'InsertDate',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE15"/>', width:'100', align:'center', 
		                	  	formatter:function(){
		                	  		return CFN_TransLocalTime(this.item.InsertDate, "yyyy-MM-dd HH:mm:ss")
		                		}
		                  },
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_apv_formchoice"/>', width:'60', align:'center', sort: false,
		                	  	formatter : function(){
		                		  	return "<a href='#' class='btnTypeDefault'><spring:message code='Cache.lbl_apv_formchoice'/></a>";
		                	  	}
		                  },
		                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_apv_ChargerManage"/>', width:'75', align:'center', sort: false,
		                	  	formatter : function(){
		                			return "<a href='#' class='btnTypeDefault'><spring:message code='Cache.lbl_apv_ChargerManage'/></a>";
		                	 	}
		                  },
		                  {key:'BizDocManage', label:'<spring:message code="Cache.lbl_apv_BizDocManage"/>', width:'75', align:'center', sort: false,
		                	  	formatter:function () {
		                			return "<a class='btnTypeDefault'><spring:message code='Cache.lbl_apv_BizDocManage'/></a>";
			      		  		}
		                  }
			      	];
		
		bizDocGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "bizDocGrid",
			height:"auto",
			body:{
				onclick: function(){
					var itemName = bizDocGrid.config.colGroup[this.c].key;
					if(itemName=='FormName'){							
						goBizDocForm(this.item.BizDocID,CFN_GetDicInfo(this.item.BizDocName),this.item.EntCode);
					}else if(itemName=='UR_Name'){							
						goBizDocMember(this.item.BizDocID,CFN_GetDicInfo(this.item.BizDocName),this.item.EntCode);
					}else if(itemName=='BizDocManage'){
						updateConfig( this.item.BizDocID );
					}
			    }				
		}
		};
		bizDocGrid.setGridConfig(configObj);
	}
	

	
	// 검색
	function searchConfig(pObj){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		
		var sel_State = isDetail ? $("#sel_State").val() : "";	
		var sel_Search = isDetail ? $("#sel_Search").val() : "";
		var search = isDetail ? $("#search").val() : "";
		var sel_Date = isDetail ? $("#sel_Date").val() : "";
		var bizDocType = isDetail ? $("#BizDocType").val() : "";
		var icoSearch = $("#searchInputSimple").val();
		var entCode = confMenu.domainId;
		//var startdate = $("#startdate").val();
		//var enddate = $("#enddate").val();
		bizDocGrid.page.pageNo = 1;
		bizDocGrid.page.pageSize = $("#selectPageSize").val();
		bizDocGrid.bindGrid({
				ajaxUrl:"/approval/manage/getBizDocList.do",
				ajaxPars: {
					"sel_State":sel_State,
					"sel_Search":sel_Search,
					"search":search,
					"sel_Date":sel_Date,
					"startDate":"",
					"endDate":"",
					"bizDocType":bizDocType,
					"entCode":entCode,
					"icoSearch":icoSearch
				}
		});
	}	

	//담당 양식목록 팝업 
	function goBizDocForm(bizDocID, bizDocName, entCode){		
		Common.open("","updateBizForm","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_formchoice'/>","/approval/manage/goBizDocForm.do?mode=modify&key="+bizDocID+"&entCode="+entCode,"750px","700px","iframe",true,null,null,true);
	}
	
	//담당자 목록 팝업 
	function goBizDocMember(bizDocID, bizDocName, entCode){		
		Common.open("","updateDocMember","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_ChargerManage'/>","/approval/manage/goBizDocMember.do?mode=modify&key="+bizDocID+"&entCode="+entCode,"700px","700px","iframe",true,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(bizDocID){
		Common.open("","updateBizDocConfig","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_bdform_title_instruction'/>","/approval/manage/goBizDocListSetPopup.do?mode=modify&key="+bizDocID,"700px","450px","iframe",true,null,null,true);
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(){		 
		parent.Common.open("","addBizDoc","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_bdform_title_instruction'/>","/approval/manage/goBizDocListSetPopup.do?mode=add","700px","450px","iframe",true,null,null,true);
	}

	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	//axisj selectbox변환
	function selSelectbind(){
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