<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style type="text/css">
.flowerPopup{
	float: left;
}
</style>
<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_User_Info'/></h2>						
</div>
<div class="mt20 tabMenuCont">
	<ul class="tabMenu clearFloat tabMenuType02">
		<li class="active"><a href="#"><spring:message code='Cache.lbl_User_Info'/></a></li>
		<li class=""><a href="#"><spring:message code='Cache.lbl_userRanking'/></a></li>
		<li class=""><a href="#"><spring:message code='Cache.lbl_call'/></a></li>
	</ul>
</div>
<div class="mt20 tabContentContanier">
	<div class="tabContent active">
		<div class="tblList tblCont">
			<div id="UserGridDiv">
			</div>
		</div>					
	</div><!-- 회원정보-->	
	<div class="tabContent">
		<div class="commTabFloatBox clearFloat">
			<div class="commAddRanking " id="boardRank">
				
			</div>
			<div class="commVisitRanking" id="visitRank">
				
			</div>
		</div>
	</div><!-- 회원랭킹-->
	<div class="tabContent ">
		<div class="commTabFloatBox clearFloat">
			<div class="commTabChkListCont">
				<div class="commTabChkContTop">
					<div class="searchBox03 ">
						<span>
							<input type="text" id="callMemberSearchInput"  onkeypress="if(event.keyCode==13) {setCallMember(); return false;}">
							<button type="button" class="btnSearchType01" onclick="setCallMember();"><spring:message code='Cache.lbl_search'/></button>
						</span>
					</div>
				</div>
				<div class="commTabChkContMiddle">
					<div class="chkStyle04 chkType01 ">
						<input type="checkbox" id="allSVAll" name="allSV">
						<label for="allSVAll">
							<span></span><spring:message code='Cache.lbl_selectall'/>
						</label>
					</div>
				</div>
				<div class="mScrollV scrollVType01 commTabChkContBottom " >
						<ul id="callMember">
							
						</ul>
				</div>
			</div>
			<div class="commTabMsgCont">
				<div class="commMsgChkBox">
					<div class="chkStyle01  nMail">
						<input type="checkbox" id="eeeeee1">
						<label for="eeeeee1">
							<span></span><spring:message code='Cache.lbl_MAIL'/>
						</label>
					</div>
					<div class="chkStyle01  nTodo ml25">
						<input type="checkbox" id="eeeeee2" >
						<label for="eeeeee2">
							<span></span>To-do
						</label>
					</div>
				</div>
				<div class="mt20">
					<textarea id="sendMessageTxt" maxlength="1000"></textarea>
				</div>
				<div class="mt25 btm">
					<a href="#" class="btnTypeDefault btnTypeBg " onclick="sendMessage();"><spring:message code='Cache.msg_sendMessage'/></a>
				</div>					
			</div>
		</div>
	</div><!-- 연락하기-->	
</div>
<script type="text/javascript">
var userGrid = new coviGrid();
var userHeaderData = "";
userGrid.config.fitToWidthRightMargin=0;

$(function(){	
	setCmEvent();
	setUserGrid();
	setRank();
	setCallMember();
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
			setRank();
		}else{
			//setCallMember();
		}
	});		
	
	$("#allSVAll").on('click',function(){
		if($("input:checkbox[id='allSVAll']").is(":checked")){
			$("input[name^='allSV']").prop('checked', true) ;
		}else{
			$("input[name^='allSV']").prop('checked', false) ;
		}
		
	});
	
}

//폴더 그리드 세팅
function setUserGrid(){
	userGrid.setGridHeader(UserGridHeader());
	selectUserList();				
}

