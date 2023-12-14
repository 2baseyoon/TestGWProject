<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_apv_Regisign'/></h2><!-- 서명등록 -->
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="apprvalBottomCont">
			<!-- 본문 시작 -->
			<div class="bodyMenu">
				<div class="AXTabsLarge mb15">
					<div class="AXTabsTray" id="subMenuDiv">
						<a id="subMenuDiv_RightApvConfig" name="RightApprovalConfigForm" onclick="CoviMenu_GetContent('/approval/layout/approval_RightApprovalConfig.do?CLSYS=approval&CLMD=user&CLBIZ=Approval');" class="AXTab" style="display: none;"><spring:message code='Cache.lbl_apv_ApprovalbaseInfo'/></a>
						<a id="subMenuDiv_ApvSignReg" name="SignRegistrationForm" onclick="CoviMenu_GetContent('/approval/layout/approval_SignRegistration.do?CLSYS=approval&CLMD=user&CLBIZ=Approval');" class="AXTab on" style="display: none;"><spring:message code='Cache.lbl_apv_Regisign'/></a>
					</div>
				</div>
				<form id="SignRegistrationForm" name="SignRegistrationForm" style="display: none;">
					<!-- 탭메뉴 끝 -->
					<div id="signListDiv">
					</div>
				</form>
			</div>
			<!-- 본문 끝 -->
		</div>
	</div>
</div>
<script>
	var sessionObj = null; //전체호출
	initContent();

	function initContent(){
		setSubMenu();
		sessionObj = Common.getSession(); //전체호출
		gridDataBind();
	}

	function setSubMenu(){
		$("#subMenuDiv").find("a[id^='subMenuDiv']").each(function(i, obj) {
			if(Common.getBaseConfig("use" + $(obj).attr("id").split("_")[1]) == "Y") {
				$(obj).show();
				$("form[id='" + $(obj).attr("name") + "']").show();
			}
		});
	}

	// 새로고침
	function refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}

	//그리드에 담당자 데이터 바인딩
	function gridDataBind(){
		$.ajax({
			url:"/approval/user/getUserSignList.do",
			type:"post",
			async:false,
			success:function (data) {
				$("#signListDiv").empty();
				var html = "";
				var strBackStoragePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")); // 이전 서명 표시를 위해서만 사용, 신규 데이터는 무관
				var src;
				$(data.list).each(function(index){
					html = "<div class=\"signWrap\">"
				        + "  <a class=\"signDel\" onclick='deleteSign(\""+this.SignID+"\", \""+this.IsUse+"\")'><spring:message code='Cache.lbl_delete'/></a>"; //삭제
			        if(this.IsUse == "Y"){ //대표이미지인경우
			        	html += "  <div class=\"stand\"><spring:message code='Cache.lbl_RepresentativeImage'/></div>";
			        	 
			        }
			        html += "       <ul class=\"signBox\">"
				         + "       	  <li><spring:message code='Cache.lbl_apv_setschema_114'/></li>";
				         
				    src = "";
				    if(this.FileID && this.FileID > 0){
				    	src = coviCmn.loadImageId(this.FileID,"ApprovalSign");
				    } else if(this.FilePath.indexOf(strBackStoragePath) > -1){
				    	src = coviCmn.loadImage(this.FilePath);
				    } else {
				    	src = coviCmn.loadImage(strBackStoragePath+this.FilePath);
				    }
				    	 
				    html += "       	  <li class=\"sigFill\"><a onclick='openSignRegistrationUpdtPopup(\""+this.SignID+"\")'><img style='max-width: 100%;height: auto;' src='"+src+"' alt=\"\" onerror='coviCmn.imgError(this)'></a></li>";	 
				        	 
				    html += "		  <li>" + setUserFlowerName(sessionObj["UR_Code"], sessionObj["USERNAME"]) + "</li>"
				         + "		  <li>"+getStringDateToString("yyyy.MM.dd HH:mm:ss",this.InsertDate)+"</li>"
				         + "       </ul>"
				         + "</div>";
				   $("#signListDiv").append(html);
				});
				html = "<div class=\"signAdd\"><a onclick='openSignRegistrationPopup()'><spring:message code="Cache.lbl_Additional"/></a></div>" //추가
				$("#signListDiv").append(html);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getUserSignList.do", response, status, error);
			}
		});
	}

	//서명 삭제
	function deleteSign(signID, isUse){
		//다국어: 해당 서명을 삭제하시겠습니까? ,서명등록

		var usercode = Common.getSession("UR_Code");
				
		Common.Confirm("<spring:message code='Cache.msg_apv_393'/>","<spring:message code='Cache.lbl_apv_Regisign'/>",function(result){
			if(result==true){
				$.ajax({
					type:"POST",
					data:{
						"SignID" : signID,
						"isUse" : isUse,
						"UserCode" : usercode
					},
					url:"/approval/user/deleteUserSign.do",
					success:function (data) {
						if(data.result == "ok"){
							refresh();
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/user/deleteUserSign.do", response, status, error);
					}
				});
			}
		});

	}

	//서명 사용여부 변경
	function changeSignUse(signID){
		$.ajax({
			type:"POST",
			data:{
				"SignID" : signID
			},
			url:"/approval/user/changeUserSignUse.do",
			success:function(data){
				if(data.result=="ok"){
					refresh();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/changeUserSignUse.do", response, status, error);
			}
		});

		refresh();
	}

	//서명등록 팝업 표시
	function openSignRegistrationPopup(){
		//다국어: 서명등록
		objPopup = parent.Common.open("","signRegistrationPopup","<spring:message code='Cache.lbl_apv_Regisign'/>","/approval/user/goSignRegistrationPopup.do?&mode=inst","600","327","iframe",true,null,null,true);
	}

	//서명수정 팝업 표시
	function openSignRegistrationUpdtPopup(signID){
		//다국어: 서명등록
		objPopup = parent.Common.open("","signRegistrationPopup","<spring:message code='Cache.lbl_apv_Regisign'/>","/approval/user/goSignRegistrationPopup.do?&mode=updt&signID="+signID+"","600","327","iframe",true,null,null,true);
	}
</script>