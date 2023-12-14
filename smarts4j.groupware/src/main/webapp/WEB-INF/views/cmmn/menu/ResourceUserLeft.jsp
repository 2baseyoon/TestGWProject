<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cLnbTop">
	<h2><spring:message code='Cache.lbl_resource_title' /></h2><!-- 자원예약 -->
	<div><a class="btnType01" onclick="CoviMenu_GetContent('resource_DetailWrite.do?CLSYS=resource&CLMD=user&CLBIZ=Resource');"><spring:message code='Cache.lbl_resource_booking' /></a></div><!-- 예약하기 -->
</div>
<div class='cLnbMiddle mScrollV scrollVType01'>
	<div class="scheduleMenu">
		<div class="calContanier">
			<div class="calendarTop active">
				<a class="btnFold active" onclick="btnFoldOnClick(this);"><spring:message code='Cache.lbl_folding' /></a><!-- 접기 -->
				<a class="btnPervArrow" onclick="moveLeftMonth('-');"><spring:message code='Cache.lbl_previous' /></a><span class="calTopdate"></span><a class="btnNextArrow" onclick="moveLeftMonth('+');"><spring:message code='Cache.lbl_next' /></a><!-- 이전 --><!-- 다음 -->
				<input type="hidden" id="calTopDateVal" >
			</div>
			<div class="calCont">
			
				<div id="leftCalendar" class="tablCalendar active">
					
				</div>
				<ul class="contLnbMenu resMenu">
					<li>
						<a id="allShow" onclick="javascript:aAllOnClick();" value="off"><spring:message code='Cache.lbl_resource_viewAllRes' /><span></span></a><!-- 전체자원 보기 -->
						<div id="placeOfBusinessSel">
						</div>
					</li>
				</ul>
				<ul id="resource" class="contLnbMenu resMenu"   style="padding-bottom:25px;">
				</ul>
			</div>
				<div>
					<ul id="leftmenu" class="contLnbMenu" style="border-top: 1px solid #eaeaea;"></ul>
				</div>
		</div>
	</div>
</div>
<!-- 간단등록에서 상세등록으로 이동시 temp -->
<input type="hidden" id="simpleSelectDatePicker" >
<input type="hidden" id="simpleSubject" >
<input type="hidden" id="simpleStartDate" >
<input type="hidden" id="simpleEndDate" >
<input type="hidden" id="simpleStartHour" >
<input type="hidden" id="simpleStartMinute" >
<input type="hidden" id="simpleEndHour" >
<input type="hidden" id="simpleEndMinute" >
<input type="hidden" id="simpleIsChkSchedule" >

