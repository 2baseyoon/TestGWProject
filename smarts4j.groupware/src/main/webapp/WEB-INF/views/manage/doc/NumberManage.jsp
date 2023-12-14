<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<script type="text/javascript" src="/groupware/resources/script/admin/boardAdmin.js<%=resourceVersion%>"></script>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_DocNo'/></h2> <!-- 문서번호관리 -->
</div>
<div class="cRContBottom mScrollVH">
<form id="form1">

	<div id="topitembar03" class="inPerView type02 sa04 active" style="padding-left: 25px !important;">
		<!-- 문서번호 예시. -->
		<span><spring:message code='Cache.lbl_docNumberExample'/> : </span> <!-- 문서번호 예시 -->
		<text id="exAutoDocNumber2"></text><br/><br/>
		<span><spring:message code='Cache.lbl_docNumberConfig'/> : </span> <!-- 문서번호 구성 -->
		<text id="exAutoDocNumber1"></text>
	</div>
			
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 추가 버튼 -->
					<a onclick="javascript:createDocNumberPopup();" class="btnTypeDefault"><spring:message code="Cache.btn_Add"/></a>
					<!-- 삭제 버튼 -->
					<a onclick="javascript:deleteDocNumber();" class="btnTypeDefault"><spring:message code="Cache.lbl_delete"/></a>
				</div>
			</div>
			<div class="buttonStyleBoxRight">
				<button id="btnRefresh" class="btnRefresh" type="button" href="#"></button>
			</div>
		</div>	
		<div id="lowerMessageGrid" class="tblList tblCont"></div>
	</div>
	<input type="hidden" id="hiddenMenuID" value=""/>
	<input type="hidden" id="hiddenFolderID" value=""/>
	<input type="hidden" id="hiddenMessageID" value=""/>
	<input type="hidden" id="hiddenComment" value="" />
	
	<!-- 문서번호 예시 관련 임시 저장값 -->
	<input type="hidden" id="compNmLang" />
	<input type="hidden" id="compNm" />
	<input type="hidden" id="compSnmLang" />
	<input type="hidden" id="compSnm" />
	<input type="hidden" id="deptNmLang" />
	<input type="hidden" id="deptNm" />
	<input type="hidden" id="deptSnmLang" />
	<input type="hidden" id="deptSnm" />
	<input type="hidden" id="cateNmLang" />
	<input type="hidden" id="cateNm" />
	
</form>
</div>
<script type="text/javascript">
	
	<%-- // #/manage/doc/NumberManage.jsp, 간편관리자 문서관리 > 문서번호관리. --%>
 
