<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<%
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<style>
	.sortEl-placeholder {border: 1px dotted black;width:100%;height:30px}	/* 이동예정표시 */
	.sortEl .item-hidden {display:none;}
	.sortEl .item-text-hidden {display:none;}
</style>

<script type="text/javascript" src="/groupware/resources/script/user/survey.js"></script>
<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js<%=resourceVersion%>"></script>

<div class='cRConTop'>
	<div class='surveryTopButtons'>
		<a name="registBtn"		class="btnTypeDefault btnTypeChk" style="display:none;"><spring:message code='Cache.btn_register' /></a>
		<a name="updateBtn"		class="btnTypeDefault btnTypeChk" style="display:none;"><spring:message code='Cache.btn_register' /></a>
		<a name="modifyBtn"		class="btnTypeDefault" style="display:none;"><spring:message code='Cache.btn_Edit' /></a>
		<a name="tempBtn"		class="btnTypeDefault" style="display:none;"><spring:message code='Cache.btn_tempsave' /></a>
		<a name="deleteBtn"		class="btnTypeDefault" style="display:none;"><spring:message code='Cache.lbl_delete' /></a><!-- 삭제 -->
		<a name="previewBtn"	class="btnTypeDefault"><spring:message code='Cache.btn_preview' /></a>
	</div>
	<div class='surveySetting'>
		<a class="surveryContSetting"><spring:message code='Cache.lbl_Set' /></a>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<div class='surveyMakeView'>
		<div class="inpStyle01 surveyMakeTitle">
			<a class='btnType02 btnUrgent' id="isImportance"><spring:message code='Cache.lbl_surveyUrgency' /></a><input type="text" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" id="surveySubject" placeholder="<spring:message code='Cache.lbl_surveyMsg9' />." />
		</div>
		<div class='surveySettingView active'>
			<div class="inStyleSetting">
				<ul>
					<li id="isSubjectBold">
						<a class="btnBold">B</a>
					</li>
					<li class="active">
						<a class="btnInqPer"><spring:message code='Cache.lbl_settingSurveyPeriod' /></a>
					</li>
				</ul>
				<div class="inPerView active" id="inPerView">
					<div>
						<div class='selectCalView'>
							<span class="star"><spring:message code='Cache.lbl_surveySearchTerm' /></span>
							<div class="dateSel type02" >
								<div id="resultViewCalendarPicker"></div>
							</div>											
						</div>
						<div class="chkGrade">
							<div class="chkStyle01">
								<input type="checkbox" id="chkGrade"/><label for="chkGrade"><span></span><spring:message code='Cache.lbl_chkAnonymityYN' /></label>
							</div>
						</div>
					</div>
				</div>
				<div class="surveyOptionInput">
					<div class="inputBoxSytel01">
						<div><span><spring:message code='Cache.lbl_Description' /></span></div>
						<div class="txtEdit">
							<textarea id="description" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
							<div id="dext5"></div> <!--editor-->
							<p id="pSwitchEditor" class="editChange" value="textarea"><a><spring:message code='Cache.lbl_editChange' /></a></p>
							<input type="hidden" id="hidDescription" value="">
						</div>
					</div>
					<div class="inputBoxSytel01">
						<div><span><spring:message code='Cache.lbl_sectionEng' /></span></div> <!-- 섹션 -->
						<div>
							<select id="selectProjectSection" class="selectType02"></select> <!-- 섹션 선택 -->
						</div>
					</div>
					<div class="inputBoxSytel01 type01" style="display:none">
						<div><span class="star"><spring:message code='Cache.lbl_pollTargetType' /></span></div>
						<div>
							<div class="h_Line">
								<span class="radioStyle04 size">
									<input type="radio" id="surveyTarget1" name="surveyTarget" value="P" ischeck="N">
									<label for="surveyTarget1"><span><span></span></span><spring:message code='Cache.lbl_Whole' /></label> <!-- 전체 -->
								</span>
								<span class="radioStyle04 size">
									<input type="radio" id="surveyTarget2" name="surveyTarget" value="S" ischeck="Y" checked> 
									<label for="surveyTarget2"><span><span></span></span><spring:message code="Cache.lbl_specifySurveyTargets" /></label> <!-- 설문 대상 지정 -->
								</span>
							</div>
						</div>
					</div>
					
					<div id="surveyTargetDetail">
						<div class="inputBoxSytel01 type01">
							<div><span class="star"><spring:message code='Cache.lbl_polltarget' /></span><a class="btnMoreStyle01 btnSurMove active"><spring:message code='Cache.lbl_viewMoreSurveyTargets' /></a></div>
							<div class="autoCompleteCustom" id="targetDetailDiv">
								<input id="targetDetailInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 125px)" autocomplete="off">
								<a class="btnTypeDefault nonHover type01" style="margin-left: 5px;"><spring:message code="Cache.lbl_surveySubject" /></a> <!-- 설문 대상 -->
							</div>
						</div>
						<div class="surveyMoreInput active">
							<div class="inputBoxSytel01 type01">
								<div><span><spring:message code='Cache.lbl_resultDisclosure' /></span></div>
								<div class="autoCompleteCustom" id="resultViewDetailDiv">
									<input id="resultViewDetailInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 125px)" autocomplete="off">
									<a class="btnTypeDefault nonHover type01" style="margin-left: 5px;"><spring:message code="Cache.lbl_surveySubject" /></a> <!-- 설문 대상 -->
								</div>
							</div>
									<!-- 요청사항에 의해 숨김 
											<div class="inputBoxSytel01 type01" id="reviewerDiv" style="display:none;">
												<div><span><spring:message code='Cache.lbl_Reviewer' /></span></div>
												<div class="autoCompleteCustom" id="reviewerDetailDiv">
													<input id="reviewerDetailInput" type="text" class="ui-autocomplete-input" style="width:calc(100% - 60px)" autocomplete="off">
													<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup('reviewerDetailDiv')"><spring:message code='Cache.btn_OrgManage' /></a>
												</div>
											</div>
									-->
							<div class="inputBoxSytel01 type01" id="approverDiv" style="display:none;">
								<div><span class="star"><spring:message code='Cache.lbl_Approver' /></span></div>
								<div class="autoCompleteCustom" id="approverDetailDiv">
									<input id="approverDetailInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 60px)" autocomplete="off">
									<a class="btnTypeDefault nonHover type01"><spring:message code='Cache.btn_OrgManage' /></a>
								</div>
							</div>										
						</div>
					</div>
					
					<div class="inputBoxSytel01" style="padding: 10px 0 10px;">
						<div><span class="star"><spring:message code='Cache.lbl_Survey_period' /></span></div>
						<div class="dateSel type02">
							<div id="surveyCalendarPicker"></div>
						</div>
						<div class="noticeMedia" style="display: none;">
							<div class='alarm type01'>
								<span><spring:message code='Cache.lbl_AlarmMedia' /></span>
							</div>
							<div class='alarm type01'>
								<span><spring:message code='Cache.lbl_MAIL' /></span>
								<a class='onOffBtn' id="isSendMail"><span></span></a>
							</div>
							<div class='alarm type01'>
								<span><spring:message code='Cache.lbl_ToDo' /></span>
								<a class='onOffBtn' id="isSendTodo"><span></span></a>
							</div>
						</div>
					</div>
					<div id="fileDiv" class="inputBoxSytel01 type01" style="padding-top: 10px;">
						<div><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>	<!-- 파일 첨부 -->
						<div id="con_file" style="padding:0px;"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="surveyMakeListView">
		<div class="surMListcont sortEl">
		</div>
		<div class="surMListcontEnd">
			<div class='surveryTopButtons'>
				<a name="registBtn"		class="btnTypeDefault btnTypeChk" style="display:none;"><spring:message code='Cache.btn_register' /></a>
				<a name="updateBtn"		class="btnTypeDefault btnTypeChk" style="display:none;"><spring:message code='Cache.btn_register' /></a>
				<a name="modifyBtn"		class="btnTypeDefault" style="display:none;"><spring:message code='Cache.btn_Edit' /></a>
				<a name="tempBtn"		class="btnTypeDefault" style="display:none;"><spring:message code='Cache.btn_tempsave' /></a>
				<a name="deleteBtn"		class="btnTypeDefault" style="display:none;"><spring:message code='Cache.lbl_delete' /></a><!-- 삭제 -->
				<a name="previewBtn"	class="btnTypeDefault"><spring:message code='Cache.btn_preview' /></a>
			</div>
			<a class="btnTop"><spring:message code='Cache.lbl_topMove' /></a>
		</div>
		<div class="surMakeSideMenu">
			<ul>
				<li><a id="addQBtn"><spring:message code='Cache.lbl_question' /></a></li>
				<li><a id="addDBtn"><spring:message code='Cache.lbl_surveyDirection' /></a></li>
				<li><a id="addGBtn"><spring:message code='Cache.lbl_group' /></a></li>
			</ul>
		</div>
	</div>
