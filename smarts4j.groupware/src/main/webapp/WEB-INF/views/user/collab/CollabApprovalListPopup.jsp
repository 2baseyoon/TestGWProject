<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.coviframework.util.XSSUtils"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt")); %>
<% String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv")); %>
<% String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize")); %>
<% int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"))); %>
<% int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"))); %>
<%
	String userID 				= SessionHelper.getSession("USERID");
	String useFido			    = PropertiesUtil.getSecurityProperties().getProperty("fido.login.used");
	String cookie 				= "N";
	String listChangeVal 		= "737";
	Cookie[] cookies  			= request.getCookies();
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getValue().equals(userID)){
			for(int j= 0; j < cookies.length; j++){
				if(cookies[j].getName().equals("ListViewCookie")){
					cookie = cookies[j].getValue();
				}
				if(cookies[j].getName().equals("ListChangeVal")){
					listChangeVal = cookies[j].getValue();
				}
			}
		}
	}
	
	// 이전 검색 조건 세팅
	String schFrmSeGroupID = request.getParameter("schFrmSeGroupID") == null ? "" : request.getParameter("schFrmSeGroupID");
	String schFrmSeGroupWord = request.getParameter("schFrmSeGroupWord") == null ? "" : request.getParameter("schFrmSeGroupWord");
	String schFrmTitleNm = request.getParameter("schFrmTitleNm") == null ? "" : request.getParameter("schFrmTitleNm");
	String schFrmUserNm = request.getParameter("schFrmUserNm") == null ? "" : request.getParameter("schFrmUserNm");
	String schFrmDeputyFromDate = request.getParameter("schFrmDeputyFromDate") == null ? "" : request.getParameter("schFrmDeputyFromDate");
	String schFrmDeputyToDate = request.getParameter("schFrmDeputyToDate") == null ? "" : request.getParameter("schFrmDeputyToDate");
	String schFrmSeSearchID = request.getParameter("schFrmSeSearchID") == null ? "" : request.getParameter("schFrmSeSearchID");
	String schFrmSearchInput = request.getParameter("schFrmSearchInput") == null ? "" : request.getParameter("schFrmSearchInput");
	String schFrmDtlSchBoxSts = request.getParameter("schFrmDtlSchBoxSts") == null ? "" : request.getParameter("schFrmDtlSchBoxSts");
	String schFrmTabId = request.getParameter("schFrmTabId") == null ? "" : request.getParameter("schFrmTabId");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<body>	

	<div class="collabo_popup_wrap">
	
		<div class="selectCalView">
			<!-- 
			<select class="selectType02" id="seSearchID" style="width:130px;"></select> 
			<div class="dateSel type02">
				<input type="text" id="searchInput">
			</div>
			-->
			<select class="selectType01 size90" id="selectSearchType">
				<option value='txtFormSubject'><spring:message code='Cache.lbl_apv_subject'/></option> <!-- 제목 -->
				<option value='txtFormName'><spring:message code='Cache.lbl_apv_formname'/></option> <!--  양식명 -->
			</select>
			<div class="dateSel type02">
				<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="simpleSearchBtn"><spring:message code='Cache.btn_search'/></a>	<!-- 검색 -->
		</div>
		
		<div class="c_titBox">
			<h3 class="cycleTitle2"><spring:message code='Cache.lbl_apv_doc_finish'/></h3>	<!-- 진행중인 프로젝트 -->
		</div>
		<div class="tblList tblCont boradBottomCont StateTb">
			<div id="collabGridDiv"></div>
		</div>
		
		<div class="popBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.btn_Confirm'/></a>
			
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.btn_Close'/></a>
		</div>
		
	</div>
	<input type="hidden" id="txtFormSubject"/>
	<input type="hidden" id="txtFormName"/>
</body>
<script type="text/javascript">

var g_mode = "Complete";
var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
var bstored = "false";
var approvalListType = "user";		// 공통 사용 변수 - 결재함 종류 표현 - 개인결재함

