<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer " id="testpopup_p" style="width:358px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
<!-- 			<div class="pop_header" id="testpopup_ph"> -->
<!-- 				<h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">열람권한 설정</span></h4><a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a> -->
<!-- 			</div> -->
		<div class="popContent layerType02 boardReadingRightPop ">
			<div>				
				<div class="top">			
					<a href="#" class="btnAddPerson" onclick="javascript:OrgMapLayerPopup()"><spring:message code="Cache.btn_apv_DirectWrite"/></a>
				</div>
				<div class="middle">
					<div class="addSurveyTarget">
						<ul id="ulDistibuteTarget" class="clearFloat">
						</ul>
					</div>
				</div>
				
				<div class="bottom">
					<div class="popTop">
						<p id="spnCommentInfo"><spring:message code='Cache.msg_reasonDistribution'/></p>	<!-- 배포 사유를 입력해주세요. -->
						<textarea id="txtComment" class="HtmlCheckXSS ScriptCheckXSS" style="width:310px; height:100px; "></textarea>
					</div>
					<div class="popBottom">
						<a href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:confirmSetting();"><spring:message code="Cache.btn_Confirm"/></a>	<!-- 확인 -->
						<a href="#" class="btnTypeDefault" onclick="javascript:initSetting();"><spring:message code='Cache.btn_DelAll'/></a>	<!-- 전체삭제 -->
						<a href="#" class="btnTypeDefault" onclick="javascript:btnClose_Click();"><spring:message code="Cache.btn_Cancel"/></a>	<!-- 취소 -->
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>

<script>
	var messageID = CFN_GetQueryString("messageID");
	var version = CFN_GetQueryString("version");
	
	function OrgMapLayerPopup(){
		CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=targetAdd_CallBack&type=D9","<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
		//Common.open("","orgmap_pop","조직도","/covicore/control/goOrgChart.do?callBackFunc=targetAdd_CallBack&type=D9&openerID=distributeDocPopup","1060px","580px","iframe",true,null,null,true);
		//CFN_OpenWindow("/covicore/cmmn/orgmap.do?functionName=targetAdd_CallBack","<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
	}
	
	function targetAdd_CallBack(orgData){
		var targetJSON =  $.parseJSON(orgData);
		var sCode = "";
		var sDisplayName = "";
		var sObjectType_A = "";
		var sHTML = "";
		var step = $("[name=readAuth]").length;
		var lang = Common.getSession("lang");
		
		$(targetJSON.item).each(function (i, item) {
			sObjectType = item.itemType
	  		if(sObjectType.toUpperCase() == "USER"){ //사용자
	  			sObjectTypeText = "사용자"; // 사용자
	  			sObjectType_A = "UR";
	  			sCode = item.AN;//UR_Code
	  			sDisplayName  = CFN_GetDicInfo(item.DN, lang);
	  			sDNCode = item.ETID;; //DN_Code
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

			$("[name=target]").children().each(function () {
	             if (($(this).attr("type").toUpperCase() == sObjectType.toUpperCase()) &&
	                 ($(this).attr("code") == sCode)) {
	                 bCheck = true;
	             }
	        });

			if (!bCheck) {
				sHTML += String.format("<li><div id='target_{0}' name='target' code='{1}' type='{2}'>", step, sCode, sObjectType_A );
				sHTML += String.format("{0}<a href='#' class='btnRemove' onclick='javascript:deleteNode(this)'/></div></li>", sDisplayName);
			}
			step++;
	 	});

		$('#ulDistibuteTarget').append(sHTML);
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

	function initSetting(){
		$('#ulDistibuteTarget').html("");
	}

	function getACLData(){
		var aclArray = [];
		
		//subject 추출
		$('#ulDistibuteTarget div').each(function () {
	        var ACL = new Object();
	        ACL.TargetType = $(this).attr("type");
	    	ACL.TargetCode = $(this).attr("code");
	    	aclArray.push(ACL);
	    });
	    
		return JSON.stringify(aclArray);
	}
	
	function confirmSetting(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		$.ajax({
	    	type:"POST",
	    	url: "/groupware/board/distributeDoc.do",
	    	data: {
		    	'messageID' : messageID
		    	,'version'	: version
		    	,'targetList' : getACLData()
		    	,'comment'	: $('#txtComment').val()
		    },
	    	dataType : 'json',
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
		    			Common.Close();
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
	    		}
	    	}, 
	  		error:function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	  		}
	    });
	}
</script>
