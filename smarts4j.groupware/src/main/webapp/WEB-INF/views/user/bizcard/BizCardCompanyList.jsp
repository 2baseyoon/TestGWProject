<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/groupware/resources/script/user/bizcard.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/groupware/resources/script/user/bizcard_list.js<%=resourceVersion%>"></script>

<div class="cRConTop titType">
		<h2 class="title"><spring:message code='Cache.lbl_CompanyList' /></h2> <!-- 업체 목록 -->
		<div class="searchBox02" >
			<select id="searchType" class="selectType02 lg widSm">
				<option value="ComName"><spring:message code='Cache.lbl_BusinessName'/></option> <!-- 업체명 -->
				<option value="PhoneNum"><spring:message code='Cache.lbl_Phone'/></option> <!-- 전화 -->
				<option value="EMAIL"><spring:message code='Cache.lbl_Email2'/></option> <!-- 이메일 -->
			</select>
			<span>
				<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ onClickSearchButton(this); return false; }"> <%-- placeholder="<spring:message code='Cache.msg_apv_001' />"	 --%>
				<button type="button" class="btnSearchType01" onclick="onClickSearchButton(this);"><spring:message code='Cache.lbl_search'/></button><!-- 검색 -->
			</span>
		</div>
</div>

<!-- 상단 필터 및 메뉴 -->
<div class="cRContBottom mScrollVH ">
		<div class="bizcardAllCont">
			<div class="bizcardTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a href="#"  id="btnDelete" class="btnTypeDefault"><spring:message code="Cache.btn_delete"></spring:message></a><!-- 삭제 -->
					<a href="#"  id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="ExcelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a><!-- 엑셀저장 -->
				</div>
				<div class="buttonStyleBoxRight">
					<select class="selectType02 listCount" id="selDataPerPageCnt" >
						<option value="10">10</option> 
						<option value="15">15</option> 
						<option value="20">20</option> 
						<option value="30">30</option> 
						<option value="50">50</option> 
					</select>
					<!-- <button type="button" class="btnIcoComm btnPrint" type="button" onclick="alert('<spring:message code='Cache.msg_037' />');">
						<spring:message code='Cache.lbl_Print'/>
					</button> --><!-- 인쇄 -->
					<button type="button"  class="btnRefresh" type="button" onclick="refresh()"></button> <!-- 새로고침 -->
				</div>
			</div>	
			<div class="selectListWrap autoCompleteCustom active">
				<div class="heading">
					<span><spring:message code='Cache.lbl_Choice' /></span><!-- 선택 -->
					<strong class="colorTheme">0</strong>
					<button class="btnRemoveAll" type="button" onclick="resetSelectedGroup();"><spring:message code='Cache.btn_DelAll' /></button><!-- 전체삭제 -->
				</div>
				<ul class="ui-autocomplete-multiselect ui-state-default ui-widget">
				</ul>
				<a class="btnMoreStyle01 active" href="#">fold list</a><!-- 리스트 접기 -->
			</div>
			<div id="divTabTray" class="tblList tblCont tblBizcardList">
				<div class="tblFilterTop">
					<p class="filterGroup">
						<a id="bizCardListGroup" href="#" onclick="clickTab(this);" value="Group"><spring:message code='Cache.lbl_group' /></a> <!-- 그룹 -->
					</p>
					<ul class="filterList">
						<li class="active"><a id="bizCardListAll" href="#" onclick="clickTab(this);" value="ALL"><spring:message code='Cache.lbl_all' /></a><!-- 전체 --></li>
						<li><a id="bizCardListKor1" href="#" onclick="clickTab(this);" 	value="ㄱ">ㄱ</a> </li>
						<li><a id="bizCardListKor2" href="#" onclick="clickTab(this);" 	value="ㄴ">ㄴ</a> </li>
						<li><a id="bizCardListKor3"	href="#" onclick="clickTab(this);" value="ㄷ">ㄷ</a></li>
						<li><a id="bizCardListKor4" href="#" onclick="clickTab(this);" value="ㄹ">ㄹ</a> </li>
						<li><a id="bizCardListKor5"	href="#" onclick="clickTab(this);" value="ㅁ">ㅁ</a></li>
						<li><a id="bizCardListKor6" href="#" onclick="clickTab(this);" 	value="ㅂ">ㅂ</a> </li>
						<li><a id="bizCardListKor7"	href="#" onclick="clickTab(this);" value="ㅅ">ㅅ</a></li>
						<li><a id="bizCardListKor8" href="#" onclick="clickTab(this);"	value="ㅇ">ㅇ</a> </li>
						<li><a id="bizCardListKor9"	href="#" onclick="clickTab(this);" value="ㅈ">ㅈ</a></li>
						<li><a id="bizCardListKor10" href="#" onclick="clickTab(this);"	value="ㅊ">ㅊ</a> </li>
						<li><a id="bizCardListKor11"	href="#" onclick="clickTab(this);" value="ㅋ">ㅋ</a></li>
						<li><a id="bizCardListKor12" href="#" onclick="clickTab(this);"	value="ㅌ">ㅌ</a> </li>
						<li><a id="bizCardListKor13"	href="#" onclick="clickTab(this);" value="ㅍ">ㅍ</a></li>
						<li><a id="bizCardListKor14" href="#" onclick="clickTab(this);"	value="ㅎ">ㅎ</a> </li>
						<li><a id="bizCardListEng" href="#"	onclick="clickTab(this);" value="ENG">A-Z</a> </li>
						<li><a id="bizCardListNum" href="#" onclick="clickTab(this);"	value="NUM">0-9</a></li>
						<li><a id="bizCardListEtc" href="#" onclick="clickTab(this);"	value="ETC"><spring:message code='Cache.lbl_Etc' /></a></li><!-- 기타 -->
					</ul>
				</div>
			
				<!-- Grid -->
				<div id="resultBoxWrap">
					<div id="bizCardGrid"></div>
				</div>
				
			</div>
		</div>
