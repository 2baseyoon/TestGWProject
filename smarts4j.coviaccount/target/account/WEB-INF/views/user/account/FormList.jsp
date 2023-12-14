<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType">
	<h2 class="title">결재작성</h2><!-- TODO 다국어 -->
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="apprvalBottomCont">
			<!-- 본문 시작 -->
			<div class="content_in">
				<div class="bodyMenu">
					<div class="btn_group mb10">
						<div class="selBox" style="width:61px;" >
							<span class="selTit" ><a id="selListTypeID" onclick="clickSelectListBox(this);" value="tab" class="up"><spring:message code="Cache.btn_apv_class_by"/></a></span>
							<div class="selList" style="width:77px;display: none;">
								<a class="listTxt select" value="tab" onclick="clickSelectListBoxData(this);" id="<spring:message code="Cache.btn_apv_class_by"/>"><spring:message code="Cache.btn_apv_class_by"/></a>
								<a class="listTxt" value="list" onclick="clickSelectListBoxData(this);" id="<spring:message code="Cache.btn_apv_total"/>"><spring:message code="Cache.btn_apv_total"/></a>
							</div>
						</div>
						<input type="button" value="<spring:message code='Cache.lbl_approval_recentlyApv'/>" class="opBtn" onclick="boxShowHide(this,'giBox');"> <!-- 최근기안 -->
						<input type="button" value="<spring:message code='Cache.lbl_approval_favoriteForm'/>" class="opBtn" onclick="boxShowHide(this,'faGi');"> <!-- 자주쓰는 기안 -->
						<div class="fRight searchBox02">
							<input type="text" id="searchInput" onkeypress="if (event.keyCode==13){ onClickSearchButton(); return false;}" style="width:260px;" placeholder="<spring:message code='Cache.msg_apv_001' />"><a onclick="onClickSearchButton();" class="btnSearchType01"><spring:message code="Cache.btn_search"/></a>
						</div>
					</div>
				</div>
				<!-- 최근기안  시작-->
				<div class="giBox" id="giBox">
					<span class="giTit"><spring:message code='Cache.lbl_approval_recentlyApv'/></span> <!-- 최근기안 -->
					<dl class="giLeft" id="giLeft"></dl>
					<dl class="giRight" id="giRight"></dl>
				</div><!-- 최근기안  끝-->
				<!-- 자주쓰는 기안-->
				<ul class="faGi" id="faGi"></ul>
				<!-- 자주쓰는 끝-->
				<div class="tabLine">
					<ul class="writeTab" id="writeTab"></ul>
				</div>
				<ul class="writeTapCont" id="writeTapCont"></ul>
			</div>
			<!-- 본문 끝 -->
		</div>
	</div>
