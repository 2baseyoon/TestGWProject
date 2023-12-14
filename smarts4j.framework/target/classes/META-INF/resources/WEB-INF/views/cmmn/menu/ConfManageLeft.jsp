<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.DicHelper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ page import="egovframework.coviframework.util.StringUtil"%>
<div class="cLnbTop">
	<h2>
	<%if (SessionHelper.getSession("isAdmin").equals("Y")){
		out.println(DicHelper.getDic("lbl_GroupwareSetting"));
	}	
	else{
		out.println(DicHelper.getDic("lbl_SimpleManager"));
	}	
	%>
	</h2>
	<div class=domain>
		<label><spring:message code="Cache.lbl_Domain"/></label>
		<select class="selectType04 w60" id="selectDomainList">
		</select>	
	</div>	
</div>
<div class='cLnbMiddle mScrollV scrollVType01'>
	<ul class="contLnbMenu sadminMenu" id="leftConfMenu"></ul>			
</div>
<div class="lnbLicense" style="display:none;">
	<ul class="detail">
		<c:forEach items="${licenseInfo}" var="list" varStatus="status">
			<c:if test="${list.count ==0 && (list.LicUserCount+list.LicExUserCount)>0}">
			<li ${list.LicUsingCnt<=(list.LicUserCount+list.LicExUserCount)?'':  'class="full"'}>
				<h4><span class="lname">${list.LicName}</span><span class="per"><b><fmt:formatNumber value="${list.LicUsingCnt/(list.LicUserCount+list.LicExUserCount)*100}" pattern="#,###" />%</b> (${list.LicUsingCnt}/${(list.LicUserCount+list.LicExUserCount)})</span></h4>
				<div class="capacity_box"><div id="divCapacity_bar" class="capacity_bar" style="width: ${list.LicUsingCnt/(list.LicUserCount+list.LicExUserCount)*100}%; max-width: 100%; background-color: #4ABDE1;"></div></div>
			</li>
			</c:if>
		</c:forEach>
	</ul>
</div>
<div class="lnbLicense" style="display:none;"> <!-- 확장됐을 경우 open 클래스 추가 -->
	<a class="btn_open" href="#"></a>
	<a class="btn_close" href="#"></a>
	<ul class="detail">
		<c:forEach items="${licenseInfo}" var="list" varStatus="status">
			<c:if test="${list.LicUserCount+list.LicExUserCount>0}">
			<li ${list.LicUsingCnt<=(list.LicUserCount+list.LicExUserCount)?'':  'class="full"'}>
				<h4><span class="lname">${list.LicName}</span><span class="per"><b><fmt:formatNumber value="${list.LicUsingCnt/(list.LicUserCount+list.LicExUserCount)*100}" pattern="#,###" />%</b> (${list.LicUsingCnt}/${(list.LicUserCount+list.LicExUserCount)})</span></h4>
				<div class="capacity_box"><div id="divCapacity_bar" class="capacity_bar" style="width: ${list.LicUsingCnt/(list.LicUserCount+list.LicExUserCount)*100}%; max-width: 100%; background-color: #4ABDE1;"></div></div>
			</li>
			</c:if>
		</c:forEach>
	</ul>
