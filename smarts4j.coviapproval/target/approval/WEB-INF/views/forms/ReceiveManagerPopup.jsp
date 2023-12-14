<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = PropertiesUtil.getGlobalProperties().getProperty("resource.version", ""); 
	resourceVersion = resourceVersion.equals("") ? "" : ("?ver=" + resourceVersion);
%>
 <jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include> 
<!-- <script type="text/javascript" src="/approval/resources/script/forms/ApvlineManager.js"></script> -->
<body>
<div class="layer_divpop ui-draggable" id="testpopup_p" style="width: 1100px; /*height: 741px;*/ z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
 <!-- 팝업 Contents 시작 --> 
    <!--appBox 시작 -->
	 <div class="AXTabsLarge" id="ApvTab" style="margin-left: 12px; width: 99%;">
          <div class="AXTabsTray"> 
          	  <a id="checkIndocID" name="docID" class="AXTab on" href="#ax" value="inreceive" onclick="clickApvTab(this)" >대내수신</a> 
	          <a id="checkOutelecID" name="docID" class="AXTab" href="#ax" value="outelecdoc" onclick="clickApvTab(this)" >대외전자</a> 
	          <a id="checkOutpaperID" name="docID" class="AXTab" href="#ax" value="outpaperdoc" onclick="clickApvTab(this)" >대외종이</a>
          </div>
	</div>

	<div id="IframeDiv">
		<iframe id="IframecheckDocType" name="IframecheckDocType" src="deployline.do?pgbn=In" frameborder="0" width="100%" height="580px" scrolling="no"></iframe>
    </div>
    <div id="PaperDiv" style="display: none;"></div>

	<!--appBox 끝 -->
    <!-- 하단버튼 시작 -->
    <%-- <div class="popBtn"> 
	    <input type="button" id="btOK" name="cbBTN" onclick="doButtonAction(this);" class="ooBtn" value="<spring:message code='Cache.btn_Confirm'/>"/><!--확인-->
	    <input type="button" id="btOK" name="cbBTN" onclick="setMultiReceiveInfo();" class="ooBtn" value="<spring:message code='Cache.btn_Confirm'/>"/>
	    <input type="button" id="btExit" name="cbBTN" onclick="doButtonAction(this);" class="gryBtn mr30" value="<spring:message code='Cache.btn_apv_close'/>"/><!--닫기-->
    </div> --%>
    <!-- 하단버튼 끝 --> 
	<!--팝업 컨테이너 끝-->
</div>

