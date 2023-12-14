<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer " id="testpopup_p" style="width:358px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02 boardReadingRightPop ">
			<div>				
				<div class="top">			
					<a href="#" class="btnAddPerson" onclick="javascript:OrgMapLayerPopup_readAuth()"><spring:message code="Cache.btn_apv_DirectWrite"/></a>
					<a href="#" class="btnRemoveAll btnTypeX btnTypeDefault" onclick="javascript:initAclSetting();"><spring:message code="Cache.btn_DelAll"/></a>
				</div>
				<div class="middle">
					<div class="addSurveyTarget">
						<ul id="ulReadAuth" class="clearFloat">
						</ul>
					</div>
				</div>
				<div class="bottom">
					<div class="popBottom">
						<a href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:confirmAclSetting();"><spring:message code="Cache.btn_Confirm"/></a>
						<a href="#" class="btnTypeDefault" onclick="javascript:btnClose_Click();"><spring:message code="Cache.btn_Cancel"/></a>
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>

<script>
	var folderID = CFN_GetQueryString("folderID");
	var messageID = CFN_GetQueryString("messageID");
	var UseMessageReadAuth = null;		//팝업을 호출한 페이지의 Element참조용
	var messageReadAuth = null;			//messageReadAuth 값은 작성 페이지 접근시 UseMessageReadAuth가 Y일경우 조회하도록 구현
	
	$(document).ready(function () {
		//팝업 모드 별 parent, opener Element참조용...개선여부 확인
		if(parent != null && parent.$("#UseMessageReadAuth").val() != undefined && parent.$("#messageReadAuth").val() != undefined) {
			UseMessageReadAuth = parent.$("#UseMessageReadAuth");
			messageReadAuth = parent.$("#messageReadAuth");
		} else {
			UseMessageReadAuth = opener.$("#UseMessageReadAuth");
			messageReadAuth = opener.$("#messageReadAuth");
		}
		renderReadAuth();
	});
	
	function OrgMapLayerPopup_readAuth(){
		CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=readAuthAdd_CallBack&type=D9","<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
	}
	
	function readAuthAdd_CallBack(orgData){
		var readAuthJSON =  $.parseJSON(orgData);
		var sCode = "";
		var sDisplayName = "";
		var sObjectType_A = "";
		var sHTML = "";
		var step = $("[name=readAuth]").length;
		
		$(readAuthJSON.item).each(function (i, item) {
			sObjectType = item.itemType
	  		if(sObjectType.toUpperCase() == "USER"){ //사용자
	  			sObjectTypeText = "사용자"; // 사용자
	  			sObjectType_A = "UR";
	  			sCode = item.UserCode;//UR_Code
	  			sDisplayName = CFN_GetDicInfo(item.DN);
	  			sDNCode = item.DN_Code; //DN_Code
	  		}else{ //그룹
	  			switch(item.GroupType.toUpperCase()){
		  			 case "COMPANY":
		                 sObjectTypeText = "회사"; // 회사
		                 sObjectType_A = "CM";
		                 break;
		             case "JOBLEVEL":
		                 sObjectTypeText = "직급";
		                 sObjectType_A = "JL";
		                 break;
		             case "JOBPOSITION":
		                 sObjectTypeText = "직위";
		                 sObjectType_A = "JP";
		                 break;
		             case "JOBTITLE":
		                 sObjectTypeText = "직책";
		                 sObjectType_A = "JT";
		                 break;
		             case "MANAGE":
		                 sObjectTypeText = "관리";
		                 sObjectType_A = "MN";
		                 break;
		             case "OFFICER":
		                 sObjectTypeText = "임원";
		                 sObjectType_A = "OF";
		                 break;
		             case "DEPT":
		                 sObjectTypeText = "부서"; // 그룹
		                 sObjectType_A = "GR";
		                 break;
	         	}
	  			sCode = item.AN
	            sDisplayName = CFN_GetDicInfo(item.GroupName);
	            sDNCode = item.DN_Code;
	  		}
			bCheck = false;

			$("[name=readAuth]").each(function () {
	             if (($(this).attr("type").toUpperCase() == sObjectType_A) &&
	                 ($(this).attr("code") == sCode)) {
	                 bCheck = true;
	             }
	        });

			if (!bCheck) {
				sHTML += String.format("<li><div class='topbar_grid' style='display:inline-block;' id='readAuth_{0}' name='readAuth' code='{1}' type='{2}'>", step, sCode, sObjectType_A );
				sHTML += String.format("{0}<a href='#' class='btnRemove' onclick='javascript:deleteNode(this)'/></div></li>", sDisplayName);
			}
			step++;
	 	});

		$('#ulReadAuth').append(sHTML);
	}

	//상위의 $("#messageReadAuth").val() 참조 
	function renderReadAuth(){
		if(messageReadAuth.val() != ""){
			var sHTML = "";
			var readAuth = messageReadAuth.val().split(";");	// code|type|name;code|type|name;...
			
			for(var step = 0; step < readAuth.length; step++){
				var authShard = readAuth[step].split("|");	//code|type|name
				
				sHTML += String.format("<li><div class='topbar_grid' style='display:inline-block;' id='readAuth_{0}' name='readAuth' code='{1}' type='{2}'>", step, authShard[0], authShard[1] );
				sHTML += String.format("{0}<a href='#' class='btnRemove' onclick='javascript:deleteNode(this)'/></div></li>", authShard[2]);
			}
			$('#ulReadAuth').append(sHTML);
		}
	}

	
	//승인자 삭제 
	function deleteNode( pObj ){
		//span 엘리먼트 삭제
		$(pObj).parent().remove();
	}
	
	//하단의 닫기 버튼 함수
	function btnClose_Click(){
		Common.Close();
	}

	function initAclSetting(){
		$('#ulReadAuth').html("");
	}
	
	function confirmAclSetting(){
		if($("[name=readAuth]").length > 0){
			var readAuthData = "";
			
			//열람권한을 사용하도록 설정 하며 권한 설정정보를 BoardWrite.jsp에 있는 messageReadAuth에 저장
			UseMessageReadAuth.val("Y");
			
			$("[name=readAuth]").each(function(i, item){ 
				readAuthData += String.format("{0}|{1}|{2};",$(this).attr("code"), $(this).attr("type"), $(this).text());
			});
			
			readAuthData = readAuthData.substring(0, readAuthData.length-1);
			messageReadAuth.val(readAuthData);
		} else {
			//열람권한을 사용하는 게시판이긴 하지만 별도 설정을 하지 않으면 열람권한을 사용하지 않는 것으로 설정
			UseMessageReadAuth.val("");
			messageReadAuth.val("");
		}

		Common.Close();
	}
</script>
