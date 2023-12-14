<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_admin_approvalMenu_05"/></span>
	</h2>
</div>
<div class="cRContBottom mScrollVH">
	<form id="DistributionManager">
		<div class="sadminContent">
			<div class="sadminMTopCont" id="topitembar01">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a id="btnFormAdd" class="btnTypeDefault btnPlusAdd" href="#" onclick="addConfig(true);"><spring:message code="Cache.btn_Add"/></a>
					<a style="visibility:hidden;"></a>
				</div>
				<div class="buttonStyleBoxRight">
					<select class="selectType02 listCount" id="selectPageSize" onchange="setGridConfig1();searchConfig1();">
						<option value="10">10</option>
						<option value="20">20</option>
						<option value="30">30</option>
					</select>
					<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
				</div>
			</div>
			<div class="tblList tblCont">
				<div id="GridView1"></div>
			</div>
			<input type="hidden" id="hidden_domain_val" value=""/>
		</div>
	</form>
</div>

<script type="text/javascript">

	var myGrid1 = new coviGrid();
	myGrid1.config.fitToWidthRightMargin = 0;

	var objPopup;

	initDistributionMgr();
	
	function initDistributionMgr(){			
		setControl();
		setGrid();			// 그리드 세팅
		$("#divMember").hide();
		setUseAuthority();		// 사용권한 히든 값 세팅
	}
	
	// 초기 셋팅
	function setControl(){ 
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
	}
	
	//그리드 헤더 세팅
	function setGrid(){// 헤더 설정1
		var headerData1 =[					
		                  {key:'IsUse', label:'<spring:message code="Cache.lbl_apv_IsUse"/>', width:'70', align:'center'
		                	  , formatter:function(){
		                		  var IsUse;
		                		  if(this.item.IsUse=='Y'){
		                			  IsUse='<spring:message code="Cache.lbl_UseY"/>'; // 사용
		                		  }else if(this.item.IsUse=='N'){
		                			  IsUse='<spring:message code="Cache.lbl_UseN"/>'; // 미사용
		                		  }
		                		return IsUse;  
		                	  }
		                  },	                 
		                  {key:'GroupName', label:'<spring:message code="Cache.lbl_DistributionGroupNm"/>', width:'150', align:'center'},
		                  {key:'GroupCode',  label:'<spring:message code="Cache.lbl_GroupCode"/>', width:'150', align:'center'},
		                  {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', width:'200', align:'left'},
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'50', align:'center'  ,sort:"asc"},
		                  {key:'InsertDate', label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE15"/>', width:'100', align:'left'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.InsertDate, "yyyy-MM-dd HH:mm")}
		                  },
			      		  {key:'TargetManage', label:'<spring:message code="Cache.lbl_DistributionTargetManage"/>', width:'70', align:'center', sort: false, // 배포대상 관리
		                	  formatter:function () {
		                		  return "<a class='btnTypeDefault'><spring:message code='Cache.lbl_DistributionTargetManage'/></a>";
			      		  }}
			      		];
	
		myGrid1.setGridHeader(headerData1);		
		setGridConfig1();	
	}
	
	// 그리드 Config 설정
	function setGridConfig1(){
		var configObj1 = {
			targetID : "GridView1",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",			
			page : {
				pageNo: 1,
				pageSize:$("#selectPageSize").val()
			},	
			paging : true,
			colHead:{},
			body:{
				 onclick: function(){
						 	var itemName = myGrid1.config.colGroup[this.c].key;
					    	if(itemName == 'TargetManage'){
					    		updateDistributionTarget(true, this.item.GroupID, this.item.GroupName);
					    	}else{
					    		updateConfig(true, this.item.GroupID);
					    	}
					 }			
			}
		};
		
		myGrid1.setGridConfig(configObj1);
	}
	
	// 사용권한 히든 값 세팅
	function setUseAuthority(){
    	//$("#hidden_GroupID").val("");
    	//$("#hidden_GroupName").val("");
		searchConfig1();
	}
	
	// 리스트 조회
	function searchConfig1(){
		//$("#GridView1").find(".AXPaging[value=1]").click();
		myGrid1.page.pageNo = 1;
		myGrid1.bindGrid({
 			ajaxUrl:"/approval/manage/getDistributionList.do",
 			ajaxPars: {
 				"EntCode": $("#hidden_domain_val").val()
 			},
 			onLoad:function(){
			    myGrid1.fnMakeNavi("myGrid1");
 			}
		});		
	}
	
	// 배포목록 수정
	function updateConfig(pModal, configkey){			
		objPopup = parent.Common.open("","updateDistributionGroup"
					,"<spring:message code='Cache.lbl_apv_SelectDistributeList'/>|||<spring:message code='Cache.lbl_apv_DistributeList_instuction'/>"
					,"/approval/manage/goDistributionListSetPopup.do?mode=modify&EntCode="+$("#hidden_domain_val").val()+"&configkey="+configkey
					,"580px","380px","iframe",pModal,null,null,true);
	}
	
	// 배포목록 추가
	function addConfig(pModal){	
		if($("#hidden_domain_val").val()=="") {
			Common.Warning("<spring:message code='Cache.msg_MngCompany' />");
			return;
		}
		
		objPopup = parent.Common.open("","addDistributionGroup"
					,"<spring:message code='Cache.lbl_apv_SelectDistributeList'/>|||<spring:message code='Cache.lbl_apv_DistributeList_instuction'/>"
					,"/approval/manage/goDistributionListSetPopup.do?mode=add&EntCode="+$("#hidden_domain_val").val()
					,"550px","335px","iframe",pModal,null,null,true);
	}
	
	// 배포대상 수정
	function updateDistributionTarget(pModal, pGroupID, pGroupName){
		//$("#hidden_GroupID").val(pGroupID);
		//$("#hidden_GroupName").val(pGroupName);
		//$("#divMember").show();
		//searchConfig2();
		Common.open("","updateDistributionTarget"
					,"<spring:message code='Cache.lbl_DistributionTargetManage'/>|||"+pGroupName
					,"/approval/manage/goDistributionMemberList.do?mode=modify&key="+pGroupID+"&entCode="+$("#hidden_domain_val").val()
					,"800px","620px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	function setFirstPageURL(){
		SaveFirstPageURL("/covicore/systemadmin_dictionarymanage.do");
	}
	
</script>