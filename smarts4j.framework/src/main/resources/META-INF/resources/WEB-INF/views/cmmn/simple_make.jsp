<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="java.util.Arrays,egovframework.baseframework.util.StringUtil,egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.ComUtils" %>
<div>
	<div class="topHead">
		<ul class="tabMenuArrow  clearFloat">
			<%if (ComUtils.getAssignedBizSection("Mail")){ %><li class="active" type="Mail"><a><spring:message code='Cache.lbl_MAIL'/></a></li><%} %>
			<%if (ComUtils.getAssignedBizSection("Approval")){ %><li class="" type="Approval"><a><spring:message code='Cache.lbl_apv_app'/></a></li><%} %>
			<%if (ComUtils.getAssignedBizSection("Schedule")){ %><li class="" type="Schedule"><a><spring:message code='Cache.lbl_Schedule'/></a></li><%} %>
			<%if (ComUtils.getAssignedBizSection("Resource")){ %><li class="" type="Resource"><a><spring:message code='Cache.lbl_Reservation'/></a></li><%} %>
			<%if (ComUtils.getAssignedBizSection("Board")){ %><li class="" type="Board"><a><spring:message code='Cache.lbl_Post'/></a></li><%} %>
		</ul>
		<a class="btnOrderContClose">닫기</a>
	</div>
	<div class="middleCont">
		<div id="mailSimpleMake" class="tabContentArrow">							
			<div class="simpleContent simpleContMail">
				<div class="inputBoxSytel01 type02">
					<div><span><spring:message code='Cache.lbl_Mail_To'/></span></div>
					<div>
						<div class="autoCompleteCustom">
							<input id="myAutocompleteMultiple" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 60px)" autocomplete="off">
							<a class="btnTypeDefault" onclick="javascript:OrgMapLayerPopup_sendMail();return false;"><spring:message code='Cache.lbl_DeptOrgMap'/></a>
						</div>
					</div>
				</div>
				<div class="inputBoxSytel01 type02">
					<div><span><spring:message code='Cache.lbl_Title'/></span></div>
					<div>
						<input id="mailSubject" type="text" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</div>
				<div>
					<textarea id="mailBodyText" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
				</div>
			</div>
			<div class="bottomCont">
				<a id="btnDetailSendMail" style="display:none" class="btnTypeDefault btnThemeLine"><spring:message code='Cache.btn_WriteDetail'/></a>
				<a id="btnSendMail" class="btnTypeDefault btnTypeBg ml5"><spring:message code='Cache.btn_Mail_Send'/></a>
			</div>
			<input type="hidden" id="checkMailChange" value="false">
		</div>
		<script>
			var isLoad = new Object();
			isLoad["All"] = false;
			isLoad["Mail"] = false;
			isLoad["Approval"] = false;
			isLoad["Schedule"] = false;
			isLoad["Resource"] = false;
			isLoad["Board"] = false;
			
			function initSimpleMake(moduleName){
				if(moduleName == "Mail" && isLoad["Mail"] == false){
					coviCtrl.setUserMailAddressWithDeptAutoTags('myAutocompleteMultiple', '/covicore/control/getAllUserAutoTagList.do', {
						labelKey : 'UserName',
						addInfoKey: "DeptName",
						valueKey : 'UserCode',
						minLength : 1,
						useEnter : false,
						multiselect : true,
					});
					
					$("#mailSimpleMake input, #mailSimpleMake textarea").on("change",function(){
						$("#checkMailChange").val("true");
					});
					
					$('#btnSendMail').on('click', function(){
						mailValidation();
					});
					
					//CP 메일 사용할 경우에만 표시
					if(Common.getBaseConfig("isUseMail") == "Y"){ //Common.getExtensionProperties("isUse.mail")
						$('#btnDetailSendMail').show().on('click', function(){
							/* var receiverArr = new Array();
							//subject 추출
							$('#mailSimpleMake .ui-autocomplete-multiselect-item').each(function () {
						         var uJson = $.parseJSON($(this).attr("data-json"));
						     	 var address = '';
						     	address += (uJson.UserName + "+");
						     	address += ( (uJson.MailAddress != undefined && uJson.MailAddress != '' ) ? ("<" + uJson.MailAddress + ">" ) : '');
						         receiverArr.push(address);
						    }); */
							
							if(sessionStorage.getItem(Common.getSession("DN_Code")+"_"+Common.getSession("USERID")) == null){
								var index = 0;
								var userMail = Common.getSession("UR_Mail");
								var isSendMail = "Y";
								var isMailDomainCode = Common.getSession("DN_Code");
								var isMailUserCode = Common.getSession("USERID");
								var mailDeptCode = Common.getSession("DEPTID");
								var data = sessionStorage.getItem(isMailDomainCode+"_"+isMailUserCode) == null ? {} : JSON.parse(sessionStorage.getItem(isMailDomainCode+"_"+isMailUserCode));
								
								if(sessionStorage.getItem(isMailDomainCode+"_"+isMailUserCode) == null){
									var isLayouTypeStr = "MAILLIST";
									
									data.isLayoutType = isLayouTypeStr;	//목록 레이아웃	
									data.isSortType = "";	//목록 정렬
									data.isViewType = "";	//목록 시간,대화형
									data.isViewNum = "10";
									data.isCurrentPage = "1";
									data.initYn = "Y";
								}
								
								//메일작성 새창에서 사용
								data.ismailuserid = Common.getSession("USERID");
								data.ismailuserNm = Common.getSession("UR_Name");
								//sessionStorage에 값 저장
								data.userMail = userMail;
								data.isSendMail = isSendMail;
								data.isMailDomainCode = isMailDomainCode;
								data.isMailUserCode = isMailUserCode;
								data.isMailDeptCode =  mailDeptCode;
								
								sessionStorage.setItem(isMailDomainCode+"_"+isMailUserCode, JSON.stringify(data));
								
								//페이지가 새로고침되어 userId를 담아둔 태그가 초기화되어 임시로 담아둔 후 태그에 담고 삭제한다.
								sessionStorage.setItem("tempMailUserCode", isMailDomainCode+"_"+isMailUserCode);
							}
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
						    	_query = "/mail/userMail/goMailWindowWritePopup.do?";
								_queryParam = {
									userMail: Common.getSession("UR_Mail"),
									inputUserId: Common.getSession("DN_Code")+"_"+Common.getSession("USERID"),
									popup: "Y",
									callMenu: "SimpleMailSend"
								};
								_query += $(_queryParam).serializeQuery();
						 		window.open(_query, "Mail Write"+stringGen(10), "height=700, width=1000");
						    }
						});
					}
					
					isLoad["Mail"] = true;
					
				}else if(moduleName == "Approval" && isLoad["Approval"]  == false ){
					setFavoriteApproval();
					setLastDraftApproval();
					
					isLoad["Approval"]  = true;
				}else if(moduleName == "Schedule" && isLoad["Schedule"]  == false ){
					setSimpleMakeAclEventFolderData();
					setFolderTypeSchedule();
					setDateConSchedule();
					
					isLoad["Schedule"] = true;
				}else if(moduleName == "Resource" && isLoad["Resource"]  == false ){
					setDateConResource();
					
					isLoad["Resource"] = true;
				}else if(moduleName == "Board" && isLoad["Board"]  == false ){
					$('#boardFolderID').coviCtrl("setSelectOption","/groupware/board/selectSimpleBoardList.do", {}, "<spring:message code='Cache.lbl_JvCate'/>", "" );
					$('#boardFolderID').on("change",function(){
						if(!board.checkFolderWriteAuth($(this).val().split("_")[1])){	////폴더별 권한 체크
							Common.Warning("<spring:message code='Cache.msg_UNotWriteAuth'/>", "Warning Dialog", function () {
								$("#boardFolderID").val("");
							});
						}	
						$("#checkBoardChange").val("true");
					});
					
					$("#boardSimpleMake input, #boardSimpleMake textarea").on("change",function(){
						$("#checkBoardChange").val("true");
					});
					
					$('#btnBoardWriteDetail').on('click', function(){
						if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

						var simpleMenuID = $('#boardFolderID').val().split("_")[0];
						var simpleFolderID = $('#boardFolderID').val().split("_")[1];
						sessionStorage.setItem("urlHistory", location.href);
						board.createSimpleMessage(simpleFolderID, simpleMenuID, "writeDetail");
					});
	
					$('#btnBoardWrite').on('click', function(){
						Common.Progress();
						var simpleMenuID = $('#boardFolderID').val().split("_")[0];
						var simpleFolderID = $('#boardFolderID').val().split("_")[1];
						board.createSimpleMessage(simpleFolderID, simpleMenuID);
					});
	
					$('#btnBoardEditorPopup').on('click', function(){
						if ($(this).text() == "<spring:message code='Cache.lbl_editChange'/>") {
							Common.open("","editorPopup","<spring:message code='Cache.lbl_TextEditor'/>","/groupware/board/goEditorPopup.do","720px","650px","iframe",true,null,null,true);
						} else {
							$('#hiddenEditorBody').val('');
							$('#boardBodyText').val('').attr('disabled',false);
							$(this).text("<spring:message code='Cache.lbl_editChange'/>");
						}
					});
					
					isLoad["Board"] = true;
				}
			}
			
			function clickSimpleMakeTap(obj){
				initSimpleMake($(obj).attr("type"));
				$('.tabMenuArrow>li').removeClass('active');
				$('.tabContentArrow').removeClass('active');
				//$(obj).attr('id');
				$(obj).addClass("active");
				$('#'+$(obj).attr("type").toLowerCase()+'SimpleMake').addClass('active');
			}
			
			function setSimpleMake(option){
				if(isLoad["All"] == false)  {
					initSimpleMake($('.tabMenuArrow>li').eq(0).attr("type"));
					//event bind
					//탭매뉴 간편작성 스타일
					$('.tabMenuArrow>li').on('click', function(){
						var thisObj = this;
						
						var nowObj = $('.tabMenuArrow').find(".active");
						var moduleType = $(nowObj).attr("type");
						// 각 탭으로 이동시 빈값으로 변경
						if(moduleType != "Approval" && checkSimpleMakeWrite(moduleType)){
							Common.Confirm(Common.getDic("msg_WantLeaveTab"), "Confirm", function(result){
								if(result){
									setSimpleMakeBlank(moduleType);
									clickSimpleMakeTap(thisObj);
								}
							});
						}else{
							clickSimpleMakeTap(thisObj);
						}
					});
					$('.tabMenuArrow li:eq(0)').trigger('click');

					// 간단작성 팝업 닫기
			    	$('.simpleMakeLayerPopUp .btnOrderContClose').on('click', function(){
			    		var nowObj = $('.tabMenuArrow').find(".active");
						var moduleType = $(nowObj).attr("type");
						$("#mailSimpleMake .ui-autocomplete-multiselect-item").remove()
						
						// 각 탭으로 이동시 빈값으로 변경
						if(moduleType != "Approval" && checkSimpleMakeWrite(moduleType)){
							Common.Confirm(Common.getDic("msg_CloseThisWindow"), "Confirm", function(result){
								if(result){
									setSimpleMakeBlank(moduleType);
									
									$('.simpleMakeLayerPopUp').removeClass('active');
								}
							});
						}else{
							$('.simpleMakeLayerPopUp').removeClass('active');
						}
			    	});
					
			    	isLoad["All"] = true;
				}
			}
			
			function setSimpleMakeBlank(moduleType){
				switch (moduleType){
				case "Mail":
					$("#mailSimpleMake #mailSubject").val("");
					$("#mailSimpleMake #mailBodyText").val("");
					$("#mailSimpleMake .ui-autocomplete-multiselect-item").remove()					
					$("#checkMailChange").val("false");
					break;
				case "Schedule":
					$("#scheduleSimpleMake #ulFolderTypes").find("li").eq(0).click();
					$("#scheduleSimpleMake #Subject").val("");
					setDateConSchedule();
					$("#checkSCHChange").val("false");
					break;
				case "Resource":
					$("#resourceSimpleMake #FolderName").val("");
					$("#resourceSimpleMake #ResourceID").val("");
					$("#resourceSimpleMake #Subject").val("");
					setDateConResource();
					$("#checkRESChange").val("false");
					break;
				case "Board":
					//TODO
					$("#boardSimpleMake #boardSubject").val("");
					$("#boardSimpleMake #boardFolderID").val("");
					$("#boardSimpleMake #boardBodyText").val("");
					$("#checkBoardChange").val("false");
					break;
				default:
					break;
				}
			}
			function checkSimpleMakeWrite(moduleType){
				var returnBol = false;
				
				switch (moduleType){
				case "Mail":
					returnBol = $("#checkMailChange").val() == "true";
					break;
				case "Schedule":
					returnBol = $("#checkSCHChange").val() == "true";
					
					if($("#scheduleSimpleMake #ulFolderTypes").find("li").eq(0).attr("data-selvalue") != $("#FolderType").val())
						returnBol = true;
					
					break;
				case "Resource":
					returnBol = $("#checkRESChange").val() == "true";
					break;
				case "Board":
					//TODO
					returnBol = $("#checkBoardChange").val() == "true";
					break;
				default:
					break;
				}
				
				return returnBol;
			}
	
		</script>
		
		<script> /* 메일 스크립트  */
			function OrgMapLayerPopup_sendMail(){
	 			Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=sendMail_CallBack&type=B9","1000px","580px","iframe",true,null,null,true);
			}
	
			//소유자 지정
			function sendMail_CallBack(orgData){
				var userJSON =  $.parseJSON(orgData);
				var sCode, sDisplayName, sDNCode, sMail;
				
				$(userJSON.item).each(function (i, item) {
			  		var sObjectType = item.itemType;
			  		if(sObjectType.toUpperCase() == "USER"){ //사용자
			  			//sObjectTypeText = "사용자"; 	// 사용자
			  			//sObjectType_A = "UR";
			  			sCode = item.AN;			//UR_Code
			  			sDisplayName = CFN_GetDicInfo(item.DN);
			  			sDNCode = item.ETID; //DN_Code
			  			sMail = item.EM; // E-mail
			  		}
			  		/*else{ //그룹
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
			  		}*/
	
					bCheck = false;	
					$('#mailSimpleMake .ui-autocomplete-multiselect-item').each( function(i, item){ 
						  if ($(this).attr("data-value") == sCode) {
			                 bCheck = true;
			             }
					});
	
					if (!bCheck) {
						var orgMapItem = $('<div class="ui-autocomplete-multiselect-item" />')
						.attr({'data-value': sCode, 'data-json': JSON.stringify({ 'MailAddress' : sMail, 'UserName' : sDisplayName}) } )
						.text(sDisplayName)
						.append($("<span></span>")
	                    .addClass("ui-icon ui-icon-close")
	                    .click(function(){
	                                var item = $(this).parent();
	                                // delete self.selectedItems[item.text()]; 자동완성을 이용하여 추가한게 아니므로 삭제 하지 않아도 됨.
	                                item.remove();
	                            }));
						$('#myAutocompleteMultiple').before(orgMapItem);
					}
			 	});
			}
	
			//수신자 목록 jsonstring으로 변경
			function getReceiverData(){
				var userArray = [];
				
				//subject 추출
				$('#mailSimpleMake .ui-autocomplete-multiselect-item').each(function () {
			        var receiver = new Object();
			        var dateJson =  $.parseJSON($(this).attr("data-json"));
			        receiver.ReceiverMail = dateJson.MailAddress;
			        userArray.push(receiver);
			    });
			    
				return JSON.stringify(userArray);
			}
			
			// 메일 Validation 
			function mailValidation(){
				if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				
				if($('.ui-autocomplete-multiselect-item').length < 1){
					Common.Warning("<spring:message code='Cache.msg_noMailRecipient'/>");
					return;
				} else if($('#mailSubject').val() == ""){
					Common.Warning("<spring:message code='Cache.msg_EnterSubject'/>");
					return;
				} else if($('#mailBodyText').val() == ""){
					Common.Warning("<spring:message code='Cache.msg_EnterContents'/>");
					return;
				}
				
				if($("#myAutocompleteMultiple").val() != "") {
					Common.Confirm(Common.getDic("msg_unknownRecipientsName"), 'Confirmation Dialog', function (result) {
						if(result){
							sendMail();
						}
					});
				} else {
					sendMail();
				}				
			}
			
			//메일 보내기
			function sendMail() {
				var plantext = $("#mailBodyText").val().split(' ').join('&nbsp;'); //replaceAll() 함수 효과
				var text = plantext.replace(/(\r\n|\n|\n\n)/gi, '<br />');
				
				//CP 메일 사용할 경우에만 표시
				if(Common.getBaseConfig("isUseMail") == "Y"){ //Common.getExtensionProperties("isUse.mail")
					var arrTo = []; // 받는 사람
					
					$('#mailSimpleMake .ui-autocomplete-multiselect-item').each(function () {
						var receiver = new Object();
						var dateJson =  $.parseJSON($(this).attr("data-json"));
						receiver['UserName'] = $(this).text();
						receiver['MailAddress'] = dateJson.MailAddress;
				        arrTo.push(receiver);
					});
				    
					
					$.ajax({
				        type : "POST",
				        data: JSON.stringify({
				            "subject" : $('#mailSubject').val(),
				            "to" : arrTo, // 받는 사람
				            "content" : text, // 본문(html 태그 포함)
				            "contentText" : plantext, // 본문(html 태그 미포함) 
				            "sentSaveYn" : 'Y', // 보낸메일함 저장 여부(Y: 저장 N: 저장안함)
				            "from" : Common.getSession("UR_Mail"), // 보낸 사람
				            "userMail" : Common.getSession("UR_Mail"), // 발신인 메일 주소
				            "userName" : CFN_GetDicInfo(Common.getSession("UR_MultiName")), // 발신인 이름
				        }),
				        contentType: "application/json",
				        dataType: "json",
				        url : "/mail/userMail/simpleMailSent.do",
				        success:function (data) {
				        	if(data.msgType === "noAuth"){
				        		Common.Warning(Common.getDic("msg_notHaveAccess"), Common.getDic("CPMail_warning_msg"));  //접근 권한 없습니다
                        	}else{
    				        	if(data.resultTy == "S"){
    				        		Common.Inform("<spring:message code='Cache.lbl_Mail_SendCompletion'/>");
    					    		setSimpleMakeBlank('Mail');
    								
    								$('.simpleMakeLayerPopUp').removeClass('active');
    				        	}
    				        	else if(data.resultTy == "noQuota"){
    				        		Common.Warning("<spring:message code='Cache.msg_cannotSendQuota'/>");
    				        	}
				        	}
				        },
				        error:function(response, status, error) {
				        	CFN_ErrorAjax("/mail/userMail/simpleMailSent.do", response, status, error);
				        }
				        
				    });
				}else{
					$.ajax({
					    url: "/covicore/control/sendSimpleMail.do",
					    type: "POST",
					    data: {
							userCode: getReceiverData()
							,subject: $('#mailSubject').val()
							,bodyText: text
						},
					    async: false,
					    success: function (res) {
					    	if(res.status == "SUCCESS"){
					    		Common.Inform("<spring:message code='Cache.lbl_Mail_SendCompletion'/>");
					    		setSimpleMakeBlank('Mail');
								
								$('.simpleMakeLayerPopUp').removeClass('active');
					    	}else{
					    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
					    	}
				        },
				        error:function(response, status, error){
							CFN_ErrorAjax("/covicore/control/sendSimpleMail.do", response, status, error);
						}
					});
				}
			}
		</script>
		
		<div id="approvalSimpleMake" class="tabContentArrow">							
			<div class="simpleContent simpleContApproval">
				<ul class="tabMenuStyle02 clearFloat">
					<li onclick="approvalTabClick(this);" class="active"><a><spring:message code='Cache.lbl_favoriteDraft'/></a></li>
					<li onclick="approvalTabClick(this);" class=""><a><spring:message code='Cache.lbl_latestDraft'/></a></li>
				</ul>
				<div id="tabMenuStyle02Div">									
					<div class="tabContentStyle02 active">
						<ul id="favoriteList" class="favTopMenuList clearFloat mt15">
						</ul>
					</div>
					<div class="tabContentStyle02">
						<ul id="lastDraftList" class="favTopMenuList clearFloat mt15">
						</ul>
					</div>
				</div>
			</div>
			<script> /* 결재 스크립트  */
				function setFavoriteApproval(){
					$.ajax({
					    url: "/groupware/approval/getFavoriteUsedFormListData.do",
					    type: "POST",
					    data: {},
					    async: false,
					    success: function (res) {
					    	if(res.status == "SUCCESS"){
					    		var favoriteHtml = "";
					    		var lang = Common.getSession("lang");
					    		
					    		$(res.list).each(function(){
					    			// TODO 가로 양식에 대한 처리 필요
					    			favoriteHtml += '<li><a onclick=\'CFN_OpenWindow("/approval/approval_Form.do?formID='+ this.FormID + '&mode=DRAFT", "", 790, (window.screen.height - 100), "resize", "false");\'>'+CFN_GetDicInfo(this.LabelText, lang)+'</a></li>';
					    		});
					    		$("#favoriteList").html(favoriteHtml);
					    	}else{
					    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
					    	}
				        },
				        error:function(response, status, error){
							CFN_ErrorAjax("/groupware/approval/getFavoriteUsedFormListData.do", response, status, error);
						}
					});
				}
				
				function setLastDraftApproval(){
					$.ajax({
					    url: "/groupware/approval/getLastestUsedFormListData.do",
					    type: "POST",
					    data: {},
					    async: false,
					    success: function (res) {
					    	if(res.status == "SUCCESS"){
					    		var favoriteHtml = "";
					    		$(res.list).each(function(){
					    			// TODO 가로 양식에 대한 처리 필요
					    			favoriteHtml += "<li><a onclick='onClickApprovalPopButton(\""+this.ProcessArchiveID+"\",\""+this.WorkitemArchiveID+"\",\""+this.PerformerID+"\",\""+this.ProcessDescriptionID+"\",\""+this.FormSubKind+"\",\"\",\"\",\"\",\"\",\""+this.UserCode+"\",\""+this.TYPE+"\",\""+this.FormPrefix+"\"); return false;'>"+this.FormSubject+"</a></li>";
					    		});
					    		$("#lastDraftList").html(favoriteHtml);
					    	}else{
					    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
					    	}
				        },
				        error:function(response, status, error){
							CFN_ErrorAjax("/groupware/approval/getFavoriteUsedFormListData.do", response, status, error);
						}
					});
				}
				
				function onClickApprovalPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,TYPE,FormPrefix){
					var archived = "false";
					var mode;
					var gloct;
					var subkind;
					var archived;
					var userID;
					if(TYPE=="Complete"){
						mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; 	// 완료함
					}else{
						mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode;	// 반려함
					}
					var width = "790";
					
					CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind, "", width, (window.screen.height - 100), "resize");
				}
				
				function approvalTabClick(obj){
					$(".tabMenuStyle02>li").removeClass("active");
					$("#tabMenuStyle02Div>div").removeClass("active");
					$(obj).addClass("active");
					$('#tabMenuStyle02Div>div').eq($(obj).index()).addClass('active');
				}
			</script>
		</div>
		<div id="scheduleSimpleMake" class="tabContentArrow">
			<div class="simpleContent simpleContSchedule">								
				<div class="cusSelect">
					<!-- 셀렉트 선택시 아래 input에 value값으로 ul 태그 li에 data-selvalue 값 입력 -->
					<input id="FolderType" type="txt" readonly class="selectValue"/>
					<span id="defaultFolderType" class="sleOpTitle" onclick="sleOpTitleOnClick(this);"></span>
					<ul id="ulFolderTypes" class="selectOpList">
					</ul>
				</div>
				<div class="inputDateView mt10"><input id="Subject" class="HtmlCheckXSS ScriptCheckXSS" type="text" placeholder="<spring:message code='Cache.msg_mustEnterEvent'/>" /></div> <!--일정명을 입력하세요.  -->
				<div id="simpleSchDateCon" class="dateSel"></div>
			</div>
			<div class="bottomCont">
				 <!-- CalendarPopup.jsp에서 사용하기 위해 ID 부여  -->
				<a id="scheduleDetailBtn" onclick="goSchDetailWritePage();" class="btnTypeDefault btnThemeLine"><spring:message code='Cache.btn_WriteDetail'/></a>
				<a id="scheduleRegistBtn" onclick="scheduleUser.setOne('SC');" class="btnTypeDefault btnTypeChk ml5"><spring:message code='Cache.btn_register'/></a>
			</div>
			<input type="hidden"  id="checkSCHChange" value="false">
			<script type="text/javascript"> /* 일정 스크립트  */
				function setFolderTypeSchedule(){
					//권한 있는 모든 폴더 리스트
					var selectHtml = "";
					var selectFolderObj;
					var gBaseConfigGoogleFolderID = Common.getBaseConfig("ScheduleGoogleFolderID");
					
					selectFolderObj = $(sm_schAclArray.create);
						
					$(selectFolderObj).each(function(i){
						if(i == 0){
							$("#scheduleSimpleMake #defaultFolderType").html('<span style="background-color:'+this.Color+'"></span> '+this.MultiDisplayName);
							$("#scheduleSimpleMake #FolderType").val(this.FolderID);
						}
						if(!(isConnectGoogle == false && this.FolderID == gBaseConfigGoogleFolderID)){
							if (this.FolderType != "Folder" && this.FolderType != "ScheduleShare"){
								selectHtml += '<li onclick="selectOpListLiOnclick(this);" data-selvalue="'+this.FolderID+'" folderType="'+this.FolderType+'"><span style="background-color:'+this.Color+'"></span>&nbsp'+this.MultiDisplayName+'</li>';
							}
	     				}
					});
						
					$("#scheduleSimpleMake #ulFolderTypes").html(selectHtml);
				}
				
				function setDateConSchedule(){
					target = 'simpleSchDateCon';
					
					var timeInfos = {};
					timeInfos = {
							width : "80",
							H : "1,2,3,4,8",
							W : "1,2", //주 선택
							M : "1,2", //달 선택
							Y : "1,2" //년도 선택
						};
					
					var initInfos = {
							useCalendarPicker : 'Y',
							useTimePicker : 'Y',
							useBar : 'Y',
							useSeparation : 'Y',
							minuteInterval : 5,  //TODO 만약, 60의 약수가 아닌 경우, 그려지지 않음.
							timePickerwidth : '50',
							height : '200',
							use59 : 'Y'
						};
					
					coviCtrl.renderDateSelect(target, timeInfos, initInfos);
					
					// onchange 함수 세팅
					$("#scheduleSimpleMake").find("input,select").attr("onchange", "funcSCHOnChange();");
				}
				
				function goSchDetailWritePage(){
					location.href = "/groupware/layout/schedule_DetailWrite.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
							+"&subject="+$("#scheduleSimpleMake #Subject").val()
							+"&folderID="+$("#scheduleSimpleMake #FolderType").val()
							+"&simpleDatePicker="+coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=datePicker]').val
							+"&startDate="+$("#scheduleSimpleMake #simpleSchDateCon_StartDate").val()
							+"&endDate="+$("#scheduleSimpleMake #simpleSchDateCon_EndDate").val()
							+"&startHour="+coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=startHour]').val
							+"&startMinute="+coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=startMinute]').val
							+"&endHour="+coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=endHour]').val
							+"&endMinute="+coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=endMinute]').val
				}
				
				function funcSCHOnChange(){
					$("#checkSCHChange").val("true"); 
				}
				
				function setSimpleMakeAclEventFolderData(){
					var userCode = Common.getSession("UR_Code");
					/* if (localCache.exist("schAclArray_" + userCode)) {
						sm_schAclArray = localCache.get("schAclArray_" + userCode);
					} else { */
						$.ajax({
						    url: "/groupware/schedule/getACLFolder.do",
						    type: "POST",
						    data: {},
						    async: false,
						    success: function (res) {
						    	if(res.status == "SUCCESS"){
						    		sm_schAclArray = res;
						    		//localCache.set("schAclArray_" + userCode, res, "");
						    	}else{
						    		Common.Error("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
						    	}
					        },
					        error:function(response, status, error){
								CFN_ErrorAjax("/groupware/schedule/getACLFolder.do", response, status, error);
							}
						});
					//}
				}
			</script>
		</div>						
		<div id="resourceSimpleMake" class="tabContentArrow">
			<div class="simpleContent simpleContReservation">
				<div class="inputDateView02 ">
					<input type="text" id="FolderName" readonly="readonly" ><a onclick="resourceUser.openResourceTree('SC');" class="btnTypeDefault btnTypeChkLine"><spring:message code='Cache.lbl_resource_selectRes'/></a><!-- 자원선택 -->
				</div>
				<input type="hidden" id="ResourceID" value="">
				<div class="inputDateView mt10"><input type="text" id="Subject" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_ReservationWrite_01'/>"></div><!-- 용도를 입력해주세요. -->
				<div id="simpleResDateCon" class="dateSel type02 mt5">
				</div>		
			</div>
			<div class="bottomCont">
				<a onclick="goResDetailWritePage();" class="btnTypeDefault btnThemeLine"><spring:message code='Cache.btn_WriteDetail'/></a>
				<a id="resourceRegistBtn" onclick="resourceUser.setOne('SC');" class="btnTypeDefault btnTypeChk ml5"><spring:message code='Cache.lbl_Reservation'/></a>
			</div>
			<input type="hidden" id="checkRESChange" value="false">
			<script type="text/javascript"> /* 자원 스크립트 */
			
			function setDateConResource(){
				target = 'simpleResDateCon';
				
				var timeInfos = {
						width : "80",
						H : "1,2,3,4",
						W : "1,2", //주 선택
						M : "1,2", //달 선택
						Y : "1,2" //년도 선택
					};
				
				var initInfos = {
						useCalendarPicker : 'Y',
						useTimePicker : 'Y',
						useBar : 'Y',
						useSeparation : 'Y',
						minuteInterval : 5,  //TODO 만약, 60의 약수가 아닌 경우, 그려지지 않음.
						timePickerwidth : '50',
						height : '200',
						use59 : 'Y'
					};
				
				var nowHour = new Date(CFN_GetLocalCurrentDate());
				var nowMinite = AddFrontZero(Math.ceil((new Date(CFN_GetLocalCurrentDate()).getMinutes())/5)*5, 2);
				
				if(nowMinite >= 60) {
					nowHour.setHours(new Date(CFN_GetLocalCurrentDate()).getHours() + 1);	
					nowMinite = AddFrontZero(0, 2);
				}
				
				coviCtrl.renderDateSelect(target, timeInfos, initInfos);
				
				coviCtrl.setSelected('simpleResDateCon [name=startHour]', AddFrontZero(nowHour.getHours(), 2));
				coviCtrl.setSelected('simpleResDateCon [name=startMinute]', nowMinite);
				
				nowHour.setTime(nowHour.getTime() + (60*60*1000));
				
				$("#simpleResDateCon_EndDate").val(schedule_SetDateFormat(nowHour, "."));
				coviCtrl.setSelected('simpleResDateCon [name=endHour]', AddFrontZero(nowHour.getHours(), 2));
				coviCtrl.setSelected('simpleResDateCon [name=endMinute]', nowMinite);
				
				// onchange 함수 세팅
				$("#resourceSimpleMake").find("input,select").attr("onchange", "funcRESOnChange();");
			}
			
			function goResDetailWritePage(){
				location.href = "/groupware/layout/resource_DetailWrite.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
						+"&subject="+$("#resourceSimpleMake #Subject").val()
						+"&resourceID="+$("#resourceSimpleMake #ResourceID").val()
						+"&simpleDatePicker="+coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=datePicker]').val
						+"&startDate="+$("#resourceSimpleMake #simpleResDateCon_StartDate").val()
						+"&endDate="+$("#resourceSimpleMake #simpleResDateCon_EndDate").val()
						+"&startHour="+coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=startHour]').val
						+"&startMinute="+coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=startMinute]').val
						+"&endHour="+coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=endHour]').val
						+"&endMinute="+coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=endMinute]').val
			}
			
			function funcRESOnChange(){
				$("#checkRESChange").val("true"); 
			}
			</script>
		</div>
		<div id="boardSimpleMake" class="tabContentArrow">							
			<div class="simpleContent simpleContPost">
				<div class="inputBoxSytel01 type02">
					<div><span><spring:message code='Cache.lbl_Title'/></span></div>	<!-- 제목 -->
					<div>
						<input id="boardSubject" class="HtmlCheckXSS ScriptCheckXSS" type="text">
					</div>
				</div>
				<div class="inputBoxSytel01 type02">
					<div><span><spring:message code='Cache.lbl_JvCate'/></span></div>	<!-- 분류 선택 -->
					<div class="simple_publishing_category">
						<input type="text" id="boardName" readonly="readonly" style="width:75%">
						<input type="hidden" id="boardFolderID" value="">
						<a onclick="BoardPopup();" class="btnTypeDefault btnTypeChkLine"><span><spring:message code='Cache.lbl_SelectBoard'/></span></a>
					</div>
				</div>								
				<div>
					<textarea id="boardBodyText" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
					<input type="hidden" id="hiddenEditorBody" value="">
					<input type="hidden" id="hiddenEditorInlineImage" value="">
					<p class="editChange"><a id="btnBoardEditorPopup"><spring:message code='Cache.lbl_editChange'/></a></p> <!-- 편집기로 작성 -->
				</div>
			</div>
			<div class="bottomCont">
				<a id="btnBoardWriteDetail" class="btnTypeDefault btnThemeLine"><spring:message code='Cache.btn_WriteDetail'/></a>	<!-- 상세등록 -->
				<a id="btnBoardWrite" class="btnTypeDefault btnTypeBg ml5"><spring:message code='Cache.btn_register'/></a>			<!-- 등록 -->
			</div>
			<input type="hidden" id="checkBoardChange" value="false">
			<script type="text/javascript"> /* 게시판 스크립트  */
				function editorPopupCallBack(textWithTag, text, textInlineImage) {
					$('#hiddenEditorBody').val(textWithTag);
					$('#hiddenEditorInlineImage').val(textInlineImage);
					$('#boardBodyText').val(text).attr('disabled',true);
					$('#btnBoardEditorPopup').text("<spring:message code='Cache.lbl_writeTextArea'/>");
				}
			
				function BoardPopup() {
					parent._CallBackMethod = BoardPopupCallBack;
					var url = String.format("/groupware/board/goSearchBoardTreePopup.do?bizSection=Board&menuCode=BoardMain");
					parent.Common.open("", "boardTreePopup", Common.getDic("lbl_SelectBoard"), url, "360px", "500px", "iframe", true, null, null, true);
				}
				function BoardPopupCallBack(Obj) {
					$("#boardFolderID").val(Obj.MenuID + "_" + Obj.FolderID + "_" + Obj.FolderType);
					$("#boardName").val(Obj.DisplayName);
				}
			</script>
			
		</div>
	</div>
	
</div>
<script>
</script>