</div>	

<script>

	var bizCardViewType = "C";
	var bizCardGrid = new coviGrid();
	var msgHeaderData = getGridHeader("C");
	var groupID = "";
	var storagePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
	
	//***************************************************************************************************************************/
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		if($("#divTabTray .active").find("a").attr('value') != "Group"){
			    //전체
				bizCardGrid.setGridHeader([
									  {key:'chk', label:'chk', width:'20', align:'center',formatter:'checkbox'},
									  {key:'ComName',  label:"<spring:message code='Cache.lbl_CompanyName'/>", width:'70', align:'left', //회사명
					                	  formatter:function () {
					                		  var sReturn = "<span class=\"thumb ";
					                		  if(this.item.ImagePath != "" && this.item.ImagePath != undefined) {
					                			  sReturn +=  "\">";
					                			  sReturn +=  "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" src=\"" + coviCmn.loadImage(storagePath + this.item.ImagePath);
					      					  } else {
					      						  sReturn +=  "noImg \">";
					      						  sReturn += "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" src=\"" + "/covicore/resources/images/common/noImg.png";
					      					  }
					                		sReturn += "\" /></span>&nbsp;";
					                		sReturn += "<a href='#' onclick='viewBizCardPop(\""+ this.item.BizCardID +"\"); return false;'>"+this.item.ComName+"</a>";
					                		
					      					return sReturn;
					      			  }}, 
					                  {key:'ComRepName',  label:"<spring:message code='Cache.lbl_RepName'/>", width:'50', align:'center'}, //대표자명
					                  {key:'EMAIL', label:"<spring:message code='Cache.lbl_Email2'/>", width:'70', align:'center', formatter : function() { //이메일
					                		var EMAIL = this.item.EMAIL;
					                		if(EMAIL.indexOf(";") > 0)
					                			EMAIL = EMAIL.substr(0,EMAIL.indexOf(";"));
					                		return EMAIL;
					                  }},
					                  {key:'PhoneNum',  label:"<spring:message code='Cache.lbl_Phone'/>", width:'70', align:'center', formatter : function() { //전화
					                		var PhoneNum = this.item.PhoneNum;
					                		
					                		if(PhoneNum.indexOf(";") > -1)
					                			PhoneNum = PhoneNum.substr(0,PhoneNum.indexOf(";"));
					                		return PhoneNum;
					                  }},
					                  {key:'ComAddress', label:"<spring:message code='Cache.lbl_HomeAddress'/>", width:'100', align:'center', formatter : function() { //주소
					                		var ComAddress = this.item.ComAddress;
		
					                		if(ComAddress.length > 25)
					                			ComAddress = ComAddress.substr(0,25) + "...";;
					                		return ComAddress;
					                  }}
						      		]);
		} else { //그룹
			bizCardGrid.setGridHeader([
		  							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
		  							  {key:'Groupname',  label:"<spring:message code='Cache.lbl_GroupName'/>", width:'70', align:'center', formatter: function(){ //그룹명
					                	    return this.item.Groupname + "<span style='display:none;'>" + this.item.GroupID + "</span>"; 
					                  }},
					                  {key:'MemberCnt',  label:"<spring:message code='Cache.lbl_MemberCount'/>", width:'50', align:'center'}, //멤버수
					                  {key:'Groupname',  label:"<spring:message code='Cache.lbl_Modify'/>", width:'40', align:'center', sort:false, formatter : function() { //수정
					                	  return "<button id='btnModify' type='button' class='AXButton' onclick='modifyGroup(\""+ bizCardViewType +"\",\""+ this.item.GroupID +"\"); return false;'><spring:message code='Cache.btn_Edit' /></button>"; 
				                	  }}
						      		]);
		}
		//setGridConfig();
		bindGridData();
	}

	function bindGridData() {	
		
		var tabFilter = $('#divTabTray').find(".active").first().children().attr('value');
		var startDate = null;/* $("#startDate").val(); */
		var endDate = null;/* $("#endDate").val(); */
		var searchInput = $("#searchInput").val();
		var searchType = $("#searchType").val();
		
		setGridConfig();
		
		if(tabFilter == "Group"){
			bizCardGrid.bindGrid({
				ajaxUrl:"/groupware/bizcard/getBizCardGroupList.do",
				ajaxPars: {
					shareType : bizCardViewType,
					sortBy: bizCardGrid.getSortParam()
				},
				onLoad:function () {
					$("#bizCardGrid").find('input[name=checkAll]').hide();
					$("#bizCardGrid").find('input[type=checkbox]').on("click", function(){ chkGroup(this); });
					chkSelGroupChked();
				}
			});
		}
		else{
			bizCardGrid.bindGrid({
				ajaxUrl:"/groupware/bizcard/getBizCardCompanyList.do",
				ajaxPars: {
					tabFilter : tabFilter,
					searchWord : searchInput,
					searchType: searchType,
					startDate : startDate,
					endDate : endDate,
					groupIDs : groupID,
					sortBy: bizCardGrid.getSortParam()
				}
			});
		}
	}

	//***************************************************************************************************************************/
	
	// 새로고침
	function refresh(){
		setGrid();
	}
	
	//***************************************************************************************************************************/
	
	//그룹 바인딩 : 체크박스에 체크시 처리
	var chkGroup = function(obj) {
		
		if(obj.checked == true){
			
			var sGroupID = "";
			var sGroupname = "";
			var sHTML = ""; 
			
			sGroupID = $(obj).closest('tr').children('td:nth-child(2)').find('span').text();
			sGroupname = $(obj).closest('tr').children('td:nth-child(2)').text().split(sGroupID)[0];	
			
			var cloneli = "<li id=\"" + sGroupID + "\"><div class=\"ui-autocomplete-multiselect-item\">";
			cloneli += sGroupname;
			cloneli += "<span class=\"ui-icon ui-icon-close\" onclick=\"deleteGroupBind(this);\"></span></div></li>"
			
			if($('ul.ui-autocomplete-multiselect').children('li').length == 0){
				$('ul.ui-autocomplete-multiselect').prepend(cloneli)
			} else{
				$('ul.ui-autocomplete-multiselect').children('li:last').after(cloneli);	
			}			
			
			groupID += sGroupID + ';';
			
		}
		else{
			
			var sGroupID = $(obj).closest('tr').children('td:nth-child(2)').find('span').text();
			$('ul.ui-autocomplete-multiselect').find('li[id=\"' + sGroupID +  '\"]').remove();
			groupID = groupID.replace(sGroupID+";", "");
	
		}
		setSelGroupDisplay();
	}
	
	//그룹 바인딩 해지 : 선택 그룹 표기 삭제, 체크박스 해지
	function deleteGroupBind(obj){
		groupID = groupID.replace($(obj).parent().parent().attr('id')+";", "");
		$(obj).closest('li').remove();
		
		if($("#divTabTray .active").find("a").attr('value') == "Group"){
			$('#bizCardGrid').find("span:contains('"+ $(obj).parent().parent().attr('id') +"')").parent().parent().parent().find('td:first-of-type input[type=checkbox]')[0].checked = false;
		} else{
			clickTab($("#divTabTray .active").find("a"));
		}
		
		setSelGroupDisplay();
	}
	
	//그룹 바인딩 : 선택 그룹에 포함된 chk 체크
	function chkSelGroupChked(){
		if($('ul.ui-autocomplete-multiselect').children('li').length > 0){
			$('ul.ui-autocomplete-multiselect').children('li').each (function() {
				$('#bizCardGrid').find("span:contains('"+ this.id +"')").parent().parent().parent().find('td:first-of-type input[type=checkbox]')[0].checked = true;
			});   		
		}
	}
	
	//그룹 바인딩 : 선택 그룹 표기 영역 display 여부
	function setSelGroupDisplay(){
		if($('div.selectListWrap').children('ul').children('li').length > 0){
			$('div.selectListWrap').show();
		}
		else {
			$('div.selectListWrap').hide();
		}
		
		setSelectedGroupCnt();
	} 
	
	//그룹 바인딩 : 초기화
	function resetSelectedGroup(){
		$('div.selectListWrap').children('ul').children('li').remove();
		groupID = "";
		$('div.selectListWrap').hide();
		$('#bizCardGrid').find('td:first-of-type input[type=checkbox]').each(function() {
			this.checked = false;
		});
	}
	
	//그룹 바인딩 : 선택된 값 변경
	function setSelectedGroupCnt(){
		$('strong.colorTheme').text($('ul.ui-autocomplete-multiselect').children('li').length);
	}
	
	//***************************************************************************************************************************/
	
	//엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirm Dialog", function(result) {
			if(result) {
				var headerName = getHeaderNameForExcel();
				var sortKey = "ComName";//bizCardGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
				var sortWay = "DESC"; //bizCardGrid.getSortParam("one").split("=")[1].split(" ")[1]; 				  	
				
				location.href = "/groupware/bizcard/bizCardListExcelDownload.do?sortColumn="+sortKey+"&sortDirection="+sortWay+"&tabFilter="+ $('#divTabTray').find(".active").first().children().attr('value') +"&searchWord="+ $("#searchInput").val() +"&searchType="+ $("#searchType").val() +"&shareType="+ "C" + "&groupID=" + groupID + "&headerName="+headerName;				
			}
		});
	}

	//엑셀용 Grid 헤더정보 설정
	function getHeaderNameForExcel(){
		var returnStr = "";
		
	   	for(var i=0;i<msgHeaderData.length; i++){
	   	   	if(msgHeaderData[i].display != false && msgHeaderData[i].label != 'chk'){
				returnStr += msgHeaderData[i].label + "|";
	   	   	}
		}
		
		return returnStr;
	}

	//***************************************************************************************************************************/

	
	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "bizCardGrid",		// grid target 지정
			height:"auto",
			page : {
				pageNo:1,
				pageSize: $("#selDataPerPageCnt").val()
			},
			paging : true
		};

		// Grid Config 적용
		bizCardGrid.setGridConfig(configObj);
	}	

	var bindSelect = function() {
	};
	
	var searchWorkReport = function() {
		bindGridData();
	};
	
	function onClickSearchButton(pObj){
		if($(pObj).attr("class") == "btnSearchType01"){
			if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
				Common.Warning("<spring:message code='Cache.msg_EnterSearchword'/>");							//검색어를 입력하세요
				$("#searchInput").focus();
				return false;
			}
		}
		bindGridData();
	}
		
	//탭 선택(그리드 헤더 변경)
	function clickTab(pObj){
		bizCardGrid = new coviGrid();		
		
		$("#divTabTray").find("a").parent().removeClass("active");
		$(pObj).parent().addClass("active");
		$("#searchInput").val("");
		
		if($("#divTabTray .active").find("a").attr('value') == 'Group'){
			if($('#bizcard_btn_group').css("display") != "none") {
				$('#bizcard_btn_group').css("display", "none");
				$('#group_btn_group').css("display", "block");
			}
			$('#btnDelete').removeAttr('onclick');
			$("#btnDelete").attr("onclick", "DeleteCheck(bizCardGrid, bizCardViewType, 'Group')");
		} else{
			if($('#group_btn_group').css("display") != "none") {
				$('#bizcard_btn_group').css("display", "block");
				$('#group_btn_group').css("display", "none");
			}
			$('#btnDelete').removeAttr('onclick');
			$("#btnDelete").attr("onclick", "DeleteCheck(bizCardGrid, bizCardViewType, 'Person')");
		}
		
		setGrid();
	}
		
	var viewBizCardPop = function(id) { //업체 보기
		var BizCardID = id;
		
		Common.open("", "ViewBizCardCompany", "<spring:message code='Cache.lbl_Company_CardView'/>", "/groupware/bizcard/ViewBizCardCompany.do?BizCardID=" + encodeURIComponent(BizCardID) + "&ShareType=C", "500px", "530px", "iframe", true, null, null, true);		
		return;
	} 
	
	
	window.onload = initContent();
		
	function initContent(){
		
		$.urlParam = function(name){
			var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
			if(results != null)
				return results[1] || 0;
			else
				return null;
		}
		
		$('#btnDelete').removeAttr('onclick');
		$("#btnDelete").attr("onclick", "DeleteCheck(bizCardGrid, bizCardViewType, 'Person')");
		
		if($.urlParam('grpid') != null){
			
			var grpID = ($.urlParam('grpid'));
			
			$.getJSON('/groupware/bizcard/getGroup.do', {ShareType : bizCardViewType, GroupID : ($.urlParam('grpid'))}, function(d) {
				d.list.forEach(function(d) {
					var sGroupID = "";
					var sGroupname = "";
					var sHTML = ""; 

					sGroupID = grpID;
					sGroupname = d.GroupName;

					var cloneli = "<li id=\"" + sGroupID + "\"><div class=\"ui-autocomplete-multiselect-item\">";
					cloneli += sGroupname;
					cloneli += "<span class=\"ui-icon ui-icon-close\" onclick=\"deleteGroupBind(this);\"></span></div></li>"

					if($('ul.ui-autocomplete-multiselect').children('li').length == 0){
						$('ul.ui-autocomplete-multiselect').prepend(cloneli)
					} else{
						$('ul.ui-autocomplete-multiselect').children('li:last').after(cloneli);	
					}
					
					setSelGroupDisplay();
				});
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/groupware/bizcard/getGroupList.do", response, status, error);
			});
			
			groupID =  grpID + ";";
			
		}
		
		//그리드 설정
		setGrid();
		
		$(".selectSearchField").on("change", function() {
			bindGridData();
		});
		
		$("#selDataPerPageCnt").on("change", function(){
			bindGridData();
		});
		
		//검색 조건 설정
		setSelGroupDisplay(); 		
		
		bindSelect(); 
	}
</script>