<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ page import="egovframework.coviframework.util.ComUtils" %>	
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="el" uri="/WEB-INF/tlds/el-functons.tld"%>
<!doctype html>
<% pageContext.setAttribute("CR", "\r");
pageContext.setAttribute("LF", "\n");
pageContext.setAttribute("CRLF", "\r\n");
pageContext.setAttribute("BR", "<br/>");
pageContext.setAttribute("QT", "'");
pageContext.setAttribute("SQ", "\\'");
%>
<!-- 개행문자 변환처리 -->
<c:set var="Remark" value="${fn:replace(taskData.Remark,CRLF, BR)}" />
<c:set var="Remark" value="${fn:replace(Remark,CR, BR)}" />
<c:set var="Remark" value="${fn:replace(Remark,LF, BR)}" />
<c:set var="Remark" value="${fn:replace(Remark,QT, SQ)}" />

<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js"></script>
<style>
#subViewMember{border:0px}
.btn_arrow_c{display:table-cell}
</style>
<body>
<c:if test="${taskData eq null}"> 
	<script language='javascript'>
		Common.Warning(Common.getDic("msg_not_access_delete"), "Warning", function(result){ // 접근권한이 없거나 삭제된 업무입니다.
			window.close();
		});
	</script>;
</c:if>
<c:if test="${taskData ne null}"> 

<form id="form1">
	<input type="file" multiple id="file" name="file" >
</form>
	<div class="popCont popTask" style="width:100%; left:0; top:0; z-index:104;" id="CollabTaskPopup">
		<div class="pop_top">
			<div class="pop_l">
				<c:if test="${authSave eq 'Y'}"> 
				<div class="chkStyle10">
					<input type="checkbox" id="chk_${taskData.TaskSeq}" ${taskData.TaskStatus=='C'?'checked':''} data-taskSeq="${taskData.TaskSeq}"><label for="chk_${taskData.TaskSeq}"><span class="s_check"></span><spring:message code='Cache.lbl_CompleteIt' /></label> <!--완료하기  -->
				</div>
				<c:if test="${taskData.ParentKey eq 0}"> 
					<div class="chkStyle10">
						<input type="checkbox" id="chkM_${taskData.TaskSeq}" ${taskData.IsMile=='Y'?'checked':''} data-taskSeq="${taskData.TaskSeq}"><label for="chkM_${taskData.TaskSeq}"><span class="s_check"></span><spring:message code='Cache.lbl_Mile' /></label> <!--Mile-->
					</div>
					</c:if>				
				</c:if>
			</div>
			<div class="pop_r">
				<ul class="pop_btn01">
					<c:if test="${(taskData.ObjectType == 'SURVEY' && (taskData.RegisterCode == USERID && taskData.EndDate >= today && surveyComplete[0].State != 'G')) || (taskData.ObjectType != 'SURVEY' && authSave eq 'Y')}">
					<li><a href="#" class="btn_edit" id="btnDetail"></a></li>
					</c:if>
					<li><a href="#" class="btn_bookmark ${taskData.IsFav=='0'?'':'active'}" id="btnFav"></a></li>
