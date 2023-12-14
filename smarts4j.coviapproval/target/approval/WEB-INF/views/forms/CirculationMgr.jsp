<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script>

	var myDeptTree = new coviTree();
	var tempWord = ""
	var FormInstID = getInfo("FormInstanceInfo.FormInstID");
	var ProcessID = getInfo("ProcessInfo.ProcessID");
	var usid = getInfo("AppInfo.usid");
	var usnm = getInfo("AppInfo.usnm");
	var dpid = getInfo("AppInfo.dpid");
	var dpdn = getInfo("AppInfo.dpdn");
	var FormName = getInfo("FormInfo.FormName");
	var FormPrefix = getInfo("FormInfo.FormPrefix");
	var Subject = getInfo("FormInstanceInfo.Subject");
	
	//JWF_CirculationBoxDescription
	var FormID = getInfo("ProcessInfo.ProcessDescription.FormID");
	var FormName = getInfo("ProcessInfo.ProcessDescription.FormName");
	var FormSubject = getInfo("ProcessInfo.ProcessDescription.FormSubject");
	var IsSecureDoc = getInfo("ProcessInfo.ProcessDescription.IsSecureDoc");
	var IsFile = getInfo("ProcessInfo.ProcessDescription.IsFile");
	var FileExt = getInfo("ProcessInfo.ProcessDescription.FileExt");
	var IsComment = getInfo("ProcessInfo.ProcessDescription.IsComment");
	var ApproverCode = getInfo("ProcessInfo.ProcessDescription.ApproverCode");
	var ApproverName = getInfo("ProcessInfo.ProcessDescription.ApproverName");
	var ApprovalStep = getInfo("ProcessInfo.ProcessDescription.ApprovalStep");
	var ApproverSIPAddress = getInfo("ProcessInfo.ProcessDescription.ApproverSIPAddress");
	var IsReserved = getInfo("ProcessInfo.ProcessDescription.IsReserved");
	var ReservedGubun = getInfo("ProcessInfo.ProcessDescription.ReservedGubun");
	//var ReservedTime = getInfo("ProcessInfo.ProcessDescription.ReservedTime")
	var Priority = getInfo("ProcessInfo.ProcessDescription.Priority");
	var IsModify = getInfo("ProcessInfo.ProcessDescription.IsModify");
	var Reserved1 = getInfo("ProcessInfo.ProcessDescription.Reserved1");
	var Reserved2 = getInfo("ProcessInfo.ProcessDescription.Reserved2");

	//JWF_CirculationBox
	var ReceiptID; //부서혹은사람ID
	var ReceiptType //부서면U 사람지정이면P(이건 클릭할 때 구분)
	var ReceiptName //부서혹은사람이름
	var Kind = "C";
	
	var ProfileImagePath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code")); //프로필 이미지 경로

// SenderID //현재접속유저아이디 usid
//SenderName 현재접속유저이름 usnm