</body>
<script type="text/javascript">
	const g_MultiIdx = CFN_GetQueryString("multiidx")=="undefined"? "":CFN_GetQueryString("multiidx");
	let g_oFormEditor = null;
	let g_SelectedReceiveType = '';
	
	$(document).ready(function(){
	    const openID = CFN_GetQueryString("openID")=="undefined"? "":CFN_GetQueryString("openID");
	    if (openID != "") {//Layer popup 실행
	        if ($("#" + openID + "_if", opener.document).length > 0) {
	        	g_oFormEditor = $("#" + openID + "_if", opener.document)[0].contentWindow;
	        } else { //바닥 popup
	        	g_oFormEditor = opener;
	        }
	    } else {
	    	g_oFormEditor = top.opener;
	    }
	    
	    // 다안기안+문서유통인 경우 처리=>이전에 선택한 탭으로 선택
	    if (typeof (g_oFormEditor.isGovMulti()) != 'undefined' && g_oFormEditor.isGovMulti()) {
	    	g_SelectedReceiveType = g_oFormEditor.document.getElementsByName("MULTI_RECEIVE_TYPE")[g_MultiIdx].value;
		    $('div.AXTabsTray').find('a[value="' + g_SelectedReceiveType + '"]').click();
	    }
	});
	
	/* 	
$(window).load(function(){
		//로딩시 내부수신 check값 양식에 넘기기
		top.opener.document.getElementsByName("MULTI_RECEIVE_CHECK")[1].value = 'inreceive'; 
	}); */

 function clickApvTab(pObj){
	$("#ApvTab .AXTab").attr("class","AXTab");
	$(pObj).addClass("AXTab on");
	
	var val =  $(pObj).attr("value");
	var url = "";
	
	if(val == "inreceive"){
		$("#IframeDiv").show();
		$("#PaperDiv").hide();
		//url = "multiReceiveline.do?mode=receviePopup&pgbn=In";
		url = "deployline.do?mode=receviePopup&pgbn=In&multiidx=" + g_MultiIdx + "&multireceivetype=" + val;
	}
	else if(val == "outelecdoc"){//outelecdoc
		$("#IframeDiv").show();
		$("#PaperDiv").hide();
		url = "govdoc/deployline.do?mode=OutreceviePopup&itemnum=999&multiidx=" + g_MultiIdx + "&multireceivetype=" + val;
	} 
	else{//outpaperdoc
		$("#PaperDiv").show();
		$("#IframeDiv").hide();
		outpaper();
		savedData();
		
		// 다안기안+문서유통시. 선택된 수신처 타입 지정
		if (g_SelectedReceiveType == 'outpaperdoc' && typeof (g_oFormEditor.isGovMulti()) != 'undefined' && g_oFormEditor.isGovMulti()) {
			setSelectedDataOutPaper();
		}
	}
	
	$("#IframecheckDocType").attr("src",url);
}

	function setSelectedDataOutPaper() {
		// 기 선택된 정보 바인딩
		const selectedData = g_oFormEditor.document.getElementsByName('MULTI_RECEIVENAMES')[g_MultiIdx].value;
		selectedData.split(',').forEach(function(data) { addMulti(data); });
	}
 function savedData(){
	 var saveRecData = "";
	 
	 //saveRecData = top.opener.document.getElementsByName("MULTI_Receivepaper")[1].value;
 }
 
 function outpaper(){
	 GridHtml ="";
	 GridHtml += "<input type='text' id='Receivepaper' autocomplete='off' placeholder='수신자를 입력하십시오.' style='margin: 15px; width: 300px;'>";
	 GridHtml += "<input type='button' id='btRecDept' name='cbBTN' style='width: 80px;' onclick='addMulti();' value='확인'/>";
	 GridHtml += "<div>";
	 GridHtml += "</div>";
	 GridHtml += "<div class='appTab' style='width: calc(100% - 580px) !important; margin-top: -80px;margin-right:40px; margin-bottom: 10px; float: right;'>";
	 GridHtml += "<div class='AXTabsLarge' id='ApvTab'>";
	 GridHtml += 	"<div class='AXTabsTray'> ";
	 GridHtml += 		"<a id='tabrecinfo' class='AXTab on' href='#ax'  value='divrecinfo'><spring:message code='Cache.lbl_apv_DDistribute' /></a>";
	 GridHtml += 	"</div>";
	 GridHtml += "</div>";
	 GridHtml += "<div class='appInfo02' id='divrecinfo'>";
	 GridHtml += 	"<div id='divrecinfolist'>";
	 GridHtml += 	"<table id='tblrecinfo' name='tblrecinfo' class='tableStyle t_center hover infoTable'><colgroup>";
	 GridHtml += 		"<col id='Col1' style='width:100px' />";
	 GridHtml += 		"<col id='Col2' style='width:*'/>";
	 GridHtml += 		"<col id='Col3' style='width:50px'/>";
	 GridHtml += 		"</colgroup><thead>";
	 GridHtml += 		"<tr>";
	 GridHtml += 			"<td colspan='3'>";
	 GridHtml += 			"<h3 class='titIcn'><spring:message code='Cache.lbl_apv_DDistribute' /></h3>";
	 GridHtml += 			"</td>";
	 GridHtml += 		"</tr>";
	 GridHtml += 		"</thead>";
	 GridHtml += 	"<tbody>";
	 GridHtml += 		"<tr style='display: none;'>";
	 GridHtml += 		"<td></td>";
	 //GridHtml += 		"<td></td>";
	 //GridHtml += 		"</tr>";
	 //GridHtml += 		"<tr style='display: none;'>";
	 //GridHtml += 		"<td></td>";
	 //GridHtml += 		"<td></td>";
	 //GridHtml += 		"</tr>";
	 GridHtml += 	"</tbody>";
	 GridHtml += "</table>";
	 GridHtml += "</div>";
	 GridHtml += "</div>";
	 GridHtml += "</div>";
	 GridHtml += "</div>";
	 
	 GridHtml += "<div class='popBtn'> ";
	 GridHtml += "<input type='button' id='btOK' name='cbBTN' onclick='ReceivebtnOK();' class='ooBtn' value='<spring:message code='Cache.btn_Confirm'/>'/>";
	 GridHtml += "&nbsp;";
	 GridHtml += "<input type='button' id='btExit' name='cbBTN' onclick='ReceivebtnEXIT();' class='gryBtn mr30' value='<spring:message code='Cache.btn_apv_close'/>'/><!--닫기-->";
	 GridHtml += "</div>";
      
      $("#PaperDiv").html(GridHtml);
      $("#Receivepaper").attr("onkeypress","if (event.keyCode==13){ $('#btRecDept').click(); return false;}");
 }	 
var rRecDept = "";	
 function addMulti(data){
		
    var aRecDept = !data ? $("#Receivepaper").val() : data; // 기 선택된 데이터 바인딩 할 때 data param 사용
    var sRecDept = "";
	var j = $("#tblrecinfo").find('tbody>tr').length;

	if(aRecDept == ""){}
	else{
		if (aRecDept.includes(',')) {
			Common.Warning("수신처에 ',(콤마)'를 포함할 수 없습니다.");
		} else {
            sRecDept += 	"<tr id="+ j +">";
            sRecDept += 		"<td colspan='2'>";
            sRecDept += 		aRecDept;
            sRecDept += 		"</td>";
            sRecDept += 		"<td><a href='#' class='icnDel' id="+ j +" onclick='deleList(this)'></a></td>";
            sRecDept += 	"</tr>";
            
		    $("#tblrecinfo").append(sRecDept);
		    $("#Receivepaper").val("");
		}
	}
 }
 
 function deleList(obj){
	 var delID = $(obj).attr("id");
	 $("#"+delID+"").remove();
 }
 
