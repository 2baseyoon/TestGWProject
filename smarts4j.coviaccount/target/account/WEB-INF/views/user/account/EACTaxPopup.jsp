<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>
	<input id="mode"	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" id="EACTaxPopup" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<div class="ulList type02 mt20">
						<ul>
							
						</ul>
					</div>
				</div>
				<div class="bottom">
					<a onclick="EACTaxPopup.initInform()"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_execute'/></a> <!-- 실행 -->
					<a onclick="EACTaxPopup.closeLayer()"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a> <!-- 닫기 -->
				</div>
			</div>
		</div>	
	</div>
</body>

<script>

	if (!window.EACTaxPopup) {
		window.EACTaxPopup = {};
	}	

	(function(window) {
		
		var EACTaxPopup = {
				popupInit : function(){
					var me = this;
					me.setPopupEdit();
					me.pageDatepicker();
					
					$('#uploadfile').on('change', function(e) {
						var file = $(this)[0].files[0];
						
						if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
					});
				},
				
				setPopupEdit : function(){
					var me		= this;
					var mode	= CFN_GetQueryString("mode");
					$("#mode").val(mode);
					var listStr = '';
					
					if (mode == 'UP') {
						listStr += '<li class="listCol">';
						listStr += '	<div><strong><spring:message code="Cache.ACC_lbl_selectFile" /></strong></div>';
						listStr += '	<div>';
						listStr += '		<input type="text" id="uploadfileText" placeholder="<spring:message code="Cache.ACC_msg_excelUpload_2" />"><a class="btnTypeDefault" onclick="$(\'#uploadfile\').click();"><spring:message code="Cache.ACC_lbl_selectFile" /></a>';
						listStr += '		<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>';
						listStr += '	</div>';
						listStr += '</li>';
						listStr += '<li class="listCol">';
						listStr += '	<div><a onclick="EACTaxPopup.sampleTemplateDownload()" class="btnTypeDefault"><spring:message code="Cache.ACC_lbl_addFile" /></a></div>';
						listStr += '	<div>';
						listStr += '		<span><spring:message code="Cache.ACC_lbl_canUploadSampleFile" /></span>';
						listStr += '	</div>';
						listStr += '</li>';
					}else{
						listStr += '<li class="listCol">';
						listStr += '	<div><strong><spring:message code="Cache.ACC_lbl_StatementGenerateDate" /></strong></div>';
						listStr += '	<div id="dateArea">';
						listStr += '</li>';
						listStr += '<li class="listCol">';
						listStr += '	<div><strong><spring:message code="Cache.ACC_lbl_StatementGenerateDate" /></strong></div>';
						listStr += '	<div><spring:message code="Cache.ACC_lbl_total" />: <span id="eacTaxCnt">0</span></div>';
						listStr += '</li>';
						listStr += '<li class="listCol">';
						listStr += '	<div></div>';
						listStr += '	<div id="eacTaxMsg"><spring:message code="Cache.ACC_lbl_beforeTakeCareOf" /></div>';
						listStr += '</li>';
					}
					
					$(".middle .ulList ul").html(listStr);
				},
				
				pageDatepicker : function(){
					var mode = $("#mode").val();
					
					makeDatepicker('dateArea','sDate','eDate','','','','');
				},
				
				initInform : function(){
					var me		= this;
					var mode	= $("#mode").val();
					
					switch(mode){
						case "UP" :
							me.fileUpload();
							break;
						case "MAPPING" :
							me.autoMapping();
							break;
						case "INITIAL" :
							me.initial();
							break;
						default: 
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
							return false;
					}
					
					try{
						accountCtrl.popupCallBackStr([]);
					}catch (e) {
						coviCmn.traceLog(e);
						coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
					}
				},
				
				fileUpload : function() {
					var formData = new FormData();
					formData.append("uploadfile",$('#uploadfile')[0].files[0]);
					
					$.ajax({
						url : "/account/EACTax/EACTaxExcelUpload.do",
						type: "POST",
						processData: false,
						contentType: false,
						data: formData,
						success:function (data){
							if(data.status == "SUCCESS"){
								Common.Inform(data.message, "Information", function(result){
									if(result){
										EACTaxPopup.closeLayer();
									}
								});
							}else if(data.status == "DUPLICATE"){
								Common.Error("<spring:message code='Cache.ACC_msg_existData' />");
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}				
					});
				},
				
				autoMapping : function() {
					var stDt		= $('#sDate').val();
					var edDt		= $('#eDate').val();
					var sDate		= stDt.replaceAll(".", "-");
					var eDate		= edDt.replaceAll(".", "-");
					
					if(sDate==""||eDate==""){
						Common.Warning("<spring:message code='Cache.ACC_msg_Date'/>"); //날짜를 입력해주세요
						return false;
					}
					
					$.ajax({
						url : "/account/EACTax/EACTaxAutoMapping.do",
						type: "POST",
						data: {
							"sDate":		sDate,
							"eDate":		eDate,
							"userCode":		Common.getSession("UR_ID")
						},
						success: function(data){
							if(data.status == "SUCCESS"){
								var infoMsg = "";
								
								if(data.result == 0){
									infoMsg = "<spring:message code='Cache.ACC_msg_noDataMapping' />"; // 맵핑할 자료가 없습니다.
								}else if(data.result > 0){
									infoMsg = "<spring:message code='Cache.ACC_msg_completeAutoMapping' />"; // 자동맵핑이 완료 되었습니다.
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />");
									return false;
								}
								
								$("#eacTaxCnt").text(data.result);
								$("#eacTaxMsg").text(infoMsg);
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
							}
						},
						error: function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}				
					});
				},
				
				initial : function() {
					var stDt		= $('#sDate').val();
					var edDt		= $('#eDate').val();
					var sDate		= stDt.replaceAll(".", "-");
					var eDate		= edDt.replaceAll(".", "-");
					
					if(sDate==""||eDate==""){
						Common.Warning("<spring:message code='Cache.ACC_msg_Date'/>"); //날짜를 입력해주세요
						return false;
					}
					
					$.ajax({
						url : "/account/EACTax/EACTaxInitial.do",
						type: "POST",
						data: {
							"sDate":	sDate,
							"eDate":	eDate
						},
						success: function(data){
							if(data.status == "SUCCESS"){
								var infoMsg = "";
								
								$("#eacTaxCnt").text(data.result);
								$("#eacTaxMsg").text("<spring:message code='Cache.ACC_msg_completeInitial' />"); // 초기화가 완료 되었습니다.
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
							}
						},
						error: function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}				
					});
				},
				
				sampleTemplateDownload : function() {
					location.href = "/account/EACTax/downloadTemplateFile.do";
				},
				
				closeLayer : function(){
					var isWindowed		= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID			= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.EACTaxPopup = EACTaxPopup;
	})(window);
	
	EACTaxPopup.popupInit();
</script>