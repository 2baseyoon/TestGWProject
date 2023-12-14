<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"  %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
.underline{text-decoration:underline}
input[name='checkAll']{display:none}
label.help_label{font-size: 14px;}
</style>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code="Cache.lbl_DeptManage"/></h2>	<!-- 부서 관리 -->
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			<button id="simpleSearchBtn" type="button" onclick="searchListKeyword(this);"class="btnSearchType01"><spring:message code='Cache.btn_search' /></button>
		</span>
		<a id="detailSchBtn" onclick="DetailDisplay(this);" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>	
<div class="cRContBottom mScrollVH"> 
	<div id="DetailSearch" class="inPerView type02">
		<div>
			<div class="selectCalView">
				<select id="selDetailSearchItem" class="selectType02">
					<option value="DisplayName"><spring:message code="Cache.lbl_DeptName"/>	</option>
					<option value="GroupCode"><spring:message code="Cache.lbl_DeptCode"/>	</option>
				</select>
				<input type="text" id="txtDetailSearchText" style="width: 215px;" onkeypress="if (event.keyCode==13){searchListKeyword(this); return false;}" >
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchListKeyword(this);" ><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<!-- 상단 버튼 시작 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" 	id="btnAdd"		onclick="addOrgGroup();"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->
				<a class="btnTypeDefault btnSaRemove" 	id="btnDel"		onclick="deleteOrgGroup();"><spring:message code="Cache.btn_NotUse"/></a><!-- 사용안함 -->
				<a class="btnTypeDefault btnExcel" 						onclick="excelDownload();"><spring:message code="Cache.btn_SaveToExcel"/></a><!-- 엑셀저장 -->
				<!-- <input type="button" class="btnTypeDefault btnExcel" 					value = "<spring:message code="Cache.btn_SaveToExcelWithSub"/>"	onclick="excelDownload_hasChildGroup('group');"/>--><!-- 하위부서 포함 엑셀저장 -->
				<!-- <input type="button" class="btnTypeDefault" 							value = "<spring:message code="Cache.lbl_Property"/>"			onclick="editOrgGroup();"/> --><!-- 속성 -->
				<a class="btnTypeDefault" 								onclick="syncSelectDomain();"><spring:message code="Cache.btn_CacheApply"/></a><!-- 캐시적용 -->
				<label class='help_label'>*<spring:message code="Cache.msg_validCheckHasObject"/></label><!--소속된 객체가 있을 경우 체크박스 선택 불가능합니다.-->
			
			</div>
			<div class="buttonStyleBoxRight">
				<div class="searchBox02"><button id="folderRefresh" class="btnRefresh" type="button" onclick="searchList()"></button>
				</div>
			</div>
		</div>
		<!-- 상단 버튼 끝 -->
		<div class="tblList tblCont">
			<div id="orggrouptree" class="treeBody"></div>
		</div>
	</div>
