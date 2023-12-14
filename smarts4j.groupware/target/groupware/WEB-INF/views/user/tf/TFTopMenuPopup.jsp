<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style type="text/css">
.chkStyle04.chkType01 input[type="checkbox"]:checked + label span:first-child {
	border: 0px;
}
</style>
<div class="popContent layerType02 communityPopContent">
	<input type="hidden" id ="C" value = "${C}"/>
	<div class="communityUDMenuCont">				
		<div class="top">
			<a href="#" class="btnPosUp" onclick="mSortC('T');"><span><spring:message code='Cache.btn_UP'/></span></a>
			<a href="#" class="btnPosDown ml5" onclick="mSortC('B');"><span><spring:message code='Cache.btn_Down'/></span></a>
			<!-- <a href="#" class="btnPosChange ml5"><span>변경</span></a> -->
		</div>
		<div class="middle mt10">
			<h2><spring:message code='Cache.lbl_topMenu'/></h2>
			<div class="communityPosUDListCont">
				<ul id = 'chkTopMenu'>
					<li>
						<div class="radioStyle04 inpBtnStyle">
							<label><span style="border: 0px;"><span></span></span>Home</label>
						</div>
					</li>
					<li>
						<div class="radioStyle04 inpBtnStyle">
							<label><span style="border: 0px;"><span></span></span><spring:message code='Cache.MN_108'/></label>
						</div>
					</li>
				</ul>
			</div>
		</div>
		<div class="bottom mt20">
			<div class="popBottom">
				<!-- <a href="#" class="btnTypeDefault btnTypeBg">확인</a> -->
				<a href="#" onclick="Common.Close();" class="btnTypeDefault"><spring:message code='Cache.btn_Close'/></a>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">

$(document).ready(function(){	
	selTopMenu();
});

function selTopMenu(){
	$("li[name='cTM']").remove();
	
	var strHtml = "";
	
	$.ajax({
		url:"/groupware/layout/userCommunity/communityTopMenu.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : $("#C").val()
		},
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					strHtml += "<li name='cTM'>";
					strHtml += "<div class='radioStyle04 inpBtnStyle'>";
					strHtml += "<input type='radio' id='rd"+v.Idx+"' rkey='"+v.Idx+"' name='rdAll'>";
					
					if(v.FolderType == "Schedule"){
						strHtml += "<label for='rd"+v.Idx+"'><span><span></span></span>"+"일정"+"</label>";
					}else{
						strHtml += "<label for='rd"+v.Idx+"'><span><span></span></span>"+v.DisplayName+"</label>";
					}
					
					if(v.UseYn == "N"){
						strHtml += "<a href='#' class='onOffBtn' id='isRead_"+v.Idx+"' onclick='updateIsCheck(\""+v.Idx+"\");'><span></span></a>";
					}else{
						strHtml += "<a href='#' class='onOffBtn on' id='isRead_"+v.Idx+"' onclick='updateIsCheck(\""+v.Idx+"\");'><span></span></a>";
					}
					strHtml += "</div></li>";
				});
			}
			
			$("#chkTopMenu").append(strHtml);
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityTopMenu.do", response, status, error); 
		}
	}); 
}

function updateIsCheck(id){
	var isCheckValue = "";
	if($("#isRead_"+id).hasClass("on")){
		isCheckValue = "N";
	}else{
		isCheckValue = "Y";
	}
	
	$.ajax({
		type:"POST",
		data:{
			"id" : id,
			"isCheck" : isCheckValue
		},
		url:"/groupware/layout/userCommunity/updateCommunityTopMenuUse.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				if(isCheckValue == "N"){
					$("#isRead_"+id).removeClass("on");
				}else{
					$("#isRead_"+id).addClass("on");
				}
				
				if(opener){
					opener.inCommMenu();
				}else{
					parent.inCommMenu();				
				}

				alert("<spring:message code='Cache.msg_Changed'/>");	
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/updateCommunityTopMenuUse.do", response, status, error);
		}
	});
}

function mSortC(mode){
	var str = "";
	str = topMenuCheck();
	
	$.ajax({
		type:"POST",
		data:{
			"id" : str,
			"mode" : mode,
			"CU_ID" : $("#C").val()
		},
		url:"/groupware/layout/userCommunity/updateCommunityTopMenuSort.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				alert("<spring:message code='Cache.msg_Edited'/>");
				selTopMenu();
				
				if(opener){
					opener.inCommMenu();
				}else{
					parent.inCommMenu();				
				}

			}else{
				alert("<spring:message code='Cache.msg_changeFail'/>");
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/updateCommunityTopMenuSort.do", response, status, error);
		}
	});	
}

function topMenuCheck(){
	var str = "";
	
	$("input:radio[name='rdAll']").each(function(){
		if($(this).is(":checked")){
			str = $(this).attr("rkey");
		}
	});
	
	return str;
}

</script>