<!--  					<c:if test="${authSave eq 'Y' && taskData.ObjectType != 'SURVEY'}">
						<li><a href="#" class="btn_file" id="btnFile"></a></li>
					</c:if>-->
					<li><a href="#" class="btn_share" id="btnShare"></a></li>
					<li><a href="#" class="btn_dot" id="btnDot"></a></li>
					<li><a href="#" class="btn_close" id="btnPopClose" style="display:none;"></a></li>
				</ul>
				<div class="ul_smenu_layer">
					<ul class="ul_smenu">
						<c:if test="${empty taskData.ObjectType}"><li><a id="btnCopy" class="btnCopy"><spring:message code='Cache.lbl_Copy' /></a></li></c:if> <!-- 복사 -->
						<c:if test="${authSave eq 'Y'}"><li><a id="btnExport" class="btnExport"><spring:message code='Cache.lbl_Move' /></a></li></c:if>  <!-- 업무내보내기 -->
						<li><a id="btnPrint" class="btnPrint"><spring:message code='Cache.lbl_Print' /></a></li> <!-- 인쇄 -->
						<li><a id="btnReload" class="btnReload"><spring:message code='Cache.lbl_Refresh' /></a></li> <!-- 새로고침 -->
						<c:if test="${authSave eq 'Y' && taskData.ObjectType != 'SURVEY'}">
							<li><a id="btnDel" class="btnDel"><spring:message code='Cache.lbl_delete' /></a></li>
						</c:if> <!-- 삭제 -->
					</ul>
				</div>
				
			</div>
		</div>
		<div class="pop_middle   viewTask">
			<div class="pop_slide">
			<!-- 타이틀
			<div class="pop_naviBox">
				<c:if test="${taskData.ParentKey ne 0}"> 
				<c:forEach items="${mapList}" var="list" varStatus="status">
					<strong class="pop_navi01">	${list.PrjName} > ${list.SectionName}</strong>
				</c:forEach>
				</c:if>+(item.IsDelay == 'Y'?' mred':'')
			</div> -->
			<div class="pop_box">
				<strong class="pop_title02 ${taskData.ParentKey ne 0?'pop_title_s ':''}  ${taskData.IsMile=='Y'?'milestone':''} ${taskData.IsMile=='Y'&&taskData.IsDelay=='Y'?' mred':''}">
					<c:if test="${taskData.IsMile=='Y'}">
						<div class="milestone">
							<input type="checkbox" id="chk14"><label for="chk14"><span class="ms_check"></span></label>
						</div>
					</c:if>
					<c:if test="${taskData.ParentKey ne 0}"> 
						<a id="parTaskSeq" data-taskseq="${taskData.ParTaskSeq}"> ${taskData.ParTaskName}</a> >
					</c:if>
					${taskData.TaskName}
				<div class="titleoption">
					<a href="#" class="btn_important ${taskData.Label == 'E'?'on':''}"><spring:message code='Cache.lbl_Urgency'/></a>
					<div class="titleoption02">${taskData.TaskStatusName}</div>
					<div class="titleoption03">${taskData.ProgRate}%</div>
				</div>
				</strong>
				<ul class="pop_table">
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_Res_Admin' /></div>
						<div class="div_td">
							<div class="date_del_scroll ATMgt_T" id="resultViewMember">
								<c:if test="${memberList.size() == 0}">
									<div class="user_img noimg"></div>
									<span class="user_name"><spring:message code='Cache.msg_not_assigned' /></span> <!-- 배정되지 않음 -->
								</c:if>
							</div>
						</div>
					</li>
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_Period' /></div> <!-- 기간 -->
						<div class="div_td">
							<c:if test="${taskData.IsMile!='Y'}">
								${el:ConvertDateFormat(taskData.StartDate,".")} - 
							</c:if>
							${el:ConvertDateFormat(taskData.EndDate,".")}
						</div>
					</li>
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_Project' /></div>
						<div class="div_td">
							<c:forEach items="${mapList}" var="list" varStatus="status">
								<p class="teamProject"><span class="chip" style="background-color:${list.PrjColor}"></span> ${list.PrjName} > ${list.SectionName}</p>
							</c:forEach>
						</div>
					</li>
					<c:if test="${fn:length(linkList)>0}">
						<li>
							<div class="div_th"><spring:message code='Cache.lbl_linkTask' /></div>
							<div class="div_td">
								<c:forEach items="${linkList}" var="list" varStatus="status">
									<p>
									<span class="relatedTask" data-taskname="${list.TaskName}" ${list.LinkType eq 'AF' && list.TaskStatus ne 'C'?'data-status="NOT"':''}><span class="precedingTask"></span>
									<c:if test="${list.LinkType eq 'AF'}">   
										<spring:message code='Cache.lbl_LinkAF' />
									</c:if>	
									<c:if test="${list.LinkType eq 'BF'}">   
										<spring:message code='Cache.lbl_LinkBF' />
									</c:if>	
									</span> ${list.TaskStatusName} > ${list.TaskName}
									</p>
								</c:forEach>
							</div>
						</li>
					</c:if>	
					<c:if test="${taskData.ImpLevel != null && taskData.ImpLevel != ''}">
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_importance' /></div> <!-- 중요도 -->
						<div class="div_td">
							<c:if test="${taskData.ImpLevel  == 'H'}">
								<span class="num_up"></span> <spring:message code="Cache.Anni_Priority_2" />
							</c:if>
							<c:if test="${taskData.ImpLevel  == 'M'}">
								<span class="num_equal"></span> <spring:message code="Cache.Anni_Priority_3" />
							</c:if>
							<c:if test="${taskData.ImpLevel  == 'L'}">
								<span class="num_down"></span> <spring:message code="Cache.Anni_Priority_4" />
							</c:if>
						</div>
					</li>
					</c:if>
					<c:if test="${fn:length(tagList)>0}">
						<li id="liTag" >
							<div class="div_th"><spring:message code="Cache.lbl_Tag" /></div> 
							<div class="div_td">
								<ul class="clearFloat fileUpview tagview" id="tagList">
									<c:forEach items="${tagList}" var="list" varStatus="status">
									<li>
										<div data-tagID="${list.TagID }">
										<span class="btn_dtag bg0<%=(new java.security.SecureRandom()).nextInt(3)+1 %>">#${list.TagName}</span>
										</div>
									</li>
									</c:forEach>
								</ul>
							</div>
						</li>		
					</c:if>
					<c:set var="appCnt" value="0" />
					<c:set var="fileCnt" value="0" />
					<c:forEach items="${fileList}" var="list" varStatus="status">
						<c:if test="${list.ObjectType eq 'APPROVAL'}"><c:set var="appCnt" value="${appCnt+1}" /></c:if>
						<c:if test="${list.ObjectType ne 'APPROVAL'}"><c:set var="fileCnt" value="${fileCnt+1}" /></c:if>
					</c:forEach>
					<c:if test="${appCnt>0}">
						<li id="liFile" >
							<div class="div_th"><spring:message code="Cache.lbl_RelatedApproval" /></div> 
							<div class="div_td">
								<ul class="fileUpview fileview">
									<c:forEach items="${fileList}" var="list" varStatus="status">
										<c:set var="selValue" value="${el:getImageFilePath(list.FileID, list.FilePath, list.SavedName)}" />
										<c:if test="${list.ObjectType eq 'APPROVAL'}">
											<li>
											<div class="" data-fileid="${list.FileID }" data-filetoken="${list.FileToken}" data-fileext="${list.Extention}">
												<span class="btn_dfile">
													<a class="file_down">
													<script>var icon = collabUtil.getFileClass("${list.Extention}");
															document.write("<span class='"+icon+"'></span>");
													</script>
													${list.FileName}
													</a>
													<span class="file_prev btn_dsearch" onclick=""></span>
												</span>
											</div>
											</li>
										</c:if>	
									</c:forEach>
								</ul>
							</div>
						</li>
					</c:if>			
					<c:if test="${fileCnt>0}">
						<li id="liFile" >
							<div class="div_th"><spring:message code="Cache.lbl_File" /></div> 
							<div class="div_td">
								<ul class="fileUpview fileview" style="max-height:196px;">
									<c:forEach items="${fileList}" var="list" varStatus="status">
										<c:set var="selValue" value="${el:getImageFilePath(list.FileID, list.FilePath, list.SavedName)}" />
										<c:if test="${list.ObjectType ne 'APPROVAL'}">
											<li>
											<div class="" data-fileid="${list.FileID }" data-filetoken="${list.FileToken}" data-fileext="${list.Extention}">
												<span class="btn_dfile">
													<a class="file_down">
													<script>var icon = collabUtil.getFileClass("${list.Extention}");
															document.write("<span class='"+icon+"'></span>");
													</script>
													${list.FileName}
													</a>
													<span class="file_prev btn_dsearch" onclick=""></span>
												</span>
											</div>
											</li>
										</c:if>
									</c:forEach>
								</ul>
							</div>
						</li>	
					</c:if>		
					<li>
						<div class="div_th"><spring:message code='Cache.lbl_work_explanation' /></div> <!-- 업무설명 -->
						<div class="div_td"><div class="pop_txt" id="remark" style="height: 100%; overflow-y: hidden;"></div></div>
					</li>
					
				<c:forEach items="${userformList}" var="list" varStatus="status">
					<li>
						<c:choose>
					    	<c:when test="${list.OptionType eq 'linkURL'}">
					    		<div class="div_th">연결게시</div>
								<div class="div_td">
									<span class="btnType02 btnNormal" style="cursor:pointer; margin-bottom: 0px;" href="javascript:void(0);" onclick="collabTaskAdd.goOrgViewPopup('${list.OptionVal}')">${list.OptionTitle}</span>
								</div>
					    	</c:when>
					    	<c:otherwise>
					    		<div class="div_th">${list.OptionTitle}</div>
					    		<div class="div_td">${list.OptionVal}</div>
					    	</c:otherwise>
					    </c:choose>	
					</li>
				</c:forEach>	
				
			</div>
		</div>
		<div class="pop_box02">
			<div class="pop_titBox">
				<strong class="pop_title_s"><spring:message code='Cache.lbl_Subtask' /></strong> <!-- 하위업무 -->
				<c:if test="${authSave eq 'Y'}"> 
					<div class="control_btn">
						<a href="#" class="btn_add" id="btnAddSub"></a>
					</div>
				</c:if>	
			</div>
			<c:forEach items="${subTaskList}" var="list" varStatus="status">
				<div class="pop_listBox" onclick="" >
					<div class="pop_l">
						<div class="chkStyle10">
							<input type="checkbox" id="chk_${list.TaskSeq}" ${list.TaskStatus=='C'?'checked':''} data-taskSeq="${list.TaskSeq}"  ${authSave eq 'Y'?'':'disabled'}>
							<label for="chk_${list.TaskSeq}"><span class="s_check "></span>${list.TaskName}</label>
						</div>
					</div>
					<div class="pop_r" id="sub_${list.TaskSeq}">
						<span class="user_date">${el:ConvertDateFormat(list.EndDate,".")}</span>
						<c:set var="users" value="${fn:split(list.tmUser,'|')}" />
						<c:forEach var="sub" items="${users}" varStatus="status">
							<c:if test="${status.index eq 0}">
								<script>
								var userDetailArr = "${sub}".split('^');
								$("#sub_${list.TaskSeq}").append(collabUtil.drawProfileOne({"code":userDetailArr[0],"DisplayName":userDetailArr[1],"PhotoPath":userDetailArr[2],"DeptName":userDetailArr[3], "personCnt":"${fn:length(users)}"}, false)); </script>
							</c:if>	
						</c:forEach> 
					</div>
					<a href="#" class="btn_arrow_c btnSubDetail" data-taskSeq="${list.TaskSeq}"></a>
				</div>
			</c:forEach>
		</div>
		<!-- 댓글 -->
		<div id="commentView" class="commentView">
		</div>
	</div>
