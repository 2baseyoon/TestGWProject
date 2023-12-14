<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_User_Manager'/></h2>						
</div>
<div class="mt20 tabMenuCont">
	<ul class="tabMenu clearFloat tabMenuType02">
		<li class="active"><a href="#"><spring:message code='Cache.lbl_Join_Test'/></a></li>
		<li class=""><a href="#"><spring:message code='Cache.lbl_Activity_User'/></a></li>
		<li class=""><a href="#"><spring:message code='Cache.lbl_MemberStatus'/></a></li>
	</ul>
</div>
<div class="mt20 tabContentContanier">
	<div class="tabContent active">
		<div class="selectBox">
			<a href="#" class="btnTypeDefault btnExcel" id="delBtn" onclick="excelDownload('U');"><spring:message code='Cache.btn_SaveToExcel'/></a>
			<button href="#" class="btnRefresh" type="button" onclick="selectUserList();"></button>							
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv">
			</div>
		</div>
	</div><!-- 회원정보-->	
	<div class="tabContent">
		<div class="selectBox">
			<a href="#" class="btnTypeDefault btnExcel" id="delBtn" onclick="excelDownload('D');"><spring:message code='Cache.btn_SaveToExcel'/></a>
			<button href="#" class="btnRefresh" type="button" onclick="selectDelList();"></button>							
		</div>
		<div class="tblList tblCont">
			<div id="DelGridDiv">
			</div>
		</div>
	</div><!-- 회원랭킹-->
	<div class="tabContent">
		<div class="selectBox">
			<a href="#" class="btnTypeDefault btnExcel" id="delBtn" onclick="excelDownload('C');"><spring:message code='Cache.btn_SaveToExcel'/></a> 
			<a id="copyBtn" class="btnTypeDefault"  style="margin-left: 100px" onclick="MemberLeave();">탈퇴</a>
			<button href="#" class="btnRefresh" type="button" onclick="selectCallList();"></button>					
		</div>		
		<div class="tblList tblCont">
			<div id="CallGridDiv">
			</div>
		</div>
	</div><!-- 연락하기-->	
	<form id="form1">
			
	</form>
	
</div>

<script type="text/javascript">
var userGrid = new coviGrid();
var delGrid = new coviGrid();
var callGrid = new coviGrid();

var userHeaderData = "";
var delHeaderData = "";
var callHeaderData = "";

userGrid.config.fitToWidthRightMargin=0;
delGrid.config.fitToWidthRightMargin=0;
callGrid.config.fitToWidthRightMargin=0;
sessionStorage.community_member_list_page=1;

$(function(){					
	setCmEvent();
	$('.tabMenu>li').eq(0).click();
});

function setCmEvent(){
	$('.tabMenu>li').on('click', function(){
		$('.tabMenu>li').removeClass('active');
		$('.tabContent').removeClass('active');
		$(this).addClass('active');
		$('.tabContent').eq($(this).index()).addClass('active');
		
		if($(this).index() == "0"){
			setUserGrid();
		}else if($(this).index() == "1"){
			setDelGrid();
		}else{
			setCallGrid();
		}
		
	});		
	
}

var URcode;
var UName;
var checkSt;
function MemberClose(){
	URcode="";
	UName="";
	checkSt=false;
}

function MemberLeave(){	
	if(checkSt==false){
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>"); //대상을 선택해주세요.
		return false;
	}	
	var url = "/groupware/layout/userCommunity/communityMovePagePopUp.do?cId="+cID+"&UName="+UName+"&URcode="+URcode;
	Common.open("","MovePagePopUp","<spring:message code='Cache.lbl_CommunityWithdrawal'/>",url,"450px","290px","iframe",false,null,null,true); //커뮤니티 탈퇴
	
}


//폴더 그리드 세팅
function setUserGrid(){
	MemberClose();
	userGrid.setGridHeader(UserGridHeader());
	selectUserList();				
}

//폴더 그리드 세팅
function setDelGrid(){
	MemberClose();
	delGrid.setGridHeader(DelGridHeader());
	selectDelList();				
}

//폴더 그리드 세팅
function setCallGrid(){
	MemberClose();
	callGrid.setGridHeader(CallGridHeader());
	selectCallList();				
}