var collabApprovalList = {
		grid:'',
		objectInit : function(){	
			this.makeGrid();
			this.addEvent();
			this.searchData(1);
		}	,
		makeGrid :function(){
			var configObj = {	
					targetID : "collabGridDiv",
					height : "auto",
					page : {
						pageNo: 1, 
						pageSize: 5
						},
					paging : true,
					overflowCell : [7]
			};
			
			var headerData =[
				  {
					display: false,
					key: "showInfo", label: " " , width: "1", align: "center"
				  },
	              {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', sort:false},
                {display: false, 
	            	  key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false,
              	  formatter: function () {
              		   return "<a onclick=\'showDetailInfo(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
					   }
                },								   // 구분
                {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100', align:'left',						       // 제목
				   	  formatter:function () {
				   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden;\">";
				   			
				   			if(CFN_GetCookie("ListViewCookie") == "Y"){
				   				html += "<a class=\"taTit\" onclick='onClickIframeButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormSubKind+"\",\"\",\"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.TaskID+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
				   			}else{
				   				html += "<a class=\"taTit\" onclick='onClickPopButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormSubKind+"\",\"\",\""+this.item.FormInstID+"\",\""+this.item.FormID+"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.TaskID+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
				   			}
				   			
				   			if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	}  //보안
				   			
				   			html += "</div>";
				   			
					   		return html;
						}
                },
                {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',
                	  formatter:function () {
                		  return CFN_GetDicInfo(this.item.FormName);
            	  	  }
                  }, // 양식명
                {display: false,
                	key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
              	  formatter:function(){return this.item.InitiatorUnitName;}
                },				           // 기안부서
                {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
              	  formatter:function(){return this.item.InitiatorName;}
                },						   // 기안자
                {display: false,
                	key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center', sort:false,
              	  formatter:function () {
              		  if(this.item.IsFile == "Y"){
              			  return "<div class=\"fClip\" style=\"float: none;\"><a class=\"mClip\" onclick='openFileList(this,\""+this.item.FormInstID+"\")'><spring:message code='Cache.lbl_attach'/></a></div>"; //첨부
              		  }
              	  }
                }, // 파일
                {display: false,
                	key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center'},									   // 문서번호
                {key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center', sort:'desc',
              	  formatter:function () {
              			  return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.EndDate);
              	  }
                },				   // 일시
                {display: false,
                	key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center', sort:false,
              	  formatter:function () {
              		  if(this.item.IsComment == "Y"){
              			  return "<a onclick='openCommentView(\""+this.item.ProcessArchiveID+"\",\""+this.item.FormInstID+"\")' style='cursor: default;'><img src=\"/approval/resources/images/Approval/ico_comment.gif\" alt=\"\"></a>";
              		  }
              	  }
                },							   // 의견
                {display: false,
                	key:'IsModify', label:'<spring:message code="Cache.lbl_Modify"/>', width:'40', align:'center', sort:false,
              	  formatter:function () {
              		  if(this.item.IsModify == "Y"){
              			  if(this.item.ExtInfo.UseMultiEditYN == "Y") {
              				  return "<span><img src=\"/approval/resources/images/Approval/ico_research_join.gif\" alt=\"\"></span>";
              			  } else {
              				  return "<a onclick='openModifyPop(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormSubKind+"\",\"\",\""+this.item.FormInstID+"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\")'><img src=\"/approval/resources/images/Approval/ico_research_join.gif\" alt=\"\"></a>";
              			  }
              		  }
              	  }
                }];								       // 수정
			
			collabApprovalList.grid = new coviGrid();
			collabApprovalList.grid.setGridHeader(headerData);
			collabApprovalList.grid.setGridConfig(configObj);
		},
		addEvent : function(){	
			
			$("#selectSearchType").on('change', function() {
				$("#searchInput").val('');
				$("#txtFormSubject").val('');
				$("#txtFormName").val('');
			});
			
			$("#simpleSearchBtn").on('click', function(){
				collabApprovalList.searchData(1);
			});
			
			$("#searchInput").on('keydown', function(key){
				if (key.keyCode == 13)
					collabApprovalList.searchData(1);
			});
			
			$("#btnSave").on('click', function(){
				var ListGrid = collabApprovalList.grid;
				TransferCollabTask(ListGrid);
			});
			
			$("#btnCancel").on('click', function(){
				var prjSeqArr = '';
				$.each(collabApprovalList.grid.getCheckedList(0), function(i, v) {
					if (i > 0) prjSeqArr += ',';
					prjSeqArr += v.PrjSeq;
				});
				
				$.ajax({
					type : "POST",
					data : {prjSeqArr : prjSeqArr},
					async: false,
					url : "/groupware/collabProject/cencelProjectAlarm.do",
					success: function (list) {
						collabApprovalList.searchData(1);
					},
					error: function(response, status, error) {
						Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
			
		},
		searchData:function(pageNo){
			var ListGrid = collabApprovalList.grid;
			$("#" + $("#selectSearchType option:selected").val()).val($("#searchInput").val());
			
			if(searchValueValidationCheck()){		// 공통 함수
				setSelectParams(ListGrid);// 공통 함수
				
				ListGrid.bindGrid({
					ajaxUrl:"/approval/user/getApprovalListData.do?&mode="+g_mode,
					ajaxPars: selectParams,
					onLoad: function(){
						coviInput.init();
						setGridCount();
					}
				});
			}
		}
}

$(document).ready(function(){
	collabApprovalList.objectInit();
});

	function setGridCount(){
		var ListGrid = collabApprovalList.grid;
		
		gridCount = ListGrid.page.listCount;
		if (g_mode == "Approval") {
		} else if (g_mode == "Process") {
		}
	}

	function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix,BusinessData1,BusinessData2,TaskID){
		strPiid_List = "";
		strWiid_List = "";
		strFiid_List = "";
		strPtid_List = "";
		
		var width;
		var archived = "false";
		switch (g_mode){
			case "PreApproval" : mode="PREAPPROVAL"; gloct = "PREAPPROVAL"; subkind="T010"; userID=UserCode; break;
			case "Approval" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;
			case "Process" : mode="PROCESS"; gloct = "PROCESS"; subkind=SubKind; userID=UserCode; break;
			case "Complete" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;
			case "Reject" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;
			case "TempSave" : mode="TEMPSAVE"; gloct = "TEMPSAVE"; subkind="";  userID=""; break;
			case "TCInfo" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;
		}
		if(IsWideOpenFormCheck(FormPrefix, FormID) == true){
			width = 1070;
		}else{
			width = 790;
		}
		
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+""
			+"&ExpAppID="+((typeof BusinessData2!="undefined"&&BusinessData2!="undefined")?BusinessData2:"")+"&taskID="+(typeof TaskID!="undefined"?TaskID:""), "", width, (window.screen.height - 100), "resize");
	}


	function onClickIframeButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,BusinessData1,BusinessData2,TaskID){
		strPiid_List = "";
		strWiid_List = "";
		strFiid_List = "";
		strPtid_List = "";
		
		var archived = "false";
		
		switch (g_mode){
			case "PreApproval" : mode="PREAPPROVAL"; gloct = "PREAPPROVAL"; subkind="T010"; userID=UserCode; break;
			case "Approval" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;
			case "Process" : mode="PROCESS"; gloct = "PROCESS"; subkind=SubKind; userID=UserCode; break;
			case "Complete" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;
			case "Reject" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;
			case "TempSave" : mode="TEMPSAVE"; gloct = "TEMPSAVE"; subkind="";  userID=""; break;
			case "TCInfo" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;
		}
		
		document.IframeFrom.target = "Iframe";
	  	document.IframeFrom.action = "/approval/user/ApprovalIframeList.do";
	  	document.IframeFrom.ProcessID.value = ProcessID;
	  	document.IframeFrom.WorkItemID.value = WorkItemID;
	  	document.IframeFrom.PerformerID.value = PerformerID;
	  	document.IframeFrom.ProcessDescriptionID.value = ProcessDescriptionID;
	  	document.IframeFrom.Subkind.value = SubKind;
	  	document.IframeFrom.FormTempInstBoxID.value = FormTempInstBoxID;
	  	document.IframeFrom.FormInstID.value = FormInstID;
	  	document.IframeFrom.FormID.value = FormID;
	  	document.IframeFrom.FormInstTableName.value = FormInstTableName;
	  	document.IframeFrom.Mode.value = mode;
	  	document.IframeFrom.Gloct.value = gloct;
	  	document.IframeFrom.UserCode.value = userID;
	  	document.IframeFrom.Archived.value = archived;
	  	document.IframeFrom.BusinessData1.value = BusinessData1;
	  	document.IframeFrom.BusinessData2.value = BusinessData2;
	  	document.IframeFrom.TaskID.value = TaskID;
	  	
	  	document.IframeFrom.submit();
	  	$("#IframeDiv").show();
	  	$("#contDiv").hide();
	}
	
	// 협업스페이스 업무 등록.
	function TransferCollabTask(grid){
		var checkApprovalList = grid.getCheckedList(1);
		if (checkApprovalList.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (checkApprovalList.length > 0) {
			
			var folderData = new Object;
			folderData["taskSeq"] = CFN_GetQueryString("taskSeq");
			folderData["svcType"] = CFN_GetQueryString("svcType");
			folderData["isExport"] = "N";
			
			transferCollabTask(folderData);
		}
	}
	
	// 선택한 문서를 협업스페이스 업무로 등록.
	function transferCollabTask(ev){
		var ListGrid = collabApprovalList.grid;
		
		var params = [];
		if (CFN_GetQueryString("svcType") == "" || CFN_GetQueryString("svcType") != "PROJECT"){
			params["PrjSeq"] = CFN_GetQueryString("PrjSeq");
			params["PrjType"] = CFN_GetQueryString("PrjType");
			params["taskSeq"] = CFN_GetQueryString("taskSeq");
		}else{
			params["PrjSeq"] = CFN_GetQueryString("PrjSeq");
			params["svcType"] = CFN_GetQueryString("svcType");
		}

		var checkApprovalList = ListGrid.getCheckedList(1);
		if(checkApprovalList.length > 0){
	    	var paramArr = [];
			$(checkApprovalList).each(function(i, v) {
				var json = {};
				json.formInstanceId = v.FormInstID;
				json.processId = v.ProcessArchiveID;
				paramArr.push(json);
			});
			
			if (paramArr.length > 0) {
				var _data = Base64.utf8_to_b64(JSON.stringify(paramArr));
				var url = "/approval/user/transferCollabLink.do";

				var $f = $("#collabLinkIfrm");
				if($f.length == 0){
					$f = $("<form>", {id:"collabLinkIfrm", name:"collabLinkIfrm", action:url, method:"POST", target:"collabLinkIframe"});
					$("body").append($f);
				}
				
				params["formInstanceIDs"]= _data;
				
				$f.html("");
				for(key in params){
					try{
						if(key != "nodeName"){// jquery reserved.
							$f.append($("<input/>", {"type":"hidden", "value":""+params[key], "name":""+key}));
						}
					}catch(e){
						coviCmn.traceLog(e);
					}
				}
				
				var $ifr = $("#collabLinkIframe");
				if($ifr.length == 0){
					$ifr = $("<iframe>", {id:"collabLinkIframe", name:"collabLinkIframe", style:"border:none;width:0px; height:0px;position:absolute;"});
					$("body").append($ifr);
				}

				var txt = "<span style='font-weight:bold'>" + "Process 1 of "+ (checkApprovalList.length)  +" ...</span>";
				Common.Progress("", null, 0);
				$("p","#popup_message").last().html(txt);
				
				// 문서변환 시간이 소요되므로, 서버에서 jspWriter 에 flush 하여 진행율 표시.
				window.callbackCollabTrans = function(mode, idx){
					if(mode == "progress"){
						if(idx < checkApprovalList.length - 1){
							var txt = "<span style='font-weight:bold'>" + "Process "+(Number(idx) + 2)+" of "+ (checkApprovalList.length)  +" ...</span>";
							$("p","#popup_message").last().html(txt);
						}
					}
					else if(mode == "complete"){
						Common.AlertClose();
						var resultinfo = arguments[1];
						var status = resultinfo.status;
						var msg = resultinfo.msg;
						var totalCnt = resultinfo.totalCnt;
						var successCnt = resultinfo.successCnt;
						var failCnt = resultinfo.failCnt;
						
						var informMessage = msg;
						informMessage += "<br>";
						informMessage += "Success : " + successCnt + ", Fail : " + failCnt + " ( Total : "+totalCnt+" )";
						
						if(status == "SUCCESS" && failCnt == 0){
							Common.Inform(informMessage, "Confirmation Dialog", function (confirmResult) {
//								parent.location.reload();
								window.parent.postMessage(
										{ 	functionName : "callbackApprovalList"
											, params : { "status" : "complete"}
										}, '*'
								);
								Common.Close();
							});
						}else {
							Common.Warning(informMessage);
						}
						$.ajaxSettings.complete.call(this);
					}
				};
				
				$f.submit();
				
			} else {
				Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
			}
		}
	}

	var attachFileInfoObj;
	function openFileList(pObj,FormInstID){
		if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
			$(pObj).parent().find('.file_box').remove();
			return false;
		}
		$('.file_box').remove();
		var Params = {
				FormInstID : FormInstID
		};
		$.ajax({
			url:"/approval/getCommFileListData.do",
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				if(data.list.length > 0){
					var vHtml = "<ul class='file_box'>";
						vHtml += "<li class='boxPoint'></li>";
					for(var i=0; i<data.list.length;i++){
						attachFileInfoObj = data.list;
						vHtml += "<li><a onclick='attachFileDownLoadCall("+i+")'>"+data.list[i].FileName+"</a></li>";
					}
					vHtml += "</ul>";
					$(pObj).parent().append(vHtml);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/getCommFileListData.do", response, status, error);
			}
		});
	}
	
	function attachFileDownLoadCall(index){
    	var fileInfoObj = attachFileInfoObj[index];
    	Common.fileDownLoad($$(fileInfoObj).attr("FileID"), $$(fileInfoObj).attr("FileName"), $$(fileInfoObj).attr("FileToken"));
    }

</script>