</div>
</c:if>

</body>
</html>
<script type="text/javascript">

var collabTaskAdd = {
		sReceiversCode:'',
		objectInit : function(){			
			<c:forEach items="${memberList}" var="list" varStatus="status">
				<c:if test="${list.UserCode ne USERID}">
				collabTaskAdd.sReceiversCode+= (collabTaskAdd.sReceiversCode != ""?";":"")+"${list.UserCode}";
				</c:if>
			$("#resultViewMember").append(collabUtil.drawProfile({"code":"${list.UserCode}","type":"UR", "PhotoPath":"${list.PhotoPath}","DisplayName":"${list.DisplayName}","DeptName":"${list.DeptName}"}, false)); 
			$(".c_chatBox").append(collabUtil.drawProfile({"code":"${list.UserCode}","type":"UR", "UserCode":"${list.UserCode}","PhotoPath":"${list.PhotoPath}","DisplayName":"${list.DisplayName}","DeptName":"${list.DeptName}"}, "${authSave eq 'Y'? 'true':'false'}", "sub_member"));
			</c:forEach>
			this.addEvent();
			
			$(".pop_middle").attr("style","overflow-y:visible;height:100%;");
			
			var myConf;
			if(parent.collabMenu != undefined) myConf = parent.collabMenu.myConf;
			else if(opener.parent.collabMenu != undefined) myConf = opener.parent.collabMenu.myConf;
			
			if (myConf != undefined && myConf["taskShowCode"] == "SLIDING") $("#btnPopClose").show();
		
			// 업무설명 html 입력
			$("#remark").html(unescape('${Remark}'));
		}	,
		addEvent : function(){
			var messageSetting = {
					SenderCode : sessionObj["USERID"],
					RegistererCode : sessionObj["USERID"],
					ReceiversCode : collabTaskAdd.sReceiversCode,
					GotoURL:  "/groupware/collabTask/CollabTaskPopup.do?taskSeq="+ CFN_GetQueryString("taskSeq")+"&topTaskSeq="+CFN_GetQueryString("taskSeq"),
					PopupURL: "/groupware/collabTask/CollabTaskPopup.do?taskSeq="+ CFN_GetQueryString("taskSeq")+"&topTaskSeq="+CFN_GetQueryString("taskSeq"), 
					MobileURL: "",
					MessagingSubject : "[${fn:replace(taskData.TaskName, '\"', '')}]",
					ReceiverText : "[${fn:replace(taskData.TaskName, '\"', '')}]", //요약된 내용
					ServiceType : "Collab",
					MsgType : "TaskAddComment",
					MentionMsgType : "TaskAddMention"
			};
			coviComment.load('commentView', 'Collab', CFN_GetQueryString("taskSeq"), messageSetting);

		    $('.txtArearBox textarea').keydown(function(e){
		    	var prjType = '${mapList[0].PrjType}';
		    	var prjSeq = '${mapList[0].PrjSeq}';
	        	var popupURL = Common.getGlobalProperties("smart4j.path")+ "/groupware/collabTask/CollabTaskPopup.do?"+
	        			"taskSeq="+ CFN_GetQueryString("taskSeq")+"&prjType="+prjType+"&prjSeq="+prjSeq+"&topTaskSeq="+CFN_GetQueryString("topTaskSeq"); 

	        	coviComment.commentVariables["commentView"]["messageSetting"]["PopupURL"]=popupURL;
	        	coviComment.commentVariables["commentView"]["messageSetting"]["GotoURL"]=popupURL;
//	        	coviComment.commentVariables["commentView"]["messageSetting"]["MessagingSubject"]="[${taskData.TaskName}]"+ $(this).val();
		    });
			    
			$('.txtArearBox textarea').autocomplete({
				source : function(request, response) {
			    	var prjType = '${mapList[0].PrjType}';
			    	var prjSeq = '${mapList[0].PrjSeq}';

					if (request.term.substring(0,1) == "@" && prjSeq != ""){
			            $.ajax({
			                type : 'post',
			                url : '/groupware/collabProject/getProjectMemberList.do',
			                data : {prjSeq:prjSeq,prjType:prjType,keyword : request.term.substring(1)},
			                success : function(data) {
			                    response(
			                        $.map(data.list, function(item) {
			                            return {
			                                label : "@"+item["DisplayName"],
			                                value : item["UserCode"]
			                            }
			                        })
			                    );
			                }
			            });
					}    
		        },
		        select : function(event, ui) {
    				var item = ui.item;
    				var type = "UR" ;

					coviComment.commentVariables["commentView"]["mentionInfos"][item.value]=item.label;
					var liHtml = '<p class="date_del" type="UR" code="'+item.value+'">'+item.label+'<a class="ui-icon ui-icon-close"></a></p>';
					$('#commentView .txtArearBox').before(liHtml);
					ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
		        },
		        focus : function(event, ui) {
		            return false;
		        },
		        minLength : 1,
		        autoFocus : true,
		        classes : {
		            'ui-autocomplete': 'highlight'
		        },
		        delay : 500,
		        position : { my : 'right top', at : 'right bottom' },
		        close : function(event) {
		        }
			});
				
			//상위업무 클릭시
			$("#parTaskSeq").on( 'click',function(e){
				parent.collabUtil.openTaskPopup("CollabTaskPopup", 'CollabTaskPopup', $(this).data("taskseq"), CFN_GetQueryString("topTaskSeq"));
				
			});
			$("#btnDot").on( 'click',function(e){
				if($('.ul_smenu_layer').hasClass('active')){
					$('.ul_smenu_layer').removeClass('active');
				}else {
					$('.ul_smenu_layer').addClass('active');
				}
			});

			//즐겨찾기
			$("#btnFav").on( 'click',function(e){
				$.ajax({
            		type:"POST",
            		data:{"taskSeq":  CFN_GetQueryString("taskSeq"), "isFlag":$(this).hasClass("active")},
            		url:"/groupware/collabTask/saveTaskFavorite.do",
            		success:function (data) {
            			if(data.status == "SUCCESS"){
            				$("#btnFav").toggleClass("active");
            				if (opener != null && typeof opener.collabPortal == 'object') {
            					opener.collabPortal.reloadPortal();
            				} else if (typeof parent.collabPortal == 'object') {
            					parent.collabPortal.reloadPortal();
            				}
            			}
            			else{
            				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
            			}
            		},
            		error:function (request,status,error){
            			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
            		}
            	});
			});

			//file
			$("#btnFile").on( 'click',function(e){
				$('#file').click()
			});			
			$("#file").on("change", function(){
				var file = $(this)[0].files;
				
				var formData = new FormData($('#form1')[0]);
				formData.append("taskSeq", "${taskData.TaskSeq}");
				
				$.ajax({
					type:"POST",
					enctype: 'multipart/form-data',
					data: formData,
					processData: false,
					contentType: false,
					url:"/groupware/collabTask/addTaskFile.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
	            			$("#btnReload").trigger("click");
						}
						else{
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />["+data.message+"]"); //	ì¤ë¥ê° ë°ìíìµëë¤. ê´ë¦¬ììê² ë¬¸ìë°ëëë¤
							$('#form1')[0].reset();
						}
					},
					error:function (request,status,error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
			});
			//공유
			$("#btnShare").on( 'click',function(e){
				var textArea = document.createElement('textArea');
	            textArea.readOnly = true;
	            textArea.contentEditable = true;
	            textArea.value = location.href;
	            document.body.appendChild(textArea);
	            
	            var range, selection;

	            /*if (navigator.userAgent.match(/ipad|iphone/i)()) {
	                range = document.createRange();
	                range.selectNodeContents(textArea);
	                selection = window.getSelection();
	                selection.removeAllRanges();
	                selection.addRange(range);
	                textArea.setSelectionRange(0, 999999);
	            } else {
	                textArea.select();
	            }*/
	            textArea.select();
	            document.execCommand('copy');
	            document.body.removeChild(textArea);
	            Common.Inform("<spring:message code='Cache.msg_LinkCopiedPaste' />");    //링크가 복사되었습니다. 원하는 곳에 붙여넣기 해주세요.     
			});		
			//인쇄
			$("#btnPrint").on( 'click',function(e){
				$("#btnDot").trigger("click");
				window.print();
			});		
			//태그
			$("#btnTag").on( 'click',function(e){
				//$(".column_menu").toggleClass("active");
				//$("#divTag").show();
				
				$(".column_menu").toggleClass("active");
	        	var cardData={"objectType":"${taskData.ObjectType}","objectID":"${taskData.ObjectID}", "StartDate":"${taskData.StartDate}", "EndDate":"${taskData.EndDate}" , "taskSeq": CFN_GetQueryString("taskSeq"),"taskName":"${fn:replace(taskData.TaskName,'\"','')}"
	        			,"prjType":"${prjType}","prjSeq":"${prjSeq}"};
	        	collabTaskAdd.goTaskTag(cardData,"callbackTaskTag");
			});
			/*
			$("#iconClose").on( 'click',function(e){
				$("#divTag").hide();
			});	
			//태그등록
			$("#btnAddTag").on("click", function(e){
				var data ={"taskSeq": CFN_GetQueryString("taskSeq"),"tagName":$("#tagName").val()};
				$.ajax({
					type:"POST",
					data: data,
					url:"/groupware/collabTask/addTaskTag.do",
					success: function(data) {
						$("#divTag").hide();
						$("#liTag").show();
						$("#tagList").append($("<li>").append($("<div>").data({"tagid":data.tagData.tagID})
										.append($("<span>",{"class":"btn_dtag bg0"+(Math.floor(coviCmn.random() * 4)+1),"text":data.tagData.TagName}))
										.append($("<a>",{"class":"btn_del tag_del"}))
								));	
					},
					error:function (jqXHR, textStatus, errorThrown) {
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
			});
			*/
			//초대
	        $('#btnInvite, #btnInvite2').on( 'click',function(e){
	        	$(".column_menu").toggleClass("active");

	        	var prjType = '${mapList[0].PrjType}';
				var prjSeq = '${mapList[0].PrjSeq}';
				var popupID	= "CollabProjectInvitePopup";
				var openerID	= "";
				var popupTit	= Common.getDic("TodoMsgType_Invited");//"<spring:message code='Cache.lbl_app_approval_extention' />";
				var popupYN		= "N";
				var callBack	= "callbackInvite";
				var popupUrl	= "/groupware/collab/CollabTargetListPopup.do?"
								+ "&thisTaskSeq="    + "${taskData.TaskSeq}"
								+ "&popupID="		+ popupID	
								+ "&openerID="		+ openerID	
								+ "&popupYN="		+ popupYN	
								+ "&prjSeq="        + prjSeq
								+ "&prjType="       + prjType
								+ "&callbackType="
								+ "&callback="	+ callBack	;

				Common.open("", popupID, popupTit, popupUrl, "550px", "650px", "iframe", true, null, null, true);
				
	        });
			//삭제
			$("#btnDel").on('click', function(){
				$(".column_menu").toggleClass("active");
				var cardData={"objectType":"${taskData.ObjectType}","objectID":"${taskData.ObjectID}", "parentKey":"${taskData.ParentKey}", "taskSeq": CFN_GetQueryString("taskSeq")};
		 		collabUtil.goTaskDelete(cardData);
	        });
	        //복사화면
	        $('#btnCopy').on( 'click', function(e){
	        	$(".column_menu").toggleClass("active");
	        	var cardData={"objectType":"${taskData.ObjectType}","objectID":"${taskData.ObjectID}", "StartDate":"${taskData.StartDate}", "EndDate":"${taskData.EndDate}" , "taskSeq": CFN_GetQueryString("taskSeq"),"taskName":"${fn:replace(taskData.TaskName,'\"','')}"
	        			,"prjType":"${prjType}","prjSeq":"${prjSeq}"};
		 		collabUtil.goTaskCopy(cardData,"callbackTaskCopy");
	        });

			//수정
		 	$("#btnDetail").on('click', function(){
		 		
		 		var cardData = {"objectType":"${taskData.ObjectType}","objectID":"${taskData.ObjectID}", "StartDate":"${taskData.StartDate}", "EndDate":"${taskData.EndDate}" , "taskSeq": CFN_GetQueryString("taskSeq")
		 				, "sectionSeq":"${taskData.TaskStatus}","prjType":"${mapList[0]['PrjType']}","prjName":"${mapList[0]['PrjName']}","sectionName":"${mapList[0]['SectionName']}","prjSeq":"${mapList[0]['PrjSeq']}","popup":"Y"};
		 		collabUtil.goTaskModify(cardData,"callbackTaskSave");
			});
			
			//새로고침
			$("#btnReload").on('click',function(){
				
				var popupMode = opener !== null ? opener : parent;
				
				popupMode.$("a[class='btnRefresh']").trigger("click");
				$(".column_menu").toggleClass("active");
				location.reload();
			});
			
			//내보내기
		 	$("#btnExport").on('click', function(){
		 		collabUtil.openProjectAllocPopup(CFN_GetQueryString("taskSeq"), "Y", "saveProjectAllocPopup");
			});
			
			//프로젝트 추가
		 	$("#btnAddPrjoject").on('click', function(){
		 		collabUtil.openProjectAllocPopup(CFN_GetQueryString("taskSeq"), "N", "saveProjectAllocPopup");
			});
			
			//프로젝트 삭제
			$("#btnDelProject").on('click', function(){
				//var data = ($("#prjMap").find("option:selected").data());
				data["taskSeq"] = CFN_GetQueryString("taskSeq");
				 $.ajax({
	            		type:"POST",
	            		data:data,
	            		url:"/groupware/collabTask/deleteAllocProject.do",
	            		success:function (data) {
	            			$("#btnReload").trigger("click");
	            		},
	            		error:function (request,status,error){
	            			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	            		}
	            	});
			});

			//서부 항목 추가
			$("#btnAddSub").on	('click', function(){
				if ($("#subViewMember").length>0){
					Common.Error("<spring:message code='Cache.msg_JobNotRegistered' />");	//등록 안 된 업무가 있습니다.
					return;
				}
				$('.pop_box02').append(collabUtil.drawAddTask("subViewMember", "subStartDate", "subEndDate", "LIST"));
				$("#subEndDate").bindTwinDate({
					startTargetID : "subStartDate",
					separator : ".",
					onchange: function(dateText){
						$("#viewDate").text(this["ST_value"]+"~"+this["ED_value"]);
					}
				})

				//담당자 추가
				$(".btn_list_icon02").on('click', function(){
					var prjType = '${mapList[0].PrjType}';
					var prjSeq = '${mapList[0].PrjSeq}';
					var popupID	= "CollabProjectInvitePopup";
					var openerID	= "";
					var popupTit	= Common.getDic("TodoMsgType_Invited");//"<spring:message code='Cache.lbl_app_approval_extention' />";
					var popupYN		= "N";
					var callBack	= "callbackInvite";
					var popupUrl	= "/groupware/collab/CollabTargetListPopup.do?"
									+ "&popupID="		+ popupID	
									+ "&openerID="		+ openerID	
									+ "&popupYN="		+ popupYN	
									+ "&prjSeq=" 		+ prjSeq
									+ "&prjType=" 		+ prjType
									+ "&taskSeq=" 		+ "${taskData.TaskSeq}"
									+ "&callbackType="
									+ "&callback=callbackOrgMember"	;
									
					Common.open("", popupID, popupTit, popupUrl, "550px", "650px", "iframe", true, null, null, true);
				});

				
//				$('.pop_box02 input[type=text]').focus();
				//collabUtil.attachEventAddTask("subViewMemberInput", "subStartDate", "subEndDate");
				/*$("#subStartDate").datepicker({
					dateFormat: 'yy-mm-dd',
					beforeShow: function(input) {
					           var i_offset = $(".calendarcontrol").offset();      // 버튼이미지 위치 조회
					           setTimeout(function(){
					              jQuery("#ui-datepicker-div").css({"left":i_offset});
					           })
					        },
					onSelect: function(dateText){
					}
				});*/
								
				$('.pop_box02 #subTaskName').on('keydown', function(key){
					 if (key.keyCode == 13) {
						 	
							if (!XFN_ValidationCheckOnlyXSS(false)) { return; }			
							// 특수 문자 입력 불가
							
							var spePatt = /[`!#$%^&*|\\\'\";:\/?¢™$®]/gi;
							if(spePatt.test($(this).val())) {
								Common.Warning("<spring:message code='Cache.msg_specialNotAllowed'/>"); // 특수문자는 사용할 수 없습니다.
								return false;
							}
							
							if ( $(this).val() == ""){
								Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}", "<spring:message code='Cache.lbl_workname' />"));
							    return false;
							}
							
							if ( $(this).val().length > 150 ){
								Common.Warning("["+"<spring:message code='Cache.ACC_lbl_projectName' />"+"] <spring:message code='Cache.msg_RxceedNumberOfEnter'/> [125자]");
							    return false;
							}
							
			                $.ajax({
			            		type:"POST",
			            		contentType:'application/json; charset=utf-8',
								dataType   : 'json',
			            		data:JSON.stringify({"taskSeq": CFN_GetQueryString("taskSeq"),
			            			   "topTaskSeq": '${taskData.TopParentKey==0?taskData.TaskSeq:taskData.TopParentKey}',
			            				"taskName":  $(this).val(),            				
			            				"startDate": $("#viewDate").text().split("~")[0],
			            				"endDate": $("#viewDate").text().split("~").length>0?$("#viewDate").text().split("~")[1]:"",
			            				"trgMember":collabUtil.getUserArray("subViewMember")}),
			            		url:"/groupware/collabTask/addSubTaskSimple.do",
			            		success:function (data) {
			            			$("#btnReload").trigger("click");
			            		},
			            		error:function (request,status,error){
			            			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			            		}
			            	});
			                
			            }
			        });
			});
			
			//서브 상세
			$(".btnSubDetail").on('click', function(){
				var prjType = '${mapList[0].PrjType}';
		    	var prjSeq = '${mapList[0].PrjSeq}';
				collabUtil.openTaskPopup("CollabTaskPopup", "${prjType}_${prjSeq}", $(this).data("taskseq"), CFN_GetQueryString("topTaskSeq"), 'SELF');
//				Common.Close();
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
			
			//완료 처리					
			$(".pop_top #chk_${taskData.TaskSeq}").on('change', function(){
				var	data={"taskSeq":  $(this).data("taskseq"), "taskStatus":  $(this).is(':checked')};
				
				if ($(this).is(':checked') && $('.relatedTask[data-status="NOT"').length> 0){
					var msg = Common.getDic("msg_AfComplet").replace("{0}",$('.relatedTask ').attr("data-taskname"));
					Common.Confirm(msg , "Confirmation Dialog", function (confirmResult) {
						collabUtil.saveTaskComplete(data, function (res) {
							$("#btnReload").trigger("click");
							if (opener != null && typeof opener.collabPortal == 'object') {
            					opener.collabPortal.reloadPortal();
            				} else if (typeof parent.collabPortal == 'object') {
            					parent.collabPortal.reloadPortal();
            				}
						});
					})
				}else{
					collabUtil.saveTaskComplete(data, function (res) {
						$("#btnReload").trigger("click");
						if (opener != null && typeof opener.collabPortal == 'object') {
        					opener.collabPortal.reloadPortal();
        				} else if (typeof parent.collabPortal == 'object') {
        					parent.collabPortal.reloadPortal();
        				}
					});
				}
			});
			
			//milestone 처리
			$(".pop_top #chkM_${taskData.TaskSeq}").on('change', function(){
				var	data={"taskSeq":  $(this).data("taskseq"), "taskStatus":  $(this).is(':checked')};
				$.ajax({
            		type:"POST",
            		data:{"taskSeq":   $(this).data("taskseq"), "isMile":$(this).is(':checked')?"Y":"N"},
            		url:"/groupware/collabTask/saveTaskMile.do",
            		success:function (data) {
            			if(data.status == "SUCCESS"){
            				$("#btnMile").toggleClass("active");
            				$("#btnReload").trigger("click");
            			}
            			else{
            				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
            			}
            		},
            		error:function (request,status,error){
            			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
            		}
            	});
			});

			$(".pop_listBox input[type=checkbox]").on('change', function(){
				var	data={"taskSeq":  $(this).data("taskseq"), "taskStatus":  $(this).is(':checked')};
				collabUtil.saveTaskComplete(data, function (res) {
				});
			});
			
			$(document).on('click', '.file_down', function(e) {
				Common.fileDownLoad($(this).closest("div").data("fileid"), $(this).closest("div").text(), $(this).closest("div").data("filetoken"));//data-fileext
			});
			$(document).on('click', '.file_prev', function(e) {
				e.preventDefault();
				Common.filePreview($(this).closest("div").data("fileid"), $(this).closest("div").data("filetoken"),$(this).closest("div").data("fileext"),"N");
			});
			//file 삭제
			$(document).on('click', '.file_del', function(e) {
				var obj = this;
				$.ajax({
					type:"POST",
					data: {"taskSeq": CFN_GetQueryString("taskSeq"),"fileID":$(this).parent().data("fileid")},
					url:"/groupware/collabTask/deleteTaskFile.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");	//ë³µì¬ëììµëë¤.
							$(obj).closest("li").remove();
						}
						else{
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	ì¤ë¥ê° ë°ìíìµëë¤. ê´ë¦¬ììê² ë¬¸ìë°ëëë¤
						}
					},
					error:function (request,status,error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
				
			});
			
			//tag 삭제
			$(document).on('click', '.tag_del', function(e) {
				var obj = this;
				$.ajax({
					type:"POST",
					data: {"taskSeq": CFN_GetQueryString("taskSeq"),"tagID":$(this).parent().data("tagid")},
					url:"/groupware/collabTask/deleteTaskTag.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							$(obj).closest("li").remove();
						}
						else{
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	ì¤ë¥ê° ë°ìíìµëë¤. ê´ë¦¬ììê² ë¬¸ìë°ëëë¤
						}
					},
					error:function (request,status,error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
			});
			

			//사용자나 부서/ 일자 삭제
			$(document).on('click', '.btn_del', function(e) {
				e.preventDefault();
				$(this).parent().remove();
			});

			$(document).on('click', '.date_del', function(e) {
				delete coviComment.commentVariables["commentView"]["mentionInfos"][$(this).attr("code")];
				$(this).remove();
			});

			//참가자 삭제
			$(document).on('click', '.sub_member', function(e) {
				var obj = this;
				$.ajax({
					type:"POST",
					data: {"taskSeq": CFN_GetQueryString("taskSeq"),"UserCode":$(this).parent().attr("code")},
					url:"/groupware/collabTask/deleteTaskMemeber.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							$(obj).parent().remove();
							
							var url = opener.location.pathname.split("?")[0];
							if(url == "/groupware/collabTask/CollabTaskPopup.do") opener.location.reload();
						}
						else{
							Common.Error(Common.getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
						}
					},
					error:function (request,status,error){
						Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
				
			});
			
			//슬라이드 닫기
			$("#btnPopClose").on('click', function(e) {
				parent.$("#rightmenu").removeClass("active");
			});

		},
		getTaskData:function(){
			var taskData = {"trgMember":collabUtil.getUserArray("resultViewMember") 
					,"taskName":  $("#taskName").val()
					,"startDate": $("#startDate").val()
					,"endDate": $("#endDate").val()
					,"taskStatus": $("#taskStatus").val()
					,"progRate": $("#progRate").val()
					,"remark": $("#remark").val()};
			return taskData;
		},
		saveProjectAllocPopup:function(folderData){
			$.ajax({
				url:"/groupware/collabTask/addAllocProject.do",
				type:"POST",
				data:folderData,
				success:function (data) {
				},
				error:function (request,status,error){
					Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});
		},
		goTaskTag:function(cardData, callBackFunc){
			var popupID	= "CollabTaskTagPopup";
			var openerID	= "";
			var popupTit	= "["+cardData.taskName + "] "+Common.getDic("lbl_Tag"); //태그
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/collabTask/CollabTaskTagPopup.do?"
							+ "&taskSeq="       +  cardData.taskSeq
	 						+ "&prjType="    	+ cardData.prjType
	 						+ "&prjSeq="    	+ cardData.prjSeq
							+ "&popupID="		+ popupID	
							+ "&openerID="		+ openerID	
							+ "&popupYN="		+ popupYN	
							+ "&callBackFunc="	+ callBackFunc	;
			Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);

   		},
   		goOrgViewPopup:function(pLinkURL) {
			CFN_OpenWindow(pLinkURL, "boardViewPopup", 930, 650, "resize");
   		}
}


$(document).ready(function(){
	collabTaskAdd.objectInit();
});

window.addEventListener( 'message', function(e){
    // 부모창의 함수 실행
    switch (e.data.functionName){
	    case "saveProjectAllocPopup":
	    	collabTaskAdd.saveProjectAllocPopup(e.data.params);
	    	break;
	    case "callbackTaskSave":	
			$("#btnReload").trigger("click");
			
			var url = opener.location.pathname.split("?")[0];
			if(url == "/groupware/collabTask/CollabTaskPopup.do") opener.location.reload();
			
	    	break;
	    case "callbackTaskCopy":	
	    	window.opener.postMessage(
				    { functionName : "callbackTaskCopy"
				    		,reqParams:{"prjType":"${prjType}","prjSeq":"${prjSeq}"}
				    }
				    , '*' 
				);
	    	break;
	    case "callbackTaskTag":	
	    	var params = e.data.params;
	    	$("#liTag").show();
			//$("#tagList").append($("<li>").append($("<div>").data({"tagid":params.tagid})
			$("#tagList").append($("<li>").append($('<div data-tagid="'+params.tagid+'">')
							.append($("<span>",{"class":"btn_dtag bg0"+(Math.floor(coviCmn.random() * 4)+1),"text":"#"+params.TagName}))
							.append($("<a>",{"class":"btn_del tag_del"}))
					));
	    	break;
	    case "callbackInvite":	//초대
	    	var list = e.data.params.list;
	    	var trgMemberArr = new Array();
			$.each(list, function (i, v){
				var type = 'UR';
				var code = v.UserCode;
				var saveData = { "type":type, "userCode":code};
				trgMemberArr.push(saveData);
			});

			$.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				data:JSON.stringify({"trgMember":trgMemberArr
					,"taskSeq":  CFN_GetQueryString("taskSeq")
					}),
				url:"/groupware/collabTask/addTaskInvite.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform(Common.getDic("msg_com_processSuccess"));	//
						$("#btnReload").trigger("click");
						
						var url = opener.location.pathname.split("?")[0];
						if(url == "/groupware/collabTask/CollabTaskPopup.do") opener.location.reload();
					}
					else{
						Common.Error(Common.getDic("msg_ErrorOccurred")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});	
	    	break;	
	    case "callbackOrgMember"://서부 담당자
	    	var list = e.data.params.list;
			var duplication = false; // 중복 여부
			$.each(list, function (i, v){
				var type = 'UR';
				var code = v.UserCode;
				
				if ($('#subViewMember').find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 0) {
					duplication = true;
					return true;;
				}
				
   				var cloned = collabUtil.drawProfile({"code":code,"type":type,"DisplayName":CFN_GetDicInfo(v.DisplayName),"DeptName":v.DeptName, "PhotoPath":v.PhotoPath}, true);
   				$('#subViewMember').append(cloned);
			});
			
			if(duplication){
				Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
			}
	    	break;
    }
    
});
	
</script>