function UserGridHeader(){
	var UserGridHeader = [
	      		         	{key:'UR_Code', label:'UR_Code', hideFilter : 'Y',display:false},
							{key:'RegRequestDate',  label:"<spring:message code='Cache.lbl_Join_RequestDay'/>", width:'3', align:'center', sort:'desc'},    
	      		        	{key:'opName',  label:"<spring:message code='Cache.lbl_FirstName'/>", width:'3', align:'center', addClass:"bodyTdFile", formatter: function(){
	      		        	     return coviCtrl.formatUserContext("List", this.item.opName, this.item.UR_Code, this.item.MailAddress);
	      		        	}}, 
	      		        	{key:'opDeptName',  label:"<spring:message code='Cache.lbl_apv_dept'/>", width:'3', align:'center'},
	      		        	{key:'opJobPositionName',  label:"<spring:message code='Cache.lbl_JobPosition'/>", width:'3', align:'center'},
	      		        	{key:'',  label:"<spring:message code='Cache.lbl_Join_Test'/>", width:'8', align:'center', sort: false, formatter: function () {
	      		        		var html = "";
	      		        		html = String.format('<div class="btnTblBox"><a class="btnTypeChk btnTypeDefault" onclick="goCommunityApprove('+"'{0}'"+","+"'P'"+');">'+
	      		        					          '{1}</a><a class="btnTypeX btnTypeDefault" onclick="goCommunityApprove('+"'{0}'"+","+"'C'"+');">{2}</a></div>',
	      		        					        this.item.UR_Code
	      		        					        ,"<spring:message code='Cache.btn_Approval2'/>"
	      		        					        ,"<spring:message code='Cache.lbl_Deny'/>");
	      		        		return html;
							 }}
	      		        	
	      		        ];
	userHeaderData = UserGridHeader;
	return UserGridHeader;
}

function DelGridHeader(){
	var DelGridHeader = [
							{key:'UR_Code', label:'UR_Code', hideFilter : 'Y',display:false},
	      		        	{key:'opName',  label:"<spring:message code='Cache.lbl_name'/>", width:'3', align:'center', addClass:"bodyTdFile", formatter: function(){
	      		        	     return coviCtrl.formatUserContext("List", this.item.opName, this.item.UR_Code, this.item.MailAddress );
	      		        	}}, 
	      		        	{key:'opDeptName',  label:"<spring:message code='Cache.lbl_apv_dept'/>", width:'3', align:'center'},
	      		        	{key:'opJobPositionName',  label:"<spring:message code='Cache.lbl_JobPosition'/>", width:'3', align:'center'},
	      		        	{key:'DetailStatus',  label:"<spring:message code='Cache.lbl_Withdrawal_Class'/>", width:'3', align:'center'},
	      		        	{key:'LeaveProcessDate',  label:"<spring:message code='Cache.lbl_Withdrawal_Date'/>", width:'3', align:'center', sort:'desc'},
	      		        	{key:'LeaveMessage',  label:"<spring:message code='Cache.lbl_Withdrawal_Reason'/>", width:'3', align:'center'},
	      		        	{key:'RegProcessDate',  label:"<spring:message code='Cache.lbl_Join_Day'/>"+Common.getSession("UR_TimeZoneDisplay"), width:'3', align:'center',
	      		        		formatter:function(){
	      		        			return CFN_TransLocalTime(this.item.RegProcessDate,_ServerDateSimpleFormat);
	      		        		}
	      		        	}
   	];
	delHeaderData = DelGridHeader;
	return DelGridHeader;
}

