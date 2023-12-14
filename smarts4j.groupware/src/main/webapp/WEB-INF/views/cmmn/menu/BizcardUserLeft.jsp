<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
.btnType01.twobtn {margin-right:8px;padding:10px 0 12px;display:inline-block;width: calc(50% - 7px);text-align:center;font-size:15px;color:#fff;border-radius:2px;font-weight:700;transition:box-shadow .3s;} 
.btnType01.twobtn:last-child{margin-right: 0px;} 
</style>
<!-- class="commContLeft" -->
<div class="cLnbTop">
	<h2><spring:message code='Cache.BizSection_BizCard' /></h2> <!-- 인명관리 -->
	<div class="cLnbTop_group">
		<!-- a class="btnType01" href="javascript:;" onclick="CoviMenu_GetContent('/groupware/layout/bizcard_CreateBizCard.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard');return false;"><spring:message code='Cache.btn_RegistBizCard' /></a-->
		<a class="btnType01 half" href="#" onclick='addGroup(this)'><spring:message code='Cache.CPMail_RegistGroup' /></a>
		<a class="btnType01 half" href="/groupware/layout/bizcard_CreateBizCard.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard"><spring:message code='Cache.btn_RegistBizCard' /></a>
	</div>
</div>
<div class="cLnbMiddle mScrollV scrollVType01">
	<div >
		<ul id="leftmenu" class="contLnbMenu bizcardMenu">
		</ul>
	</div>			
</div>						
<input type = "hidden" id = "inputUserId" value = "">

<script type="text/javascript">
	//# sourceURL=BizcardUserLeft.jsp
	
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';

	var arr = ['P', 'D', 'U', 'C'];
	
	initLeft();
	
	var bizcardLeft;
	function selectPublicMailCombo(){
		
		var mailVal = Common.getSession().UR_Mail;
		var mailNm = Common.getSession().USERNAME + ' &#60;' + mailVal + '&#62;';
		var mailUserId = Common.getSession().USERID;
		var mailUserCode = Common.getSession().UR_Code;
		var mailDomainCode = Common.getSession().DN_Code;
		var mailDeptCode = Common.getSession().GR_Code;
		var localKey = mailDomainCode+"_"+mailUserCode;
		
		var strSel = "";
		
		//최초에 주입
		if(sessionStorage.getItem(localKey) == null || JSON.parse(sessionStorage.getItem(localKey)).isMailDeptCode == null){
			//새창 읽기/작성에서 $("select[name='publicMailCombo']") 를 가져올 수없어 sessionStorage에 넣기 - 기존 창 /새 창 동일 함수 사용
			var data = {userMail: mailVal, 
						ismailuserNm: Common.getSession().USERNAME, 
						isMailUserCode : mailUserCode,
						isMailDomainCode : mailDomainCode,
						isMailDeptCode : mailDeptCode,
						ismailuserid: mailUserId
						};
			
			sessionStorage.setItem(localKey, JSON.stringify(data));
			
			strSel = "selected";
		}
		
		if(sessionStorage.getItem("tempMailUserCode") == null){
			$("#inputUserId").val(localKey);
		}else{
			$("#inputUserId").val(sessionStorage.getItem("tempMailUserCode"));
			//새로고침시 선택한 공용메일 유지시키기 위해 주석처리
			//sessionStorage.removeItem("tempMailUserCode");
		}
		
		
		if(Common.getSession('UR_AssignedBizSection').includes('Mail')){
			bizcardUserMailDefaultInfo();
		}
	}
	function bizcardUserMailDefaultInfo(){
		if(!Common.getSession('UR_AssignedBizSection').includes('Mail')) return false;
		
		var localUserInfo = JSON.parse(sessionStorage.getItem($("#inputUserId").val()));
		var domainCode = localUserInfo.isMailDomainCode;
		var userCode = localUserInfo.isMailUserCode;
		
		$.ajax({
			url:"/mail/mailSettings/selectMailSettingsDefault.do",
			type:"POST",
			data: {
				"DomainCode" : domainCode
		       ,"UserCode" : userCode
			},
			dataType : 'json',
			success:function (data, res) {
				if(data.status=='SUCCESS'){
	        		if(data.list.length > 0){
	        			localUserInfo.userSettings = data.list[0];
	        			sessionStorage.setItem($("#inputUserId").val(), JSON.stringify(localUserInfo));
	        		}
				}
			},
			error:function (error){
				Common.Warning("mail setting error", "<spring:message code='Cache.CPMail_warning_msg'/>");
			}
		});
	}
	
	function initLeft(){
		
		selectPublicMailCombo();
		// 스크롤
		coviCtrl.bindmScrollV($('.mScrollV'));
		
		var opt = {
    			lang : Common.getSession("lang"),
    			isPartial : "true"
    	};
		bizcardLeft = new CoviMenu(opt);
		if(leftData.length != 0){
			bizcardLeft.render('#leftmenu', leftData, 'userLeft');
			setMenuURL();
		}
		
		// 즐겨찾기 연락처, 전체 연락처, 업체 연락처 count
		/* $("#leftmenu").find("a").each(function() {
			$(this).append("<strong class='colorTheme ml5'>0</strong>");
		}); */
		
		/*
		$("li.menuContactCompany").find("a").attr("class", "btnOnOff");
		$("li.menuContactCompany").find("a").wrap("<div class='selOnOffBox'></div>");
		$("li.menuContactCompany").append("<div class='selOnOffBoxChk type02 boxList'></div>");
		*/
		/* 인명관리 left tree 그룹등록기능 삭제 iwyoon 2018-12-27
		for(var i = 0; i < arr.length; i++)	 {
			if(arr[i] != 'C')
				$("div .menuAllContact0" + (i+1)).find("a").after("<button type='button' class='btnAddList' onclick='addGroup(this)' data-mntype='" + arr[i] + "' data-mnurl='/groupware/bizcard/CreateBizCardGroup.do' >그룹 추가하기</button>");
			else
				$("li.menuContactCompany").append("<button type='button' class='btnAddList' onclick='addGroup(this)' data-mntype='" + arr[i] + "' data-mnurl='/groupware/bizcard/CreateBizCardGroup.do' style='top: 18px;'>그룹 추가하기</button>");
		}
		*/
		for(var j = 0; j < arr.length; j++) {
			if (arr[j] != 'C') {
				$("div .menuAllContact0" + (j+1)).append("<div class='menuAllContactList'></div>");
			}
		//  인명관리 left tree 하위 그룹목록 호출기능 삭제 iwyoon 2018-12-27
		//	appendGroup(j);
		}
    	
    	if(loadContent == 'true'){
    		CoviMenu_GetContent('/groupware/layout/bizcard_BizCardFavoriteList.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard');
    	}
    	
		$('.btnOnOff').css('background-image', 'none');
		$('.btnOnOff').closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');		
   	
    	//SubMenu Open/Close 기능
 		/* $('.btnOnOff').unbind('click').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
			}else {
				$(this).addClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
			}	
		}); */
	}
	
	function setMenuURL(){
		var pathname = location.pathname + location.search;
		$.each($('.bizcardMenu [data-menu-target*=Current]'), function(i, el){ 
			var menuURL = decodeURIComponent(el.dataset.menuUrl);
			if(menuURL == pathname){
				$('.non').removeClass('selected');
				$(el).find('a').addClass("selected");
			}
		}); 
	}
	
	function appendGroup(index) {
		$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : arr[index]}, function(d) {
			if(arr[index] != 'C') {
				d.list.forEach(function(d) {
					$("div .menuAllContact0" + (index+1)).find("div.menuAllContactList")
						.append("<a href='javascript:;' data-menu-url='%2Fgroupware%2Flayout%2Fbizcard_BizCardPersonListFor" + arr[index] + ".do%3FCLSYS%3Dbizcard%26CLMD%3Duser%26CLBIZ%3DBizcard%26grpid%3D" + d.GroupID + "' onclick='CoviMenu_ClickLeft(this);return false;'><span>" + d.GroupName + "</span></a>");
				});
			} else {
				d.list.forEach(function(d) {
					$("li.menuContactCompany").find("div.selOnOffBoxChk")
						.append("<a href='javascript:;' data-menu-url='%2Fgroupware%2Flayout%2Fbizcard_BizCardCompanyList.do%3FCLSYS%3Dbizcard%26CLMD%3Duser%26CLBIZ%3DBizcard%26grpid%3D" + d.GroupID + "' onclick='CoviMenu_ClickLeft(this);return false;'><span>" + d.GroupName + "</span></a>");
				});
			}
		}).error(function(response, status, error){
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
	}
	
	
	var addGroup = function(target) {
		var url = "/groupware/bizcard/CreateBizCardGroupPop.do";
		var sTitle = "<spring:message code='Cache.lbl_bizcard_registGroup'/>"; /*그룹 수정*/
		Common.open("", "CreateBizCardGroupPop", sTitle, url + "?sharetype=P", "750px", "480px", "iframe", true, null, null, true);
		return;
	};
	
	var addBizcard = function(target) {
		var url = "/groupware/layout/bizcard_CreateBizCard.do" + "?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard"; 
		CoviMenu_GetContent(url);
	};

</script>