</div>
<script type="text/javascript">
	var confMenu = {
		leftData : '${leftMenuData}',
		loadContent : '${loadContent}',
		domainId : '${selDomainid ne null && selDomainid ne '' ? selDomainid: domainId}',
		domainCode : '${seldomaincode ne null && seldomaincode ne '' ? seldomaincode: domainCode}',
		domainName : '',
		isAdmin : '${isAdmin}',
		$mScrollV : $('.mScrollV'),
		portalUrl : '/covicore/layout/system_CompanyManage.do?CLSYS=conf&CLMD=manage&CLBIZ=Conf',
		objectInit : function(){			
			$(".commContLeft").addClass("sadminLeft");
			//기준날짜 구하기
			this.initLeft();
			$('.selOnOffBox a').unbind('click').on('click', function(){
				if($(this).hasClass('active')){
					$(this).removeClass('active');
					$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
				}else {
					$(this).addClass('active');
					$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
				}	
			});
			
			$('#isService').click(function(){
				confMenu.getDomainList();
			});
			
			$("#selectDomainList").change(function(){
				confMenu.changeDomain();
			});

			$('.lnbLicense .btn_open').click(function(){
			      $(this).hide();
			      $('.lnbLicense .btn_close').show();
			      $('.lnbLicense').addClass('open');
			});
			
			$('.lnbLicense .btn_close').click(function(){
			    $(this).hide();
			    $('.lnbLicense .btn_open').show();
			    $('.lnbLicense').removeClass('open');
			});
		},
		initLeft : function(){
		 	var opt = { lang : "ko", isPartial : "true" };
		 	
		 	var leftData = ${leftMenuData};
		 	var coviMenu = new CoviMenu(opt);
		 	
		 	if(leftData.length != 0){
		 		coviMenu.render('#leftConfMenu', leftData, 'userLeft');
		 	}
		 	
		 	this.getDomainList();
			coviCtrl.bindmScrollV($('.mScrollV'));
		 	if(this.loadContent == 'true'){
		 		 $( "#leftConfMenu li:eq(0) .selOnOffBox a").addClass("active");
		 		 $( "#leftConfMenu li:eq(0) .selOnOffBoxChk").addClass("active");
		 		 if ($("#leftConfMenu li:eq(0) .selOnOffBoxChk div:eq(0)").attr("data-menu-url") != ""){
		 			$("#leftConfMenu li:eq(0) .selOnOffBoxChk div:eq(0) a:eq(0)").trigger("click");
		 		 }
		  	}else{
		  		if ('${menuId}' != ''){
		  			var obj  = $( "#leftConfMenu div[data-menu-id='${menuId}']");
		  			
		  			obj.find("a").addClass("selected");
		  			var parentObj =obj.parent(".selOnOffBoxChk");
		  			
		  			parentObj.siblings(".selOnOffBox").find(".btnOnOff").addClass('active');		
		  			parentObj.addClass('active');		

		  			parentObj =parentObj.parent(".selOnOffBoxChk");
		  			if(parentObj.length>0){
			  			parentObj.siblings(".selOnOffBox").find(".btnOnOff").addClass('active');		
			  			parentObj.addClass('active');		
		  			}	
		  		}
		  	}
		 	
		 	$(".btn_open").parent(".lnbLicense").show();
		},
		getDomainList:function(){
			$.ajax({
				type:"POST",
				url:"/covicore/domain/getCode.do",
				async:false,
				data:{"isService":($("#isService").is(":checked")?"N":"Y")},
				success:function (data) {
					if(data.result == "ok"){
						var codeArray = data.list;

				    	for(var j = 0; j < codeArray.length; j++) {
				    		let codeObj = codeArray[j];
				    		
				    		var domainId = codeObj.DomainID;
				    		var domainName = CFN_GetDicInfo(codeObj.MultiDisplayName, lang);
				    		
				    		var option = $("<option>", {"value":domainId, "text":domainName, "data":codeObj});
				    		
				    		$("#selectDomainList").append(option);
				    	}
				    	
				    	$("#selectDomainList option[value=" + confMenu.domainId +"]").prop("selected", true);
					}
				},
				error:function (error){
					Common.Error(error.message);
				}
			});
		},
		changeDomain:function(){
			var menuObj = $("#leftConfMenu .selected").closest("div");
			var url =confMenu.portalUrl;
			var domainData = $('#selectDomainList option:selected').data();
			
			if ($("#leftConfMenu .selected").length > 0)
				url = decodeURIComponent(menuObj.attr("data-menu-url"));
			url += "&menuid="+menuObj.attr("data-menu-id")+"&seldomainid="+domainData["DomainID"];
			url += "&seldomaincode=" +domainData["DomainCode"];
			
			location.replace(url)
		}
	}
	
	$(document).ready(function(){
		confMenu.objectInit();
	});
</script>