function CallGridHeader(){
	var CallGridHeader = [
	                    {key:'chk', label:' ',  width:'3', align:'center', hideFilter : 'Y',sort:false,formatter:function(){
	                    	var html ;
	                    	if(this.item.memberLevel == "9"){
	                    		html = this.item.CuMemberLevel;
	                    	}else{
	                    		html =seletCheckBox(this.item.UR_Code,this.item.opName);
	                    	}
	                    	return html;
	                    }},	                   
						{key:'UR_Code', label:'UR_Code', hideFilter : 'Y',display:false},
						{key:'opName',  label:"<spring:message code='Cache.lbl_name'/>", width:'3', align:'center', addClass:"bodyTdFile", formatter: function(){
     		        	     return coviCtrl.formatUserContext("List", this.item.opName, this.item.UR_Code, this.item.MailAddress);
      		        	}}, 
						{key:'opDeptName',  label:"<spring:message code='Cache.lbl_apv_dept'/>", width:'3', align:'center'},
						{key:'VisitCount',  label:"<spring:message code='Cache.lbl_Counter'/>", width:'3', align:'center'},
						{key:'MsgCount',  label:"<spring:message code='Cache.lbl_noticeCount'/>", width:'3', align:'center'},
						{key:'ReplyCount',  label:"<spring:message code='Cache.lbl_CommentCount'/>", width:'3', align:'center'},
						{key:'ViewCount',  label:"<spring:message code='Cache.lbl_PostViews'/>", width:'3', align:'center'},
						{key:'VisitDate',  label:"<spring:message code='Cache.lbl_Latest_Date'/>"+Common.getSession("UR_TimeZoneDisplay"), width:'3', align:'center',
							formatter:function(){
								return CFN_TransLocalTime(this.item.VisitDate,_ServerDateSimpleFormat);
							}	
						},
						{key:'RegProcessDate',  label:"<spring:message code='Cache.lbl_Join_Day'/>"+Common.getSession("UR_TimeZoneDisplay"), width:'3', align:'center',
							formatter:function(){
								return CFN_TransLocalTime(this.item.RegProcessDate,_ServerDateSimpleFormat);
							}	
						},
						{key:'memberLevel',  label:'memberLevel', align:'center', hideFilter : 'Y',display:false},
						{key:'CuMemberLevel',  label:"<spring:message code='Cache.lbl_User_Grade'/>", width:'3', align:'center', formatter: function () {
      		        		var html = "";
      		        		
      		        		if(this.item.memberLevel == "9"){
      		        			html = this.item.CuMemberLevel;
      		        		}else{
      		        			html = selectMemberLevel(this.item.memberLevel, this.item.UR_Code);
      		        		}
      		        		
      		        		return html;
						 }}
	];
	callHeaderData = CallGridHeader;
	return CallGridHeader;
}

function seletCheckBox(code,name){	
	var str = String.format('<input type="checkbox" class="check_class" name="group" onclick=checkBox(this,\''+code+'\',\''+name+'\')>');	
	return str;
}

function checkBox(select,code,name){	 
	  var obj = document.getElementsByName("group");
      for(var i=0; i<obj.length; i++){
          if(obj[i] != select){
              obj[i].checked = false;
          }else{
        	  URcode=code;
        	  UName=name;
        	  checkSt =obj[i].checked = true;
          }
      }
}
 
function selectMemberLevel(memberLevel, userCode){
	var str = ""
	
	$.ajax({
		type:"POST",
		data:{
			memberLevel : memberLevel
 		},
		async:false,
		url:"/groupware/layout/userCommunity/selectMemberLevelBox.do",
		success:function (data) {
			if(data.list.length > 0){
				str = String.format('<select id="memberLevel_'+userCode+'" onchange="memberLevelChange('+"'{0}'"+');">',
						userCode);
				
				$(data.list).each(function(i,v){
					str += '<option value="'+v.optionValue+'"  >'+v.optionText+'</option>';
    			});
				
				str += '</select> ';
			}
			
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/userCommunity/selectMemberLevelBox.do", response, status, error);
		}
	});
	
	return str;
}



function selectUserList(){
	//폴더 변경시 검색항목 초기화
	 setUserGridConfig();
	 userGrid.bindGrid({
		ajaxUrl:"/groupware/layout/userCommunity/communityMemberManageGridList.do",
		ajaxPars: {
			MemberLevel : '0',
			CU_ID : cID
		}, 
	}); 
}

function setUserGridConfig(){
	var configUserObj = {
		targetID : "gridDiv",
		height:"auto",
		overflowCell: [2]
	};
	
	userGrid.setGridConfig(configUserObj);
}

function selectDelList(){
	//폴더 변경시 검색항목 초기화
	setDelGridConfig();
    delGrid.bindGrid({
		ajaxUrl:"/groupware/layout/userCommunity/communityDeleteMemberGridList.do",
		ajaxPars: {
			CU_ID : cID
		},
	});   
}
function setDelGridConfig(){
	var configDelObj = {
		targetID : "DelGridDiv",
		height:"auto",
		overflowCell: [1]
	};
	
	delGrid.setGridConfig(configDelObj);
}

function selectCallList(){
	//폴더 변경시 검색항목 초기화
	setCallGridConfig();
	callGrid.bindGrid({
		ajaxUrl:"/groupware/layout/userCommunity/selectCommunityMemberGridList.do",
		ajaxPars: {
			CU_ID : cID
		}
	}); 
}

