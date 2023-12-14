<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CommunityUserInclude.jsp"></jsp:include>

<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" /> 

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
	
	if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
		$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
		$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
	}
	else {
		$("#cCss, #cthemeCss").remove();
	}
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
					strHtml += "<input type='radio' id='rd"+v.Idx+"' rkey='"+v.Idx+"' value='"+v.SortKey+"' name='rdAll'>";
					
					if(v.FolderType == "Schedule"){
						strHtml += "<label for='rd"+v.Idx+"'><span><span></span></span><spring:message code='Cache.lbl_Schedule'/></label>"; // 일정
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
			"CU_ID" : $("#C").val(),
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

				Common.Inform("<spring:message code='Cache.msg_Changed'/>");	 //변경되었습니다
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/updateCommunityTopMenuUse.do", response, status, error);
		}
	});
}

function mSortC(mode){
	var nIdx = "";
	var cIdx = "";
	var nSortKey = "";
	var cSortKey = "";
	
	if($("input:radio[name='rdAll']:checked").length <= 0){
		Common.Warning("<spring:message code='Cache.msg_Common_09'/>");      // 이동할 항목을 선택하여 주십시오.
		return;
	}
	
	var index = $("input:radio[name='rdAll']").index($("input:radio[name='rdAll']:checked"));
	nIdx = $("input:radio[name='rdAll']:checked").attr("rkey");
	nSortKey = $("input:radio[name='rdAll']:checked").val();
	
	if(mode == "T"){
		if($("input:radio[name='rdAll']:first").attr("rkey") == $("input:radio[name='rdAll']:checked").attr("rkey")){
			Common.Warning("<spring:message code='Cache.msg_cannotRaise'/>"); // 더이상 위로 올릴 수 없습니다.
			return false;
		}else{
			cIdx = $("input:radio[name='rdAll']").eq(index - 1).attr("rkey");
			cSortKey = $("input:radio[name='rdAll']").eq(index - 1).val();
		}
	}else if(mode == "B"){
		if($("input:radio[name='rdAll']:last").attr("rkey") == $("input:radio[name='rdAll']:checked").attr("rkey")){
			Common.Warning("<spring:message code='Cache.msg_cannotLower'/>"); // 더이상 아래로 내릴 수 없습니다.
			return false;
		}else{
			cIdx = $("input:radio[name='rdAll']").eq(index + 1).attr("rkey");
			cSortKey = $("input:radio[name='rdAll']").eq(index + 1).val();
		}
	}
	
	$.ajax({
		type:"POST",
		data:{
			"nIdx": nIdx,
			"cIdx": cIdx,
			"nSortKey": nSortKey,
			"cSortKey": cSortKey,
			"CU_ID" : $("#C").val()
		},
		url:"/groupware/layout/userCommunity/updateCommunityTopMenuSort.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_Edited'/>"); //수정되었습니다
				selTopMenu();
				
				if(opener){
					opener.inCommMenu();
				}else{
					parent.inCommMenu();				
				}

			}else{
				Common.Error("<spring:message code='Cache.msg_changeFail'/>"); //변경에 실패하였습니다.
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/updateCommunityTopMenuSort.do", response, status, error);
		}
	});	
}

</script>