</div>
<script type="text/javascript">
	var _SearchKeyword = '';
	var _isMailDisplay = true;
	var _myGridTree;
	var _gr_code='';
	var _group_type = 'Dept';
	var _domainId =confMenu.domainId;
	var _domainCode = confMenu.domainCode;
	var _groupHeaderData;
	
	$(document).ready(function () {
		_myGridTree = new coviTree();
		//기초설정에 따른 메일 표기 여부
		if(coviCmn.configMap["IsSyncMail"] == null ||  coviCmn.configMap["IsSyncMail"] == 'N'){
			_isMailDisplay = false;
		} 
		_groupHeaderData =[	{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'
								,disabled:function() {
									if(this.item.__subTreeLength == 0&&this.item.MEMBER_CNT=='0')//하위노드 없고 member가 없을경우만 삭제가능
										return false;    
									else
										return true; 
								}
								,
							},
							{key:'UPPER_GroupCode',  label:"<spring:message code='Cache.lbl_ParentDeptCode'/>", display:false,containExcel : true},
							{key:'UPPER_LANG_DISPLAYNAME',  label:"<spring:message code='Cache.lbl_ParentDeptName'/>", display:false,containExcel : true},
							//부서명
							{key:'LANG_DISPLAYNAME',  label:"<spring:message code='Cache.lbl_DeptName'/>", width:'150', align:'left'
								,formatter:function () {
									return "<a class='underline' href='#' onclick='editOrgGroup(\""+ this.item.GroupCode +"\", \"" + this.item.GroupType + "\"); return false;'>"+this.item.LANG_DISPLAYNAME+"</a>";
								}
								,indent: true
								,getIconClass: function(){
									return "ic_folder";
								}
								,containExcel : true
							},
							//부서코드
							{key:'GroupCode',  label:"<spring:message code='Cache.lbl_DeptCode'/>", width:'100', align:'left',containExcel : true, display:false},
							{key:'MemberOf', label:'MemberOf', width:'80', display:false, align:'center'},
							//우선순위
							{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>", width:'50', align:'center',containExcel : true},
							//간략명칭
							{key:'LANG_SHORTNAME',  label:"<spring:message code='Cache.lbl_CompanyShortName'/>", width:'100', align:'center',containExcel : true},
							//사용여부
							{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'80', align:'center'
								, formatter:function () {
									return coviCmn.getCoviSwitch("IsUse"+this.item.GroupCode,{"on":"Y","off":"N", "defVal":this.item.IsUse, "retVal":this.item.GroupCode}, function (retVal) { updateIsUse(retVal, 'Dept'); });
//									return "<input type='text' kind='switch' isPreventEvent='N' on_value='Y' off_value='N' id='IsUse"+this.item.GroupCode+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.GroupCode+"\", \"Dept\",this);' />";
								}
								,containExcel : true
							},
							//인사연동여부
							{key:'IsHR', label:"<spring:message code='Cache.lbl_IsHR'/>",  width:'80', align:'center'
								, formatter:function () {
									return coviCmn.getCoviSwitch("IsHR"+this.item.GroupCode,{"on":"Y","off":"N", "defVal":this.item.IsHR, "retVal":this.item.GroupCode},  function(retVal){updateIsHR(retVal, 'Dept');});
//									return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsHR"+this.item.GroupCode+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsHR+"' onchange='updateIsHR(\""+this.item.GroupCode+"\", \"Dept\");' />";
								}
								,containExcel : true
							},
							//부서표시여부
							{key:'IsDisplay', label:"<spring:message code='Cache.lbl_IsDisplay'/>",   width:'70', align:'center'
								, formatter:function () {
									return coviCmn.getCoviSwitch("IsDisplay"+this.item.GroupCode,{"on":"Y","off":"N", "defVal":this.item.IsDisplay, "retVal":this.item.GroupCode}, function (retVal) { updateIsDisplay(retVal); });
//									return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsDisplay"+this.item.GroupCode+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsDisplay+"' onchange='updateIsDisplay(\""+this.item.GroupCode+"\");' />";
								}
								,containExcel : true
							},
							//메일
							{key:'PrimaryMail', label:"<spring:message code='Cache.lbl_Mail'/>", width:'80', align:'center',containExcel : true},//display: _isMailDisplay,
							//관리자코드
							{key:'ManagerCode', label:"<spring:message code='Cache.lbl_admin'/>", width:'80', display:false, align:'center'},
							//관리자
							{key:'MANAGERNAME', label:"<spring:message code='Cache.lbl_admin'/>", width:'80', align:'center',containExcel : true},
							//기능
							{key:'UpDown', label:"<spring:message code='Cache.lbl_action'/>", width:'130', align:'center'
								, formatter:function () {
									var item = '';
										item = '<div class="btnActionWrap">'
												+	'<a class="btnTypeDefault btnMoveUp" href="#" onclick="move(\'group\',\''+this.index+'\',\'UP\');"><spring:message code="Cache.lbl_apv_up"/></a>'
												+	'<a class="btnTypeDefault btnMoveDown" href="#" onclick="move(\'group\',\''+this.index+'\',\'DOWN\');"><spring:message code="Cache.lbl_apv_down"/></a>'
												+'</div>'
										return item;
								}
							},
							{key:'DEPT_FULL_PATH',  label:"<spring:message code='Cache.lbl_Path'/>", display:false,containExcel : true},
						];
		
		setTreeConfigGroup();
		searchList();
		var timer = null;
		
		$(window).on("resize", function(){
			clearTimeout(timer);
			timer = setTimeout(function(){
				coviInput.setSwitch();
			}, 200);
		});
	});
	function setTreeConfigGroup(){
		var configObj = {
				targetID : "orggrouptree",					// HTML element target ID
				colGroup:_groupHeaderData,						// tree 헤드 정의 값
				relation:{
					parentKey: "MemberOf",		// 부모 아이디 키
					childKey: "GroupCode"			// 자식 아이디 키
				},
				persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
				persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				colHead: {
					display:true
				},
				theme: "AXTree_none",
				height:"auto",
				fitToWidth:true, // 너비에 자동 맞춤
				xscroll:true,
				body: {
					onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
						_gr_code = item.GroupCode;
						//_group_type = item.GroupType; 최상위 company
					}
				},
				showConnectionLine: true,	// 점선 여부
				
			};
		_myGridTree.setConfig(configObj);
	}
	
	function searchListKeyword(obj) {
		var searchType = $("#selDetailSearchItem").val();
		var searchText = $("#txtDetailSearchText").val();
		if(!($.isEmptyObject(obj)||obj=='') && obj.id=='simpleSearchBtn')
		{
			searchType = "DisplayName";
			searchText = $("#searchInput").val();
		}
		findKeyword(searchType,searchText)
	}
	
	function findKeyword(searchType,searchText) {
		var curIdx =Number(_myGridTree.selectedRow)+1;
		if(_SearchKeyword!=searchText)
		{	
			curIdx = 0;
			_SearchKeyword = searchText;
		}
		_myGridTree.findKeywordData(searchType,searchText,true,true,curIdx)
	}
	function searchList() {
		bindTree();
	}
	function bindTree() {
		if($.isEmptyObject(_domainId)||_domainId=='')
			return;
		_myGridTree.setList({
			ajaxUrl:"/covicore/manage/conf/selectAllDeptList.do",
 			ajaxPars: "domainId="+_domainId,
			onLoad:function(){
 				if(_gr_code==''&&_myGridTree.selectedRow.length==0&&_myGridTree.list.length>0)
				{
					_myGridTree.setFocus(0)
					_gr_code = _myGridTree.list[0].GroupCode;
					//_group_type = List[0].GroupType;
				}
				_myGridTree.expandAll(1);
				coviInput.setSwitch();
 			}
		});
	}
	
	// 사용여부 스위치 버튼에 대한 값 변경
	function updateIsUse(pCode, pType,pObj){//pCode : GroupCode
		pObj = $("#IsUse"+pCode);

		if($(pObj).attr('isPreventEvent')=='Y'){
			$(pObj).attr('isPreventEvent','N')
			return;
		}
		var now = new Date();
		var isUseValue = $("#IsUse"+pCode).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "/covicore/manage/conf/updateIsUseGroup.do";
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsUse" : isUseValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
				{
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog");
					$(pObj).attr('isPreventEvent','N')
				}
				else
				{
					if(data.message.indexOf("|")>-1) 
						Common.Warning(Common.getDic(data.message.split("|")[0]).replace("{0}",data.message.split("|")[1]));
					else
						Common.Inform(data.message);
					if(data.reason = 'EXIST_INFO'){
						$(pObj).attr('isPreventEvent','Y')

						if (isUseValue=="Y")
							$(pObj).siblings("a").removeClass("on");
						else	
							$(pObj).siblings("a").addClass("on");
//						$(pObj).closest("a").tol(isUseValue=="Y"?"N":"Y")
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	// 인사연동여부 스위치 버튼에 대한 값 변경
	function updateIsHR(pCode, pType){
		var now = new Date();
		var isHRValue = $("#IsHR"+pCode).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "/covicore/manage/conf/updateishrdept.do";
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsHR" : isHRValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog");
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	// 표시여부 스위치 버튼에 대한 값 변경
	function updateIsDisplay(pCode){
		var now = new Date();
		var isDisplayValue = $("#IsDisplay"+pCode).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsDisplay" : isDisplayValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:"/covicore/manage/conf/updateisdisplaydept.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog");
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/updateisdisplaydept.do", response, status, error);
			}
		});
	}	
	function addOrgGroup(){
		var sOpenName = "divDeptInfo";

		var sURL = "/covicore/DeptManageInfoPop.do";
		sURL += "?gr_code=" + ''
		sURL += "&domainId=" + _domainId
		sURL += "&domainCode=" + _domainCode
		sURL += "&memberOf=" + _gr_code
		sURL += "&GroupType=" + _group_type
		sURL += "&mode=add"
		sURL += "&OpenName=" + sOpenName;

		var sTitle = "<spring:message code='Cache.lbl_OrganizationDeptAdd'/>" + " ||| " + "<spring:message code='Cache.msg_OrganizationDeptAdd'/>" ;
		
		var sWidth = "700px";
		var sHeight = "680px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
	}
	
	function deleteOrgGroup(){
		var groupCodes='';
		var deleteObject = _myGridTree.getCheckedList(0);
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_CheckNotUseObject'/>");//미사용할 항목을 선택해 주세요
			return;
		}
		$.each(deleteObject, function(i,obj){
			groupCodes += obj.GroupCode + ','
		});
		groupCodes=groupCodes.slice(0,-1)
		Common.Confirm("<spring:message code='Cache.msg_AreYouNotUse'/>", 'Confirmation Dialog', function (result) {    
             if (result) {
                $.ajax({
                	type:"POST",
                	url:"/covicore/manage/conf/deleteGroup.do",
                	data:{
                		"GroupCodes":groupCodes
                	},
                	success:function(data){
						if(data.status == "FAIL") {
							if($.isEmptyObject(data.message)){
								Common.Warning("<spring:message code='Cache.msg_changeFail'/>");
							}
							else{
								if(data.message.indexOf("|")>-1) Common.Warning(Common.getDic(data.message.split("|")[0]).replace("{0}",data.message.split("|")[1]));
								else Common.Warning(data.message);
							}
						} else {
							Common.Inform("<spring:message code='Cache.msg_processSuccess'/>", "Information Dialog", function(result) {
								if(result) {
									searchList()
								}
							});
						}
                	},
                	error:function(response, status, error){
                	     CFN_ErrorAjax("/covicore/manage/conf/deleteDept.do", response, status, error);
                	}
                });
			}
		});
		 
	}
	
	// 위로 버튼 클릭시 실행되며, 해당 항목을 위로 이동합니다.
    function move(Type,Idx,UPDOWN) {
		var sCode_A = 0;
		var sCode_B = 0;

		var oChangeTR = null;
		var oCurrentTR = _myGridTree.list[Idx];
		sCode_A = oCurrentTR.GroupCode;

		var pHash = _myGridTree.list[Idx].pHash
		var hash = _myGridTree.list[Idx].hash
		var i = Number(Idx);
		var TreeList = $.grep(_myGridTree.list,function(item,idx){
			return item.pHash==pHash&&item.hash!=hash&&(UPDOWN=='DOWN'?(idx>i):(idx<i));
		})
		if (TreeList.length==0) {
			Common.Inform("<spring:message code='Cache.msg_gw_UnableChangeSortKey'/>", "Information Dialog");//순서를 변경할 수 없습니다
			return;
		} 
		// 상위OR하위Row
		oChangeTR = (UPDOWN=='UP'?TreeList[TreeList.length-1]:TreeList[0]);
		if(oChangeTR.SortKey==oCurrentTR.SortKey)
		{
			Common.Inform("<spring:message code='Cache.msg_gw_UnableChangeSortKeySameSort'/>", "Information Dialog");//동일한 우선순위는 이동 불가능합니다.
			return;
		}
			
		sCode_B = oChangeTR.GroupCode;

		$.ajax({
			url: "/covicore/manage/conf/moveSortKey_GroupUser.do",
			type:"post",
			data:{
				"pStrCode_A":sCode_A,
				"pStrCode_B":sCode_B,
				"pStrType":Type
				},
			async:false,
			success:function (res) {
				if(res.result == "OK")
					Common.Inform("<spring:message code='Cache.msg_apv_move'/>", "Information Dialog", function() {
						searchList() 
					});
					
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/moveSortKey_GroupUser.do", response, status, error);
			}
		});
	    
	}
		
	
	function editOrgGroup(gr_code,group_type){
		if($.isEmptyObject(gr_code)||gr_code=='')
			return;
		
		var sOpenName = "divDeptInfo";

		var sURL = "/covicore/DeptManageInfoPop.do";
		sURL += "?gr_code=" + gr_code
		sURL += "&domainId=" + _domainId
		sURL += "&domainCode=" + _domainCode
		sURL += "&memberOf=" + ''
		sURL += "&GroupType=" + group_type
		sURL += "&mode=modify"
		sURL += "&OpenName=" + sOpenName;
		

		var sTitle = "<spring:message code='Cache.lbl_OrganizationDeptInfo'/>" + " ||| " + "<spring:message code='Cache.msg_OrganizationDeptAdd'/>" ;
		
		var sWidth = "700px";
		var sHeight = "680px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
	}
	
	function syncSelectDomain() {
		Common.Progress("<springmessage code='Cache.msg_Processing'/>");
		$.post("/covicore/aclhelper/refreshSyncKeyAll.do", {"DomainID" : _domainId}, function(data) {
			Common.AlertClose();
		});
	}
		
	function modifyMember(isModify){
		if(isModify)
			searchList()
	}
	
	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
	}
	
  	//엑셀 다운로드
	function excelDownload(){ 
		var type = 'dept'
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", 'Confirmation Dialog', function (result) {  
			if (result) {
                var headerName = getHeaderNameForExcel();
				var	sortKey = "SortKey";
				var	sortWay = "ASC";				  	
				
				location.href = "/covicore/manage/conf/groupExcelDownload.do?sortColumn=" + sortKey 
				+ "&sortDirection=" + sortWay 
				+ "&groupType=" + type 
				+ "&groupCode=" + ''
				+ "&domainId=" + _domainId
				+ "&headerName=" + encodeURI(encodeURIComponent(headerName)) 
			}
		});
	}
  	
	//엑셀용 Grid 헤더정보 설정
	function getHeaderNameForExcel(){
		var returnStr = "";
		
	   	for(var i=0;i<_groupHeaderData.length; i++){
	   	   	if(_groupHeaderData[i].containExcel){
				returnStr += _groupHeaderData[i].label + ";";
	   	   	}
		}
		
		return returnStr;
	}

	function pageRefresh(){
		searchList();
	}
</script>