function ReceivebtnOK(){ 
	var RecPaperData = "";
	var RecPaperLen = "";
	var RecPaperInfo = "";
	 
	RecPaperDataR = $("#tblrecinfo").find('tbody')[0].innerText.replaceAll("\n","").replaceAll("\t",",");
	RecPaperData = $("#tblrecinfo").find('tbody')[0].innerText.replaceAll("\n","").split("\t");
	RecPaperLen = RecPaperData.length;
	let HwpCtrl = typeof (g_oFormEditor.isGovMulti()) != 'undefined' && g_oFormEditor.isGovMulti() ? g_oFormEditor.document.getElementById('tbContentElement' + g_MultiIdx + 'Frame').contentWindow.HwpCtrl : g_oFormEditor.HwpCtrl; // 다안기안+문서유통시 안 index에 따라 한글에디터 지정

    //문서유통 일반에디터 사용
	if(typeof(HwpCtrl)== 'undefined'){
		if(RecPaperLen == "2"){
			RecPaperInfo =  RecPaperData[0];
			$("#DocRecLine",opener.document).val(RecPaperInfo.replace(/<[^>]*>?/g, ''));
			if (typeof (g_oFormEditor.isGovMulti()) != 'undefined' && g_oFormEditor.isGovMulti()) {
				$("#"+"DocRecLine"+g_MultiIdx,top.opener.document).children().val(RecPaperInfo.replace(/<[^>]*>?/g, ''));
				top.opener.document.getElementsByName('MULTI_DOC_RECLINE')[g_MultiIdx].value = RecPaperInfo.replace(/<[^>]*>?/g, '');
			}
		}
		else{
			for(var i=0; i < RecPaperLen-1; i++){
				RecPaperInfo += RecPaperData[i] + ",";
			}  
			RecPaperInfo = RecPaperInfo.substring(0,RecPaperInfo.length-1);
			$("#DocRecLine",opener.document).val(RecPaperInfo.replace(/<[^>]*>?/g, ''));
			// 다안기안
			if (typeof (g_oFormEditor.isGovMulti()) != 'undefined' && g_oFormEditor.isGovMulti()){
				$("#"+"DocRecLine"+g_MultiIdx,top.opener.document).children().val(RecPaperInfo.replace(/<[^>]*>?/g, ''));
				top.opener.document.getElementsByName('MULTI_DOC_RECLINE')[g_MultiIdx].value = RecPaperInfo.replace(/<[^>]*>?/g, '');
				
			}
		}
	//문서유통 한글기안기 사용
	}else{
		if(RecPaperLen == "2"){
			//top.opener.document.getElementsByName("MULTI_Receivepaper")[1].value = RecPaperData[0];
			RecPaperInfo =  RecPaperData[0];
			HwpCtrl.PutFieldText("recipient",RecPaperInfo);
			HwpCtrl.PutFieldText("recipients", " ");
			HwpCtrl.PutFieldText("hrecipients", " ");
		}
		else{
			for(var i=0; i < RecPaperLen-1; i++){
				RecPaperInfo += RecPaperData[i] + ",";
			}  
			RecPaperInfo = RecPaperInfo.substring(0,RecPaperInfo.length-1);
			//top.opener.document.getElementsByName("MULTI_Receivepaper")[1].value = RecPaperInfo;
			HwpCtrl.PutFieldText("hrecipients", "수신자");
			HwpCtrl.PutFieldText("recipient", "수신자 참조");
			HwpCtrl.PutFieldText("recipients",RecPaperInfo);
		}
	}
	
	// 다안기안+문서유통시
	if (typeof (g_oFormEditor.isGovMulti()) != 'undefined' && g_oFormEditor.isGovMulti()) {
		g_oFormEditor.document.getElementsByName('MULTI_RECEIVE_TYPE')[g_MultiIdx].value = 'outpaperdoc';
		g_oFormEditor.document.getElementsByName('MULTI_RECEIVENAMES')[g_MultiIdx].value = RecPaperInfo;
		//g_oFormEditor.document.getElementsByName('MULTI_RECEIPTLIST')[g_MultiIdx].value = RecPaperInfo;
	}else if(top.opener.getInfo("SchemaContext.scDistribution.isUse") == "Y"){
		top.opener.document.getElementById('RECEIVEGOV_TYPE').value = "in"; //대내
	}
	
	//대외수신처 초기화
	g_oFormEditor.document.getElementById("RECEIVEGOV_NAMES").value = "";
	//대내수신처 초기화
	g_oFormEditor.document.getElementById("ReceiveNames").value = "";
	var chkID = top.$("[name='docID'].AXTab.on").attr("id");
	//top.opener.document.getElementsByName("MULTI_RECEIVE_CHECK")[1].value = top.$("#"+chkID).attr("value");
	//top.opener.document.getElementsByName("MULTI_RECEIVE_CHECK")[1].value =  $("#"+$("[name='docID'].AXTab.on").attr("id")).attr("value");
  	window.close();
}
 
function ReceivebtnEXIT(){
	window.close();
 }
</script>