</div>

<script>
	//# sourceURL=SurveyCollabWritePopup.jsp
	var surveyInfo = new Object();	// 설문 정보 -> 미리보기 팝업에서 parent.surveyInfo 호출하여 전역변수로 선언함
	
	(function(param){
		var prjSeq, prjType;
		
		var g_fileList = null;
		var g_editorKind = Common.getBaseConfig('EditorType');
		
		// 달력 옵션
		var timeInfos = {
			width : '200', //기본값은 100 [필수항목X]
			H : "", // 날짜 단위기 때문에 H는 없음.
			W : "1,2,3", //주 선택
			M : "1,2,3", //달 선택
			Y : "1" //년도 선택
		};
		
		var initInfos = {
			height : '300', //그려지는 모든 select box의 길이
			width : '100',   //시간 picker에 대한 사이즈 값 기본값은 100 [필수 X]
			useCalendarPicker : 'Y',
			useTimePicker : 'N',
			useBar : 'Y',
			useSeparation : 'N',
		};
		
		// 자동완성 옵션
		var MultiAutoInfos = {
			labelKey : 'DisplayName',
			valueKey : 'UserCode',
			minLength : 1,
			useEnter : false,
			multiselect : true,
			select : function(event, ui) {
				var id = $(document.activeElement).attr('id');
				var item = ui.item;
				
				if ($('#' + id.replace("Input","Div")).find(".ui-autocomplete-multiselect-item[type='UR'][code='"+ item.UserCode+"']").length > 0) {
					Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
					ui.item.value = '';
					return;
				}
				
				var cloned = orgMapDivEl.clone();
				cloned.attr('type', "UR").attr('code', item.UserCode);
				cloned.find('.ui-icon-close').before(item.label);
				
				$('#' + id).before(cloned);
				
				ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
			}		
		};
		
		var NonMultiAutoInfos = {
			labelKey : 'DisplayName',
			valueKey : 'UserCode',
			minLength : 1,
			useEnter : false,
			multiselect : true,
			select : function(event, ui) {
				var id = $(document.activeElement).attr('id');
				var item = ui.item;
				var cloned;
				
				if ($('#' + id.replace("Input","Div")).find('.ui-autocomplete-multiselect-item').length > 0) {
					Common.Confirm('<spring:message code="Cache.lbl_surveyMsg11" />\n<spring:message code="Cache.lbl_surveyMsg12" />', "Confirm", function(retVal){
						if(retVal){
							$('#' + id.replace("Input","Div")).find('.ui-autocomplete-multiselect-item').remove();
							
							cloned = orgMapDivEl.clone();
							cloned.attr('type', 'UR').attr('code', item.UserCode);
							cloned.find('.ui-icon-close').before(item.label);

							$('#' + id).before(cloned);
						}else{
							ui.item.value = '';
							return ;
						}
					});
				}else{
					cloned = orgMapDivEl.clone();
					cloned.attr('type', 'UR').attr('code', item.UserCode);
					cloned.find('.ui-icon-close').before(item.label);
					
					$('#' + id).before(cloned);
				}
				
				ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
			}
		};
		
		var setDefaultSetting = function(){
			// coviFile.fileInfos 초기화
			coviFile.files.length = 0;
			coviFile.fileInfos.length = 0;
			
			coviCtrl.renderDateSelect('resultViewCalendarPicker', timeInfos, initInfos);	// 조회
			coviCtrl.renderDateSelect('surveyCalendarPicker', timeInfos, initInfos);	// 설문기간
			
			setSelectProjectSection();
		}
		
		/* 프로젝트 섹션 셀렉트 박스 옵션 데이터 세팅 */
		var setSelectProjectSection = function() {
			prjSeq = param.prjSeq;
			prjType = param.prjType;
			
			$("#selectProjectSection").data("prjSeq", prjSeq);
			$("#selectProjectSection").data("prjType", prjType);
			
			$.ajax({
				type:"POST",
				url: "/groupware/collabProject/getProjectSection.do",
				async: false,
				data: { "prjSeq" : prjSeq, "prjType" : prjType},
				success: function(res) {
					$.each(res.sectionList, function(idx, item) {
						$("#selectProjectSection").append($("<option>", {"value": item.SectionSeq, "text": item.SectionName}))
					});
					
					var sectionSeq = $("#selectProjectSection option:selected").val();
					var sectionName = $("#selectProjectSection option:selected").text();
					
					$("#selectProjectSection").data("sectionSeq", sectionSeq);
					$("#selectProjectSection").data("prjTxt", sectionName);
				}
			});
			
			/* 자동 태그 관련 */
			$("#targetDetailDiv .ui-autocomplete-multiselect-item").remove();
			$("#resultViewDetailDiv .ui-autocomplete-multiselect-item").remove();
			
			var autoTagsUrl = String.format("/groupware/collabProject/getProjectMemberList.do?prjSeq={0}&prjType={1}&objectType=SURVEY", prjSeq, prjType);
			
			coviCtrl.setCustomAjaxAutoTags('targetDetailInput', autoTagsUrl, MultiAutoInfos);	// 설문대상
			coviCtrl.setCustomAjaxAutoTags('resultViewDetailInput', autoTagsUrl, MultiAutoInfos);	// 결과공개
			
			$('#targetDetailInput, #resultViewDetailInput').parent().css('width', 'calc(100% - 85px)');
		}
		
		var setEvent = function(){
			$("a[name=registBtn]").on("click", function(){
				saveBtn("reqApproval");
			});
			
			$("a[name=updateBtn]").on("click", function(){
				updateSurvey();
			});
			
			$("a[name=modifyBtn]").on("click", function(){
				updateSurvey("modify");
			});
			
			$("a[name=tempBtn]").on("click", function(){
				saveBtn("tempSave");
			});
			
			$("a[name=deleteBtn]").on("click", function(){
				deleteSurvey();
			});
			
			$("a[name=previewBtn]").on("click", function(){
				goPreView();
			});
			
			$("#selectProjectSection").change(function() {
				var sectionSeq = $("#selectProjectSection option:selected").val();
				var sectionName = $("#selectProjectSection option:selected").text();
				
				$("#selectProjectSection").data("sectionSeq", sectionSeq);
				$("#selectProjectSection").data("prjTxt", sectionName);
			});
			
			window.addEventListener("message", function(e)  {
				// 부모창의 함수 실행
				switch(e.data.functionName){
					case "surveyTargetPopupCallback":
						var list = e.data.params.list;
						var currentDiv = e.data.params.currentDiv;
						var duplication = false; // 중복 여부
						
						$.each(list, function (i, item){
							var cloned = orgMapDivEl.clone();
							
							if($('#' + currentDiv).find(".ui-autocomplete-multiselect-item[type='UR'][code='"+ item.UserCode+"']").length > 0){
								duplication = true;
								return true;
							}
							
							cloned.attr('type', 'UR').attr('code', item.UserCode);
							cloned.find('.ui-icon-close').before(CFN_GetDicInfo(item.DisplayName));
							
							$('#' + currentDiv + ' .ui-autocomplete-input').before(cloned);
						});
						
						if(duplication) Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />'); // 특정 대상을 중복해서 입력할 수 없습니다
						
						break;
				}
			});
			
			$("#targetDetailDiv > a, #resultViewDetailDiv > a").on("click", function(e){
				var currentDiv = $(e.currentTarget).closest("div").attr("id");
				var url = "/groupware/collab/CollabTargetListPopup.do"
						+ "?callback=" + "surveyTargetPopupCallback"
						+ "&prjSeq=" + prjSeq
						+ "&prjType=" + prjType
						+ "&currentDiv=" + currentDiv
						+ "&objectType=SURVEY";
				
				Common.open("","surveyTargetPopup", "<spring:message code='Cache.lbl_surveySubject' />", url, "500px", "650px", "iframe", true, null, null, true); // 설문 대상
			});
			
			$("#pSwitchEditor").on("click", function(){
				switchTextAreaEditor(this);
			});
			
			$("[name=surveyTarget]").eq(1).attr('checked', true);
			$("[name=surveyTarget]").on('change', function(){
				// 설문대상유형(P:전체, S:지정)
				this.value === 'P' 	&&  $("#surveyTargetDetail").hide();
				this.value === 'S' 	&& 	$("#surveyTargetDetail").show();
			});
			
			if(param.reqType =="create"){
				coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'});	
			}else if(param.reqType == "edit"){
				var fileList = JSON.parse(JSON.stringify(g_fileList));
				coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'}, fileList);
				$(".surveyMakeListView").hide();
				$(".surveryTopButtons a").hide();
				$("a[name=modifyBtn]").show();
				$("a[name=modifyBtn]").off("click").on("click", function(){
					updateSurvey('edit');
				});
			}else{ 	// 수정, 임시저장, 재사용한 설문
				var fileList = JSON.parse(JSON.stringify(g_fileList));
				coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'}, fileList);
			}
		}
		
		// 문항 생성
		var createQuestion = function(){

	 		if (param.reqType == "create") {	// 신규
	 			$("a[name=registBtn], a[name=tempBtn]").show();	// 버튼 display
	 			
	 			$(".surMListcont").append(surveyQSDivEl.clone());
				
				sortable();	// sortable
//				$("#surveyTarget2").prop('checked', true);
				
				syncGroupInfo();	// 그룹 정보, 번호, 문항 번호

				
			} else {	// 수정, 임시저장, 재사용한 설문
				if(param.reqType == "reuse"){
					$("a[name=registBtn], a[name=tempBtn]").show();	// 버튼 display
				}else{
					$("a[name=updateBtn], a[name=modifyBtn], a[name=deleteBtn]").show();
				}
				
				$.ajax({
					type: "POST",
					data: {surveyId : param.surveyId},
					async: false,
					url: "/groupware/survey/getSurveyData.do",
					success: function(list){
						surveyInfo = $.extend(true, {}, list.data);
						g_fileList = list.fileList;
						
						setSurveyData();	// 조회한 데이터 세팅
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/groupware/survey/getSurveyData.do", response, status, error);
					}
				});
				
				$.ajax({
					type: "POST",
					data: {surveyID : param.surveyId},
					url: "/groupware/survey/getCollabSurveyInfo.do",
					success: function(result){
						var prjInfo = result.data;
						
						$("#selectProjectSection").val(prjInfo.sectionSeq).prop("selected", true);
						$("#selectProjectSection").trigger("change");
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/groupware/survey/getCollabSurveyInfo.do", response, status, error);
					}
				});
			}
		}
		
		// 설문 파라미터 생성
		var makeSurveyParam = function(state){
			var surveyDate =  coviCtrl.getDataByParentId('surveyCalendarPicker');
			var resultDate =  coviCtrl.getDataByParentId('resultViewCalendarPicker');
			
			surveyInfo = new Object();	// 설문 정보
			surveyInfo.surveyID = (param.reqType == "create") ? '' : param.surveyId;
			var isGrouping = $(".surveyMakeListView").children().hasClass("group") ? 'Y' : 'N';
			surveyInfo.isGrouping = isGrouping;	// 그룹핑 타입
			surveyInfo.subject = $("#surveySubject").val();	// 주제
			surveyInfo.isImportance = $("#isImportance").hasClass("active") ? 'Y' : 'N';	// 긴급

			var subjectHtml = '';
			if ($("#isSubjectBold").hasClass("active")) subjectHtml += '<b>';
			subjectHtml += '<font color="' + '#000' + '">' + surveyInfo.subject + '</font>';
			if ($("#isSubjectBold").hasClass("active")) subjectHtml += '</b>';
			surveyInfo.subjectHtml = subjectHtml;
			
			surveyInfo.isAnonymouse = $("#chkGrade").is(":checked") ? 'Y' : 'N'	// 익명사용
			surveyInfo.isSendTodo = $("#isSendTodo").hasClass("on") ? 'Y' : 'N'	// TODO
			surveyInfo.isSendMail = $("#isSendMail").hasClass("on") ? 'Y' : 'N'	// 메일사용
			surveyInfo.surveyType = "R";	// 설문종류		
			surveyInfo.targetRespondentType = $("[name=surveyTarget]:checked").val();	// 설문대상유형(A:전체,S:지정)		
			var isDescriptionUseEditor = ($('#pSwitchEditor').attr('value') == 'editor') ? 'Y' : 'N'	// 설명 에디터 사용여부
			surveyInfo.isDescriptionUseEditor = isDescriptionUseEditor;
			surveyInfo.description =  (isDescriptionUseEditor == 'Y') ? coviEditor.getBody(g_editorKind, 'tbContentElement') : $("#description").val();	// 설명
			surveyInfo.inlineImage =  (isDescriptionUseEditor == 'Y') ? coviEditor.getImages(g_editorKind, 'tbContentElement') : '';	// 인라인 이미지 정보
			surveyInfo.state = state;	// 설문상태
			surveyInfo.surveyStartDate = surveyDate.startDate;	// 설문기간 시작
			surveyInfo.surveyEndDate = surveyDate.endDate	// 설문기간 종료
			surveyInfo.resultViewStartDate = resultDate.startDate	// 조회기간 시작
			surveyInfo.resultViewEndDate = resultDate.endDate	// 조회기간 종료
	   		surveyInfo.companyCode = Common.getSession("DN_Code");
			
			//surveyInfo.respondentTarget = [{targetType : 'UR', targetCode : 'bjlsm2', targetDeptCode : 'U10000002'}];	// 참여 대상
	   		var respondentTargetArr = new Array();
	   		$('#targetDetailDiv').find('.ui-autocomplete-multiselect-item').each(function (i, v) {
	   			var item = $(v);
	 			var respondentTarget = new Object();
	 			
				respondentTarget.targetType = item.attr('type');
				respondentTarget.targetCode = item.attr('code');
	   		
				respondentTargetArr.push(respondentTarget);
			});
	   		surveyInfo.respondentTarget = respondentTargetArr;	// 참여 대상
	   		
	   		//surveyInfo.resultviewTarget = [{targetType : 'UR', targetCode : 'bjlsm2', targetDeptCode : 'U10000002'}];	// 결과 공개 대상
	   		var resultviewTargetArr = new Array();
	   		$('#resultViewDetailDiv').find('.ui-autocomplete-multiselect-item').each(function (i, v) {
	   			var item = $(v);
				var resultview = new Object();
				
				resultview.targetType = item.attr('type');
				resultview.targetCode = item.attr('code');
	   		
				resultviewTargetArr.push(resultview);
			});
	   		surveyInfo.resultviewTarget = resultviewTargetArr;	// 결과 공개 대상
			surveyInfo.reviewerCode = $('#reviewerDetailDiv').find('.ui-autocomplete-multiselect-item').attr('code');	// 검토자
			surveyInfo.reviewerDeptCode = '';
	   		surveyInfo.approverCode = $('#approverDetailDiv').find('.ui-autocomplete-multiselect-item').attr('code');	// 승인자
	   		surveyInfo.approverDeptCode = '';
	   		surveyInfo.communityID = 0;
	   		surveyInfo.prjInfo = JSON.stringify($("#selectProjectSection").data());
	   		
	   		var questionInfo = null;
	   		var questionInfoArr = new Array();
	   		var itemInfo = null;
	   		var itemInfoArr = null;
	   		var isEtc = null;
	   		var nextDefaultQuestionNo = 0; 
	   			
			$(".surveyMakeListView").find('.surveyMakeBox').each(function (i, v) {
				var question = $(this);
				questionInfo = new Object();	// 문항 정보
				questionInfo.paragraph = question.find('.paragraphText').val();	// 지문
				questionInfo.question = question.find('.questionText').val();	// 문항
				questionInfo.description = question.find('.descriptionText').val();	// 설명
				questionInfo.questionNO = question.find('.ribbon').text();	// 문항번호
				questionInfo.questionType = question.find('.qTypeSelBox option:selected').val();	// 문항 유형			
				questionInfo.isRequired = question.find('.qReq').hasClass('on') ? 'Y' : 'N';	// 필수여부
				questionInfo.requiredInfo = question.find('.requiredInfo').val();	// 필수 체크시 알림문구
				
				// 그룹 분기
				if (isGrouping == "Y") {
					questionInfo.groupingNo = question.siblings('.gNumTxt').text();	// 그룹번호
					questionInfo.groupName = question.siblings('.sgTitle').find('.gName').val();	// 그룹명
					questionInfo.nextGroupingNo = question.siblings('.groupQuartSelect').find('.gDivSel option:selected').val();	// 그룹분기시 다음그룹번호
				} else {
					questionInfo.groupingNo = 0;
					questionInfo.nextGroupingNo = 0;
				}

				itemInfoArr = new Array();
				isEtc = question.find('.item-text').length > 0 ? 'Y' : 'N';
				nextDefaultQuestionNo = question.find('.qNNum').html();
				questionInfo.nextDefaultQuestionNO = nextDefaultQuestionNo;
				
				question.find('.itemDtl:visible').each(function (i, v) {
					var item = $(this);
					
					itemInfo = new Object();	// 보기 정보
					itemInfo.itemNO = (i + 1);	// 보기번호
					itemInfo.item = item.find('.itemTxt').val();	// 보기
					
					if (questionInfo.questionType == "S") {
						itemInfo.nextQuestionNO = item.find('.iDivSel option:selected').val();	// 문항분기시 다음문항번호
					} else {
						itemInfo.nextQuestionNO = nextDefaultQuestionNo;
					}
					
					itemInfo.fileIds = item.find('.fileIds').val();	// front 이미지 fileId
					itemInfo.updateFileIds = item.find('.updateFileIds').val() ? ";" + item.find('.updateFileIds').val() + ";" : "";	// back update 이미지 fileId
					itemInfo.deleteFileIds = item.find('.deleteFileIds').val();	// back delete 이미지 fileId
					
					itemInfoArr.push(itemInfo);
				});
				
				var etcDiv = question.find('div.item-text');
				if (questionInfo.questionType == "S" && etcDiv.length > 0) {
					itemInfo = new Object();
					itemInfo.itemNO = (itemInfoArr.length + 1);
					itemInfo.item = '';
					itemInfo.nextQuestionNO = etcDiv.siblings('.sruTitleCont').find('.qNNum').html();
					
					itemInfoArr.push(itemInfo);
				}
				
				questionInfo.isEtc = isEtc;
				questionInfo.items = itemInfoArr;
				questionInfo.itemCount = itemInfoArr.length;
				
				questionInfoArr.push(questionInfo);
			});
		   	
		   	surveyInfo.questions = questionInfoArr;
			surveyInfo.questionCount = questionInfoArr.length;
		}
		
		// 조회한 데이터 세팅
		var setSurveyData = function(){
			$("#surveySubject").val(surveyInfo.subject);	// 주제
			if (surveyInfo.isImportance == 'Y') $("#isImportance").addClass("active"); // 긴급 
			if (surveyInfo.isSubjectBold == 'Y') {
				$('#isSubjectBold').addClass('active');	
				$('#surveySubject').css('font-weight', 'bold');	// BOLD	
			}
			(surveyInfo.isAnonymouse == 'Y') ? $("#chkGrade").prop('checked', true) : $("#chkGrade").prop('checked', false);	// 익명사용
			(surveyInfo.isSendTodo == 'Y') ? $("#isSendTodo").addClass("on") : $("#isSendTodo").removeClass("on");	// TODO
			(surveyInfo.isSendMail == 'Y') ? $("#isSendMail").addClass("on") : $("#isSendMail").removeClass("on");	// 메일사용
			if (surveyInfo.isDescriptionUseEditor == 'Y') {
				$("#dext5").show();
				$("#description").hide();
				$("#pSwitchEditor").attr("value", "editor").find("a").html("<spring:message code='Cache.lbl_writeTextArea' />");
				
				coviEditor.loadEditor( 'dext5', {
					editorType : g_editorKind,//editor 종류(현재는 dext5)
					containerID : 'tbContentElement',//frame id값
					frameHeight : '400',//에디터의 높이
					focusObjID : '',
					useResize : 'Y',
					bizSection : 'Survey',
					onLoad: function(){
						coviEditor.setBody(g_editorKind, 'tbContentElement', surveyInfo.description);
					}
				});
			} else {
				$("#dext5").hide();
				$("#description").show();
				$("#pSwitchEditor").attr("value", "textarea").find("a").html("<spring:message code='Cache.lbl_editChange' />");
				$("#description").val(surveyInfo.description);	// 설명
			}
			$('#surveyCalendarPicker').find('.hasDatepicker:eq(0)').val(CFN_TransLocalTime(surveyInfo.surveyStartDate,'yyyy.MM.dd'));	// 설문기간 시작
			$('#surveyCalendarPicker').find('.hasDatepicker:eq(1)').val(CFN_TransLocalTime(surveyInfo.surveyEndDate,'yyyy.MM.dd'));	// 설문기간 종료
			$('#resultViewCalendarPicker').find('.hasDatepicker:eq(0)').val(CFN_TransLocalTime(surveyInfo.resultViewStartDate,'yyyy.MM.dd'));	// 조회기간 시작
			$('#resultViewCalendarPicker').find('.hasDatepicker:eq(1)').val(CFN_TransLocalTime(surveyInfo.resultViewEndDate,'yyyy.MM.dd'));	// 조회기간 종료
			
			var autoTagsUrl = String.format("/groupware/collabProject/getProjectMemberList.do?prjSeq={0}&prjType={1}&objectType=SURVEY", prjSeq, prjType);
			
			coviCtrl.setCustomAjaxAutoTags('targetDetailInput', autoTagsUrl, NonMultiAutoInfos);	// 설문대상
			coviCtrl.setCustomAjaxAutoTags('resultViewDetailInput', autoTagsUrl, NonMultiAutoInfos);	// 결과공개
			
			$('#targetDetailInput, #resultViewDetailInput').parent().css('width', 'calc(100% - 85px)');

			if(surveyInfo.targetRespondentType == 'P') {
				$("#surveyTarget1").prop('checked', true);
				$("#surveyTarget2").prop('checked', false);

				$("#surveyTargetDetail").hide();
			} else {
				$("#surveyTarget1").prop('checked', false);
				$("#surveyTarget2").prop('checked', true);

				$("#surveyTargetDetail").show();
			}
			
			$.each(surveyInfo.respondentTarget, function (i, v) {	// 설문대상
				var cloned = orgMapDivEl.clone().attr('type', v.type).attr('code', v.code);
				cloned.find('.ui-icon-close').before(v.label);
			
				$('#targetDetailInput').before(cloned);
			});
			$.each(surveyInfo.resultviewTarget, function (i, v) {	// 결과공개
				var cloned = orgMapDivEl.clone().attr('type', v.type).attr('code', v.code);
				cloned.find('.ui-icon-close').before(v.label);
			
				$('#resultViewDetailInput').before(cloned);
			});		
			var reviewerCodeText = surveyInfo.reviewerCodeText;	// 검토자
			if (reviewerCodeText != undefined && reviewerCodeText != '') {
				var cloned = orgMapDivEl.clone().attr('type', 'UR').attr('code', reviewerCodeText.split(';')[0]);
				cloned.find('.ui-icon-close').before(reviewerCodeText.split(';')[1]);
			
				$('#reviewerDetailInput').before(cloned);
			}
			var approverCodeText = surveyInfo.approverCodeText;	// 승인자
			if (approverCodeText != undefined && approverCodeText != '') {
				var cloned = orgMapDivEl.clone().attr('type', 'UR').attr('code', approverCodeText.split(';')[0]);
				cloned.find('.ui-icon-close').before(approverCodeText.split(';')[1]);
			
				$('#approverDetailInput').before(cloned);
			}		
			
		   	var surveyType = surveyInfo.surveyType;
			var isGrouping = surveyInfo.isGrouping;
			if (isGrouping == 'Y') $(".surveyMakeListView").find('.surMListcont').remove();
			
	 		$.each(surveyInfo.questions, function(i, v) {
				var questionType = v.questionType;
				var isEtc = v.isEtc;
				var questionClone;
				if (questionType == 'S') {
					questionClone = surveyQSDivEl.clone();	// 객관식
				} else if (questionType == 'D') {	
					questionClone = surveyQDDivEl.clone();	// 주관식
				} else if (questionType == 'M') {	
					questionClone = surveyQMDivEl.clone();	// 복수응답
				} else if (questionType == 'N') {	
					questionClone = surveyQNDivEl.clone();	// 순위선택
				}
				questionClone.find('div.itemDtl').remove();
				questionClone.find('.ribbon').text(v.questionNO);	// 문항 번호
				
				if (typeof(v.paragraph) != "undefined" || typeof(v.description) != "undefined") {	// 지문 + 설명
					questionClone.find('.sruTitleCont').before(exPlanDivEl.clone());
					questionClone.find('.paragraphText').val(v.paragraph);
					questionClone.find('.descriptionText').val(v.description);
				} 
				questionClone.find('.questionText').val(v.question);	// 문항
				questionClone.find('.qTypeSelBox').val(v.questionType);	// 문항 유형
				if (v.isRequired == 'Y') questionClone.find('.qReq').removeClass("on").addClass("on");	// 필수여부
				if (questionType == 'D' && v.isRequired == 'Y'){ //주관식, 필수
	        		questionClone.find('.requiredInfo').val(v.requiredInfo);	// 주관식 필수 체크시 알림문구
	        		questionClone.find('.requiredInfo').show();
	        	}
				
				questionClone.find('.qNNum').html(v.nextDefaultQuestionNO);	// 분기 아닐 시 다음 문항
				
				var iLen = v.items.length;
				$.each(v.items, function(i, v) {
					var itemClone = null;
					if (questionType == 'S') {
						if (i == (iLen - 1) && isEtc == 'Y') {
							questionClone.find('.item-hidden').before(itemTextHidDivObj.clone().removeClass('item-text-hidden').addClass('item-text'));
						} else {
							itemClone = itemSDivEl.clone();	// 객관식
							
							if (isGrouping == 'N') {	// 일반 분기일때
								itemClone.find('.iDivSel').replaceWith(makeDivSelectBox(isGrouping, 'iDivSel', v.itemDivOptions));	// 분기 selectbox
								itemClone.find('.iDivSel').val(v.nextQuestionNO);	// 문항분기시 다음문항번호
							}
							itemClone.find('.itemTxt').val(v.item).attr("placeholder", "<spring:message code='Cache.lbl_view' />" + (i + 1));	// 보기내용, placeholder
						}
					} else if (questionType == 'D') {	
						itemClone = itemDDivEl.clone();	// 주관식
						itemClone.find('.itemTxt').val(v.item);	// 보기내용
					} else if (questionType == 'M') {	
						itemClone = itemMDivEl.clone();	// 복수응답
						itemClone.find('.itemTxt').val(v.item).attr("placeholder", "<spring:message code='Cache.lbl_view' />" + (i + 1));	// 보기내용, placeholder
					} else if (questionType == 'N') {	
						itemClone = itemNDivEl.clone();	// 순위선택
						itemClone.find('.itemTxt').val(v.item).attr("placeholder", "<spring:message code='Cache.lbl_view' />" + (i + 1));	// 보기내용, placeholder
					}
					
					if (questionType == 'D') {
						questionClone.find('.itemSetOption').before(itemClone);
					} else {
						if (typeof v.updateFileIds !== 'undefined' && v.updateFileIds !== '') {	// 이미지		※ Bugfix : v.updateFileIds 가 '' 으로 들어올경우 Script Error 및 Exception 발생
							var fileIds = v.updateFileIds.split(';');
							
							$.each(fileIds, function (i, v) {
								if (itemClone.find('.photoBox').length == 0) itemClone.append(photoDivEl.clone());
								var thumbSrc = "/covicore/common/preview/Survey/" + v + ".do";
								var cloned = photoDetailDivEl.clone();
								$(cloned).removeClass('frontPhoto').find('img').attr('src', thumbSrc);
								$(itemClone).find('.photoBox').append(cloned);
							});
							
							$(itemClone).find('.updateFileIds').val(v.updateFileIds);
						}
						
						questionClone.find('.item-hidden').before(itemClone);
					}
				});
							
				// 그룹 분기 일때
				if (isGrouping == 'Y') {
					questionClone.find('.itemSetOption').append(questionMoveEl.clone());
					questionClone.find('.gMDivSel').replaceWith(makeDivSelectBox(isGrouping, 'gMDivSel', v.groupMoveOptions));	// 그룹이동 selectbox
					
					var groupClone;
					if ($(".surveyMakeListView").find('.group').length > 0) {
	 					var index = -1;
	 					
						$(".surveyMakeListView").find('.group').each(function(i) {
							if (v.groupingNo == $(this).find('.gNumTxt').html()) {
								index = i;
								return false;
							}
						});
						
						if (index == -1) {
							groupClone = groupDivEl.clone();
							groupClone.find('div.surveyMakeBox').replaceWith(questionClone);
							groupClone.find('.gName').val(v.groupName);	// 그룹명
							groupClone.find('.gDivSel').replaceWith(makeDivSelectBox(isGrouping, 'gDivSel', v.groupDivOptions));	// 분기 selectbox
							groupClone.find('.gDivSel').val(v.nextGroupingNo);	// 그룹분기시 다음그룹번호
							groupClone.find('.gNumTxt').text(v.groupingNo);	// 그룹 번호
						} else {
							$(".surveyMakeListView").find('.group').eq(index).find('.groupQuartSelect').before(questionClone);
						}
					} else {
						groupClone = groupDivEl.clone();
						groupClone.find('div.surveyMakeBox').replaceWith(questionClone);
						groupClone.find('.gName').val(v.groupName);	// 그룹명
						groupClone.find('.gDivSel').replaceWith(makeDivSelectBox(isGrouping, 'gDivSel', v.groupDivOptions));	// 분기 selectbox
						groupClone.find('.gDivSel').val(v.nextGroupingNo);	// 그룹분기시 다음그룹번호
						groupClone.find('.gNumTxt').text(v.groupingNo);	// 그룹 번호
					}
					
					$(".surMListcontEnd").before(groupClone);
				} else {
					$(".surMListcont").append(questionClone);
				}
				
			});
				
			sortable();
			
			syncGroupArr();	// syncGroupArr
			
			setTimeout(function(){
				coviEditor.setBody(g_editorKind, 'tbContentElement', surveyInfo.description);
			}, 500);
		}
		
		// 분기 selectbox
		var makeDivSelectBox = function(isGrouping, className, divOptions){
			var options, len
			
			if(divOptions == undefined){
				len = 0;
			}else{
				options = divOptions.split(',');
				len = options.length;
			}
			var targetDiv = null;
			
			if (isGrouping == "Y") {
				if (className == 'gMDivSel') {
					targetDiv = questionMoveEl.clone();
					targetDiv.append($('<option>', {
						value: '',
						text : '<spring:message code="Cache.lbl_groupTransfer" />'
					}));
				} else {
					targetDiv = groupDivSelEl.clone();
				}
			} else {
				targetDiv = itemDivSelEl.clone();
			}
			
			for (var i=0; i<len; i++) {
				if (options[i] != "99") {
					targetDiv.append($('<option>', {
						value: options[i],
						text : options[i]
					}));
				} else {
					targetDiv.append($('<option>', {
						value: options[i],
						text : '<spring:message code="Cache.lbl_Exit" />'
					}));					
				}
			}
			
			return targetDiv;
		}
		
		// 필수값 체크
		var checkValidation = function(type){
			var resultDate =  coviCtrl.getDataByParentId('resultViewCalendarPicker');
			var surveyDate =  coviCtrl.getDataByParentId('surveyCalendarPicker');

			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
			if ($("#surveySubject").val() == '') {
				alert('<spring:message code="Cache.lbl_surveyMsg9" />');
				return false;
			} else if (!prjSeq) {
				alert("<spring:message code='Cache.msg_selectProject' />"); // 프로젝트를 선택해주세요.
				return false;
			} else if(type === 'modify' || type === 'tempSave'){ // 임시저장일 경우 제목, 프로젝트만 체크
				return true;
			}else if (resultDate.startDate== '' || resultDate.endDate == '' ) {
				alert('<spring:message code="Cache.lbl_surveyMsg12" />');
				return false;
			} else if (surveyDate.startDate== '' || surveyDate.endDate == '' ) {
				alert('<spring:message code="Cache.lbl_surveyMsg13" />');
				return false;
			} else if (surveyDate.endDate < new Date().format('yyyy.MM.dd') ) { //설문 종료일자가 현재일자보다 이전이면
				alert('<spring:message code="Cache.lbl_surveyMsg17" />');
				return false;
			} else if ($("[name=surveyTarget]:checked").val() === 'S' && $('#targetDetailDiv .ui-autocomplete-multiselect-item').length === 0) {
				alert('<spring:message code="Cache.lbl_surveyMsg14" />','','');
				return false;
			} else {
				if ($('#approverDetailDiv').find('.ui-autocomplete-multiselect-item').length <= 0 && Common.getBaseConfig("useSurveyApprover") == "Y" && prjSeq == 0) {
					alert('<spring:message code="Cache.msg_survey25" />');
					return false;
				}else{
					var retValue = true;			

					$(".surveyMakeListView").find(".gName:visible").each(function(idx,obj){
						if($(obj).val() == ""){
							alert('<spring:message code="Cache.lbl_surveyMsg15" />');					
							retValue = false;
							return false;
						}
					});
				
					if(!retValue){
						return retValue;
					}
					$(".surveyMakeBox").find(".questionText:visible,.itemTxt:visible").each(function(idx,obj){
						if($(obj).val() == "" && $(obj).attr("class").split(" ").includes("questionText")){
							alert('<spring:message code="Cache.msg_survey30" />');
							retValue = false;
							return false;
						}else if($(obj).val() == "" && $(obj).attr("class").split(" ").includes("itemTxt") && $(obj).hasClass("inpFocus")){
							alert('<spring:message code="Cache.msg_survey33" />');
							retValue = false;
							return false;
						}
					});
					return retValue;
				}
				
			}
			return true;
		}
		
		// 승인 요청, 임시 저장
		var saveBtn = function(type){
			if (checkValidation(type)) {	// 필수값 체크
				var state = '';
				if (type == 'reqApproval') { //등록
					if(param.prjSeq != 0){ // 요청 페이지가 커뮤니티일 경우 바로 승인완료
						state = 'F'	 // 진행중
					}else if($('#reviewerDetailDiv').find('.ui-autocomplete-multiselect-item').length > 0 ){ // 검토자가 있을 경우
						state = 'B' // 검토대기	
					}else if($('#approverDetailDiv').find('.ui-autocomplete-multiselect-item').length > 0){ //승인자 있을 경우
						state = 'C' //승인대기	
					}else{ // 커뮤니티 요청은 아니지만 검토자와 승인자가 모두 없을 때
						state = 'F'	 // 진행중
					}				
				} else {
					state = 'A'; // 작성중()
				}
				
				makeSurveyParam(state);	// 설문 파라미터 생성
						
				var formData = new FormData(); 
				
				formData.append("surveyInfo", JSON.stringify(surveyInfo));
				
				formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
				for (var i = 0; i < coviFile.files.length; i++) {
					if (typeof coviFile.files[i] == 'object') {
						formData.append("files", coviFile.files[i]);
					}
				}
				formData.append("fileCnt", coviFile.fileInfos.length);
				
	  		  	Common.Confirm("<spring:message code='Cache.msg_survey14' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
				 		$.ajax({
							type : "POST",
							data: formData,
							processData : false,
							contentType : false,
							url : "/groupware/survey/insertCollabSurvey.do",
							success:function (data) {
								if(data.result == "ok") {
									if(data.status === "SUCCESS"){
										Common.Inform("<spring:message code='Cache.msg_survey15' />", "Inform", function(result){
											if(result){
												parent.$(".Project_tabList li[data-type=SURVEY]").click();
												Common.Close();
											}
										});
							  		}else{
							  			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
							  		}
								}
							},
							error:function(response, status, error) {
								CFN_ErrorAjax(url, response, status, error);
							}
						});
					} else {
						return false;
					}
				});
			}
		}
		
		// 미리보기
		var goPreView = function(){
			makeSurveyParam('A');	// 설문 파라미터 생성
			
			Common.open("","preView_pop","<spring:message code='Cache.lbl_preview' />","/groupware/survey/goSurvey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=preview&&isPopup=Y&surveyId=","1000px","650px","iframe",true,null,null,true);
		}

		// 설문 수정 요청
		var updateSurvey = function(type){
			if (checkValidation(type)) {	// 필수값 체크
				var state; 
				var url = "/groupware/survey/updateCollabSurvey.do";
				var typeTxt =  (type == 'modify' ? '<spring:message code="Cache.lbl_Edit" />' : '<spring:message code="Cache.lbl_Regist" />');
				
				if(type == 'modify'){
					state = 'A'	 //작성 중(임시저장)
				}else if(type == 'edit'){ // 등록된 설문을 수정할 경우
					state = 'F'; // 진행중
	   				url = "/groupware/survey/updateSurveyInfo.do";
				}else if(param.prjSeq != 0){ // 요청 페이지가 커뮤니티일 경우 바로 승인완료
					state = 'F'	 // 진행중
				}else if($('#reviewerDetailDiv').find('.ui-autocomplete-multiselect-item').length > 0 ){ // 검토자가 있을 경우
					state = 'B' // 검토대기	
				}else if($('#approverDetailDiv').find('.ui-autocomplete-multiselect-item').length > 0){ //승인자 있을 경우
					state = 'C' //승인대기	
				}else{ // 커뮤니티 요청은 아니지만 검토자와 승인자가 모두 없을 때
					state = 'F'	 // 진행중
				}			
				
				makeSurveyParam(state);	// 설문 파라미터 생성
				
				var formData = new FormData(); 
				
				formData.append("surveyInfo", JSON.stringify(surveyInfo));
				formData.append("surveySubject", $("#surveySubject").val()); // 설문 제목을 업무 제목에 반영하기 위한 데이터
				formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
				for (var i = 0; i < coviFile.files.length; i++) {
					if (typeof coviFile.files[i] == 'object') {
						formData.append("files", coviFile.files[i]);
					}
				}
				formData.append("fileCnt", coviFile.fileInfos.length);
				
			  	Common.Confirm('<spring:message code="Cache.lbl_surveyMsg2" />', "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
				 		$.ajax({
							type : "POST",
							contentType : 'application/json; charset=utf-8',
							data: formData,
							processData : false,
							contentType : false,
							url : url,
							success:function (data) {
								if(data.status === "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_170' />", "Inform", function(result){
										if(result){
											if(parent.$('#btnReload').length>0) {
												parent.$('#btnReload').trigger('click');
											} else if (parent.$(".Project_tabList li[data-type=SURVEY]").length>0){
												parent.$(".Project_tabList li[data-type=SURVEY]").click();
											}
											Common.Close();
										}
									});
						  		}else{
						  			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
						  		}
							},
							error:function(response, status, error) {
								CFN_ErrorAjax(url, response, status, error);
							}
						});
					} else {
						return false;
					}
				});
			}
		}
		
		var switchTextAreaEditor = function(obj){
			if($(obj).attr("value") == "textarea"){
				$("#description").hide();
				$("#dext5").show();
				
				if($("#dext5").html() == ""){
					coviEditor.loadEditor( 'dext5', {
						editorType : g_editorKind,//editor 종류(현재는 dext5)
						containerID : 'tbContentElement',//frame id값
						frameHeight : '400',//에디터의 높이
						focusObjID : '',
						useResize : 'Y',
						bizSection : 'Survey',
						onLoad: function(){
							coviEditor.setBody(g_editorKind, 'tbContentElement', $("#description").val().replaceAll("\n", "<br>"));
						}
					});
				}else{
					if(coviEditor.getBodyText(g_editorKind, 'tbContentElement') == $("#description").val()){
						coviEditor.setBody(g_editorKind, 'tbContentElement', $("#hidDescription").val());
					}else{
						coviEditor.setBody(g_editorKind, 'tbContentElement', $("#description").val().replaceAll("\n", "<br>"));
					}
				}
				
				$(obj).attr("value", "editor");
				$(obj).find("a").html("<spring:message code='Cache.lbl_writeTextArea' />");
			}else{
				$("#dext5").hide();
				$("#description").show();
				
				$(obj).attr("value", "textarea");
				$(obj).find("a").html("<spring:message code='Cache.lbl_editChange' />");
				
				$("#hidDescription").val(coviEditor.getBody(g_editorKind, 'tbContentElement'));
				$("#description").val(coviEditor.getBodyText(g_editorKind, 'tbContentElement'));
			}
		}
		
		var deleteSurvey = function(){
			var surveyIdArr = new Array();
			surveyIdArr.push(surveyInfo.surveyID);
			
	       	Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Confirmation Dialog", function(confirmResult){ /*  삭제하시겠습니까?  */
				if(confirmResult){
			 		$.ajax({
						type: "POST",
						data: {
							"surveyIdArr": surveyIdArr
						},
						url: "/groupware/survey/deleteSurvey.do",
						success: function(data){
							if(data.status === "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_Deleted'/>", "Inform", function() {	/* 삭제 되었습니다 */
									parent.$(".Project_tabList li[data-type=SURVEY]").click();
									Common.Close();
								});
			          		}else{
			          			Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");/* 오류가 발생하였습니다. */
			          		}
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/groupware/survey/updateSurveyState.do", response, status, error);
						}
					});
				} else {
					return false;
				}
			});
		}
		
		var initContent = function(){
			setDefaultSetting();
			createQuestion();	// 문항 생성
			setEvent();
		}
		
		initContent();
	})({
		  "reqType":	"${reqType}" // create(신규), modify(수정), tempSave(임시저장), reuse(재사용), edit(등록사항 수정)
		, "surveyId":	"${surveyId}"
		, "prjSeq": "${prjSeq}"
		, "prjType" : "${prjType}"
	});
</script>