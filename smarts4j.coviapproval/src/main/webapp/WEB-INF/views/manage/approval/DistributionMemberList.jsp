<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript">
	var mode ="${param.mode}";
	var paramGroupID =  "${param.key}";
	var paramEntCode =  "${param.entCode}";
	
	var myGrid2 = new coviGrid();
	myGrid2.config.fitToWidthRightMargin = 0;
	
	var objPopup;
	
	$(document).ready(function (){
		setGridConfig2();			// 그리드 세팅			
		searchConfig2(); // 리스트 조회
	});	
	
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
				pageSize:$("#selectPageSize").val()
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
	
	// 리스트 조회
	function searchConfig2(){	
		//$("#divMember").find(".AXPaging[value=1]").click();	
		myGrid2.page.pageNo = 1;
		var GroupID = paramGroupID; //$("#hidden_GroupID").val();		
		//$("#MemberName").text($("#hidden_GroupName").val());		
		var sel_Search = ""; //$("#sel_Search").val();
		var search = ""; //$("#search").val();
		
		myGrid2.bindGrid({
 			ajaxUrl:"/approval/manage/getDistributionMemberList.do",
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
	
	// 배포대상자추가 버튼에 대한 레이어 팝업
	function addMember(pModal){
		objPopup = parent.Common.open("","orgmap_pop"
					,"<spring:message code='Cache.lbl_apv_org'/>"
					,"/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&strType=D9"
					,"1060px","580px","iframe",true,null,null,true);
	}
	parent._CallBackMethod2 = setDistrList;
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
					DistributionMemberObj.GroupID = paramGroupID; //$("#hidden_GroupID").val();
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
			url:"/approval/manage/insertDistributionMember.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_apv_137' />");
				searchConfig2();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/insertDistributionMember.do", response, status, error);
			}
		});
	}
	
	// 대상자 수정 레이어 팝업
	function memberDetailPopup(pModal,param){
		var paramGroupMemberID = param.replaceAll("\"", "");
		Common.open("","updatebaseconfig"
					,"<spring:message code='Cache.lbl_apv_ChargerManage'/>"
					,"/approval/manage/goDistributionMemberDetailPopup.do?mode=modify&param="+paramGroupMemberID
					,"500","270","iframe",pModal,null,null,true);
		//memberDetailPopup(true,Object.toJSON(this.item.GroupMemberID));
	}
	
	// 새로고침 대상자
	function Refresh2(){
		//$("#search").val('');
		searchConfig2();
	}

	/*
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){		
		Common.open("","updateConfig","<spring:message code='Cache.lbl_apv_JobFunctionManage'/>|||<spring:message code='Cache.lbl_apv_charge_person'/>","goJobFunctionMemberDetailPopup.do?mode=modify&key="+configkey,"530px","300px","iframe",pModal,null,null,true);
	}
	*/
	
</script>
<div class="sadmin_pop sadminContent" id="divMember">
	<div class="sadminMTopCont">
		<div class="pagingType02 buttonStyleBoxLeft">
			<a class="btnTypeDefault btnPlusAdd" href="#" onclick="addMember();"><spring:message code="Cache.btn_Add" /></a>
		</div>
		<div class="buttonStyleBoxRight">
			<select class="selectType02 listCount" id="selectPageSize" onchange="setGridConfig2();searchConfig2();">
				<option value="10">10</option>
				<option value="20">20</option>
				<option value="30">30</option>
			</select>
			<button class="btnRefresh" type="button" href="#" onclick="Refresh2();"></button>
		</div>
	</div>
	<div id="GridViewMemberList" class="tblList tblCont"></div>
	<!-- <input type="hidden" id="hidden_GroupID" value=""/>
	<input type="hidden" id="hidden_GroupName" value=""/> -->
</div>


