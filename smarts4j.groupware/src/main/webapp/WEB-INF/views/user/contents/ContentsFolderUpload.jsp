<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script src="/covicore/resources/script/xlsx.full.min.js"></script>
<body>	
	<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104;">
		<div class="" style="overflow:hidden; padding:0;">
			<div class="ATMgt_popup_wrap">
				<div class="topInfoBox">
					<ul class="bulDashedList">
						<li><span class="icoTheme icoInputFile"></span> <spring:message code='Cache.lbl_bizcard_importContactExplain1' /></li>
						<li><spring:message code='Cache.lbl_bizcard_importContactExplain2' /></li>
					</ul>
					
					<div style="padding-top: 7px;">
						<a onclick="templateDownload('EXCEL');" class="btnTypeDefault btnExcel">Excel Template</a>
					</div>
					
					<!-- 파일 불러오기 -->
					<div class="grayBox02">
						<input type="file" id="importedFile" style="display:none" accept=".csv,.xls, .xlsx" onchange="changeAttachFile()"><!-- accept=".csv, .xls, .xlsx, .txt"  -->
						<div class="inputFileForm" onclick="clickAttachFile(this);">
							<strong class="txtFileName" id="importedFileText"></strong>
							<span class="btnTypeDefault btnIco btnThemeLine btnInputFile"></span>
						</div>
					</div>
					<div class="btnArea">
						<a class="btnTypeDefault btnThemeBg" id="btnImport" ><spring:message code='Cache.btn_preview'/></a>
					</div>
					<!-- // 파일 불러오기 -->
				</div>
				<div class="tblFix tblCont">
					<div id="messageGridDiv"></div>
				</div>		
				<div class="bottom" style="margin-top: 20px;">
					<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_Save'/></a>
					<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
				</div>
			</div>		
		</div>
	</div>
</body>
<script type="text/javascript">

(function(param){
	//폴더 그리드 세팅
	var messageGrid = new coviGrid();		//게시글 Grid
	
	var setInit=function(){
		//사용자 정의 필드 이전의 컬럼헤더
		var msgHeaderData = [ 
        	{key:'key_0',  	label:Common.getDic("lbl_subject"), width:'12', align:'left'},		//제목
        	<c:forEach items="${formList}" var="list" varStatus="status">
	        	<c:if test="${list.FieldType eq 'Input' || list.FieldType eq 'TextArea' || list.FieldType eq 'Number' || list.FieldType eq 'Date'}">
		        	{key:'key_${status.count}',  	label:'${list.DisplayName}', width:'12', align:'left'},		//제목
		        </c:if>	
        	</c:forEach>
        ];
		
		
		messageGrid.setGridHeader(msgHeaderData);
		messageGrid.setGridConfig({
			targetID : "messageGridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"500px",
			fitToWidth:true,
			colHeadTool:false,
			paging:false
		
		});
		
		 var document_list= [
		                    {document_srl:46695, category_srl:0, member_srl:4, nick_name:"Aliswel", user_id:"aliswel", user_name:"admin", title:"지구온난화를 이겨내는 숲의 고수, 대나무 '담양 호남기후변화체험관'", content:"<p><span style=\"color: rgb(85, 85, 85); font-family: 굴림, Gulim, 돋움, Dotum, AppleGothic, sans-serif; text-align: justify;\">지난 3월 초순, 전남 담양군 담양 읍내 메타세쿼이아길 옆에 호남기후변화체험관이 문을 열었다. 담양에 대나무박물관이 들어선 지는 이미 오래됐지만, 메타세쿼이아박물관도 아니고 죽순음식체험관도 아니고 왜 기후변화체험관일까? 이런 의문을 품은 채 느린 걸음으로 죽녹원 대숲길, 관방제림 수변길, 메타세쿼이아 가로수길 산책을 1시간 반 정도 즐긴 다음 메타세쿼이아 가로수길 동쪽 끝 가까운 지점에 사각형 대바구니 형상을 하고 있는 기후변화체험관을 찾아갔다.</span></p>", "tags":"", "readed_count":0, "voted_count":0, "blamed_count":0, "comment_count":0, "regdate":"20140425122850", "last_update":"20140425122850", "extra_vars":"N;", "status":"PUBLIC"},
		                    {document_srl:46693, category_srl:0, member_srl:4, nick_name:"Aliswel", user_id:"aliswel", user_name:"admin", title:"봄바다의 맛과 멋! 서산 삼길포항 우럭 & 간재미", content:"<p><span style=\"color: rgb(85, 85, 85); font-family: 굴림, Gulim, 돋움, Dotum, AppleGothic, sans-serif; text-align: justify;\">겨우내 움츠렸던 몸과 마음이 활짝 기지개를 켜는 봄. 따스한 햇살과 부드럽게 살랑대는 바람을 만끽하기엔 봄바다 여행만한 것이 없다. 서산 삼길포항으로 떠나는 주말 맛기행!</span></p>", "tags":"", "readed_count":0, "voted_count":0, "blamed_count":0, "comment_count":0, "regdate":"20140425122826", "last_update":"20140425122843", "extra_vars":"N;", "status":"PUBLIC"},
		                ]
		
		var gridData = {
                list: document_list,
            };
		messageGrid.setData(gridData);
            
		
	};
	var setEvent=function(){
		$("#btnImport").click(function () { //import
			showListImport();
		});
	};
	var showListImport= function() {
		if ($('#importedFile').val() == "") {
			Common.Warning(Common.getDic("msg_FileNotAdded"), ""); //파일이 추가되지 않았습니다.
			
			return false;
		}

		var file = $('#importedFile');
		var fileObj = file[0].files[0];
		var ext = file.val().split(".").pop().toLowerCase();
		
		 var gridData= []
			
		if (fileObj != undefined) {
			var reader = new FileReader();
			reader.onload = function(e) {
				let data = e.target.result;
				var csvResult = e.target.result.split(/\r?\n|\r/);
				var arrIndex = new Array();
				var tempStr = "";
				for (var i = 0; i < csvResult.length; i++) {
					var strResult = csvResult[i].replaceAll("\"", "").replaceAll("\t", "").replaceAll(", ", ",").replaceAll(" ,", ",");
					var tempResult = strResult.split(',');
					var rows = {}
					for (var j = 0; j < tempResult.length; j++) {
						rows["key_"+j] = tempResult[j];
					}
					gridData.push(rows)
				}
				messageGrid.setData({
	                list: gridData,
	            });

			}
			reader.readAsText(fileObj, "EUC-KR");
		}	
	};
	
	var init = function(){
		setInit();
		setEvent();
	};
	
	init();
})({
	folderID: "${folderID}"
});
	
</script>