function UserGridHeader(){
	var UserGridHeader = [
						{key:'UR_Code', label:'UR_Code', hideFilter : 'Y',display:false},
						{key:'opName',  label:"<spring:message code='Cache.lbl_name'/>", width:'4', align:'center', addClass:"bodyTdFile",formatter: function () {
      		        		var html = "";
      		        		html = "<span style='float: left;'><img name='bizCardThumbnail' style='display: inline-block; width: 30px; height: 30px; border-radius: 50%; background: #efeff0; overflow: hidden; vertical-align: middle; margin-right: 5px; margin-top: 5px;' src='"+ coviCmn.loadImage(this.item.PhotoPath) +"' onerror='coviCmn.imgError(this, true);' alt=''></span>";
      		        		/* html += this.item.opName; */
      		        		html += coviCtrl.formatUserContext("List", this.item.opName, this.item.UR_Code, this.item.MailAddress);
      		        		return html;
						 }},
						{key:'opDeptName',  label:"<spring:message code='Cache.lbl_apv_dept'/>", width:'3', align:'center'},
						{key:'RegProcessDate',  label:"<spring:message code='Cache.lbl_Join_Day'/>" +Common.getSession("UR_TimeZoneDisplay"), width:'3', align:'center',
							formatter:function(){
								return CFN_TransLocalTime(this.item.RegProcessDate,_ServerDateSimpleFormat);
							}
						},
						{key:'PhoneNumber',  label:"<spring:message code='Cache.lbl_HP'/>", width:'3', align:'center'},
						{key:'MailAddress',  label:"<spring:message code='Cache.lbl_Mail_Address'/>", width:'3', align:'center'},
						{key:'CuMemberLevel',  label:"<spring:message code='Cache.lbl_User_Grade'/>", width:'3', align:'center'},
						{key:'PhotoPath',  label:'PhotoPath', display:false, hideFilter : 'Y'}
	];
	userHeaderData = UserGridHeader;
	return UserGridHeader;
}

function selectUserList(){
	//폴더 변경시 검색항목 초기화
	setUserGridConfig();
	userGrid.bindGrid({
		ajaxUrl:"/groupware/layout/userCommunity/selectCommunityMemberGridList.do",
		ajaxPars: {
			CU_ID : cID
		},
	}); 
}

function setUserGridConfig(){
	var configUserObj = {
		targetID : "UserGridDiv",
		height:"auto",
		overflowCell: [1]
	};
	
	userGrid.setGridConfig(configUserObj);
}

function setRank(){
	setUserBoardRank();
	setUserVisitRank();
}

function setUserBoardRank(){
	var str = "";
	$.ajax({
		url:"/groupware/layout/userCommunity/selectCommunityBoardRankInfo.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (br) {
			$("#boardRank").html("");
			str = "<h3 class='cycleTitle'>"+"<spring:message code='Cache.lbl_Notice_Rank'/>"+"</h3>";
			str += "<ul class='mt20 commRankingListCont'>";
			if(br.list.length > 0){
				$(br.list).each(function(i,v){
					if(v.num == '1'){
						str += "<li class='one'>";
					}else if(v.num == '2'){
						str += "<li class='two'>";
					}else if(v.num == '3'){
						str += "<li class='three'>";
					}else{
						str += "<li>";
					}
					str += "<div><p>"+v.num+"</p></div>";
					str += "<div class='personBox individualPersonBox'>";
					str += "<div class='perPhoto'>";
					str += "<img name='bizCardThumbnail' style='width: auto; height: 100%;' src='"+ coviCmn.loadImage(v.PhotoPath) +"' onerror='coviCmn.imgError(this, true);' alt=''>";
					str += "</div>";
					str += "<div class='name'>";
					str += "<div class='btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='position:relative;cursor:pointer' data-user-code='"+ v.UserCode +"' data-user-mail=''>"+v.opName+"</div>";
					str += "</div></div>";
					str += "<div><p>"+v.MsgCount+"<spring:message code='Cache.lbl_Point'/>"+"</p></div>";
					str += "</li>";
					
				});
			}
			str += "</ul>";
			$("#boardRank").html(str);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/selectCommunityBoardRankInfo.do", response, status, error); 
		}
	}); 
	
}

function setUserVisitRank(){
	var str = "";
	$.ajax({
		url:"/groupware/layout/userCommunity/selectCommunityVisitRankInfo.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (vr) {
			$("#visitRank").html("");
			str = "<h3 class='cycleTitle'>"+"<spring:message code='Cache.lbl_CommunityVisitsNo'/>"+"</h3>";
			str += "<ul class='mt20 commRankingListCont'>";
			if(vr.list.length > 0){
				$(vr.list).each(function(i,v){
					if(v.num == '1'){
						str += "<li class='one'>";
					}else if(v.num == '2'){
						str += "<li class='two'>";
					}else if(v.num == '3'){
						str += "<li class='three'>";
					}else{
						str += "<li>";
					}
					str += "<div><p>"+v.num+"</p></div>";
					str += "<div class='personBox individualPersonBox'>";
					str += "<div class='perPhoto'>";
					str += "<img name='bizCardThumbnail' style='width: auto; height: 100%;' src='"+ coviCmn.loadImage(v.PhotoPath) +"' onerror='coviCmn.imgError(this, true);' alt=''>";
					str += "</div>";
					str += "<div class='name'>";
					str += "<div class='btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='position:relative;cursor:pointer' data-user-code='"+ v.UserCode +"' data-user-mail=''>"+v.opName+"</div>";
					str += "</div></div>";
					str += "<div><p>"+v.VisitCount+"<spring:message code='Cache.lbl_Point'/>"+"</p></div>";
					str += "</li>";
				});
			}
			str += "</ul>"; 
			$("#visitRank").html(str)
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/selectCommunityVisitRankInfo.do", response, status, error); 
		}
	}); 
}

