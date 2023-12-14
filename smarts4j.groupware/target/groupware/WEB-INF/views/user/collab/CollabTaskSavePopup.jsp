<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!doctype html>
<% 
pageContext.setAttribute("QT", "'");
pageContext.setAttribute("SQ", "\\'");
%>
<c:set var="Remark" value="${fn:replace(taskData.Remark,QT, SQ)}" />
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js"></script>
<style>
	.ui-autocomplete-multiselect.ui-state-default{width:100% !important;border:0px}
	.ui-autocomplete-multiselect input{width:60px !important; border:0px !important}
	.pop_box .fileUpview {max-height: 100% !important;}
</style>
<body>
<!-- 업무보고 상세팝업 시작 -->
	<form id="form1">
		<div class="divpop_body" style="overflow:hidden; padding:0;">
			<div class="collabo_popup_wrap">
				<div class="pop_slide addTask">
					<div class="pop_box">
						<strong class="pop_title02">
							<!-- 업무명을 입력해주세요 -->
							<input type="text" class="HtmlCheckXSS ScriptCheckXSS Required MaxSizeCheck" max="150" id="taskName" name="taskName"  value="${taskData.TaskName}" title="<spring:message code='Cache.lbl_TaskName' />" placeholder="<spring:message code='Cache.msg_chk_taskName' />"/>
							
							<div class="titleoption">
								<c:if test="${taskData.Label == 'E'}">
									<a href="#" onclick="btnToggleImportant()" class="btn_important on"><spring:message code="Cache.lbl_Urgency" /></a> <!-- 긴급 -->
								</c:if>
								<c:if test="${taskData.Label != 'E'}">
									<a href="#" onclick="btnToggleImportant()" class="btn_important"><spring:message code="Cache.lbl_Urgency" /></a> <!-- 긴급 -->
								</c:if>
								
								<!-- 상태 -->
								<select class="selectType02" id="taskStatus">	
									<option value="W" ${sectionSeq==null or sectionSeq=='W' or taskData.TaskStatus =='W'? 'selected':''} ><spring:message code='Cache.lbl_Ready' /></option>
									<option value="P" ${sectionSeq=='P' or taskData.TaskStatus =='P'? 'selected':''} ><spring:message code='Cache.lbl_Progress' /></option>			<!-- 진행 -->
									<option value="H" ${sectionSeq=='H' or taskData.TaskStatus =='H'? 'selected':''} ><spring:message code='Cache.lbl_Hold' /></option> 			<!-- 보류 -->
									<option value="C" ${sectionSeq=='C' or taskData.TaskStatus =='C'? 'selected':''} ><spring:message code='Cache.lbl_Completed' /></option> 		<!-- 완료 -->
								</select>
								
								<!-- 진행률 -->
								<select class="selectType02" id="progRate" name="progRate" value="${taskData.ProgRate }" ></select>
							</div>
						</strong>
						
						<ul class="pop_table">
							<!-- 담당자 -->
							<li>
								<div class="div_th"><font color="red">*</font><spring:message code='Cache.lbl_charge' /></div>
								<div class="div_td">
									<div class="org_T">
										<div class="org_T_l">
											<div class="org_list_box" style="height:100%;min-height:50px;" id="resultViewMember">
												<input id="resultViewMemberInput" type="text" class="HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
											</div>
										</div>
										<!-- 검색버튼 -->
										<div class="org_T_r">
											<a href="#" id="btnMember" class="btnTypeDefault search" ></a>
										</div>
									</div>
								</div>
							</li>
							<!-- 기간 -->
							<li>
								<div class="div_th"><font color="red">*</font><spring:message code='Cache.lbl_Period' /></div> 	<!-- 기간 -->
								<div class="div_td">
									<div class="dateSel type02">
										<c:if test="${taskData.IsMile == 'Y'}">
											<input class="adDate Required" type="text" id="endDate"  name="endDate"  date_separator="." kind="date" value="${taskData.EndDate}" title="<spring:message code='Cache.lbl_apv_EndDate'/>">
										</c:if>
										<c:if test="${taskData.IsMile != 'Y'}">
											<input class="adDate Required" type="text" id="startDate" name="startDate" date_separator="." value="${taskData.StartDate}" title="<spring:message code='Cache.lbl_start_date'/>"/>
											<span>-</span>
											<input class="adDate Required" type="text" id="endDate" name="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" value="${taskData.EndDate}" title="<spring:message code='Cache.lbl_apv_EndDate'/>"/>
										</c:if>
									</div>
								</div>
							</li>
							
							<!-- 팀/프로젝트 -->
							<c:if test="${taskData !='' && taskData.TaskSeq ne null}">
								<li>
									<div class="div_th"><spring:message code='Cache.lbl_apv_vacation_team'/>/<spring:message code='Cache.lbl_Project' /></div>
									<div class="div_td">
										<div id = "divPrjList">
										<c:if test="${empty mapList}">
												<c:if test="${taskData.ParentKey eq 0}"> 
												<span class="control_box"><a href="#" class="btn_plus" id="btnAddPrjoject"></a></span>
												</c:if>
										</c:if>
										<c:forEach items="${mapList}" var="list" varStatus="status">
											<div data-prjName='${list.PrjName}' data-prjType='${list.PrjType}' data-prjSeq='${list.PrjSeq}' data-sectionSeq='${list.SectionSeq}'>
												<input value="${list.PrjName}" readonly class="taskName">
												<input value="${list.SectionName}"  readonly class="selectType02">
												<c:if test="${taskData.ParentKey eq 0}"> 
												<div class="control_box">
													<a href="#" class="btn_remove" id="btnDelProject"  data-prjName='${list.PrjName}'   data-prjType='${list.PrjType}'  data-prjSeq='${list.PrjSeq}'></a>
													<c:if test="${status.index eq 0 }">
													<a href="#" class="btn_plus" id="btnAddPrjoject"></a>
													</c:if>
												</div>
												</c:if>
											</div>
										</c:forEach>
										</div>
									</div>
								</li>
							</c:if>	
							
							<!-- 관련업무 -->
							<li>
								<!-- 툴팁 -->
								<div class="div_th"><spring:message code='Cache.lbl_linkTask' />
									<div class="collabo_help02">
										<a id="toolTipToggle" class="help_ico"></a>	
									</div>
								</div>
								<div class="div_td">
									<div id="divLinkTask">
										<div>
											<select type="text" class="selectType02" id="linkTask" name="linkTask">
	                                        	<option value="linkAF"><spring:message code='Cache.lbl_LinkAF' /></option>    <!-- 선행업무 -->
	                                          	<option value="linkBF"><spring:message code='Cache.lbl_LinkBF' /></option>    <!-- 후행업무 -->
		                                    </select>
											<input id="inptLinkTask" class="taskName" readonly/> 
											
											<div class="control_box">
												<a id="btnDelLinkTask" onclick="collabTaskAdd.delFrstLinkTask();" class="btn_remove">삭제</a>
												<a id="btnAddLinkTask" onclick="collabTaskAdd.addLinkTask(this);" class="btn_plus">추가</a>
											</div>
										</div>
										<c:if test="${not empty linkList}">
											<c:forEach items="${linkList}" var="list" varStatus="status" >
												<div style='margin-top: 5px;' class="relatedTask" data-taskname="${list.TaskName}" ${list.LinkType eq 'AF' && list.TaskStatus ne 'C'?'data-status="NOT"':''}>
													<select type='text' class='selectType02' name='linkTask' disabled>
														<c:if test="${list.LinkType == 'AF'}" >
															<option value='linkAF'><spring:message code='Cache.lbl_LinkAF' /></option>
														</c:if>
														<c:if test="${list.LinkType == 'BF'}" >
															<option value='linkBF'><spring:message code='Cache.lbl_LinkBF' /></option>
														</c:if>
													</select>
													<input value='${list.TaskStatusName} > ${list.LinkTaskName}' data-value='${list.LinkTaskSeq}' class='taskName' disabled/>
													<div class='control_box' style='margin-left: 14px;' >
														<a onclick='collabTaskAdd.delLinkTask(this)' class='btn_remove'>삭제</a>
													</div>
												</div>
											</c:forEach>
										</c:if>
									</div>
								</div>
							</li>
							
							<!-- 관련결재 -->
							<%if (RedisDataUtil.getBaseConfig("isUseCollabApproval").equals("Y")){%>
							<c:choose>
						    	<c:when test="${taskData !='' && taskData.TaskSeq ne null  }">
									<li>
										<div class="div_th"><spring:message code='Cache.lbl_RelatedApproval' /></div>
										<div class="div_td">
											<input type="text" value="" class="connect_approval">
											<a href="#" class="btnTypeDefault" onclick="collabUtil.openApprovalListPopup('${taskData.TaskSeq}','');">찾아보기 </a>
											<ul class="clearFloat fileUpview fileview" id="collabApprovalList" >
												<c:forEach items="${approvalList}" var="list" varStatus="status">
													<li>
														<div class="" data-filesize="${list.Size}" data-fileid="${list.FileID}" data-filetoken="${list.FileToken}" data-fileext="${list.Extention}">
															<span class="btn_dfile">
																<a class="file_down">
																<script>var icon = collabUtil.getFileClass("${list.Extention}");
																		document.write("<span class='"+icon+"'></span>");
																</script>
																${list.FileName}
																</a>
																<a class="tag_del" id ="approval_del"></a>
															</span>
														</div>
													</li>
												</c:forEach>
											</ul>
										</div>
									</li>
								</c:when>
								<c:when test="${formInstanceID !='' && formInstanceID ne null  }">
									<li>
										<div class="div_th"><spring:message code='Cache.lbl_RelatedApproval' /></div>
										<div class="div_td">
											<ul class="clearFloat fileUpview fileview" id="collabApprovalList" >
												<li>
													<span class="btn_dfile">
															<span class="ic_pdf"></span>
															${subject}.pdf
													</span>
												</li>
											</ul>
										</div>
									</li>
								</c:when>
					    	</c:choose>
							<%}%>							
							<!-- 중요도 -->
							<li>
								<div class="div_th"><spring:message code='Cache.lbl_importance' /></div>
								<div class="div_td">
									<div class="cusSelect02">
										<input type="txt" id="impLvl" readonly="" class="selectValue" value="">
										<span class="sleOpTitle">
											<span class="num_equal"></span> <spring:message code='Cache.lbl_middle' /></span> 	<!-- 중간 -->
										<ul class="selectOpList">
											<li data-selvalue="E"><span class="num_none"></span> <spring:message code='Cache.lbl_noUse' /></li> 	<!-- 사용안함 -->
											<li data-selvalue="H"><span class="num_up"></span> <spring:message code='Cache.CPMail_High' /></li> 	<!-- 높음 -->
											<li data-selvalue="M"><span class="num_equal"></span> <spring:message code='Cache.lbl_middle' /></li> 	<!-- 중간 -->
											<li data-selvalue="L"><span class="num_down"></span> <spring:message code='Cache.CPMail_Low' /></li> 	<!-- 낮음 -->
										</ul>
									</div>
								</div>
							</li>
							
							<!-- 태그 -->
							<li>
								<div class="div_th"><spring:message code='Cache.lbl_Tag' /></div>
								<div class="div_td">
									<a id="btnTag" class="btnTypeDefault"><spring:message code='Cache.lbl_Add' /> </a> <!-- 추가 -->
									<ul class="clearFloat fileUpview" id="tagList" >
										<c:forEach items="${tagList}" var="list" varStatus="status">
											<li>
												<div data-tagID="${list.TagID }">
													<span class="btn_dtag bg0<%= (new java.security.SecureRandom()).nextInt(3)+1 %>">#${list.TagName}</span>
													<c:if test="${authSave eq 'Y'  && list.RegisterCode eq USERID}">
														<a class="tag_del" id="tag_del"></a>
													</c:if>
												</div>
											</li>
										</c:forEach>
									</ul>
								</div>
							</li>
							<li>
								<div class="div_th"><spring:message code='Cache.lbl_apv_attachfile' /></div> 	<!-- 파일 첨부 -->
								<div class="div_td">
									<div id="con_file" style="padding:0px"></div>
								</div>
							</li>
							<li>
								<div class="div_th"><spring:message code='Cache.lbl_Description' /></div> 	<!-- 설명 -->
								<div class="div_td">
									<textarea id="remark" name="remark" title="<spring:message code="Cache.lbl_Description"/>">${taskData.RemarkText}</textarea>
									<c:if test="${isUseDescEditor eq 'Y'}">
										<div id="descEditor"></div> 	<!--editor-->
									</c:if>
								</div>
							</li>
						</ul>
					</div>
				</div>
				
				<!-- 확장필드 -->
				<div class="c_titBox">
					<h3 class="cycleTitle"><spring:message code="Cache.btn_ExtendedField"/></h3> <!-- 확장필드 -->
				</div>
				<!-- 확장필드 항목 -->
				<div class="tblList tblCont boradBottomCont StateTb">
					<table class="WorkingStatus_table" id="tblUserForm" cellpadding="0" cellspacing="0">
						<colgroup>
							<col width="180">
							<col width="*">
						</colgroup>
						<thead>
							<tr>
								<th><spring:message code="Cache.lbl_ItemName"/></th>	<!-- 항목명 -->
								<th><spring:message code="Cache.lbl_Contents"/></th>	<!-- 내용 -->
							</tr>
						</thead>
						<tbody>
							<c:if test="${not empty linkURL}">
								<tr style="display:none;">
									<td>
										<input id="orgSubject" type=text class="txtTitle textArea" name="optionTitle" value="" readonly />
										<input type=hidden class="txtType textArea" name="optionType" value="linkURL" readonly />									
									</td>
									<td>
										<input type=text class="txtVal HtmlCheckXSS ScriptCheckXSS MaxSizeCheck w100" max="150" name="optionVal" value="${linkURL}" />
									</td>
								</tr>
							</c:if>
							<c:forEach items="${userformList}" var="list" varStatus="status">
								<tr>
									<td><input type=text class="txtTitle textArea" name="optionTitle" value="${list.OptionTitle}" readonly />
										<input type=hidden class="txtType textArea" name="optionType" value="${list.OptionType}" readonly />									
									</td>
									<td>
										<c:choose>
									    	<c:when test="${list.OptionType eq 'Date'}">
												<input class="adDate txtVal" data-axbind="date" date_separator="."  type="text" kind="date" value="${list.OptionVal}" >
									    	</c:when>
									    	<c:when test="${list.OptionType eq 'TextArea'}">
												<textarea class="txtVal w100">${list.OptionVal}</textarea>
									    	</c:when>
									    	<c:when test="${list.OptionType eq 'linkURL'}">
												<input type=text class="txtVal HtmlCheckXSS ScriptCheckXSS MaxSizeCheck w100" max="150" name="optionVal" value="${list.OptionVal}" readonly/>
									    	</c:when>
									    	<c:otherwise>
									    		<input type=text class="txtVal HtmlCheckXSS ScriptCheckXSS SpecialCheck MaxSizeCheck w100" max="150" name="optionVal" value="${list.OptionVal}" />
									    	</c:otherwise>
									    </c:choose>	
									</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>

				<!-- 버튼영역 -->
				<div class="popBtnWrap">
					<c:if test="${taskData =='' || taskData.TaskSeq eq null  }">
						<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.lbl_AddTask'/></a> 	<!-- 업무 추가 -->
					</c:if>
					<c:if test="${taskData !='' && taskData.TaskSeq ne null  }">
						<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_SaveTask'/></a> 	<!-- 업무저장 -->
					</c:if>
					<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a> 		<!-- 취소 -->
				</div>
			</div>
			
		</div>
	</form>
