<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/task.js<%=resourceVersion%>"></script>

<div class="layer_divpop ui-draggable taskPopLayer" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent">
				<!-- 팝업 내부 시작 -->
				<div class="taskPopContent taskFolderAdmin" style="padding:0;">
					<div class="top">
						<div class=" cRContBtmTitle">
							<div class="boardTitle">
								<h2 id="nameRead">
									<input type="text" id="nameWrite" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_028'/>"  kind="write" style="display:none;"><!-- 제목을 입력하세요  -->
								</h2>
								<div class="boardTitData" id="folderRegInfo" style="display:none;"><span id="registerName" class="popName"></span><span id="registDate" class="date"></span></div>
							</div>							
						</div>
					</div>				
					<div class="middle">
						<div class="inputBoxSytel01 type03">
							<div><span><spring:message code='Cache.lbl_State'/><!-- 상태 --></span></div>
							<div>
								<p id="stateRead" class="textBox" kind="read" style="display:none;"></p>
								<div id="stateWrite" kind="write" style="display:none;"></div>
							</div>
						</div>
						<div class="inputBoxSytel01 type03">
							<div><span><spring:message code='Cache.lbl_ProgressRate'/><!-- 진도율--></span></div>
							<div>
								<span id="progressRead" class="textBox" kind="read" style="display:none;"></span>
								<input type="text" id="progressWrite" kind="write" style="display:none;" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" /> %
							</div>
						</div>						
						<div class="inputBoxSytel01 type03">
							<div><span><spring:message code='Cache.lbl_Description'/><!-- 설명 --></span></div>
							<div>
								<p  id="descriptionRead" class="textBox" kind="read" style="display:none;"></p>
								<textarea id="descriptionWrite" class="HtmlCheckXSS ScriptCheckXSS" kind="write" style="display:none;"></textarea>
							</div>
						</div>
						<div class="inputBoxSytel01 type03">
							<div><span><spring:message code='Cache.lbl_Coowner'/><!-- 공유자 --></span></div>
							<div>
								<div class="autoCompleteCustom"  kind="write" style="display:none;">
									<input type="text" id="shareMember" class="HtmlCheckXSS ScriptCheckXSS"/>									
									<a class="btnTypeDefault ml5 " onclick="orgChartPopup('D9','OrgCallBack_SetShareMember','folderSet');"><spring:message code='Cache.lbl_DeptOrgMap'/><!-- 조직도 --></a>									
								</div>
								<div class="sharePerSonListBox mt10">
									<ul id="shareMemberList" class="personBoxList clearFloat">
									</ul>
								</div>
							</div>
						</div>
					</div>
					<div class="bottom mt20">
						<a name="registBtn" onclick="saveFolder('I')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Regist'/><!-- 등록 --></a> <!--추가 시  -->
						<a name="saveBtn" onclick="saveFolder('U')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Save'/><!-- 저장 --></a> <!-- 수정 시  -->
						<a name="confirmBtn" onclick='Common.Close(); return false; ' class="btnTypeDefault btnTypeBg"  style="display:none"><spring:message code='Cache.lbl_Confirm'/><!-- 확인 --></a> <!-- 단순 조회 시  -->
						<a name="cancelBtn" onclick='Common.Close(); return false; ' class="btnTypeDefault " style="display:none"><spring:message code='Cache.lbl_Cancel'/><!-- 취소 --></a>
					</div>
				</div>
				<!-- 팝업 내부 끝 -->
		</div>
	</div>
</div>

<script>
	//# sourceURL=FolderSetPopup.jsp
	
	//폴더 설정에서 사용변수
	var f_mode = isNull(CFN_GetQueryString("mode").toUpperCase(),'');
	var f_folderID = isNull(CFN_GetQueryString("folderID"),'');
	var f_isOwner = isNull(CFN_GetQueryString("isOwner"),'');
	var f_isSearch = isNull(CFN_GetQueryString("isSearch"),'N');
	var f_parentFolderID = isNull(CFN_GetQueryString("parentFolderID"),'');
	
	var f_parentInfoObj;  //추가시 상위 폴더 정보 조회
	var f_haveModifyAuth;  //수정권한 (추가시, 수정 시 등록자 또는 소유자일 경우)

	//ready
	init();
	
	//초기화 함수
	function init(){
		
		if(f_mode == "ADD"){ //추가
			$("#folderRegInfo").hide();
			
			f_haveModifyAuth = "Y";
			setParentFolderData(f_parentFolderID);
			
			$('*[kind="read"]').hide();
			$('*[kind="write"]').show();
			
			setFolderControl();	
			
		}else{	 //수정 혹은 조회 (mode == MODIFY)
			$("#folderRegInfo").show();
			
			f_haveModifyAuth = (f_isOwner == "Y" ? "Y" : "N");
			
			if(f_haveModifyAuth=="Y"){
				$('*[kind="read"]').hide();
				$('*[kind="write"]').show();
				setFolderControl();	
			}else{
				$('*[kind="write"]').hide();
				$('*[kind="read"]').show();
			}
			
			setFolderData(f_folderID);
		}
		
		setTitleWidth();
		setButton(f_mode, f_haveModifyAuth);
	}
	
	
</script>