function setCallMember(){
	var str = "";
	$.ajax({
		url:"/groupware/layout/userCommunity/selectCommunityCallMember.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID,
			searchWord : $("#callMemberSearchInput").val()
		},
		success:function (cm) {
			$("#callMember").html("");
			if(cm.list.length > 0){
				$(cm.list).each(function(i,v){
					str += "<li>";
					str += "<div class='chkStyle04 chkType01 '>";
					str += "<input type='checkbox' id='allSV"+v.UR_Code+"' key='"+v.UR_Code+"' name='allSV'>";
					str += "<label for='allSV"+v.UR_Code+"'>";
					str += "<span></span>"+v.opName;
					str += "</label>";
					str += "</div>";
					str += "</li>";
				});
			}
			$("#callMember").html(str);
			
			coviCtrl.bindmScrollV($('.mScrollV'));
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/selectCommunityCallMember.do", response, status, error); 
		}
	}); 
}

function sendMessage(){
	if(Common.getBaseConfig("isUseExchMail") == 'Y' && Common.getBaseConfig("isUseMail") == 'Y'){
		// 전송 데이터 세팅
		MailJsonData = {
		  "Token": GetEncryptToken(), // 인증용 JWT 토큰
		  "Subject": "", // 메일 제목
		  "Body": "", // 메일 본문
		  "To": [], // 받는 사람
		  "Cc": [], // 참조
		  "Bcc": [], // 숨은 참조
		  "Attachment": [] // 첨부 파일
		};
  	
		exch_mailSend(MailJsonData);
	} else {
		var str = "";
		
		var sendUserArr = checkMsgMember();
		
		var sendMail = "";
		var sendTodo = "";
		
		if($("input:checkbox[id='eeeeee1']").is(":checked")){
			sendMail = 'Y';
		}else{
			sendMail = 'N';
		}
		
		if($("input:checkbox[id='eeeeee2']").is(":checked")){
			sendTodo = 'Y';
		}else{
			sendTodo = 'N';
		}
		
		if(sendUserArr == "" || sendUserArr == null){
			Common.Warning("<spring:message code='Cache.msg_memberContact'/>"); //연락할 회원을 선택하세요.
			return ;	
		}
		
		if(sendMail == "N" && sendTodo == "N"){
			Common.Warning("<spring:message code='Cache.msg_methodContact'/>"); //연락할 방법을 선택하세요.
			return ;	
		}
		
		if($("#sendMessageTxt").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_messageCheck'/>"); //메세지를 입력하세요.
			return ;	
		}
		
		$.ajax({
			url:"/groupware/layout/userCommunity/CommunityCallMemberSendMessage.do",
			type:"POST",
			async:false,
			data:{
				CU_ID : cID,
				sendMail : sendMail,
				sendTodo : sendTodo,
				sendUserArr : sendUserArr,
				sendMessageTxt : $("#sendMessageTxt").val()
			},
			success:function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_insert'/>"); //등록되었습니다.
					goReset();
				}else{ 
					Common.Error("<spring:message code='Cache.msg_38'/>"); //오류로 인해 저장 하지 못 하였습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/layout/userCommunity/CommunityCallMemberSendMessage.do", response, status, error); 
			}
		}); 
	}
}

function checkMsgMember(){
	var str = "";
	$("input:checkbox[name='allSV']:checked").each(function() { 
	   	if($(this).attr("key") != null && $(this).attr("key") != ''){
	   		str += $(this).attr("key")+";"; 
	   	}
	});
	  
	str = str.slice(0,-1);
	  
	return str;
}

function goReset(){
	$("input[name='allSV']").prop('checked', false) ;
	$("#callMemberSearchInput").val("");
	$("#sendMessageTxt").val("");
	$("input[id='eeeeee1']").prop('checked', false) ;
	$("input[id='eeeeee2']").prop('checked', false) ;
}
</script>