<!-- ê¸°íê·¼ë¬´ë±ë¡ íì ë -->
</body>

<script type="text/javascript">


function changeRate(){
	// 진행율이 100으로 변경했을 경우, 상태를 완료로 변경. 현재 상태가 진행이 아니라면 진행율 select를 disabled함. 
	if ($("#progRate").val() == "100") {
		$("#taskStatus").val("C");	// 진행률 완료로 변경.
		$("#progRate").bindSelectDisabled($("#taskStatus").val() != "P");  // 상태가 진행(P)만 아니면 진행율 selectBox를 disabled함.
	}
}
var collabTaskAdd = {
		callbackFunc:CFN_GetQueryString("callBackFunc"),
		fileList:'',
		delPrjList:new Array(),
		bizSection:'',
		formInstanceID:'',
		subject:'',
		objectInit : function(){			
			this.addEvent();
			coviCtrl.renderAXSelect('TaskProgress', 'progRate', 'ko', 'changeRate', '', "${taskData =='' || taskData.TaskSeq eq null?'0':taskData.ProgRate}");
			
			collabTaskAdd.subject = "${subject}" != null ? "${subject}" : "";
			collabTaskAdd.bizSection = "${bizSection}" != null ? "${bizSection}" : "";
			collabTaskAdd.formInstanceID = "${formInstanceID}" != null ? "${formInstanceID}" : "";
			var fileInfo = "${fileInfo}" != null ? "${fileInfo}" : "";
			var contents = "";
			
			if(collabTaskAdd.bizSection == "Board" || collabTaskAdd.bizSection == "Approval"){
				fileInfo = Base64.b64_to_utf8(fileInfo);
				if(collabTaskAdd.subject != null && collabTaskAdd.subject != ""){
					$("#taskName").val(collabTaskAdd.subject);
                    $("#orgSubject").val(collabTaskAdd.subject);
				}
				// 첨부파일
				if(fileInfo != "" && fileInfo != "undefined"){
					collabTaskAdd.fileList = $.parseJSON(fileInfo);
				}
			} else if(collabTaskAdd.bizSection == "Mail"){
				var uid = "${uid}" != null ? "${uid}" : "";
				var msgId = "${msgId}" != null ? "${msgId}" : "";
				var boxName = "${boxName}" != null ? "${boxName}" : "";
				var userMail = "${userMail}" != null ? "${userMail}" : "";
				var folderTy = "${mailInfo}" != null ? "${folderTy}" : "";
				
				$.ajax({
		            type:"POST",
		            url: "/mail/userMail/mailFolderMsgTransfer.do",
		            data: {
		                //메일에서 조회하기 위한 정보
		     			 "uid" : uid
		                ,"msgId" : Base64.b64_to_utf8(msgId)
		                ,"boxName" : boxName
		                ,"userMail" : userMail
		                ,"folderTy" : folderTy
		            },
		            dataType : 'json',
		            async : false,
		            success:function(data){
			        	if(data.msgType === "noAuth"){
			        		Common.Warning(Common.getDic("msg_notHaveAccess"), Common.getDic("CPMail_warning_msg"));  //접근 권한 없습니다
			        	}else{					
			                if(data.status=='SUCCESS'){
			                    if(data.errMsg != ''){
			                        Common.Warning(Common.getDic("msg_sns_03"), Common.getDic("CPMail_warning_msg")); //저장 중 오류가 발생하였습니다.
			                        return;
			                    }
			                    $("#taskName").val(data.subject);
			                    contents = data.body;
			                }else{
			                    Common.Warning(Common.getDic("msg_sns_03"), Common.getDic("CPMail_warning_msg")); //저장 중 오류가 발생하였습니다.
			                }
		                }
		            },
		            error:function(error){
		                Common.Warning(Common.getDic("msg_sns_03"),Common.getDic("CPMail_warning_msg")); //저장 중 오류가 발생하였습니다.
		            }
		        });
			}
			
			// 중요도 초기 로딩 시 해당 값을 가져와서 세팅.
			if ( ("${taskData.ImpLevel}" != "") ) {
				if ( "${taskData.ImpLevel }" === "E" ) { 		// 사용안함
					$('.selectOpList>li').eq(0).click();
				} else if ("${taskData.ImpLevel }" === "H" ) { 	// 높음
					$('.selectOpList>li').eq(1).click();
				} else if ("${taskData.ImpLevel }" === "M" ) { 	// 중간
					$('.selectOpList>li').eq(2).click();
				} else if ("${taskData.ImpLevel }" === "L" ) { 	// 낮음
					$('.selectOpList>li').eq(3).click();
				}	
			}else{
					$('.selectOpList>li').eq(0).click();
			}

			
			// 상태가 진행(P)이 아니면 진행율을 disabled함.
			$("#progRate").bindSelectDisabled($("#taskStatus").val() != "P");	
			
			// taskStatus가 완료이면 진행률을 100%로 표시.
			$("#taskStatus").trigger('change');
			
			// 담당자 관련
			collabUtil.attachDeptEventAutoTags("resultViewMemberInput",{"prjType":"${prjType}","prjSeq":"${prjSeq}"});
			$(".ui-autocomplete-multiselect.ui-state-default.ui-widget").removeAttr('style');
			
			//내업무일 때 담당자에 내 프로필 추가
			if("${prjType}" == "M"){
				var code = Common.getSession("UR_ID");
				var CodeName = Common.getSession("UR_Name");
				var DisplayName = CFN_GetDicInfo(Common.getSession("UR_MultiName"));
				var DeptName = CFN_GetDicInfo(Common.getSession("GR_MultiName"));
				var PhotoPath = Common.getSession("PhotoPath");
				
				$("#resultViewMember input").before(collabUtil.drawProfile({
					"type":"UR",
					"code":code,
					"codeName":CodeName,
					"DisplayName":DisplayName,
					"DeptName":DeptName,
					"PhotoPath":PhotoPath
				}, false));
			}

			// 변경화면 첨부파일
			<c:if test="${fileList !='' && fileList ne null  }">
				collabTaskAdd.fileList= JSON.parse('${fileList}');
			</c:if>
			coviFile.renderFileControl('con_file', {listStyle:'div', actionButton :'add', multiple : 'true', image : 'false'}, collabTaskAdd.fileList);
			// 변경화면 첨부파일
			
		    <c:if test="${taskData.FileName ne null}">
		    	// taskData 에는 파일정보 없고, #prevImg , .task_img 모두 없는 dom 이므로 제거
		    	// 추후 필요하다면 coviCmn.loadImageId 이용 필요 - coviCmn.loadImageId("Collab", "${fileList.FileID}")
			    //$("#prevImg").attr("src", coviCmn.loadImageFilePath("Collab", "${taskData.FilePath}", "${taskData.SavedName}"));
			    $(".task_img").show();
		    </c:if>
		    
		    // 조직도 담당자 추가
			<c:forEach items="${memberList}" var="list" varStatus="status">
				$("#resultViewMember input").before(collabUtil.drawProfile({"type":"UR","code":"${list.UserCode}", "UserID":"${list.UserID}","PhotoPath":"${list.PhotoPath}","DisplayName":"${list.DisplayName}","DeptName":"${list.DeptName}","UserID":"${list.UserID}"}
				,"true", "member")); 
			</c:forEach>
			
			<c:if test="${fn:length(mapList) > 0 }">
				<c:forEach items="${mapList}" var="item" varStatus="status">
					taskMapData.PrjSeq = "${item.PrjSeq}";
					taskMapData.PrjType = "${item.PrjType}";
					taskMapData.PrjName = "${item.PrjName}";
					taskMapData.SectionSeq = "${item.SectionSeq}";
					taskMapData.SectionName = "${item.SectionName}";
				</c:forEach>
			</c:if>
			taskMapData.taskSeq = "${taskData.TaskSeq}";
			
			// 설명 에디터 여부.
			<c:if test="${isUseDescEditor eq 'Y'}">
				$("#remark").hide(); 		// textarea hide.
				
				coviEditor.loadEditor( 		// editor load.
					'descEditor',
					{
						editorType : g_editorKind,
						containerID : 'tbContentElement',
						frameHeight : '300',
						focusObjID : '',
						onLoad:  function() {
							if(collabTaskAdd.bizSection == "Mail"){
								coviEditor.setBody(g_editorKind, 'tbContentElement', contents);
							} else{
								coviEditor.setBody(g_editorKind, 'tbContentElement', unescape('${Remark}'));	
							}
						}
					}
				);
			</c:if>
			
		}	,
		addEvent : function(){
			
			//툴팁
			Common.toolTip($("#toolTipToggle"), Array("collabTask1","collabTask2","collabTask3"));
			
			// 긴급 on/off 버튼 이벤트.
			$(".btn_important").on('click', function() {
				if ( $(".btn_important").hasClass("on") ) {
					$(".btn_important").removeClass("on");
				} else {
					$(".btn_important").addClass("on");
				}
			});
			
			// 중요도 select 클릭 이벤트
			$('.sleOpTitle').on('click', function(){
		 		if($(this).hasClass('active')){
		 			$(this).removeClass('active');
		 			$('.selectOpList').removeClass('active');
		 		}else {
		 			$(this).addClass('active');
		 			$('.selectOpList').addClass('active');
		 		}
		 	});
			// 중요도 select 값 선택 입력.
			$('.selectOpList>li').on('click', function(){
		 		$('.sleOpTitle').html($(this).html());
		 		$('.selectValue').val($(this).data( "selvalue" ));
		 		$('.sleOpTitle').removeClass('active');
		 		$(this).closest('.selectOpList').removeClass('active');
		 	});
			
			//담당자 추가
			$("#btnMember").on('click', function(){
				if("${prjType}" == 'M' || "${prjType}" == "undefined" || "${prjType}" == ""){
					collabTaskAdd.openOrgMapLayerPopup('orgMemberCallback', '');//전사 노출
				}else{
					collabTaskAdd.openCollabMapLayerPopup('orgMemberCallback2','');
				}	
			});
			//사용자나 부서/일자 삭제
			$(document).on('click', '.btn_del', function(e) {
				e.preventDefault();
				$(this).parent().remove();
			});
			
		 	//확장필드 전체선택
		 	$("#allChk").on('click', function(){
				$('#tblUserForm > tbody input[type="checkbox"]').prop("checked",$(this).is(":checked"));
			});
		 	
		 	//확장필드 삭제
			$("#btnDelUser").on('click', function(){
				if($('#tblUserForm > tbody input[type="checkbox"]:checked').size() < 1)
					Common.Inform("<spring:message code='Cache.msg_Common_03' />");	//삭제할 항목을 선택하여 주십시오.
					
				$('#tblUserForm > tbody input[type="checkbox"]:checked').each(function (i, v) {
					$(v).parents("tr").remove();
				});
			});

			//확장필드 추가
			$("#btnAddUser").on('click', function(){
				if ($('#tblUserForm tbody tr').length < 11){
					 $('#tblUserForm > tbody:last').append('<tr>'+
							 '<td><input type=checkbox></td>'+
							 '<td><input type=text class="txtTitle" name="optionTitle"></td>'+
							 '<td><input type=text class="txtVal" name="optionVal"></td>'+
						'</tr>');
				}
				else{
					
				}
			});
		 	
			//프로젝트 추가
		 	$(document).on('click', '#btnAddPrjoject', function(e) {
		 		collabUtil.openProjectAllocPopup(CFN_GetQueryString("taskSeq"), "N", "saveTaskAllocPopup");
			});
			
			//프로젝트 삭제
			$(document).on('click', '#btnDelProject', function(e) {
				var projectData = { "taskSeq":CFN_GetQueryString("taskSeq"), 
						"prjseq":$(this).attr('data-prjseq'),
						"prjtype":$(this).attr('data-prjType'),
						"prjname":$(this).attr('data-prjName')};
				collabTaskAdd.delPrjList.push(projectData);
				$(this).parent('div').parent('div').remove();
				
				if ($('#divPrjList').find('div.control_box').length == 0) {
					$('#divPrjList').append('<span class="control_box"><a href="#" class="btn_plus" id="btnAddPrjoject"></a></span>');
				} else {
					if ($('#divPrjList').find('.control_box').first().find('.btn_plus').length == 0){
						$('#divPrjList').find('.control_box').first().append('<a href="#" class="btn_plus" id="btnAddPrjoject"></a>');
					}
				}
			});

			
			$("#btnSave").on('click', function(){
				if(!collabTaskAdd.validationChk(false))     	return ;

				var msg = "<spring:message code='Cache.msg_RUSave' />";
				if ( $("#taskStatus").val() == "C" && $('.relatedTask[data-status="NOT"').length> 0){
					msg = Common.getDic("msg_AfComplet").replace("{0}",$('.relatedTask ').attr("data-taskname"));
				}
				Common.Confirm(msg, "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var taskData = collabTaskAdd.getTaskData();
						
						$.ajax({
							type:"POST",
							enctype: 'multipart/form-data',
							data: taskData,
							processData: false,
							contentType: false,
							url:"/groupware/collabTask/saveTask.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>", "Confirmation Dialog", function (confirmResult) {
										if(parent.$('#btnReload').length>0) {
											parent.$('#btnReload').trigger('click');
										} else if(parent.$('.btnRefresh').length>0) {
											parent.$('.cRContCollabo_sub:visible .btnRefresh').trigger('click');
										}
										
										Common.Close();
									});
								}
								else{
									if (data.exception.indexOf("MultipartException")>-1){
										Common.Error("<spring:message code='Cache.msg_ExistLimitedExtensionFile' />"); //	파일 ulload
									}else{
										Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
									}	
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					}});	
			});
			
			$("#btnAdd").on('click', function(){
				if(!collabTaskAdd.validationChk(true))     	return ;
				Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var taskData = collabTaskAdd.getTaskData();
						var taskSeq = "";
						$.ajax({
							type:"POST",
							enctype: 'multipart/form-data',
							data: taskData,
							processData: false,
							contentType: false,
							async: false,
							url:"/groupware/collabTask/addTask.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									if(collabTaskAdd.bizSection == "Approval"){
										taskSeq = data.taskSeq;
									} else{
										Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>", "Confirmation Dialog", function (confirmResult) {
											if(parent.$('#btnReload').length>0) {
												parent.$('#btnReload').trigger('click');
											} else if(parent.$('.btnRefresh').length>0) {
												parent.$('.cRContCollabo_sub:visible .btnRefresh').trigger('click');
											}
											
											Common.Close();
										});
									}
								}
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
						
						if(taskSeq != ""){
							//관련결재 pdf 저장
							$.ajax({
								type:"POST",
								data: {
									"taskSeq":taskSeq,
									"formInstanceID":collabTaskAdd.formInstanceID,
									"subject":collabTaskAdd.subject
								},
								url:"/approval/user/transferPdfCollab.do",
								success:function (data) {
									if(data.status == "SUCCESS"){
										Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");	// 성공적으로 처리되었습니다.
										parent.$('.cRContCollabo_sub:visible .btnRefresh').trigger('click');
										//parent.collabMenu.getUserMenu();
										Common.Close();
									} else{
										Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
									}
								},
								error:function (request,status,error){
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
								}
							});
						}
					}
				});	
			});
			
			// 상태를 완료로 변경하면 진행율을 100%로 변경하고, 상태가 진행이 아니면 disabled 함.
			$("#taskStatus").on('change', function() {
				if ( $("#taskStatus").val() === "C" ) {
					$("#progRate").setValueSelect("100");
				}
				$("#progRate").bindSelectDisabled( $("#taskStatus").val() != "P" );
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
			
			$("#file").on("change", function(){
				var file = $(this)[0].files[0];
				
				if(file.name != ""){
					var pathPoint = file.name.lastIndexOf('.');
					var filePoint = file.name.substring(pathPoint + 1, file.name.length);
					var fileType = filePoint.toLowerCase();
					
					if(file.size > 1000000){
						Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
						$(this).val("");
						$("#prevImg").attr("src", "");
					}else{
						var imgObj = $("#prevImg");
						imgObj.show();
						$(".file_name01 strong").text(file.name);
						
						if (this.files && file) {
							var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
							reader.onload = function (e) {
								//파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
						        imgObj.attr("src", e.target.result);
						    }                   
						    reader.readAsDataURL(file);
						}
					}
				}
			});
			
			$("#btnTag").on('click', function(e) {
				var cardData = {"taskSeq": CFN_GetQueryString("taskSeq")
						,"taskName" : "${taskData.TaskName}"};
				collabTaskAdd.popTaskTag(cardData, "callbackTaskTag");
				
			});
			
			//tag 삭제
			$(document).on('click', '#tag_del', function(e) {
				var obj = this;
				$(obj).closest("li").remove();
			});
			
			//ì¬ì©ìë ë¶ì/ ì¼ì ì­ì 
			$(document).on('click', '.ui-icon-close', function(e) {
				e.preventDefault();
				$(this).parent().remove();
			});
			
			$(document).on('click', '.file_down', function(e) {
				Common.fileDownLoad($(this).closest("div").data("fileid"), $(this).closest("div").text(), $(this).closest("div").data("filetoken"));//data-fileext
			});
			
			
			//관련결재 삭제
			$(document).on('click', '#approval_del', function(e) {
				var obj = this;
				
				//파일 정보 삭제
				$.ajax({
					type:"POST",
					data: {"fileID":$(obj).closest("div").attr('data-fileid')},
					url:"/groupware/collabTask/deleteTaskFile.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>"); // 성공적으로 처리되었습니다.
							$(obj).closest("li").remove();
						}
						else{
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
						}
					},
					error:function (request,status,error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.	
					}
				});
			});
			
			// 23.02.16, 담당자를 자동완성 기능으로 추가 시, 중복 표기 방지.
			var observer = new MutationObserver(function(mutations) {
				var duplication = false;
				var code = $("#resultViewMember .user_img").last().attr("code");
				var type = $("#resultViewMember .user_img").last().attr("type");
				
				if ($('#resultViewMember').find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 1) {
					duplication = true;
				}
				
				if (duplication) {
					Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
					$("#resultViewMember .user_img").last().remove();
				}
			});

			var optionObserver = {
			    childList: true,
			    subtree : true
			};

			observer.observe($("#resultViewMember")[0], optionObserver);
			// 23.02.16, 담당자 자동완성 기능으로 추가 시, 중복 표기 방지.
			
		},
		getTaskData:function(){
			
			var trgUserFormArr = new Array();
		 	$('#tblUserForm tbody tr').each(function (i, v) {
				var item = $(v);
				if (item.find('.txtTitle').val() != ""){
					var saveData = { "optionTitle":item.find('.txtTitle').val(), "optionVal":item.find('.txtVal').val(), "optionType":item.find('.txtType').val()};
					trgUserFormArr.push(saveData);
				}	
			});

		 	var delFileArr = new Array();
		 	for (var i=0; i < collabTaskAdd.fileList.length; i++){
		 		var bFind=false;
			 	for (var j=0; j < coviFile.fileInfos.length; j++){
		 			if (collabTaskAdd.fileList[i].FileID == coviFile.fileInfos[j].FileID){
		 				bFind=true;
		 				break;
		 			}
			 	}
		 		if (bFind== false){
		 			delFileArr.push(collabTaskAdd.fileList[i]);
		 		}
		 	}
			
		 	// 관련업무정보
		 	var linkTaskArr = new Array();
		 	var strlinkF = "";
		 	var strLinkTask = "";
		 	var linkTaskList = $("#divLinkTask").children('div');
		 	if ( linkTaskList.length >= 1 ) {
		 		for (var i=0;linkTaskList.length > i ; i++) {
		 			if ( (typeof(linkTaskList.eq(i).find("input").prop("data-value")) === "number") && (i == 0) ) {
		 				strLinkTask = linkTaskList.eq(i).find("input").prop("data-value");
		 			} else {
		 				strLinkTask = linkTaskList.eq(i).find("input").attr("data-value");
		 			}
		 			strlinkF = linkTaskList.eq(i).find("select").val();
		 			if (strlinkF != undefined && strlinkF != "" && strLinkTask != undefined && strLinkTask != "") {
		 				linkTaskArr.push({ "linkF" : strlinkF, "linkTask" : ""+strLinkTask });	
		 			}
		 		}	
		 	}
	 		
			var formData = new FormData($('#form1')[0]);
			
			// 설명에 에디터를 사용하도록 되어 있다면, 에디터의 값을 formData에 세팅.
			<c:if test="${isUseDescEditor eq 'Y'}">
				formData.append("body", escape(coviEditor.getBody(g_editorKind, 'tbContentElement')));
				formData.append("bodyText", coviEditor.getBodyText(g_editorKind, 'tbContentElement'));
				formData.append("remarkText", coviEditor.getBodyText(g_editorKind, 'tbContentElement'));
				formData.append("bodyInlineImage", escape(coviEditor.getImages(g_editorKind, 'tbContentElement')));
				formData.append("frontStorageURL", escape(Common.getGlobalProperties("smart4j.path")+ Common.getBaseConfig("FrontStorage")));
				formData.append("bodyBackgroundImage", escape(coviEditor.getBackgroundImage(g_editorKind, 'tbContentElement')));				
			</c:if>
						
			<!-- 긴급 여부 -->
			if ( $(".btn_important").hasClass("on") ) {
				formData.append("label", "E");
			} else {
				formData.append("label", "");
			}
			<!-- 상태 - 대기(W),진행(P)... -->
			formData.append("taskStatus", $("#taskStatus").val());
			if ("${taskData.TaskStatus}" != $("#taskStatus").val()) formData.append("isSend", "Y"); 	// 상태가 변경되었을 시, isSend 값을 지정.

			
			formData.append("progRate", $("#progRate").val());
			formData.append("taskSeq", "${taskData.TaskSeq}");
			formData.append("prjType", "${prjType}");
			formData.append("prjSeq", "${prjSeq}");
			formData.append("prjName", "${prjName}");
			formData.append("sectionSeq", "${sectionSeq}");
			formData.append("sectionName", "${sectionName}");
			formData.set("taskName", $("#taskName").val().replace(/\'/gi, "′").replace(/\"/gi, "″"));
			
			if(collabTaskAdd.bizSection != ""){
				formData.append("objectType", collabTaskAdd.bizSection);
			}
			
			formData.append("trgMember", JSON.stringify(collabUtil.getUserArray("resultViewMember")));
			formData.append("trgUserForm", JSON.stringify(trgUserFormArr));
			formData.append("delFile", JSON.stringify(delFileArr));
			if ("${taskData.IsMile}" == 'Y'){
				formData.append("startDate", $("#endDate").val());
			}
			
			// 22.03.02, 중요도 포함.
			formData.append("impLvl", $("#impLvl").val());
			formData.append("linkTaskList", JSON.stringify(linkTaskArr));
			
			// 22.03.14, 태그 정보 포함.
			var tagArray = new Array();
		 	$('#tagList span').each(function (i, v) {
				tagArray.push( $(v).text().substring(1));
			});
			formData.append("tags", JSON.stringify(tagArray));	
			
			formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
		    for (var i = 0; i < coviFile.files.length; i++) {
		    	if (typeof coviFile.files[i] == 'object') {
		    		formData.append("file", coviFile.files[i]);
		        }
		    }
		    // 팀/프로젝트
		    var addPrjList = new Array();
			if ("${taskData.ParentKey}" == 0){
			 	$("#divPrjList").children('div').each(function (i, v) {
					var projectData = {"taskSeq":CFN_GetQueryString("taskSeq"), 
					"PrjSeq":$(v).attr('data-prjSeq'), 
					"PrjType":$(v).attr('data-prjType'), 
					"SectionSeq":$(v).attr('data-sectionSeq'), 
					"PrjName":$(v).attr('data-prjName')};
					addPrjList.push(projectData);
				});
			}
		    formData.append("addPrjList", JSON.stringify(addPrjList));
		    formData.append("delPrjList", JSON.stringify(collabTaskAdd.delPrjList));
		    
			return formData;
		},
		openCollabMapLayerPopup:function(callBackFunc, sType){
			var popupUrl = "/groupware/collab/CollabTargetListPopup.do?callback="+callBackFunc+"&callbackType=O&prjSeq=${prjSeq}&prjType=${prjType}";
			
			var title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
			var w = "500";
			var h = "650";
			CFN_OpenWindow(popupUrl,"openCollabLayerPop",w,h,"");
		},
		openOrgMapLayerPopup:function(callBackFunc, trgId){
			var trgArr = new Array();
		 	$('#'+trgId).find('.user_img').each(function (i, v) {
				var item = $(v);
				var userData = { "itemType":"user", "code":item.data('code'), "UserCode":item.data('code'), "UserID":item.data('UserID'), "DN":item.data('DisplayName'), "RGNM":item.data('DeptName'),"Dis":true};
				trgArr.push(userData);
			});
		 	initData["item"] = trgArr		 	
		 	
			url = "/covicore/control/goOrgChart.do?callBackFunc="+callBackFunc+"&type=B9&treeKind=Group&groupDivision=Basic&drawOpt=_MARB&setParamData=initData";			
			
			var title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
			var w = "1000";
			var h = "580";
			CFN_OpenWindow(url,"openGroupLayerPop",w,h,"");
			
		},
		orgMapLayerCallback:function(list, tagId, popType){
			var duplication = false; // 중복 여부
			
			$.each(list, function (i, v){
				var type = 'UR';
				var code = v.UserCode;
				if (!v.Dis  ) {
					if ($('#'+tagId).find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 0) {
						duplication = true;
						return true;;
					}
					var cloned ;
					if (tagId == "resultViewMember" && popType == "Y")
	    				cloned = collabUtil.drawProfile({"code":code, "codeName":v.DisplayName,"type":type,"DisplayName":CFN_GetDicInfo(v.DisplayName), "DeptName":CFN_GetDicInfo(v.DeptName), "data":v}, true);
					else
	    				cloned = collabUtil.drawProfile({"code":code, "code":code,"type":type,"DisplayName":CFN_GetDicInfo(v.DN), "DeptName":CFN_GetDicInfo(v.RGNM), "data":v}, true);
					$('#'+tagId+' .ui-autocomplete-input').before(cloned);
				}	
			});
			
			if(duplication){
				Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
			}
	 	},
	 	validationChk:function(isNew){ // isNew = true : 업무 신규 등록, isNew = false : 기존 업무 수정	
			var returnVal= true;
			
			// 상태값 체크. 필수값.
			if ( $("#taskStatus").val() == undefined || $("#taskStatus").val() == "" ) {
				Common.Warning("<spring:message code='Cache.msg_task_selectState'/>");
			    return false;
			}
			
			if ($('#progRate').val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}", "<spring:message code='Cache.lbl_projectProgressRate' />"));
			    return false;
			}
			if(!(0 <= $("#progRate").val() && $("#progRate").val() <= 100)){
				Common.Warning("<spring:message code='Cache.msg_checkPercent'/>", "Warning Dialog") //진행율을 0~100이하로 입력해주세요.
				return false;
			}
			
			// 선행업무
			var linkTaskList = $("#divLinkTask").children('div');
			var cntLinkF = 0;
			for (var i=0;linkTaskList.length > i ; i++) {
				if ( (i == 0) && (linkTaskList.eq(i).find("select").val() === "linkAF") ) {
					if (typeof(linkTaskList.eq(i).find('input').prop("data-value")) === "number") {
						cntLinkF++;
					}
				} else if (linkTaskList.eq(i).find("select").val() === "linkAF") {
					cntLinkF++;
				}
			}
			if ( cntLinkF > 1) {
				Common.Warning("<spring:message code='Cache.msg_collab23' />","Warning Dialog");	//선행업무는 1개만 등록 가능합니다.
				return false;
			}
			//자동완성 안 된 담당자 체크
			if($.trim($("#resultViewMemberInput").val()).length > 0 ){
				Common.Warning("<spring:message code='Cache.lbl_apv_noenter' />(<spring:message code='Cache.lbl_charge' />)"); // 입력 되지 않았습니다. (담당자)
				return;
			}
			//담당자 체크
			if($('#resultViewMember').find('.user_img').length == 0){
				if(isNew) {
					//TODO alert 교체 필요
					alert("<spring:message code='Cache.msg_managerIsRegistrant'/>");	//신규 생성시 생성자가 담당자가 됩니다.
				}else{
					Common.Warning("<spring:message code='Cache.msg_addManager'/>","Warning Dialog");	 //담당자를 추가하세요.
					return false;
				}
			}
			
			return returnVal;
	 },
	 orgMapLayerPopupCallBack:function(orgData, reqOrgMapTarDiv) {
			var data = $.parseJSON(orgData);
			var item = data.item
			var len = item.length;

			if (item != '') {
				var duplication = false; // 중복 여부
				$.each(item, function (i, v) {
					//var cloned = collabProjectAdd.orgMapDivEl.clone();
					var type = (v.itemType == 'user') ? 'UR' : 'GR';
					var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;
					
					if (!v.Dis  ) {
						if ($('#' + reqOrgMapTarDiv).find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 0) {
							duplication = true;
							return true;;
						}
						
	    				var cloned = collabUtil.drawProfile({"code":code,"type":type,"DisplayName":CFN_GetDicInfo(v.DN), "data":v}, true);
	    				$('#' + reqOrgMapTarDiv + ' .ui-autocomplete-input').before(cloned);
					}	
				});
				
				if(duplication){
					Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
				}
					
			}
		}
	 
	// 태그 추가 팝업 
	, popTaskTag : function(cardData, callBackFunc) {
		var popupID	= "CollabTaskTagPopup";
		var popupTit	= (cardData.taskSeq== ""? "":"["+cardData.taskName + "] ")+Common.getDic("lbl_Tag"); //태그
		var callBack	= "";
		var popupUrl	= "/groupware/collabTask/CollabTaskTagPopup.do?"
						+ "&taskSeq="       + cardData.taskSeq
						+ "&popupID="		+ "CollabTaskTagPopup"	
						+ "&openerID="		+ ""
						+ "&popupYN="		+ "N"	
						+ "&callBackFunc="	+ callBackFunc	;
		parent.Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);
	 },
	
	// 관련업무 추가 버튼 클릭 이벤트
	addLinkTask : function(obj) {
		var strPrjType = "";
		if ("${prjType}" == 'M' || "${prjType}" == "undefined" || "${prjType}" == "") {
			strPrjType = "M";
		} else {
			strPrjType = "${prjType}";
		}
		
		if ( $("#inptLinkTask").prop("disabled") === false && typeof($("#inptLinkTask").prop("data-value")) === "undefined") {
			// 새로 추가
			collabUtil.openTaskLinkPopup(strPrjType,"${prjSeq}");
		} else {
			// 선행업무 입력 체크
			var linkTaskList = $("#divLinkTask").children('div');
			var cntLinkF = 0;
			for (var i=0;linkTaskList.length > i ; i++) {
				if ( (i == 0) && (linkTaskList.eq(i).find("select").val() === "linkAF") ) {
					if (typeof(linkTaskList.eq(i).find('input').prop("data-value")) === "number") {
						cntLinkF++;
					}
				} else if (linkTaskList.eq(i).find("select").val() === "linkAF") {
					cntLinkF++;
				}
			}
			if ( cntLinkF > 1) {
				Common.Warning("<spring:message code='Cache.msg_collab23' />","Warning Dialog");	//선행업무는 1개만 등록 가능합니다.
				return false;
			}
			
			var strHtml = "<div style='margin-top: 5px;'>";
			strHtml += "<select type='text' class='selectType02' name='linkTask' disabled>";
			// 선행/후행업무 선택값.
			if ($("#linkTask").val() === "linkAF") {
				strHtml += "<option value='linkAF'><spring:message code='Cache.lbl_LinkAF' /></option></select>";	
			} else if ($("#linkTask").val() === "linkBF") {
				strHtml += "<option value='linkBF'><spring:message code='Cache.lbl_LinkBF' /></option></select>";
			}
			var linkTaskStr = $('#inptLinkTask').val();
			var linkTaskSeq = $("#inptLinkTask").prop("data-value");
			strHtml += "<input value='"+ linkTaskStr +"' data-value='"+linkTaskSeq+"' class='taskName' style='margin-left: 5px' disabled/>";
			strHtml += "<div class='control_box' style='margin-left: 14px;' >";
			strHtml += "<a onclick='collabTaskAdd.delLinkTask(this)' class='btn_remove'>삭제</a>";
			strHtml += "</div></div>";
			
			if ((linkTaskStr.length>0) && (typeof(linkTaskSeq) === "number")) {
				$("#divLinkTask").append(strHtml);
			}
			
			collabUtil.openTaskLinkPopup(strPrjType,"${prjSeq}");
			
			$("#inptLinkTask").val("");
			$("#inptLinkTask").prop("data-value", "")
		}
	},
	
	// 추가로 인해 생긴 관련업무 삭제 버튼 클릭 이벤트
	delLinkTask : function(param) {
		var $obj = $(param);
		// 신규와 수정을 구분.
		if ( CFN_GetQueryString("taskSeq") === "" ) {
			// 신규일 때.
			$obj.parent('div').parent('div').remove();	
		} else {
			// 수정일 때.
			var strLinkStatus = $obj.parent('div').parent('div').find('select').val(); 
			var linkTaskSeq = $obj.parent('div').parent('div').find('input').attr("data-value"); 
			var taskSeq = CFN_GetQueryString("taskSeq"); 
			var param = {};
			if (strLinkStatus === "linkAF") {	// 선행업무
				param = {"taskSeq" : taskSeq};
			} else if (strLinkStatus === "linkBF") { 	//  후행업무
				param = {"taskSeq" : linkTaskSeq};
			}
			$.ajax({
				type : "POST",
				data : param,
				url : "/groupware/collabTask/deleteTaskLink.do",
				success:function (data) {
					if(data.status == "SUCCESS") {
						$obj.parent('div').parent('div').remove();
						Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");		// 성공적으로 처리되었습니다.
					} else {
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); 		// 오류가 발생하였습니다.
					}
				},
				error:function (request,status,error) {
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />");			// 오류가 발생하였습니다.
				}
			});
		}
	},
	// 관련업무 첫번째 항목 삭제 클릭.
	delFrstLinkTask : function() {
		$("#inptLinkTask").val("");
		$("#inptLinkTask").prop("data-value","");
		$("#inptLinkTask").prop("disabled", false);
	},
	
	saveTaskAllocPopup:function(folderData){
		// 중복체크
		var duplication = false;
		var prjname = '';
		$("#divPrjList").children('div').each(function (i, v) {
		if ($(v).attr('data-prjSeq') == folderData.PrjSeq && 
				$(v).attr('data-prjType') == folderData.PrjType){
					duplication = true;
					prjname = folderData.PrjName;
					return true;
		 	}
		});
		if(duplication){
			Common.Warning(prjname+'<spring:message code="Cache.msg_AlreadyAdd" />');
		}else{
			$("#divPrjList").find('span.control_box').remove();

			var sHtml = "";
			sHtml += '<div data-prjName="'+folderData.PrjName+'" data-prjType="'+folderData.PrjType+'" data-prjSeq="'+folderData.PrjSeq+'" data-sectionSeq="'+folderData.SectionSeq+'">';
			sHtml += '<input value="'+folderData.PrjName+'" readonly class="taskName"> ';
			sHtml += '<input value="'+folderData.SectionName+'"  readonly class="selectType02"> ';
			sHtml += '<div class="control_box">';	
			sHtml += '<a href="#" class="btn_remove" id="btnDelProject"  data-prjName="'+folderData.PrjName+'"   data-prjType="'+folderData.PrjType+'"  data-prjSeq="'+folderData.PrjSeq+'"></a>';		
			sHtml += '</div>';
			sHtml += '</div>';				
			$("#divPrjList").append(sHtml);

			var firstCntlBox = $('#divPrjList').find('div.control_box').first();
			if (firstCntlBox.find('.btn_plus').length == 0){
				firstCntlBox.append('<a href="#" class="btn_plus" id="btnAddPrjoject"></a>');
			}			
		}
	},

	
	getApprovalList:function(){
		var param = {"taskSeq" : CFN_GetQueryString("taskSeq")};
		$.ajax({
			url:"/groupware/collabTask/collabFileList.do",
			type:"POST",
			data:param,
			success:function (data) {				
				var sHtml = "";
				$("#collabApprovalList").html("");
				if(data.fileList.length > 0){
					$(data.fileList).each(function(i,v){
							sHtml += '<li><div class="" data-filesize="'+v.Size+'" data-fileid="'+v.FileID +'" data-filetoken="'+v.FileToken+'" data-fileext="'+v.Extention+'">';
							sHtml += '<span class="btn_dfile"><a class="file_down">';
							sHtml += '<span class="'+collabUtil.getFileClass(v.Extention)+'"></span>';
							sHtml += v.FileName;
							sHtml += '</a><a class="tag_del" id ="approval_del"></a></span></div></li>';
	    			});
				}
				$("#collabApprovalList").append(sHtml);
			},
			error:function (error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.	
			}
		});
	},
}

