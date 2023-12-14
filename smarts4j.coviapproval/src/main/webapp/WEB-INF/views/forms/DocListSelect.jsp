<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<script>

	var ListGrid = new coviGrid();
	var m_oInfoSrc = top.opener;;
	var gridCount = 0;
	var sessionObj = Common.getSession(); //전체호출
    var userID = sessionObj["USERID"];
    var DEPTID = sessionObj["DEPTID"];
    var lang = sessionObj["lang"];
    var approvalListType = "user";					// 공통 사용 변수 - 결재함 종류 표현 - 개인결재함
    var selectParamss;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var g_mode = "COMPLETE";
	var gloct = "";
	var subkind = "";
    var chkVal = '';
    var bstored = "false";
	$(document).ready(function () {
// 		$("#userId").val(USERID);
// 		$("#deptId").val(DEPTID);

		setselectType();
		$("#selectType").val('Complete').attr('selected',true);
		setSelect(ListGrid, g_mode, "");
		setGrid();
		}
	
	);


	function setGrid(){
		setGridHeader();
		setGridConfig();
		setListData();
	}

	function setGridHeader(){
		var headerData = '';
		chkVal = $("#selectType").val();


		if(chkVal == "TCInfo" || chkVal == "DeptTCInfo" || chkVal == "StoreTCInfo" || chkVal == "StoreDeptTCInfo"){
			
			headerData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
							{key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100', align:'left',
							formatter:function (){
								if(chkVal == "TCInfo" || chkVal == "StoreTCInfo"){ //참조/회람함
					   					return "<div><a href=\"#none\" onclick='onClickPop(\""+this.item.ProcessID+"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a></div>";
					   			}else if(chkVal == "DeptTCInfo" || chkVal == "StoreDeptTCInfo"){ //참조회람함
				   					return "<div><a href=\"#none\" onclick='onClickPopButton(\""+this.item.ProcessID+"\",\"\",\"\",\"\",\"\",\"\",\"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a></div>";
				   				}}},
							{key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
				   				formatter:function(){
				   					return CFN_GetDicInfo(this.item.InitiatorUnitName,lang)
								}
							},
							{key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
								formatter:function(){
				   					return CFN_GetDicInfo(this.item.InitiatorName,lang)
								}
							},
							{key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',
								formatter:function(){
				   					return CFN_GetDicInfo(this.item.FormName,lang)
								}
							},
							{key: 'RegDate' , label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center', sort:'desc'}];
 		}
		else{
			headerData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
							{key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100', align:'left',
 								formatter:function (){
								if(chkVal == "Complete" || chkVal == "StoreComplete"){ //완료함 || 반려함
					   					return "<div><a href=\"#none\" onclick='onClickPop(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\"\",\"\",\"\",\"\",\"\",\"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a></div>";
					   			}else if(chkVal == "DeptComplete" || chkVal == 486 || chkVal == "ReceiveComplete" || chkVal == "StoreDeptComplete"){ //완료함 || 발신함 || 수신처리함
					   				return "<div><a href=\"#none\" class=\"taTit\" onclick='onClickPopButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a></div>";
								}else if(chkVal == 487){ //수신함
				   					return "<div><a href=\"#none\" onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a></div>";
				   				}else if(chkVal.indexOf("JobFuc") > -1){
				   					return "<div><a href=\"#none\" onclick='onClickPopButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkItemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\"\",\""+this.item.FormSubKind+"\",\"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a></div>";
				   				}}},
							{key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
						   			formatter:function(){
					   					return CFN_GetDicInfo(this.item.InitiatorUnitName,lang)
									}
							},
							{key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
								formatter:function(){
				   					return CFN_GetDicInfo(this.item.InitiatorName,lang)
								}
							},
							{key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',
								formatter:function(){
				   					return CFN_GetDicInfo(this.item.FormName,lang)
								}
							},
							{key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center', sort:'desc',
								formatter:function(){
									if(chkVal.indexOf("JobFuc") > -1) return this.item.Finished;
									else return this.item.EndDate;
								}
							}];
		}

		ListGrid.setGridHeader(headerData);

	}

	function setGridConfig(){
		var configObj = {
				targetID : "ListGrid",
				height:"auto",
				listCountMSG:"<b>{listCount}</b> 개",
	            page: {
	            	display: false,
					paging: false
	            },
	            body:{
	            	onclick:function(){
	            		if(this.c == 1)
	            			openFormDraft(this.list[this.index].FormID);
	            	}
	            },

	            page : {
					pageNo:1,
					pageSize:10
				},
				paging : true
		}

		ListGrid.setGridConfig(configObj);
	}

	function setListData(){
		chkVal = $("#selectType").val();
		
		if(chkVal.indexOf("Store") == 0) // 이관문서
			bstored = "true";
		else
			bstored = "false";

		var requestType = "DocList";
		
		var url;
		if(chkVal == "Complete" || chkVal == "TCInfo" || chkVal == "StoreComplete" || chkVal == "StoreTCInfo"){
			approvalListType = "user";
			url = 'user/getApprovalListData.do?mode='+chkVal.replace("Store", "") + "&requestType=" + requestType;
		}
		else if(chkVal == "DeptComplete" || chkVal == "ReceiveComplete" || chkVal == "DeptTCInfo"
				|| chkVal == "StoreDeptComplete" || chkVal == "StoreDeptTCInfo"){
			approvalListType = "dept";
			url = 'user/getDeptApprovalListData.do?mode='+chkVal.replace("Store", "") + "&requestType=" + requestType;
		}
		else if(chkVal.indexOf("JobFuc") > -1){
			approvalListType = "job";
			url = 'user/getJobFunctionCompleteListData.do?jobFunctionCode='+chkVal.replace("JobFuc", "") + "&requestType="+requestType;
		}
		
		setSelectParams(ListGrid);// 공통 함수
		ListGrid.bindGrid({
			ajaxUrl: url,
			ajaxPars: selectParams,
			onLoad: function(){
				setGridCount();
				
				setTimeout(function() {
					//기존 체크 항목 유지를 위한 delay
					var list = ListGrid.list;
					if(chkObj.length > 0){
						for(var i=0; i<list.length; i++){
							for(var j=0; j<chkObj.length; j++){
								if(chkObj[j].PerformerID == list[i].PerformerID){
									$("input[name='chk']")[i].checked = true;
								}
							}
						}
					}
				}, 100);
			}
		});

	}

	var chkObj = []; //선택된 리스트
	function getChecked(chkIdx){
       var list = ListGrid.list;
       
       if(!chkObj.includes(list[chkIdx])) {
    	   chkObj.push(list[chkIdx]);
       }else {
    	   chkObj.pop(list[chkIdx]);
       }
       
	}
	
	function getCheckedAll(){ //전체 선택, 해제
       var list = ListGrid.list;
       var checkAll = $("input[name='checkAll']")[0];
       
       if(checkAll.checked){
    	   chkObj.clear();
    	   for(var i=0; i<list.length; i++){
    		   chkObj.push(list[i]);
    	   }
       }else{
    	   chkObj.clear();
       }
	}
	
	function OK(){
		var chkList = [];
		
		var chkObj = ListGrid.getCheckedList(0);
		for(var i = 0; i <chkObj.length; i++){
			var param = {};
			param.processID = (chkObj[i].ProcessArchiveID == undefined ? chkObj[i].ProcessID : chkObj[i].ProcessArchiveID);
			param.formPrefix = chkObj[i].FormPrefix;
			param.subject = chkObj[i].FormSubject;
			param.forminstanceID = chkObj[i].FormInstID;
			param.bstored = bstored;
			param.businessData1 = chkObj[i].BusinessData1;
			param.businessData2 = chkObj[i].BusinessData2;
			
			param.initiatorName = chkObj[i].InitiatorName;
			param.docNo = chkObj[i].DocNo;
			param.date = chkObj[i].RegDate || chkObj[i].EndDate || chkObj[i].Finished;
			
			//chkList.push(param);
			if(!chkList.some(function(el){ if(el.processID === param.processID){ return true; }})){
				chkList.push(param);
			}
		}

		if(typeof opener.InputDocLinks === "function"){
			opener.InputDocLinks(chkList.map(function(docItem){ return docItem.processID + "@@@" + docItem.formPrefix + "@@@" + docItem.subject + "@@@" + docItem.forminstanceID + "@@@"+ docItem.bstored + "@@@" + docItem.businessData1 + "@@@" + docItem.businessData2 + "@@@" + docItem.initiatorName + "@@@" + docItem.docNo  + "@@@" + docItem.date; }).join("^^^"));
		}
		else opener.docLinks.addItem(chkList);
		window.close();
	}

	function onClickPop(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,BusinessData1,BusinessData2){
		var archived = "true";
		switch (chkVal){
			case "Complete" : case "StoreComplete": gloct = "COMPLETE"; subkind=SubKind; userID=UserCode; break;
			case "TCInfo" : case "StoreTCInfo": gloct = "TCINFO"; subkind=SubKind; archived="false"; break;		// 참조/회람함
			case "DeptComplete" : case "StoreDeptComplete": gloct = "DEPART"; subkind="A"; break; // 완료함
			case "ReceiveComplete" : gloct = "DEPART"; subkind="REQCMP"; break;	// 수신처리함
			case "DeptTCInfo" : case "DeptTCInfo": gloct = "DEPART"; subkind="T006"; archived="false"; break;		// 참조/회람함
		}
			
		CFN_OpenWindow("approval_Form.do?mode=COMPLETE&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&bstored="+bstored
				+"&ExpAppID="+(typeof BusinessData2!="undefined"?BusinessData2:"")+"&taskID="+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"", "", 790, (window.screen.height - 100), "resize");
	}
	function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,Mode,SubKind,UserCode,BusinessData1,BusinessData2){
		var archived = "true";
		switch (chkVal){
			case "DeptComplete" : case "StoreDeptComplete": mode = "COMPLETE"; gloct = "DEPART"; subkind="A"; userID = UserCode; break;
			case "ReceiveComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="REQCMP"; userID = UserCode; break;
			case "DeptTCInfo" : case "DeptTCInfo": mode = "COMPLETE"; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = ""; break;
			default : if (chkVal.indexOf("JobFuc") > -1) mode="COMPLETE"; gloct="JOBFUNCTION"; subkind=SubKind; userID=chkVal.replace("JobFuc", ""); archived="true"; break;
		}
		
		CFN_OpenWindow("approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&admintype=&archived="+archived+"&bstored="+bstored + "&usisdocmanager=true&listpreview=N&subkind="+subkind+""
				+"&ExpAppID="+(typeof BusinessData2!="undefined"?BusinessData2:"")+"&taskID=", "", 790, (window.screen.height - 100), "resize");
	}

	function setGridCount(){
		gridCount = ListGrid.page.listCount;
		$("#approvalCnt").html(gridCount);
	}

	function viewDocListType(){
		setGrid();
	}

	function onClickSearchButton() {
		setListData();
	}

	function btnClose_Click(){
		Common.Close();
	}
	
	function enterKey(e){
		if(e.keyCode != 13) return true;
		
		onClickSearchButton();
		
		return false;
	}
	
	function setselectType(){
		var selectTypeHtml = '';
		
		selectTypeHtml += "<option value='Complete'>개인완료함</option>";
		selectTypeHtml += "<option value='TCInfo'>개인문서함 - 참조/회람함</option>";
		selectTypeHtml += "<option value='DeptComplete'>부서문서함</option>";
		selectTypeHtml += "<option value='ReceiveComplete'>부서수신처리함</option>";
		selectTypeHtml += "<option value='DeptTCInfo'>부서문서함 - 참조/회람함</option>";
		
		if(getJobFuncCount() > 0) {
			var oaFuncList = getJobFuncList();
			oaFuncList.map(function(oJob) { selectTypeHtml += "<option value='JobFuc"+oJob.code+"'>담당업무함 - "+CFN_GetDicInfo(oJob.name)+"</option>"; });
		}
		
		if(Common.getBaseConfig("DocLinkBStored")=="Y"){
			selectTypeHtml += "<option value='StoreComplete'>이관문서 - 개인문서함</option>";
			selectTypeHtml += "<option value='StoreTCInfo'>이관문서 - 개인 참조/회람함</option>";
			selectTypeHtml += "<option value='StoreDeptComplete'>이관문서 - 부서문서함</option>";
			selectTypeHtml += "<option value='StoreDeptTCInfo'>이관문서 - 부서 참조/회람함</option>";	
		}
		
		$("#selectType").html(selectTypeHtml);
	}
	
	function getJobFuncCount() {
		var jobfunctionCnt = 0;
		
		$.ajax({
			type:"POST",
			url:"/approval/user/getJobFunctionCount.do",
			data:{
				JobFunctionType:"APPROVAL"
			},
			async: false,
			success:function (data) {
				if(data.result=="ok") jobfunctionCnt = data.cnt;
			},
			error:function(response, status, error){
				CFN_ErrorAjax("user/getJobFunctionCount.do", response, status, error);
			}
		});
		
		return jobfunctionCnt;
	}
	
	function getJobFuncList() {
		var oaFuncList = [];
		
		$.ajax({
			url:"/approval/user/getJobFunctionListData.do",
			type:"post",
			data:{
				JobFunctionType:"APPROVAL"
			},			
			async:false,
			success:function (data) {
				$(data.list).each(function(job){
					var oJob = new Object();
					oJob.code = this.JobFunctionCode;
					oJob.name = this.JobFunctionName;
					oaFuncList.push(oJob);
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getJobFunctionListData.do", response, status, error);
			}
		});
		
		return oaFuncList;
	}
	

</script>
</head>
<body>
<form>
<div class="layer_divpop ui-draggable" id="testpopup_p" style="min-width: 840px; width:100%; z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
  <div class="divpop_contents">
    <div class="pop_header" id="testpopup_ph">
      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico"><spring:message code="Cache.lbl_apv_doclink"/></span></h4>
      <!--<a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a><a class="divpop_window" id="testpopup_LayertoWindow" style="cursor: pointer;" onclick="Common.LayerToWindow('layerpopuptest.do?as=ads', 'testpopup', '331px', '270px', 'both')"></a><a class="divpop_full" style="cursor: pointer;" onclick="Common.ScreenFull('testpopup', $(this))"></a><a class="divpop_mini" style="cursor: pointer;" onclick="Common.ScreenMini('testpopup', $(this))"></a>-->
    </div>
    <!-- 팝업 Contents 시작 -->
    <div class="popBox">
		<div class="searchBox">
			<input type="text" id="DeputyFromDate" class="AXInput adDate" />~
			<input type="text" kind="twindate" date_startTargetID="DeputyFromDate" id="DeputyToDate" class="AXInput adDate" />&nbsp;
		<!-- 	<select name="seSearchID" id="seSearchID">
				<option value="FormSubject">제목</option>
				<option value="FormName">양식명</option>
				<option value="InitiatorName">기안자</option>
				<option value="InitiatorUnitName">기안부서</option>
			</select> -->
			<div class="selBox" style="width: 100px;" id="selectSearchType"></div>
			<input type="text" class="W200" placeholder="검색어를 입력하세요" id="searchInput" onkeypress="return enterKey(event);"/>
			<a href="#" class="searchImgGry" onclick="onClickSearchButton();"><spring:message code="Cache.btn_search"/></a>
			<div class="fRight">
				<select name="selectType" id="selectType" onchange="viewDocListType();"></select>
			</div>
		</div>
		<div class="coviGrid">
			<div id="ListGrid"></div>
		</div>
		<div>
      	<div class="popBtn">
      	<a class="ooBtn" href="#ax" onclick="OK();" return false;><spring:message code='Cache.btn_apv_doclink'/></a>
      	<a class="owBtn" href="#ax" onclick="btnClose_Click();" return false;><spring:message code='Cache.btn_apv_close'/></a>
		</div>
		</div>
		</div>
		</div>
		</div>
		</form>
</body>
</html>