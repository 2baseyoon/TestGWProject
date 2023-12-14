<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	
	<div class="layer_divpop ui-draggable schPopLayer" id="testpopup_p" style="width:420px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="themePopUp">
					<div id="themeList" class="top"></div>
					<div class="bottom">
						<a onclick="goThemeOne();" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_Add' /></a><a onclick="deleteTheme();" class="btnTypeDefault"><spring:message code='Cache.btn_delete' /></a><!-- 추가 --><!-- 삭제 -->
					</div>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
initContent();

function initContent(){
	getThemeList();
}

// 테마일정 리스트 조회
function getThemeList(){
	$.ajax({
		url: "/groupware/schedule/getThemeList.do",
		type: "POST",
		data: {},
		success: function(res){
			if(res.status == "SUCCESS"){
				var themeListHtml ="";
				var disabled = "";
				var userCode = Common.getSession("UR_Code");
				
				$(res.list).each(function(i){
					disabled = this.OwnerCode === userCode ? "" : "disabled";
					
					themeListHtml += '<div class="chkStyle04 chkType01" id="'+this.FolderID+'">';
					themeListHtml += '<input type="checkbox" id="allSV'+i+'" name="allSV" '+disabled+'><label for="allSV'+i+'"><span></span></label>';
					themeListHtml += '<span onclick="goThemeOne('+this.FolderID+')" style="cursor: pointer;"><span class="nemobox" style="background-color:'+this.Color+'"></span>'+this.MultiDisplayName+'</span>';
					themeListHtml += '</div>';
				});
				$("#themeList").html(themeListHtml);
			} else {
				Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/schedule/getThemeList.do", response, status, error);
		}
	});
}

// 테마 일정 추가 및 하나 보기
function goThemeOne(folderID){
	var paramStr = "";
	
	if(folderID != undefined)
		paramStr = "?folderID="+folderID;
	
	parent._CallBackMethod2 = getThemeList;
	parent.Common.open("","themeOne_Popup","<spring:message code='Cache.lbl_schedule_themeMng' />","/groupware/schedule/goThemeOne.do"+paramStr,"720px","330px","iframe",true,null,null,true);		//테마일정관리
}


// 삭제
function deleteTheme(){
	var folderIDs = ";";
	
	$("[id^=allSV]").each(function(){
		if($(this).is(":checked"))
			folderIDs += $(this).parent().attr("id") + ";";
	});
	
	if(folderIDs !=";"){
		$.ajax({
		    url: "/groupware/schedule/removeTheme.do",
		    type: "POST",
		    data: {
		    	"FolderIDs" : folderIDs
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	Common.Inform("<spring:message code='Cache.msg_deleteSuccess'/>", "", function(){			//성공적으로 삭제하였습니다.
			    		getThemeList();
			    		parent.setLeftMenu();
			    	});
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/removeTheme.do", response, status, error);
			}
		});
	}else{
		Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>"); //삭제할 항목을 선택하여 주십시오
	}
}
</script>