//Subject --세션에 있음 Subject
	
	var ListGrid = new coviGrid();
	
	$(document).ready(function(){
		setSelect();
		setSearchSelect();
		setTreeData();
		setGrid();
		
		$(".bodyNodeIcon").hide();
		
		loadMyDept();
	});
	
	// 전체선택 체크박스 클릭
	$(function(){
		$('#allchk').change(function () {
			var table= $("#orgSearchList").closest('table');
			$('tbody tr td input[type="checkbox"]',table).prop('checked', $(this).prop('checked'));
		});
	});
	
	function loadMyDept(){
		var sessionObj = Common.getSession(); //전체호출
		var DN_ID = sessionObj["DN_ID"];		
		var deptID = sessionObj["DEPTID"];
		
		/* $("#domainSelect option").each(function(i,o){
		if(o.value==DN_ID){
			$('#domainSelect').bindSelectSetValue(i);
		}
		}); */
	
		$('#domainSelect').bindSelectSetValue(DN_ID);

		myDeptTree.expandAll(1)	// tree의 depth 1만 open
		
		$(myDeptTree.list).each(function(i,obj){
			if(deptID == obj.GR_Code){
				myDeptTree.click(obj.__index,'open');	
				getOrgMapListData(obj.GR_Code);
			}
		});
	}
	
	//검색용 selectbox 초기화
	function setSearchSelect(){
		$("#searchWord").bindSelector({
			reserveKeys: {
				optionValue: "value",
				optionText: "text"
			},
			minHeight:1000,
			ajaxAsync:false,
			appendable:false,
			onsearch     : function(objID, objVal, callBack) {                            // {Function} - 값 변경 이벤트 콜백함수 (optional)
				// 유저 검색일 경우만
				if($("#searchType option:selected").val() == "dept"){
			        return {options:[]}
				}

				var word = $("#searchWord").val();
				setTimeout(function(){
					callBack({
						options:[
							{value:"name;"+word, text:"<b>이름: <font color='#409CE5'>"+word+"</font></b>", desc: "-이름으로 찾기"},
							{value:"dept;"+word, text:"<b>부서: <font color='#409CE5'>"+word+"</font></b>", desc: "-부서로 찾기"},
							{value:"phone;"+word, text:"<b>핸드폰: <font color='#409CE5'>"+word+"</font></b>", desc: "-핸드폰으로 찾기"},
							{value:"charge;"+word, text:"<b>담당업무: <font color='#409CE5'>"+word+"</font></b>", desc: "-담당업무로 찾기"},
							{value:"jobposition;"+word, text:"<b>직위: <font color='#409CE5'>"+word+"</font></b>", desc: "-직위로 찾기"},
							{value:"joblevel;"+word, text:"<b>직급: <font color='#409CE5'>"+word+"</font></b>", desc: "-직급으로 찾기"}
						]
					});
				}, 000);
			},
			onChange:function(){
				searchUser(this.selectedOption);
				$("#searchWord").val(tempWord);
			}
		});
		
		$('#searchWord').keydown(function(e) {
		    if (e.keyCode == 13) {
		    	if($("#searchType option:selected").val() == "dept"){
		    		searchUser("deptName;"+$("#searchWord").val());
		    	} else {
			    	searchUser("name;"+$("#searchWord").val());       
		    	}
		    	
		    	$("#inputBasic_AX_searchWord_AX_Handle").attr("class","bindSelectorNodes AXanchorSelectorHandle");
		    }
		});
				
	}
	
	var myOrgTree = new coviTree();
	//tree 데이터 
	function setTreeData(){
		var domain = $("#domainSelect").val();
		var grouptype = "dept";
		
		$.ajax({
			url:"/covicore/cmmn/orgmap/getdeptlist.do",
			type:"POST",
			data:{
				"domain" : domain,
				"grouptype" : grouptype
			},
			async:false,
			success:function (data) {
				var List = data.list;
				myDeptTree.setTreeList("orgMapTree", List, "nodeName", "170", "left", true, false);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("cmmn/orgmap/getdeptlist.do", response, status, error);
			}
		});
	}
	
	//select 바인딩
	function setSelect(){
		$("#domainSelect").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "DN_ID",
				optionText: "DisplayName"
			},
			ajaxUrl: "/covicore/cmmn/orgmap/getOrgSelectData.do",
			ajaxPars: {"filter": "domain"},
			ajaxAsync:false,
			onchange: function(){
				setTreeData();
			}
		});

		$("#selectGroupType").bindSelect({
			reserveKeys: {
				optionValue: "optionValue",
				optionText: "optionText"
			},
			options:[{"optionValue":"dept","optionText":"▣ 조직도"},{"optionValue":"group","optionText":"▣ 그룹"}],
			onchange:function () {
				setTreeData();
			}
		});
	}

	//검색버튼 클릭
	function searchUser(searchTextAndType){
		if(searchTextAndType==null || searchTextAndType=='undefined'){
			return;
		}
		var val =searchTextAndType.value;
		
		if(val=="null" || val =="undefined" || val == undefined){
			val = searchTextAndType;
		}
		var searchType = val.split(";")[0];
		var searchText = val.split(";")[1];
		
		tempWord = searchText;
		
		var url = "/covicore/cmmn/orgmap/getuserlist.do";
		var params = new Object();
		var domain = $("#domainSelect").val();
		if (searchType == "deptName") {
			url = "/covicore/cmmn/orgmap/getdeptlist.do";
			params.domain = domain;
			params.grouptype = "dept";
			//params.schDeptType = $("#deptSelbox option:selected").val();
		} else {
			params.dn_id = domain;
			params.searchType = searchType;
		}
		params.searchText = searchText;
		
		$.ajax({
			url: url,
			type:"post",
			data: params,
			//async:true,
			success:function (data) {
				// 조회된 후 선택부서TEXT 초기화
				$("#selDeptTxt").text("");
				
				if (searchType == "deptName") {
					setOrgMapList(data,"schDept");
				} else {
					setOrgMapList(data,"search");
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	// 각 부서에 해당하는 사원들 데이터 가져오기
	function getOrgMapListData(nodeValue){
		
		var deptCode = nodeValue;
		$("#orgSearchListAll").attr("checked", false);
		
		$.ajax({
			type:"POST",
			data:{
				"deptCode" : deptCode
			},
			async:true,
			url:"/covicore/cmmn/orgmap/getuserlist.do",
			success:function (data) {
				if (data.list.length == 0) {
					$("#selDeptTxt").text("");					
				} else {
					$("#selDeptTxt").text(data.list[0].GroupName);
				}
				
				setOrgMapList(data);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("cmmn/orgmap/getuserlist.do", response, status, error);
			}
		});
	}

	// 각 부서에 해당하는 사원들 리스트 HTML 에 바인드
	function setOrgMapList(data,pMode){
		//trace(Object.toJSON(data));
		var strData ="";
		var strMsg = "";

		if(data.list.length == 0 || data.list.length == null)
			strMsg = "조회되는 내용이 없습니다.";
		else{
			strMsg = "";

			$(data.list).each(function(){
				if (pMode == "search") {
					strData += "<tr>";
					strData += "<td><input type='checkbox' id='orgSearchList_people"+this.no +"' name='"+this.DN +"' value='"+ Object.toJSON(this) +"'/></td>";
					strData += "<td><a href='#none' class='cirPro'><img src='"+ProfileImagePath+this.AN +".jpg"+"' alt='' onerror='coviCmn.imgError(this, true)'></a></td>";
					//strData += "<td><a href='#none' class='cirPro'><img src='http://192.168.11.126:8080/covicore/resources/images/theme/profile_pic.jpg' alt=''></a></td>";
					strData += "<td class='subject'><dl class='listBotTit'><dt>"+this.DN+" "+this.LV.split(";")[1] +"</dt><dd class='lGry'>"+this.ETNM +"</dd></dl></td>";
					strData += "</tr>";
				} else if (pMode == "schDept") {
					strData += "<tr>";
					strData += "<td><input type='checkbox' id='orgSearchList_people"+this.GR_Code +"' name='"+this.DN +"' value='"+ Object.toJSON(this) +"'/></td>";
					strData += "<td colspan=\"2\" class='subject'><dl class='listBotTit'><dt>"+this.DN +"</dt><dd class='lGry'>"+this.grFullName +"</dd></dl></td>";
					strData += "</tr>";
				} else {
					strData += "<tr>";
					strData += "<td><input type='checkbox' id='orgSearchList_people"+this.no +"' name='"+this.DN+"' value='"+ Object.toJSON(this) +"'/></td>";
					strData += "<td><a href='#none' class='cirPro'><img src='"+ProfileImagePath+this.AN +".jpg"+"' alt='' onerror='coviCmn.imgError(this, true)'></a></td>";
					//strData += "<td><a href='#none' class='cirPro'><img src='http://192.168.11.126:8080/covicore/resources/images/theme/profile_pic.jpg' alt=''></a></td>";
					strData += "<td class='subject'><dl class='listBotTit'><dt>"+this.DN+" "+this.LV.split(";")[1]+"</dt><dd class='lGry'>"+this.ETNM+"</dd></dl></td>";
					strData += "</tr>";
				}
			})
		}
		document.getElementById("orgSearchListMessage").innerHTML = strMsg;
		document.getElementById("orgSearchList").innerHTML = strData;
	}
	// 임직원 체크 박스
	function setCheckedAllList(objID, checkobj){
		$("#"+objID+" input:checkbox").each(function(){
			$(this).prop("checked", $(checkobj)[0].checked);
		});
	}
	
	// 취소 버튼
	function closeLayer(){
		Common.Close();
	}
	

    function displayGroupDetail(strNum, strId, strType, strName, strPDDID, strOuName) {
        var rtnValue = "";
        if(strOuName != null){
            rtnValue += "<li title='"+strOuName+"'>";
        }else{
            rtnValue += "<li>";
        }
        rtnValue += "<span class='app_line_conf_li_number'>" + strNum + "</span>";
        rtnValue += strName;
        rtnValue += "<a href=\"javascript:delApvListGroupDetail('" + strPDDID + "','" + strId + "','" + strType + "');\"><img src='/HtmlSite/smarts4j_n/approval/resources/images/Approval/app_conf_x.gif' alt='" + "<spring:message code='Cache.btn_apv_delete' />" + "' title='" + "<spring:message code='Cache.btn_apv_delete' />" + "' class='img_align2' /></a>";  // 삭제
        rtnValue += "</li>";

        return rtnValue;
    }
    function setGrid(){
    	setGridHeader();
    	setListData();
    	setGridConfig();
    }
	function setGridHeader(){
		 var headerData =[{key:'chk', label:'chk', width: '5', align: 'center', formatter: 'checkbox', disabled:function(){
			 					var receiptDate = this.item.ReceiptDate;
			 					if(receiptDate != "" && receiptDate != null && receiptDate != undefined){
			 						return true;
			 					}else{
			 						return false;
			 					}
		 				   }},
		                  {key:'DEPT_Name', label:'부서', width:'14', align:'center'},
					      {key:'ReceiptName', label:'이름', width:'13', align:'center', formatter:function(){
					    	  if(this.item.ReceiptType == 'U'){
					    		  return '';
					    	  }else{
					    		  return this.item.ReceiptName;
					    	  }
					      }},						
		                  {key:'SenderName', label:'회람자',  width:'13', align:'center'},
					      {key:'ReceiptDate', label:'지정일자',  width:'13', align:'center'},
					      {key:'ReadDate', label:'접수일자',  width:'13', align:'center'}]; 		
		 
			
		 ListGrid.setGridHeader(headerData);		 
	}
	function setListData(){					
		
		ListGrid.bindGrid({
			ajaxUrl: "getExistingCirculationList.do",//조회 컨트롤러
			ajaxPars: {"FormIstID" : FormInstID,
						"Kind" : "C" },
		});
	} 
	function setGridConfig(){
		var configObj = {
				targetID : "ListGrid",
				height:"245",
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
                }
		}
		
		ListGrid.setGridConfig(configObj);
	}
	
	function sendCirculation(){				

		var Comment = $('#ideas').val();
		
		if(Comment.trim().length == 0){
			
			alert("코멘트를 입력하세요.");
			
			return;
		};
		
		$.ajax({
			type:"POST",
			data:
			{ 
				ListData : JSON.stringify(ListGrid.getList("C,U")),
				FormInstID : FormInstID,
				ProcessID : ProcessID,
				usid : usid,
				usnm : usnm,
				dpid : dpid,
				dpdn : dpdn,
				FormName : FormName,
				Subject : Subject,
				FormID : FormID,
				FormPrefix : FormPrefix,
				FormName : FormName,
				FormSubject : FormSubject,
				IsSecureDoc : IsSecureDoc,
				IsFile : IsFile,
				FileExt : FileExt,
				IsComment : IsComment,
				ApproverCode : ApproverCode,
				ApproverName : ApproverName,
				ApprovalStep : ApprovalStep,
				ApproverSIPAddress : ApproverSIPAddress,
				IsReserved : IsReserved,
				ReservedGubun : ReservedGubun,
				Priority : Priority,
				IsModify : IsModify,
				Reserved1 : Reserved1,
				Reserved2 : Reserved2,
				Kind : Kind,
				Comment : Comment
			},
			async:true,
			url:"setCirculation.do",
			success:function (data) {
				setListData();
				Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){
					closeLayer();
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("setCirculation.do", response, status, error);
			}
		});
	}
	
	
	function addGridRow(DeptID, DeptName, URID, URName){		
		var dup = false ;
		 
		$(ListGrid.list).each(function(idx,obj){
			if(URID == undefined && obj.ReceiptID == DeptID && obj.ReceiptType == 'U'){
				dup = true;
				return false; //break;
			}else if(URID == obj.ReceiptID && obj.ReceiptType=='P'){
				dup = true;
				return false;  //break;
			}
		});
		
		if(dup){				
			
			var msgStr = DeptName;
			
			if(URName)
				msgStr = URName;
			
			alert(msgStr + "은 이미 추가 되었습니다.");			
		}
		else {
			var type = URID == undefined? 'U' : 'P';  
			if(type =='U'){
				ListGrid.pushList({Dept_ID : DeptID, DEPT_Name : DeptName, ReceiptID : DeptID, ReceiptName : DeptName, SenderName : usnm, ReceiptType:type});
			}else{
				ListGrid.pushList({Dept_ID : DeptID, DEPT_Name : DeptName, ReceiptID : URID, ReceiptName : URName, SenderName : usnm, ReceiptType:type});
			}
		}
	}
	
	function setOrgSelectList(){
		var chkList = myDeptTree.getCheckedTreeList('checkbox');

		$.each(chkList, function(i, item){
			addGridRow(item.AN, item.DN);
		});
		
		$('#orgSearchList input[type=checkbox]:checked').each(function(){
			var item = JSON.parse($(this).val());
			
			if (item.itemType == "user") {
				addGridRow(item.RG, item.RGNM, item.AN, item.DN);			
			} else {
				addGridRow(item.AN, item.DN);
			}
		});
		
		$('#orgSearchList input[type=checkbox]').prop('checked',false);
		$("input:checkbox[id^=orgMapTree]").prop('checked',false); 
	}
	
	function deleteOrgSelectList(){
		
		ListGrid.removeListIndex(ListGrid.getCheckedListWithIndex(0));
	}
	
	function removeCheckedList(){
		
		 var checkedList = ListGrid.getCheckedList(0);// colSeq
         
		 if(checkedList.length == 0){
             alert("선택된 목록이 없습니다. 삭제하시려는 목록을 체크하세요");    
             return;
         }
		         
         var removeList = [];
         $.each(checkedList, function(){
	             removeList.push({ReceiptID:this.ReceiptID});
         });
         
         ListGrid.removeList(removeList);
	}
	
	function removeAll(){
		
		var v = getInfo("ProcessInfo.ProcessDescription.ApproverCode");		
		
		ListGrid.reloadList();
	}
	
    
</script>

<form>
  <div class="divpop_contents">
    <div class="pop_header">
    <!-- 팝업 Contents 시작 -->
    <div class="appBox">
      <!-- 트리 시작 -->
      <div class="appTree">
        <div class="appTreeTop">
          <!-- 셀렉트 시작 -->
			<select id="domainSelect" class="treeSelect"></select>
          <!-- 셀렉트 끝 -->
        </div>
        <div class="appTreeBot">
        	<div id="orgMapTree" style="height:100%;"></div>
        </div>
      </div>
      <!-- 트리 끝 -->
      <!-- 리스트검색 시작 -->
      <div class="appList_top_b">
      	<select id="searchType" class="j_appSelect">
      		<option value="person"><spring:message  code='Cache.lbl_apv_person' /></option>	<!-- 개인 -->
      		<option value="dept"><spring:message  code='Cache.lbl_apv_dept' /></option> <!-- 부서 -->
      	</select>
      	<input style="width: 192px;" type="text" placeholder="<spring:message  code='Cache.msg_EnterSearchword' />" id="searchWord" name="inputSelector_onsearch"  data-axbind="selector"  ><a class="searchImgBlue" href="#"><spring:message  code='Cache.btn_apv_search' /></a><!-- 검색 -->
      </div>
      <div class="appList">
        <table class="tableStyle t_center hover appListTop" style="width:276px;">
          <thead>
            <tr>
            	<th>
					<input type="checkbox" id="allchk" name="allchk">
					<span id="selDeptTxt"></span>
				</th>
            </tr>
          </thead>
        </table>
        <div class="appListBot">
        <table class="tableStyle t_center hover">
          <colgroup>
          <col style="width:30px">
          <col style="width:50px">
          <col style="width:*">
          </colgroup>
          <tbody id="orgSearchList">
          </tbody>
        </table>
        <div id="orgSearchListMessage" align="center"></div>
      </div>
     </div>
      <!-- 리스트검색 끝 -->
      <!-- 버튼영역 시작 -->
      <div class="arrowBtn">
          <a class="btnRight" href="#" onclick="setOrgSelectList();">오른쪽으로 이동</a>
	      <a class="btnLeft" href="#" onclick="deleteOrgSelectList();">왼쪽으로 이동</a>
      </div>
      <!-- 버튼영역 끝 --> 
	  <!-- 탭영역 시작 -->
      <div class="appSel" style="margin-top: -40px;">
        <div class="selTop">
          <table class="tableStyle t_center hover infoTableBot">
            <colgroup>
            <col style="width:50px">
            <col style="width:*">
            </colgroup>
            <thead>
              <tr>
                <td colspan="2"><h3 class="titIcn"><spring:message code='Cache.lbl_apv_circulation_list'/></h3>
                <input type="button" value="<spring:message code='Cache.btn_delete'/>" class="smButton" onclick="removeCheckedList();" style="margin-left: 4px;float:right;"/>
                <input type="button" value="<spring:message code='Cache.btn_DelAll'/>" class="smButton" onclick="removeAll();" style="float:right"/>
                </td>
              </tr>
            </thead>
          </table>
          <div class="coviGrid">
          <div id="ListGrid"></div>
          </div>
        </div>
        <div class="selBot" style="overflow:hidden;">
          <table class="tableStyle t_center hover infoTableBot">
            <colgroup>
            <col style="width:50px">
            <col style="width:*">
            </colgroup>
            <thead>
              <tr>
                <td colspan="2"><h3 class="titIcn"><spring:message code='Cache.lbl_apv_comment'/></h3></td>
              </tr>
            </thead>
            <tbody id="orgSelectList_dept">
            </tbody>
          </table>
          <textarea id="ideas" name="ideas" style="width:410px; height:140px; resize:none;"></textarea>
        </div>
      </div>
      <!-- 탭영역 끝 -->
    </div>
	</div>
	<!-- 하단버튼 시작 -->
      <div class="popBtn"> 
      <input type="button" class="ooBtn" onclick="sendCirculation();" value="<spring:message code='Cache.btn_Circulation_Confirm'/>"/> <!--회람지정-->
      <input type="button" class="gryBtn mr30" onclick="closeLayer();" value="<spring:message code='Cache.btn_Cancel'/>"/> </div><!--취소-->
      <!-- 하단버튼 끝 -->
    <!-- 팝업 Contents 끝 -->
  </div>

</form>
</html>