function setCallGridConfig(){
	var configCallObj = {
		targetID : "CallGridDiv",
		height:"auto",
		overflowCell: [2],
		page: {
			pageNo: (sessionStorage.community_member_list_page) ? sessionStorage.community_member_list_page : 1
		}
	};
	callGrid.setGridConfig(configCallObj);
}

function goCommunityApprove(userId, type){
	var str = "";
	if(type == "C"){
		str = "<spring:message code='Cache.msg_JoinCommunityReject'/>";
	}else if(type == "P"){
		str = "<spring:message code='Cache.msg_JoinCommunity'/>";
	}
	
	Common.Confirm(str, "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityJoinProcess.do",
				type:"post",
				data:{
					CU_ID : cID,
					UserCode : userId,
					Type : type
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_170'/>"); //완료되었습니다.
						selectUserList();
					}else{ 
						Common.Error("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityJoinProcess.do", response, status, error); 
				}
			}); 
		}
	});
}

function excelDownload(type){
	var action;
	if(type == "U"){
		var headerName = getHeaderNameForExcel(type);
		
		var	sortKey = userGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
		var	sortWay = userGrid.getSortParam("one").split("=")[1].split(" ")[1]; 		
		
		action = String.format("/groupware/layout/userCommunity/communityMemberMenageListExcelDownload.do?sortKey={0}&sortWay={1}&headerName={2}&CU_ID={3}", sortKey, sortWay, headerName,cID);
		
	}else if(type == "D"){
		var headerName = getHeaderNameForExcel(type);
		
		var	sortKey = delGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
		var	sortWay = delGrid.getSortParam("one").split("=")[1].split(" ")[1]; 		
		
		action = String.format("/groupware/layout/userCommunity/communityDeleteMemberListExcelDownload.do?sortKey={0}&sortWay={1}&headerName={2}&CU_ID={3}", sortKey, sortWay, headerName,cID);
		
	}else if(type == "C"){
		var headerName = getHeaderNameForExcel(type);
		
		var sortParam = callGrid.getSortParam("one");
		var	sortKey;
		var sortWar; 
		
		if(sortParam == ""){
			sortKey = "memberLevel";
			sortWay = "desc";
		}else{
			sortKey = sortParam.split("=")[1].split(" ")[0];
			sortWay = sortParam.split("=")[1].split(" ")[1];
		}		
		
		action = String.format("/groupware/layout/userCommunity/communityMemberListExcelDownload.do?sortKey={0}&sortWay={1}&headerName={2}&CU_ID={3}", sortKey, sortWay, headerName,cID);
	}	
	location.href = action;

	
}

function getHeaderNameForExcel(type){
	
	var returnStr = "";
   	
	if(type == "U"){
		for(var i=0;i<userHeaderData.length; i++){
	   		if(userHeaderData[i].display != false && 
	   				userHeaderData[i].label != 'UR_Code' && 
	   				userHeaderData[i].key != ''){
				returnStr += userHeaderData[i].label + "|";
	   	   	}
		}
	}else if(type == "D"){
		for(var i=0;i<delHeaderData.length; i++){
	   		if(delHeaderData[i].display != false && 
	   				delHeaderData[i].label != 'UR_Code' && 
	   				delHeaderData[i].key != ''){
				returnStr += delHeaderData[i].label + "|";
	   	   	}
		}
	}else if(type == "C"){
		for(var i=0;i<callHeaderData.length; i++){
	   		if(callHeaderData[i].display != false && 
	   				callHeaderData[i].label != 'UR_Code' && callHeaderData[i].label != 'memberLevel' &&
	   				callHeaderData[i].key != '' && callHeaderData[i].key != 'chk'){
				returnStr += callHeaderData[i].label + "|";
	   	   	}
		}
	}
	
	return encodeURI(returnStr);
}

function memberLevelChange(userCode){
	
	$.ajax({
		url:"/groupware/layout/userCommunity/communityMemberLevelChange.do",
		type:"post",
		data:{
			CU_ID : cID,
			UserCode : userCode,
			memberLevel : $("select[id='memberLevel_"+userCode+"']").val()
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_170'/>"); //완료되었습니다.
				sessionStorage.community_member_list_page = callGrid.page.pageNo; 
				selectCallList();
			}else{
				Common.Error("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityMemberLevelChange.do", response, status, error); 
		}
	}); 
	
}


</script>