(function(){
	var bizSection = "Doc";
	var boardType = "DocNumberManage";
	
	var lowerMsgGrid = new coviGrid();		//게시글 Grid
	
	var initFunc = function() {
		setMessageGridConfig();
		selectDocNumberGridList();
	}
	
	var msgHeaderData =	[
    	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'}
     	, {key:'FieldType',  label:'<spring:message code="Cache.lbl_FieldType"/>', width:'7', align:'center' 		// 필드유형
     		, formatter : function() {
 			return boardAdmin.formatFieldtypeLang(this); 
 		}}
     	, {key:'FieldLength',  label:'<spring:message code="Cache.lbl_FieldSize"/>', width:'7', align:'center'} 	// 필드크기
     	, {key:'LanguageCode',  label:'<spring:message code="Cache.lbl_DicModify"/>', width:'3', align:'center'} 	// 언어설정
     	, {key:'Separator',  label:'<spring:message code="Cache.CPMail_Separator"/>', width:'3', align:'center'} 	// 구분
     	, {key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>', width:'5', align:'center'					//사용여부
     		, formatter: function() {
     			return formatSwitch(this); 
     	}} 
      	, {key:'CreateDate', label:'<spring:message code="Cache.lbl_registeDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'7', align:'center'
      		, formatter : function() { 		// 생성일
				return CFN_TransLocalTime(this.item.CreateDate);
		}}
		, {key:'Action', label: '<spring:message code="Cache.lbl_PriorityOrder"/>', width:'7', align: 'center'
			, formatter : function() { 		// 우선순위
				var html = '<div class="btnActionWrap">';
				html += '<a href="javascript:;" class="btnTypeDefault btnMoveUp"   onclick="fieldSeqChange(' + this.item.ManagerID + ','+this.item.Seq+',\''+this.item.FieldType+'\', \'UP\');"><spring:message code="Cache.lbl_apv_up"/></a>';
				html += '<a href="javascript:;" class="btnTypeDefault btnMoveDown"   onclick="fieldSeqChange(' + this.item.ManagerID + ','+this.item.Seq+',\''+this.item.FieldType+'\', \'DOWN\');"><spring:message code="Cache.lbl_apv_down"/></a>';
				html += '</div>';
			return html;	
		}}
    ];
	
	// 새로고침
	$("#btnRefresh").on('click', function(){
		selectDocNumberGridList();
	});
	
	// 추가 및 수정에 대한 callback 관련 postMessage.
	window.addEventListener("message", function(e) {
		if (e.data.functionName === "docNumMngPop") {
			if (e.data.param1 === "callback_setDocNumber") {
				$("#btnRefresh").trigger("click")
			}
		}
	});
	
	// 추가 버튼 클릭 이벤트.
	this.createDocNumberPopup = function () {
		Common.open("","createDocNumber","<spring:message code='Cache.lbl_DocNo'/> <spring:message code='Cache.lbl_Regist'/>","/groupware/board/manage/goDocNumberManagePopup.do?mode=create&domainID="+confMenu.domainId,"550px","250px","iframe",true,null,null,true);
	}

	// 삭제 버튼 클릭 이벤트.
	this.deleteDocNumber = function () {
		var managerIDs = '';
		$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
			managerIDs += obj.ManagerID + ';'
		});
		
		if(managerIDs == ''){
			 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
	       return;
		}
		Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
			if (result) {
			    $.ajax({
			    	type:"POST",
			    	url:"/groupware/board/manage/deleteDocNumber.do",
			    	data:{
			    		"managerIDs": managerIDs
			    	},
			    	success:function(data){
			    		if(data.status=='SUCCESS'){
			    			Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
			    			selectDocNumberGridList();
			    		}else{
			    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
			    		}
			    	},
			    	error:function(response, status, error){
			    	     CFN_ErrorAjax("/groupware/board/manage/deleteDocNumber.do", response, status, error);
			    	}
			    });
			}
		});
	}

	//IsUse, IsDisplay 변경
	this.updateDocNumberFlag = function (pManagerID, pFlagValue, pTarget) {
		if (pManagerID != undefined && pManagerID != "") {
			$.ajax({
	       		type : "POST"
	       		, url : "/groupware/board/manage/updateDocNumberFlag.do"
	       		, data : {
	       			"managerID": pManagerID,
	       			"flagValue": pFlagValue
	       		}
	       		, success : function(data) {
	       			if (data.status === 'SUCCESS') {
	       				Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
	       			} else {
	       				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); 	//오류가 발생헸습니다.
	       				
	       				if(pFlagValue == 'Y'){
							$(pTarget).removeClass("on");
							$("#switch_"+pManagerID).val($("#switch_"+pManagerID).attr("off_value"));
						} else {
							$(pTarget).addClass("on");
							$("#switch_"+pManagerID).val($("#switch_"+pManagerID).attr("on_value"));
						}
	       			}
	       		}
	       		, error : function(response, status, error) {
			    	CFN_ErrorAjax("/groupware/board/manage/updateDocNumberFlag.do", response, status, error);
				}
	       });
		}
	}

	// 우선순위 변경 이벤트.
	this.fieldSeqChange = function(pManagerID, pSeq, pFieldType, pStatus) {		// 우선순위 -1
		$.ajax({
			type : "POST"
			, data : { 
				"ManagerID" : pManagerID
				, "Seq" : pSeq
				, "DomainID" : confMenu.domainId
				, "FieldType" : pFieldType
				, "Status" : pStatus
			}
			, url : "/groupware/board/manage/updateFieldSeq.do"
			, success : function(data) {
				if (data.status === 'SUCCESS') {
					Common.Inform("<spring:message code='Cache.msg_37'/>","Information", function() { //저장되었습니다.
						selectDocNumberGridList();	// 변경 후, reload.
					});
				} else {
					Common.Warning(data.message,"Warning", null);
				}
			}
			, error : function(response, status, error) {
				CFN_ErrorAjax("/groupware/board/manage/updateFieldSeq.do", response, status, error);
			}
		});
	}
	
	// 필드명 클릭을 통한 상세 팝업.
	this.editDocNumberPopup = function(pDomainID, pManagerID) {
		parent.Common.open("","editDocNumber","<spring:message code='Cache.lbl_DocNo'/> <spring:message code='Cache.lbl_Edit'/>","/groupware/board/manage/goDocNumberManagePopup.do?mode=update&managerID="+pManagerID+"&domainID="+pDomainID,"550px","250px","iframe",true,null,null,true);
	}

	//게시글 그리드 세팅
	var setMessageGridConfig = function() {
		lowerMsgGrid.setGridHeader(msgHeaderData);
		
		var messageConfigObj = {
			targetID : "lowerMessageGrid",
			height:"auto",
			page : {
				pageNo : 1,
				pageSize : 10
			},
			paging : true,
			colHead:{},
			body:{
				onchangeScroll : function() {
	                for(var i=this.startIndex;i<this.endIndex+1;i++){
	                    $("#AXInputSwitch"+i).bindSwitch({off:"N", on:"Y"});
	            }}
			}
		};
		
		lowerMsgGrid.setGridConfig(messageConfigObj);
		lowerMsgGrid.config.fitToWidthRightMargin = 0;
	 }
	
	// 문서번호 Grid 조회 
	var selectDocNumberGridList = function() {
		
		lowerMsgGrid.bindGrid({
			ajaxUrl:"/groupware/message/manage/selectDocNumberGridList.do",
			ajaxPars: {
				"domainID":confMenu.domainId,
				"boardType": boardType,
				"sortBy": "Seq ASC"
			},
			onLoad : function() {
				$('#exAutoDocNumber1').text("");
				$('#exAutoDocNumber2').text("");
				getFieldInfos(); 	// 문서번호 필드에 대한 다국어를 가져옴.
			}
		});
	}
	
	var getFieldInfos = function() {
		var compNmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "CompanyName" });
		if (compNmLang.length > 0) { $('#compNmLang').val(compNmLang[0].LanguageCode); }
		var compSnmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "CompanyShortName" });
		if (compSnmLang.length > 0) { $('#compSnmLang').val(compSnmLang[0].LanguageCode); }
		var deptNmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "DeptName" });
		if (deptNmLang.length > 0) { $('#deptNmLang').val(deptNmLang[0].LanguageCode); }
		var deptSnmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "DeptShortName" });
		if (deptSnmLang.length > 0) { $('#deptSnmLang').val(deptSnmLang[0].LanguageCode); }
		var cateNmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "CateName" });
		if (cateNmLang.length > 0) { $('#cateNmLang').val(cateNmLang[0].LanguageCode); }
		
		// 파라미터 확인.
		if ( sessionObj.USERID != "" && sessionObj.USERID != undefined
			&& sessionObj.DN_ID != "" && sessionObj.DN_ID != undefined
			&& sessionObj.DN_Code != "" && sessionObj.DN_Code != undefined
			&& sessionObj.DEPTID != "" && sessionObj.DEPTID != undefined ) {
			
			$.ajax({
				type :"POST"
				, data : {
					"USERID" : sessionObj.USERID			, "DN_ID" : sessionObj.DN_ID
					, "DN_Code" : sessionObj.DN_Code		, "DEPTID" : sessionObj.DEPTID
					, "compLang" : $('#compNmLang').val()	, "compSnmLang" : $('#compSnmLang').val()
					, "deptNmLang" : $('#deptNmLang').val()	, "deptSnmLang" : $('#deptSnmLang').val()
					, "cateNmLang" : $('#cateNmLang').val()
				},
				url : "/groupware/board/manage/selectFieldLangInfos.do",
				success : function(data) {
					if (data.list != undefined || data.list != "" ) {
						if (data.list[0].compNm != "" && data.list[0].compNm != undefined) {	// 회사명.
							$('#compNm').val(data.list[0].compNm);
						}
						if (data.list[0].compSnm != "" && data.list[0].compSnm != undefined) {	// 회사명약어.
							$('#compSnm').val(data.list[0].compSnm);
						}
						if (data.list[0].deptNm != "" && data.list[0].deptNm != undefined) { 	// 부서명.
							$('#deptNm').val(data.list[0].deptNm);	
						}
						if (data.list[0].deptSnm != "" && data.list[0].deptSnm != undefined) { 	// 부서명약어.
							$('#deptSnm').val(data.list[0].deptSnm);	
						}
						if (data.list[0].folderNm != "" && data.list[0].folderNm != undefined) { // 분류명(문서함마다 달라지므로 ROOT값으로).
							$('#cateNm').val(""+data.list[0].folderNm);
						}					
					}
					setExmplDocNum(lowerMsgGrid.list);	// 언어별 정보 조회 후, 예시를 보여줌.
				},
				error : function(response, status, error){
					CFN_ErrorAjax("selectFieldLangInfos.do", response, status, error);
				}
			});
		}
	}
	
	// 문서번호 예시를 보여줌.
	var setExmplDocNum = function (pList) {
		if ( pList.length === 0 ) {		// 문서번호 발번 내역이 없다면 return.
			return;
		}
		var useFields = pList.filter(function (obj, idx, pList) {	// 사용 중인 것들만 filtering.
			return obj.IsUse === "Y"
		});
		
		useFields.sort(function(a, b) {		// sorting. 1차 Seq, 2차 ManagerID.
			if (a.Seq > b.Seq) { return 1; }
			if (a.Seq < b.Seq) { return -1; }
			if ( (a.Seq === b.Seq) && (a.ManagerID > b.ManagerID) ) { return 1; }
			if ( (a.Seq === b.Seq) && (a.ManagerID < b.ManagerID) ) { return -1; }
			return 0;
		});
		
		alertFirstSerialNumber(useFields);	// 일련번호가 최상위일 때 오류 내용 관리자에게 알림.
		
		var exDocNum = "";
		
		// FieldName(FieldLength) 형식으로 문서번호 예시 보여주기.
		for (var item of useFields) {
			exDocNum = exDocNum + Common.getBaseCodeDic('NumberFieldType', item.FieldType) + "(" + item.FieldLength + ")" + item.Separator
		}
		$('#exAutoDocNumber1').text( exDocNum );	// 문서 번호 예시 값.
		
		exDocNum = "";
		for (var item of useFields) {
			exDocNum = exDocNum + fieldCombine(item);
		}
		
		$('#exAutoDocNumber2').text( exDocNum );	// 문서 번호 예시 값.
	}

	// 문서번호를 지정할 때, 일련번호를 최상위 혹은 일련번호만 남겨두면 안되어 관리자에게 알림창으로 알려줌.
	var alertFirstSerialNumber = function (pUseFields) {
		if (pUseFields[0].FieldType === "SerialNumber") {
			Common.Inform("<spring:message code='Cache.msg_NotUsedFirstSN'/>","Information",function(){ // 일련번호를 첫번째로 사용하실 수 없습니다.
				Common.Close();
	    	});
			return false;
		} else {
			return true;
		}
	}
	
	var fieldCombine = function (field) {
		if (typeof(field) === "undefined") {
			return;
		}
		var retVal = "";
		var dateToday = new Date();
		
		if (field.FieldType === 'CompanyName') {	// 회사명
			retVal = $('#compNm').val().substr(0, field.FieldLength);
			retVal = retVal + field.Separator;
		} else if (field.FieldType === "CompanyShortName") {	// 회사명 약어
			if ( $('#compSnm').val() != "" ) {
				retVal = $('#compSnm').val().substr(0, field.FieldLength);
			} else { 	// 회사명 약어가 조회할 수 없다면, '{회사명 약어(FieldLength)}'로 보여주기
				retVal = "{<spring:message code='Cache.lbl_CorpAliasName'/>("+ field.FieldLength +")}";		// ex : {회사명 약어(4)}
			}
			retVal = retVal + field.Separator;
		} else if ( field.FieldType === "DeptName" ) {		// 부서명
			if ( $('#deptNm').val() != undefined || $('#deptNm').val() != "" ) {
				retVal = $('#deptNm').val().substr(0, field.FieldLength);
			} else {	// 부서명 조회를 못했을 경우, "{부서명(4)}" 형식으로 표기.
				retVal = "{<spring:message code='Cache.lbl_DeptName'/>("+ field.FieldLength +")}";		// ex : {부서명(4)}
			}
			retVal = retVal + field.Separator;
		} else if (field.FieldType === "DeptShortName") {
			if ( $('#deptSnm').val() != "" ) {
				retVal = $('#deptSnm').val().substr(0, field.FieldLength);
			} else {	// 부서명 약어가 빈값이면, '{부서명약어(FieldLength)}'
				retVal = "{<spring:message code='lbl_DeptShortName' />(" + field.FieldLength + ")}";
			}
			retVal = retVal + field.Separator;
		} else if ( field.FieldType === "CateName") {	// 분류명(선택한 문서함). 예시로 좌측 트리메뉴의 ROOT 폴더 이름을 예시로 가져온다.
			retVal = $('#cateNm').val().substr(0, field.FieldLength);
			retVal = retVal + field.Separator;
		} else if ( field.FieldType === "Year") { 	// 년도.
			retVal = ""+dateToday.getFullYear();
			retVal = retVal.substr(retVal.length - field.FieldLength, field.FieldLength);
			retVal = retVal + field.Separator;
		} else if (field.FieldType === "Month") {	// 월.
			retVal = dateToday.getMonth() + 1;
			retVal = ""+retVal;
			if (retVal.length < 2) { retVal = "0"+ retVal; }
			retVal = retVal.substr(retVal.length - field.FieldLength, field.FieldLength);
			retVal = retVal + field.Separator;
		} else if (field.FieldType === "Day") {
			retVal = dateToday.getDate();
			retVal = ""+retVal;
			if (retVal.length < 2) { retVal = "0"+ retVal; }
			retVal = retVal.substr(retVal.length - field.FieldLength, field.FieldLength);
			retVal = retVal + field.Separator;
		} else if (field.FieldType === "SerialNumber") {	// 일련번호는 예시이므로 1로 보여준다.
			retVal = "1";
			retVal = retVal + field.Separator;
		}

		return retVal;
	}
	
	function formatSwitch(pObj){
		var param = pObj.item;
		param.on = 'Y'; param.off = 'N';
		param.defVal = param[pObj.key];
		param.retVal = param.ManagerID;
		return coviCmn.getCoviSwitch('switch_'+param.ManagerID, param, 'updateDocNumberFlag');
	}
	
	initFunc();

})();

</script>
