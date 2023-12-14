<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code="Cache.CN_117"/></h2><!-- 직인관리 -->
	<div class="searchBox02">
		<span><input id="searchInputSimple" type="text" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}"><button type="button" id="simpleSearchBtn" class="btnSearchType01" onclick="searchConfig(this);"><spring:message code="Cache.btn_search"/></button></span><a href="#" class="btnDetails" onclick="DetailDisplay(this);"><spring:message code="Cache.lbl_apv_detail"/></a>
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<!-- 검색영역 -->
	<div id="DetailSearch" class="inPerView type02 sa02">
		<div>
			<div class="selectCalView" style="margin:0;">
				<spring:message code="Cache.lbl_apv_OfficailSeal_Name"/> : 
				<input type="text" id="search" name="search" onkeypress="if (event.keyCode==13){ searchConfig(1); return false;}" />
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<div class="sadminContent">
		<!-- 상단버튼 영역 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="addConfig(true); return false;"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->
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
		<div id="DataGrid1" class="tblList"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</div>
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;

	initStampManager();

	function initStampManager(){
		setSelect();
		setGrid();			// 그리드 세팅			
	}
	
	//그리드 세팅
	function setGrid(){
		var SERVICE_TYPE = "ApprovalStamp";
		// 헤더 설정
		var headerData =[	            
		                  {key:'UseYn', label:'<spring:message code="Cache.lbl_Use"/>', width:'65', align:'center',sort: false,
			      			formatter:function () {
		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' style='width:50px;height:21px;border:0px none;' value='"+this.item.UseYn+"' onchange='ChangeIsUse(\""+ this.item.StampID +"\",\""+ this.item.EntCode +"\",this);'/>";
		      				}
		                  },	           
		                  {key:'EntName',  label:'<spring:message code="Cache.lbl_CorpName"/>', width:'150', align:'center',sort: false},
		                  {key:'StampName', label:'<spring:message code="Cache.lbl_apv_OfficailSeal_Name"/>', width:'500', align:'left',sort: false,
		                	  formatter:function () {
			      					return "<a class='txt_underline' onclick='updateConfig(true, \""+ this.item.StampID +"\"); return false;'>"+this.item.StampName+"</a>";
		                	  }},
		                  {key:'FileInfo',  label:'<spring:message code="Cache.lbl_image"/>', width:'100', align:'center',sort: false,           //미리보기
			                	  formatter:function () {
			                		  var strBackStoragePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")); // 이전 직인표시를 위해서만 사용, 신규문서와는 무관
			                		  var fileInfo;
			                		  if(this.item.FileID && !isNaN(this.item.FileID)){
			                			  fileInfo = coviCmn.loadImageId(this.item.FileID, SERVICE_TYPE);
			                		  } else {
			                			  fileInfo = this.item.FileInfo;
			                			  if(fileInfo.indexOf(strBackStoragePath) > -1){ 
			                				  fileInfo = coviCmn.loadImage(fileInfo);
				                		  }else{
				                			  fileInfo = coviCmn.loadImage(strBackStoragePath + fileInfo);
				                		  }  
			                		  }
			                		  return "<a class='photo_img'><img src='"+fileInfo+"' onerror='coviCmn.imgError(this)' width='50px' height='50px'/></a>";
				      			  }
			                  },
		                  {key:'OrderNo',  label:'<spring:message code="Cache.lbl_SortOrder"/>', width:'100', align:'center',sort: false},
		                  {key:'RegDate',  label:'<spring:message code="Cache.lbl_RegistrationDate"/>', width:'100', align:'center', sort: false
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.RegDate, "yyyy-MM-dd HH:mm:ss")} }              
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();			
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "DataGrid1",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	

	
	// baseconfig 검색
	function searchConfig(flag){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		var EntCode = confMenu.domainCode; 		
		var sel_Search = "";
		var search = isDetail ? $("#search").val() : $("#searchInputSimple").val();	
		myGrid.page.pageNo = 1;
		myGrid.page.pageSize = $("#selectPageSize").val();
		myGrid.bindGrid({
				ajaxUrl:"/approval/manage/getStampList.do",
				ajaxPars: {
					"EntCode":EntCode,				
					"sel_Search":sel_Search,
					"search":search				
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
	function updateConfig(pModal, configkey){
		Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_apv_OfficialSeal'/>","/approval/manage/goStampManagerSetPopup.do?mode=modify&key="+configkey,"580px","400px","iframe",pModal,null,null,true);
	}

	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){		
		objPopup = parent.Common.open("","addbaseconfig","<spring:message code='Cache.lbl_apv_OfficialSeal'/>","/approval/manage/goStampManagerSetPopup.do?mode=add","580px","400px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	// Select box 바인드
	function setSelect(){	
	}
	
	//직인 사용 여부 변경
	function ChangeIsUse(pStampID,pEntCode,pObj){
		var Params = {
				StampID : pStampID,
				EntCode : pEntCode,
				UseYn : $(pObj).val()
		};
		$.ajax({
			url:"/approval/manage/setUseStampUse.do",
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				searchConfig();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/setUseStampUse.do", response, status, error);
			}
		});
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