<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/tf.js<%=resourceVersion%>"></script>
<div class="layer_divpop ui-draggable taskPopLayer" id="testpopup_p" style="width:950px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent">
				<!-- 팝업 내부 시작 -->
				<form id="formData" method="post" enctype="multipart/form-data">
					<div class="taskPopContent  taskAddContent">
						<div class="top" style="display:none">
							<a name="registBtn" onclick="saveTask('I')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Regist'/><!-- 등록 --></a> <!-- 추가 시  -->
							<a name="saveBtn" onclick="saveTask('U')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Save'/><!-- 저장 --></a>  <!--  수정 시  -->
							<a name="confirmBtn"  onclick='Common.Close(); return false; ' class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Confirm'/><!-- 확인 --></a>  <!-- 단순 조회 시  -->
							<a name="cancelBtn" onclick='Common.Close(); return false; ' class="btnTypeDefault ml5" style="display:none"><spring:message code='Cache.lbl_Cancel'/> <!-- 취소 --></a>
						</div>				
						<div class="middle">
							<div class="inputBoxSytel01 type03" id="ATMemberOf" style="display:none;">
								<div><span><spring:message code='Cache.lbl_Activity'/></span></div>
								<div>
									<select id="selLCategory" class="selectType02" style="width:40%;height:25px;" onchange="selLCategoryChange(this)"></select>
									<select id="selMCategory" class="selectType02" style="width:40%;height:25px;" onchange="selMategoryChange(this)"></select>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_JobName'/></span></div>
								<div>
									<p id="ATnameRead" class="textBox" kind="read" style="display:none;"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_RepeateDate'/><!-- 일시 --></span></div>
								<div>
									<p id="periodRead"  kind="read" class="textBox" style="display:none;"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_State'/><!-- 상태 --></span></div>
								<div>
									<p id="stateRead" class="textBox" kind="read" style="display:none;"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03" id="divweight">
								<div><span><spring:message code='Cache.lbl_Priority'/></span></div>
								<div>
									<p id="weightRead" class="textBox" kind="read" style="display:none;"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_ProgressRate'/><!-- 진도율--></span></div>
								<div>
									<p id="progressRead" class="textBox" kind="read" style="display:none;"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_Order'/><!-- 순서--></span></div>
								<div>
									<p id="sortkeyRead" class="textBox" kind="read" style="display:none;"></p>
								</div>
							</div>							
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_task_performer'/><!-- 수행자 --></span></div>
								<div>
									<div class="autoCompleteCustom"  kind="write" style="display:none;">
										<input type="text" id="performer" />
										<a class="btnTypeDefault ml5 " onclick="orgChartPopup('D9','OrgCallBack_SetPerformer','ActivitySet');"><spring:message code='Cache.lbl_DeptOrgMap'/><!-- 조직도 --></a>									
									</div>
									<div class="sharePerSonListBox mt10">
										<ul id="performerList"  class="personBoxList clearFloat">
										</ul>
									</div>
								</div>
							</div>
							
							<!-- 첨부 -->
							<div class="inputBoxSytel01 type03" id="divFileInfos">
								<div><spring:message code='Cache.lbl_File'/></div>
								<div class="attFileListBox" style="position:relative;"></div>					<!-- [Added][FileUpload] 첨부파일 -->
							</div>
							<div id="divAppendFile" class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>	<!-- 파일 첨부 -->
								<div id="con_file" style="padding : 0px;"></div>
							</div>
							
							<div id="commentView" class="commentView"> </div> <!-- 공통 댓글 -->
						</div>
						<div class="bottom">
							<a name="cancelBtn" onclick='Common.Close(); return false; ' class="btnTypeDefault ml5"><spring:message code='Cache.btn_Close'/> <!-- 닫기 --></a>
						</div>
					</div>
				</form>
				<!-- 팝업 내부 끝 -->
		</div>
	</div>
	<input type="hidden" id="txtMemberOf"/>
