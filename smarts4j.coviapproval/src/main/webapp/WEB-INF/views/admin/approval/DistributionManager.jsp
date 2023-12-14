<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_apv_admin_approvalMenu_05"/></span>
</h3>
<form id="DistributionManager">
	<div style="width:100%;min-height: 800px">
		<div id="topitembar01" class="topbar_grid">			
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<select name="selectDdlCompany" class="AXSelect" id="selectDdlCompany"></select>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(true);"/>				
		</div>
		<div id="GridView1" class="ztable_list" style="min-height: 300px; padding-top: 1px; overflow-x: hidden;">
		</div>
		<!-- 대상자 추가 시작-->
		<div id="divMember" >
			<div>
				<span id="MemberName" style="font-size: 20px; font-weight: bold; display: block; padding-top: 20px; padding-bottom: 5px;"></span>
			</div>
			<div id="topitembar01" class="topbar_grid">			
				<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh2();"/>
				<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addMember();"/>				
			</div>			
			<div id="GridViewMemberList" class="ztable_list" style="min-height: 300px; padding-top: 1px; overflow-x: hidden;">
			</div>
		</div>
	</div>
	<input type="hidden" id="hidden_GroupID" value=""/>
	<input type="hidden" id="hidden_GroupName" value=""/>
</form>