var taskMapData = new Object();

$(document).ready(function(){
	collabTaskAdd.objectInit();
});

function orgMemberCallback(orgData){
	var data = $.parseJSON(orgData);
	var item = data.item
	collabTaskAdd.orgMapLayerCallback(item, "resultViewMember");
}

function orgMemberCallback2(orgData){
	var data = $.parseJSON(orgData);
	var item = data.item
	collabTaskAdd.orgMapLayerCallback(item, "resultViewMember", "Y");
}

window.addEventListener( 'message', function(e){
    // 부모창의 함수 실행
    switch (e.data.functionName){
        case "saveTaskAllocPopup":
    	    collabTaskAdd.saveTaskAllocPopup(e.data.params);
	    	break;
	    case "orgMemberCallback":
	    	var orgData = e.data.params.list;
	    	collabTaskAdd.orgMapLayerCallback(orgData, "resultViewMember");
			break;
	    case "orgMemberCallback2":
	    	var orgData = e.data.params.list;
	    	collabTaskAdd.orgMapLayerCallback(orgData, "resultViewMember", "Y");
			break;
	    case "callbackApprovalList":
	    	collabTaskAdd.getApprovalList();
	    	break;
    }
});
window.parent.addEventListener( 'message', function(e){
    // 부모창의 함수 실행
    switch (e.data.functionName){
	    case "callbackTaskTag" :
	    	var params = e.data.params;
	    	$("#tagList").show();
	    	$("#tagList").append($("<li>").append($('<div data-tagid="'+params.tagid+'">')
					.append($("<span>",{"class":"btn_dtag bg0"+(Math.floor(coviCmn.random() * 4)+1),"text":"#"+params.TagName}))
					.append($("<a>",{"class":"tag_del","id":"tag_del"}))
			));
	    	break;
	    case "callbackTaskLinkKanban" :
	    	// 관련업무 팝업 콜백.
	    	var taskData = e.data.params
	    	if (taskData.Type === "selected") {
	    		$("#inptLinkTask").prop("data-value", taskData.TaskSeq);
				$("#inptLinkTask").val(taskData.TaskName);
				$("#inptLinkTask").prop("disabled", true);	
	    	} else if (taskData.Type === "close") {
	    		$("#inptLinkTask").prop("data-value", "");
				$("#inptLinkTask").val("");
				$("#inptLinkTask").prop("disabled", false);
	    	}
	    	
	    	break;
    }
});



</script>
