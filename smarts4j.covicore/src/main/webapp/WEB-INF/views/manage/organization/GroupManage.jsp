<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
.underline{text-decoration:underline}
a.disabled {pointer-events: none;}
input[name='checkAll']{display:none}
label.help_label{font-size: 14px;}
</style>
<div class="cRConTop titType"> 
	<h2 class="title"><spring:message code="Cache.CN_146"/></h2>	<!-- 그룹 관리 -->
</div>	
<div class="cRContBottom mScrollVH"> 
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
				<button id="folderRefresh" class="btnRefresh" type="button" onclick="bindTree()"></button>
			</div>
		</div>
		<!-- 상단 버튼 끝 -->
		<div class="tblList tblCont">
			<div id="orggrouptree" class="treeBody"></div>
		</div>
	</div>
</div>
<script type="text/javascript">
	var _isMailDisplay = true;
	var _myGridTree;
	var _gr_code='';
	var _group_type = '';
	var _domainId =confMenu.domainId;
	var _domainCode = confMenu.domainCode;
	var _groupHeaderData;
	
	$(document).ready(function () {
		_myGridTree = new coviTree();
		//기초설정에 따른 메일 표기 여부
		if(coviCmn.configMap["IsSyncMail"] == null ||  coviCmn.configMap["IsSyncMail"] == 'N'){
			_isMailDisplay = false;
		} 
		setBtnDisplay()
		_groupHeaderData =[	{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'
								,disabled:function() {
									if(this.item.__subTreeLength == 0&&this.item.MEMBER_CNT=='0/0')//하위노드 없고 member가 없을경우만 삭제가능
										return false;    
									else
										return true; 
								}
								
							},
							//그룹 명칭
							{key:'LANG_DISPLAYNAME',  label:"<spring:message code='Cache.lbl_apv_groupName'/>", width:'100', align:'left'
								,indent: true
								,formatter:function () {
									return "<a class='underline' href='#' onclick='editOrgGroup(\""+ this.item.GroupCode +"\", \"" + this.item.GroupType + "\"); return false;'>"+this.item.LANG_DISPLAYNAME+"</a>";
								}
								,indent: true
								,getIconClass: function(){		// indent 속성 정의된 대상에 아이콘을 지정 가능
												return "ic_folder";
								}
								,containExcel : true
							},
							//그룹코드
							{key:'GroupCode', label:"<spring:message code='Cache.lbl_GroupCode'/>", width:'80', display:false, align:'center'},
							//우선순위
							{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>", width:'50', align:'center',containExcel : true},
							//간략명칭
							{key:'ShortName',  label:"<spring:message code='Cache.lbl_CompanyShortName'/>", width:'100', align:'center',containExcel : true},
							//메일
							{key:'PrimaryMail', label:"<spring:message code='Cache.lbl_Mail'/>", width:'80',align:'center',containExcel : true},//display: _isMailDisplay,
							//사용여부
							{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'40', align:'center'
								,formatter:function(){ return formatSwitch(this); }
								,containExcel : true
							},
							//그룹멤버 수  
							{key:'MEMBER_CNT',  label:"<spring:message code='Cache.lbl_GroupMemberCnt'/>", width:'40', align:'center',containExcel : true},
							//그룹멤버관리
							{key:'USERMANAGE',  label:"<spring:message code='Cache.lbl_UserManage'/>", width:'70', align:'center'
								, formatter:function () {
									var GroupType = this.item.GroupType.toUpperCase()
									var GroupCode = this.item.GroupCode.toUpperCase()
									// 지역, 직위, 직급, 직책, 배포그룹, 퇴직부서는 하위에 구성원(사용자)를 생성 할 수 없다.
									if (//GroupType == "JOBLEVEL" || GroupType == "JOBTITLE" || GroupType == "JOBPOSITION"|| GroupType == "REGION"||
										   GroupType == "COMPANY"  || GroupType == "DISTRIBUTE" || GroupType == "COMMUNITY"
										|| (GroupCode.indexOf("_DIVISION") != -1) || (GroupCode.indexOf("_JOBLEVEL") != -1) || (GroupCode.indexOf("_JOBTITLE") != -1) || (GroupCode.indexOf("_JOBPOSITION") != -1)
										|| (GroupCode.indexOf("_REGION") != -1) || (GroupCode.indexOf("_DISTRIBUTE") != -1) || (GroupCode.indexOf("_COMMUNITY") != -1) || (GroupCode.indexOf("_RETIREDEPT") != -1)
										|| (GroupCode.indexOf("_AUTHORITY") != -1)|| (GroupCode.indexOf("_MANAGE") != -1)
									)
									{
										return '';
									}
									return '<a class="btnTypeDefault" href="#" onclick="showMemberManagePopup(\''+this.item.GroupCode+'\',\''+this.item.GroupType+'\');"><spring:message code="Cache.lbl_GroupMemberManage"/></a>';
								}
							},
							//기능
							{key:'UPDOWN',  label:"<spring:message code='Cache.lbl_action'/>", width:'100', align:'center', formatter:function () {
									var item = '';
									item = '<div class="btnActionWrap">'
											+	'<a class="btnTypeDefault btnMoveUp" href="#" onclick="move(\'group\',\''+this.index+'\',\'UP\');"><spring:message code="Cache.lbl_apv_up"/></a>'
											+	'<a class="btnTypeDefault btnMoveDown" href="#" onclick="move(\'group\',\''+this.index+'\',\'DOWN\');"><spring:message code="Cache.lbl_apv_down"/></a>'
											+'</div>'
									return item;
								}
							},
						];
		
		setTreeConfigGroup();
		bindTree();
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
				persistSelected: false,			// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				colHead: {
					display:true
				},
				theme: "AXTree_none",
				height:"auto",
				fitToWidth:true, // 너비에 자동 맞춤
				xscroll:true,
				yscroll:true,
				body: {
					onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
						_gr_code = item.GroupCode;
						_group_type = item.GroupType;
						setBtnDisplay();
					}
				},
				paging : false,
				showConnectionLine: true,	// 점선 여부
			};
		_myGridTree.setConfig(configObj);
	}
	
	function bindTree() {
		if($.isEmptyObject(_domainId)||_domainId=='')
			return;
		
		_myGridTree.setList({
			ajaxUrl:"/covicore/manage/conf/getAllGroupList.do",
 			ajaxPars: "domainId="+_domainId,
			onLoad:function(){
				if(_gr_code==''&&_myGridTree.selectedRow.length==0&&_myGridTree.list.length>0) {
					_myGridTree.click(0, "open", true);
				}
				_myGridTree.expandAll(1);
 			}
		});
	}
	
	// 사용여부 스위치 버튼에 대한 값 변경
	function updateIsUse(pCode, pIsUse, pTarget){
		var now = new Date();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "/covicore/manage/conf/updateIsUseGroup.do";
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsUse" : pIsUse,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok") {
					Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
				}
				else {
					if(data.message.indexOf("|")>-1) {
						Common.Warning(Common.getDic(data.message.split("|")[0]).replace("{0}",data.message.split("|")[1]));
					} else {
						Common.Inform(data.message);
					}
					if(pIsUse == 'Y'){
						$(pTarget).removeClass("on");
						$("#switch_"+pCode).val($("#switch_"+pCode).attr("off_value"));
					} else {
						$(pTarget).addClass("on");
						$("#switch_"+pCode).val($("#switch_"+pCode).attr("on_value"));
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
		
	function addOrgGroup(){
		var sOpenName = "divgroupInfo";
		var sGR_Code = "";
		var sURL = "/covicore/ArbitraryGroupManageInfoPop.do";
		sURL += "?gr_code=" + '';
		sURL += "&domainId=" + _domainId
		sURL += "&memberOf=" + _gr_code;
		sURL += "&GroupType=" + _group_type;
		sURL += "&mode=add";
		sURL += "&OpenName=" + sOpenName;
		
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_OrganizationGroupAdd'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationGroupAdd'/>" ;

		var sWidth = "710px";
		var sHeight = "640px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
	}
	
	function deleteOrgGroup(){
		var groupCodes='';
		var deleteObject = _myGridTree.getCheckedList(0);
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_CheckNotUseObject'/>"); 
			return;
		}
		$.each(deleteObject, function(i,obj){
			groupCodes += obj.GroupCode + ','
		});
		groupCodes=groupCodes.slice(0,-1)
		Common.Confirm("<spring:message code='Cache.msg_AreYouNotUse'/>", 'Confirmation Dialog', function (result) {       //apv_msg_rule02 하위 노드가 존재하면 같이 삭제 됩니다. 선택한 항목을 삭제 하시겠습니까?
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
									bindTree()
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
	
	function setBtnDisplay(){
		var setBtnDisable  = false;
		var sGroupType = $.isEmptyObject(_group_type) ? '':_group_type.toUpperCase();	
		var sGrCode = 	$.isEmptyObject(_gr_code) ? '':_gr_code.toUpperCase();			
		
		
		$("#btnAdd").removeClass('disabled');
		$("#btnDel").removeClass('disabled');
		
		if (sGroupType==''
			||sGroupType == "JOBLEVEL" || sGroupType == "JOBTITLE" || sGroupType == "JOBPOSITION" || sGroupType == "COMPANY" || sGroupType == "REGION" || sGroupType == "DISTRIBUTE" || sGrCode.indexOf("_DIVISION") != -1
			|| sGrCode.indexOf("_REGION") != -1 || sGrCode.indexOf("_JOBLEVEL") != -1 || sGrCode.indexOf("_JOBTITLE") != -1 || sGrCode.indexOf("_JOBPOSITION") != -1)
		{
			$("#btnAdd").addClass('disabled');
			$("#btnDel").addClass('disabled');
		}
		
		
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
						bindTree() 
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
		
		var sOpenName = "divgroupInfo";
		var sURL = "/covicore/ArbitraryGroupManageInfoPop.do";
		sURL += "?gr_code=" + gr_code
		sURL += "&domainId=" + _domainId
		sURL += "&memberOf=" + ''
		sURL += "&GroupType=" + group_type
		sURL += "&mode=modify"
		sURL += "&OpenName=" + sOpenName; 
 

		sTitle = "<spring:message code='Cache.lbl_OrganizationGroupInfo'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationGroupInfo'/>" ;
		
		var sWidth = "710px";
		var sHeight = "640px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
	}
	
	function syncSelectDomain() {
		Common.Progress("<spring:message code='Cache.msg_Processing'/>");
		$.post("/covicore/aclhelper/refreshSyncKeyAll.do", {"DomainID" : _domainId}, function(data) {
			Common.AlertClose();
		});
	}
		
	function showMemberManagePopup(gr_code,groupType){
		if($.isEmptyObject(gr_code)||gr_code=='')
			return;
		
		var sOpenName = "divgroupMemberInfo";

		var sURL = "/covicore/GroupMemberManagePop.do";
		sURL += "?gr_code=" + gr_code
		sURL += "&domainId=" + _domainId
		sURL += "&OpenName=" + sOpenName
		sURL += "&domainCode=" + _domainCode
		sURL += "&groupType=" + groupType
		sURL += "&callBackFunc=modifyMember";
		

		var sTitle = "<spring:message code='Cache.lbl_GroupMemberManage'/>";//그룹멤버관리
		
		var sWidth = "720px";
		var sHeight = "630px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
	}
	function modifyMember(isModify){
		if(isModify==='true')
			bindTree()
	}
	
	
  	//엑셀 다운로드
	function excelDownload(){ 
		var type = 'group'
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
		bindTree();
	}
	
	function formatSwitch(pObj){
		var param = pObj.item;
		param.on = 'Y'; param.off = 'N';
		param.defVal = param[pObj.key];
		param.retVal = param.GroupCode;
		return coviCmn.getCoviSwitch('switch_'+param.GroupCode, param, 'updateIsUse');
	}
</script>