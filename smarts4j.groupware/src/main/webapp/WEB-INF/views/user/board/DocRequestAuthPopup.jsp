<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style type="text/css">

</style>

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:685px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent">
			<div class="middle">
				<table class="tableTypeRow">
					<caption><spring:message code='Cache.lbl_Doc_requestAuth'/></caption>	<!-- 문서권한 요청 -->
					<colgroup>
						<col style="width: 21.66%;">
						<col style="width: auto;">
					</colgroup>
					<tbody>
						<tr>
							<th><spring:message code='Cache.lbl_Title'/></th>	<!-- 제목 -->
							<td>
								<div class="box">
									<span id="spanSubject" class="title"> <!-- 제목 --> </span>
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_DocCate'/></th>	<!-- 문서분류 -->
							<td>
								<div class="box">
									<div id="divFolderPath" class="path">
										<!-- 분류 -->
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_Owner'/></th> <!-- 소유자  -->
							<td>
								<input type="hidden" id="hidOwnerCode" value="" />
								<div id="divOwnerCode" class="box">
									<!-- 소유자 -->
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_Requester'/></th>	<!-- 요청자 -->
							<td>
								<div id="divUserCode" class="box">
									<!-- 요청자 -->
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_AclRequestComment'/></th>	<!-- 권한요청 사유 -->
							<td>
								<textarea id="txtComment" class="HtmlCheckXSS ScriptCheckXSS" cols="20" rows="3" title="처리사유입력" style="margin: 10px 5px; resize: none;"></textarea>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_AclRequest'/></th> <!-- 권한요청 -->
							<td>
								<ul class="setList requestList">
									<li>
										<strong>[S]<spring:message code='Cache.lbl_SecurityAcl'/></strong>	<!-- 보안권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnSecurity" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>	<!-- 거부, 허용 -->
											</p>
										</div>
									</li>
									<li>
										<strong>[D]<spring:message code='Cache.lbl_DeleteAcl'/></strong>	<!-- 삭제 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnDelete" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>	<!-- 거부, 허용 -->
											</p>
										</div>
									</li>
									<li>
										<strong>[M]<spring:message code="Cache.lbl_ModifyAcl"/></strong>	<!-- 수정 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnModify" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>	<!-- 거부, 허용 -->
											</p>
										</div>
									</li>
									<li>
										<strong>[E]<spring:message code='Cache.lbl_ExecuteAcl'/></strong>	<!-- 실행 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnExecute" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>	<!-- 거부, 허용 -->
											</p>
										</div>
									</li>
									<li>
										<strong>[R]<spring:message code='Cache.lbl_ReadAcl'/></strong>	<!-- 읽기 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnRead" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>	<!-- 거부, 허용 -->
											</p>
										</div>
									</li>
								</ul>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:saveAclRequest();"><spring:message code="Cache.lbl_ApprovalRequest"/></a><!-- 승인 요청 --> 
				<a href="#" class="btnTypeDefault" onclick="javascript:Common.Close();"><spring:message code="Cache.btn_Cancel"/></a><!-- 취소 -->			
			</div>
			</div>
		</div>
	</div>

<script>
	var folderID = CFN_GetQueryString("folderID");
	var folderPath = CFN_GetQueryString("folderPath");
	var messageID = CFN_GetQueryString("messageID");
	var version = CFN_GetQueryString("version");
	var communityID = '';	//parameter 채우기용
	var currentAclList = '';	// 현재권한
	
	function setCurrentAcl(){
		var bSecurityFlag = false;
		var bReadFlag = false;
		var bModifyFlag = false;
		var bDeleteFlag = false;
		var bExecuteFlag = false;
		
		var aclObj = board.getMessageAclList( "Doc", version, messageID, folderID ).aclObj;
		
		bSecurityFlag = aclObj.Security == "_"?false:true;
		bCreateFlag = aclObj.Create == "_"?false:true;
		bDeleteFlag = aclObj.Delete == "_"?false:true;
		bModifyFlag = aclObj.Modify == "_"?false:true;
		bExecuteFlag = aclObj.Execute == "_"?false:true;
		bReadFlag = aclObj.Read == "_"?false:true;

		if(bSecurityFlag){ $('#btnSecurity').addClass('on'); }
		if(bReadFlag){ $('#btnRead').addClass('on'); }		
		if(bModifyFlag){ $('#btnModify').addClass('on'); }
		if(bDeleteFlag){ $('#btnDelete').addClass('on'); }
		if(bExecuteFlag){ $('#btnExecute').addClass('on'); }
		
		currentAclList = aclObj.Security + aclObj.Create + aclObj.Delete + aclObj.Modify + aclObj.Execute + aclObj.Read;
	}

	function setAclList(){
		var aclList = '';
		aclList += $('#btnSecurity').hasClass('on')?"S":"_";
		aclList += currentAclList.charAt(1);
		aclList += $('#btnDelete').hasClass('on')?"D":"_";
		aclList += $('#btnModify').hasClass('on')?"M":"_";
		aclList += $('#btnExecute').hasClass('on')?"E":"_";
		aclList += $('#btnRead').hasClass('on')?"R":"_";
		return aclList;
	}
	
	function saveAclRequest(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if($("#txtComment").val()==""){
 			parent.Common.Warning("<spring:message code='Cache.msg_gw_ValidationComment' />", "Warning Dialog", function () {
		    	$("#txtComment").focus();
		    });
			return;
		}

		$.ajax({
	    	type:"POST",
	    	url: "/groupware/board/createRequestAuth.do",
	    	data: {
		    	'messageID': messageID
		    	,'folderID': folderID
		    	,'version': version
		    	,'aclList': setAclList()
		    	,'currentAclList' : currentAclList
		    	,'requestMsg': $('#txtComment').val()
		    	,'ownerCode':$('#hidOwnerCode').val()
		    },
	    	dataType : 'json',
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
		    		Common.Inform(data.message,"Information",function(){
		    			Common.Close();
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); /* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	  		error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/groupware/board/createRequestAuth.do", response, status, error);
			}
	    });
	}

	$(function () {
		board.getBoardConfig(folderID);
		$('.path').html(board.renderFolderPath());		
		
		$.ajax({
	    	type:"POST",
	    	url: "/groupware/board/selectRequestAuthMessageInfo.do",
	    	data: {
				"bizSection": 'Doc',
				"version": version,
				"messageID": messageID,
				"folderID": folderID
			},
	    	dataType : 'json',
	    	success:function(data){
	    		if(data.status == 'SUCCESS'){
	    			var msgData = data.msgData;
	    			
	    			$('#spanSubject').text(msgData.Subject);		// 제목
	    	 		$('#divOwnerCode').text(msgData.OwnerName);		// 소유자
	    	 		$('#hidOwnerCode').val(msgData.OwnerCode);		// 소유자 UserCode
	    	 		$('#divUserCode').text(Common.getSession('USERNAME'));	// 요청자
	    			setCurrentAcl();
	    			
	    			//스위치 on/off 이벤트 바인드
	    			$(".alarm").on('click', function(){
	    				$(this).find('.onOffBtn').hasClass('on') == true?$(this).find('.onOffBtn').removeClass('on'):$(this).find('.onOffBtn').addClass('on');
	    			});
	    		} else {
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
	    		}
	    	}, 
	  		error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/createRequestAuth.do", response, status, error);
			}
	    });
	});
</script>