</div>
<script>
	//# sourceURL=ActivitySetPopup.jsp
	var t_mode = isNull(CFN_GetQueryString("mode").toUpperCase(),'');
	var t_CU_ID = isNull(CFN_GetQueryString("C"),'');
	var t_AT_ID = isNull(CFN_GetQueryString("ActivityId"),'');
	var t_isSearch = isNull(CFN_GetQueryString("isSearch"),'N');
	var t_haveModifyAuth;  //수정권한 (추가시, 수정 시 등록자 또는 소유자일 경우)

	var t_folderInfoObj;  
	var t_TaskInfoObj;  //수정 시 (작업 정보)
	var t_isTempSave; 	//임시저장 여부	: setTaskDataBind() 에서 처리
	
	init();
	
	function init(){
		// [Added][FileUpload]
    	coviFile.fileInfos.length = 0;			// coviFile.fileInfos 초기화

    	selCategoryChange("A");
    	
		t_haveModifyAuth = "N";
		
		if(t_haveModifyAuth=="Y"){
			$('*[kind="read"]').hide();
			$('*[kind="write"]').show()
			
			setTaskControl(t_CU_ID);
		}else{
			$('*[kind="write"]').hide();
			$('*[kind="read"]').show();
		}
		
    	if(Common.getBaseConfig('IsUseWeight') == 'Y'){
        	$("#divweight").show();
    	}else{
        	$("#divweight").hide();
    	}
    	
		setTaskData(t_CU_ID, t_AT_ID);

		$(".attFileListBox").html("");
		if(g_fileList !== undefined && g_fileList !== null && g_fileList.length > 0){
			var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + g_fileList.length + ')');
			var attFileListCont = $('<ul>').addClass('attFileListCont').attr("style", "left: 0;");
			var attFileDownAll = $('<li>').append("<a href='#' onclick='javascript:downloadAll(g_fileList)'>"+Common.getDic("lbl_download_all")+"</a>").append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >').addClass("btnXClose btnAttFileListBoxClose"));
			var attFileList = $('<li>');
			var videoHtml = '';
			
			$.each(g_fileList, function(i, item){
				var iconClass = "";
				if(item.Extention == "ppt" || item.Extention == "pptx"){
					iconClass = "ppt";
				} else if (item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
					iconClass = "fNameexcel";
				} else if (item.Extention == "pdf"){
					iconClass = "pdf";
				} else if (item.Extention == "doc" || item.Extention == "docx"){
					iconClass = "word";
				} else if (item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
					iconClass = "zip";
				} else if (item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
					iconClass = "attImg";
				} else {
					iconClass = "default";
				}
				$(attFileList).append($('<p style="cursor:pointer;"/>').attr({"fileID": item.FileID, "fileToken": item.FileToken}).addClass('fName').append($('<span title="'+item.FileName+'">').addClass(iconClass).text(item.FileName)).append($('<span class="fileSize">').text("("+convertFileSize(item.Size)+")")));
			});
			
			$(attFileListCont).append(attFileDownAll, attFileList);
			$('.attFileListBox').append(attFileAnchor ,attFileListCont);
			$('.attFileListBox .fName').click(function(){
				Common.fileDownLoad($(this).attr("fileID"), $(this).text(), $(this).attr("fileToken"));
			});
			$('.attFileListBox').show();
		} else {
			$('.attFileListBox').hide();
		}
		
		// [Added][FileUpload]
		if(t_haveModifyAuth == "Y") {
			var fileList = JSON.parse(JSON.stringify(g_fileList));
			coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'}, fileList);
			// $(".attFileListBox").hide();
		} else {
			// [Added][FileUpload]
			$("#divAppendFile").hide();
		}

		//Activity level 조정
		if($("#txtMemberOf").val() != ""){
			$("#selLCategory").val($("#txtMemberOf").val()); //Level 체크 필요
		}
		
		//setTitleWidth();
		setButton(t_mode, t_haveModifyAuth, t_isTempSave);
	}
	
	
	function selCategoryChange(plevelType){
		var CategoryType = plevelType;
		
		if(CategoryType =='T'){	//대분류
			$('#selLCategory').find('option').remove();
			$('#selMCategory').find('option').remove();
			$("#LCategory,#MCategory").hide();
		}else if(CategoryType =='A'){	//중분류 선택시
			$("#MCategory").hide();
			$("#LCategory").show();
			$('#selLCategory').find('option').remove();
			
			$('#selLCategory').append($('<option>', {
				value : "",
		     	text : "<spring:message code='Cache.lbl_Choice' />"
			}))
			
			//대분류 select data	selCategory
			$.getJSON('/groupware/tf/getLevelTaskList.do', {CU_ID : t_CU_ID, MemberOf : ''}, function(d) {
				d.list.forEach(function(d) {
					$('#selLCategory').append($('<option>', {
						value : d.AT_ID ,
				     	text : d.ATName
					}));
					//if (setTaskkKind != "")$("#selLCategory").val(setTaskkKind);
				});
			}).error(function(response, status, error){
				//TODO 추가 오류 처리
				CFN_ErrorAjax("/groupware/tf/getTaskList.do", response, status, error);
			});
		}else if(CategoryType =='B'){	//소분류 선택시
			$("#LCategory,#MCategory").show();
			$('#selLCategory').find('option').remove();
			$('#selMCategory').find('option').remove();
			
			$('#selLCategory').append($('<option>', {
				value : "",
		     	text : "<spring:message code='Cache.lbl_Choice' />"
			}))
			$('#selMCategory').append($('<option>', {
				value : "",
		     	text : "<spring:message code='Cache.lbl_Choice' />"
			}))
			 
			//대분류 select data	selCategory
			$.getJSON('/groupware/tf/getLevelTaskList.do', {CU_ID : t_CU_ID, MemberOf : ''}, function(d) {
				d.list.forEach(function(d) {
					$('#selLCategory').append($('<option>', {
						value : d.AT_ID,
				     	text : d.ATName
					}));
					//if (setTaskkKind != "")$("#selLCategory").val(setTaskkKind);
				});
			}).error(function(response, status, error){
				//TODO 추가 오류 처리
				CFN_ErrorAjax("/groupware/project/getCategory.do", response, status, error);
			});
			
		}
		
	}
	function selLCategoryChange(obj){//대분류 선택시 중분류 셀렉트값 조회
		$('#selMCategory').find('option').remove();
		var LCategoryType = $(obj).val();
		alert(LCategoryType);
		$("#txtMemberOf").val(LCategoryType);
		$('#selMCategory').append($('<option>', {
			value : "",
	     	text : "<spring:message code='Cache.lbl_Choice' />"
		}))		
		//중분류 select data	selCategory
		$.getJSON('/groupware/tf/getLevelTaskList.do', {CU_ID : t_CU_ID, MemberOf : LCategoryType}, function(d) {
			d.list.forEach(function(d) {
				$('#selMCategory').append($('<option>', {
					value : d.AT_ID,
			     	text : d.ATName
				}));
				//if (setTaskkKind != "")$("#selMCategory").val(setTaskkKind);
			});
		}).error(function(response, status, error){
			//TODO 추가 오류 처리
			CFN_ErrorAjax("/groupware/tf/getLevelTaskList.do", response, status, error);
		});
	}
	function selMCategoryChange(obj){//대분류 선택시 중분류 셀렉트값 조회
		var MCategoryType = $(obj).val();
		$("#txtMemberOf").val(MCategoryType);
	}
	
	function convertFileSize(pSize) {
		var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
	    if (pSize == 0) return 'n/a';
	    var i = parseInt(Math.floor(Math.log(pSize) / Math.log(1024)));
	    return (pSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
	}
</script>