</div>
<script>

	var ListGrid = new coviGrid();
	var TabList;
	var vValue = "";
	$(document).ready(function () {
		setTab();
		setCompleteAndRejectList();
		setFavoriate();
		//selSelectbind();
		getListDataType();
		$("#giBox").hide();
		$("#faGi").hide();
	});

	//axisj selectbox변환
	function selSelectbind(){
		//사용여부selectbind
		$("#getListType").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        		getListType(this.value);
        	}
        });
	}

	function setTab(){
		$.ajax({
			url:"/approval/user/getClassificationListData.do",
			type:"post",
			data:{
					"viewAll":"T",
					"entCode":"",
				},
			async:false,
			success:function(data) {
				setTabClass(data);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getClassificationListData.do", response, status, error);
			}
		});
	}


	function setFavoriate(){

		$.ajax({
			url:"/approval/user/getFavoriteUsedFormListData.do",
			type:"post",
			data:{
					"userCode":Common.getSession("USERID"),
				},
			async:false,
			success:setdivFavoriate,
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getFavoriteUsedFormListData.do", response, status, error);
			}
		});
	}

	function setdivFavoriate(data){
		var vHtml = "";
		if($(data.list).length > 0){
			$(data.list).each(function(idx){
				//if(idx=="4") return false;
				vHtml += "<li><a class='faList' href='javascript:openFormDraft("+this.FormID+",\""+this.FormPrefix+"\");'>"+this.LabelText+"</a><a onclick='deleteFavorite("+this.FormID+");' class='giDel'><spring:message code='Cache.lbl_delete'/></a></li>"; //삭제
			});
		}
		else
			vHtml = "";
		$('#faGi').html(vHtml);
	}
	//탭  세팅
	function setTabClass(pObj){
		$("#writeTab").empty();
		$(pObj.list).each(function(index){
			if(index == 0)
				vValue = this.FormClassID;
			var html = "";
			if(index == 0){
				html = "<li class='on'><a onclick='javascript:changeTab(this,"+this.FormClassID+");'>"+this.FormClassName+"</a></li>";
			}else{
				html = "<li><a onclick='javascript:changeTab(this,"+this.FormClassID+");'>"+this.FormClassName+"</a></li>";
			}
			$("#writeTab").append(html);
		});
		setListData(vValue);
	}
	function changeTab(pObj,vValue){
		$(pObj).parent().parent().find("li").attr('class','');
		$(pObj).parent().attr('class','on');
		setListData(vValue);
	}

	function setListData(pFromClassID, pSearchText){
		var Params = {
				FormClassID : pFromClassID,
				viewAll : "T", // 임시로 T로 박는다.
				entCode : "",
				FormName : pSearchText,
				userCode : Common.getSession("USERID")
		};

		$.ajax({
			url:"/approval/user/getFormListData.do",
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				$("#writeTapCont").empty();
				var html = "";
				for(var i =0; i< data.list.length;i++){
					if(data.list[i].FormPrefix=="WF_FORM_VACATIONCANCEL"){
						continue; //하드코딩으로 향후에 휴가신청서를 사용안함으로 변경할 것.
					}
					
					var formDesc = Base64.b64_to_utf8(data.list[i].FormDesc);
					
					if (data.list[i].Favorite=="Y") {
						html = "<li class='on'>";
					} else {
						html = "<li>";
					}
					html += "<a onclick='javascript:openFormDraft("+data.list[i].FormID+",\""+data.list[i].FormPrefix+"\");' class='starList'>"+data.list[i].FormName+"</a>";
					html += "<a onclick='javascript:modifyFavorite(this,"+data.list[i].FormID+")' class='starBtn'><spring:message code='Cache.lbl_Favorite'/></a>";  //즐겨찾기
					html += "<a onclick='javascript:clickComment(event,\""+formDesc+"\");' class='deTxt tooltips'><spring:message code='Cache.lbl_Description'/>";   //설명
					html += "<span><div>"+formDesc+"</div></span></a>";
					html += "</li>";

			        $("#writeTapCont").append(html);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getFormListData.do", response, status, error);
			}
		});
	}

	//즐겨찾기 수정
	function modifyFavorite(pObj,FormID){
		var url;
		if($(pObj).parent().attr('class')=="on"){
			url = "/approval/user/removetFavoriteUsedFormListData.do";
		}else{
			url = "/approval/user/addFavoriteUsedFormListData.do";
		}
		var Params = {
				userCode : Common.getSession("USERID"),
				formID : FormID
		};
		$.ajax({
			url:url,
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				if(!$('#writeTab').is(":hidden")){
					$('#writeTab').children('.on').children().trigger('onclick');
				}else{
					onClickSearchButton();
				}

				setFavoriate();
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}

	//즐겨찾기 삭제
	function deleteFavorite(FormID){
		var url;
		url = "/approval/user/removetFavoriteUsedFormListData.do";
		var Params = {
				userCode : Common.getSession("USERID"),
				formID : FormID
		};
		$.ajax({
			url:url,
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				if(!$('#writeTab').is(":hidden")){
					$('#writeTab').children('.on').children().trigger('onclick');
				}else{
					onClickSearchButton();
				}

				setFavoriate();
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}

	function onClickSearchButton(){
		var vSearchText = $('#searchInput').val();
		setListData('', vSearchText);
		$('#writeTab').hide();
	}



	//팝업 오픈 함수
	function openFormDraft(FormID,FormPrefix){
		var width = "790";
		if(IsWideOpenFormCheck(FormPrefix, FormID)){
			width = "1070";
		}else{
			width = "790";
		}
		CFN_OpenWindow("/approval/approval_Form.do?formID=" + FormID + "&mode=DRAFT", "", width, (window.screen.height - 100), "resize", "false");

	}


	function getListType(type) {
		var vTabChecked = type == 'tab';
		// 분류일땐 탭에 내용만 조회
		if(vTabChecked){
			setListData();
			$('#writeTab').show();
			$('#writeTab').children('.on').children().trigger('onclick');
		}
		else{
			setListData(); // 분류 없이 전체 조회
			$('#writeTab').hide();
		}
	}
	function getListDataType(){
		// 분류일땐 탭에 내용만 조회
		if($("#selListTypeID").attr("value") == 'tab'){
			setListData();
			$('#writeTab').show();
			$('#writeTab').children('.on').children().trigger('onclick');
		}
		else{
			setListData(); // 분류 없이 전체 조회
			$('#writeTab').hide();
		}
	}
	function writeListShowHide(type){
		if(type=="show"){
			$('#writeList').show();
			$('#arrOpen').hide();
			$('#arrClose').show();
		}else{
			$('#writeList').hide();
			$('#arrOpen').show();
			$('#arrClose').hide();
		}
	}

	//최근기안
	function setCompleteAndRejectList(){
		var Params = {
				userCode : Common.getSession("USERID")
		};
		var giLeftHtml = "";
		var giRightHtml = "";
		$.ajax({
			url:"/approval/user/getCompleteAndRejectListData.do",
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				$(data.list).each(function(idx){
					if(idx=="3") return false;
				          if(this.TYPE=="Complete"){
				        	  giLeftHtml +=  "<dt><input type='button' class='sComplete' value='<spring:message code='Cache.lbl_Completed'/>'></dt>"; //완료
				          }else{
				        	  giLeftHtml +=  "<dt><input type='button' class='sReturn' value='<spring:message code='Cache.lbl_apv_reject'/>'></dt>"; //반려
				          }
				          giLeftHtml +=  "<dd><a onclick='onClickPopButton(\""+this.ProcessArchiveID+"\",\""+this.WorkitemArchiveID+"\",\""+this.PerformerID+"\",\""+this.ProcessDescriptionArchiveID+"\",\""+this.FormSubKind+"\",\"\",\"\",\"\",\"\",\""+this.UserCode+"\",\""+this.TYPE+"\",\""+this.FormPrefix+"\"); return false;'>"+this.FormSubject+"</a></dd>";
				          giRightHtml += "<dt>"+getStringDateToString("yyyy.MM.dd HH:mm",this.EndDate)+"</dt>"
							+  "  <dd><input type='button' class='sUse' onclick='formReuse(\""+this.ProcessArchiveID+"\",\""+this.WorkitemArchiveID+"\",\""+this.PerformerID+"\",\""+this.ProcessDescriptionArchiveID+"\",\""+this.FormSubKind+"\",\"\",\"\",\"\",\"\",\""+this.UserCode+"\",\""+this.TYPE+"\",\""+this.FormPrefix+"\"); return false;' value='<spring:message code='Cache.btn_reuse'/>'></dd>";
				});
				$('#giLeft').html(giLeftHtml);
				$('#giRight').html(giRightHtml);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getCompleteAndRejectListData.do", response, status, error);
			}
		});
	}

	//재사용
	function formReuse(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,TYPE,FormPrefix){
		var archived = "false";
		var mode;
		var gloct;
		var subkind;
		var archived;
		var userID;
		if(TYPE=="Complete"){
			mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; 	// 완료함
		}else{
			mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode;	// 반려함
		}
		var width = "790";
		if(IsWideOpenFormCheck(FormPrefix, FormID)){
			width = "1070";
		}else{
			width = "790";
		}
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"&editMode=Y&reuse=Y", "", width, (window.screen.height - 100), "resize");
	}


	//최근기안팝업
	function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,TYPE,FormPrefix){
		var archived = "false";
		var mode;
		var gloct;
		var subkind;
		var archived;
		var userID;
		if(TYPE=="Complete"){
			mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; 	// 완료함
		}else{
			mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode;	// 반려함
		}
		var width = "790";
		if(IsWideOpenFormCheck(FormPrefix, FormID)){
			width = "1070";
		}else{
			width = "790";
		}
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind, "", width, (window.screen.height - 100), "resize");
	}

	function boxShowHide(pObj,pData){

		if($(pObj).attr('class')=="opBtn"){
			$(pObj).parent().find('input[type=button]').attr('class','opBtn');
			$(pObj).attr('class','opBtn on');
			if(pData=="giBox"){
				$("#giBox").show();
				$("#faGi").hide();
			}else{
				$("#giBox").hide();
				$("#faGi").show();
			}
		}else{
			$(pObj).attr('class','opBtn');
			$("#giBox").hide();
			$("#faGi").hide();
		}
	}

	function clickSelectListBox(pObj){
		if($(pObj).parent().parent().find('.selList').css('display') == 'none'){
			$(pObj).parent().parent().find('.selList').show();
		}else{
			$(pObj).parent().parent().find('.selList').hide();
		}
		if($(pObj).attr('class')=='listTxt'||$(pObj).attr('class')=='listTxt select'){
			$(pObj).parent().find(".listTxt").attr("class","listTxt");
			$(pObj).attr("class","listTxt select");
			$(pObj).parent().parent().find(".up").html($(pObj).attr("id"));
			$(pObj).parent().parent().find(".up").attr("value",$(pObj).attr("value"));
		}
	}

	function clickSelectListBoxData(pObj){
		if($(pObj).parent().parent().find('.selList').css('display') == 'none'){
			$(pObj).parent().parent().find('.selList').show();
		}else{
			$(pObj).parent().parent().find('.selList').hide();
		}
		if($(pObj).attr('class')=='listTxt'||$(pObj).attr('class')=='listTxt select'){
			$(pObj).parent().find(".listTxt").attr("class","listTxt");
			$(pObj).attr("class","listTxt select");
			$(pObj).parent().parent().find(".up").html($(pObj).attr("id"));
			$(pObj).parent().parent().find(".up").attr("value",$(pObj).attr("value"));
		}
		getListDataType();
	}

	// comment 클릭
	function clickComment(event, formDesc){
		var $this = $(event.target);
		
		if (formDesc != "") {
			if ($this.hasClass('tooltips-show')) {
				$this.removeClass('tooltips-show');
			} else {
				$this.addClass('tooltips-show');
			}
		}
	}
</script>