<script type="text/javascript">

	var myGrid1 = new coviGrid();
	var myGrid2 = new coviGrid();
	var objPopup;

	initDistributionMgr();
	
	function initDistributionMgr(){			
		setSelect();
		setGrid();			// 그리드 세팅
		$("#divMember").hide();
		setUseAuthority();		// 사용권한 히든 값 세팅
	}
	
	//그리드 세팅
	function setGrid(){// 헤더 설정1
		var headerData1 =[					
		                  {key:'IsUse', label:'<spring:message code="Cache.lbl_apv_IsUse"/>', width:'70', align:'center'
		                	  , formatter:function(){
		                		  var IsUse;
		                		  if(this.item.IsUse=='Y'){
		                			  IsUse='사용';
		                		  }else if(this.item.IsUse=='N'){
		                			  IsUse='미사용';
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
		                  {key:'', label:'<spring:message code="Cache.lbl_Edit"/>', width:'70', align:'center', sort: false, 
		                	  formatter:function () {
		                		  return "<input class='smButton' type='button' value='<spring:message code='Cache.lbl_Edit'/>'  onclick='updateConfig(true, \""+ this.item.GroupID +"\"); return false;'>";
			      				}}
			      		];
	
		myGrid1.setGridHeader(headerData1);		
		setGridConfig1();	
		setGridConfig2()
	}
	
	// 그리드 Config 설정
	function setGridConfig1(){
		var configObj1 = {
			targetID : "GridView1",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"",			
			page : {
				pageNo: 1,
				pageSize: 10
			},	
			paging : true,
			colHead:{},
			body:{
				 onclick: function(){				    
					    if(!(Object.toJSON(this.c).replaceAll("\"", "")=='6')){		
					    	$("#hidden_GroupID").val(Object.toJSON(this.item.GroupID).replaceAll("\"", ""));
					    	$("#hidden_GroupName").val(Object.toJSON(this.item.GroupName).replaceAll("\"", ""));
					    	$("#divMember").show();
					    	searchConfig2();
					    }
					    
					 }			
			}
		};
		
		myGrid1.setGridConfig(configObj1);
	}
	
	// 그리드 Config 설정
	function setGridConfig2(data){
		// 헤더 설정2
		var headerData2 =[					
		                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_DistributionTarget"/>', width:'200', align:'center'},	                 
		                  {key:'UserCode', label:'<spring:message code="Cache.lbl_ID"/>', width:'200', align:'center'},
		                  {key:'DEPT_Name',  label:'<spring:message code="Cache.lbl_DeptName"/>', width:'500', align:'center'},	                  
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_SortKey"/>',  width:'100', align:'center',sort:"asc"}	                               
			      		];
		
		myGrid2.setGridHeader(headerData2);
		
		var configObj2 = {
			targetID : "GridViewMemberList",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			colHead:{},
			body:{
				onclick: function(){					
						memberDetailPopup(true,Object.toJSON(this.item.GroupMemberID));
				    }				
			}
		};
		
		myGrid2.setGridConfig(configObj2);		
	}
	
	// 사용권한 히든 값 세팅
	function setUseAuthority(){
    	$("#hidden_GroupID").val("");
    	$("#hidden_GroupName").val("");
		searchConfig1();
		searchConfig2();
	}
	
	// baseconfig 검색
	function searchConfig1(){
		$("#GridView1").find(".AXPaging[value=1]").click();
		myGrid1.bindGrid({
 			ajaxUrl:"/approval/admin/getDistributionList.do",
 			ajaxPars: {
 				"EntCode": $("#selectDdlCompany").val()
 			},
 			onLoad:function(){
			    myGrid1.fnMakeNavi("myGrid1");
 			}
		});		
	}
	
	// baseconfig 검색
	function searchConfig2(){	
		$("#divMember").find(".AXPaging[value=1]").click();	
		var GroupID = $("#hidden_GroupID").val();		
		$("#MemberName").text($("#hidden_GroupName").val());		
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
		
		myGrid2.bindGrid({
 			ajaxUrl:"/approval/admin/getDistributionMemberList.do",
 			ajaxPars: {
 				"sel_Search":sel_Search,
				"search":search,
 				"GroupID": GroupID
 			},
 			onLoad:function(){
 				//아래 처리 공통화 할 것
 				coviInput.setSwitch();
			    myGrid2.fnMakeNavi("myGrid2");
 			}
		});		
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){			
		objPopup = parent.Common.open("","updateDistributionGroup","<spring:message code='Cache.lbl_apv_SelectDistributeList'/>|||<spring:message code='Cache.lbl_apv_DistributeList_instuction'/>","/approval/admin/goDistributionListSetPopup.do?mode=modify&EntCode="+$("#selectDdlCompany").val()+"&configkey="+configkey,"580px","320px","iframe",pModal,null,null,true);
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){	
		if($("#selectDdlCompany").val()=="") {
			Common.Warning("<spring:message code='Cache.msg_MngCompany' />");
			return;
		}
		
		objPopup = parent.Common.open("","addDistributionGroup","<spring:message code='Cache.lbl_apv_SelectDistributeList'/>|||<spring:message code='Cache.lbl_apv_DistributeList_instuction'/>","/approval/admin/goDistributionListSetPopup.do?mode=add&EntCode="+$("#selectDdlCompany").val(),"550px","300px","iframe",pModal,null,null,true);
	}
	
	
	// 배포대상자추가 버튼에 대한 레이어 팝업
	function addMember(pModal){
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=setDistrList&strType=D9","1060px","580px","iframe",true,null,null,true);
	}
	
	//조직도선택후처리관련
	function setDistrList(peopleValue){
		
		var gridMemberData = {"members" : myGrid2.list};
		var duplicationChk = false;
		
		var dataObj = $.parseJSON(peopleValue);	
		var UR_Data;
		
		var DistributionMemberArray = new Array();		
		jQuery.ajaxSettings.traditional = true;
		
		$(dataObj.item).each(function(i){
			duplicationChk = false;
			
			if($$(gridMemberData).find("members[UserCode="+dataObj.item[i].AN+"]").length > 0){
				duplicationChk = true;
			}
			
			if(!duplicationChk){
				if(dataObj.item[i].AN != undefined){
					var DistributionMemberObj = new Object();	
					DistributionMemberObj.GroupID = $("#hidden_GroupID").val();
					DistributionMemberObj.SortKey = i;			
					DistributionMemberObj.UserCode = dataObj.item[i].AN;
					DistributionMemberArray.push(DistributionMemberObj);
				}
			}
		});
		
		//jsavaScript 객체를 JSON 객체로 변환
		DistributionMemberArray = JSON.stringify(DistributionMemberArray);
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{				
				"DistributionMember" : DistributionMemberArray
			},
			url:"/approval/admin/insertDistributionMember.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_apv_137' />");
				searchConfig2();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/admin/insertDistributionMember.do", response, status, error);
			}
		});
	}
	
	// 대상자 수정 레이어 팝업
	function memberDetailPopup(pModal,param){
		var paramGroupMemberID = param.replaceAll("\"", "");
		objPopup = parent.Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_apv_ChargerManage'/>","/approval/admin/goDistributionMemberDetailPopup.do?mode=modify&param="+paramGroupMemberID,"500","200","iframe",pModal,null,null,true);		
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	// 새로고침 대상자
	function Refresh2(){
		$("#search").val('');
		searchConfig2();
	}
	
		
	function setFirstPageURL(){
		SaveFirstPageURL("/covicore/systemadmin_dictionarymanage.do");
	}
	
	//엔터검색
	function cmdSearch(){
		searchConfig2();
	}
	
	// Select box 바인드
	function setSelect(){
		$("#selectDdlCompany").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListData.do",			
			ajaxAsync:false,
			onchange: function(){
				setUseAuthority();
			}
		}).bindSelectRemoveOptions([{optionValue:"ORGROOT"}]);
		
		$("#selectDdlCompany").bindSelectSetValue(Common.getSession("DN_Code"));
	}
</script>