/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2017.06.22</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///권한지정 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/

/// <summary>

/// 임시 생성 향후 covision.orgchart.js와 결합

/// 조직도 유형(Type): 대상 1자리(A/B/C/D) + 구분1자리(0/1/2)
/// [A0: 직원 조회용(2열)]
/// [B1: 사용자 선택(3열-1명만)]
/// [B9: 사용자 선택(3열-여러명)]
/// [C1: 그룹 선택(3열-1개만)]
/// [C9: 그룹 선택(3열-여러개)]
/// [D1: 사용자/그룹 선택(3열-1개만)]
/// [D9: 사용자/그룹 선택(3열-여러개) [Default]]

/// Tree 종류[TreeKind]
/// [Dept - 부서(부서 조직도만 필요시)]
/// [Group - 그룹(권한 설정, 사용자 검색 등) : 부서, 그룹(배포그룹 제외)]

/// </summary>
//# sourceURL=covision.orgchartA0.js

var coviOrgA0 = (function () {
	var coviOrgObj={};
	
	//개별호출 일괄처리
	var orgDic =  Common.getDicAll(["lbl_officer", "lbl_apv_deptsearch", "btn_Confirm","btn_Close", "lbl_apv_person","btn_apv_search",
	                                ,"msg_OrgMap03","msg_OrgMap04","msg_OrgMap05","msg_OrgMap06","lbl_name","lbl_dept" , "msg_EnterSearchword"
	                                ,"lbl_MobilePhone", "lbl_apv_InPhone", "lbl_Role", "lbl_JobTitle", "lbl_JobPosition","lbl_JobLevel","msg_NoDataList", "lbl_CompanyNumber"
	                                ,"OrgTreeKind_Dept","OrgTreeKind_Group", "lbl_UserProfile", "lbl_DeptOrgMap" , "lbl_group","lbl_OpenAll","lbl_CloseAll", "lbl_apv_recinfo_td2"
									,"lbl_com_exportAddress", "lbl_apv_appMail", "lbl_com_Absense", "lbl_com_searchByName", "lbl_com_searchByDept", "lbl_com_searchByPhone"
									, "lbl_com_searchByRole", "lbl_com_searchByJobPosition", "lbl_com_searchByJobLevel","lbl_MyInfo_14"
									,"lbl_att_offWork","lbl_n_att_absent","lbl_Place","lbl_Reason","lblOfficeCall","lbl_AddJob","lbl_DisJob"
									,"lbl_AbsentType","lblAbsentTerm","lbl_AbsentDuty","lblAbsentReason"]);
	
	var sessionObj = Common.getSession();
	var lang = sessionObj["lang"]; 
	var companyCode = CFN_GetQueryString("companyCode") == "undefined" ? sessionObj["DN_Code"] : CFN_GetQueryString("companyCode");
	var useAffiliateSearch = Common.getBaseConfig("useAffiliateSearch");
	var useAttendStatusInOrgChart = Common.getBaseConfig("useAttendStatusInOrgChart");
	
	var $this = coviOrgObj;
	var allGroupBind = "N";
	var changeIndex=0;
	var searchKeyword = ''; //검색어
	var selectDeptCode = '';
	
	coviOrgObj.groupTree = new AXTree();
	coviOrgObj.groupTree.config.xscrollRatio = 0.8;	//x스크롤이 끝까지 이동하지 않을때 1보다 작은 값을 주어 조정한다.
	
	coviOrgObj.config = {
			targetID: '',
			type:'A0',
			treeKind:'Group',
			groupDivision: '',
			communityId: '',
			drawOpt:'LM__B', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
			callbackFunc: '', 
			openerID:'',
			allCompany:useAffiliateSearch     /// 타 계열사 검색 허용 여부
	}; 
	
	
	//public 함수 
	coviOrgObj.render = function(orgOpt){
		setConfig(orgOpt);
		insertBasicHTML();
		setControls();
		setViewChart();
		
		if($this.config.drawOpt.charAt(0)=="L"){
			setInitGroupTreeData("Y");
		}
	};

	coviOrgObj.returnData = function(){
		if($this.config.type=="A0"){
			$this.closeLayer();
			return;
		}
	}
	
	coviOrgObj.closeLayer = function(){
		Common.Close();
	}
	
	coviOrgObj.getUserOfGroupList = function(nodeValue){
		
		if($this.config.type=="C1"||$this.config.type=="C9"||$this.config.drawOpt.charAt(1)!="M")
			return ;
		
		var deptCode = nodeValue;		
		var groupType = $(":input:radio[name=groupTypeRadio]:checked").val();
		
		// 선택한 부서 코드 저장
		selectDeptCode = nodeValue;
		
		//검색 초기화
		searchKeyword = '';
		$("#searchText").val('');
		
		setGroupInfo(deptCode);

		$.ajax({
			type:"POST",
			data:{
				"deptCode" : deptCode,
				"groupType" : groupType,
				"hasChildGroup" :  ($("#hasChildGroup").prop("checked") ? "Y": "N"),
				"useAttendStatus": useAttendStatusInOrgChart
			},
			async:false,
			url:"/covicore/control/getUserList.do",
			success:function (data) {
				if(data.status == 'SUCCESS'){
					setMemberList(data);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getUserList.do", response, status, error);
			}
		});
	}
	
	/*coviOrgObj.allCheck = function(obj){
		var table= $("#orgSearchList").closest('table');
		$('tbody tr td input[type="checkbox"]',table).prop('checked', $(obj).prop('checked'));
	}*/
	
	//전체 펴기
	coviOrgObj.expandAllTree = function(obj){
		if(allGroupBind == "N"){
			$.each($this.groupTree.list,function(idx,group){
				if(group.haveChild == "Y" && group.isLoad == "N"){ //하위 항목이 있는데 로드가 안된 경우가 있는 경우 전체 트리 바인드
					setAllGroupTreeData();
					return false; //break
				}
			});
		}
		
		$this.groupTree.expandAll();
	}
	
	//전체 접기
	coviOrgObj.collapseAllTree = function(obj){
		$this.groupTree.collapseAll();
	}
	
	
	coviOrgObj.close = function(){
		parent.Common.close($this.config.popupID);
	}			
	
	coviOrgObj.contentDoubleClick = function(){
		coviOrgObj.sendRight();
	}
	
	coviOrgObj.goUserInfoPopup = function(userID){
		parent.Common.open("","MyInfo",orgDic["lbl_UserProfile"],"/covicore/control/callMyInfo.do?userID="+userID,"810px","500px","iframe",true,null,null,true); //사용자 프로필
	}
	
	coviOrgObj.imgError = function(image) {
	    image.onerror = "";
	    image.src = "/covicore/resources/images/no_profile.png";
	    return true;
	}
	
	coviOrgObj.loadPhotoArea = function(elem) {
		if($(elem).height() > $(elem).closest('.photoArea').height())
			$(elem).css('margin-top', (($(elem).height() - $(elem).closest('.photoArea').height()) / 2 * -1) + "px");
	}
	
	//목록형, 분할형, 카드형 선택시 리스트형태 Change
	coviOrgObj.ChangeChart=function(obj){
		$("a[name='viewType']").removeClass("active");
		$(obj).addClass('active');
		
		var viewType = $("a[name='viewType'][class~='active']").attr("value");
		var nodeValue = $this.groupTree.getSelectedList().item != null ? $this.groupTree.getSelectedList().item.GroupCode : $("#groupPathList").find("li").last().attr("code");
		
		coviCmn.setCookie('orgChartViewTypeCookie',viewType, 365);	

		if(searchKeyword != ''){
			search();
		}else if(nodeValue != null){
			$this.getUserOfGroupList(nodeValue);
		}else{
			return;
		}
		
		/*if(viewType =="listType"){//목록형, 분할형, 카드형선택시 리스트화면전환
			$("#orgSearchList").attr('class','org_view_list01');		
		}else if(viewType =="splitType"){
			$("#orgSearchList").attr('class','org_view_list02');			
		}else if(viewType =="cardType"){
			$("#orgSearchList").attr('class','org_view_list03');			
		}*/
		
	}
	
	//분할형 상세조회시 데이터변경
	coviOrgObj.indexChenge =function(index){
		changeIndex= index;				
		var nodeValue = $this.groupTree.getSelectedList().item.GroupCode;
		
		if(searchKeyword != ''){
			search();
		}else if(nodeValue!=null){
			$this.getUserOfGroupList(nodeValue);
		}else{
			return;
		}
	}
	
	//Tree 함수
	coviOrgObj.groupTree.displayIcon = function(value){
		if(value){
			$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","block");
		}else{
			$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","none");
		}
	}
	
	coviOrgObj.groupTree.getCheckedTreeList = function(inputType){
		var collect = [];
		var list = this.list;
		
		this.body.find("input[type="+inputType+"]").each(function(){
			var arr = this.id.split('_'); 
			if(this.checked && (arr[1] == "treeCheckbox" || arr[1]== "treeRadio")){
				var itemIndex = this.id.replace(arr[0]+ "_" + arr[1] + "_", "");
				for(var i=0; i < list.length; i++)
					if(list[i].no == itemIndex)
						collect.push(list[i]);
			}
		});
		return collect;
	}
	
	//private 함수 
	//초기 설정값 셋팅
	function setConfig(orgOpt){
		$this.config.targetID = orgOpt.targetID;	
		
		if(!isEmpty(orgOpt.type)){
			$this.config.type = orgOpt.type;	
			if(orgOpt.type == "A0"){ //조회용일 경우 선택화면 안 그림
				orgOpt.drawOpt = "LM__B" ; 
			}
		}
		
		$this.config.treeKind = isEmptyDefault(orgOpt.treeKind , $this.config.treeKind );
		$this.config.drawOpt = isEmptyDefault(orgOpt.drawOpt , $this.config.drawOpt );
		$this.config.callbackFunc = isEmptyDefault(orgOpt.callbackFunc , $this.config.callbackFunc);
		$this.config.openerID = isEmptyDefault(orgOpt.openerID , $this.config.openerID);
		$this.config.allCompany = isEmptyDefault(orgOpt.allCompany , $this.config.allCompany);
		if(Common.getGlobalProperties("isSaaS") == "Y") {
			// SaaS 그룹웨어의 경우 사간검색 무조건 불가능
			$this.config.allCompany = "N";
		}
		$this.config.groupDivision = isEmptyDefault(orgOpt.groupDivision , $this.config.groupDivision);
		$this.config.communityId = isEmptyDefault(orgOpt.communityId , $this.config.communityId);
	}	
	
	//기본 HTML 바인딩
	function insertBasicHTML(){
		var html = '';
		
		//부서 및 그룹 트리 
		if($this.config.drawOpt.charAt(0) === 'L'){
			html += '			<div class="org_tree_wrap" id="groupTreeDiv">';
			html += '				<div class="org_tree_top">';
			html += '					<select id="companySelect" class="org_tree_top_select"></select>';
			if($this.config.treeKind.toUpperCase() == "GROUP"){
				html += '				<div class="org_tree_top_radio_wrap">';
				html += '					<input id="deptRadio" type="radio" class="org_tree_top_radio" value="dept"  name="groupTypeRadio"  checked><label for="deptRadio">' + orgDic["lbl_DeptOrgMap"]+ '</label>'; //조직도
				html += '					<input id="groupRadio" type="radio" class="org_tree_top_radio" value="group"  name="groupTypeRadio"><label for="groupRadio">' + orgDic["lbl_group"]+ '</label>'; // 그룹
				html += '				</div>';
			}
			/*html += '					<div class="org_tree_top_btn">';
			html += '						<a class="org_tree_close" onclick="coviOrgA0.collapseAllTree();">' + orgDic["lbl_CloseAll"]+ '</a>'; //전체닫기
			html += '						<a class="org_tree_open" onclick="coviOrgA0.expandAllTree();">' + orgDic["lbl_OpenAll"]+ '</a>'; //전체열기
			html += '					</div>';*/
			html += '					<div class="treeList radio radioType02 org_tree mScrollVH scrollVHType01" >';
			if($this.config.allCompany == "Y" || $this.config.allCompany == "") {
				html += '						<div id="groupTree" class="treeList radio radioType02 org_tree" style="height:480px; overflow:hidden;"></div>';
			} else {
				html += '						<div id="groupTree" class="treeList radio radioType02 org_tree" style="height:525px; overflow:hidden;"></div>';
			}
			html += '					</div>';
			html += '				</div>';
			html += '			</div>';
		}
		
		//사용자 목록
		if($this.config.drawOpt.charAt(1) === 'M'){
			html += '<div class="org_list_wrap">';
			html += '	<div class="org_list_loc_wrap  mScrollH scrollHType01">';
			html += '		<ul id="groupPathList" class="org_list_loc">';
			//html += 			'<li><a>코비젼</a></li>';
			html += ' 		</ul>';
			html += ' 	</div>';
			html += ' 	<div class="org_list_top">';
			html += ' 		<select class="org_list_top_select" id="searchTypeSelect">';
			html += ' 			<option value="name">' + orgDic["lbl_name"] + '</option>'; //이름
			html += ' 			<option value="dept">' + orgDic["lbl_dept"] + '</option>'; //부서
			html += ' 			<option value="phone">' + orgDic["lbl_MobilePhone"] + '</option>'; //핸드폰
			html += ' 			<option value="mail">' + orgDic["lbl_apv_appMail"] + '</option>'; //메일
			html += ' 			<option value="companynumber">' + orgDic["lbl_CompanyNumber"] + '</option>'; //회사번호
			html += ' 			<option value="charge">' + orgDic["lbl_Role"] + '</option>'; //담당업무
			html += ' 			<option value="jobtitle">' + orgDic["lbl_JobTitle"] + '</option>'; //직책
			html += ' 			<option value="jobposition">' + orgDic["lbl_JobPosition"] + '</option>'; //직위
			//html += ' 			<option value="joblevel">' + orgDic["lbl_JobLevel"] + '</option>'; //직급
			html += ' 		</select>';
			html += ' 		<div class="searchBox02">';
			html += '   		<span>';
			html += '				<input type="text" id="searchText" >';
			html += '     			<button id="searchBtn" type="button" class="btnSearchType01"></button>'; //검색
			html += '			</span>';
			html += ' 		</div>';
			html += ' 		<div class="chkStyle04 chkType01">';
			html += '   		<input type="checkbox" id="hasChildGroup"><label for="hasChildGroup"><span></span>' + orgDic["lbl_apv_recinfo_td2"] + '</label>'; //하위부서 포함
			html += ' 		</div>';
			html += '  		<div class="buttonStyleBoxRight" >';
						html += '<a class="btnListView listViewType01" name="viewType" value="listType" onclick="coviOrgA0.ChangeChart(this);"></a>'; //목록형
						html += '<a class="btnListView listViewType04" name="viewType" value="splitType"  onclick="coviOrgA0.ChangeChart(this);"></a>'; //분할형
						html += '<a class="btnListView listViewType02"  name="viewType" value="cardType"  onclick="coviOrgA0.ChangeChart(this);"></a>'; //카드형
			html += '		</div>';
			html += ' 	</div>';
			html += '   <div class="org_view_wrap" id="addType">';
			html += '   	<div class="mScrollV scrollVType01" id="orgScroll"><div id="orgSearchListDiv" ></div>';
			html +=	'	</div>';
			html += '   	<div id="profileDiv" class="org_view_profile" style="display:none"></div>';
			html += ' </div>';
			html += ' </div>';
		}		

		if($this.config.drawOpt.charAt(4) === 'B'){
			html += '<div class="org_btn_wrap">';
			html += ' 	<a style="display:none" class="org_btn_address">' + orgDic["lbl_com_exportAddress"] + '</a>';  // TODO 향후 개발 예정  / 주소록 내보내기				
			if($this.config.type != "A0"){
				html += '	<a class="btnTypeDefault" onclick="coviOrgA0.returnData();" >'+orgDic["btn_Confirm"]+'</a>'; /*확인*/ 
			}
			html += ' 	<a class="owBtn" onclick="coviOrgA0.closeLayer();">'+orgDic["btn_Close"]+'</a>'; /*닫기*/ 
			html += '</div>';
		}
		
		
		if($this.config.targetID != ''){
			$("#"+$this.config.targetID).addClass("portalOrgPopContent");
			$("#"+$this.config.targetID).prepend(html);
			coviCtrl.bindmScrollV($('.mScrollV'));
			coviCtrl.bindmScrollH($('.mScrollH'));
		}
		
		if($this.config.drawOpt.charAt(1) === 'M'){
			$("a[name='viewType']").click(function(e){
				$('a[name="viewType"]').removeClass('active');
				   $(this).addClass('active');
			});
		}
		
	}
	
	//Select 박스 바인딩 (회사 목록 및 검색 조건)
	function setControls(){
		if($this.config.drawOpt.charAt(0) === "L"){
			var isAdmin = CFN_GetQueryString("CLMD");
			if(isAdmin == "undefined") {
				if(opener != null) {
					isAdmin = opener.parent.CFN_GetQueryString("CLMD");
				} else {
					isAdmin = window.parent.CFN_GetQueryString("CLMD");
				}
			}
			
			$.ajax({
				type:"POST",
				url : "/covicore/control/getCompanyList.do",
				data:{
					allCompany: $this.config.allCompany,
					companyCode: companyCode,
					isAdmin: isAdmin
				},
				async: false, 
				success : function(data){
					$.each(data.list,function(idx, obj){
						$("#companySelect").append($('<option/>', {value: obj.GroupCode, text: obj.DisplayName}));
					});
					
					$('#companySelect').val(companyCode); //loadMyCompany;
				}
			});
			
			$("#companySelect").change(function (){
				allGroupBind = "N";
				setInitGroupTreeData("Y");
				$("#groupPathList").empty();
			});
			
			if($this.config.treeKind.toUpperCase() == "GROUP"){
				$(":input:radio[name=groupTypeRadio]").click(function (){
					$("#groupPathList").empty();
					allGroupBind = "N";
					setInitGroupTreeData("Y"); //loadMyDept = "N"
					
					if($(this).val() == "group") {
						$("#orgSearchListDiv").empty().append('<div class="tdRelBlock" style="margin-left:45px;"><div class="bodyNode bodyTdText" align="center">' + orgDic["msg_NoDataList"]+ '</div></div>');
					}
				});
			}
		}
		
		
		if($this.config.drawOpt.charAt(1) === "M"){
			$('#searchText').keydown(function(e) {
			    if (e.keyCode == 13) {
		    		changeIndex=0;
		    		search();
			    }
			});
			
			$('#searchBtn').click(function(e) {
				changeIndex=0;
				search();
			});
			
			$('#hasChildGroup').change(function(e) {
				changeIndex=0;
				$this.getUserOfGroupList($this.groupTree.getSelectedList().item.GroupCode);
			});
		}
		
		if($this.config.allCompany == "N") { 
			//사간 검색 불가일 경우 select box 숨김 처리
			$("#companySelect").hide();
			$(".appTreeBot").css("margin-top", "0px");
			$(".org_tree_top_radio_wrap").css("margin-top", "0px");
		}
	}
	
	function setGroupTreeConfig(){
		var pid = "groupTree" //treeTargetID
		var func = { 		// 내부에서 필요한 함수 정의
				covi_setCheckBox : function(item){		// checkbox button
					if(item.chk == "Y"){
						return "<input type='checkbox' id='"+pid+"_treeCheckbox_"+item.no+"' name='treeCheckbox_"+item.no+"' value='"+jsonToString(item)+"' />";
					}else if(item.chk == "N"){
						return "";
					}else{
						return "";
					}
				},
				covi_setRadio : function(item){			// radio button
					if(item.rdo == "Y"){
						return "<input type='radio' id='"+pid+"_treeRadio_"+item.no+"' name='treeRadio' value='"+jsonToString(item)+"' />";
					}else if(item.rdo == "N"){
						return "";
					}else{
						return "";
					}
				}
		};
		
		var bodyConfig = {};
		
		if($(":input:radio[name=groupTypeRadio]:checked").val() == "group"){
			bodyConfig = {
					onclick:function(idx, item){
						if(item.GroupType.toUpperCase() != "COMPANY"){							
							changeIndex=0;						
							$this.getUserOfGroupList(item.GroupCode);	
						}else{							
							changeIndex=0;
							$this.groupTree.clearFocus();
						}
					},
					onexpand:function(idx, item){ //[Function] 트리 아이템 확장 이벤트 콜백함수
						if(item.isLoad == "N" && item.haveChild == "Y"){ //하위 항목이 로드가 안된 상태
							$this.groupTree.updateTree(idx, item, {isLoad: "Y"});
							getChildrenData(idx, item);
						}
			        }
			};
		}else{
			bodyConfig = {
					onclick:function(idx, item){
						changeIndex=0;
						$this.getUserOfGroupList(item.GroupCode);	
					},
					onexpand:function(idx, item){ //[Function] 트리 아이템 확장 이벤트 콜백함수
						if(item.isLoad == "N" && item.haveChild == "Y"){ //하위 항목이 로드가 안된 상태
							$this.groupTree.updateTree(idx, item, {isLoad: "Y"});
							getChildrenData(idx, item);
						}
			        }
			};
		}
		
		$this.groupTree.setConfig({
			targetID : "groupTree",					// HTML element target ID
			theme: "AXTree_none",		// css style name (AXTree or AXTree_none)
			//height:"auto",
			xscroll:true,
			width:"auto",
			showConnectionLine:true,		// 점선 여부
			relation:{
				parentKey: "pno",		// 부모 아이디 키
				childKey: "no"			// 자식 아이디 키
			},
			persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: false,			// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colGroup:[{
				key: "nodeName",			// 컬럼에 매치될 item 의 키
				//label:"TREE",				// 컬럼에 표시할 라벨
				//width: "400", 			// 부서명 말줌임하지 않고 전체 표시시킬 경우 주석해제(긴 부서가 없을때도 스크롤 생기는 문제 있음)
				align: "left",	
				indent: true,					// 들여쓰기 여부
				getIconClass: function(){		// indent 속성 정의된 대상에 아이콘을 지정 가능
					var iconNames = "folder, AXfolder, movie, img, zip, file, fileTxt, company".split(/, /g);
					var iconName = "";
					if(typeof this.item.type == "number") {
						iconName = iconNames[this.item.type];
					} else if(typeof this.item.type == "string"){
						iconName = this.item.type.toLowerCase(); 
					} 
					return iconName;
				},
				formatter:function(){
					var anchorName = $('<a />').attr('id', 'folder_item_'+this.item.no);
					anchorName.text(this.item.nodeName);
					
					if(this.item.url != "" && this.item.url != undefined){
						anchorName.attr('href', this.item.url);
					}
					if(this.item.onclick != "" && this.item.onclick != undefined){
						anchorName = $('<div />').attr('onclick', this.item.onclick).append(anchorName);
					}
					
					var str = anchorName.prop('outerHTML');
					if($this.config.type != "B1"&& $this.config.type!="B9" && $this.config.type!="A0"){
						str = func.covi_setCheckBox(this.item) + str;
					}
					
					return str;
				}
			}],						// tree 헤드 정의 값
			body:bodyConfig									// 이벤트 콜벡함수 정의 값
		});
		
	}
	
	//전체 트리 바인딩
	function setAllGroupTreeData(){
		var domain = $("#companySelect").val();
		var groupType = $(":input:radio[name=groupTypeRadio]:checked").val();

		setGroupTreeConfig();
		
		$.ajax({
			url:"/covicore/control/getDeptList.do",
			type:"POST",
			data:{
				"companyCode" : domain,
				"groupType" : groupType,
				"treeKind":$this.config.treeKind,
				"groupDivision":$this.config.groupDivision,
				"communityId":$this.config.communityId
			},
			async:false,
			success:function (data) {
				allGroupBind = "Y";
				$this.groupTree.setList( data.list );
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getDeptList.do", response, status, error);
			}
		});

		$this.groupTree.displayIcon(false); //Icon에 checkbox 가려지는 현상 제거
	}
	
	
	//초기 그룹 트리 바인딩
	function setInitGroupTreeData(isloadMyDept){
		var domain = $("#companySelect").val();
		var groupType = $(":input:radio[name=groupTypeRadio]:checked").val();
		
		setGroupTreeConfig();
		
		$.ajax({
			url:"/covicore/control/getInitOrgTreeList.do",
			type:"POST",
			data:{
				"loadMyDept" : isloadMyDept,
				"companyCode" : domain,
				"groupType" : groupType,
				"groupDivision":$this.config.groupDivision,
				"communityId":$this.config.communityId
			},
			async:false,
			success:function (data) {
				$this.groupTree.setList( data.list );
				if(isloadMyDept == "Y"){
					loadMyDept();
				}else{
					$this.groupTree.expandAll(1)
				}
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getInitOrgTreeList.do", response, status, error);
			},
		});

		$this.groupTree.displayIcon(false); //Icon에 checkbox 가려지는 현상 제거
	}
	
	//하위 항목 조회
	function getChildrenData(idx, item){
		var domain = $("#companySelect").val();
		var groupType = $(":input:radio[name=groupTypeRadio]:checked").val();
		
		$.ajax({
			url:"/covicore/control/getChildrenData.do",
			type:"POST",
			data:{
				"memberOf" : item.AN,
				"companyCode" : domain,
				"groupType" : groupType,
				"groupDivision":$this.config.groupDivision,
				"communityId":$this.config.communityId
			},
			async:false,
			success:function (data) {
				$this.groupTree.appendTree(idx, item, data.list);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getChildrenData.do", response, status, error);
			},
		});
	}
	
	//검색버튼 클릭
	function search(){
		if( $("#searchText").val() == ''){ 
			Common.Warning(orgDic["msg_EnterSearchword"]); //검색어를 입력해주세요
			$("#searchText").focus()
			return;
		}
		if($("#searchTypeSelect").val() == "phone" && $("#searchText").val().replace('-','') == "010") {
			Common.Warning("010 을 제외한 최소 1자리 수를 입력해주세요");
			$("#searchText").focus();
			return;
		}
		if($("#searchTypeSelect").val() == "phone") {
			if($("#searchText").val() == "01" || $("#searchText").val() == "10") {
				Common.Warning("01, 10 을 제외한 2자리 수를 입력해주세요");
				$("#searchText").focus();
				return;
			}
		} else if($("#searchTypeSelect").val() == "phone" && $("#searchText").val().length < 2) {
			Common.Warning("최소 2자리 수를 입력해주세요");
			$("#searchText").focus();
			return;
		}
		
		searchKeyword = $("#searchText").val();
		
		$("#hasChildGroup").attr("checked", false);  //검색 시에는 하위 부서 포함 X
		
		var params = new Object();
		//$("#allchk").attr("checked", false);
		
	/*	if (searchType == "deptName") {
			url = "/covicore/control/getDeptList.do";
			params.companyCode = $("#companySelect").val();
			params.groupType = 'dept' //부서 검색 (고정값)
		} else {*/
			var url = "/covicore/control/getUserList.do";
			params.companyCode = $("#companySelect").val();
			params.searchType = $("#searchTypeSelect").val();
			params.searchText = $("#searchText").val();
			params.hasChildGroup = $("#hasChildGroup").prop("checked") ? "Y" : "N";
			params.groupType = 'dept'; //검색 시 고정
			params.useAttendStatus = useAttendStatusInOrgChart;
			// params.groupType =  $(":input:radio[name=groupTypeRadio]:checked").val();
		/*}*/
		
		$.ajax({
			url: url,
			type:"post",
			data: params,
			success:function (data) {
			/*	if (searchType == "deptName") {
					setMemberList(data,"schDept");
				} else {*/
					setMemberList(data,"search");
	/*			}*/
				
				$("#groupPathList").empty();			// 조회된 후 선택부서TEXT 초기화		
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	

	
	// 각 부서에 해당하는 사원들 리스트 HTML 바인딩
	function setMemberList(data,pMode){
		if($this.config.drawOpt.charAt(1)!="M")
			return;
		
		var viewType = $("a[name='viewType'][class~='active']").attr("value"); // viewType (listType: 목록형, split: 분할형, cardType: 카드형)
		//var viewType = "split";
		var strData ="";
		var profilData = "";
		var temp = $("div#profileDiv");
		if(data.list.length == 0 || data.list.length == null){
			var con = document.getElementById("profileDiv");
			
			
			strData = ' <div class="tdRelBlock" style="margin-left:45px;" ><div class="bodyNode bodyTdText"  align="center">' + orgDic["msg_NoDataList"]+ '</div></div>'; //조회할 목록이 없습니다.
			
			 if(con.style.display!='none'){
		    	 con.style.display = 'none';			
		    }

			if(viewType=="splitType"||viewType=="cardType"){//분할형,카드형 조회목록이없는 부서로 이동시(리스트형으로 변경)			
				$("#orgScroll").attr('class','mScrollV scrollVType01 mCustomScrollbar _mCS_2 mCS_no_scrollbar');
				$("#addType").attr('class','org_view_wrap');
			}
			
		   			
		}else{					
			var listClass = '';			
		
			if(viewType =="listType"){//목록형, 분할형, 카드형선택시 리스트화면전환
				listClass = 'org_view_list01';
				$("#addType").removeClass("type02");
				$("#orgScroll").removeClass("org_view_list02_wrap");				
				deleteClass();
				$("#profileDiv").hide();
			}else if(viewType =="splitType"){
				listClass ='org_view_list02';
				deleteClass();
				$("#addType").addClass("type02");
				$("#orgScroll").addClass("org_view_list02_wrap");
				$("#profileDiv").show();				
			}else if(viewType =="cardType"){
				$("#addType").removeClass("type02");
				$("#addType").addClass("type03");
				$("#addType").addClass("mScrollV");
				$("#addType").addClass("scrollVType01");
				$("#orgScroll").removeClass("org_view_list02_wrap");
				listClass ='org_view_list03';			
				$("#profileDiv").hide();
			}			
		
			strData += '<ul class="'+listClass+'" id="orgSearchList" >';			

			$(data.list).each(function(index){
				var PO = "";
				var TL = "";
				var LV = "";
				var reason = "";
				
				TL = isEmptyDefault(CFN_GetDicInfo(this.TL.split("|")[1],lang), "");
				PO = isEmptyDefault(CFN_GetDicInfo(this.PO.split("|")[1],lang), "");
				LV = isEmptyDefault(CFN_GetDicInfo(this.LV.split("|")[1],lang), "");
				if(CFN_GetDicInfo(this.TL.split("|")[1],lang).charAt(0) == " "){
					TL = CFN_GetDicInfo(this.TL.split("|")[1],lang).replace(/ /gi, "");
				}
				
				if(CFN_GetDicInfo(this.PO.split("|")[1],lang).charAt(0) == " "){
					PO = CFN_GetDicInfo(this.PO.split("|")[1],lang).replace(/ /gi, "");
				}
				
				if(CFN_GetDicInfo(this.LV.split("|")[1],lang).charAt(0) == " "){
					LV = CFN_GetDicInfo(this.LV.split("|")[1],lang).replace(/ /gi, "");
				}
				
				if (pMode == "schDept") {
					 //TODO 부서 검색
				} else { //pMode == 'search' or 'undefined'
					if(viewType == "listType"){
						strData += '<li class="hg">';
						strData += ' 	<a style="cursor:default">';
						strData += '		<div class="user_info">';
						strData += '  			<span class="photo"><img src="' + coviCmn.loadImage(this.PhotoPath) + '" onerror="coviOrgA0.imgError(this);" ></span>';
						
			        	var sMultiRepJobTypeConfig = Common.getBaseConfig("MultiRepJobType");
				        var sMultiRepJobType = "";
						if(sMultiRepJobTypeConfig != null && sMultiRepJobTypeConfig != ""){
							sMultiRepJobTypeConfig.split(";").forEach(function(e){
								if(e == "PN"){
								    if(PO == "-" || PO != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += PO;
									}
						        } 
								else if(e == "LN"){
									if(LV == "-" || LV != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += LV;
									}
						        }
								else if(e == "TN"){
									if(TL == "-" || TL != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += TL;
									}
						        }
							});
						} else {
							if(TL == "-" || TL != ""){
								sMultiRepJobType += TL;
							}
							if(PO == "-" || PO != ""){
								if(sMultiRepJobType != ""){
									sMultiRepJobType += "/";
								}
								sMultiRepJobType += PO;
							}
						}
						
						strData += '	 			<span class="tx_name ellip" onclick="coviOrgA0.goUserInfoPopup(\''+this.AN+'\'); return false;" style="cursor:pointer">'+CFN_GetDicInfo(this.DN,lang) + (sMultiRepJobType == "" ? "" : ' (' + sMultiRepJobType + ')') + '</span>';
						
						if(this.JobType == "AddJob"){
							strData += '	  			<span class="tx_team ellip" title="' + CFN_GetDicInfo(this.RGNM,lang) + '"><span style="color:blue">[' + orgDic["lbl_AddJob"] + ']</span>' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						} else if(this.JobType == "DisJob"){
							strData += '	  			<span class="tx_team ellip" title="' + CFN_GetDicInfo(this.RGNM,lang) + '"><span style="color:red">[' + orgDic["lbl_DisJob"] + ']</span>' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						} else{
							strData += '	  			<span class="tx_team ellip">' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						}
						
						if (useAttendStatusInOrgChart == 'Y'){
							if (this.VacStatus && this.VacStatus !="") {
								strData += '	  		<span class="tx_state tx_state02">'+Common.getBaseCodeDic('VACATION_TYPE', this.VacStatus)+'</span>';
							}
							else {
								if (this.AttendStatus == "lbl_att_offWork") {
									// 퇴근 표기는 휴가와 동일하게 설정
									strData += '	  		<span class="tx_state tx_state02">'+orgDic[this.AttendStatus]+'</span>';
								}
								else {
									if (this.JobStatus) {
										var job = this.JobStatus.split(';');
										reason = job[3];
										// 외근과 출장은 기타근무로 동일함. 필요시 근무코드를 분기하여 처리. 출장 tx_state03, 외근 tx_state01
										strData += '	  		<span class="tx_state tx_state03">'+job[0]+'</span>';
									}
									else {
										if (this.AttendStatus == "lbl_n_att_absent") {
											// 외근 정보 없이 등록된 타각이 없는 경우, 결근으로 최종 간주
											strData += '	  		<span class="tx_state tx_state04">'+orgDic[this.AttendStatus]+'</span>';
										}
									}
								}
							}
						}
						if(this.AbsenseUseYN == 'Y'){
							strData += '		<span class="etc out collabo_help02">' //부재
							strData += '			<div class="absentDataBox helppopup">';
							if(this.AbsenseType != "") 		
							strData += '				<span class="tx_ex">'+orgDic["lbl_AbsentType"]+'</span>'+Common.getDic("AbsenseType_"+this.AbsenseType)+'<br>';
							if(this.AbsenseTermStart != "") 
							strData += '				<span class="tx_ex">'+orgDic["lblAbsentTerm"]+'</span>'+this.AbsenseTermStart+'~'+this.AbsenseTermEnd+'<br>';
							if(this.AbsenseDuty != "")		
							strData += '				<span class="tx_ex">'+orgDic["lbl_AbsentDuty"]+'</span>'+CFN_GetDicInfo(this.AbsenseDuty,lang)+'<br>';
							if(this.AbsenseReason != "") 	
							strData += '				<span class="tx_ex">'+orgDic["lblAbsentReason"]+'</span>'+this.AbsenseReason+'<br>';
							strData += '			</div>';
							strData += '		</span>';
						}
						strData += '		</div>';
						strData += '		<span class="tx_info01">';
						strData += '			<dl>';
						strData += '				<dt>' + orgDic["lbl_MobilePhone"]+ '</dt>'; //핸드폰
						strData += '				<dd class="ellip">'+isEmptyDefault(this.MT,'')+'</dd>';
						strData += '			</dl>';
						strData += '			<dl>';
						strData += '				<dt>' + orgDic["lbl_CompanyNumber"] + '</dt>'; //회사번호
						strData += '				<dd class="ellip">'+isEmptyDefault(this.OT,'')+'</dd>';
						strData += '			</dl>';
						if (useAttendStatusInOrgChart == 'Y'){
							strData += '			<dl>'; 
							strData += '				<dt>' + orgDic["lbl_Place"] +'/' + orgDic["lbl_Reason"] + '</dt>'; //장소/사유
							strData += '				<dd class="ellip">'+reason+'</dd>';
							strData += '			</dl>';
						}
						strData += '		</span>';
						strData += '		<span class="tx_info02">';
						strData += '			<dl>';
						strData += '				<dt>' + orgDic["lbl_apv_appMail"]+ '</dt>'; //메일
						strData += '				<dd class="ellip">'+isEmptyDefault(this.EM,'')+'</dd>';
						strData += '			</dl>';
						strData += '			<dl>'; 
						strData += '				<dt>' + orgDic["lbl_Role"]+ '</dt>'; //담당업무
						strData += '				<dd class="ellip">'+CFN_GetDicInfo(isEmptyDefault(this.ChargeBusiness,''),lang)+'</dd>';
						strData += '			</dl>';
						strData += '		</span>';
						strData += '  </a>';
						strData += '</li>';
					}
					else if(viewType == "splitType"){
						strData += '<li>';
						
						if(index==changeIndex){
							strData += '	<a class="selected" id="userSplitType" onclick="coviOrgA0.indexChenge('+index+'); return false;">';
							strData += '		<div class="user_info">';
							strData += '  			<span class="photo"><img src="'+coviCmn.loadImage(this.PhotoPath)+'" onerror="coviOrgA0.imgError(this);" ></span>';
							
				        	var sMultiRepJobTypeConfig = Common.getBaseConfig("MultiRepJobType");
					        var sMultiRepJobType = "";
							if(sMultiRepJobTypeConfig != null && sMultiRepJobTypeConfig != ""){
								sMultiRepJobTypeConfig.split(";").forEach(function(e){
									if(e == "PN"){
									    if(PO == "-" || PO != ""){
											if(sMultiRepJobType != ""){
												sMultiRepJobType += "/";
											}
											sMultiRepJobType += PO;
										}
							        } 
									else if(e == "LN"){
										if(LV == "-" || LV != ""){
											if(sMultiRepJobType != ""){
												sMultiRepJobType += "/";
											}
											sMultiRepJobType += LV;
										}
							        }
									else if(e == "TN"){
										if(TL == "-" || TL != ""){
											if(sMultiRepJobType != ""){
												sMultiRepJobType += "/";
											}
											sMultiRepJobType += TL;
										}
							        }
								});
							} else {
								if(TL == "-" || TL != ""){
									sMultiRepJobType += TL;
								}
								if(PO == "-" || PO != ""){
									if(sMultiRepJobType != ""){
										sMultiRepJobType += "/";
									}
									sMultiRepJobType += PO;
								}
							}
							
							strData += '	 			<span class="tx_name ellip">'+CFN_GetDicInfo(this.DN,lang) + (sMultiRepJobType == "" ? "" : ' (' + sMultiRepJobType + ')') + '</span>';
							
							if(this.JobType == "AddJob"){
								strData += '	  			<span class="tx_team ellip" title="' + CFN_GetDicInfo(this.RGNM,lang) + '"><span style="color:blue">[' + orgDic["lbl_AddJob"] + ']</span>' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
							} else if(this.JobType == "DisJob"){
								strData += '	  			<span class="tx_team ellip" title="' + CFN_GetDicInfo(this.RGNM,lang) + '"><span style="color:red">[' + orgDic["lbl_DisJob"] + ']</span>' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
							} else{
								strData += '	  			<span class="tx_team ellip">' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
							}
							
							if (useAttendStatusInOrgChart == 'Y'){
								if (this.VacStatus && this.VacStatus !="") {
									strData += '	  		<span class="tx_state tx_state02">'+Common.getBaseCodeDic('VACATION_TYPE', this.VacStatus)+'</span>';
								}
								else {
									if (this.AttendStatus == "lbl_att_offWork") {
										// 퇴근 표기는 휴가와 동일하게 설정
										strData += '	  		<span class="tx_state tx_state02">'+orgDic[this.AttendStatus]+'</span>';
									}
									else {
										if (this.JobStatus) {
											var job = this.JobStatus.split(';');
											reason = job[3];
											// 외근과 출장은 기타근무로 동일함. 필요시 근무코드를 분기하여 처리. 출장 tx_state03, 외근 tx_state01
											strData += '	  		<span class="tx_state tx_state03">'+job[0]+'</span>';
										}
										else {
											if (this.AttendStatus == "lbl_n_att_absent") {
												// 외근 정보 없이 등록된 타각이 없는 경우, 결근으로 최종 간주
												strData += '	  		<span class="tx_state tx_state04">'+orgDic[this.AttendStatus]+'</span>';
											}
										}
									}
								}
							}
							if(this.AbsenseUseYN == 'Y'){
								strData += '		<span class="etc out">' + orgDic["lbl_com_Absense"]+ '</span>'; //부재
							}
						strData += '		</div>';						
						strData += '	</a>';
						if(this.AbsenseUseYN == 'Y'){
							profilData += '		<span class="etc out collabo_help02">' //부재
							profilData += '			<div class="absentDataBox helppopup">';
							if(this.AbsenseType != "") 		
							profilData += '				<span class="tx_ex">'+orgDic["lbl_AbsentType"]+'</span>'+Common.getDic("AbsenseType_"+this.AbsenseType)+'<br>';
							if(this.AbsenseTermStart != "") 
							profilData += '				<span class="tx_ex">'+orgDic["lblAbsentTerm"]+'</span>'+this.AbsenseTermStart+'~'+this.AbsenseTermEnd+'<br>';
							if(this.AbsenseDuty != "")		
							profilData += '				<span class="tx_ex">'+orgDic["lbl_AbsentDuty"]+'</span>'+CFN_GetDicInfo(this.AbsenseDuty,lang)+'<br>';
							if(this.AbsenseReason != "") 	
							profilData += '				<span class="tx_ex">'+orgDic["lblAbsentReason"]+'</span>'+this.AbsenseReason+'<br>';
							profilData += '			</div>';
							profilData += '		</span>';
						}
						var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
				        var sRepJobType = LV;
				        if(sRepJobTypeConfig == "PN"){
				        	sRepJobType = PO;
				        } else if(sRepJobTypeConfig == "TN"){
				        	sRepJobType = TL;
				        } else if(sRepJobTypeConfig == "LN"){
				        	sRepJobType = LV;
				        }
						
						profilData += '		<div class="org_view nameCard">';
						profilData += '			<a style="cursor:default">';
						profilData += '  			<div class="photoArea"><img src="'+coviCmn.loadImage(this.PhotoPath)+'" onerror="coviOrgA0.imgError(this);" onload="coviOrgA0.loadPhotoArea(this)"></div>';
						profilData += '				<dl class="infoArea">';
						profilData += '					<dt onclick="coviOrgA0.goUserInfoPopup(\''+this.AN+'\'); return false;" style="cursor:pointer"><strong>'+CFN_GetDicInfo(this.DN,lang)+'</strong>'+ sRepJobType +'</dt>';
						profilData += ' 					<dd class="division">'+CFN_GetDicInfo(this.RGNM,lang)+'</dd>';
						profilData += '				</dl>';
						profilData += '			</a>';
						profilData += '		</div>';
						/*profilData += '			<ul class="profileCommuList clearFloat">';
						profilData += '				<li class="profileCommuList01"><a>메일</a></li>';
						profilData += '				<li class="profileCommuList02"><a>와이파이</a></li>';
						profilData += '				<li class="profileCommuList03"><a id="sendTalk">말풍선</a></li>';
						profilData += '				<li class="profileCommuList04"><a id="addNumber">추가</a></li>';
						profilData += '			</ul>';*/
						profilData += '			<div class="rowTypeWrap contDetail">';
				        var sJobTypeUses = Common.getBaseConfig("JobTypeUses");
				        if(sJobTypeUses != null && sJobTypeUses != ""){
					        if(sJobTypeUses.indexOf("PN") > -1){
								profilData += '				<dl>';
								profilData += '					<dt>' + orgDic["lbl_JobPosition"]+ '</dt>';
								profilData += '					<dd>'+ CFN_GetDicInfo(this.PO.split("|")[1],lang)+ '</dt>';
								profilData += '				</dl>'
					        }
					        if(sJobTypeUses.indexOf("LN") > -1){
								profilData += '				<dl>';
								profilData += '					<dt>' + orgDic["lbl_JobLevel"]+ '</dt>';
								profilData += '					<dd>'+ CFN_GetDicInfo(this.LV.split("|")[1],lang)+ '</dt>';
								profilData += '				</dl>'
					        }
					        if(sJobTypeUses.indexOf("TN") > -1){
								profilData += '				<dl>';
								profilData += '					<dt>' + orgDic["lbl_JobTitle"]+ '</dt>';
								profilData += '					<dd>'+ CFN_GetDicInfo(this.TL.split("|")[1],lang)+ '</dt>';
								profilData += '				</dl>';
					        }
				        } else {
							profilData += '				<dl>';
							profilData += '					<dt>' + orgDic["lbl_JobTitle"]+ '</dt>';
							profilData += '					<dd>'+ CFN_GetDicInfo(this.TL.split("|")[1],lang)+ '</dt>';
							profilData += '				</dl>';
							profilData += '				<dl>';
							profilData += '					<dt>' + orgDic["lbl_JobPosition"]+ '</dt>';
							profilData += '					<dd>'+ CFN_GetDicInfo(this.PO.split("|")[1],lang)+ '</dt>';
							profilData += '				</dl>';
				        }
						profilData += '				<dl>';
						profilData += '					<dt>' + orgDic["lbl_Role"]+ '</dt>';//담당업무
						profilData += '					<dd>'+CFN_GetDicInfo(isEmptyDefault(this.ChargeBusiness,''),lang).replace('|','<br>').replace('|','<br>').replace('|','<br>').replace('|','<br>')+'</dt>';
						profilData += '				</dl>';
						profilData += '				<dl>';
						profilData += '					<dt>' + orgDic["lbl_apv_appMail"]+ '</dt>';//메일
						profilData += '					<dd>'+isEmptyDefault(this.EM,'')+'</dt>';
						profilData += '				</dl>';
						profilData += '				<dl>';
						profilData += '					<dt>' + orgDic["lbl_CompanyNumber"] + '</dt>';//회사번호
						profilData += '					<dd>'+isEmptyDefault(this.OT,'')+'</dt>';
						profilData += '				</dl>';
						profilData += '				<dl>';
						profilData += '					<dt>' + orgDic["lblOfficeCall"] + '</dt>';
						profilData += '					<dd>' + isEmptyDefault(this.PhoneNumberInter,'') + '</dd>';
						profilData += '				</dl>';
						profilData += '				<dl>';
						profilData += '					<dt>' + orgDic["lbl_MobilePhone"]+ '</dt>';//핸드폰
						profilData += '					<dd>'+isEmptyDefault(this.MT,'')+'</dt>';
						profilData += '				</dl>';
						if (useAttendStatusInOrgChart == 'Y'){
							profilData += '				<dl>'; 
							profilData += '					<dt>' + orgDic["lbl_Place"] +'/' + orgDic["lbl_Reason"] + '</dt>'; //장소/사유
							profilData += '					<dd>'+reason+'</dd>';
							profilData += '				</dl>';		
						}								
						profilData += '			</div >';
						profilData += '		</div>';
						}else{
						strData += '	<a id="userSplitType"  onclick="coviOrgA0.indexChenge('+index+')">';
						strData += '		<div class="user_info">';
						strData += '  			<span class="photo"><img src="'+coviCmn.loadImage(this.PhotoPath)+'" onerror="coviOrgA0.imgError(this);" ></span>';
						//strData += '	 			<span class="tx_name ellip" onclick="coviOrgA0.indexChenge('+index+')">'+CFN_GetDicInfo(this.DN,lang)+ ' ('+ CFN_GetDicInfo(this.TL.split("|")[1],lang)+ ', '+ CFN_GetDicInfo(this.PO.split("|")[1],lang) +')</span>';
						
			        	var sMultiRepJobTypeConfig = Common.getBaseConfig("MultiRepJobType");
				        var sMultiRepJobType = "";
						if(sMultiRepJobTypeConfig != null && sMultiRepJobTypeConfig != ""){
							sMultiRepJobTypeConfig.split(";").forEach(function(e){
								if(e == "PN"){
								    if(PO == "-" || PO != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += PO;
									}
						        } 
								else if(e == "LN"){
									if(LV == "-" || LV != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += LV;
									}
						        }
								else if(e == "TN"){
									if(TL == "-" || TL != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += TL;
									}
						        }
							});
						} else {
							if(TL == "-" || TL != ""){
								sMultiRepJobType += TL;
							}
							if(PO == "-" || PO != ""){
								if(sMultiRepJobType != ""){
									sMultiRepJobType += "/";
								}
								sMultiRepJobType += PO;
							}
						}
						
						strData += '	 			<span class="tx_name ellip">'+CFN_GetDicInfo(this.DN,lang) + (sMultiRepJobType == "" ? "" : ' (' + sMultiRepJobType + ')') + '</span>';
						
						if(this.JobType == "AddJob"){
							strData += '	  			<span class="tx_team ellip" title="' + CFN_GetDicInfo(this.RGNM,lang) + '"><span style="color:blue">[' + orgDic["lbl_AddJob"] + ']</span>' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						} else if(this.JobType == "DisJob"){
							strData += '	  			<span class="tx_team ellip" title="' + CFN_GetDicInfo(this.RGNM,lang) + '"><span style="color:red">[' + orgDic["lbl_DisJob"] + ']</span>' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						} else{
							strData += '	  			<span class="tx_team ellip">' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						}
						
						if (useAttendStatusInOrgChart == 'Y'){
							if (this.VacStatus && this.VacStatus !="") {
								strData += '	  		<span class="tx_state tx_state02">'+Common.getBaseCodeDic('VACATION_TYPE', this.VacStatus)+'</span>';
							}
							else {
								if (this.AttendStatus == "lbl_att_offWork") {
									// 퇴근 표기는 휴가와 동일하게 설정
									strData += '	  		<span class="tx_state tx_state02">'+orgDic[this.AttendStatus]+'</span>';
								}
								else {
									if (this.JobStatus) {
										var job = this.JobStatus.split(';');
										reason = job[3];
										// 외근과 출장은 기타근무로 동일함. 필요시 근무코드를 분기하여 처리. 출장 tx_state03, 외근 tx_state01
										strData += '	  		<span class="tx_state tx_state03">'+job[0]+'</span>';
									}
									else {
										if (this.AttendStatus == "lbl_n_att_absent") {
											// 외근 정보 없이 등록된 타각이 없는 경우, 결근으로 최종 간주
											strData += '	  		<span class="tx_state tx_state04">'+orgDic[this.AttendStatus]+'</span>';
										}
									}
								}
							}
						}
						if(this.AbsenseUseYN == 'Y'){
							strData += '		<span class="etc out">' + orgDic["lbl_com_Absense"]+ '</span>'; //부재
						}
						strData += '		</div>';						
						strData += '	</a>';
						strData += '</li>';
						}						
					}else if(viewType == "cardType"){						
						strData += '<li>';
						strData += ' 	<a style="cursor:default">';
						strData += '		<div class="user_info" >';
						strData += '  			<span class="photo"><img src="'+coviCmn.loadImage(this.PhotoPath)+'" onerror="coviOrgA0.imgError(this);" ></span>';
						
			        	var sMultiRepJobTypeConfig = Common.getBaseConfig("MultiRepJobType");
				        var sMultiRepJobType = "";
						if(sMultiRepJobTypeConfig != null && sMultiRepJobTypeConfig != ""){
							sMultiRepJobTypeConfig.split(";").forEach(function(e){
								if(e == "PN"){
								    if(PO == "-" || PO != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += PO;
									}
						        } 
								else if(e == "LN"){
									if(LV == "-" || LV != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += LV;
									}
						        }
								else if(e == "TN"){
									if(TL == "-" || TL != ""){
										if(sMultiRepJobType != ""){
											sMultiRepJobType += "/";
										}
										sMultiRepJobType += TL;
									}
						        }
							});
						} else {
							if(TL == "-" || TL != ""){
								sMultiRepJobType += TL;
							}
							if(PO == "-" || PO != ""){
								if(sMultiRepJobType != ""){
									sMultiRepJobType += "/";
								}
								sMultiRepJobType += PO;
							}
						}
						
						strData += '	 			<span class="tx_name ellip" onclick="coviOrgA0.goUserInfoPopup(\''+this.AN+'\'); return false;" style="cursor:pointer">'+CFN_GetDicInfo(this.DN,lang) + (sMultiRepJobType == "" ? "" : ' (' + sMultiRepJobType + ')') + '</span>';
						
						if(this.JobType == "AddJob"){
							strData += '	  			<span class="tx_team ellip" title="' + CFN_GetDicInfo(this.RGNM,lang) + '"><span style="color:blue">[' + orgDic["lbl_AddJob"] + ']</span>' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						} else if(this.JobType == "DisJob"){
							strData += '	  			<span class="tx_team ellip" title="' + CFN_GetDicInfo(this.RGNM,lang) + '"><span style="color:red">[' + orgDic["lbl_DisJob"] + ']</span>' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						} else{
							strData += '	  			<span class="tx_team ellip">' + CFN_GetDicInfo(this.RGNM,lang) + ' (' + CFN_GetDicInfo(this.ETNM,lang) + ')' + '</span>';
						}
						
						if (useAttendStatusInOrgChart == 'Y'){
							if (this.VacStatus && this.VacStatus !="") {
								strData += '	  		<span class="tx_state tx_state02">'+Common.getBaseCodeDic('VACATION_TYPE', this.VacStatus)+'</span>';
							}
							else {
								if (this.AttendStatus == "lbl_att_offWork") {
									// 퇴근 표기는 휴가와 동일하게 설정
									strData += '	  		<span class="tx_state tx_state02">'+orgDic[this.AttendStatus]+'</span>';
								}
								else {
									if (this.JobStatus) {
										var job = this.JobStatus.split(';');
										reason = job[3];
										// 외근과 출장은 기타근무로 동일함. 필요시 근무코드를 분기하여 처리. 출장 tx_state03, 외근 tx_state01
										strData += '	  		<span class="tx_state tx_state03">'+job[0]+'</span>';
									}
									else {
										if (this.AttendStatus == "lbl_n_att_absent") {
											// 외근 정보 없이 등록된 타각이 없는 경우, 결근으로 최종 간주
											strData += '	  		<span class="tx_state tx_state04">'+orgDic[this.AttendStatus]+'</span>';
										}
									}
								}
							}
						}
						if(this.AbsenseUseYN == 'Y'){
							strData += '		<span class="etc out collabo_help02">' //부재
							strData += '			<div class="absentDataBox helppopup">';
							if(this.AbsenseType != "") 		
							strData += '				<span class="tx_ex">'+orgDic["lbl_AbsentType"]+'</span>'+Common.getDic("AbsenseType_"+this.AbsenseType)+'<br>';
							if(this.AbsenseTermStart != "") 
							strData += '				<span class="tx_ex">'+orgDic["lblAbsentTerm"]+'</span>'+this.AbsenseTermStart+'~'+this.AbsenseTermEnd+'<br>';
							if(this.AbsenseDuty != "")		
							strData += '				<span class="tx_ex">'+orgDic["lbl_AbsentDuty"]+'</span>'+CFN_GetDicInfo(this.AbsenseDuty,lang)+'<br>';
							if(this.AbsenseReason != "") 	
							strData += '				<span class="tx_ex">'+orgDic["lblAbsentReason"]+'</span>'+this.AbsenseReason+'<br>';
							strData += '			</div>';
							strData += '		</span>';
						}
						strData += '		</div>';
						strData += '		<span class="tx_info01">';
						strData += '			<dl>';
						strData += '				<dt>' + orgDic["lbl_MobilePhone"]+ '</dt>'; //핸드폰
						strData += '				<dd class="ellip">'+isEmptyDefault(this.MT,'')+'</dd>';
						strData += '			</dl>';
						strData += '			<dl>';
						strData += '				<dt>' + orgDic["lbl_CompanyNumber"] + '</dt>'; //회사번호
						strData += '				<dd class="ellip">'+isEmptyDefault(this.OT,'')+'</dd>';
						strData += '			</dl>';					
						strData += '			<dl>';
						strData += '				<dt>' + orgDic["lbl_apv_appMail"]+ '</dt>'; //메일
						strData += '				<dd class="ellip">'+isEmptyDefault(this.EM,'')+'</dd>';
						strData += '			</dl>';
						strData += '			<dl>'; 
						strData += '				<dt>' + orgDic["lbl_Role"]+ '</dt>'; //담당업무
						strData += '				<dd class="ellip">'+CFN_GetDicInfo(isEmptyDefault(this.ChargeBusiness,''),lang)+'</dd>';
						strData += '			</dl>';
						if (useAttendStatusInOrgChart == 'Y'){
							strData += '			<dl>'; 
							strData += '				<dt>' + orgDic["lbl_Place"] +'/' + orgDic["lbl_Reason"] + '</dt>'; //장소/사유
							strData += '				<dd class="ellip">'+reason+'</dd>';
							strData += '			</dl>';
						}
						strData += '		</span>';
						strData += '  </a>';
						strData += '</li>';
					}
				}
			});
			
			strData += '</ul>';
			
		}

		$("#orgSearchListDiv").html(strData);
		$("#profileDiv").html(profilData);
		
		setAbsentData();
	}	
	
	function deleteClass(){		
		$("#addType").removeClass("type03");
		$("#addType").removeClass("mScrollV");
		$("#addType").removeClass("scrollVType01");
		$("#addType").removeClass("mCustomScrollbar");
		$("#addType").removeClass("_mCS_4");
		$("#addType").removeClass("mCS_no_scrollbar");
	}
	
	
	function setViewChart(){//마지막으로 조회한(리스트형,분할형,카트형)페이지 쿠키저장
		var viewType = coviCmn.getCookie("orgChartViewTypeCookie");		
		var orgViewType = Common.getBaseConfig("orgViewType");
		
		if(viewType != undefined && viewType != ''){
			$("a[name='viewType'][value='"+viewType+"']").addClass('active');
		}else if(orgViewType != ""){
			$("a[name='viewType'][value='"+orgViewType+"']").addClass('active');
		}else{
			$("a[name='viewType'][value='listType']").addClass('active');
		}
		
	}
	
	//화면 로드 시 사용자의 부서 로드
	function loadMyDept(){
		
		//var companyCode = Common.getSession("DN_Code");		//companyCode로 명칭 변경
		var deptID = selectDeptCode == "" ? sessionObj["DEPTID"] : selectDeptCode;
		selectDeptCode = deptID;
		
		if($this.config.drawOpt.charAt(0)=="L"){
			//$('#companySelect').bindSelectSetValue(companyCode);
			//$('#companySelect').val(companyCode);
			
			$this.groupTree.expandAll(1)	// tree의 depth 1만 open
		
			var selectedIndex = "";
			$($this.groupTree.list).each(function(i,obj){
				if(deptID == obj.GroupCode){
					$this.groupTree.click(obj.__index,'open');
					selectedIndex = obj.__index;
					//$this.getUserOfGroupList(obj.GroupCode);
				}
			});
			
			// 자신의 부서만 선택 표시
			if(selectedIndex != "") {
				$('.gridBodyTr').not(".gridBodyTr_" + selectedIndex).removeClass("selected");
			}
		}
	}
	
	function setGroupInfo(deptCode){
		
		var groupPath = new Array();
		var groupNamePath = new Array();
		var startIndex = 0 
		var strHtml = '';
		
		$("#groupPathList").empty();
		
		$($this.groupTree.list).each(function(i,obj){
			if(deptCode == obj.GroupCode){
				groupPath = obj.GroupPath.split(";");
				groupNamePath = obj.GroupFullPath.split(">");
				return false;
			}
		});
	
		startIndex =  (  groupPath.indexOf($("#companySelect").val()) < 0 ? 0 : groupPath.indexOf($("#companySelect").val()) );
		
		groupPath = groupPath.slice(startIndex, groupPath.length);
		groupNamePath = groupNamePath.slice(startIndex, groupNamePath.length);
		
		$.each(groupNamePath,function(idx,obj){
			strHtml += '<li code="' + groupPath[idx] + '"><a>' + obj + '</a></li>';
		});
		
		$("#groupPathList").html(strHtml);
		
		$("#groupPathList>li").click(function(e){
			var code = $(e.currentTarget).attr("code")
			$($this.groupTree.list).each(function(i,obj){
				if(code == obj.GroupCode){
					$this.groupTree.click(obj.__index,'open');	
					//$this.getUserOfGroupList(obj.GroupCode);
				}
			});
		});

	}
	

	//초기 설정 값 셋팅 시 빈값 확인
	function isEmpty(value){
		  return (value == undefined || value == 'undefined');
	}
	
	
	//초기 설정 값 셋팅 시 빈값 확인
	function isEmptyDefault(value, defaultVal){
		  if(value == undefined || value == 'undefined'){
			  return defaultVal;
		  }
		  return value;
	}
	
	//JSON Object to String 
	function jsonToString(jsonObj){
		if(jsonObj != undefined && jsonObj != ''){
			var jsonStr = Object.toJSON(jsonObj);
			
			//특수 문자 처리
			jsonStr = jsonStr.replaceAll("'", "&#39;");
			
			return jsonStr;
		}
	}
	
	//부재 정보 세팅
	function setAbsentData(){
		var absentDataList = [];
		
		$(".etc.out.collabo_help02").prepend('<a href="javascript:void(0);" class="help_ico absentIcon" style="border:none"></a>'); 
		$(".etc.out.collabo_help02").prepend(orgDic["lbl_com_Absense"]); //부재

		$(".absentIcon").mouseover(function() {
			$(this).toggleClass("active");
		});
		
		$(".absentIcon").mouseout(function() {
			$(this).toggleClass("active");
		});
	}
	
	return coviOrgObj;
	
}());