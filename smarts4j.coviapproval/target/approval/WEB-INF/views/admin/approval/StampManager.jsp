<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">직인관리</span>	
</h3>
<form id="form1">
    <div style="width:100%; min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(true);"/>
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>										
			&nbsp;&nbsp;					
			직인명으로 검색
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>								
		</div>	
		<div id="DataGrid1"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">

	var myGrid = new coviGrid();

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
		                  {key:'UseYn', label:'<spring:message code="Cache.lbl_Use"/>', width:'100', align:'center',
			      			formatter:function () {
		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' style='width:50px;height:21px;border:0px none;' value='"+this.item.UseYn+"' onchange='ChangeIsUse(\""+ this.item.StampID +"\",\""+ this.item.EntCode +"\",this);'/>";
		      				}
		                  },	           
		                  {key:'EntName',  label:'<spring:message code="Cache.lbl_CorpName"/>', width:'250', align:'center'},
		                  {key:'StampName', label:'<spring:message code="Cache.lbl_apv_OfficailSeal_Name"/>', width:'250', align:'center',
		                	  formatter:function () {
			      					return "<a onclick='updateConfig(true, \""+ this.item.StampID +"\"); return false;'>"+this.item.StampName+"</a>";
		                	  }},
		                  {key:'FileInfo',  label:'<spring:message code="Cache.lbl_image"/>', width:'100', align:'center',           //미리보기
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
			                		  return "<img src='"+fileInfo+"' onerror='coviCmn.imgError(this)' width='50px' height='50px'/>";
				      			  }
			                  },
		                  {key:'OrderNo',  label:'<spring:message code="Cache.lbl_SortOrder"/>', width:'100', align:'center'},
		                  {key:'RegDate',  label:'<spring:message code="Cache.lbl_RegistrationDate"/>', width:'200', align:'center', sort:"desc"
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
		var EntCode = $("#selectUseAuthority").val(); 		
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();	
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getStampList.do",
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
		parent.Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_apv_OfficialSeal'/>","/approval/admin/goStampManagerSetPopup.do?mode=modify&key="+configkey,"580px","320px","iframe",pModal,null,null,true);
	}

	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){		
		objPopup = parent.Common.open("","addbaseconfig","<spring:message code='Cache.lbl_apv_OfficialSeal'/>","/approval/admin/goStampManagerSetPopup.do?mode=add","580px","350px","iframe",pModal,null,null,true);
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
		$('#selectUseAuthority').bindSelectAddOptions([{optionValue:'', optionText:'관리회사'}]);
		$("#selectUseAuthority").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListData.do",			
			ajaxAsync:false,
			onchange: function(){
				searchConfig();
			}
		});
		
	}
	
	//직인 사용 여부 변경
	function ChangeIsUse(pStampID,pEntCode,pObj){
		var Params = {
				StampID : pStampID,
				EntCode : pEntCode,
				UseYn : $(pObj).val()
		};
		$.ajax({
			url:"/approval/admin/setUseStampUse.do",
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				searchConfig();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/admin/setUseStampUse.do", response, status, error);
			}
		});
	}
</script>