<script type="text/javascript">
var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var g_folderCheckList = ";";
	var g_folderList = ";";
	var placeOfBusiness = "";
	var resourceMenuID = '${menuId}';
	var g_lastURL;
	
	var resourceLeft;
	
	initLeft();
	
	function initLeft(){
		// 스크롤
		coviCtrl.bindmScrollV($('.mScrollV'));
		var isUsePlaceOfBusinessSel = Common.getBaseConfig("IsUsePlaceOfBusinessSel");

		setPlaceOfBusiness();
		// 사업장 사용 여부
		if(isUsePlaceOfBusinessSel === "N"){
			$("#placeOfBusinessSel").hide();
		}else{
			$("#placeOfBusinessSel").show();
		}
		
		resourceLeft = new CoviMenu(opt);
		resourceLeft.render('#leftmenu', leftData, 'userLeft');
		$("#leftmenu .selected").removeClass("selected");
		
		g_lastURL = '/groupware/layout/resource_View.do?CLSYS=resource&CLMD=user&CLBIZ=Resource';
		if (CFN_GetQueryString('menuID') != 'undefined') g_lastURL += '&menuID=' +CFN_GetQueryString('menuID');
		
		// 기존에 선택된 자원들 Checkbox Checked (PC 와 Mobile 에서 동일한 체크값을 공유 하기 위해서 Redis 부터 조회한다)
		getMainResourceMenuList();		
		if(g_folderCheckList == "undefined" || g_folderCheckList == "" || g_folderCheckList == ";"){
			if(window.sessionStorage.getItem("ResourceCheckBox_"+userCode) != null){
	 			g_folderCheckList = window.sessionStorage.getItem("ResourceCheckBox_"+userCode);
	 			g_folderList = g_folderCheckList;
	 		}
		}
		
		setLeftMenu();
	};
	
	// 사업장 Select Box 세팅
	function setPlaceOfBusiness(){
		var lang = Common.getSession("lang");
		var initInfos = [
	        {
		        target : 'placeOfBusinessSel',
		        codeGroup : 'PlaceOfBusiness',
		        defaultVal : 'PlaceOfBusiness',
		        width : '220',
		        onchange : 'onchangePlaceOfBusiness'
	        }
        ];
        coviCtrl.renderAjaxSelect(initInfos, '', lang);
	}
	
	// 사업장 Select Box 변경시
	function onchangePlaceOfBusiness(){
		placeOfBusiness = coviCtrl.getSelected('placeOfBusinessSel').val;
		
		if(placeOfBusiness == "PlaceOfBusiness"){
			placeOfBusiness = "";
		}
		
		$(allShow).val("on");
		getMainResourceMenuList();
		setLeftMenu();
		resourceUser.refresh();
	}
	
	function drawTreeChild(data, depth){
		var folderHTML = '';
		folderHTML += '<div class="selOnOffBoxChk type02 boxList">';
		$(data).each(function(idx, el){
			if(el.FolderType == "Folder") {
				folderHTML += '		<div class="selOnOffBox" style="padding: 13px 0;">';
				folderHTML += '			<a class="btnOnOff" style="height: 15px; line-height: 15px;" onclick="btnOnOffOnClick(this);">'+el.FolderName+'<span></span></a>';
				folderHTML += '		</div>';
				
				//하위 폴더 그려주기
				if(el.child && el.child.length > 0){
					folderHTML += drawTreeChild(el.child, ++depth);
					depth--;
				}
			} else if(el.FolderType == "Resource"){
				folderHTML += '<div class="chkStyle04 chkType01" style="width: calc(100% - ' + (depth * 25) +'px)">';
				folderHTML += '<input type="checkbox" id="allSV'+el.FolderID+'" name="allSV" value="'+el.FolderID+'" onchange="checkFolderData(this);"><label for="allSV'+el.FolderID+'" style="width: 180px;" title="'+ el.FolderName +'"><span></span>'+el.FolderName+'</label>';
				folderHTML += '<button type="button" onclick="openResourceInfoView(\''+el.FolderID+'\');" class="btnTblSearch">'+"<spring:message code='Cache.btn_search'/>"+'</button>';		//검색
				folderHTML += '</div>';
			}
		});
		folderHTML += '</div>';
		
		return folderHTML;
	}
	
	function drawTree(data){
		//폴더일 경우
		var folderHTML = '<li></li>';
		$.each(data, function(idx, el){
			if(el.FolderType == "Folder"){
				folderHTML += '	<li>';
				folderHTML += '		<div class="selOnOffBox">';
				folderHTML += '			<a class="btnOnOff" onclick="btnOnOffOnClick(this);">'+el.FolderName+'<span></span></a>';
				folderHTML += '		</div>';
				
				//하위 폴더 그려주기
				if(el.child && el.child.length > 0){
					folderHTML += drawTreeChild(el.child, 0);
				}
			}
			//자원일 경우
			else if(el.FolderType == "Resource"){
				folderHTML += '	<li class="contLnbMenuChk">';
				folderHTML += '		<div id="topResourceDiv" class="selOnOffBoxChk type02 boxList active">';
				folderHTML += '			<div class="chkStyle04 chkType01">';
				folderHTML += '				<input type="checkbox" id="allSV'+el.FolderID+'" name="allSV" value="'+el.FolderID+'" onchange="checkFolderData(this);"><label for="allSV'+el.FolderID+'" style="width: 200px;" title="'+ el.FolderName +'"><span></span>'+el.FolderName+'</label>';
				folderHTML += '				<button type="button" onclick="openResourceInfoView(\''+el.FolderID+'\');" class="btnTblSearch">'+"<spring:message code='Cache.btn_search'/>"+'</button>';		//검색
				folderHTML += '			</div>';
				folderHTML += '		</div>';
			}
			folderHTML += '</li>';
		});
		
		return folderHTML;
	}
	
	// 좌측 메뉴 세팅
	function setLeftMenu(){
		if(resAclArray.status != "SUCCESS") {
			resourceUser.setAclEventFolderData();
		}
		
		var folderIDs = "";
		
		if($$(resAclArray).find("view").concat().length > 0){
			
			$$(resAclArray).find("view").concat().each(function(i, obj){
				folderIDs += $$(obj).attr("FolderID") + ",";
			});
			
			folderIDs = "(" + folderIDs.substring(0, folderIDs.length-1) + ")";
			
			$.ajax({
			    url: "/groupware/resource/getFolderTreeData.do",
			    type: "POST",
			    async: false,
			    data: {
			    	"placeOfBusiness" : placeOfBusiness,
			    	"FolderIDs" : folderIDs,
			    	"MenuID" : (CFN_GetQueryString('menuID') != 'undefined') ? CFN_GetQueryString('menuID') : ''
			    },
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		
			    		var folderHTML = "";
			    		folderHTML += drawTree(res.list);
			    		
			    		$("#resource").html(folderHTML);
			    		
			    		for (var i=0; i<g_folderCheckList.split(";").length; i++) {
		                    var val = g_folderCheckList.split(";")[i];
		     				var tar = $('#allSV' + val).closest('.selOnOffBoxChk');
		     				
		     				if ($('#allSV' + val).length > 0) {
			                    $("#allSV" + val).prop("checked", true);
			                    
		     					tar.addClass('active');
			     				tar.prev('.selOnOffBox').find('a').addClass('active');
		     				}
		                }
			    		
			    		// 체크할 항목에 없는 것은 우측 자원 목록에서 제외하기
			    		var folderListArr = g_folderCheckList.split(";");
			    		var folderCheckList = g_folderCheckList;
			    		for (var i=0; i<folderListArr.length; i++) {
			    			var thisFDID = folderListArr[i];
		                    if($("#allSV" +thisFDID).length < 1){
		                    	folderCheckList = folderCheckList.replace(";" + thisFDID + ";", ";");
		                    }
		                }
			    		
			    		g_folderList = folderCheckList;
		     			
		     			if(loadContent == 'true'){
		     				var contentUrl = "/groupware/layout/resource_View.do?CLSYS=resource&CLMD=user&CLBIZ=Resource&viewType=D&MenuID="+resourceMenuID 
		     				CoviMenu_OpenMenu(contentUrl);
			    			g_lastURL = contentUrl;
		     			}
			    		
			    	}else{
			    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
			    	}
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/getFolderTreeData.do", response, status, error);
				}
			});
		}
	}
	
	// 전체자원 보기
	function aAllOnClick(){
		// TODO : 폴더로 된 것들을 모두 펼침.
		//$(".btnOnOff").click();
		
		if($(allShow).val() == "off"){
			$("[name=allSV]").each(function(){
				$(this).prop("checked", true);
				g_folderCheckList += $(this).val() + ";";
			});
			
			g_folderList = g_folderCheckList;
			
			$(allShow).val("on");
		}else{
			$("[name=allSV]").each(function(){			
				$(this).removeAttr("checked");	
			});
			
			g_folderCheckList = ";";
			g_folderList = g_folderCheckList;
			
			$(allShow).val("off");
		}
		
		var url = "resource_View.do?CLSYS=resource&CLMD=user&CLBIZ=Resource&viewType="+g_viewType+"&startDate="+g_startDate+(g_endDate == undefined ? "" : ("&endDate="+g_endDate));
		CoviMenu_GetContent(url, false);
		g_lastURL = url;
		
		resourceUser.saveChkFolderListRedis(g_folderCheckList);
		window.sessionStorage.setItem("ResourceCheckBox_"+userCode, g_folderCheckList);
		
		$("#leftmenu .selected").removeClass("selected");
	}
	
	// 체크된 Folder 데이터 View로 전달
	function checkFolderData(obj){
		var folderID = $(obj).val();
		if(g_folderCheckList.indexOf(";"+folderID+";") > -1 && $(obj).prop("checked") == false){
			g_folderCheckList = g_folderCheckList.replace(";"+folderID+";", ";");
		}else if(g_folderCheckList.indexOf(";"+folderID+";") < 0 && $(obj).prop("checked") == true){
			g_folderCheckList += folderID + ";";
		}
		
		var folderListArr = g_folderCheckList.split(";");
		var folderCheckList = g_folderCheckList;
		for (var i=0; i<folderListArr.length; i++) {
			var thisFDID = folderListArr[i];
            if($("#allSV" +thisFDID).length < 1){
            	folderCheckList = folderCheckList.replace(";" + thisFDID + ";", ";");
            }
        }
		
		g_folderList = folderCheckList;
		
		$("#leftmenu .selected").removeClass("selected");
		
		resourceUser.saveChkFolderListRedis(g_folderCheckList);
		window.sessionStorage.setItem("ResourceCheckBox_"+userCode, g_folderCheckList);
		
		var url = "resource_View.do?CLSYS=resource&CLMD=user&CLBIZ=Resource&viewType="+g_viewType+"&startDate="+g_startDate+(g_endDate == undefined ? "" : ("&endDate="+g_endDate));
		CoviMenu_GetContent(url, false);
		g_lastURL = url;
	}
	
	//메인 화면 목록 데이터 가져오기
	function getMainResourceMenuList(){
		$.ajax({
		    url: "/groupware/resource/getMainResourceMenuList.do",
		    type: "POST",
		    async: false,
		    data: {
		    	"domainID" : Common.getSession("DN_ID")
		    },
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		if(res.redisData != undefined && res.redisData != "" && res.redisData != ";"){
		    			g_folderList = res.redisData;
		    			g_folderCheckList = g_folderList;
		    		} else if(res.list.length > 0){
		    			$(res.list).each(function(){
			    			g_folderCheckList += this.FolderID+";";
			    		});
			    		g_folderList = g_folderCheckList;
		    		}	
		    	}else{
		    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/getMainResourceMenuList.do", response, status, error);
			}
		});
	}
	
	function openResourceInfoView(folderID){
		Common.open("","resourceInfo_Popup", "<spring:message code='Cache.lbl_resource_Info' />","/groupware/resource/goResourceInfoView.do?folderID="+folderID,"500px","533px","iframe",true,null,null,true);		//자원정보
	}
	
</script>