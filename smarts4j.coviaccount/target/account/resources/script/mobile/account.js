/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 e-Accounting js 파일
 * 함수명 : mobile_account_...
 * 
 * 
 */

/*!
 * 
 * 페이지별 init 함수
 * 
 */

//포탈
$(document).on('pageinit', '#account_portal_page', function () {
	g_ActiveModule = "account";
	
	if($("#account_portal_page").attr("IsLoad") != "Y"){
		$("#account_portal_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_PortalInit()",10);
	}
});

//사용자 포탈
$(document).on('pageinit', '#account_portal_user_page', function () {
	g_ActiveModule = "account";
	
	if($("#account_portal_user_page").attr("IsLoad") != "Y"){
		$("#account_portal_user_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_PortalInit('user')",10);
	}
});

//관리자 포탈
$(document).on('pageinit', '#account_portal_manager_page', function () {
	g_ActiveModule = "account";
	
	if($("#account_portal_manage_page").attr("IsLoad") != "Y"){
		$("#account_portal_manage_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_PortalInit('manager')",10);
	}
});

//e-Accouting 공통 리스트
$(document).on('pageinit', '#account_list_page', function () {
	g_ActiveModule = "account";
	
	if($("#account_list_page").attr("IsLoad") != "Y"){
		$("#account_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_ListInit()",10);
	}
});

//증빙 상세조회
$(document).on('pageinit', '#account_receipt_view_page', function () {
	if($("#account_receipt_view_page").attr("IsLoad") != "Y"){
		$("#account_receipt_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_ReceiptViewInit()",10);
	}
});

//비용신청
$(document).on('pageinit', '#account_write_page', function () {
	g_ActiveModule = "account";
	
	if($("#account_write_page").attr("IsLoad") != "Y"){
		$("#account_write_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_WriteInit()",10);
	}
});

//전표 상세조회
$(document).on('pageinit', '#account_view_page', function () {
	g_ActiveModule = "account";
	
	if($("#account_view_page").attr("IsLoad") != "Y"){
		$("#account_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_ViewInit()",10);
	}
});

//거래처 선택
$(document).on('pageinit', '#account_vendor_page', function () {
	if($("#account_vendor_page").attr("IsLoad") != "Y"){
		$("#account_vendor_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_VendorInit()",10);
	}
});

//개인카드 선택
$(document).on('pageinit', '#account_prcard_page', function () {
	if($("#account_prcard_page").attr("IsLoad") != "Y"){
		$("#account_prcard_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_PRCardInit()",10);
	}
});

//코스트센터 선택
$(document).on('pageinit', '#account_costcenter_page', function () {
	if($("#account_costcenter_page").attr("IsLoad") != "Y"){
		$("#account_costcenter_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_CostCenterInit()",10);
	}
});

//IO 선택
$(document).on('pageinit', '#account_io_page', function () {
	if($("#account_io_page").attr("IsLoad") != "Y"){
		$("#account_io_page").attr("IsLoad", "Y");
		setTimeout("mobile_account_IOInit()",10);
	}
});

/*!
 * 
 * e-Accounting 공통
 * 
 */


function mobile_account_datepickerLoad(pObjID) {
	var targetObj;
	
	if(pObjID) {
		targetObj = $("#" + pObjID);
	}
	else {
		targetObj = $(".input_date");
	}
	
	$(targetObj).attr('class', 'input_date').datepicker({
		dateFormat : 'yy-mm-dd',
		dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	});
}

//결재 진행을 위한 주요 정보 조회
function mobile_account_getFormData(pPageObj) {
	$.ajax({
		url:"/account/getFormData.do",
		type:"post",
		data:{
			mode: pPageObj.Mode,
			gloct: pPageObj.Gloct,
			Subkind: pPageObj.SubKind,
			UserCode: pPageObj.UserCode,
			WorkitemID: pPageObj.WorkitemID,
			ExpAppID: pPageObj.ExpenceApplicationID
		},
		async:false,
		success:function (data) {
			if(data.status == "SUCCESS") {
				pPageObj.Mode = data.formData.mode;
				pPageObj.Loct = data.formData.loct;
				pPageObj.UserCode = data.formData.UserCode;
				pPageObj.ReqUserCode = data.formData.reqUserCode;
				pPageObj.ParentProcessID = data.formData.ParentProcessID;
				pPageObj.SchemaContext = data.formData.SchemaContext;
				pPageObj.FormID = data.formData.FormID;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/account/getFormData.do", response, status, error);
		}
	});
}

// 문서연결 HTML 구성 리턴
function mobile_account_getDocLinkHtml(bWrite, pProcessID, pSubject, bStored, pBusiessData1, pBusinessData2) {
	var sHtml = "";
	var sURL = "";
	var sMode = "COMPLETE";
	var bUseTotalApproval = mobile_comm_getBaseConfig("useTotalApproval");
	
	// 통합결재 사용 시 모듈에 따른 URL 구성
	if(bUseTotalApproval == "Y" && pBusiessData1 == "ACCOUNT") {
		sURL = "/account/mobile/account/view.do";
		sURL += "?mode=" + sMode;
		sURL += "&expAppID=" + pBusinessData2;
	}
	else {
		sURL = "/approval/mobile/approval/view.do";
		sURL += "?mode=" + sMode;
	}

	sURL += "&processID=" + pProcessID;
	
	sURL += "&ownerExpAppID=" + _mobile_account_view.ExpenceApplicationID;
	
	// 조회 구분에 따른 HTML 구성
	// TO-DO: 동일 페이지 팝업 오픈 시 문제로 인하여 연결문서 클릭 시 이벤트 삭제, 추후 구현 필요
	if(bWrite) {
		// 작성 페이지
		//sHtml += "<a name='aDocLink' onclick='mobile_account_openDocLink(\"" + sURL + "\");' processID='" + pProcessID + "' subject='" + pSubject + "' bStored='" + bStored + "' businessData1='" + pBusiessData1 + "' businessData2='" + pBusinessData2 + "'>"
		sHtml += "<a name='aDocLink' processID='" + pProcessID + "' subject='" + pSubject + "' bStored='" + bStored + "' businessData1='" + pBusiessData1 + "' businessData2='" + pBusinessData2 + "'>"
		sHtml += "	<p class='detail_doc'>" + pSubject + "<a onclick='mobile_account_delLinkedDoc(this);' class='nea_del'></a></p>";
		sHtml += "</a>";
	}
	else {
		// 조회 페이지
		sHtml += "<p class='detail_doc' onclick='mobile_account_openDocLink(\"" + sURL + "\");'>" + pSubject + "</p>";
	}
	
	return sHtml;
}

// 연결문서 조회
// TO-DO: 추후 연결문서 조회 후 이전 결재문서로 돌아갈 수 있도록 보완 필요
function mobile_account_openDocLink(pUrl) {
	if(confirm(mobile_comm_getDic("msg_apv_openDocLink"))) {
		mobile_comm_back(pUrl);
	}
}

/* 
 * 
 * 포탈 페이지 시작
 * 
 */

//포탈 초기화
function mobile_account_PortalInit(mode) {
	if(window.sessionStorage["account_writeinit"] == "Y") {
		window.sessionStorage.removeItem('account_writeinit');
	}

	if(mode == "user") {
		//좌측메뉴 표시
		$('#account_portal_user_topmenu').html(mobile_account_getTopMenuHtml(AccountMenu));
		
		//TODO: 사용자 포탈 관련 개발
		mobile_account_SetUserPortal('');
		mobile_account_SetUserYearPortal('');
		
	} else if(mode == "manager") {
		//좌측메뉴 표시
		$('#account_portal_manager_topmenu').html(mobile_account_getTopMenuHtml(AccountMenu));		
		mobile_account_setManagerPortal();
		
		//TODO: 관리자 포탈 관련 개발
	} else {
		//모바일 비용신청 사용 여부에 따른 포탈 내 메뉴 숨김 처리
		if(mobile_comm_getBaseConfig("useMobileAccountWrite") == "Y" || mobile_comm_getBaseConfig("useMobileAccountWriteUser").indexOf(mobile_comm_getSession("UR_Code")) > -1) {
	        $("#li_account_portal_AppExpence").show();
	    }
		
		//좌측메뉴 표시
		$('#account_portal_topmenu').html(mobile_account_getTopMenuHtml(AccountMenu));
		
		//경비 마감일 및 공지사항 표시
		mobile_account_setDeadlineInfo("P");

		//TODO: 승인대기 문서함 카운트 표시
	}
}
function mobile_account_SetUserPortal(type){
	var strYear ="";
	var strMonth="";
	
	var dateArr 		= 	[];
	dateArr[0]=$("#account_portal_user_year").text();
	dateArr[1]=$("#account_portal_user_month").text();

	if (type=="PREV"){
		strYear  		=  (dateArr[1]-1) === 0 ? dateArr[0]-1 : dateArr[0] ;
        strMonth 		=  (dateArr[1]-1) === 0 ? 12 : (dateArr[1]-1) ;
	}
	else if (type=="NEXT"){
		var date  			=   new Date( dateArr[0] , dateArr[1] , 1 );
		strYear  		=   date.getFullYear();
        strMonth   		=   date.getMonth()+1 ;
	}
	
	if (strMonth!="" && parseInt(strMonth)<10) strMonth ="0"+parseInt(strMonth);
		
	var payDate = strYear+""+strMonth;
	//pie chart
	var proofChartObj = {type:'doughnut',
					data : {labels :["전자세금계산서","모바일영수증","법인카드"]		
							,datasets : [{borderWidth : 0,backgroundColor : [ "rgba(0,43,180,100)","rgba(1,5,138,100)","rgba(101,203,204,100)"]}]}
					,options: {tooltips: {enabled: true
			    			,callbacks: {  label: function(tooltipItem, data) {				                	
			                    var label = data.labels[tooltipItem.index] || '';
			                    if (label) {label += ': ';}
			                    return label += userComm.makeComma(data.datasets[0].data[tooltipItem.index])+"원";}
			    			}	}
					,legend: { display: false } }};
	$.ajax({
		url:"/account/accountPortal/getAccountUserMonth.do",
		type:"POST",
		cache: false,
		data:{"payDate" : payDate},
		success:function (r) {
			if(r.result == "ok"){
				var proofCount = r.proofCount;
				$("#account_portal_user_year").text(r.payDate.substring(0,4));
				$("#account_portal_user_month").text(r.payDate.substring(4,6));
				//증빙별
				if(proofCount != undefined) {
					var data = [proofCount["TaxBillAmount"],proofCount["ReceiptAmount"],proofCount["CorpCardAmount"]];
					if (proofCount["TotalAmount"] == 0){
						data=[100,0,0];
					}

					proofChartObj.data.datasets[0].data = data;
					var chart = new Chart(  $("#proofDoughnut"), proofChartObj ); 
					
					var sListHtml ='';
					var totCnt = proofCount.TotalAmount;
					var colArray = [["TaxBill","전자세금계산서"],["Receipt","모바일영수증"],["CorpCard","법인카드"]	];
					for (var i=0; i< colArray.length;i++){
						sListHtml   += '<li>'+
									'<div class="DetailRank10 height"><div class="Gragh_color blue'+(i+1)+'"></div><a href="#">'+colArray[i][1]+'('+proofCount[colArray[i][0]+"Cnt"]+'건)</a></div>'+
									'<div class="Detailaccount10"><a href="#">'+CFN_AddComma(String(proofCount[colArray[i][0]+"Amount"]))+'원</a></div>'+
								'</li>';
					}

					$("#account_portal_user_proof_tot").text(CFN_AddComma(String(totCnt)));
					$("#account_portal_user_proof_list").html(sListHtml);
				}
				
				var accountCount = r.accountCount;
				//계정별
				if(accountCount != undefined) {
					if (accountCount.length == 0){
						
					}
					else{
						var sChartHtml = '<ul class="Newgraph_stick">';
						var sListHtml ='';
						var sSlideHtml = '';
						var totCnt = accountCount[0].Amount;
						
						for (var i=1; i< accountCount.length;i++){
							var per		= accountCount[i].Amount*100.00/totCnt;

							if (i>4 && i%5 == 1){
								sChartHtml   += '</ul><ul class="Newgraph_stick" style="display:none">';
							}
							sChartHtml	+=	'<li>'+
								'		<div class="conR">'+
								'	<div class="Detailtxt20">'+accountCount[i].Name+'</div>'+
								'	<div class="zt-skill-bar"><div class="skillbar0'+(i%5+1)+'" data-width="'+per+'" style="width: '+per+'%;"></div></div>'+
								'</div>'+
								'<div class="Detailnumber20"><a href="#">'+CFN_AddComma(String(accountCount[i].Amount))+'원</a></div>'+
							'</li>';
						}
						
						$("#account_portal_user_account_tot").text(CFN_AddComma(String(totCnt)));
						$("#account_portal_user_account_chart").html(sChartHtml+"</ul>");
						$("#account_portal_user_account_slide").html("");
						if (accountCount.length > 5){
							for (var i=0; i<Math.ceil(accountCount.length/5); i++){
								$("#account_portal_user_account_slide").append('<a class="'+(i==0?'Slideroll_btn_on':'Slideroll_btn_off')+'"  onclick="mobile_account_portalAccountSlide('+i+')"><span></span></a>');
								
							}
						}	
					}		
				}
			}
			else{
				alert(r.message);
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror("/account/accountPortal/getAccountUserMonth.do", response, status, error);
		}
	});
}
function mobile_account_SetUserYearPortal(type){
	var strYear =$("#account_portal_user_year_flow").text();
	if (type=="PREV"){
		strYear  		=  parseInt(strYear)-1;
	}
	else if (type=="NEXT"){
		strYear  		=  parseInt(strYear)+1;
	}
	else{
		strYear="";
	}
	
	var payYear = strYear;
	//pie chart
	var monthChartObj = {  type: 'bar',
		    data: { labels: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'] }
		    ,options: {
		    	legend: {display: true,labels: {boxWidth : 20,usePointStyle : true,padding : 30}}
		        ,scales: {xAxes: [{ stacked: true }],			            
			        	  yAxes: [{stacked: true,ticks: {callback: function(value, index, values) {return CFN_AddComma(String(value))}}}] }
			    ,tooltips: {
		    	 	enabled: false,	
		            custom: function(tooltipModel) {	
		                var tooltipEl = document.getElementById('monthTooltip');
		                if (!tooltipEl) {
		                	var $div = $("<div>",{ "id" : "monthTooltip" });			                	
		                	$div.append( $("<div>",{ "class" : "arrow_box" }) ).appendTo( $("body") );
		                	tooltipEl = $div.get(0); 
		                };
		             	// Hide if no tooltip
		                if (tooltipModel.opacity === 0) {
		                    tooltipEl.style.opacity = 0;
		                    return;
		                }
		                
		             	// Set caret Position
		                tooltipEl.classList.remove('above', 'below', 'no-transform');
		                if (tooltipModel.yAlign) {
		                    tooltipEl.classList.add(tooltipModel.yAlign);
		                } else {
		                    tooltipEl.classList.add('no-transform');
		                }
		                
		             	// Set Text
		                if (tooltipModel.body) {
		                    var title = tooltipModel.title[0];
		                	var body = tooltipModel.body;
		                	var lineIndex = Number( title.replace('월',"") ) - 1; 
		                    
		                	var $arrow_box = $(".arrow_box",tooltipEl);
		                	var $ul = $("<ul>");
		                	var $h1 = $("<h1>",{ "class" : "arrow_titlename" }).append( title );			                	
		                	var total = this._data.datasets.reduce( function(acc,cur,idx,arr){
		                		var $li = $("<li>",{ "class" : "arrowBtncolor0"+(idx+1) });
		                		var $txt01 = $("<span>",{ "class" : "txt01", "text" : cur.label });
		                		var $txt02 = $("<span>",{ "class" : "txt02", "text" : CFN_AddComma(String(cur.data[lineIndex])) });
		                		$li.append( $txt01 ).append( $txt02 ).appendTo( $ul );			                		
		                		return acc += cur.data[lineIndex]; 
		                	},0);
		                	var $span = $("<span>",{ "text" : CFN_AddComma(String(total)) });			                	
		                	$h1.append( $span ).append("원").appendTo( $arrow_box.empty() );			                	
		                	$arrow_box.append( $ul );			                	
		                }
		                // `this` will be the overall tooltip
		                var position = this._chart.canvas.getBoundingClientRect();
		                // Display, position, and set styles for font
		                tooltipEl.style.opacity = 1;
		                tooltipEl.style.position = 'absolute';
		                tooltipEl.style.left = (position.left + window.pageXOffset + tooltipModel.caretX - 100 ) + 'px';
		                tooltipEl.style.top = (position.top + window.pageYOffset + tooltipModel.caretY - 20) + 'px';
		                tooltipEl.style.fontFamily = tooltipModel._bodyFontFamily;
		                tooltipEl.style.fontSize = tooltipModel.bodyFontSize + 'px';
		                tooltipEl.style.fontStyle = tooltipModel._bodyFontStyle;
		                tooltipEl.style.padding = tooltipModel.yPadding + 'px ' + tooltipModel.xPadding + 'px';
		                tooltipEl.style.pointerEvents = 'none';
		            }
		        }
		    }}; 
	

	$.ajax({
		url:"/account/accountPortal/getAccountMonth.do",
		type:"POST",
		cache: false,
		data:{"payYear" : payYear, "searchType":"user"},
		success:function (data) {
			var chartColorList = [ "rgba(253,207,2,100)","rgba(255,105,101,100)","rgba(101,203,204,100)","rgba(158,112,176,100)","rgba(118.215,116,100)" ];			
			var obj = data.chartObj;
			monthChartObj.data.datasets = 
				obj.monthHeader.reduce(function( acc,cur,idx,arr ){
					var rowHeader = {};				
					rowHeader.label					= 	cur.Name;
					rowHeader.data 					= 	obj.monthList.map(function(item,idx){ return item["SUM_"+cur.Code] ? item["SUM_"+cur.Code] : 0 }); 
					rowHeader.backgroundColor 		=	chartColorList[idx] 
					rowHeader.hoverBackgroundColor	=	chartColorList[idx]
					rowHeader.borderColor			=	'rgb(255, 255, 255)'
					return acc = acc.concat( rowHeader );
				},[]);			
			var chart = new Chart(  $("#account_portal_user_month_chart"), monthChartObj ); 
			$('#account_portal_user_year_flow').text( data.payYear );
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror("/account/accountPortal/getAccountUserMonth.do", response, status, error);
		}
	});
}
function mobile_account_portalAccountSlide(idx){
	$("#account_portal_user_account_slide a").removeClass('Slideroll_btn_on').addClass('Slideroll_btn_off');
	$("#account_portal_user_account_chart ul").hide();

	$('#account_portal_user_account_slide a').eq(idx).removeClass('Slideroll_btn_off').addClass('Slideroll_btn_on');
	$('#account_portal_user_account_chart ul').eq(idx).show();	
}

function mobile_account_PortalLinkClick(mode) {
	var sURL;
	
	if(mode == "Portal") {
		sURL = "/account/mobile/account/portal.do";	
	}
	else {
		sURL = "/account/mobile/account/list.do";
	}
	
	mobile_account_ChangeMenu(sURL, mode);
}

//상단메뉴(PC 좌측메뉴) 그리기
function mobile_account_getTopMenuHtml(menuData) {
    var menuHtml = "";
    var bizHtml = "";
    
	// 권한있는 담당업무함, 업무문서함 카운트 가져오기
	var l_ActiveModule = mobile_approval_getActiveModule();
	var sBusinessData1 = l_ActiveModule.toUpperCase(); // 전자결재 결재함, e-Accounting 비용결재함 구분
	var mJobBizBoxCnt = new Object();
	var url = "/approval/mobile/approval/getNotDocReadCnt.do";
	$.ajax({
		url: url,
		data: {
			businessData1: sBusinessData1
		},
		type: "post",
		async:false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				mJobBizBoxCnt["JobFunction"] = response.jobFunction_Cnt;
				mJobBizBoxCnt["BizDoc"] = response.bizDoc_tcNDRCnt;
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	
    menuHtml += "<ul class=\"h_tree_menu_wrap\">";
    
    //모바일에만 존재하는 메뉴 그리기
    if(mobile_comm_getBaseConfig("useMobileAccountWrite") == "Y" || mobile_comm_getBaseConfig("useMobileAccountWriteUser").indexOf(mobile_comm_getSession("UR_Code")) > -1) {
        //menuHtml += mobile_account_getMenuHtml("/account/mobile/account/list.do", "AppExpence", "lbl_expenceApplication", true, "0");	//경비신청
		var tmpMenu = new Object();
		tmpMenu["MobileURL"] = "/account/mobile/account/list.do";
		tmpMenu["Reserved1"] = "AppExpence";
		tmpMenu["DisplayName"] = mobile_comm_getDic("lbl_expenceApplication");
		tmpMenu["MenuID"] = "0";
		menuHtml += mobile_account_getMenuHtml(tmpMenu, mJobBizBoxCnt);
    }
    
    //PC와 같이 사용하는 메뉴
    $(menuData).each(function (i, menu){
    	if(menu.MobileURL != undefined && menu.MobileURL != "" && menu.IsUse == "Y") {
    		//menuHtml += mobile_account_getMenuHtml(menu.MobileURL, menu.Reserved1, menu.MultiDisplayName, false, menu.MenuID);
			menuHtml += mobile_account_getMenuHtml(menu, mJobBizBoxCnt);
    	}
    	
    	if(menu.Sub.length > 0) {
    		$(menu.Sub).each(function (i, submenu){
    	    	if(submenu.MobileURL != undefined && submenu.MobileURL != "" && submenu.IsUse == "Y") {
    	    		//menuHtml += mobile_account_getMenuHtml(submenu.MobileURL, submenu.Reserved1, submenu.MultiDisplayName, false, submenu.MenuID);
					menuHtml += mobile_account_getMenuHtml(submenu, mJobBizBoxCnt);
    	    	}
    	    });
    	}
    });
    
    menuHtml += "</ul>";
    
    return menuHtml;
}

//메뉴 1개에 대한 HTML 리턴
function mobile_account_getMenuHtml(pMenu, pJobBizBoxCnt) {
	var subMenu_jobBiz = []; // 하위메뉴(담당업무함,업무문서함만 사용)
	var sALink = "";
    var menuHtml = "";
	var isTeams = false;
	try {
		if (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) {
			isTeams = true;
		}
	} catch(e) { coviCmn.traceLog(e); }
	if(isTeams == true && pMenu.Reserved1=="AppExpence") return menuHtml;
	
	// 담당업무함/업무문서함인경우(임의로 하위메뉴생성)
	if(pMenu.Reserved1 == "JobFunction" || pMenu.Reserved1 == "BizDoc"){
		if(!pJobBizBoxCnt[pMenu.Reserved1]) return ""; // 권한있는 문서함이 없으면 표시안함
		
		var tmpSubType = [];
		switch(pMenu.Reserved1){
			case "JobFunction": tmpSubType = ["Approval","Process","Complete","Reject"]; break; // 미결,진행,완료,반려
			case "BizDoc": tmpSubType = ["Process","Complete"]; break; // 진행,완료
		}
		
		tmpSubType.forEach(function(item,idx){
			var tmpSub = {};
			tmpSub.MobileURL = pMenu.MobileURL;
			tmpSub.Reserved1 = pMenu.Reserved1 + item;
			tmpSub.DisplayName = mobile_comm_getDic("tte_" + item + "ListBox");
			subMenu_jobBiz.push(tmpSub);
		});
	}
	
	menuHtml += "<li mode=\"" + pMenu.Reserved1 + "\" displayname=\"" + pMenu.DisplayName + "\">";
	menuHtml += "    <div class=\"h_tree_menu\">";
	
	if(subMenu_jobBiz.length > 0) {
		
		sALink = "javascript: mobile_approval_openclose('li_sub_" + pMenu.MenuID + "', 'span_menu_" + pMenu.MenuID + "');";
		
		menuHtml += "    <ul class=\"h_tree_menu_list\">";
		menuHtml += "        <li>";
		menuHtml += "            <a onclick=\"" + sALink + "\" class=\"t_link not_tree\">";
		menuHtml += "                <span id=\"span_menu_" + pMenu.MenuID + "\" class=\"t_ico_open\"></span><span class=\"" + mobile_account_getMenuClass(pMenu.Reserved1) + "\"></span>";
		menuHtml += "                " + pMenu.DisplayName;
		menuHtml += "            </a>";
		menuHtml += "        </li>";
		menuHtml += "    </ul>";
	} else {
		sALink = "javascript: mobile_account_ChangeMenu('" + pMenu.MobileURL + "','" + pMenu.Reserved1 + "'); return false;";
		
		menuHtml += "    	<a onclick=\"" + sALink + "\" class=\"t_link\">";
		menuHtml += "        <span class=\"" + mobile_account_getMenuClass(pMenu.Reserved1) + "\"></span>" + pMenu.DisplayName;
		menuHtml += "    	</a>";
	}
	menuHtml += "    </div>";
	menuHtml += "</li>";
	
	if(subMenu_jobBiz.length > 0) {
		menuHtml += "<li id=\"li_sub_" + pMenu.MenuID + "\">";
		menuHtml += "    <ul class=\"sub_list\">";

		var parentDisplayName = (pMenu.DisplayName) ? (pMenu.DisplayName + " - ") : "";
		$(subMenu_jobBiz).each(function (j, subdata){
			sALink = "javascript: mobile_account_ChangeMenu('" + subdata.MobileURL + "','" + subdata.Reserved1 + "'); return false;";
			
			menuHtml += "    <li mode=\"" + subdata.Reserved1 + "\" displayname=\"" + parentDisplayName + subdata.DisplayName + "\">";
			menuHtml += "        <a onclick=\"" + sALink + "\" class=\"t_link\">";
			menuHtml += "            <span class=\"t_ico_board\"></span>";
			menuHtml += "            " + subdata.DisplayName;
			menuHtml += "        </a>";
			menuHtml += "    </li>";
		});
		menuHtml += "    </ul>";
		menuHtml += "</li>";
	}
		
	return menuHtml;
}

//상단 메뉴명 셋팅
function mobile_account_getTopMenuName() {
	var oActivePage = $("#" + $.mobile.activePage.attr("id"));
	var oTopMenu = $(oActivePage).find("div[id^='account_'][id$='_topmenu']");
	var oTopTitle = $(oActivePage).find("span[id^='account_'][id$='_title']");
	var sTopMenuTxt;
	
	//선택된 메뉴명 찾기
	//sTopMenuTxt = $(oTopMenu).find("li:has(a.selected)").attr("displayname");
	sTopMenuTxt = $(oTopMenu).find("li:has(a.selected)[displayname]").attr("displayname"); // 하위메뉴명 가져오기
	
	//타이틀 세팅
	$(oTopTitle).html("<span class=\"Tit\">" + sTopMenuTxt + "</span>");
}

//좌측메뉴별 클래스 리턴
function mobile_account_getMenuClass(menuAlias) {
	var menu_class = "";

	//TODO: 출장신청사전품의, 팀원사용현황, 예산대비사용현황 추가 필요
	
	if(menuAlias != undefined){
		switch(menuAlias) {
		case "ApprovalList_Approval":	//경비승인대기
			menu_class = "t_ico_nea_01";
			break;
		case "ApprovalList_Process":	//경비진행함
			menu_class = "t_ico_nea_02";
			break;
		case "AppExpence":				//경비신청
			menu_class = "t_ico_nea_03";
			break;
		case "ExpenceMgr":				//전표조회
			menu_class = "t_ico_nea_04";
			break;
		case "JobFunction":				//담당업무함
			menu_class = "t_ico_approval";
			break;
		case "BizDoc":				//업무문서함
			menu_class = "t_ico_documents";
			break;
		case "Sub":				//하위메뉴
			menu_class = "t_ico_board";
			break;
		default:
			menu_class = "t_ico_app";
				break;
		}
	}	
	
	return menu_class;
}

//상단메뉴 change
function mobile_account_ChangeMenu(pUrl, pMode) {
	var oActivePage = $("#" + $.mobile.activePage.attr("id"));
	var oTopMenu = $(oActivePage).find("div[id^='account_'][id$='_topmenu']");
	
	if(pMode == undefined || pMode == 'undefined' || pMode == '') {
		pMode = "AppExpence";
	}
	
	//현재 선택한 메뉴에 대한 선택 정보 저장, 검색정보 초기화, 리스트 모드 초기화
	window.sessionStorage.setItem("AccountSelectBox", pMode);
	mobile_comm_TopMenuClick($(oTopMenu).attr("id"), true);

	if(location.href.indexOf(pUrl) == -1) {
		mobile_comm_go(pUrl);
	}
	else if(pMode != "Portal"){
		//전표조회 리스트 유형 옵션 바인딩
		if (pMode == "ExpenceMgr") {
			mobile_account_bindBaseCode("ExpAppSearchType", "account_list_expenceAppMngUserListType");
		}
		
		//현재 선택된 상단 메뉴 selected 표시
		$(oTopMenu).find("a.t_link").removeClass("selected");
		$(oTopMenu).find("li[mode='" + pMode + "']").find("a.t_link").addClass("selected");
		
		mobile_account_ChangeFolder(pMode);
	}
	
	// 메뉴 변경 후 전체선택 영역 재설정
	$("div[id^=account_list_div_allchk_]").hide();
	$("div#account_list_div_allchk").hide();
	$("#account_list_chkcnt").html("");
	$("#account_list_chkamount").html("");
	$("#account_list_allchk").prop("checked", false).checkboxradio('refresh');
	
}

//리스트 변경
function mobile_account_ChangeFolder(pMode) {
	if(pMode == undefined || pMode == 'undefined' || pMode == '') {
		pMode = _mobile_account_list.Mode;
	}
	
	_mobile_account_list.Mode = pMode;
	_mobile_account_list.SearchText = '';
	_mobile_account_list.Page = 1;
	_mobile_account_list.ListType = 'list';
	_mobile_account_list.EndOfList = false;
	
	/*if(_mobile_account_list.Mode == "TempSave") {
		$("#approval_search_input").attr("placeholder", mobile_comm_getDic("msg_apv_searchByTitle"));
		_mobile_account_list.SearchType = "Subject";
	} else {
		$("#approval_search_input").attr("placeholder", mobile_comm_getDic("msg_apv_searchBy"));
		_mobile_account_list.SearchType = "all";
	}*/

	$('#account_list_expensetype > option:eq(0)').prop("selected", true);
	
	mobile_approval_setJobBizBox(_mobile_account_list.Mode, true); // 담당업무/업무문서 함 셋팅
	mobile_account_getList(_mobile_account_list);
	mobile_account_getDropmenuList(_mobile_account_list);
}

//마감일자 정보 조회
function mobile_account_setDeadlineInfo(pMode) {
	$.ajax({
		type : "POST",
		data : {
			"companyCode": mobile_comm_getSession("DN_Code")
		},
		url : "/account/mobile/account/getDeadlineInfo.do",
		success : function(data) {
			if (data.status == "SUCCESS"){
				if(data.list != null && data.list.length > 0){
					var oDeadline = data.list[0];
					
					switch(pMode) {
					case "P": // 포탈
						if(_iphone) { //ios Date함수 이용시 yyyy/mm/dd 형식을 사용해야함.
							oDeadline.DeadlineFinishDate = oDeadline.DeadlineFinishDate.replaceAll(".", "/");
						}
						var oFinishDate = new Date(oDeadline.DeadlineFinishDate);
						var iMonth = oFinishDate.getMonth() + 1;
						var iDate = oFinishDate.getDate();
						var standardMonth = oDeadline.StandardMonth == "01" ? iMonth-1 : iMonth;
						var sDeadlineHTML = mobile_comm_getDic("ACC_041");	//@@{Month} 경비 마감일 @@{Deadline}까지
						var sMonthHTML = "<span class='nea_portal_tx_p'>" + standardMonth + mobile_comm_getDic("ACC_lbl_month") + "</span>&nbsp;";
						var sDateHTML =  "&nbsp;\"<span class='nea_portal_tx_p'>" + iMonth + mobile_comm_getDic("ACC_lbl_month") + "&nbsp;" + iDate + mobile_comm_getDic("ACC_lbl_day") + "</span>\"";
							
						sDeadlineHTML = sDeadlineHTML.replace("@@{Month}", sMonthHTML);
						sDeadlineHTML = sDeadlineHTML.replace("@@{Deadlind}", sDateHTML);
						
						$("#account_portal_deadline").html(sDeadlineHTML); // 마감일자 세팅
						$("#ul_account_portal_Notice").find(".nea_portal_top_link").text(oDeadline.NoticeText); // 공지사항 세팅
						break;
					case "W": // 비용 신청
						_mobile_account_write.DeadlineSDate = new Date(oDeadline.DeadlineStartDate);
						_mobile_account_write.DeadlineEDate = new Date(oDeadline.DeadlineFinishDate);
						break;
					}
				}
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/account/mobile/account/getDeadlineInfo.do", response, status, error);
		}
	});
}

//e-Accounting 출장품의 작성
function mobile_account_writeBizTripForm() {
	var sFormPrefix = mobile_comm_getBaseConfig("BizTripForm_EAccount");
	
	mobile_approval_clickwrite(sFormPrefix);
}

/* 
 * 
 * 목록 페이지 시작
 * 
 */
var _mobile_account_list = {
		
	// 리스트 조회 초기 데이터
	Page: 1,			//조회할 페이지
	PageSize: 10,		//페이지당 건수
	SearchText: '',		//검색어
	JobBizKey: '',		//담당업무,업무문서 함 키값
	
	// 페이징을 위한 데이터
	Loading: false,		//데이터 조회 중
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,	//전체 리스트를 다 보여줬는지
	isPopup: false,		//팝업리스트 여부
	
	//스크롤 위치 고정
	OnBack: false,		//뒤로가기로 왔을 경우
	Scroll: 0,			//스크롤 위치
	
	//현재 목록 유형
	Mode: '', 			//리스트 타입
	//SubMode: '', 		//서브 리스트 타입
	ExpenseType: 'A',	//경비신청 화면 내 경비 구분
		
	//비용신청 가능 ReceiptID
	RealReceiptID: '',
	
	//searchProperty(DB, SOAP, SAP ...)
	SearchProperty: ''	
};

//공통 리스트 초기화
function mobile_account_ListInit(mode) {
	if(window.sessionStorage["account_writeinit"] == "Y")
		window.sessionStorage.removeItem('account_writeinit');
	
	if (mobile_comm_getQueryString('page') != 'undefined') {
		_mobile_account_list.Page = mobile_comm_getQueryString('page');
	} else {
		_mobile_account_list.Page = 1;
	}	
	if (mobile_comm_getQueryString('searchtext') != 'undefined') {
		_mobile_account_list.SearchText = mobile_comm_getQueryString('searchtext');
	} else {
		_mobile_account_list.SearchText = '';
	}
	if (mobile_comm_getQueryString('onback') != 'undefined') {
		_mobile_account_list.OnBack = mobile_comm_getQueryString('onback');
	} else {
		_mobile_account_list.OnBack = false;
	}
	if (mobile_comm_getQueryString('scroll') != 'undefined') {
		_mobile_account_list.Scroll = mobile_comm_getQueryString('scroll');
	} else {
		_mobile_account_list.Scroll = 0;
	}
	if(mode != undefined) {
		_mobile_account_list.Mode = mode;		
	} else if (mobile_comm_getQueryString('mode') != 'undefined' && _mobile_account_list.Mode == "") {
		_mobile_account_list.Mode = mobile_comm_getQueryString('mode');
	} else {
		_mobile_account_list.Mode = "";
	}
	if(_mobile_account_list.Mode == "") {
		if(window.sessionStorage.getItem("AccountSelectBox") != undefined && window.sessionStorage.getItem("AccountSelectBox") != "") {
			_mobile_account_list.Mode = window.sessionStorage.getItem("AccountSelectBox");
		}
		else {
			_mobile_account_list.Mode = "AppExpence";
		}
	}
	if (mobile_comm_getQueryString('jobBizCode') != 'undefined' && mobile_comm_getQueryString('jobBizCode') != "" && _mobile_account_list.JobBizKey == "") {
		_mobile_account_list.JobBizKey = mobile_comm_getQueryString('jobBizCode');
    } 
	
	_mobile_account_list.SearchProperty = mobile_account_getSearchProperty();
	
	//좌측메뉴 표시
	$('#account_list_topmenu').html(mobile_account_getTopMenuHtml(AccountMenu));
		
	$("#account_list_topmenu").find("li").each(function() { 
		if($(this).attr("mode") == _mobile_account_list.Mode) 
			$(this).find("a").addClass("selected");
	});
	
	//콤보박스 바인딩
	if (_mobile_account_list.Mode == "ExpenceMgr") {
		mobile_account_bindBaseCode("ExpAppSearchType", "account_list_expenceAppMngUserListType");
	}
	
	mobile_approval_setJobBizBox(_mobile_account_list.Mode); // 담당업무/업무문서 함 셋팅
	
	//목록 표시
	mobile_account_getList(_mobile_account_list);
	
	//버튼 영역 표시
	mobile_account_getDropmenuList(_mobile_account_list);
	
	//datepicker
	mobile_account_datepickerLoad();
}

//기초코드를 콤보박스에 바인딩
function mobile_account_bindBaseCode(pCodeGroups, pObjID) {
	var sURL = "/account/accountCommon/getBaseCodeCombo.do";
	var selObj = $("#" + pObjID);
	
	$.ajax({
		type: "POST",
		data: {
			"codeGroups" : pCodeGroups
		},
		url: sURL,
		async: false,
		success: function (data) {
			if(data.status == "SUCCESS") {
				$.each(data.list[0][pCodeGroups], function(i, baseCode) {
					$(selObj).append($('<option>', { value: baseCode.Code, text : baseCode.CodeName }));
				});
				
				$(selObj).find("option").eq(0).attr("selected", "selected");
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror(sURL, response, status, error);
		}
	});
}

//리스트 가져오기
function mobile_account_getList(pListObj) {
	//mobile_comm_showload();
    
	var sURL = "";
	var sListMode = pListObj.Mode;
	var sListObjID = $.mobile.activePage.attr("id").split("_")[1];
	var paramData;
	var isJobBiz = false; // 담당업무함,업무문서함 여부

	// 팝업 여부에 따른 세팅
	if(!pListObj.isPopup) {
		mobile_comm_TopMenuClick('account_' + sListObjID + '_topmenu',true);
	    $('#account_' + sListObjID + '_cond').hide();
	    $('#account_' + sListObjID + '_more').hide();
	}
    
    if(sListMode.indexOf("_") > -1) {
    	sListMode = sListMode.split("_")[0];
    }
    
	if(sListMode.indexOf("JobFunction") > -1 || sListMode.indexOf("BizDoc") > -1) {
		sListMode = "ApprovalList"; // 담당업무함,업무문서함도 결재리스트와 같은방식
		isJobBiz = true;
	}
		
    // 파라미터 세팅
    paramData = mobile_account_getListParam(sListMode, pListObj);
	
    // URL 세팅
    switch(sListMode) {
    case "AppExpence":			//비용신청목록
    	// 증빙 종류에 따른 조회
    	switch(pListObj.ExpenseType){
    	case "A":				//전체
    		sURL = "/account/mobile/account/getCorpCardAndReceiptList.do";
    		break;
    	case "C":				//법인카드
    		sURL = "/account/mobile/account/getCorpCardList.do";
    		break;
    	case "M":				//모바일 영수증
    		sURL = "/account/mobile/account/getReceiptList.do";
    		break;
    	}
    	
	    $('#account_list_cond').show();
    	break;
    case "ExpenceMgr":			//전표조회
    	sURL = "/account/mobile/account/getExpenceApplicationUserList.do";	
    	break;
    case "ApprovalList":		//비용결재함
    	sURL = "/approval/mobile/approval/getMobileApprovalListData.do";
		if(isJobBiz) sURL = "/approval/mobile/approval/getMobileJobBizApprovalListData.do";
    	break;
    case "CostCenterSearch":	//코스트센터 검색 팝업
    	sURL = "/account/mobile/account/getCostCenterSearchPopupList.do";	
    	break;
    case "IOSearch":			//IO 검색 팝업
    	sURL = "/account/mobile/account/getBaseCodeSearchCommPopupList.do";	
    	break;
    default: 
    	break;
    }
	
	$.ajax({
		type: "POST",
		data: paramData,
		url: sURL,
		async: false,
		success: function (data) {
			if(data.status == "SUCCESS") {
				var sHtml = "";
				 
				_mobile_account_list.TotalCount = data.page.listCount;
				
				$('#account_' + sListObjID + '_list').removeAttr("class");
				
				// 각 리스트 화면별 HTML 리턴
				if(typeof window["mobile_account_get" + sListMode + "ListHtml"] == "function") {
					console.log("mobile_account_get" + sListMode + "ListHtml");
					sHtml = window["mobile_account_get" + sListMode + "ListHtml"](data.list);
			    }
				
				if(pListObj.Page == 1 || sHtml.indexOf("no_list") > -1) {
					$('#account_' + sListObjID + '_list').html(sHtml);
				} else {
					$('#account_' + sListObjID + '_list').append(sHtml);
				}
				
				if (Math.min((_mobile_account_list.Page) * _mobile_account_list.PageSize, _mobile_account_list.TotalCount) == _mobile_account_list.TotalCount) {
					pListObj.EndOfList = true;
	                $('#account_' + sListObjID + '_more').hide();
	            } else {
					pListObj.EndOfList = false;
	                $('#account_' + sListObjID + '_more').show();
	            }
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror(sURL, response, status, error);
		}
	});
	
	// 팝업 여부에 따른 세팅
	if(!pListObj.isPopup) {
		mobile_account_getTopMenuName();
	}

	//checkbox show
	$('#account_' + sListObjID + '_list').trigger("create");
}

//리스트별 파라미터 세팅
function mobile_account_getListParam(pMode, pListObj) {
	var listViewParams;

    switch(pMode) {
    case "AppExpence":				//비용신청목록
//    	var date = new Date();
//        var year  = date.getFullYear();
//        var month = date.getMonth() + 1;
//        var day   = date.getDate();
        
    	listViewParams = {
			"pageNo": pListObj.Page,
			"pageSize": pListObj.PageSize,
			"SDate"	: '', //(year-1)+"-"+mobile_account_addZero(month)+"-"+mobile_account_addZero(day),
			"EDate"	: '', //(year+1)+"-"+mobile_account_addZero(month)+"-"+mobile_account_addZero(day)
			"searchProperty" : pListObj.SearchProperty
		};
    	break;
    case "ExpenceMgr":				//전표조회
    	var searchParam = {
    		"SearchType": $("#account_list_expenceAppMngUserListType option:selected").val()
    	};
    	
    	listViewParams = {
    		"searchParam" : JSON.stringify(searchParam),
			"pageNo": pListObj.Page,
			"pageSize": pListObj.PageSize,
    	}
    	break;
    case "ApprovalList":			//비용결재함,담당업무함,업무문서함
    	var apvMode = pListObj.Mode;
		if(apvMode.indexOf("_") > -1) apvMode = pListObj.Mode.split("_")[1];
			
    	listViewParams = {
    		userID: mobile_comm_getSession("USERID"),
    		deptID: mobile_comm_getSession("GR_Code"),
    		mode: apvMode,
    		titleNm: "",
    		userNm: "", //mobile_comm_getSession("USERNAME"),
    		pageNo: pListObj.Page,
    		pageSize: pListObj.PageSize,
    		searchType: pListObj.SearchType,
    		searchWord: pListObj.SearchText,
    		businessData1: $.mobile.activePage.attr("id").split("_")[0].toUpperCase(),
			jobBizKey : pListObj.JobBizKey
    	};
    	break;
    case "CostCenterSearch":		//코스트센터 검색 팝업
    	listViewParams = {
			"searchStr": pListObj.SearchText,
			"pageNo": pListObj.Page,
			"pageSize"	: pListObj.PageSize,
			"companyCode" : _mobile_account_write.CompanyCode
		};
    	break;
    case "IOSearch":		//코스트센터 검색 팝업
    	listViewParams = {
			"searchText": pListObj.SearchText,
			"codeGroup": "IOCode",
			"pageNo": pListObj.Page,
			"pageSize"	: pListObj.PageSize,
			"companyCode" : _mobile_account_write.CompanyCode
		};
    	break;
	default:
		break;
    }
	
	return listViewParams;
}

//경비신청 목록 HTML 리턴
function mobile_account_getAppExpenceListHtml(list) {
	var sHtml = "";
	
	if(list.length > 0) {
		$(list).each(function (i, obj){
			var iTotalAmount = 0;
			var sDisplayDate;
			var isReceiptYN = "";
			var sProofCode = "";
			
			// 총액 콤마 삽입
			if(obj.TotalAmount) {
				iTotalAmount = mobile_comm_addComma(obj.TotalAmount.toString().trim().replace(/,/gi, ''));
			}
			
			// 증빙별 코드값 계산
			switch(_mobile_account_list.ExpenseType){
	    	case "A":				//전체
	    		sProofCode = obj.ProofCode;
	    		break;
	    	case "C":				//법인카드
	    		sProofCode = "CorpCard";
	    		break;
	    	case "M":				//모바일 영수증
	    		sProofCode = "Receipt";
	    		break;
	    	}
			
			if(sProofCode.toLowerCase() == "corpcard") {
				sDisplayDate = obj.ApproveDate;
			}
			else {
				sDisplayDate = obj.RegistDate;
				isReceiptYN = "mobile";
			}
			
			sHtml += "<li id='account_list_li_" + obj.ReceiptID + "'>";
			sHtml += "	<div class='card_chk'>";
			sHtml += "		<input type='checkbox' value='" + obj.ReceiptID + "' proofCode='" + obj.ProofCode + "' id='account_list_chk_" + (((_mobile_account_list.Page-1) * _mobile_account_list.PageSize) + i) + "' name='account_list_chkbox' onchange='mobile_account_showAllChk();'><label for='account_list_chk_" + (((_mobile_account_list.Page-1) * _mobile_account_list.PageSize) + i) + "'></label>";
			sHtml += "	</div>";
			sHtml += "	<a class='nea_card_con " + isReceiptYN + "' onclick='mobile_account_viewReceiptDetail(\"" + sProofCode + "\",\"" + obj.ReceiptID + "\", \"" + obj.ReceiptFileID + "\", \"" + obj.ApproveNo + "\")'>";
			sHtml += "		<p class='tx_cost'><span class='tx_cost_pc'>" + iTotalAmount + "</span>" + mobile_comm_getDic("ACC_lbl_won") + "</p>";
			sHtml += "		<p class='tx_cont ellip'>" + mobile_account_nullToBlank(obj.StoreName) + "</p>"; //TODO : 모바일 영수증 추후 영수증 데이터 스캔을 통해 데이터 읽어들일 예정
			sHtml += "		<p class='tx_date'>" + sDisplayDate + "</p>";
			sHtml += "		<p class='tx_txt'>" + obj.UsageText + "</p>";
			sHtml += "		<a class='btn_bill' onclick='javascript: mobile_account_showPopup(\"" + sProofCode + "\",\"" + obj.ReceiptID + "\", \"" + mobile_account_nullToBlank(obj.ReceiptFileID) + "\", \"" + mobile_account_nullToBlank(obj.ApproveNo) + "\"); return false;'><span>" + mobile_comm_getDic("ACC_lbl_receipt") + "</span><a>";
			sHtml += "	</a>";
			sHtml += "		<a class='btn_eaccounting_del' active='" + obj.Active + "' onclick='javascript: mobile_account_delete(\"" + sProofCode + "\", \"" + obj.ReceiptID + "\"); return false;'><span>" + mobile_comm_getDic("ACC_lbl_exceptApplication") + "</span></a>";
			sHtml += "</li>";
		});
	} 
	else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}

//비용결재함 HTML 리턴
function mobile_account_getApprovalListListHtml(list) {
	var sHtml = "";
	var subkind = "";
	var userID = "";
	var mode = "";
	var gloct = "";
	var archived = "false";
	var bUseTotalApproval = mobile_comm_getBaseConfig("useTotalApproval");
	var g_mode = _mobile_account_list.Mode;
	
	if(g_mode.indexOf("_") > -1) {
    	g_mode = g_mode.split("_")[1];
    }
	
	$('#account_list_list').addClass("nea_approval_list");
	
	if(list.length > 0) {
		$(list).each(function (i, obj){
			var sUrl_Module = "approval";
			var sUrl = "";
			var sDate = "";
			var sEmer = "";
			var sSec = "";
			var sFile = "";
			var sName = "";
			var sRead = "";
			var gotoUrl = "view";
			var bAccount = false;
			
			obj.Subject = mobile_approval_replaceCharacter(obj.Subject);
			
			switch (g_mode){
				//개인함
				case "PreApproval" 		: mode = "PREAPPROVAL"; gloct = "PREAPPROVAL"; subkind="T010"; userID=obj.UserCode; break; // 예고함
				case "Approval" 		: mode = "APPROVAL"; gloct = "APPROVAL"; subkind=obj.FormSubKind; userID=obj.UserCode; break;    // 미결함
				case "Process" 			: mode = "PROCESS"; gloct = "PROCESS"; subkind=obj.FormSubKind; userID=obj.UserCode; break;		// 진행함
				case "Complete" 		: mode = "COMPLETE"; gloct = "COMPLETE"; subkind=obj.FormSubKind; archived="true"; userID=obj.UserCode; break;	// 완료함
				case "Reject" 			: mode = "REJECT"; gloct = "REJECT";  subkind=obj.FormSubKind; archived="true"; userID=obj.UserCode; break;		// 반려함
				case "TempSave" 		: mode = "TEMPSAVE"; gloct = "TEMPSAVE"; subkind="";  userID=""; gotoUrl="write"; break;	// 임시함
				case "TCInfo" 			: mode = "COMPLETE"; gloct = "TCINFO"; subkind=obj.FormSubKind; userID=""; break;		// 참조/회람함
				//부서함
				case "DeptComplete"		: mode = "COMPLETE"; gloct = "DEPART"; subkind="A"; archived="true"; userID = obj.UserCode; break; // 완료함
				case "SenderComplete" 	: mode = "COMPLETE"; gloct = "DEPART"; subkind="S"; archived="true"; userID = obj.UserCode; break;    // 발신함
				case "Receive" 			: mode = "REDRAFT"; gloct = "DEPART"; subkind=obj.FormSubKind; userID = obj.UserCode; break;		// 수신함
				case "ReceiveComplete" 	: mode = "COMPLETE"; gloct = "DEPART"; subkind="REQCMP"; archived="true"; userID = obj.UserCode; break;	// 수신처리함
				case "DeptTCInfo" 		: mode = "COMPLETE"; gloct = "DEPART"; subkind=obj.FormSubKind; userID = obj.ReceiptID; break;		// 참조/회람함
				case "DeptProcess" 		: mode = "PROCESS"; gloct = "DEPART"; subkind=obj.FormSubKind; userID = obj.UserCode; break;	// 진행함
				// 담당업무함
				case "JobFunctionApproval" 	: mode = "APPROVAL"; gloct = "JOBFUNCTION"; subkind=obj.FormSubKind; userID = $("#account_list_Jobfunction").val(); break; // 담당업무 미결함 REDRAFT Created
				case "JobFunctionProcess" 	: mode = "PROCESS"; gloct = "JOBFUNCTION"; subkind=obj.FormSubKind; userID = $("#account_list_Jobfunction").val(); break; // 담당업무 진행함 RECAPPROVAL Created
				case "JobFunctionComplete" 	: mode = "COMPLETE"; gloct = "JOBFUNCTION"; subkind=obj.FormSubKind; archived="true"; userID = $("#account_list_Jobfunction").val(); break; // 담당업무 완료함 COMPLETE Finished
				case "JobFunctionReject" 	: mode = "REJECT"; gloct = "JOBFUNCTION"; subkind=obj.FormSubKind; archived="true"; userID = $("#account_list_Jobfunction").val(); break; // 담당업무 반려함 REJECT Finished
				// 업무문서함
				case "BizDocProcess" 		: mode = "PROCESS"; gloct = "BizDoc"; subkind="T006"; userID = $("#account_list_BizDoc").val(); break; // 업무문서함 진행함 StartDate
				case "BizDocComplete" 		: mode = "COMPLETE"; gloct = "BizDoc"; subkind="T006"; archived="true"; userID = $("#account_list_BizDoc").val(); break; // 업무문서함 완료함 EndDate
			}
			
			// 통합결재 사용 시 e-Accounting 조회 여부 체크
			if(bUseTotalApproval == "Y" && obj.BusinessData1 == "ACCOUNT") {
				bAccount = true;
				sUrl_Module = "account";
			}
			
			sUrl = "/" + sUrl_Module + "/mobile/" + sUrl_Module + "/" + gotoUrl + ".do";
			sUrl += "?mode=" + mode;
			if(bAccount) {
				//sUrl += "&expAppID=" + obj.BusinessData2;
				sUrl += "&expAppID=" + ((typeof obj.BusinessData2!="undefined"&&obj.BusinessData2!="undefined")?obj.BusinessData2:"");	//비용 결재문서의 경비신청서 키값
				//sUrl += "&isTotalApv=" + bUseTotalApproval;		//통합결재 내 조회여부 (전자결재 리스트에서 경비결재를 띄웠을때 사용됨)
				sUrl += "&taskID="+ obj.TaskID; 			//승인 요청할 활성 TaskID
			}
			if(mode != "TEMPSAVE") {
				var processID = (obj.ProcessID == undefined ? obj.ProcessArchiveID : obj.ProcessID);
				processID = (processID == undefined ? '' : processID);
				var workitemID = (obj.WorkItemID == undefined ? obj.WorkitemArchiveID : obj.WorkItemID);
				workitemID = (workitemID == undefined ? '' : workitemID);
				var performerID = obj.PerformerID;
				performerID = (performerID == undefined ? '' : performerID);
				var processDescriptionID = (obj.ProcessDescriptionID == undefined ? obj.ProcessDescriptionArchiveID : obj.ProcessDescriptionID);
				processDescriptionID = (processDescriptionID == undefined ? '' : processDescriptionID);
				
				sUrl += "&processID=" + processID;
				sUrl += "&workitemID=" + workitemID;
				sUrl += "&performerID=" + performerID;
				sUrl += "&processdescriptionID=" + processDescriptionID;
			}
			sUrl += "&userCode=" + userID;
			sUrl += "&gloct=" + gloct;
			sUrl += "&formID=" + (obj.FormID == undefined ? '' : obj.FormID);
			sUrl += "&forminstanceID=" + obj.FormInstID;
			if(mode == "TEMPSAVE") {
				sUrl += "&formtempID=" + obj.FormTempInstBoxID;
				sUrl += "&forminstancetablename=" + obj.FormInstTableName;
				sUrl += "&open_mode=" + mode;
			}
			sUrl += "&archived=" + archived;
			sUrl += "&subkind=" + subkind;			
			sUrl += "&formPrefix=" + obj.FormPrefix;
			sUrl += "&isMobile=Y";
			sUrl += "&admintype=&usisdocmanager=true&listpreview=N";	
			sUrl += "&page=" + _mobile_approval_list.Page;
			sUrl += "&totalcount=" + _mobile_account_list.TotalCount;
			sUrl += "&listmode=" + g_mode;
			sUrl += "&searchtext=" + _mobile_account_list.SearchText;
			
			// 날짜 계산
			if(g_mode != "TempSave") {
				if(g_mode == "PreApproval" || g_mode == "Approval" || g_mode == "Receive" || g_mode == "DeptProcess" || g_mode == "JobFunctionApproval" || g_mode == "JobFunctionProcess") { //예고함, 미결함, 부서수신함, 진행함(부서) , 담당업무(미결,진행)
					sDate = mobile_comm_getDateTimeString2('list', obj.Created);
				} else if(g_mode == "Process" || g_mode == "JobFunctionComplete" || g_mode == "JobFunctionReject") { //진행함 (개인) , 담당업무(완료,반려)				
					sDate = mobile_comm_getDateTimeString2('list', obj.Finished);
				} else if(g_mode.indexOf("Complete") > -1 || _mobile_account_list.Mode == "Reject") { //완료함/반려함, 부서완료함/발신함/수신처리함 , 업무문서함(완료 BizDocComplete)
					sDate = mobile_comm_getDateTimeString2('list', obj.EndDate);
				} else if(g_mode.indexOf("TCInfo") > -1) { //참조/회람함 (부서, 개인)
					sDate = mobile_comm_getDateTimeString2('list', obj.RegDate);
				} else if(g_mode == "BizDocProcess") { // 업무문서함(진행)
					sDate += mobile_comm_getDateTimeString2('list', obj.StartDate);
				} 
			}
			
			// 아이콘, 스타일 표시
			if(obj.IsFile == "Y") { //첨부
				sFile = "<span class=\"ico_file_clip\"></span>";
			}
			if(obj.Priority == "5") { //긴급결재
				sEmer = "<span class=\"flag_cr01\">" + mobile_comm_getDic("lbl_apv_surveyUrgency") + "</span>";
			}
			if(obj.IsReserved == "Y") { //보류
				sEmer += "<span class=\"flag_cr01\">" + mobile_comm_getDic("lbl_apv_hold") + "</span>";
			}
			if(obj.IsSecureDoc == "Y") { //기밀문서
				sSec = "<span class=\"ico_lock02\"></span>";
			}
			if(obj.ReadDate) { //읽은 문서
				sRead = "read";
			}
			
			sHtml += "<li id='account_list_li_" + g_mode + "_" + _mobile_account_list.Page + "_" + i + "'>";
			
			if(g_mode == "Approval" || g_mode == "Receive" || g_mode.toUpperCase().indexOf("TCINFO") > -1 || g_mode == "Reject" || g_mode == "TempSave" || g_mode == "JobFunctionApproval") {
				sHtml += "	<div class='checkbox'>";
				if(g_mode == "TempSave" || (obj.ExtInfo != undefined && obj.ExtInfo.UseBlocApprove == "Y")) {
					sHtml += "		<input type='checkbox' value='" + JSON.stringify(obj) + "' id='account_list_chk_" + (((_mobile_account_list.Page-1) * _mobile_account_list.PageSize) + i) + "' name='account_list_chkbox' onchange='mobile_account_showAllChk();'>";
				}
				else {
					sHtml += "		<input type='checkbox' value='" + JSON.stringify(obj) + "' id='account_list_chk_" + (((_mobile_account_list.Page-1) * _mobile_account_list.PageSize) + i) + "' name='account_list_chkbox' disabled='disabled'>";
				}
				sHtml += "		<label for='account_list_chk_" + (((_mobile_account_list.Page-1) * _mobile_account_list.PageSize) + i) + "'></label>";
				sHtml += "	</div>";
			}

			sHtml += "	<div class='txt_area' onclick='javascript: mobile_account_goViewApproval(\"" + sUrl + "\");'>";
			sHtml += "	    <p class='title " + sRead + "'>";
			sHtml += "	        <span class='title_tx'>" + sEmer + sSec + obj.FormSubject + sFile + "</span>";
			sHtml += "	        <span class='title_cost'>" + mobile_comm_addComma(Number(obj.BusinessData3.toString().replace(/,/gi, '')).toString()) + "</span>";
			sHtml += "	    </p>";
			sHtml += "	    <div class='list_info'>";
			sHtml += "	        <span class='name'>" + obj.InitiatorName + "</span>";
			sHtml += "	        <span class='team'>" + obj.InitiatorUnitName + "</span>";
			sHtml += "	        <span class='date'>" + sDate + "</span>";
			sHtml += "	        <span class='category'>" + obj.BusinessData4 + "</span>";
			sHtml += "	    </div>";
			sHtml += "	</div>";
			sHtml += "</li>";
		});
	} 
	else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}


//전표조회 HTML 리턴
function mobile_account_getExpenceMgrListHtml(list) {
	var sHtml = "";
	var g_mode = _mobile_account_list.Mode;
	var mode = "";

	$('#account_list_list').addClass("nea_approval_list");
	
	if(list.length > 0) {
		$(list).each(function (i, obj){
			var iTotalAmount = 0;
			var sChargeJobName = "";

			if(obj.AmountSum) {
				iTotalAmount = mobile_comm_addComma(Number(obj.AmountSum.toString().replace(/,/gi, '')).toString());
			}
			
			if(obj.ChargeJob) {
				sChargeJobName = obj.ChargeJob.split("@")[1];
			}
			
			sHtml += "<li id='account_list_li_" + g_mode + "_" + _mobile_account_list.Page + "_" + i + "' onclick='mobile_account_goViewExpence(\"" + obj.ExpenceApplicationID + "\", \"" + obj.ProcessID + "\", \"" + obj.ApplicationType + "\", \"" + obj.RequestType + "\", \"" + obj.ApplicationStatus + "\")'>";
			sHtml += "	<div class='txt_area'>";
			sHtml += "	    <p class='title'>";
			sHtml += "	        <span class='title_tx'>" + obj.ApplicationTitle + "</span>";
			sHtml += "	        <span class='title_cost'>" + iTotalAmount + "</span>";
			sHtml += "	    </p>";
			sHtml += "	    <div class='list_info'>";
			//sHtml += "	    <span class='name'>" + obj.ApplicationTypeName + "</span>";		//신청서 유형
			sHtml += "	        <span class='name'>" + mobile_comm_getDicInfo(sChargeJobName) + "</span>";				//비용신청 유형
			sHtml += "	        <span class='team'>" + obj.ApplicationStatusName + "</span>";	//전표 상태
			sHtml += "	        <span class='date'>" + obj.ApplicationDate + "</span>";			//기안일자
			sHtml += "	    </div>";
			sHtml += "	</div>";
			sHtml += "</li>";
		});
	} 
	else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}

//증빙구분 select 이벤트
function mobile_account_changeExpenseType() {
	var sExpenseType = $("#account_list_expensetype").find("option:selected").val();
	
	if(_mobile_account_list.ExpenseType != sExpenseType) {
		_mobile_account_list.SearchText = '';
		_mobile_account_list.Page = 1;
		_mobile_account_list.ListType = 'list';
		_mobile_account_list.EndOfList = false;
		_mobile_account_list.ExpenseType = sExpenseType;

		mobile_account_checkAll($("#account_list_allchk_" + _mobile_account_list.Mode));
		mobile_account_showAllChk();
		
		mobile_account_getList(_mobile_account_list);
	}
}

//전체선택 div show or hide
function mobile_account_showAllChk() {
	var cnt = 0;
	var amount = 0;
	var obj = $("input[type=checkbox][name=account_list_chkbox]:checked");
	var objcnt = obj.length;
	var oListAllChk;
	var listMode = _mobile_account_list.Mode;
	
	if(listMode.indexOf("_") > -1) {
		listMode = listMode.split("_")[0]
    }

	if($("#account_list_div_allchk_" + listMode).length > 0) {
		oListAllChk = $("#account_list_div_allchk_" + listMode);
	}
	else {
		oListAllChk = $("#account_list_div_allchk");
	}
	
	if(objcnt > 0) {
		$(oListAllChk).show();
		
		for(var i = 0; i < objcnt; i++) {
			if(_mobile_account_list.Mode == "AppExpence") {
				amount += parseInt($(obj).eq(i).closest("li").find(".tx_cost_pc").text().replace(/,/gi, ""));
			}
			
			cnt++;
		}

		if(listMode == "AppExpence") {
			$("#account_list_chkcnt").html(cnt);
			$("#account_list_chkamount").html(mobile_comm_addComma(amount.toString()));
		}
		
		if($("#account_list_list").find("input[type=checkbox][name=account_list_chkbox]:not([disabled=disabled])").length > cnt) {
			$(oListAllChk).find("[name='account_list_allchk']").prop("checked", false).checkboxradio('refresh');
		} else {
			$(oListAllChk).find("[name='account_list_allchk']").prop("checked", true).checkboxradio('refresh');
		}

		// 첫 번째 항목 선택 시 헤더 조회를 위하여 스크롤 조정
		if(cnt == 1) {
			$(document).scrollTop(0);
		}
	}
	else {
		$(oListAllChk).hide();
	}
}

//전체선택 checkbox change
function mobile_account_checkAll(obj) {
	if($(obj).is(":checked")) {
		$("#account_list_list").find("input[type=checkbox][name=account_list_chkbox]:not([disabled=disabled])").prop("checked", true).checkboxradio('refresh');
	} 
	else {
		$("#account_list_list").find("input[type=checkbox][name=account_list_chkbox]").prop("checked", false).checkboxradio('refresh');
	}
	
	mobile_account_showAllChk();
}

//드롭메뉴(PC 버튼 영역) 조회
function mobile_account_getDropmenuList(params) {
	var sHtml = "";
	
	if(params.Mode.indexOf("ApprovalList") > -1) {
    	var apvMode = _mobile_account_list.Mode.split("_")[1];
    	
		if(apvMode.toUpperCase() == "APPROVAL") {
			sHtml += "<li><a onclick=\"mobile_approval_batchApproval('" + apvMode + "');\">" + mobile_comm_getDic("btn_apv_blocApprove") + "</a></li>"; //일괄결재
			sHtml += "<li><a onclick=\"mobile_approval_doDocRead('" + apvMode + "');\">" + mobile_comm_getDic("lbl_apv_ReadCheck") + "</a></li>"; //읽음확인
		}
	}
	if(params.Mode.toUpperCase() == "JOBFUNCTIONAPPROVAL") {
		sHtml += "<li><a onclick=\"mobile_approval_batchApproval('JOBFUNCTION');\">" + mobile_comm_getDic("btn_apv_blocApprove") + "</a></li>"; //일괄결재
	}
	
	$("#account_list_dropmenuitems").empty();
	$("#account_list_dropmenu").closest("div").css("display", "").closest("div").removeClass("show");	
	
	if(sHtml != "") {
		$("#account_list_dropmenuitems").append(sHtml);
	}
	else {
		$("#account_list_dropmenu").closest("div").css("display", "none");
	}
}

function mobile_account_clickDropmenu(obj) {
	if($(obj).closest("div").hasClass("show"))
		$(obj).closest("div").removeClass("show");
	else
		$(obj).closest("div").addClass("show");
}

//법인카드 비용신청 불가 항목 checkbox remove
function mobile_account_getRealReceiptID(list) {
	_mobile_account_list.RealReceiptID = "";
	if($(list).length > 0) {
		$(list).each(function(i, obj) {
			_mobile_account_list.RealReceiptID += obj.ReceiptID + ",";
		});
	}

	/*$("#account_list_card_list").find("li").each(function(i, li){
		if(_mobile_account_list.RealReceiptID.indexOf($(li).attr("id").replace("account_list_card_li", "")) < 0){
			$("#" + $(li).attr("id")).find("input[type=checkbox][id^=account_list_card_chk_]").parents(".card_chk").remove();
			$("#" + $(li).attr("id")).css("padding-left", "36px");
		}
	});*/
}

function mobile_account_getSearchProperty() {
	var searchProperty = "";
	$.ajax({
		type:"POST",
		data:{
			"pageID" : 'CardReceipt'
		},
		url:"/account/accountCommon/getPropertyInfoSearchType.do",
		async	: false,
		success:function (data) {
			try{
				if(data.status == "SUCCESS"){
					searchProperty = data.pageSearchTypeProperty;
				}
			}catch(err){
			coviCmn.traceLog(err);
			}
		},
		error:function (error){
			console.log(error);
		}
	});
	return searchProperty;
}

//e-Accounting 목록 새로고침
function mobile_account_reload() {
	mobile_comm_showload(); 
	
	_mobile_account_list.SearchText = '';
	_mobile_account_list.Page = 1;
	$('#account_list_list').html("");
	
	mobile_account_getList(_mobile_account_list);
	mobile_account_showAllChk();
	mobile_comm_hideload();
}

//경비구분 팝업 setting
function mobile_account_setAppTypePopup() {
	var sHtml = "";
	var sURL = "/account/mobile/account/getBriefCombo.do";
	$.ajax({
		type:"POST",
		data:{
			"isSimp": "Y"
		},
		url:sURL,
		success:function (data) {			
			if(data.status == "SUCCESS") {
				if(data.list.length > 0) {
					$(data.list).each(function(i, obj) {
						//StandardBriefID,StandardBriefName,AccountID,AccountCode,AccountName,StandardBriefDesc,TaxCode,TaxType
						var checked = (i == 0) ? 'checked' : '';
						sHtml += '<label for="account_list_card_radio_' + obj.StandardBriefID + '">' + obj.StandardBriefName + '</label>'
								+ '<input type="radio" name="account_list_card_radio" value="' + obj.StandardBriefID + '" id="account_list_card_radio_' + obj.StandardBriefID + '" ' + checked + '>';
					});
					$("#account_list_card_radio_div").html(sHtml).trigger("create");
				}
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror(sURL, response, status, error);
		}
	});
}

//버튼 클릭
function mobile_account_clickbtn(pObj) {
	var sId = $(pObj).attr("id");
	
	switch(sId) {
		/***포탈, 리스트 공통***/
		case "account_list_application": 	//비용 신청
			mobile_account_goCostApplication();
			break;
		case "account_portal_receipt_up":	//영수증 사진 선택
		case "account_list_receipt_up": 	
			mobile_account_changeupload();
			break;
		case "account_list_card_application_del": //카드-신청제외
			if($("input[type=checkbox][id^=account_list_card_chk_]:checked").length > 0) {
				mobile_account_delete('card');
			} else {
				alert(mobile_comm_getDic("ACC_msg_selectDECorpCardList"));
			}
			break;
		case "account_list_card_popup_ok": //카드-팝업확인 
			mobile_account_goCostApplication();
			break;
		case "account_list_card_popup_cancel": //카드-팝업취소
			$("#account_list_cardpopup").hide();
			$("#account_list_content").css("position", "");
			break;
		case "account_list_card_proof_ok": //카드-영수증확인 
			$("#account_list_card_proof").hide();
			$("#account_list_content").css("position", "");
			break;
		case "account_list_receipt_receipt_del": //영수증-삭제
			if($("input[type=checkbox][id^=account_list_receipt_chk_]:checked").length > 0) {
				mobile_account_delete('receipt');
			} else {
				alert(mobile_comm_getDic("ACC_msg_selectDEReceiptList"));		
			}
			break;
		case "account_list_receipt_popup_ok": //영수증-영수증확인
			$("#account_list_receipt_popup").hide();
			break;
			
		/***영수증 업로드***/
		case "account_upload_popup_ok": 	//영수증 등록
			mobile_account_uploadToBack();
			break;
		case "account_upload_popup_cancel": //영수증 등록 취소
			mobile_account_cancelUpload();
			break;
			
		/***비용 상세조회***/
		case "account_receipt_view_card_modify": 	//법인카드 내역 수정
			mobile_account_modifyCardReceipt();
			break;
		case "account_receipt_view_receipt_modify": //영수증 내역 수정
			mobile_account_modifyMobileReceipt();
			break;
		case "account_receipt_view_receipt_cancel": //영수증 수정 취소
			mobile_comm_back();
			break;
			
		/***비용 작성***/
		case "account_write_del": 					//비용신청-삭제
			if($("input[type=checkbox][id^=account_write_chk_]:checked").length > 0) {
				mobile_account_deleteExpence();
			} else {
				alert(mobile_comm_getDic("ACC_msg_selectDeleteList"));		
			}
			break;
		case "account_write_CC": 					//비용신청-CC
			$("#account_write_cc_popup").show();
			break;
		case "account_write_card_proof_ok": 		//비용신청-법인카드 팝업 확인
			$("#account_write_card_proof").hide();
			break;
		case "account_write_receipt_popup_ok":	 	//비용신청-영수증 팝업 확인
			$("#account_write_receipt_popup").hide();
			break;
		case "account_write_cc_popup_ok": 			//비용신청-코스트센터 팝업 확인
			$("#account_write_cc_popup").hide();
			break;
		case "account_view_cmt_popup_ok": 				//비용신청-결재의견 팝업 확인
			$("#account_view_cmt_popup").hide();
			break;
			
		/***전표 상세조회***/
		case "account_view_card_proof_ok": 			//비용신청-법인카드 팝업 확인
			$("#account_view_card_proof").hide();
			break;
		case "account_view_receipt_popup_ok":
			$("#account_view_receipt_popup").hide();
			break;
			
		/***비용결재함***/
		case "btWithdraw": 				  			//경비진행함-회수
			_mobile_account_view.ActionType = sId.replace("bt", "").toLowerCase();
			mobile_account_doApvAction(_mobile_account_view);
			break;
	}
}

//스크롤 더보기
function mobile_account_list_page_ListAddMore() {
	mobile_account_nextlist(_mobile_account_list);
}

//더보기
function mobile_account_nextlist(pListObj) {
	if(!pListObj) pListObj = _mobile_account_list;
	var sListObjID = $.mobile.activePage.attr("id").split("_")[1];
	
	if (!pListObj.EndOfList) {
		pListObj.Page++;

		mobile_account_getList(pListObj);
		
		if(sListObjID == "list") {
			mobile_account_showAllChk();
		}
    } else {
        $('#account_' + sListObjID + '_more').hide();
    }
}

// 법인카드 증빙/영수증 팝업
function mobile_account_showPopup(pProofCode, pReceiptID, pFileID, pApproveNo){
	var l_ActiveID = $.mobile.activePage.attr("id");
	var sMode = pProofCode.toLowerCase();
	var sCardId = "";
	var sPageMode = "";
	
	if(l_ActiveID.indexOf("write") > -1) {
		sPageMode = "write";
	} else if(l_ActiveID.indexOf("list") > -1) {
		sPageMode = "list";
	} else if(l_ActiveID.indexOf("view") > -1) {
		sPageMode = "view";
	}
	
	sCardId = "account_" + sPageMode + "_card_proof";
	
	if(sMode == "corpcard") { // 법인카드
		$.ajax({
			type:"POST",
			data:{
				receiptID: pReceiptID,
				approveNo: pApproveNo,
				searchProperty: _mobile_account_list.SearchProperty
			},
			url:"/account/mobile/account/getCardReceiptDetail.do",
			success:function (data) {
				if(data.status == "SUCCESS") {
					if(data.list.length > 0) {
						var obj = data.list[0];

						$("#" + sCardId + "_CardNo").text(mobile_comm_getDic("ACC_lbl_cardNumber") + "(" + mobile_account_setCardNo(obj.CardNo) + ")");
						$("#" + sCardId + "_ApproveNo").text(obj.ApproveNo);
						$("#" + sCardId + "_UseDate").text(obj.UseDate);
						$("#" + sCardId + "_PayMethod").text(mobile_comm_getDic("ACC_lbl_lumpSum")); //obj.PayMethod
						$("#" + sCardId + "_StoreName").text(obj.StoreName);
						$("#" + sCardId + "_StoreNo").text(obj.StoreNo);
						$("#" + sCardId + "_StoreRepresentative").text(obj.StoreRepresentative);
						$("#" + sCardId + "_StoreRegNo").text(obj.StoreRegNo);
						$("#" + sCardId + "_StoreTel").text(obj.StoreTel);
						$("#" + sCardId + "_StoreAddress").text(obj.StoreAddress1 + " " + obj.StoreAddress2);
						$("#" + sCardId + "_RepAmount").text(obj.RepAmount);
						$("#" + sCardId + "_TaxAmount").text(obj.TaxAmount);
						$("#" + sCardId + "_ServiceAmount").text(obj.ServiceAmount);
						$("#" + sCardId + "_AmountWon_InfoIndex").text(obj.AmountWon + "(" + obj.InfoIndexName + ")");
						
						$("#" + sCardId).show();
						$("#account_list_content").css("position", "fixed");
					}
				}
			},
			error:function(response, status, error){
			     mobile_comm_ajaxerror(sURL, response, status, error);
			}
		});
	} 
	else if(sMode == "receipt") { // 모바일 영수증
		$.ajax({
			type:"POST",
			data:{
				FileID: pFileID
			},
			url:"/account/EAccountFileCon/getFileURLInfo.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					if(data.info != undefined) {
						var info = data.info;
						var imgURL = "/covicore/common/photo/photo.do?img=" + encodeURIComponent(info.URLPath);
						
						$("#account_" + sPageMode + "_receipt_image").html("<img src='" + mobile_account_getEscapeStr(imgURL) + "'alt='" + pReceiptID + "'>");
						$("#account_" + sPageMode + "_receipt_popup").show();
					}
				}else{
					alert(mobile_comm_getDic("ACC_msg_error")); // data.message	
				}
			},
			error:function(response, status, error){
			     mobile_comm_ajaxerror(sURL, response, status, error);
			}
		});
	}
}

// 법인카드 항목제외/영수증 삭제
function mobile_account_delete(pMode, pReceiptID){	
	var chkList = new Array;
	
	if(pReceiptID != undefined) {
		chkList.push({"ReceiptID" : pReceiptID+""});
	} else {
		if($("input[type=checkbox][id^=account_list_chk_]:checked").length == 0){
			alert(mobile_comm_getDic("ACC_msg_noSelectedList"));
			return;
		}
		
		var isReturn = false;
		$("input[type=checkbox][id^=account_list_chk_]:checked").each(function(i, obj) {
			var delClass = (pMode == "CorpCard" ? ".btn_eaccounting_del" : ".btn_receipt_list_del");
			if($(obj).parents("li").find(delClass).attr("active") == "N") {
				chkList.push({"ReceiptID" : $(obj).val()});
			} else {
				isReturn = true;
				$(obj).parents("li").find(delClass).click();
				return false;
			}
		});		
	}
	
	if(isReturn) return;
	
	var strMessage = "";
		
	if(pMode == "CorpCard") {
		strMessage = mobile_comm_getDic("ACC_msg_doExceptApplication");
	} else if(pMode == "Receipt") {
		strMessage = mobile_comm_getDic("msg_AreYouDelete");
	}
	
	if(confirm(strMessage)){
		var params				= new Object();
		params.mode				= pMode;
		params.isPersonalUse	= 'Y';
		params.chkList			= chkList;
		
		$.ajax({
			url			: "/account/mobile/account/savePersonaldeleteReceipt.do",
			type		: "POST",
			data		: JSON.stringify(params),
			dataType	: "json",
			contentType	: "application/json",
			
			success:function (data) {
				if(data.status == "SUCCESS"){
					mobile_account_reload();
				}else{
					alert(data.message);
				}
			},
			error:function(response, status, error){
			     mobile_comm_ajaxerror("/account/mobile/account/savePersonaldeleteReceipt.do", response, status, error);
			}
		});
	}
}

// 비용 결재문서 조회
function mobile_account_goViewApproval(pUrl) {
	mobile_comm_showload();
	
	// 결재문서 조회 팝업
	mobile_comm_go(pUrl, "Y");
}

// 전표 상세조회
function mobile_account_goViewExpence(pExpAppID, pProcessID, pAppType, pReqType, pAppStatus) {
	var sUrl = "";
	
	if(pAppStatus == "T" || pAppStatus == "S") { // 임시저장
		// 비용신청을 사용하는 경우에만 임시저장된 건 오픈 가능하도록 함
		if(mobile_comm_getBaseConfig("useMobileAccountWrite") == "Y" || mobile_comm_getBaseConfig("useMobileAccountWriteUser").indexOf(mobile_comm_getSession("UR_Code")) > -1) {
			// 모바일에서 [직원간편신청-일반경비신청] 유형만 작성 가능
			if(pAppType == "SC" && pReqType == "NORMAL") {
				sUrl = "/account/mobile/account/write.do";
				sUrl += "?open_mode=TEMPSAVE";
				sUrl += "&expAppID=" + pExpAppID;
			}
			else {
				alert(mobile_comm_getDic("ACC_msg_MobileNotSupportWrite"));
				return false;
			}
		}
		else {
			alert(mobile_comm_getDic("ACC_msg_MobileNotSupportTempSave"));
			return false;
		}
	}
	else {
		sUrl = "/account/mobile/account/view.do";
		sUrl += "?expAppID=" + pExpAppID;
		sUrl += "&processID=" + pProcessID;
	}
	
	if(sUrl != "") {
		mobile_comm_go(sUrl, "Y");
	}
}

// 비용 상세조회 페이지 조회
function mobile_account_viewReceiptDetail(pProofCode, pReceiptID, pFileID, pApproveNo) {
	var sMode = pProofCode.toLowerCase();
	var sUrl = "/account/mobile/account/receipt_view.do";

	sUrl += "?mode=" + sMode;
	sUrl += "&receiptID=" + pReceiptID;
		
	if(sMode == "corpcard") { // 법인카드
		sUrl += "&approveNo=" + pApproveNo;
	}
	else {
		sUrl += "&fileID=" + pFileID;
	}
	
	mobile_comm_go(sUrl, 'Y');
}

//비용신청 페이지로 이동
function mobile_account_goCostApplication(){
	var sUrl = "/account/mobile/account/write.do";
	var sReceiptIDList_Card = "";		//법인카드
	var sReceiptIDList_Receipt = "";	//모바일 영수증
	
	//파라미터 구성
	$("input[type=checkbox][id^=account_list_chk_]:checked").each(function(i, obj) {
		var tmpVal = $(obj).val() + ",";
		
		switch(_mobile_account_list.ExpenseType){
			case "A":				//전체
				if($(obj).attr("proofCode").toLowerCase() == "corpcard") {
					sReceiptIDList_Card += tmpVal;
				}
				else if($(obj).attr("proofCode").toLowerCase() == "receipt") {
					sReceiptIDList_Receipt += tmpVal;
				}
				break;
			case "C":				//법인카드
				sReceiptIDList_Card += tmpVal;
				break;
			case "M":				//모바일 영수증
				sReceiptIDList_Receipt += tmpVal;
				break;
		}
	});
	
	sReceiptIDList_Card = sReceiptIDList_Card.substring(0, sReceiptIDList_Card.length - 1);
	sReceiptIDList_Receipt = sReceiptIDList_Receipt.substring(0, sReceiptIDList_Receipt.length - 1);
	
	sUrl += "?open_mode=DRAFT";
	sUrl += "&receiptid_c=" + sReceiptIDList_Card;
	sUrl += "&receiptid_r=" + sReceiptIDList_Receipt;
	
	//헤더 숨기기
	$("#account_list_chkcnt").text("");
	$("#account_list_chkamount").text("");

	mobile_account_checkAll($("#account_list_allchk_" + _mobile_account_list.Mode));
	mobile_account_showAllChk();
	
	mobile_comm_go(sUrl, 'Y');
}

//모바일 영수증 파일 선택
function mobile_account_changeupload() {	
	mobile_comm_callappextractreceiptinfo(mobile_account_receiptExtractCallBack);
}

//모바일 영수증 데이터 추출 후 콜백
function mobile_account_receiptExtractCallBack(pFile, pResult) {
	var extractObj = pResult;
	var photoDate = pFile.lastModifiedDate;
	var totalAmount = 0;
	var useTime;
	
	//업로드한 영수증을 찍은 시간이 10초 이상일 경우
	//문서에서 가져왔다고 판단하여 유효하지 않은 증빙자료로 처리
	//=> 반드시 촬영 후 바로 업로드할 수 있도록(편집 불가능)
	//2018.08.03: capture="camera" 속성 추가 -> 직접 카메라 호출
	/*if(PhotoDate.getTime() < now.getTime()-10000) {  //getTime은 ms(밀리초) 단위, 따라서 10*1000 
		alert(mobile_comm_getDic("ACC_msg_invalidReceipt").replace(/\\n/gi, "\n"));
		$("#account_upload_attach_input").val("");
		return;
	}*/
	
	var fr = new FileReader();
	fr.readAsDataURL(pFile);
	
	fr.onload = function() {
		$("#account_upload_image").attr('src', fr.result);
	};

	//촬영일자 세팅
	if(typeof photoDate === 'undefined') {
		$("#account_upload_photoDate").html(mobile_account_setDateFormat(new Date()));
	}
	else {
		$("#account_upload_photoDate").html(mobile_account_setDateFormat(photoDate));
	}
	
	//FrontStorage 업로드
	mobile_account_uploadToFront(pFile);
	
	//select 세팅
	$("#account_upload_expType").html(mobile_account_setOption());
	//$("#account_upload_rcpType").html(mobile_account_setReceiptOption()); // //결제수단 미사용
	
	//사용일시 select 옵션 바인딩
	if($("#account_upload_useTimeHour").find("option").length == 0) {
		for(var i = 0; i < 24; i++) {
			var hour = mobile_account_addZero(i);
			$("#account_upload_useTimeHour").append("<option value='" + hour + "'>" + hour + "</option>");
		}
		
		for(var j = 0; j < 60; j++) {
			var minute = mobile_account_addZero(j);
			$("#account_upload_useTimeMinute").append("<option value='" + minute + "'>" + minute + "</option>");
		}	
	}

	//추출된 데이터 세팅
	useTime = extractObj["UseTime"].toString().substring(0, 5);
	
	if(extractObj["TotalAmount"].toString()) {
		totalAmount = mobile_comm_addComma(extractObj["TotalAmount"].toString());
	}
	
	if(useTime && useTime.indexOf(":") > -1) {
		$("#account_upload_useTimeHour").val(useTime.split(":")[0]);
		$("#account_upload_useTimeMinute").val(useTime.split(":")[1]);
	}
	
	$("#account_upload_totalAmount").val(totalAmount);
	$("#account_upload_useDate").val(extractObj["UseDate"].toString());
	$("#account_upload_storeName").val(extractObj["StoreName"].toString());
	$("#account_upload_storeAddress").val(extractObj["StoreAddress"].toString());
	$("#account_upload_useTime").val(useTime);
	
	//header 숨기기
	$("#account_list_receipt_header").hide();
	$("#account_list_receipt_content").hide();

	//datepicker
	mobile_account_datepickerLoad();
	
	//팝업 조회
	$("#account_upload_content").show();
	$("#account_upload_popup").show();
}

function mobile_account_setReceiptOption() {
	var sHtml = "";
	var receiptType = [ //TODO: 영수증 구분 기초코드화
		    { "code" : "Cash", "name" : mobile_comm_getDic("ACC_lbl_cash") },
		    { "code" : "PRCard", "name" : mobile_comm_getDic("ACC_lbl_privateCard") },
		    { "code" : "COCard", "name" : mobile_comm_getDic("ACC_lbl_corpCard") }
	    ];
	
	for(var i = 0; i < receiptType.length; i++) {
		sHtml += "<option value='" + receiptType[i].code + "'>" + receiptType[i].name + "</option>";
	}
	
	return sHtml;
}

var g_frontFileInfos = [];

//모바일 영수증 파일 FrontStorage 업로드
function mobile_account_uploadToFront(pFile) {
	var fileInfos = [];
	var fileObj = new Object();
	var fileData = new FormData();
	
	fileObj.FileName = encodeURIComponent(pFile.name);
	fileObj.Size = pFile.size;
	fileObj.FileID = '';
	fileObj.FilePath = '';
	fileObj.SavedName = '';
	fileObj.FileType = 'normal';
	fileInfos.push(fileObj)
	
	fileData.append("fileInfos", JSON.stringify(fileInfos));
	fileData.append("servicePath", '');
	fileData.append("files", pFile);
	
	$.ajax({
		url: "/covicore/control/uploadToFront.do",
		data: fileData,
		type:"post",
		dataType : 'json',
		processData : false,
        contentType : false,
		success:function (res) {
			if(res.list.length > 0 ){
				g_frontFileInfos = res.list;
			}else{
				alert(mobile_comm_getDic('ACC_msg_noFileToAdd'));
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror("/covicore/control/uploadToFront.do", response, status, error);
   		}			
	});
}

//모바일 영수증 파일 BackStorage 이관
function mobile_account_uploadToBack() {
	/*Front -> Back*/
	var formData = new FormData();
	formData.append("frontFileInfos", JSON.stringify(g_frontFileInfos));
	
	if(mobile_account_validateMobileReceipt("U")) {
		$.ajax({
			type : "POST",
			dataType : "json",
			data : formData,
			url : "/account/EAccountFileCon/uploadFiles.do",
			processData : false,
			contentType : false,
			success : function(data) {
				if(data.list.length > 0) {
					var fileID = data.list[0].FileID;
					mobile_account_uploadReceipt(fileID);
				} 
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror("/account/EAccountFileCon/uploadFiles.do", response, status, error);
	   		}	
		});
	}
}

//모바일 영수증 유호성 체크
function mobile_account_validateMobileReceipt(pMode) {
	var bSuccess = true;
	var sTotalAmount = "";
	var sPageName = "";
	
	switch(pMode) {
	case "U":	//모바일 영수증 업로드 팝업
		sPageName = "upload";
		break;	
	case "RV":	//경비신청 상세조회
		sPageName = "receipt_view_receipt";
		break;
	}
	
	sTotalAmount = $("#account_" + sPageName + "_totalAmount").val().replace("/,/gi", "");
	
	if(sTotalAmount == "" || parseInt(sTotalAmount) <= 0) {
		alert(mobile_comm_getDic("ACC_msg_inputAmount")); //금액을 입력하세요.
		bSuccess = false;
	}
	else if($("#account_" + sPageName + "_expType").find("option:selected").val() == "") {
		alert(mobile_comm_getDic("ACC_msg_inputStandardBrief")); //표준적요를 입력해주세요.
		bSuccess = false;
	}
	else if($("#account_" + sPageName + "_usageText").val() == "") {
		alert(mobile_comm_getDic("ACC_msg_inputComment")); //내역은 필수로 입력하여야 합니다.
		bSuccess = false;
	}	
	else if($("#account_" + sPageName + "_useDate").val() == "") {
		alert(mobile_comm_getDic("ACC_msg_inputUseDate")); //사용일자를 입력하세요.
		bSuccess = false;
	}
	else if($("#account_" + sPageName + "_storeName").val() == "") {
		alert(mobile_comm_getDic("ACC_msg_inputFranchiseCorpName")); //가맹점명을 입력하세요.
		bSuccess = false;
	}
	
	return bSuccess;
}

//모바일 영수증 추가
function mobile_account_uploadReceipt(pFileID) {
	var pUseTime = $("#account_upload_useTimeHour option:selected").val() + ":" + $("#account_upload_useTimeMinute option:selected").val();
	
	//if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	//영수증 스캔 후 추출된 데이터 INSERT (결제수단 미사용)
	var params = {
		"TotalAmount" : $("#account_upload_totalAmount").val().replace(/,/gi, ''),
		"ExpenceMgmtCode" : "",
		"StandardBriefID" : $("#account_upload_expType").val(),
		"UseDate" : $("#account_upload_useDate").val(),
		"UseTime" : pUseTime,
		"UsageText": $("#account_upload_usageText").val(),
		"StoreName": $("#account_upload_storeName").val(),
		"StoreAddress": $("#account_upload_storeAddress").val(),
		"PhotoDate": $("#account_upload_photoDate").text(),
		"ReceiptType": "", //$("#account_upload_rcpType").val()
		"ReceiptFileID": pFileID,
		"Active": 'N'
	};
	
	$.ajax({
		url			: "/account/mobile/account/saveUploadReceipt.do",
		type		: "POST",
		data		: JSON.stringify(params),
		dataType	: "json",
		contentType	: "application/json",
		
		success:function (data) {
			if(data.status == "SUCCESS"){	
				alert(mobile_comm_getDic('msg_117'));
				mobile_account_cancelUpload(); // 업로드 데이터 초기화
				
				if(location.href.indexOf("list") > -1) {
					mobile_account_reload();
				}
			}else{
				alert(data.message);
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror("/account/mobile/account/saveUploadReceipt.do", response, status, error);
   		}	
	});
}

function mobile_account_cancelUpload() {
	$("#account_upload_content").hide();
	$("#account_upload_popup").hide();
	
	$("#account_upload_attach_input").val("");
	$("#account_upload_expType").val("");
	//$("#account_upload_rcpType").find("option:eq(0)").prop("selected", true); //결제수단 미사용
	$("#account_upload_usageText").val("");
	$("#account_upload_useDate").val("");
	$("#account_upload_image").attr("src", "");
	
	$("#account_list_receipt_header").show();
	$("#account_list_receipt_content").show();
}

/* 
 * 
 * 비용 상세조회 페이지 시작
 * 
 */
var _mobile_account_receipt_view = {
	Mode: '',			//조회 타입
	ReceiptID: '',		
	ApproveNo: '',
	FileID: '',
	SearchProperty: ''  //searchProperty(DB, SOAP, SAP ...)	
};

//상세조회 페이지 초기화
function mobile_account_ReceiptViewInit() {
	if (mobile_comm_getQueryString('mode', 'account_receipt_view_page') != 'undefined') {
		_mobile_account_receipt_view.Mode = mobile_comm_getQueryString('mode', 'account_receipt_view_page');
	} else {
		_mobile_account_receipt_view.Mode = '';
	}
	if (mobile_comm_getQueryString('receiptID', 'account_receipt_view_page') != 'undefined') {
		_mobile_account_receipt_view.ReceiptID = mobile_comm_getQueryString('receiptID', 'account_receipt_view_page');
	} else {
		_mobile_account_receipt_view.ReceiptID = '';
	}
	if (mobile_comm_getQueryString('approveNo', 'account_receipt_view_page') != 'undefined') {
		_mobile_account_receipt_view.ApproveNo = mobile_comm_getQueryString('approveNo', 'account_receipt_view_page');
	} else {
		_mobile_account_receipt_view.ApproveNo = '';
	}
	if (mobile_comm_getQueryString('fileID', 'account_receipt_view_page') != 'undefined') {
		_mobile_account_receipt_view.FileID = mobile_comm_getQueryString('fileID', 'account_receipt_view_page');
	} else {
		_mobile_account_receipt_view.FileID = '';
	}
	
	//사용일시 select 옵션 바인딩
	for(var i = 0; i < 24; i++) {
		var hour = mobile_account_addZero(i);
		$("#account_receipt_view_receipt_useTimeHour").append("<option value='" + hour + "'>" + hour + "</option>");
	}
	
	for(var j = 0; j < 60; j++) {
		var minute = mobile_account_addZero(j);
		$("#account_receipt_view_receipt_useTimeMinute").append("<option value='" + minute + "'>" + minute + "</option>");
	}
	
	//기존 값 바인딩
	mobile_account_setReceiptDetail();

	//datepicker
	mobile_account_datepickerLoad();
}

function mobile_account_setReceiptDetail() {
	if(_mobile_account_receipt_view.Mode == "corpcard") { // 법인카드
		$.ajax({
			type:"POST",
			data:{
				receiptID: _mobile_account_receipt_view.ReceiptID,
				approveNo: _mobile_account_receipt_view.ApproveNo,
				searchProperty: _mobile_account_list.SearchProperty
			},
			url:"/account/mobile/account/getCardReceiptDetail.do",
			success:function (data) {
				if(data.status == "SUCCESS") {
					if(data.list.length > 0) {
						var obj = data.list[0];
						var iRepAmount = 0;
						var iTaxAmount = 0;
						
						$("#account_receipt_view_card_expType").html(mobile_account_setOption());
						
						if(obj.StandardBriefID) {
							$("#account_receipt_view_card_expType").val(obj.StandardBriefID);
						}
						
						if(obj.RepAmount) {
							iRepAmount = obj.RepAmount;
						}
						
						if(obj.TaxAmount) {
							iTaxAmount = obj.TaxAmount;
						}
						
						$("#account_receipt_view_card_storeName").text(obj.StoreName);
						$("#account_receipt_view_card_amountWon").text(obj.AmountWon);
						$("#account_receipt_view_card_approveNo").text(obj.ApproveNo);
						$("#account_receipt_view_card_repAmount").text(iRepAmount);
						$("#account_receipt_view_card_taxAmount").text(iTaxAmount);
						$("#account_receipt_view_card_useDateTime").text(obj.UseDate + " " + obj.UseTime);
						$("#account_receipt_view_card_usageText").val(obj.UsageText);
						
						$("#account_receipt_view_cardproof").show();
					}
				}
			},
			error:function(response, status, error){
			     mobile_comm_ajaxerror(sURL, response, status, error);
			}
		});
	} else if(_mobile_account_receipt_view.Mode == "receipt") { // 모바일 영수증
		$.ajax({
			type:"POST",
			data:{
				receiptID: _mobile_account_receipt_view.ReceiptID
			},
			url:"/account/mobile/account/getMobileReceipt.do",
			success:function (data) {
				if(data.status == "SUCCESS") {
					if(data.list.length > 0) {
						var obj = data.list[0];
						var iTotalAmount = 0;
						var sUseTime = obj.UseTime;
						var sHour = "";
						var sMinute = "";
						
						//var imgURL = mobile_comm_getThumbSrc('EAccount', _mobile_account_receipt_view.FileID).replace("_thumb", "");

						if(obj.TotalAmount) {
							iTotalAmount = mobile_comm_addComma(obj.TotalAmount);
						}
						
						//select 세팅
						$("#account_receipt_view_receipt_expType").html(mobile_account_setOption());
						//$("#account_receipt_view_receipt_rcpType").html(mobile_account_setReceiptOption());
						
						//기존 값 세팅
						if(obj.StandardBriefID) {
							$("#account_receipt_view_receipt_expType").val(obj.StandardBriefID);
						}

						if(obj.ReceiptType) {
							$("#account_receipt_view_receipt_rcpType").val(obj.ReceiptType);
						}
						
						if(sUseTime && sUseTime.indexOf(":") > -1) {
							$("#account_receipt_view_receipt_useTimeHour").val(sUseTime.split(":")[0]);
							$("#account_receipt_view_receipt_useTimeMinute").val(sUseTime.split(":")[1]);
						}
						
						$("#account_receipt_view_receipt_totalAmount").val(iTotalAmount);
						$("#account_receipt_view_receipt_expType").val(obj.StandardBriefID);
						$("#account_receipt_view_receipt_usageText").val(obj.UsageText);
						$("#account_receipt_view_receipt_useDate").val(obj.UseDate);
						$("#account_receipt_view_receipt_storeName").text(obj.StoreName);
						$("#account_receipt_view_receipt_photoDate").text(obj.PhotoDateFull);
						
						//$("#account_receipt_view_receipt_image").html("<img src='" + imgURL + "'alt='" + _mobile_account_receipt_view.ReceiptID + "'>");
						$("#account_receipt_view_receiptproof").show();
					}
				}
			},
			error:function(response, status, error){
			     mobile_comm_ajaxerror("/account/mobile/account/getMobileReceipt.do", response, status, error);
			}
		});
	}
}

//법인카드 내역 수정
function mobile_account_modifyCardReceipt() {
	$.ajax({
		type:"POST",
		data:{
			ReceiptID: _mobile_account_receipt_view.ReceiptID,
			StandardBriefID: $("#account_receipt_view_card_expType").val(),
			AccountCode: "",
			UsageText: $("#account_receipt_view_card_usageText").val()
		},
		url:"/account/mobile/account/updateCorpCardReceipt.do",
		success:function (data) {
			if(data.status == "SUCCESS") {
				mobile_comm_back();
				setTimeout("mobile_account_reload()", 500);
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/account/mobile/account/updateCorpCardReceipt.do", response, status, error);
		}
	});
}

//영수증 내역 수정
function mobile_account_modifyMobileReceipt() {
	if(mobile_account_validateMobileReceipt("RV")) {
		var pUseTime = $("#account_receipt_view_receipt_useTimeHour option:selected").val() + ":" + $("#account_receipt_view_receipt_useTimeMinute option:selected").val();
		
		// 수정된 데이터 저장 (결제수단 미사용)
		$.ajax({
			type:"POST",
			data:{
				ReceiptID: _mobile_account_receipt_view.ReceiptID,
				StandardBriefID: $("#account_receipt_view_receipt_expType").val(),
				AccountCode: "",
				TotalAmount: $("#account_receipt_view_receipt_totalAmount").val().replace(/,/gi, ''),
				StoreName: $("#account_receipt_view_receipt_storeName").val(),
				UsageText: $("#account_receipt_view_receipt_usageText").val(),
				UseDate: $("#account_receipt_view_receipt_useDate").val(),
				UseTime: pUseTime,
				ReceiptType: "" //$("#account_receipt_view_receipt_rcpType").val()
			},
			url:"/account/mobile/account/updateMobileReceipt.do",
			success:function (data) {
				if(data.status == "SUCCESS") {
					alert(mobile_comm_getDic("msg_apv_331"));	//저장되었습니다.
					
					mobile_comm_back();
					setTimeout("mobile_account_reload()", 500);
				}
			},
			error:function(response, status, error){
			     mobile_comm_ajaxerror("/account/mobile/account/updateMobileReceipt.do", response, status, error);
			}
		});
	}
}


/* 
 * 
 * 전표 상세조회 페이지 시작
 * 
 */
var _mobile_account_view = {
	ExpenceApplicationID: "",
	ApplicationType: 'SC',		//신청 타입 (SC: 간편신청, CO: 통합비용신청, EA: 직원경비신청)
	RequestType: 'NORMAL',		//비용신청서 타입 (NORMAL : 일반비용신청)
	Mode: '',					//Mode-결재함 모드(Approval, TempSave 등)
	TaskID: "",					//Task ID
	ParentProcessID: "",		//Parent Process ID
	ProcessID: "",				//Process ID
	WorkitemID: "",				//WorkItem ID
	PerformerID: "",			//Performer ID
	ProcessDescriptionID: "",
	UserCode: "",
	ReqUserCode: "",
	Gloct: "",
	Loct: "",
	FormID: "",					//Form ID
	FormInstID: "",
	Archived: "",
	SubKind: "",
	FormPrefix: "",				//Form Prefix
	ActionType: "",				//결재행위(승인, 반려 등)
	IsMobile: "Y",
	ListMode: "",
	IsTotalApv: "N",			//통합결재 내 조회여부
	ExpenceApplicationInfo: {},	//신청서 본문 정보
	SchemaContext: {}			//양식 스키마 정보
};

var btDisplay_Expence = {};

//전표 상세조회 초기화
function mobile_account_ViewInit() {
	if(window.sessionStorage["account_writeinit"] == "Y") {
		window.sessionStorage.removeItem('account_writeinit');
	}
	
	if(window.sessionStorage["open_mode"] != undefined) {
		window.sessionStorage.removeItem("open_mode")
	}

	if(window.sessionStorage["processid"] != undefined) {
		window.sessionStorage.removeItem("processid")
	}

	if(window.sessionStorage["apvlist"] != undefined) {
		window.sessionStorage.removeItem("apvlist")
	}

	// 파라미터 셋팅
	if (mobile_comm_getQueryString('expAppID', 'account_view_page') != 'undefined') {
		_mobile_account_view.ExpenceApplicationID = mobile_comm_getQueryString('expAppID', 'account_view_page');
	} else {
		 _mobile_account_view.ExpenceApplicationID = '';
 	}
	if (mobile_comm_getQueryString('mode', 'account_view_page') != 'undefined') {
		_mobile_account_view.Mode = mobile_comm_getQueryString('mode', 'account_view_page');
	} else {
		_mobile_account_view.Mode = 'Approval';
	}
	if (mobile_comm_getQueryString('taskID', 'account_view_page') != 'undefined') {
		_mobile_account_view.TaskID = mobile_comm_getQueryString('taskID', 'account_view_page');
    } else {
    	_mobile_account_view.TaskID = '';
    }
	if (mobile_comm_getQueryString('processID', 'account_view_page') != 'undefined') {
		_mobile_account_view.ProcessID = mobile_comm_getQueryString('processID', 'account_view_page');
    } else {
    	_mobile_account_view.ProcessID = '';
    }
	if (mobile_comm_getQueryString('workitemID', 'account_view_page') != 'undefined') {
		_mobile_account_view.WorkitemID = mobile_comm_getQueryString('workitemID', 'account_view_page');
    } else {
    	_mobile_account_view.WorkitemID = '';
    }
	if (mobile_comm_getQueryString('performerID', 'account_view_page') != 'undefined') {
		_mobile_account_view.PerformerID = mobile_comm_getQueryString('performerID', 'account_view_page');
    } else {
    	_mobile_account_view.PerformerID = '';
    }
	if (mobile_comm_getQueryString('processdescriptionID', 'account_view_page') != 'undefined') {
		_mobile_account_view.ProcessDescriptionID = mobile_comm_getQueryString('processdescriptionID', 'account_view_page');
    } else {
    	_mobile_account_view.ProcessDescriptionID = '';
    }
	if (mobile_comm_getQueryString('userCode', 'account_view_page') != 'undefined') {
		_mobile_account_view.UserCode = mobile_comm_getQueryString('userCode', 'account_view_page');
    } else {
    	_mobile_account_view.UserCode = '';
    }
	if (mobile_comm_getQueryString('gloct', 'account_view_page') != 'undefined') {
		_mobile_account_view.Gloct = mobile_comm_getQueryString('gloct', 'account_view_page');
    } else {
    	_mobile_account_view.Gloct = '';
    }
	if (mobile_comm_getQueryString('loct', 'account_view_page') != 'undefined') {
		_mobile_account_view.Loct = mobile_comm_getQueryString('loct', 'account_view_page');
    } else {
    	_mobile_account_view.Loct = '';
    }
	if (mobile_comm_getQueryString('formID', 'account_view_page') != 'undefined') {
		_mobile_account_view.FormID = mobile_comm_getQueryString('formID', 'account_view_page');
    } else {
    	_mobile_account_view.FormID = '';
    }
	if (mobile_comm_getQueryString('forminstanceID', 'account_view_page') != 'undefined') {
		_mobile_account_view.FormInstID = mobile_comm_getQueryString('forminstanceID', 'account_view_page');
    } else {
    	_mobile_account_view.FormInstID = '';
    }
	if (mobile_comm_getQueryString('archived', 'account_view_page') != 'undefined') {
		_mobile_account_view.Archived = mobile_comm_getQueryString('archived', 'account_view_page');
    } else {
    	_mobile_account_view.Archived = '';
    }
	if (mobile_comm_getQueryString('subkind', 'account_view_page') != 'undefined') {
		_mobile_account_view.SubKind = mobile_comm_getQueryString('subkind', 'account_view_page');
    } else {
    	_mobile_account_view.SubKind = '';
    }
	if (mobile_comm_getQueryString('formPrefix', 'account_view_page') != 'undefined') {
		_mobile_account_view.FormPrefix = mobile_comm_getQueryString('formPrefix', 'account_view_page');
    } else {
    	_mobile_account_view.FormPrefix = '';
    }
	if (mobile_comm_getQueryString('isMobile', 'account_view_page') != 'undefined') {
		_mobile_account_view.IsMobile = mobile_comm_getQueryString('isMobile', 'account_view_page');
    } else {
    	_mobile_account_view.IsMobile = '';
    }
	if (mobile_comm_getQueryString('listmode', 'account_view_page') != 'undefined') {
		_mobile_account_view.ListMode = mobile_comm_getQueryString('listmode', 'account_view_page');
    } else {
    	_mobile_account_view.ListMode = 'ExpenceMgr';
    }
	if (mobile_comm_getQueryString('isTotalApv', 'account_view_page') != 'undefined') {
		_mobile_account_view.IsTotalApv = mobile_comm_getQueryString('isTotalApv', 'account_view_page');
    } else {
    	_mobile_account_view.IsTotalApv = 'N';
    }
	
	// 결재문서 정보 조회
	mobile_account_getFormData(_mobile_account_view);
	
	// 증빙 목록 표시
	mobile_account_getExpenceViewList();
	
	// 결재선 표시
	mobile_account_getDomainDataDisplay(_mobile_account_view.ProcessID, true);
	
	// 대결일 경우 처리 
	if (_mobile_account_view.WorkitemID != "" && _mobile_account_view.Loct == "APPROVAL"
		&& (_mobile_account_view.Mode == "APPROVAL" || _mobile_account_view.Mode == "PCONSULT" || _mobile_account_view.Mode == "RECAPPROVAL" || _mobile_account_view.Mode == "SUBAPPROVAL" || _mobile_account_view.Mode == "AUDIT" )) {
		mobile_account_setApvList();
	}
	
	// 담당업무,수신 등 현결재자 정보 셋팅
	if (_mobile_account_view.Mode == "DRAFT"
		|| _mobile_account_view.Mode == "TEMPSAVE"
		|| ((_mobile_account_view.Loct == "APPROVAL" || _mobile_account_view.Loct == "REDRAFT") && _mobile_account_view.Mode == "REDRAFT")
		|| (_mobile_account_view.Loct == "REDRAFT" && _mobile_account_view.Mode == "SUBREDRAFT") //부서협조일경우 수신부서에서 열었을때 접수사용으로 되어 있으면 결재선을 그려 줘야함
	) {
		/*if (getInfo("Request.reuse") != "P"
			&& openMode != "W"
			&& (getInfo("Request.editmode") != 'Y' || (getInfo("Request.editmode") == 'Y' && getInfo("Request.reuse") == "Y"))) {
			//설정된 결재선 가져오기
			setDomainData();
		}
		else {
			//결재선 그리기
			initApvList();
		}*/
		var str_apvlist = mobile_account_receiveApvHTTP($("#APVLIST").val(), _mobile_account_view.Mode);
		if(str_apvlist) {
			$("#APVLIST").val(str_apvlist);
			window.sessionStorage["apvlist"] = str_apvlist;
			mobile_account_displayApvLine();
		}
	}
				
	// 비용결재함 버튼 표시
	if((_mobile_account_view.IsTotalApv == "Y") || (_mobile_account_view.IsTotalApv == "N" && _mobile_account_view.ListMode != "ExpenceMgr")) {
		// 결재암호 사용 여부
		var g_UsePWDCheck = _mobile_account_view.SchemaContext.scWFPwd.isUse;
		
		if (g_UsePWDCheck == "Y" && mobile_approval_chkUsePasswordYN()){
			flgUsePWDCheck = true;			
			$(".approval_comment").addClass("secret");
		    document.getElementById("account_view_inputpassword").focus();
		} else {
			flgUsePWDCheck = false;
			$(".approval_comment").removeClass("secret");
		}
		
		// 버튼 표시
		mobile_account_initBtn();
		
		// 읽음확인 처리
		mobile_account_setConfirmRead();
	}
}

function mobile_account_setApvList() {//대결일 경우 처리		
    try {
    	var strApv = $("#APVLIST").val();
    	var jsonApv;
		var sMode = _mobile_account_view.Mode;
		var sUserCode = _mobile_account_view.UserCode; // 원결재자
		var sessionObj = mobile_comm_getSession(); //전체호출
		var sSvdt_TimeZone = CFN_TransServerTime(CFN_GetLocalCurrentDate());

        jsonApv = $.parseJSON(strApv);
        
        if (sMode == "APPROVAL" || sMode == "PCONSULT" || sMode == "RECAPPROVAL" || sMode == "SUBAPPROVAL" || sMode == "AUDIT") { //기안부서결재선 및 수신부서 결재선
            var oFirstNode; //step에서 taskinfo select로 변경

            if (sMode == "APPROVAL" || sMode == "SUBAPPROVAL") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'],step[routetype='approve']>ou>role:has(person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "'])");
                
                if (sMode == "SUBAPPROVAL"  && oFirstNode.length == 0) {
                	oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype!='approve']>ou>person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'], step[routetype!='approve']>ou>role:has(person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "'])");
                }
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + sessionObj["USERID"] + "']>taskinfo[status='pending'][kind='substitute']");
                }
                }
            else if (sMode == "RECAPPROVAL") {
                oFirstNode = $$(jsonApv).find("steps>division[divisiontype='receive']>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'],step[routetype='approve']>ou>role:has(person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "'])");
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division[divisiontype='receive']>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + sessionObj["USERID"] + "']>taskinfo[status='pending'][kind='substitute']");
                }
                }
            else if (sMode == "PCONSULT") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step>ou>person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'], step>ou>role>taskinfo:has(person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "'])[status='pending']");
            } else if (sMode == "AUDIT") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='audit']>ou>person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "'] > taskinfo[status='pending'],step[routetype='audit']>ou>role:has(person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "'])");
            } else {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[unittype='ou'][routetype='receive']>ou>person[code!='" + sessionObj["USERID"] + "']>taskinfo[kind!='charge'][status='pending']");
            }
            if (oFirstNode.length != 0) {
            	alert(mobile_comm_getDic("msg_ApprovalDeputyWarning"));
            	
                m_bDeputy = true; m_bApvDirty = true; var elmOU; var elmPerson;
                switch (sMode) {
                    case "APPROVAL":
                    case "PCONSULT":
                    case "SUBAPPROVAL":
                    case "RECAPPROVAL":
                    case "AUDIT":
                        elmOU = $$(oFirstNode).parent().parent();
                        elmPerson = $$(oFirstNode).parent();
                        break;
                }
                var elmTaskInfo = $$(elmPerson).find("taskinfo");
                var skind = $$(elmTaskInfo).attr("kind");
                var sallottype = "serial";
                var elmStep = $$(elmOU).parent();
                try { if ($$(elmStep).attr("allottype") != null) sallottype = $$(elmStep).attr("allottype"); } catch (e) { mobile_comm_log(e); }
                //taskinfo kind에 따라 처리  일반결재 -> 대결, 대결->사용자만 변환, 전결->전결, 기존사용자는 결재안함으로
                switch (skind) {
                    case "substitute": //대결
                        if (sMode == "APPROVAL") {
                            $$(elmOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
                            $$(elmOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
                        }
                        $$(elmPerson).attr("code", sessionObj["USERID"]);
                        $$(elmPerson).attr("name", sessionObj["UR_MultiName"]);
                        $$(elmPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                        $$(elmPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                        $$(elmPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                        $$(elmPerson).attr("oucode", sessionObj["DEPTID"]);
                        $$(elmPerson).attr("ouname", sessionObj["GR_MultiName"]);
                        $$(elmPerson).attr("sipaddress", sessionObj["UR_Mail"]);
                        $$(elmTaskInfo).attr("datereceived", sSvdt_TimeZone);
                        break;
                    /*case "authorize"://전결 결재안함
                        $$(elmTaskInfo).attr("status", "completed");
                        $$(elmTaskInfo).attr("result", "skipped");
                        $$(elmTaskInfo).attr("kind", "skip");
                        $$(elmTaskInfo).remove("datereceived");
                        break;*/
                    case "consent": //합의 -> 후열
                    case "charge":  //담당 -> 후열
                    case "consult":
                    case "normal":  //일반결재 -> 후열
                    case "authorize"://전결 결재안함
                        $$(elmTaskInfo).attr("status", "inactive");
                        $$(elmTaskInfo).attr("result", "inactive");
                        $$(elmTaskInfo).attr("kind", "bypass");
                        $$(elmTaskInfo).remove("datereceived");
                        break;
                }
                if (skind == "authorize" || skind == "normal" || skind == "consent" || skind == "charge" || skind == "consult") {
                    var oStep = {};
                    var oOU = {};
                    var oPerson = {};
                    var oTaskinfo = {};
                    
                    $$(oTaskinfo).attr("status", "pending");
                    $$(oTaskinfo).attr("result", "pending");
                    //$$(oTaskinfo).attr("kind", (skind == "authorize") ? skind : "substitute");
                    $$(oTaskinfo).attr("kind", "substitute"); // 대결로 처리되는 경우 대결자 완료함에서 문서 열람이 가능해야 함!
                    $$(oTaskinfo).attr("datereceived", sSvdt_TimeZone);
                    
                    $$(oPerson).attr("code", sessionObj["USERID"]);
                    $$(oPerson).attr("name", sessionObj["UR_MultiName"]);
                    $$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                    $$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                    $$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                    $$(oPerson).attr("oucode", sessionObj["DEPTID"]);
                    $$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
                    $$(oPerson).attr("sipaddress", sessionObj["UR_Mail"]);
                    
                    if(sMode == "SUBAPPROVAL") {
                    	$$(oPerson).attr("wiid", $$(elmPerson).attr("wiid"));
                    	$$(oPerson).attr("taskid", $$(elmPerson).attr("taskid"));
                    }
                    
                    $$(oPerson).append("taskinfo", oTaskinfo);
                    
                    $$(elmOU).append("person", oPerson);							// person이 object일 경우를 위해서 추가하여 배열로 만듬
                    
                    if(sMode == "SUBAPPROVAL") {
                    	// todo: person의 index 구하는 방법 변경할 수 있으면 다른방법으로 교체할 것
                    	$$(elmOU).find("person").json().splice(parseInt(oFirstNode.parent().path().substr(oFirstNode.parent().path().lastIndexOf("/")+8, 1)), 0, oPerson);
                    } else {
                    	$$(elmOU).find("person").json().splice(0, 0, oPerson);			// 다시 앞에 추가
                    }
                    $$(elmOU).find("person").concat().eq($$(elmOU).find("person").concat().length-1).remove();			// 배열로 만들기 위해서 추가했던 person을 지움
                    
                    if (skind == 'charge') {
                        oFirstNode = oStep;
                        
                        var oStep = {};
                        var oOU = {};
                        var oPerson = {};
                        var oTaskinfo = {};
                        
                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", mobile_comm_getDic("lbl_apv_writer"));		//gLabel__writer);
                        
                        $$(oOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
                        $$(oOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
                        
                        $$(oPerson).attr("code", sessionObj["USERID"]);
                        $$(oPerson).attr("name", sessionObj["UR_MultiName"]);
                        $$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                        $$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                        $$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                        $$(oPerson).attr("oucode", sessionObj["DEPTID"]);
                        $$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
                        $$(oPerson).attr("sipaddress", sessionObj["UR_Mail"]);
                        
                        $$(oTaskinfo).attr("status", "complete");
                        $$(oTaskinfo).attr("result", "complete");
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", sSvdt_TimeZone);
                        $$(oTaskinfo).attr("datecompleted", sSvdt_TimeZone);
                        
                        $$(oPerson).append("taskinfo", oTaskinfo);
                        
                        $$(oOU).append("person", oPerson);
                        
                        $$(oStep).append("ou", oOU);
                        
                        $$(jsonApv).find("steps>division").append("step", oStep);
                        $$(jsonApv).find("steps>division>step").json().splice(0, 0, oStep);
                        $$(jsonApv).find("steps>division>step").concat().eq($$(jsonApv).find("steps>division>step").concat().length-1).remove();
                    }
                }

                var oResult = $$(jsonApv).json();

                //document.getElementById("APVLIST").value = JSON.stringify(oResult);
				var sApvList = JSON.stringify(oResult);
				$("#APVLIST").val(sApvList);
				window.sessionStorage["apvlist"] = sApvList;
				mobile_account_displayApvLine();
            }
            else {
                //document.getElementById("APVLIST").value = strApv;
            }
        }
        else {
            //document.getElementById("APVLIST").value = strApv;
        }
    }
    catch (e) {
        alert(e.message);
    }
}

// 전표 상세조회 시 증빙 데이터 가져오기
function mobile_account_getExpenceViewList() {
	$.ajax({
		type:"POST",
		data:{
			ExpenceApplicationID: _mobile_account_view.ExpenceApplicationID
		},
		async:false,
		url:"/account/mobile/account/searchExpenceApplication.do",
		success:function (data) {
			if(data.status == "SUCCESS") {
				var oExpApp = data.data;
				var iTotalAmtSum = 0;
				var iReqAmtSum = 0;

				// 증빙총액, 청구금액 계산
				$(oExpApp.pageExpenceAppEvidList).each(function(i, oEvid) {
					iTotalAmtSum += mobile_account_checkNaN(oEvid.TotalAmount);
					iReqAmtSum += mobile_account_checkNaN(!oEvid.divSum ? oEvid.Amount : oEvid.divSum);
				});
				
				// 증빙 정보 세팅
				$("#account_view_subject").val(oExpApp.ApplicationTitle);
				$("#account_view_TotalAmount").text(mobile_comm_addComma(iTotalAmtSum.toString()));
				$("#account_view_ReqAmount").text(mobile_comm_addComma(iReqAmtSum.toString()));
				$("#account_view_payDate").text(oExpApp.pageExpenceAppEvidList[0].PayDateStr);
				
				// 비용 정보 세팅
				$(oExpApp.pageExpenceAppEvidList).each(function(i, obj) {
					mobile_account_setViewExpenceHtml(i, obj);
				});
				
				_mobile_account_view.ExpenceApplicationInfo = oExpApp;
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/account/mobile/account/searchExpenceApplication.do", response, status, error);
		}
	});
}

//전표 상세조회 내 증빙 HTML 리턴
function mobile_account_setViewExpenceHtml(idx, obj) {
	var sHtml = "";
	var sFileHtml = "";
	var sDocLinkHtml = "";
	var receiptID = obj.ReceiptID;
	var storeName = "";
	
	if(obj.ApplicationType == "CO") {
		if(obj.ProofCode != "CorpCard") {
			storeName = obj.VendorName;
		}
	}
	
	switch(obj.ProofCode) {
	case "CorpCard": storeName = obj.StoreName; receiptID = obj.CardUID; break;
	case "TaxBill": receiptID = obj.TaxUID; break;
	case "PaperBill": receiptID = obj.PaperBillID; break;
	case "CashBill" : receiptID = obj.CashUID; break;
	case "EtcEvid": receiptID = obj.ExpAppEtcID; break;
	case "Receipt": storeName = obj.StoreName; receiptID = obj.ReceiptID; break;
	case "PrivateCard" : receiptID = obj.ExpAppPrivID; break;
	}
	
	
	sHtml += "<li id='account_view_li_" + receiptID + "'>";
	sHtml += "	<input type='hidden' id='account_view_DetailInfo_" + receiptID + "' proofCode='" + obj.ProofCode + "' value='" + encodeURIComponent(JSON.stringify(obj)) + "' />";
	sHtml += "	<div class='nea_applist_write'>";
	sHtml += "		<div class='card_con fullSize'>";
	sHtml += "			<p class='tx_cost'><span class='tx_cost_pc' id='account_view_useAmount_" + receiptID + "'>" + mobile_comm_addComma(obj.TotalAmount.toString().trim()) + "</span>" + mobile_comm_getDic("ACC_lbl_won") + "</p>";
	sHtml += "			<p class='tx_cont ellip'>" + mobile_account_nullToBlank(storeName) + "</p>";
	sHtml += "			<p class='tx_date' id='account_view_useDate_" + receiptID + "'>" + ((obj.ProofDateStr == "" || obj.ProofDateStr == undefined) ? proofTodayDateStr : obj.ProofDateStr) + "</p>";
	
	// 법인카드, 모바일 영수증에 한하여 증빙 팝업 조회 가능
	if(obj.ProofCode == "CorpCard" || obj.ProofCode == "Receipt") {
		sHtml += "			<a onclick='javascript: mobile_account_showPopup(\"" + obj.ProofCode + "\",\"" + receiptID + "\", \"" + mobile_account_nullToBlank(obj.FileID) + "\", \"" + mobile_account_nullToBlank(obj.CardApproveNo) + "\"); return false;' class='btn_bill'><span></span></a>";	
	}
	
	sHtml += "		</div>";
	
	// 전자세금계산서인 경우 세부 항목 조회
	if(obj.ProofCode == "TaxBill") {
		sHtml += "		<div class='nea_card_detail_bottom_wrap'>";
		sHtml += "			<div class='nea_card_detail_bottom'>";
		sHtml += "				<div class='detail_tx_area' style='border: none;'>";
		sHtml += "					<dl>";
		sHtml += "						<dt>" + mobile_comm_getDic("ACC_lbl_supplyValue") + "</dt>";
		sHtml += "						<dd><strong>" + mobile_comm_addComma(obj.RepAmount.toString()) + "</strong>" + mobile_comm_getDic("ACC_lbl_won") + "</dd>";
		sHtml += "					</dl>";
		sHtml += "					<dl>";
		sHtml += "						<dt>" + mobile_comm_getDic("ACC_lbl_taxValue") + "</dt>";
		sHtml += "						<dd><strong>" + mobile_comm_addComma(obj.TaxAmount.toString()) + "</strong>" + mobile_comm_getDic("ACC_lbl_won") + "</dd>";
		sHtml += "					</dl>";
		sHtml += "					<dl>";
		sHtml += "						<dt>" + mobile_comm_getDic("lbl_sum") + "</dt>";
		sHtml += "						<dd><strong>" + mobile_comm_addComma(obj.TotalAmount.toString()) + "</strong>" + mobile_comm_getDic("ACC_lbl_won") + "</dd>";
		sHtml += "					</dl>";
		sHtml += "				</div>";
		sHtml += "			</div>";
		sHtml += "		</div>";
	}
	
	// 증빙별 첨부파일 표시
	$(obj.fileInfoList).each(function(i, oFile) {
		sFileHtml += "<p class='detail_file' onclick='mobile_comm_getFile(\"" + oFile.FileID + "\", \"" + oFile.FileName.replace(/\'/gi, "&#39;") + "\", \"" + oFile.FileToken + "\");'>" + oFile.FileName + "</p>";
	});
	
	// 증빙별 연결문서 표시
	$(obj.docList).each(function(i, oDocLink) {
		sDocLinkHtml += mobile_account_getDocLinkHtml(false, oDocLink.ProcessID, oDocLink.Subject, oDocLink.bstored, oDocLink.BusinessData1, oDocLink.BusinessData2);
	});
		
	// 비용분할 표시
	$(obj.divList).each(function(i, oDiv) {
		sHtml += "		<div class='nea_card_detail_bottom_wrap'>";
		sHtml += "			<div class='nea_card_detail_bottom'>";
		sHtml += "				<span class='detail_category01'>" + oDiv.AccountName + "/" + oDiv.StandardBriefName + "</span>";
		sHtml += "				<span class='detail_category03'>" + oDiv.CostCenterName + "</span>";
		sHtml += "				<span class='detail_cost'><span class='detail_bottom_tx_p'>" + mobile_comm_addComma(oDiv.Amount.toString()) + "</span>" + mobile_comm_getDic("ACC_lbl_won") + "</span>";
		sHtml += "				<div class='detail_tx_area'>" + oDiv.UsageComment + "</div>";
		sHtml += "			</div>";
		sHtml += "		</div>";
	});

	sHtml += sFileHtml;
	sHtml += sDocLinkHtml;
	sHtml += "	</div>";
	sHtml += "</li>";
	
	$("#account_view_list").append(sHtml);
}

// 결재선 조회
function mobile_account_getDomainDataDisplay(pProcessID, bDisplay) {
	$.ajax({
		url:"/approval/getDomainListData.do",
		type:"post",
		data: {
			ProcessID: _mobile_account_view.ProcessID,
			FormInstID : _mobile_account_view.FormInstID
		},
		async:false,
		success:function (data) {
			if(data.status == "SUCCESS") {
				var sApvList = JSON.stringify(data.list[0].DomainDataContext);
				$("#APVLIST").val(sApvList);
				window.sessionStorage["apvlist"] = sApvList;
				
				if(bDisplay) {
					mobile_account_displayApvLine();
				}
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror("/approval/getDomainListData.do", response, status, error);
		}
	});
}

// 비용 결재문서 읽음확인 처리
function mobile_account_setConfirmRead() {
	$.ajax({
		url:"/approval/setConfirmRead.do",
		type:"post",
		data:{
			UserCode: _mobile_account_view.UserCode,
			mode: _mobile_account_view.Mode,
			loct: _mobile_account_view.Loct,
			gloct: _mobile_account_view.Gloct,
			subkind: _mobile_account_view.SubKind,
			FormInstID: _mobile_account_view.FormInstID,
			ProcessID: _mobile_account_view.ProcessID
		},
		async:false,
		success:function (data) {

		},
		error:function(response, status, error){
			mobile_comm_ajaxerror("/approval/setConfirmRead.do", response, status, error);
		}
	});
}

// 결재선 표시
function mobile_account_displayApvLine() {
	var strApv = $("#APVLIST").val();
	
	if(window.sessionStorage["open_mode"] == "APVLIST" && window.sessionStorage["processid"] == _mobile_account_view.ProcessID && window.sessionStorage["apvlist"] != undefined) { //결재선 편집 후 재조회 시
		strApv = window.sessionStorage["apvlist"];
    }
	
	var objGraphicList = ApvGraphicView.getGraphicData(strApv);
	$("#account_view_approvalList").html(ApvGraphicView.getGraphicHtml(objGraphicList));
	setApvComment(objGraphicList);
}

function setApvComment(step) {
	for(var i = 0; i < step.length; i++) {
		for(var j = 0; j < step[i].steps.length; j++) {
			var steps = step[i].steps[j];
			
			if(steps.substeps[0].comment) {
				var targetDL = $("#account_view_approvalList").children("dl:eq("+j+")");
				var icoHtml = "<span class=\"ico_task_mail\" style=\"display:inline-block;width:13px;height:auto;text-indent:-20000px;margin-left:3px;background-size:contain;\">의견</span>";
				var comment = steps.substeps[0].comment;
				
				targetDL.children("dd[class=name]").append(icoHtml);
				targetDL.attr("onclick", "mobile_account_cmt_showPopup('"+steps.substeps[0].comment+"');");
			}
		}
	}
}

function mobile_account_cmt_showPopup(comment) {
	$("#account_view_cmt_Comment").html(Base64.b64_to_utf8(comment).replace(/\n/g, "<br />"));
	$("#account_view_cmt_popup").show();
	$("#account_view_content").css("position", "fixed");
}

// 결재선 편집
function mobile_account_completeApv() {
	window.sessionStorage["apvlist"] = document.getElementById("APVLIST").value;
	window.sessionStorage["processid"] = _mobile_approval_view.ProcessID;
	window.sessionStorage.removeItem('account_writeinit');
	
	mobile_account_displayApvLine();
	mobile_account_initBtn();
	
	mobile_comm_back();
}

//전표 상세조회 내 버튼 초기화
function mobile_account_initBtn() {
	var m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
    var usid = mobile_comm_getSession("USERID");
    var registerID = $$(m_evalJSON).find("step ou person").has("taskinfo[kind='charge']").json().code; // 기안자
    var l_ActiveModule = mobile_approval_getActiveModule();
	var viewMode = "view";
    if(getInfo("Request.templatemode") == "Write") {
    	viewMode = "write";
	}
    
	// init Button
	btDisplay_Expence = {
		"btModify" : "N",
		"btHold" : "N",
		"btRejectedto" : "N",
		"btLine" : "N",
		"btDeptLine" : "N",
		"btForward" : "N",
		"btWithdraw" : "N",
		"btAbort" : "N",
		"btApproveCancel" : "N",
		"btReUse" : "N",
		"btApproved" : "N",
		"btReject" : "N",
		"btDeptDraft" : "N",
		"btApprovedlast" : "N",
		"btRejectlast" : "N",
		"btRec" : "N"
	};

    switch (_mobile_account_view.Loct) {
        case "PROCESS":
        case "COMPLETE":
        case "CANCEL":
        case "JOBDUTY":
        case "REVIEW":
        case "REJECT":
        	mobile_account_displayViewBtn("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", _mobile_account_view.Loct == "COMPLETE" ? "Y" : "N", "N", "N", "Y");
            break;
        case "DRAFT":
        case "PREDRAFT":
        case "TEMPSAVE":
            mobile_account_displayViewBtn("Y", "N", "N", "N", "Y", "N", "N", "N", "N", "Y", "N", "Y", "Y", "N", "N", "Y", "Y");
            break;
        case "REDRAFT":
        case "SHARER":
        case "APPROVAL":
            switch (_mobile_account_view.Mode) {
                case "SHARER":
                case "APPROVAL": //일반결재
                    mobile_account_displayViewBtn("N", "N", "N", "N", "Y", "N", "Y", "N", "N", "N", "Y", "N", "N", "N", "N", "N", "Y"); //모든 결재자 첨부파일 추가
					// "전결/후결/후열/결재안함"이 결재선 내 포함된 경우 편집 불가능하도록 처리
					// 해당 결재유형 개발 시 조건 삭제 필요
					var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
					if (!fn_GetReview() && $$(oApvList).find("division[divisiontype='send']>step[unittype='person']>ou").has("taskinfo[kind='authorize'], taskinfo[kind='review'], taskinfo[kind='bypass'], taskinfo[kind='skip']").length == 0) { 
					}
					else {
						btDisplay.btLine = "N"
					}
                    break;
                case "AUDIT": //감사
                case "PCONSULT": //개인합의				 
                    mobile_account_displayViewBtn("N", "N", "N", "N", "Y", "N", "Y", "N", "N", "N", "Y", "N", "N", "Y", "Y", "N", "Y");
                    break;
                case "RECAPPROVAL": //수신결재
                    mobile_account_displayViewBtn("N", "N", "N", "N", "N", "N", "Y", "N", "Y", "N", "Y", "N", "N", "N", "N", "N", "Y"); //모든 결재자 첨부파일 추가
                    break;
                case "SUBAPPROVAL": //부서합의내결재
                    mobile_account_displayViewBtn("N", "N", "N", "N", "N", "N", "Y", "N", "Y", "N", "Y", "N", "N", "Y", "Y", "N", "Y");
                    break;
                case "DEPART": //부서
                    break;
                case "CHARGE": //담당자				 
                    mobile_account_displayViewBtn("N", "N", "N", "N", "N", "N", "Y", "N", "N", "N", "Y", "N", "N", "Y", "Y", "N", "Y");
                    break;
                case "REDRAFT": //재기안
                    var sdisplay = "Y";
                    var sAttDisplay = "Y";
                    if (_mobile_account_view.SubKind == "T008") {
                        mobile_account_displayViewBtn("N", "N", "N", "N", "Y", "N", "Y", "N", "N", "N", "Y", ((_mobile_account_view.SchemaContext != null && _mobile_account_view.SchemaContext.scCHBis.isUse == "Y") ? "Y" : "N"), "N", "N", "N", "Y", "Y");
                    } else {
                        sAttDisplay = "Y";
                        //문서관리자 권한 설정
                        if (_mobile_account_view.SchemaContext.scRec.isUse == "Y") { //접수
                            sdisplay = "N";
                            sAttDisplay = "N";
                            
                            if (reqUserCode == UserCode) {
                                btDisplay_Expence.btReject = "Y";
                            }
                        }

                        if (_mobile_account_view.Loct == "REDRAFT" && _mobile_account_view.Mode == "REDRAFT") {//신청서 수신함 조회 시
                            mobile_account_displayViewBtn("N", "N", "N", "N", "N", "N", "Y", "N", "Y", "N", "Y", "N", "N", "N", "N", "Y", "Y"); //모든 결재자 첨부파일 추가					
                            btDisplay_Expence.btLine = "N";
                        } else {
                            mobile_account_displayViewBtn("N", "N", "N", "N", "N", "N", "N", "N", sdisplay, "N", "N", sAttDisplay, "N", "Y", "Y", "Y", "Y");
                        }
                    }
                    break;
            }
            
            //후결추가
            if (_mobile_account_view.SubKind == "T005") {
                btDisplay_Expence.btHold = "N";
            }
            break;
    }
    
    if (_mobile_account_view.Loct == "MONITOR" || _mobile_account_view.Loct == "PREAPPROVAL" || _mobile_account_view.Loct == "PROCESS" || _mobile_account_view.Loct == "COMPLETE" && _mobile_account_view.Mode != "REJECT") {
        if (_mobile_account_view.Loct == "PROCESS" && (_mobile_account_view.Mode == "PROCESS" || _mobile_account_view.Mode == "PCONSULT" || _mobile_account_view.Mode == "RECAPPROVAL" || _mobile_account_view.Mode == "SUBAPPROVAL" || _mobile_account_view.Mode == "AUDIT") && registerID == usid && _mobile_account_view.SubKind == "T006") {
            var elmRoot = $(m_evalJSON).find("steps");
            var elmList = $$(elmRoot).find("division>step>ou>person").has("taskinfo[kind!='charge'])");
            var strDate;

            $$(m_evalJSON).find("division>step>ou>person").has("taskinfo[kind!='charge']").each(function (i, elm) {
                var elmTaskInfo = $$(elm).find("taskinfo");
                if ($$(elmTaskInfo).attr("datecompleted") != null) {
                    strDate = $$(elmTaskInfo).attr("datecompleted");
                }
            });

            //사용자 문서 조회 및 수정
            //관리자 모드가 아닐때
            if (strDate == null) {
                if (_mobile_account_view.Gloct != "DEPART") {					//부서진행함 - 조건 없이 실행하던걸 if추가하여 안에 넣음
                    btDisplay_Expence.btWithdraw = "Y"; //회수
                }

                //수신처 담당자가 pending 상태일 때는 회수 안됨,수신처 수신함에 pending 일 경우 회수 안됨
                elmList = $$(m_evalJSON).find("division").has("taskinfo[status='pending']").find("[divisiontype='receive'] > step > ou");

                if (elmList.length > 0) {
                    btDisplay_Expence.btWithdraw = "N";
                }

            } else if (strDate != null && _mobile_account_view.SchemaContext != null && _mobile_account_view.SchemaContext.scDraftCancel != null && _mobile_account_view.SchemaContext.scDraftCancel.isUse == "Y") {
                if ($$(m_evalJSON).find("division[divisiontype='receive']>step>ou>person[code='" + usid + "']").has("taskinfo[kind='charge']").concat().length == 0) {
                    btDisplay_Expence.btAbort = "Y";		 //진행 중 문서도 취소가 됨
                }
            }
        }
    }
	
    // 승인 반려 버튼 활성화
	if(getInfo("Request.mode") == "PCONSULT" && getInfo("Request.subkind") == "T009") {
		$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").contents().filter(function(){ return this.nodeType === 3; }).replaceWith(mobile_comm_getDic("lbl_apv_agree")); //합의
		$("#"+l_ActiveModule+"_"+viewMode+"_btReject").contents().filter(function(){ return this.nodeType === 3; }).replaceWith(mobile_comm_getDic("lbl_apv_disagree")); //거부
	}
	
	$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").removeClass("full").hide();
	$("#"+l_ActiveModule+"_"+viewMode+"_btDeptDraft").removeClass("full").hide();
	$("#"+l_ActiveModule+"_"+viewMode+"_btRec").removeClass("full").hide();
	$("#"+l_ActiveModule+"_"+viewMode+"_btReject").removeClass("full").hide();
	$("#"+l_ActiveModule+"_"+viewMode+"_buttonarea").show();
	if(btDisplay_Expence.btApproved === "Y") {
		if(btDisplay_Expence.btReject === "N") {
			$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").addClass("full").show();
		} else {
			$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").show();
			$("#"+l_ActiveModule+"_"+viewMode+"_btReject").show();
		}
	} else if(btDisplay_Expence.btRec === "Y"){
		if(btDisplay_Expence.btReject === "N") {
			$("#"+l_ActiveModule+"_"+viewMode+"_btRec").addClass("full").show();
		} else {
			$("#"+l_ActiveModule+"_"+viewMode+"_btRec").show();
			$("#"+l_ActiveModule+"_"+viewMode+"_btReject").show();
		}
	} else if(btDisplay_Expence.btDeptDraft === "Y"){
		if(btDisplay_Expence.btReject === "N") {
			$("#"+l_ActiveModule+"_"+viewMode+"_btDeptDraft").addClass("full").show();
		} else {
			$("#"+l_ActiveModule+"_"+viewMode+"_btDeptDraft").show();
			$("#"+l_ActiveModule+"_"+viewMode+"_btReject").show();
		}
	} else if(btDisplay_Expence.btReject === "Y") {
		$("#"+l_ActiveModule+"_"+viewMode+"_btReject").addClass("full").show();
	} else {
		$("#"+l_ActiveModule+"_"+viewMode+"_buttonarea").hide();
	}
}


// 전표 상세조회 내 버튼 조회 처리
function mobile_account_displayViewBtn(sDraft, schangeSave, sDoc, sPost, sLine, sRecDept, sAction, sDeptDraft, sDeptLine, sSave, sMail, sAttach, sPreview, sCommand, sRec, sTempMemo, sInfo) {
    btDisplay_Expence.btLine = sLine;
    btDisplay_Expence.btDeptDraft = sDeptDraft;
    btDisplay_Expence.btDeptLine = sDeptLine;
    
    var useHold = mobile_comm_getBaseConfig("useHold");
    var usid = mobile_comm_getSession("USERID");
    
    if (sAction == "Y")
    {
        var bReviewr = fn_GetReview(usid);
        
        if (_mobile_account_view.Mode == "REDRAFT" || _mobile_account_view.Mode == "SUBREDRAFT") {
        	// 경비결재 옵션체크 안함, accountCommon.js displayBtn 기준으로 변경
			/*
			if(_mobile_account_view.SchemaContext.scRec.isUse == "Y"){ // 접수/반려버튼 활성화
        		btDisplay_Expence.btRec = "Y";
                if (!bReviewr) btDisplay_Expence.btReject = "Y"
        	} else if(_mobile_account_view.SchemaContext.scChrRedraft.isUse == "Y") { //담당자 재기안이고, 1인결재가 가능한 경우 결재버튼 활성화
        		btDisplay_Expence.btApproved = "Y"
                if (!bReviewr) btDisplay_Expence.btReject = "Y"
            }

            {  
            	var m_evalJSON_receive = $.parseJSON(document.getElementById("APVLIST").value);
                var elmRoot_receive = $$(m_evalJSON_receive).find("steps");
                var elmRouCount_receive = $$(elmRoot_receive == undefined ? {} : elmRoot_receive ).find("division[divisiontype='receive'][oucode='" + Common.getSession("GR_Code") + "']>ou>person>taskinfo[kind != 'charge']").length;
                if (elmRouCount_receive > 0) {
                	//재기안
                	btDisplay_Expence.btDeptDraft = "Y";
                	btDisplay_Expence.btApproved = "N";
                	btDisplay_Expence.btRec = "N";
                }
            }
			*/
			if (_mobile_account_view.SubKind == "T008") { //담당자 재기안 경우 결재버튼 활성화
                btDisplay_Expence.btApproved = "Y"
                if (!bReviewr) btDisplay_Expence.btReject = "Y"
            }
        } else {
            //확인결재추가
            if (_mobile_account_view.SubKind == "T019" || _mobile_account_view.SubKind == "T005" || _mobile_account_view.SubKind == "T020") {//확인결재
            	$(".btn_approval").find("span").text(mobile_comm_getDic("lbl_apv_Confirm"));
            	btDisplay_Expence.btApproved = "Y";
            } else {
            	btDisplay_Expence.btApproved = "Y";
            	
                if (!fn_GetReview(usid)) {
                	btDisplay_Expence.btReject = "Y";
                }
            }
        }
        
        switch (_mobile_account_view.Mode) {
            case "AUDIT":
                if (useHold == "Y" && _mobile_account_view.ReqUserCode == usid) {
                	//TO-DO: 추후 e-Accounting 내 보류 개발 후 주석 해제 필요
                	//btDisplay_Expence.btHold = "Y";
                }
                break;
            case "PCONSULT":
                if (_mobile_account_view.SubKind == "T009") {
                	$(".btn_approval").find("span").text(mobile_comm_getDic("lbl_apv_agree"));
                	$(".btn_return").find("span").text(mobile_comm_getDic("lbl_apv_disagree"));
                }
            case "SUBAPPROVAL": //합의부서내 결재
                if (useHold == "Y" && _mobile_account_view.ReqUserCode == usid && _mobile_account_view.SubKind != "T019") {
                	//TO-DO: 추후 e-Accounting 내 보류 개발 후 주석 해제 필요
                	//btDisplay_Expence.btHold = "Y";
                }
                break;
            case "RECAPPROVAL": //수신부서내 결재
            case "APPROVAL":
                if (useHold == "Y" && _mobile_account_view.ReqUserCode == usid && _mobile_account_view.SubKind != "T019") { 
                	if (!bReviewr) {
                		//TO-DO: 추후 e-Accounting 내 보류 개발 후 주석 해제 필요
                		//btDisplay_Expence.btHold = "Y";
                	}
                }
                break;
            case "CHARGE":
                break;
            case "REDRAFT":
                if (useHold == "Y" && _mobile_account_view.SubKind == "T008" && _mobile_account_view.Gloct == "APPROVAL" && _mobile_account_view.Gloct == "JOBFUNCTION") {
                	//TO-DO: 추후 e-Accounting 내 보류 개발 후 주석 해제 필요
                	//btDisplay_Expence.btHold = "Y";
                }
                break;
        }
    }
    
    if(btDisplay_Expence.btApproved == "Y" || btDisplay_Expence.btRec == "Y") {
    	$("#account_view_apvProcessArea").show();
    }
    
	// 사용 가능한 버튼이 1개 이상인 경우에만 확장메뉴 조회 가능
	for(var key in btDisplay_Expence) {
		if(btDisplay_Expence[key] == "Y") {
			$("#account_view_dropMenuBtn").show();
			break;
		}
	}
}

// 확장메뉴 표시
function mobile_account_showExtMenu() {
	if($("#account_view_dropMenuBtn").hasClass("show")) {
		$("#account_view_dropMenuBtn").removeClass("show");
	} else {
		var cnt = 0;
		var sHtml = "";
		if($("#account_view_dropMenuBtn").find(".exmenu_layer").length > 0) {
			$("#account_view_dropMenuBtn").addClass("show");
		} else {
			var btnArr = [];
			btnArr.push("btModify;" + mobile_comm_getDic("btn_apv_modify")); //편집
			btnArr.push("btHold;" + mobile_comm_getDic("lbl_apv_hold")); //보류
			btnArr.push("btRejectedto;" + mobile_comm_getDic("lbl_apv_rejectedto")); //지정반송
			btnArr.push("btLine;" + mobile_comm_getDic("lbl_apv_approver")); //결재선
			btnArr.push("btDeptLine;" + mobile_comm_getDic("lbl_apv_approver")); //재기안결재선
			btnArr.push("btForward;" + mobile_comm_getDic("btn_apv_forward")); //전달
			btnArr.push("btWithdraw;" + mobile_comm_getDic("btn_apv_Withdraw")); //회수
			btnArr.push("btAbort;" + mobile_comm_getDic("btn_apv_cancel")); //취소
			btnArr.push("btApproveCancel;" + mobile_comm_getDic("btn_CancelApproval")); //승인취소
			btnArr.push("btReUse;" + mobile_comm_getDic("btn_apv_reuse")); //재사용
			btnArr.push("btApprovedlast;" + mobile_comm_getDic("btn_apv_preApproved")); //선승인(예고함)
			btnArr.push("btRejectlast;" + mobile_comm_getDic("lbl_apv_prereject")); //선반려(예고함)
			
			sHtml += "<div class=\"exmenu_layer\">";
			sHtml += "	<ul class=\"exmenu_list\">";
			var btnlength = btnArr.length;
			for(var i = 0; i < btnlength; i++) {
				var id = btnArr[i].split(';')[0];
				var value = btnArr[i].split(';')[1];
				var type = id.replace("bt", "").toLowerCase();
				
				if(btDisplay_Expence[id] == "N") continue; 
				
				//승인, 반려, 출력 버튼 팝업 메뉴 X
				if(!(mobile_comm_getBaseConfig("useMobileAccountWrite") == "Y" || mobile_comm_getBaseConfig("useMobileAccountWriteUser").indexOf(mobile_comm_getSession("UR_Code")) > -1) && (id == "btReUse" || id == "btModify")) { 
				}
				//결재선, 편집, 재사용, 재기안 - write 호출
				else if(id == "btLine" || id == "btDeptLine" || id == "btReUse" || id == "btModify") {
					var open_mode = ((id == "btLine" || id == "btDeptLine") ? "APVLIST" : id.replace("bt", "").toUpperCase());
					
					var isDisplay = false;
					//결재선 버튼은 무조건 표시 / 편집, 재사용 버튼은 설정값에 따라 표시
					if(id == "btLine" || id == "btDeptLine") {
						isDisplay = true;
					}
					else if(formJson.ExtInfo.MobileFormYN != undefined && formJson.ExtInfo.MobileFormYN == "Y" && (mobile_comm_getBaseConfig("useMobileAccountWrite") == "Y" || mobile_comm_getBaseConfig("useMobileAccountWriteUser").indexOf(mobile_comm_getSession("UR_Code")) > -1)) {
						isDisplay = true;
					}
					
					if(isDisplay) {
						sHtml += "<li><a class=\"btn\" onclick=\"mobile_account_clickmodify('" + open_mode + "');\" value=\"" + value + "\">" + value + "</a></li>";
						cnt++;
					}
				}
				//보류, 지정반송, 취소 - 의견 작성란
				else if(id == "btHold" || id == "btRejectedto" || id == "btAbort" || id == "btDeptDraft" || id == "btApprovedlast" || id == "btRejectlast") {
					sHtml += "<li><a class=\"btn\" onclick=\"mobile_approval_clickbtn('', '" + type + "');\" value=\"" + value + "\">" + value + "</a></li>";
					cnt++;
				}
				else {
					sHtml += "<li><a class=\"btn\" id=\"" + id + "\" onclick=\"mobile_account_clickbtn(this);\" value=\"" + value + "\">" + value + "</a></li>";
					cnt++;
				}
			}
			sHtml += "	</ul>";
			sHtml += "</div>";
			
			if(cnt > 0) {
				$("#account_view_dropMenuBtn").addClass("show").append(sHtml);				
			}
		}
	}
}

//결재선/편집/재사용 버튼 클릭
function mobile_account_clickmodify(open_mode) {
	window.sessionStorage["open_mode"] = open_mode;
	
	var sUrl = "/account/mobile/account/write.do";
	
	if(open_mode == "MODIFY") {
		var isApvLineChg = "N";
		if(getInfo("ApprovalLine") != $("#APVLIST").val()){
			isApvLineChg = "Y";
		}
		isLoad = "N";
		sUrl += "?" + $("#account_view_page").attr("data-url").split("?")[1].replace("#", "").replace("&editMode=", "").replace("&editMode=N", "").replace("&reuse=", "") + "&editMode=Y&reuse=&isApvLineChg="+isApvLineChg;
		
		alert(mobile_comm_getDic("msg_board_donotSaveInlineImage"));
		mobile_comm_back(sUrl);
	} else {
		sUrl = $("#account_view_page").attr("data-url").replace("view.do", "write.do")+"&editMode=N&isApvLineChg=N";
		
		if(open_mode == "REUSE") {
			isLoad = "N";
			sUrl = sUrl.replace("&reuse=", "&reuse=Y");
		}
		
		mobile_comm_go(sUrl, 'Y');
	}
}

/* 
 * 
 * 작성 페이지 시작
 * 
 */
var _mobile_account_write = {
	ExpenceApplicationID: '',
	Mode: 'DRAFT',					//새로 작성인지 수정인지 등등 (CREATE/REPLY/UPDATE/REVISION/MIGRATE)
	ApvLineMode: 'approval',		//결재선 모드 (결재: approval, 참조: tcinfo, 배포: distribution)
	OpenMode: 'DRAFT',				//작성 페이지 open mode (DRAFT: 기안, APVLIST: 결재선, TEMPSAVE: 임시함, MODIFY: 편집)
	ApplicationType: 'SC', 			//신청 타입 (SC: 간편신청, CO: 통합비용신청, EA: 직원경비신청)
	RequestType: 'NORMAL', 			//비용신청서 타입 (NORMAL : 일반비용신청)
	CardReceiptID: '',
	MobileReceiptID: '',
	DeadlineSDate: null,
	DeadlineEDate: null,
	ExpenceFormInfo: {},			//신청서 관리 정보
	TaskID: "",						//Task ID
	ParentProcessID: "",			//Parent Process ID
	ProcessID: "",					//Process ID
	WorkitemID: "",					//WorkItem ID
	PerformerID: "",				//Performer ID
	ProcessDescriptionID: "",
	UserCode: "",
	Gloct: "",
	Loct: "",
	FormID: "",						//Form ID
	FormInstID: "",
	Archived: "",
	SubKind: "",
	FormPrefix: "",					//Form Prefix
	ActionType: "",					//결재행위(승인, 반려 등)
	IsMobile: "Y",
	ListMode: "",
	ExpenceApplicationInfo: {},		//신청서 본문 정보
	SchemaContext: {},				//양식 스키마 정보
	ExpenceAppEvidDeletedList: [],	//저장 후 삭제된 증빙
	ExpenceAppEvidDeletedFile: []	//저장 후 삭제된 파일
};

// 비용 신청 초기화
function mobile_account_WriteInit() {
	if(window.sessionStorage["account_writeinit"] == "undefined"  || window.sessionStorage["account_writeinit"] == undefined || window.sessionStorage["account_writeinit"] == null) {
		window.sessionStorage["account_writeinit"] = "Y";
	}
	else {
		return;
	}
	
	if (mobile_comm_getQueryString('open_mode', "account_write_page") != 'undefined') {
		_mobile_account_write.OpenMode = mobile_comm_getQueryString('open_mode', "account_write_page");
	} else if (window.sessionStorage['open_mode'] != 'undefined' && window.sessionStorage['open_mode'] != '') {
		_mobile_account_write.OpenMode = window.sessionStorage['open_mode'];
    } else {
    	_mobile_account_write.OpenMode = 'DRAFT';
	}
	if (mobile_comm_getQueryString('expAppID', 'account_write_page') != 'undefined') {
		_mobile_account_write.ExpenceApplicationID = mobile_comm_getQueryString('expAppID', 'account_write_page');
    } else {
    	_mobile_account_write.ExpenceApplicationID = '';
    }
	if (mobile_comm_getQueryString('mode', 'account_write_page') != 'undefined') {
		_mobile_account_write.Mode = mobile_comm_getQueryString('mode', 'account_write_page');
	} else {
		_mobile_account_write.Mode = 'DRAFT';
	}
	if (mobile_comm_getQueryString('taskID', 'account_write_page') != 'undefined') {
		_mobile_account_write.TaskID = mobile_comm_getQueryString('taskID', 'account_write_page');
    } else {
    	_mobile_account_write.TaskID = '';
    }
	if (mobile_comm_getQueryString('processID', 'account_write_page') != 'undefined') {
		_mobile_account_write.ProcessID = mobile_comm_getQueryString('processID', 'account_write_page');
    } else {
    	_mobile_account_write.ProcessID = '';
    }
	if (mobile_comm_getQueryString('workitemID', 'account_write_page') != 'undefined') {
		_mobile_account_write.WorkitemID = mobile_comm_getQueryString('workitemID', 'account_write_page');
    } else {
    	_mobile_account_write.WorkitemID = '';
    }
	if (mobile_comm_getQueryString('performerID', 'account_write_page') != 'undefined') {
		_mobile_account_write.PerformerID = mobile_comm_getQueryString('performerID', 'account_write_page');
    } else {
    	_mobile_account_write.PerformerID = '';
    }
	if (mobile_comm_getQueryString('processdescriptionID', 'account_write_page') != 'undefined') {
		_mobile_account_write.ProcessDescriptionID = mobile_comm_getQueryString('processdescriptionID', 'account_write_page');
    } else {
    	_mobile_account_write.ProcessDescriptionID = '';
    }
	if (mobile_comm_getQueryString('userCode', 'account_write_page') != 'undefined') {
		_mobile_account_write.UserCode = mobile_comm_getQueryString('userCode', 'account_write_page');
    } else {
    	_mobile_account_write.UserCode = '';
    }
	if (mobile_comm_getQueryString('gloct', 'account_write_page') != 'undefined') {
		_mobile_account_write.Gloct = mobile_comm_getQueryString('gloct', 'account_write_page');
    } else {
    	_mobile_account_write.Gloct = '';
    }
	if (mobile_comm_getQueryString('loct', 'account_write_page') != 'undefined') {
		_mobile_account_write.Loct = mobile_comm_getQueryString('loct', 'account_write_page');
    } else {
    	_mobile_account_write.Loct = '';
    }
	if (mobile_comm_getQueryString('formID', 'account_write_page') != 'undefined') {
		_mobile_account_write.FormID = mobile_comm_getQueryString('formID', 'account_write_page');
    } else {
    	_mobile_account_write.FormID = '';
    }
	if (mobile_comm_getQueryString('forminstanceID', 'account_write_page') != 'undefined') {
		_mobile_account_write.FormInstID = mobile_comm_getQueryString('forminstanceID', 'account_write_page');
    } else {
    	_mobile_account_write.FormInstID = '';
    }
	if (mobile_comm_getQueryString('archived', 'account_write_page') != 'undefined') {
		_mobile_account_write.Archived = mobile_comm_getQueryString('archived', 'account_write_page');
    } else {
    	_mobile_account_write.Archived = '';
    }
	if (mobile_comm_getQueryString('subkind', 'account_write_page') != 'undefined') {
		_mobile_account_write.SubKind = mobile_comm_getQueryString('subkind', 'account_write_page');
    } else {
    	_mobile_account_write.SubKind = '';
    }
	if (mobile_comm_getQueryString('formPrefix', 'account_write_page') != 'undefined') {
		_mobile_account_write.FormPrefix = mobile_comm_getQueryString('formPrefix', 'account_write_page');
    } else {
    	_mobile_account_write.FormPrefix = '';
    }
	if (mobile_comm_getQueryString('isMobile', 'account_write_page') != 'undefined') {
		_mobile_account_write.IsMobile = mobile_comm_getQueryString('isMobile', 'account_write_page');
    } else {
    	_mobile_account_write.IsMobile = '';
    }
	if (mobile_comm_getQueryString('listmode', 'account_write_page') != 'undefined') {
		_mobile_account_write.ListMode = mobile_comm_getQueryString('listmode', 'account_write_page');
    } else {
    	_mobile_account_write.ListMode = 'ExpenceMgr';
    }
	if (mobile_comm_getQueryString('receiptid_c', 'account_write_page') != 'undefined') {
		_mobile_account_write.CardReceiptID = mobile_comm_getQueryString('receiptid_c', 'account_write_page');
    } else {
    	_mobile_account_write.CardReceiptID = '';
    }
	if (mobile_comm_getQueryString('receiptid_r', 'account_write_page') != 'undefined') {
		_mobile_account_write.MobileReceiptID = mobile_comm_getQueryString('receiptid_r', 'account_write_page');
    } else {
    	_mobile_account_write.MobileReceiptID = '';
    }

	_mobile_account_write.ExpenceAppEvidDeletedList = [];
	_mobile_account_write.ExpenceAppEvidDeletedFile = [];
	
	if(_mobile_account_write.OpenMode != "APVLIST") {
		// 결재선 편집 허용
    	isApvMod = "Y";
    	
		// 탭 선택
		mobile_account_write_clickTab($("#account_write_tabmenu").find("li.step02").find("a"), 'menu');

		// 결재선 조회
		if(_mobile_account_write.ProcessID != "") {
			mobile_account_getDomainDataDisplay(_mobile_account_write.ProcessID, true);
		}
		
		// 법인 정보 세팅
		_mobile_account_write.CompanyCode = mobile_account_getUserCompanyCode();
		
		// 신청서 관리 정보 세팅
		mobile_account_getFormManageInfo(_mobile_account_write);
		
		// 지급일 목록 세팅
		mobile_account_bindBaseCode("DefaultPayDate", "account_write_payDateType");
		
		// 증빙 목록 표시
		mobile_account_getExpenceWriteList();
		
		if((_mobile_account_write.OpenMode == "DRAFT" || _mobile_account_write.OpenMode == "TEMPSAVE") && propertyOtherApv != "Y") {
			if(_mobile_account_write.OpenMode == "DRAFT") {
				// 사용자 CostCenter 가져오기
				mobile_account_getUserCC();
			}

			// 결재선 세팅
			if(propertyOtherApv != "Y") {
				mobile_account_setWorkedAutoDomainData(_mobile_account_write.ExpenceFormInfo.ApprovalFormInfo, _mobile_account_write.OpenMode, _mobile_account_write.ExpenceApplicationID);	
			}
		}
		
		// 마감일자 셋팅
		mobile_account_setDeadlineInfo("W");
	}
	else {
		var oApproveStep;
		var oWriteHeader = $("#account_write_header");

		// 결재문서 정보 조회
		mobile_account_getFormData(_mobile_account_write);
		
		// 결재선 조회
		if($("#account_view_content").length > 0){ // if(!$("#APVLIST").val() || !window.sessionStorage["apvlist"]
			// 결재자가 결재선 편집하는 경우 APVLIST 아이디 중복으로 write페이지의 APVLIST 제거
			// view페이지의 APVLIST에 결재선 조회 후 대결/수신부서/담당업무 관련 현결재자 셋팅 된 상태이므로 그것을 사용
			$("#account_write_content").find("#APVLIST").remove();
		}else{
			mobile_account_getDomainDataDisplay(_mobile_account_write.ProcessID, false);
		}
		
	    if (_mobile_account_write.Mode == "APPROVAL") {
	        var jsonApv = JSON.parse($("#APVLIST").val());
	        oApproveStep = $$(jsonApv).find("steps>division").has("taskinfo[status='pending']").find(">step").has("ou>person[code='" + getInfo("AppInfo.usid") + "']").has("ou>person>taskinfo[status='pending'])");
	    }
	    
	    if ((_mobile_account_write.Mode == "MONITOR") || (_mobile_account_write.Mode == "PREAPPROVAL") || (_mobile_account_write.Mode == "PROCESS") || (_mobile_account_write.Mode == "REVIEW") || (_mobile_account_write.Mode == "COMPLETE") || (_mobile_account_write.Mode == "REJECT") || (_mobile_account_write.Mode == "JOBDUTY") || (_mobile_account_write.Mode == "PCONSULT") || _mobile_account_write.Mode == "T019" || _mobile_account_write.Mode == "T005") { //20110318확인결재추가-확인결재자 결재선변경권한없음
	    	isApvMod = "N";
	    } else if (oApproveStep && oApproveStep.attr("routetype") == "approve" && oApproveStep.attr("allottype") == "parallel") {		// 동시결재자 결재선변경 방지 [2015-11-24]
	    	isApvMod = "N";
	    } else {
	    	isApvMod = "Y";
	    }
	    
		$("#account_write_tabmenu").find("li:not('.step03')").hide();
		mobile_account_write_clickTab($("#account_write_tabmenu").find("li.step03").find("a"), 'menu');
		
		$(oWriteHeader).find(".pg_tit").text(mobile_comm_getDic("lbl_ApprovalLine")); //결재선
		$(oWriteHeader).find(".utill").find("a").hide();
		$(oWriteHeader).children("a").remove(); //이상한 a 태그가 추가되는 현상 임시 조치
		$("#account_write_btn_completeApv").show();

	    if(isApvMod == "N") {
	    	$(".ico_add_wh").parent().hide();
	    	$(".ico_reload").parent().hide();
	    	$("#account_write_btn_completeApv").hide();
	    	
	    	//조회모드일 경우 결재유형을 select -> p 로 변경
	    	$("#approval_write_wraptype").find("li.person").each(function(i, obj){
	    		var selectedText = $(obj).find("select").find("option:selected").text();
	    		$(obj).prepend("<p class='name' style='margin: 14px 0;'>" + selectedText + "</p>");
	    		$(obj).find("select").remove();
	    	});
	    }
	}

	// 결재암호 사용 여부
	var g_UsePWDCheck = (_mobile_account_write.ExpenceFormInfo.SchemaContext) ? _mobile_account_write.ExpenceFormInfo.SchemaContext.scWFPwd.isUse : _mobile_account_write.SchemaContext.scWFPwd.isUse;
	
	if (g_UsePWDCheck == "Y" && mobile_approval_chkUsePasswordYN()){
		flgUsePWDCheck = true;			
		$(".approval_comment").addClass("secret");
	    document.getElementById("account_write_inputpassword").focus();
	} else {
		flgUsePWDCheck = false;
		$(".approval_comment").removeClass("secret");
	}
}

// 지급일 옵션 변경에 따른 지급일자 선택 가능 여부 확인
function mobile_account_changePayDateType() {
	if($("#account_write_payDateType").find("option:selected").val() == "E") {
		if($("#account_write_payDate").hasClass()) {
			mobile_account_datepickerLoad();
		}
		
		$("#account_write_payDate").show();
	}
	else {
		$("#account_write_payDate").val("");
		$("#account_write_payDate").hide();
	}
}

// 최종 결재선 조회
function mobile_account_setWorkedAutoDomainData(formPrefix, mode, expAppID) {
	//if(mode == "DRAFT") {
		document.getElementById("APVLIST").value = '{"steps":{"status":"'+mobile_comm_getSession("USERID")+'","initiatoroucode":"'+mobile_comm_getSession("DEPTID")+'","initiatorcode":"inactive"}}';
	//}
	
	$.ajax({
		type:"POST",
		url:"/approval/getWorkedAutoDomainData.do",
		data:{ 
			strFormPrefix : formPrefix,
			strExpAppID : expAppID
		},
		async:false,
		success:function (data) {
			if(data.result == "ok"){
				var domainData = JSON.stringify(data.autoDomainData);
				
				$("#APVLIST").val(mobile_account_receiveApvHTTP(domainData, mode));
			}
			else{
				Common.Error(data);
			}
		},
		error:function(response, status, error){
			//alert(mobile_comm_getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
			mobile_comm_ajaxerror("/approval/getWorkedAutoDomainData.do", response, status, error);
		}
	});
}

// 최종 결재선 세팅 (전자결재의 receiveApvHTTP가 변경될 경우 확인 후 적용 필요)
function mobile_account_receiveApvHTTP(responseJSONdata, mode) {
	if ($$(responseJSONdata) != null) {
        var errorNode = $$(responseJSONdata).find("error");
        if ($(errorNode).length > 0) {
            alert("Desc: " + errorNode.val());
        } else {
			var sSvdt_TimeZone = CFN_TransServerTime(CFN_GetLocalCurrentDate());
			var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
			if (oApvList == null) {
				alert(mobile_comm_getDic("msg_apv_075")); //"결재선 지정 오류"
			} else {
				var sessionObj = mobile_comm_getSession(); //전체호출
				if(!sessionObj["ApprovalParentGR_Name"]) sessionObj["ApprovalParentGR_Name"] = sessionObj["GR_MultiName"];
				
				var oGetApvList = {};
				if ($$(responseJSONdata).find("steps").exist()) {
					//결재선 내 & 문자열로 인해 오류 발생으로 수정함
					oGetApvList = $.parseJSON(responseJSONdata.replace(/&/gi, '&amp;'));
				}
				var oCurrentOUNode;
				if (mode == "REDRAFT") {
					var sUserCode = _mobile_account_view.UserCode; // 원결재자
		
					//담당부서 - 담당부서 및 담당업무 결재선 삭제할것 그 후로 기안자 결재선 입력할것
					oCurrentOUNode = $$(oApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']");
					if (oCurrentOUNode == null) {
						var oDiv = {};
						$$(oDiv).attr("taskinfo", {});
						$$(oDiv).attr("step", {});
						$$(oDiv).attr("divisiontype", "receive");
						$$(oDiv).attr("name", mobile_comm_getDic("lbl_apv_ChargeDept"));
						$$(oDiv).attr("oucode", sessionObj["ApprovalParentGR_Code"]);
						$$(oDiv).attr("ouname", sessionObj["ApprovalParentGR_Name"]);
						
						$$(oDiv).find("taskinfo").attr("status", "pending");
						$$(oDiv).find("taskinfo").attr("result", "pending");
						$$(oDiv).find("taskinfo").attr("kind", "receive");
						$$(oDiv).find("taskinfo").attr("datereceived", sSvdt_TimeZone);
						
						$$(oApvList).find("division").push(oDiv);
						
						oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])[divisiontype='receive']");
					}
					var oRecOUNode = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
					var tempOu = null;
					if (oRecOUNode.length != 0 && $$(oRecOUNode).find("ou").hasChild("person").length == 0) {
						tempOu = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
						$$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']").remove();
					}
					var oChargeNode = $$(oCurrentOUNode).find("step").has("ou>person>taskinfo[status='pending']");

					//담당 수신자 대결
					var isChkDeputy = false;

					if (oChargeNode.length != 0) {
						//담당 수신자 대결 S ----------------------------------------
						var objDeputyOU = $$(oApvList).find("steps>division[divisiontype='receive']>step>ou");
						var chkObjPersonNode = $$(objDeputyOU).find("person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "']").find(">taskinfo[status='pending']");
                        var chkObjRoleNode = $$(objDeputyOU).find("role:has(person[code='" + sUserCode + "'][code!='" + sessionObj["USERID"] + "'])");
						
						if (0 < (chkObjPersonNode.length + chkObjRoleNode.length)) {
							isChkDeputy = true;
						}
						//담당 수신자 대결 E -----------------------------------------
						
						var oRecApprovalNode = $$(oCurrentOUNode).find("step>ou>person>taskinfo[status='inactive']");
						if (oRecApprovalNode.length != 0) {
							for(var i=0; i<oRecApprovalNode.length; i++){
								var RecApprovalNode = oRecApprovalNode.concat().eq(i);
								oCurrentOUNode.concat().eq(0).remove(RecApprovalNode.parent().parent().parent());
							}
						}

						//person의 takinfo가 inactive가 있는 경우 routetype을 변경함
						var nodesInactives = $$(oCurrentOUNode).find("step[routetype='receive']").has("ou > person > taskinfo[status='inactive']");

						$$(nodesInactives).each(function (i, nodesInactive) {
							$$(nodesInactive).attr("unittype", "person");
							$$(nodesInactive).attr("routetype", "approve");
							$$(nodesInactive).attr("name", mobile_comm_getDic("lbl_apv_ChargeDept"));	
						});

					}

					
					var oJFNode = $$(oCurrentOUNode).find("step").has("ou>role>taskinfo[status='pending'], ou>role>taskinfo[status='reserved']"); 
					var bHold = false; //201108 보류여부
					var oComment = null;
					if (oJFNode.length != 0) {
						var oHoldTaskinfo = $$(oJFNode).find("ou>role>taskinfo[status='reserved']");
						if (oHoldTaskinfo.length != 0) {
							bHold = true;
							oComment = $$(oHoldTaskinfo).find("comment").json();
							
							// 보류한 사용자와 로그인한 사용자가 다른 경우
                            if($$(oComment).attr("reservecode") != undefined && $$(oComment).attr("reservecode") != sessionObj["USERID"]) {
                            	alert(mobile_comm_getDic("msg_apv_holdOther")); // 해당 양식은 다른 사용자가 보류한 문서입니다.
                            	bHold = false;
                        	}
						}
						tempOu = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='reserved']");
						$$(oCurrentOUNode).eq(0).remove("step");
					}

					$$(oCurrentOUNode).attr("oucode", sessionObj["ApprovalParentGR_Code"]);
					$$(oCurrentOUNode).attr("ouname", sessionObj["ApprovalParentGR_Name"]);
					
					$$(oCurrentOUNode).find("taskinfo").attr("status", "pending");
					$$(oCurrentOUNode).find("taskinfo").attr("result", "pending");
					
					var oStep = {};
					var oOU = {};
					var oPerson = {};
					var oTaskinfo = {};

					$$(oStep).attr("unittype", "person");
					$$(oStep).attr("routetype", "approve");
					$$(oStep).attr("name", mobile_comm_getDic("lbl_apv_ChargeDept"));
					
					$$(oOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
					$$(oOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
					
					$$(oOU).attr("taskid", (tempOu ? tempOu.find("ou").attr("taskid") : $$(oCurrentOUNode).find("step>ou").attr("taskid")));
					$$(oOU).attr("widescid", (tempOu ? tempOu.find("ou").attr("widescid") : $$(oCurrentOUNode).find("step>ou").attr("widescid")));
					$$(oOU).attr("wiid", (tempOu ? tempOu.find("ou").attr("wiid") : $$(oCurrentOUNode).find("step>ou").attr("wiid")));
					
					$$(oPerson).attr("code", sessionObj["USERID"]);
					$$(oPerson).attr("name", sessionObj["UR_MultiName"]);
					$$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
					$$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
					$$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
					$$(oPerson).attr("oucode", sessionObj["DEPTID"]);
					$$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
					$$(oPerson).attr("sipaddress", sessionObj["UR_Mail"]);
					
					$$(oTaskinfo).attr("status", (bHold == true ? "reserved" : "pending")); 
					$$(oTaskinfo).attr("result", (bHold == true ? "reserved" : "pending")); 
					$$(oTaskinfo).attr("kind", "charge");
					$$(oTaskinfo).attr("datereceived", sSvdt_TimeZone);
					if (bHold) $$(oTaskinfo).attr("comment", oComment); 
					
					$$(oPerson).append("taskinfo", oTaskinfo);
					
					$$(oOU).append("person", oPerson);
					
					$$(oStep).append("ou", oOU);
					
					// 조건 추가 - charge가 있는 경우에만 실행
					// receive division의 첫번째 step 교체
					if($$(oCurrentOUNode).find("step > ou > person > taskinfo[kind='charge']").length > 0) {                        
						$$(oCurrentOUNode).append("step", oStep);
						$$(oCurrentOUNode).find("step").concat().eq(0).remove();
					}
					else if($$(oCurrentOUNode).find("step").length == 0) {
						$$(oCurrentOUNode).append("step", oStep);
					}
					
					//담당 수신자 대결 S ---------------------------------------------
					if (isChkDeputy) {
						alert(mobile_comm_getDic("msg_ApprovalDeputyWarning"));
						
						objDeputyOU = $$(oApvList).find("steps>division").has("taskinfo[status='pending']").find("step>ou");

						var objOriginalApprover = $$(oChargeNode).find('ou').find("person");
						$$(objOriginalApprover).attr('title', $$(objOriginalApprover).attr('title'));
						$$(objOriginalApprover).attr('level', $$(objOriginalApprover).attr('level'));
						$$(objOriginalApprover).attr('position', $$(objOriginalApprover).attr('position'));

						$$(objOriginalApprover).find('taskinfo').remove('datereceived');
						$$(objOriginalApprover).find('taskinfo').attr('kind', 'bypass');
						$$(objOriginalApprover).find('taskinfo').attr('result', 'inactive');
						$$(objOriginalApprover).find('taskinfo').attr('status', 'inactive');

						// [2015-05-28 modi] 현재 대결인 division에만 추가하도록
                        //objDeputyOU = $(oApvList).find("steps > division[divisiontype='receive'] > step > ou");
                        //objDeputyOU = $$(oApvList).find("steps>division").has("taskinfo[status='pending']").find("step>ou");
                        //$$(objDeputyOU).append("person", $$(objOriginalApprover).json());
                        
                        // [2020-10-23] person 추가에서 step 추가로 변경
                        $$(oChargeNode).attr("routetype", "approve");
                        $$(oChargeNode).attr("name", "원결재자");
                    	$$(oCurrentOUNode).append("step", $$(oChargeNode).json());
					}
					//담당 수신자 대결 E ----------------------------------------------

					//퇴직자 및 인사정보 최신 적용을 위해 추가 예외사항생기더라도 기안/재기안자 결재선 디스플레이
					document.getElementById("APVLIST").value = JSON.stringify($$(oApvList).json());
					
					var nodesAllItems;
					nodesAllItems = $$(oGetApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']").has("step");

					if (nodesAllItems.length > 0) {
						var oSteps = $$(oGetApvList).find("steps");
						var oCheckSteps = chkAbsent(oSteps);

						if (oCheckSteps) {
							//담당 대결자 체크 필요 
							//1. 중복으로 들어가는 문제 검토 필요 (주석 처리)
							//2. chkAbsent(oSteps) 함수에서 퇴직자 정보 체크 한다 - 아래 appendChild 확인 필요
							//3. 담당수신자 지정 후 담당수신자를 대결 지정시 아래 로직을 거치면 중복으로 결재자가 들어간다

							var absentType = oCheckSteps.split("@@@")[0];
                        	var absentMsg = oCheckSteps.split("@@@")[1];
                        	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                        	                            		
                    		alert(absentMsg);
                    		
                    		if(absentType == "change") {
                    			$$(oSteps).find("division").concat().has(">taskinfo[status='pending']").find("[divisiontype='receive'] > step[unittype='person']").has("ou>person>taskinfo[kind!='charge']").each(function (i, enodeItem) {
                    				var isChanged = false; //인사정보 변경 여부
                    				for(var j = 0; j < absentCode.length; j++) {
                    					if(absentCode[j] != "") {
                        					if(absentCode[j] == $$(enodeItem).find("ou>person").attr("code")) {
                        						isChanged = true;
                        					}
                    					}
                    				}

                    				if(!isChanged) { //인사정보 변경되지 않은 결재자만 추가
                    					$$(oApvList).find("division[divisiontype='receive']").append("step", enodeItem.json());
                    				}
                                });
                    		}
						}else{
							$$(oSteps).find("division").concat().has(">taskinfo[status='pending']").find("[divisiontype='receive'] > step[unittype='person']").has("ou>person>taskinfo[kind!='charge']").each(function (i, enodeItem) {
								$$(oApvList).find("division[divisiontype='receive']").append("step", enodeItem.json());
							});
						}
					}
					if (nodesAllItems.length > 0) {
						//document.getElementById("comCostAppView_DeptDraftBtn").style.display = "inline";
					}
				} else {
//					if (sessionObj["DEPTID"] != sessionObj["DEPTID"]) 
//						$(oApvList).find("steps").attr("initiatoroucode", sessionObj["DEPTID"]);
					
					var oSteps = {};
					var oDiv = {};
					var oDivTaskinfo = {};
					var oStep = {};
					var oOU = {};
					var oPerson = {};
					var oTaskinfo = {};
					
					$$(oDiv).attr("divisiontype", "send");
					$$(oDiv).attr("name", mobile_comm_getDic("lbl_apv_circulation_sent"));
					$$(oDiv).attr("oucode", sessionObj["ApprovalParentGR_Code"]);
					$$(oDiv).attr("ouname", sessionObj["ApprovalParentGR_Name"]);
					
					$$(oDivTaskinfo).attr("status", "inactive");
					$$(oDivTaskinfo).attr("result", "inactive");
					$$(oDivTaskinfo).attr("kind", "send");
					$$(oDivTaskinfo).attr("datereceived", sSvdt_TimeZone);
					
					$$(oDiv).attr("taskinfo", oDivTaskinfo);
					
					$$(oStep).attr("unittype", "person");
					$$(oStep).attr("routetype", "approve");
					$$(oStep).attr("name", mobile_comm_getDic("lbl_apv_writer"));
					
					$$(oOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
					$$(oOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
					
					$$(oPerson).attr("code", sessionObj["USERID"]);
					$$(oPerson).attr("name", sessionObj["UR_MultiName"]);
					$$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
					$$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
					$$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
					$$(oPerson).attr("oucode", sessionObj["DEPTID"]);
					$$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
					$$(oPerson).attr("sipaddress", "");
					
					$$(oTaskinfo).attr("status", "inactive");
					$$(oTaskinfo).attr("result", "inactive");
					$$(oTaskinfo).attr("kind", "charge");
					$$(oTaskinfo).attr("datereceived", sSvdt_TimeZone);
					
					$$(oPerson).attr("taskinfo", oTaskinfo);
					
					$$(oOU).attr("person", oPerson);
					
					$$(oStep).attr("ou", oOU);
					
					$$(oDiv).attr("step", oStep);
					
					$$(oSteps).attr("division", oDiv);
					
					oApvList = {"steps" : oSteps};
					
					$("#APVLIST").val(JSON.stringify(oApvList));
					
					oCurrentOUNode = $$(oApvList).find("steps > division").has("taskinfo[status='inactive']").concat().eq(0);

					var nodesAllItems = $$(oGetApvList).find("steps>division[divisiontype='send']>step");
					if (nodesAllItems.exist() > 0) {
						var oSteps = $$(oGetApvList).find("steps").concat().eq(0);
						var oCheckSteps = chkAbsent(oSteps);
						if (oCheckSteps) {
							$$(oSteps).find("division[divisiontype='send']>step").has("[unittype='person'],[unittype='role'],[unittype='ou']").each(function (i, enodeItem) {
								$$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
							});
						}
					}
						
					//부서장결재단계사용. 임시저장, 편집, 재사용시 진행하지 않음
					if(mode == "DRAFT"){
						var nodesAllItems3 = $$(oGetApvList).find("steps > step[unittype='role']");
						if (nodesAllItems3.length > 0) {
							var oSteps = $$(oGetApvList).find("steps").concat().eq(0);
							nodesAllItems3.each(function (i, enodeItem) {
								$$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
							});
						}
					}
					//참조자 출력
					$$(oGetApvList).find("steps > ccinfo").concat().each(function (i, enodeItem) {
						$$(oApvList).find("steps").append("ccinfo", enodeItem.json());
					});
				}

				return JSON.stringify(oApvList);
			}
        }
    }
}

//탭 선택
function mobile_account_write_clickTab(obj, target) {
	var value = $(obj).parent().attr("value");
	
	$("#account_write_tab" + target).find("li").removeClass("on");
	$("#account_write_wrap" + target).children().removeClass("on");
	
	$(obj).parent().addClass('on');
	$("#" + value).addClass("on");
	
	//target : menu
	if(value == "account_write_div_detailItem" || value == "account_write_div_approvalLine" || value == "account_write_div_preview") {
		if($("#APVLIST").val() != "" && value == "account_write_div_approvalLine") {
			mobile_approval_getApprovalLine();
		}

		// 첨부 업로드 세팅
		//mobile_comm_uploadhtml();
	}
	
	//targe : type
	if(value == "account_write_div_approval") {
		_mobile_approval_write.ApvLineMode = "approval";
	}
	if(value == "account_write_div_tcinfo") {
		_mobile_approval_write.ApvLineMode = "tcinfo";
	}
	if(value == "account_write_div_distribution") {
		_mobile_approval_write.ApvLineMode = "distribution";
	}
}

// 법인 정보 조회
function mobile_account_getUserCompanyCode() {
	var CompanyCode = "";
	var SessionUser = mobile_comm_getSession("UR_Code");
	$.ajax({
		type:"POST",
		url:"/account/accountCommon/getCompanyCodeOfUser.do",
		data:{
			"SessionUser" : SessionUser
		},
		async:false,
		success:function (data) {
			if(data.status == "SUCCESS"){
				CompanyCode = data.CompanyCode;
			}
			else{
				alert(mobile_comm_getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
			}
		},
		error:function (error){
			alert(mobile_comm_getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
		}
	});
	return CompanyCode;
}

// 신청서 관리 정보 조회
function mobile_account_getFormManageInfo(pPageObj) {
	$.ajax({
		type:"POST",
		url:"/account/formManage/getFormManageInfo.do",
		data:{
			"formCode" : pPageObj.RequestType,
			"companyCode" : pPageObj.CompanyCode
		},
		async:false,
		success:function (data) {
			if (data.result == "ok" && data.list != null && data.list.length > 0) {
				pPageObj.ExpenceFormInfo = data.list[0];
				
				if(!pPageObj.ExpenceFormInfo.ApprovalFormInfo) {
					pPageObj.ExpenceFormInfo.ApprovalFormInfo = mobile_comm_getBaseConfig("LegacyFormIDForEAccount", mobile_comm_getSession("DN_ID"));
				}

				// 담당업무함 히든 필드 세팅
				mobile_account_getJobFunctionData();
				
				// 결재 설정값도 경비결재 설정값으로 변경
				$.extend(_mobile_account_write.ExpenceFormInfo.SchemaContext.scChgr, {"value" : _mobile_account_write.ExpenceFormInfo.ChargeJob});
					
			}
			else{
				alert(mobile_comm_getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
			}
		},
		error:function (error){
			alert(mobile_comm_getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
		}
	});
}

// 담당업무함 히든 필드 세팅
function mobile_account_getJobFunctionData() {
	$.ajax({
		type:"POST",
		url:"/approval/legacy/getJobFunctionData.do",
		async:false,
		data:{
			JobFunctionCode : _mobile_account_write.ExpenceFormInfo.AccountChargeInfo
			, CompanyCode : mobile_account_getUserCompanyCode()
		},
		success:function (data) {
			if(data.status == "SUCCESS" && data.result.JobFunctionData){
				$("#account_write_chargeJob").val(data.result.JobFunctionData);
			}else{
				$("#account_write_chargeJob").val("");
			}
		},
		error:function (error){
			alert(mobile_comm_getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
			$("#account_write_chargeJob").val("");
		}
	});
}

// 증빙 데이터 가져오기
function mobile_account_getExpenceWriteList() {
	if(_mobile_account_write.OpenMode == "DRAFT") {
		var iExpenceIdx = 0;
		
		// 법인카드 증빙 그리기
		if(_mobile_account_write.CardReceiptID != "") {
			$.ajax({
				type:"POST",
				data:{
					ExpenceApplicationID: '',
					receiptID: _mobile_account_write.CardReceiptID,
					StartDate: '',
					EndDate: ''
				},
				url:"/account/mobile/account/getCardReceipt.do",
				success:function (data) {
					if(data.status == "SUCCESS") {
						if(data.list.length > 0) {
							$(data.list).each(function(i, obj) {
								mobile_account_setWriteExpenceHtml(_mobile_account_write.OpenMode, iExpenceIdx, obj);
								iExpenceIdx++;
							});
						}
					}
				},
				error:function(response, status, error){
				     mobile_comm_ajaxerror("/account/mobile/account/getCardReceipt.do", response, status, error);
				}
			});
		}
		
		// 모바일 영수증 그리기
		if(_mobile_account_write.MobileReceiptID != "") {
			$.ajax({
				type:"POST",
				data:{
					receiptID: _mobile_account_write.MobileReceiptID
				},
				url:"/account/mobile/account/getMobileReceipt.do",
				success:function (data) {
					if(data.status == "SUCCESS") {
						if(data.list.length > 0) {
							$(data.list).each(function(i, obj) {
								mobile_account_setWriteExpenceHtml(_mobile_account_write.OpenMode, iExpenceIdx, obj);
								iExpenceIdx++;
							});
						}
					}
				},
				error:function(response, status, error){
				     mobile_comm_ajaxerror("/account/mobile/account/getMobileReceipt.do", response, status, error);
				}
			});
		}
	}
	else if(_mobile_account_write.OpenMode == "TEMPSAVE") {
		$.ajax({
			type:"POST",
			data:{
				ExpenceApplicationID: _mobile_account_write.ExpenceApplicationID
			},
			url:"/account/mobile/account/searchExpenceApplication.do",
			success:function (data) {
				if(data.status == "SUCCESS") {
					var oExpApp = data.data;
					var iAmountSum = 0;

					// 청구금액 계산
					$(oExpApp.pageExpenceAppEvidList).each(function(i, obj) {
						$(obj.divList).each(function(i, oDiv) {
							iAmountSum += oDiv.Amount;
						});
					});
					
					// 증빙 정보 세팅
					$("#account_write_subject").val(oExpApp.ApplicationTitle);
					$("#account_write_TotalAmount").text(mobile_comm_addComma(oExpApp.TotalAmountSum.toString()));
					$("#account_write_ReqAmount").text(mobile_comm_addComma(iAmountSum.toString()));
					
					if(oExpApp.CostCenterName != "") {
						$("#account_write_costCenter").val(oExpApp.CostCenterName);
						$("#account_write_costCenter_code").val(oExpApp.CostCenterCode);
					}
					
					if(oExpApp.IOName != "") {
						$("#account_write_IO").val(oExpApp.IOName);
						$("#account_write_IO_code").val(oExpApp.IOCode);
					}
					
					if(mobile_account_nullToBlank(oExpApp.PayDateType)) {
						var sPayDate = oExpApp.pageExpenceAppEvidList[0].PayDate;
						var oPayDate = new Date();
						
						oPayDate.setFullYear(oExpApp.pageExpenceAppEvidList[0].PayDate.substring(0, 4));
						oPayDate.setMonth(sPayDate.substring(4, 6));
						oPayDate.setDate(sPayDate.substring(6, 8));
			            
						$("#account_write_payDateType").val(oExpApp.PayDateType);
						$("#account_write_payDate").val(mobile_comm_getDateTimeString("yyyy-MM-dd", oPayDate));
						
						mobile_account_changePayDateType();
					}
					
					// 비용 정보 세팅
					$(oExpApp.pageExpenceAppEvidList).each(function(i, obj) {
						mobile_account_setWriteExpenceHtml(_mobile_account_write.OpenMode, i, obj);
					});
					
					_mobile_account_write.ExpenceApplicationInfo = oExpApp;
					
					// 전결규정에서 담당업무를 셋팅한 경우 임시저장문서 로드시 적용
					mobile_setChargeJob("Write", _mobile_account_write.ExpenceApplicationInfo.ChargeJob);

				}
			},
			error:function(response, status, error){
			     mobile_comm_ajaxerror("/account/mobile/account/getMobileReceipt.do", response, status, error);
			}
		});
	}
}

//비용신청 내 증빙 HTML 리턴
function mobile_account_setWriteExpenceHtml(openMode, idx, obj) {
	var sHtml = "";
	var sFileHtml = "";
	var sDocLinkHtml = "";
	var sExpListTemplate = "";
	
	var today = new Date();
	var proofTodayDateStr = today.getFullYear() + '.' + mobile_account_addZero(today.getMonth()+1) + '.' + mobile_account_addZero(today.getDate());
	var receiptID = "";
	var expenceAppListID = "";
	var iTotalAmount = 0;
	var ofileInfo;
	
	if(obj.ProofCode == "EtcEvid") {
		receiptID = obj.ExpAppEtcID;
	}
	else {
		//storeName = obj.StoreName;
		receiptID = obj.ReceiptID;
	}
	
	if(obj.TotalAmount) {
		iTotalAmount = mobile_comm_addComma(obj.TotalAmount.toString().trim().replace(/,/gi, ''));
	}
	
	if(obj.ExpenceApplicationListID) {
		expenceAppListID = obj.ExpenceApplicationListID;
	}
	
	// 비용 분할 HTML 템플릿
	sExpListTemplate += "<div class='nea_card_detail_bottom_wrap' name='account_write_div'>";
	sExpListTemplate += "	<div class='nea_card_detail_bottom'>";
	sExpListTemplate += "		<select class='detail_bottom_sel' id='account_write_expType_" + receiptID + "'>" + mobile_account_setOption() + "</select>";
	sExpListTemplate += "		<p class='detail_bottom_tx'><input type='text' style='text-align: right;' id='account_write_reqAmount_" + receiptID + "' class='detail_bottom_tx_input' value='' onchange='javascript:mobile_account_setAmount();' onkeypress='return mobile_account_inputNumChk(event, this);' onkeyup='mobile_account_setNumberComma(this);'></p>"
	sExpListTemplate += "		<textarea class='HtmlCheckXSS ScriptCheckXSS' id='account_write_content_" + receiptID + "' placeholder='" + mobile_comm_getDic("ACC_msg_inputComment") + "'></textarea>";
	sExpListTemplate += "	</div>";
	sExpListTemplate += "</div>";
	
	// 1. 증빙 HTML 그리기
	sHtml += "<li id='account_write_li_" + receiptID + "'>";
	sHtml += "	<input type='hidden' id='account_write_DetailInfo_" + receiptID + "' proofCode='" + obj.ProofCode + "' value='" + encodeURIComponent(mobile_account_getEscapeStr(JSON.stringify(obj))) + "' />";
	sHtml += "	<div class='nea_applist_write'>";
	sHtml += "		<div class='card_chk'>";
	sHtml += "			<input type='checkbox' value='" + receiptID + "' id='account_write_chk_" + idx + "'><label for='account_write_chk_" + idx + "'></label>";
	sHtml += "		</div>";
	sHtml += "		<div class='card_con'>";
	sHtml += "			<p class='tx_cost'><span class='tx_cost_pc' id='account_write_useAmount_" + receiptID + "'>" + iTotalAmount + "</span>" + mobile_comm_getDic("ACC_lbl_won") + "</p>";
	sHtml += "			<p class='tx_cont ellip'>" + mobile_account_nullToBlank(obj.StoreName) + "</p>";
	sHtml += "			<p class='tx_date' id='account_write_useDate_" + receiptID + "'>" + ((obj.ProofDateStr == "" || obj.ProofDateStr == undefined) ? proofTodayDateStr : obj.ProofDateStr) + "</p>";
	
	// 법인카드, 모바일 영수증에 한하여 증빙 팝업 조회 가능
	if(obj.ProofCode == "CorpCard" || obj.ProofCode == "Receipt") {
		sHtml += "			<a onclick='javascript: mobile_account_showPopup(\"" + obj.ProofCode + "\",\"" + receiptID + "\", \"" + (obj.ReceiptFileID ? obj.ReceiptFileID : obj.FileID) + "\", \"" + mobile_account_nullToBlank(obj.CardApproveNo) + "\"); return false;' class='btn_bill'><span></span></a>";	
	}
	
	sHtml += "		</div>";
	
	if(openMode == "DRAFT") {
		sHtml += sExpListTemplate;
	}
	else {
		// 증빙별 첨부파일 데이터 세팅
		ofileInfo = obj.fileInfoList;
		
		// 증빙별 연결문서 표시
		$(obj.docList).each(function(i, oDocLink) {
			sDocLinkHtml += mobile_account_getDocLinkHtml(true, oDocLink.ProcessID, oDocLink.Subject, oDocLink.bstored, oDocLink.BusinessData1, oDocLink.BusinessData2);
		});
		
		// 비용분할 표시
		$(obj.divList).each(function(i, oDiv) {
			sHtml += sExpListTemplate;
		});
	}

	sHtml += "		<p class='nea_applist_file' onclick='$(\"#mobile_attach_input_" + receiptID + "\").click();'>" + mobile_comm_getDic("lbl_apv_filelist") + "</p>";
	sHtml += "		<p class='nea_applist_doc' onclick='javascript: mobile_account_addDocLink(\"" + receiptID + "\");'>" + mobile_comm_getDic("lbl_apv_linkdoc") + "</p>";
	sHtml += "		<ul id='account_write_AttachInfo_" + receiptID + "' style='margin-top: 5px;'></ul>";
	sHtml += "		<div id='account_write_DocLinkInfo_" + receiptID + "'></div>";
	sHtml += "		<div covi-mo-attachupload system='Account' controlID='" + receiptID + "' style='display: none;'></div>";
	sHtml += "	</div>";
	sHtml += "</li>";
	
	// 2. HTML 생성
	$("#account_write_list").append(sHtml).trigger("create");

	// 3. 데이터 세팅
	if(openMode == "DRAFT") {
		$("#account_write_expType_" + receiptID).val(obj.StandardBriefID);
		$("#account_write_reqAmount_" + receiptID).val(iTotalAmount);
		$("#account_write_content_" + receiptID).val(obj.UsageText);
	}
	else {
		$(obj.divList).each(function(i, oDiv) {
			$(".nea_card_detail_bottom_wrap").eq(i).attr("id", "account_write_div_" + oDiv.ExpenceApplicationDivID);
			$("[id='account_write_expType_" + receiptID + "']").eq(i).val(oDiv.StandardBriefID);
			$("[id='account_write_reqAmount_" + receiptID + "']").eq(i).val(mobile_comm_addComma(oDiv.Amount.toString()));
			$("[id='account_write_content_" + receiptID + "']").eq(i).val(oDiv.UsageComment);
		});

		if(sDocLinkHtml != "") {
			$("#account_write_DocLinkInfo_" + receiptID).append(sDocLinkHtml);
		}
	}
	
	// 4. 파일 업로드 HTML 생성 및 기존 파일 로딩
	mobile_comm_uploadhtml(ofileInfo);
	
	// 5. 날짜 컨트롤 로딩
	mobile_account_getExpenceWriteListPost();
}

//증빙 데이터 리턴 이후 공통으로 실행되어야 할 프로세스
function mobile_account_getExpenceWriteListPost() {
	//datepicker
	mobile_account_datepickerLoad();
	
	// 총액 세팅
	mobile_account_setAmount();
}

// 경비구분 select box option setting
function mobile_account_setOption() {
	var CompanyCode = mobile_account_getUserCompanyCode();
	
	var sHtml = "<option value=''>" + mobile_comm_getDic("ACC_expType") + "</option>";
	var sURL = "/account/mobile/account/getBriefCombo.do";
	$.ajax({
		type:"POST",
		data:{
			"isSimp": "Y",
			"CompanyCode": CompanyCode
		},
		url:sURL,
		async: false,
		success:function (data) {			
			if(data.status == "SUCCESS") {
				if(data.list.length > 0) {
					$(data.list).each(function(i, obj){
						sHtml += "<option value='" + obj.StandardBriefID 
									+ "' desc='" + obj.StandardBriefDesc 
									+ "' AccountCode='" + obj.AccountCode 
									+ "' AccountName='" + obj.AccountName 
									+ "' TaxCode='" + obj.TaxCode 
									+ "' TaxCodeName='" + obj.TaxCodeName 
									+ "' TaxType='" + obj.TaxType 
									+ "' TaxTypeName='" + obj.TaxTypeName + "'>" 
									+ obj.StandardBriefName + "</option>";
					});
				}
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror(sURL, response, status, error);
		}
	});
	
	return sHtml;
}

// 증빙총액, 청구금액 바인딩
function mobile_account_setAmount() {
	var totalAmount = 0;
	var reqAmount = 0;
	
	$("#account_write_list").find("span[id^=account_write_useAmount_]").each(function(i, obj) {
		if($(obj).text() != "") {
			totalAmount += parseInt($(obj).text().replace(/,/gi, ''));
		}
	});
	
	$("#account_write_list").find("input[id^=account_write_reqAmount_]").each(function(i, obj) {
		if($(obj).val() != "") {
			reqAmount += parseInt($(obj).val().replace(/,/gi, ''));
		}
	});
	
	$("#account_write_TotalAmount").text(mobile_account_toAmtFormat(totalAmount));
	$("#account_write_ReqAmount").text(mobile_account_toAmtFormat(reqAmount));
}

// 연관문서 선택 팝업 open
function mobile_account_addDocLink(pKeyNo) {
	window.sessionStorage["account_docLink_receiptID"] = pKeyNo;
	
	// 전자결재 연결문서 팝업 이용
	mobile_approval_addDocLink();
}

// 선택된 연관문서 바인딩
function mobile_account_setLinkedDoc(param) {
	if(param != "" && param != undefined) {
		var sHtml = "";
		
		var docs = param.split("^^^");
		var cnt = docs.length;
		var obj = $("#account_write_DocLinkInfo_" + window.sessionStorage.getItem("account_docLink_receiptID"));
		
		for(var i = 0; i < cnt; i++) {
			var doc = docs[i];
			var aDoc = doc.split("@@@"); // {ProcessID or ProcessArchiveID}@@@{FormPrefix}@@@{FormSubject}@@@{FormInstanceID}@@@{bStored}@@@{BusinessData1}@@@{BusinessData2}
			var pid = aDoc[0];
			var fmpf = aDoc[1];
			var fname = aDoc[2];
			var fiid = aDoc[3];
			var bStored = aDoc[4];
			var businessData1 = mobile_account_nullToBlank(aDoc[5]);
			var businessData2 = mobile_account_nullToBlank(aDoc[6]);
			
			$(obj).find("a").each(function (i, obj) {
				if($(obj).attr("value") == pid) {
					pid = "duplicate";
				}
			});
			
			if(pid != "duplicate") {
				sHtml += mobile_account_getDocLinkHtml(true, pid, fname, bStored, businessData1, businessData2);
			}
		}
		
		$(obj).append(sHtml).show();
		window.sessionStorage.removeItem('account_docLink_receiptID');
	}
}

//세부항목 - 연관문서 삭제
function mobile_account_delLinkedDoc(pObj) {
	$(pObj).parent().remove();
}

// 거래처 선택 dialog open
function mobile_account_goSearchVendor(pReceiptID) {
	var sUrl = "/account/mobile/account/vendor.do";
	window.sessionStorage["vendor_receipt_id"] = pReceiptID;
	mobile_comm_go(sUrl, 'Y');
}

function mobile_account_goSearchPrivateCard(pReceiptID) {
	var sUrl = "/account/mobile/account/prcard.do";
	window.sessionStorage["prcard_receipt_id"] = pReceiptID;
	mobile_comm_go(sUrl, 'Y');
}

//코스트센터 선택 dialog open
function mobile_account_goSearchCostCenter() {
	var sUrl = "/account/mobile/account/costcenter.do";
	mobile_comm_go(sUrl, 'Y');
}

//IO 선택 dialog open
function mobile_account_goSearchIO() {
	var sUrl = "/account/mobile/account/io.do";
	mobile_comm_go(sUrl, 'Y');
}

// 신청서 기안
function mobile_account_draft(pSaveMode) {
	var IsTempSave = (pSaveMode == "S" ? "N" : "Y");
	
	// 신청서 유효성 체크
	if($("#account_write_list").find("li").length <= 0) {
		alert(mobile_comm_getDic("ACC_msg_noSaveData")); //저장할 데이터가 없습니다.
		return false;
	}
	else if($("#account_write_subject").val() == "") {
		alert(mobile_comm_getDic("ACC_msg_noTitle")); //제목을 입력해 주십시오
		return false;
	}
	
	// 기안 또는 임시저장 수행
	if(IsTempSave != "Y") {
		if(Number($("#account_write_TotalAmount").text().replace(/,/gi, '')) < Number($("#account_write_ReqAmount").text().replace(/,/gi, ''))) {
			alert(mobile_comm_getDic("ACC_051")); //항목의 세부비용의 합계금액이 증빙금액보다 클 수 없습니다.
			return false;
		}
		else if($("#account_write_payDateType").val() == ""
			|| ($("#account_write_payDateType").val() == "E" && $("#account_write_payDate").val() == "")) {
			alert(mobile_comm_getDic("ACC_035")); //지급일이 입력되지 않았습니다.
			return false;
		}
		else {
			mobile_approval_clickbtn($(".txt_area"), 'draft');
		}
	}
	else {
		mobile_account_save(pSaveMode);
	}
}

//결재 시 결재 진행 관련 버튼 disabled 처리
function mobile_account_disableBtns(bDisabled, bToggle) {
	var viewMode;
	
	if($.mobile.activePage.attr("id").indexOf("write") > -1) {
		viewMode = "write";
	} else {
		viewMode = "view";
	}
	
	// 버튼 비활성화 여부 확인
	if(bDisabled) {
		$("#account_" + viewMode + "_btn_OK").hide();
	}
	else {
		$("#account_" + viewMode + "_btn_OK").show();
	}
	
	// 의견 입력 영역 토글 실행 여부 확인
	if(bToggle) {
		mobile_account_toggleCommentArea();
	}
}

//결재 시 의견 입력 영역 토글 실행
function mobile_account_toggleCommentArea() {
	mobile_approval_clickbtn($(".btn_toggle"), 'toggle');
}

// 의견 영역 내 확인 버튼 클릭 시
function mobile_account_doOK() {
	var fidoUse = false;
	mobile_comm_showload();
	
	setTimeout("mobile_account_doOK_exec()",300);
}

// 결재 진행
function mobile_account_doOK_exec() {
	// 생체인증 여부 확인
	var checkType = [];
	var pageObj;
	var viewMode;
	var l_ActiveID = $.mobile.activePage.attr("id");
	
	checkType = _mobile_fido_inputValue.split("||");
	
	if(l_ActiveID.indexOf("write") > -1) {
		pageObj = _mobile_account_write;
		viewMode = "write";
	} else {
		pageObj = _mobile_account_view;
		viewMode = "view";
	}

	// 중복 엔진 호출을 막기 위한 버튼 숨김 처리
	$("#account_" + viewMode + "_btn_OK").hide();

	// comment 팝업이 따로 없기 때문에 여기서 구현
	if (flgUsePWDCheck){
		if(checkType[0] == "FIDO") {	// 생체 인증 성공 시, input value FIDO||_||_ 체크) {
			mobile_fido_checkAuth(); // 생체인증 검증 (authKey, authToken)
		} else {
			if($("#account_" + viewMode + "_inputpassword").val()==""){	// 비밀번호를 입력하지 않은 경우
				alert(mobile_comm_getDic("msg_apv_enterApvPwd")); // msg : "결재 비밀번호를 입력해주세요."
				$("#account_" + viewMode + "_btn_OK").show();
				mobile_comm_hideload();	
				return false;
			}
			if(!mobile_approval_chkCommentWrite($("#account_" + viewMode + "_inputpassword").val())){	// 비밀번호를 잘못 입력한 경우
				alert(mobile_comm_getDic("msg_apv_wrongPwdReEnter")); // msg : "잘못된 비밀번호입니다. 다시 입력해주세요."
				$("#account_" + viewMode + "_btn_OK").show();
				mobile_comm_hideload();	
				return false;
			}
		}
	}
	
	if ((pageObj.ActionType == "reject"
			|| pageObj.ActionType == "abort"
			|| pageObj.ActionType == "hold"
			|| pageObj.ActionType == "rejectedto" || pageObj.ActionType == "rejectlast")
			&& $("textarea#account_" + viewMode + "_inputcomment").val() == "") {
		alert(mobile_comm_getDic("msg_apv_064"));
		mobile_comm_hideload();
		return;
	} else if (pageObj.ActionType == "hold" && !mobile_approval_checkRereserve()) {
		mobile_comm_hideload();
		return;
	} else {
		if (pageObj.ActionType == "rejectedto") {
			// setRJTApvList(); //TODO: 지정반려 일단 보류
		}

		var txtComment = Base64.utf8_to_b64($("textarea#account_" + viewMode + "_inputcomment").val());
		document.getElementById("ACTIONCOMMENT").value = txtComment;
		commentPopupReturnValue = true; //FormMenu 전역변수
	}
	
	//mobile_account_toggleCommentArea();
	
	var txtComment = Base64.utf8_to_b64($("textarea#account_" + viewMode + "_inputcomment").val());
	document.getElementById("ACTIONCOMMENT").value = txtComment;
	commentPopupReturnValue = true; //FormMenu 전역변수
	
	if(viewMode == "write") {
		if(pageObj.OpenMode == "DRAFT" || pageObj.OpenMode == "TEMPSAVE") {
			// 기안 시 의견은 결재선 내 직접 구성
			var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
			var eml = $$(jsonApv).find("steps>division[divisiontype='send']>step>ou>person>taskinfo[kind='charge']");
			var signImage = getUserSignInfo(mobile_comm_getSession("USERID"));
			/* 엔진에서 처리하도록 변경
			if (document.getElementById("ACTIONCOMMENT").value != "") {
				//결재선에 <comment> 추가 후 의견 저장
				var oComment = { "comment" : {"#text" : document.getElementById("ACTIONCOMMENT").value} } ;
				var oCommentNode = oComment.comment;
                if (eml.length > 0) {
                	var emlComment = $$(eml).find("comment");
                	if ($$(emlComment).length > 0) {
                		$$(emlComment).remove();
                	}
                	$$(eml).append("comment", oCommentNode);
                }
                   
                document.getElementById("APVLIST").value = JSON.stringify($$(jsonApv).concat().eq(0).json());
			}
			*/
			// 서명이미지 결재선 내 구성
			if(signImage != ""){
				$$(eml).attr("customattribute1", signImage);
				document.getElementById("APVLIST").value = JSON.stringify($$(jsonApv).concat().eq(0).json());
			}
			
			// 비용신청서 기안
			mobile_account_save('S');
		}
	}
	else {
		// 보류인 경우 결재선 변경
		if(pageObj.ActionType == "hold") {
			var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
			
			$$(jsonApv).find("step>ou").concat().find("taskinfo[result=pending]").concat().each(function(i, elm){
		    	if(mobile_comm_getSession("UR_Code") == $$(elm).parent().attr("code")){
		    		$$(elm).attr("result", "reserved");
		    		$$(elm).attr("status", "reserved");
		    		
		    		$$(elm).attr("comment", {"#text" : document.getElementById("ACTIONCOMMENT").value });
		    		
		    		$$(elm).find("comment").attr("relatedresult", "reserved");
		    	}
		    });
			
            document.getElementById("APVLIST").value = JSON.stringify($$(jsonApv).concat().eq(0).json());
		}
		
		// 수동결재 API 호출
		mobile_account_doApvAction(pageObj);
	}
}

// 수동결재 진행
function mobile_account_doApvAction(pPageObj) {
	var bUseTotalApv = false;
	var viewMode = "";
	var l_ActiveID = $.mobile.activePage.attr("id");
	
	if(pPageObj == undefined) {
		if(l_ActiveID.indexOf("write") > -1) {
			pPageObj = _mobile_account_write;
			viewMode = "write";
		} else {
			pPageObj = _mobile_account_view;
			viewMode = "view";
		}
	} else {
		if(l_ActiveID.indexOf("write") > -1) {
			viewMode = "write";
		} else {
			viewMode = "view";
		}
	} 

	
	if(pPageObj.IsTotalApv == "Y") {
		bUseTotalApv = true;
	}
	
	var approvalAction = "";
	var mode = pPageObj.Mode;
    var formInstID = pPageObj.FormInstID;
    var processID = pPageObj.ProcessID;
	var taskID = pPageObj.TaskID;
	var subkind = pPageObj.SubKind;
	var apiData = {};
	
	switch(pPageObj.ActionType){
		case "approved":
			if(mode == "PCONSULT") {
				approvalAction = "AGREE"; 
			}
			else {
				approvalAction = "APPROVAL"; 
			}
			break;
		case "reject":
			if(mode == "PCONSULT") {
				approvalAction = "DISAGREE"; 
			}
			else {
				approvalAction = "REJECT"; 
			}
			break;
		case "withdraw": approvalAction = "WITHDRAW"; break;
		case "abort": approvalAction = "ABORT"; break;
		case "hold": approvalAction = "RESERVE"; break;
		case "deptdraft": approvalAction = "REDRAFT"; break;
	}

	//기안 취소 / 회수 일 경우 현재 pending 인 결재자의 taskid 넘기기
    // 진행함에서 부서내반송 클릭하는 경우 => 재기안 회수 처리.
    if(approvalAction == "ABORT" || approvalAction == "WITHDRAW" || approvalAction == "APPROVECANCEL") {
    	var apvLineObj = $.parseJSON($("#APVLIST").val());
    	
    	var ou = $$(apvLineObj).find("division>step>ou").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0);
    	var unittype = $$(ou).parent().attr("unittype");
    	
    	if(unittype == "ou" && $$(ou).find("person").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0).length > 0)
    		taskID = $$(ou).find("person").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0).attr("taskid");
    	else
    		taskID = $$(ou).attr("taskid");
    }
    
	// 파라미터 구성
    $$(apiData).append("g_action_" + taskID, approvalAction);
    $$(apiData).append("g_actioncomment_" + taskID, $("#ACTIONCOMMENT").val());
    $$(apiData).append("g_actioncomment_attach_" + taskID, "[]"); //TODO: 추후 모바일 내 의견첨부 구현 시 변경 필요
    $$(apiData).append("g_signimage_" + taskID, getUserSignInfo(mobile_comm_getSession("USERID")));
    $$(apiData).append("g_isBatch_" + taskID, "N");
    $$(apiData).append("g_isMobile_" + taskID, "Y");
    $$(apiData).append("g_appvLine", $.parseJSON($("#APVLIST").val()));
    $$(apiData).append("isAccount", "Y");
    $$(apiData).append("g_authKey",_mobile_fido_authKey);
    $$(apiData).append("g_password", aesUtil.encrypt(proaas, proaaI, proaapp, $("#account_" + viewMode + "_inputpassword").val()));
    $$(apiData).append("formID", pPageObj.FormID);
    $$(apiData).append("logonId", mobile_comm_getSession("USERID"));
    $$(apiData).append("g_isModified", "false");
    
    $.ajax({
        url: "/approval/legacy/doActionForAccount.do",
	    type: "POST",
	    data: {
			"id" : taskID,
			"data" : JSON.stringify(apiData),
			"formInstID" : formInstID // 문서번호 update 위해 추가
		},
		dataType: "json",
	    success: function (res) {
	    	if(res.status == 'SUCCESS'){
	    		var sUrl;
	    		var sUrl_Module;	//리스트를 조회할 모듈
	    		var sListMode;		//문서함 Mode
				var jobBizCode = ""; // 담당업무,업무문서함 코드

	    		// 통합결재 여부에 따른 리스트 조회 처리
	    		if(bUseTotalApv) {
	    			sUrl_Module = "approval";
	    			sListMode = pPageObj.ListMode;						//문서함 타입
				}
				else {
					sUrl_Module = "account";
					sListMode = "ApprovalList_" + pPageObj.ListMode;	//비용결재함 구분
					jobBizCode = ((pPageObj.Gloct == "JOBFUNCTION" || pPageObj.Gloct == "BizDoc") && pPageObj.UserCode) ? pPageObj.UserCode : "";
				}
	    		
	    		sUrl = "/" + sUrl_Module + "/mobile/" + sUrl_Module + "/list.do?mode=" + sListMode + "&jobBizCode=" + jobBizCode;
	    		
	    		alert(mobile_comm_getDic("msg_apv_170"));
				mobile_comm_go(sUrl);
	    	} else if(res.status == 'FAIL'){
	    		alert(res.message);
	    		mobile_comm_hideload();
	    		$("#account_" + viewMode + "_btn_OK").show();
	    	}
	    },
	    error:function(response, status, error){
	    	mobile_comm_ajaxerror("/approval/legacy/doActionForAccount.do", response, status, error);
		}
	});
}

// 각 증빙 Validation Check
function mobile_account_checkValidation(idx, pReceiptID, pProofCode) {
	var retVal = "";
	var reqAmount = $("input[id='account_write_reqAmount_" + pReceiptID + "']").eq(idx).val().replace(/,/gi, '');
	
	if(isNaN(reqAmount) || Number(reqAmount) < 1) {
		retVal = mobile_comm_getDic("lbl_amtValidateErr"); //청구금액이 0이거나 올바른 금액이 아닙니다.
	}
	else if($("#account_write_expType" + pReceiptID).eq(idx).find("option:selected").val() == "") {
		retVal = mobile_comm_getDic("ACC_msg_inputStandardBrief"); //내역을 입력하세요.	
	} 
	else if($("#account_write_content_" + pReceiptID).eq(idx).val() == "") {
		retVal = mobile_comm_getDic("ACC_msg_inputComment"); //내역을 입력하세요.	
	}
	//TODO: 마감일 날짜 포맷이 안맞음. PC쪽이랑 이야기 해보고 진행 필요
	/*else if(mobile_account_chkDeadline($("#account_write_li_" + pReceiptID).find("p.tx_date").text().replace(/\./gi, ''))) {
		retVal = mobile_comm_getDic("ACC_msg_invalidDeadline"); //경비마감일이 유효하지 않습니다.
	}*/
	
	return retVal;
}

// 증빙 유효성 체크 및 증빙 데이터 구성 후 리턴
function mobile_account_getExpenceApplicationData(pSaveMode) {
	var saveType = pSaveMode;
	var IsTempSave = (pSaveMode == "S" ? "N" : "Y");
	var IsNew = (_mobile_account_write.OpenMode == "TEMPSAVE" ? "N" : "Y");
	var ApplicationStatus = pSaveMode;
	var evidList = [];
	var today = new Date();
	var proofTodayDate = '' + today.getFullYear() + mobile_account_addZero(today.getMonth()+1) + mobile_account_addZero(today.getDate());
	var proofTodayDateStr = today.getFullYear() + '.' + mobile_account_addZero(today.getMonth()+1) + '.' + mobile_account_addZero(today.getDate());
	var payDate = mobile_account_makePayDate(); // 지급일 옵션 선택에 따른 지급일 계산
	var saveObj;
	
	var chkValidation = "";
	
	$("#account_write_list").find("li").each(function(i, li){
		var receiptID = $(li).attr("id").replace("account_write_li_", "");
		var proofCode = $(li).find("#account_write_DetailInfo_" + receiptID).attr("proofCode");
		
		var tempList = {};
		var jsonObj = {};
		
		var divList = [];
		var divListData = {};

		var uploadFileList = [];
		var fileList = [];
		var fileListData = {};
		
		var docList = [];
		var docListData = {};
		
		var divAmountSum = 0;

		// 파라미터 구성
		jsonObj = JSON.parse(mobile_account_getUnescapeStr(decodeURIComponent($("#account_write_DetailInfo_" + receiptID).val())));

		// 비용분할 데이터
		$(li).find("div.nea_card_detail_bottom_wrap").each(function(j, div) {
			var expAppDivID = "";
			var divAmount = 0;
			
			// 증빙별 유효성 체크
			if(IsTempSave != "Y") {
				chkValidation = mobile_account_checkValidation(j, receiptID, proofCode);
			}
			
			if(chkValidation != "") {
				alert((i+1) + mobile_comm_getDic("ACC_msg_itemOf") + chkValidation);
				mobile_account_disableBtns(false, false);
				mobile_comm_hideload();
				return false;
			}
			
			if($(div).attr("id")) {
				expAppDivID = $(div).attr("id").replace("account_write_div_", "");
			}
			
			if($(div).find("#account_write_reqAmount_" + receiptID).val()) {
				divAmount = parseInt($(div).find("#account_write_reqAmount_" + receiptID).val().replace(/,/gi, ''));
			}
			
			divListData = {
				"ExpenceApplicationID": _mobile_account_write.ExpenceApplicationID,
				"ExpenceApplicationListID": mobile_account_nullToBlank(jsonObj.ExpenceApplicationListID),
				"ExpenceApplicationDivID": expAppDivID,
				"AccountCode": $(div).find("#account_write_expType_" + receiptID).find("option:selected").attr("AccountCode"),
				"AccountName": $(div).find("#account_write_expType_" + receiptID).find("option:selected").attr("AccountName"),
				"CostCenterCode": $("#account_write_costCenter_code").val(),
				"CostCenterName": $("#account_write_costCenter").val(),
				"IOCode": $("#account_write_IO_code").val(),
				"IOName": $("#account_write_IO").val(),
				"Amount": $(div).find("#account_write_reqAmount_" + receiptID).val().replace(/,/gi, ''),
				"UsageComment": $(div).find("#account_write_content_" + receiptID).val(),
				"StandardBriefID": $(div).find("#account_write_expType_" + receiptID).val(),
				"StandardBriefName": $(div).find("#account_write_expType_" + receiptID).find("option:selected").text(),
				"Rownum": j
			};
			
			divAmountSum += divAmount;
			
			divList.push(divListData);
		});
		
		// 증빙별 첨부파일
		$("#account_write_AttachInfo_" + receiptID).find("span[name='sAttachWrite_liFile']").each(function(j, file) {
			fileListData = {
					"FileName": $(file).data("filename"),
					"SavedName": $(file).data("savedname"),
					"Size": $(file).data("filesize"),
					"KeyNo": receiptID,
					"fileNum": j
					,"FrontAddPath": $(file).data("frontaddpath")
			};
			
			if(!$(file).data("fileid")) { // 신규 업로드 파일
				uploadFileList.push(fileListData);
			}
			else { // 기존 업로드된 파일
				fileListData["FileID"] = $(file).data("fileid");
				
				fileList.push(fileListData);
			}
		});
		
		// 증빙별 연결문서
		$("#account_write_DocLinkInfo_" + receiptID).find(".detail_doc > a[name='aDocLink']").each(function(j, docLink) {
			docListData = {
				"ProcessID": $(docLink).attr("processID"),
				//"FormPrefix": $(docLink).attr("formPrefix"),
				"Subject": $(docLink).attr("subject"),
				//"FormInstanceID": $(docLink).attr("formInstID"),
				"bstored": $(docLink).attr("bStored"),
				"BusinessData1": $(docLink).attr("businessData1"),
				"BusinessData2": $(docLink).attr("businessData2"),
				"KeyNo": receiptID,
				"docNum": j
			};
			
			docList.push(docListData);
		});
		
		// 증빙 마스터 데이터
		if(proofCode.toLowerCase() == "corpcard") {
			// 법인카드
			tempList = {
					"ExpenceApplicationListID": mobile_account_nullToBlank(jsonObj.ExpenceApplicationListID),
					"divList": divList,
					"ProofCode": proofCode,
					"ProofDate": ((jsonObj.ProofDate != "" && jsonObj.ProofDate != undefined) ? jsonObj.ProofDate : proofTodayDate),
					"ReceiptID": receiptID,
					"PostingDate": ((jsonObj.ProofDate != "" && jsonObj.ProofDate != undefined) ? jsonObj.ProofDate : proofTodayDate),
					"TaxType": $("#account_write_expType_" + receiptID).eq(0).find("option:selected").attr("TaxType"),
					"TaxCode": $("#account_write_expType_" + receiptID).eq(0).find("option:selected").attr("TaxCode"),
					"StoreNo": jsonObj.StoreNo,
					"StoreName": jsonObj.StoreName,
					"StoreAddress": jsonObj.StoreAddress,
					"StoreTel": jsonObj.StoreTel,
					"ItemNo": jsonObj.ItemNo,
					"CardNo": jsonObj.CardNo,
					"CardUID": jsonObj.CardUID,
					"RepAmount": jsonObj.RepAmount,
					"TaxAmount": jsonObj.TaxAmount,
					"TotalAmount": jsonObj.TotalAmount,
					"IOName": $("#account_write_IO").val(),
					"Amount": $("#account_write_reqAmount_" + receiptID).val().replace(/,/gi, ''),
					"StandardBriefID": $("#account_write_expType_" + receiptID).eq(0).val(),
					"StandardBriefName": $("#account_write_expType_" + receiptID ).eq(0).find("option:selected").text(),
					"AccountCode": $("#account_write_expType_" + receiptID).eq(0).find("option:selected").attr("AccountCode"),
					"AccountName": $("#account_write_expType_" + receiptID ).eq(0).find("option:selected").attr("AccountName"),
					"UsageComment": $("#account_write_content_" + receiptID).eq(0).val(),
					"RealPayDate": payDate.replace(/-/gi, ''),
					"PayDate": payDate.replace(/-/gi, ''),
					"divSum": divAmountSum,
					"RealPayAmount": divAmountSum,
					"uploadFileList": uploadFileList,
					"fileList": fileList,
					"docList": docList
				};
		}
		else {
			// 모바일 영수증
			tempList = {
					"ExpenceApplicationListID": mobile_account_nullToBlank(jsonObj.ExpenceApplicationListID),
					"divList": divList,
					"ProofCode": proofCode,
					"ProofDate": $("#account_write_useDate_" + receiptID).text().replace(/\./gi, ''),
					"ReceiptID": receiptID,
					"PostingDate": $("#account_write_useDate_" + receiptID).text().replace(/\./gi, ''),
					"TaxType": $("#account_write_expType_" + receiptID).eq(0).find("option:selected").attr("TaxType"),
					"TaxCode": $("#account_write_expType_" + receiptID).eq(0).find("option:selected").attr("TaxCode"),
					"VendorNo": ($("#account_write_vendor_no_" + receiptID).val() == "" ? mobile_comm_getSession("UR_Code") : $("#account_write_vendor_no_" + receiptID).val()),
					"RepAmount": jsonObj.RepAmount,
					"TaxAmount": jsonObj.TaxAmount,
					"TotalAmount": $("#account_write_useAmount_" + receiptID).text().replace(/,/gi, ''),
					"IOName": $("#account_write_IO").val(),
					"Amount": $("#account_write_reqAmount_" + receiptID).eq(0).val().replace(/,/gi, ''),
					"StandardBriefID": $("#account_write_expType_" + receiptID).eq(0).val(),
					"StandardBriefName": $("#account_write_expType_" + receiptID).eq(0).find("option:selected").text(),
					"AccountCode": $("#account_write_expType_" + receiptID).eq(0).find("option:selected").attr("AccountCode"),
					"AccountName": $("#account_write_expType_" + receiptID).eq(0).find("option:selected").attr("AccountName"),
					"UsageComment": $("#account_write_content_" + receiptID).eq(0).val(),
					"RealPayDate": payDate.replace(/-/gi, ''),
					"PayDate": payDate.replace(/-/gi, ''),
					"divSum": divAmountSum,
					"RealPayAmount": divAmountSum,
					"uploadFileList": uploadFileList,
					"fileList": fileList,
					"docList": docList
				};
		}
		
		evidList.push(tempList);
	});
	
	if(chkValidation != "") return false;

	var saveObj = {
			"ExpenceApplicationID": _mobile_account_write.ExpenceApplicationID,
			"isSearched": "N",
			"isNew": IsNew,
			"CostCenterCode": $("#account_write_costCenter_code").val(),
			"CostCenterName": $("#account_write_costCenter").val(),
			"IOCode": $("#account_write_IO_code").val(),
			"IOName": $("#account_write_IO").val(),
			"pageExpenceAppEvidList": evidList,
			"pageExpenceAppEvidDeletedList": _mobile_account_write.ExpenceAppEvidDeletedList,
			"saveType": saveType,
			"IsTempSave": IsTempSave,
			"CompanyCode": _mobile_account_write.CompanyCode,
			"ApplicationTitle": $("#account_write_subject").val(),
			"ApplicationType": _mobile_account_write.ApplicationType,
			"ApplicationStatus": ApplicationStatus,
			"RequestType": _mobile_account_write.RequestType,
			"ChargeJob": $("#account_write_chargeJob").val(),
			"ApprovalLine": JSON.stringify(mobile_account_getApvList("TEMPSAVE")),
			"FormName": _mobile_account_write.ExpenceFormInfo.FormName,
			"PayDateType": $("#account_write_payDateType").find("option:selected").val()
	};
	
	/*
	pageInfo.ApprovalLine = getApvList($("#APVLIST").val(), "TEMPSAVE");
	pageInfo.FormName = accComm[requestType].pageExpenceFormInfo.FormName;
	*/
	
	return saveObj;
}

function mobile_account_getApvList(reqMode) {
	var jsonApv = $.parseJSON($("#APVLIST").val());
	
    //결재선 임시 저장 관련 수정 - 기안자만 있는 경우 결재선을 넘기지 않는다.
    // 회수 및 기안취소 포함
    if (reqMode == "TEMPSAVE" || reqMode == "WITHDRAW" || reqMode == "ABORT") {
        var oFirstNodeList = $$(jsonApv).find("steps>division>step>ou>person");
        //기안자만 있는 경우 초기화  시키는데, 그럴경우 추가된 참조자도 사라짐.*/
        var oCurrentDivNode = $$(jsonApv).find("steps>division[divisiontype='send']");
        var oChargeNode = $$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']");
        
        if (oChargeNode.length != 0)
        	$$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']").concat().eq(0).remove();
        
        var oCurrentDivTaskinfo = $$(oCurrentDivNode).find("taskinfo");
        $$(oCurrentDivTaskinfo).attr("status", "inactive");
        $$(oCurrentDivTaskinfo).attr("result", "inactive");
        
        try { $$(oCurrentDivTaskinfo).remove("datereceived"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("datecompleted"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("customattribute1"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("wiid"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("mobileType"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivNode).find("step").concat().find("person").concat().find("taskinfo>comment").remove(); } catch (e) { coviCmn.traceLog(e); }
        
        $$(oCurrentDivNode).find("step").concat().each(function(i, elm){
        	if ($$(elm).attr("unittype") == "ou") {
                var oOU = $$(elm).find("ou");
                $$(oOU).concat().each(function (i, ouNode) {
                    $$(ouNode).children().remove();
                	
                    var newOuTaskinfo = {};
                    
                    if ($$(elm).attr("routetype") == "consult") { $$(newOuTaskinfo).attr("kind", "consult"); }
                    else if ($$(elm).attr("routetype") == "assist") { $$(newOuTaskinfo).attr("kind", "assist"); }
                    else { $$(newOuTaskinfo).attr("kind", "normal"); }

                    $$(ouNode).append("taskinfo", newOuTaskinfo);
                });
                $$(elm).find("taskinfo").remove("datereceived");
            }
        	
        	var oOU = $$(elm).find("ou").concat();
        	
        	$$(oOU).concat().each(function(i, ouObj){
	        	// 엔진에서 작성되는 값들 지우기
		        $$(ouObj).remove("pfid");
		        $$(ouObj).remove("taskid");
		        $$(ouObj).remove("widescid");
		        $$(ouObj).remove("wiid");
		
		        //division/step/ou/taskinfo
		        var oOUTaskinfo = $$(ouObj).find("taskinfo");
		        if ($$(oOUTaskinfo).length != 0) {
		            $$(oOUTaskinfo).attr("status", "inactive");
		            $$(oOUTaskinfo).attr("result", "inactive");
		            $(oOUTaskinfo).attr("datereceived", "");
		
		            if ($$(oOUTaskinfo).attr("datecompleted")) { $$(oOUTaskinfo).remove("datecompleted"); }
		            if ($$(oOUTaskinfo).attr("wiid")) { $$(oOUTaskinfo).remove("wiid"); }
		
		            if ($$(oOUTaskinfo).find("comment").concat().eq(0)) { $$(oOUTaskinfo).find("comment").remove(); }
		            if ($$(oOUTaskinfo).find("comment_fileinfo").concat().eq(0)) { $$(oOUTaskinfo).find("comment_fileinfo").remove(); }
		            
		            $$(oOUTaskinfo).remove("datereceived");
		        }
		        //division/step/person/taskinfo
		        var oPersonTaskinfo = $$(ouObj).find("person>taskinfo");
		        if ($$(oPersonTaskinfo).length != 0) {
		            $$(oPersonTaskinfo).attr("status", "inactive");
		            $$(oPersonTaskinfo).attr("result", "inactive");
		            if ($$(oPersonTaskinfo).attr("kind") == "charge") $$(oPersonTaskinfo).attr("datereceived", getInfo("AppInfo.svdt"));
		            else $$(oPersonTaskinfo).attr("datereceived", "");
		            
		            if ($$(oPersonTaskinfo).attr("datecompleted")) { $$(oPersonTaskinfo).remove("datecompleted"); }
		            if ($$(oPersonTaskinfo).attr("wiid")) { $$(oPersonTaskinfo).remove("wiid"); }
		            if ($$(oPersonTaskinfo).attr("customattribute1")) { $$(oPersonTaskinfo).remove("customattribute1"); }
		            if ($$(oPersonTaskinfo).attr("mobileType")) { $$(oPersonTaskinfo).remove("mobileType"); }
		
		            if ($$(oPersonTaskinfo).find("comment").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment").remove(); }
		            if ($$(oPersonTaskinfo).find("comment_fileinfo").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment_fileinfo").remove(); }
		        }
        	});
        });
        
        //참조 셋팅
        var oCcinfo = $$(jsonApv).find("steps>ccinfo");
        try {
        	if(oCcinfo.exist()){
	            $$(oCcinfo).concat().each(function (i, elm) {
	                $$(elm).attr("datereceived", "");
	            });
        	}
        } catch (e) { coviCmn.traceLog(e); }
    }
    return jsonApv;
}

// 지급일 옵션에 따른 실제 지급일자 계산
function mobile_account_makePayDate() {
	var selectedVal = $("#account_write_payDateType").find("option:selected").val();
	var retVal = "";
	
	if(selectedVal == "E") { //기타
		retVal = $("#account_write_payDate").val();
	} else {
		var date = new Date();
		
		if(selectedVal == "M") { //15일
			var day = date.getDate();
			date.setDate(15);
			
			if(day > 15) { //15일 이후에 저장된 내역은 다음달로
				date.setMonth(date.getMonth()+1);
			}				
		}
		else if(selectedVal == "L") { //말일
			var lastDate = new Date(date.getYear(), date.getMonth()+1, 0);					
			date.setDate(lastDate.getDate());		
		} else {
			var etcPayDate = parseInt(selectedVal); 
			if(!isNaN(etcPayDate)){
				var day = date.getDate();
				date.setDate(selectedVal);
				
				if(day > etcPayDate) { //지정일 이후에 저장된 내역은 다음달로
					date.setMonth(date.getMonth()+1);
				}
			}
		}
		
		retVal = mobile_comm_getDateTimeString("yyyyMMdd", date);
	}
	
	return retVal;
}

// 비용신청 저장(T: 임시저장, S: 신청)
function mobile_account_save(pSaveMode) {
	var IsTempSave = (pSaveMode == "S" ? "N" : "Y");
	var saveObj;
	
	// 파라미터 구성
	saveObj = mobile_account_getExpenceApplicationData(pSaveMode);
	
	if(!saveObj) {
		return false;
	}

	mobile_comm_showload();
	
	// 비용신청 저장
	$.ajax({
		type:"POST",
			url:"/account/mobile/account/saveExpenceApplication.do",
		data:{
			saveObj : JSON.stringify(saveObj),
		},
		async:false,
		success:function (data) {
			if(data.result == "ok"){
				window.sessionStorage.removeItem('account_writeinit');
				
				if(IsTempSave == "N") {
					// 임시저장이 아닌 경우 자동상신 진행
					mobile_account_searchData(data.data.getSavedKey); //getSavedKey == ExpenceApplicationID
				}
				else {					
					var sUrl = "/account/mobile/account/list.do";
					
					alert(mobile_comm_getDic("ACC_msg_saveComp"));

					mobile_comm_go(sUrl);
				}
			}
			else if(data.result == "D"){				
				var duplObj = data.duplObj;
				var msg = mobile_comm_getDic("ACC_msg_isExpAppDupl");
				
				if(duplObj.CCCnt>0){
					msg = msg + "<br>" + mobile_comm_getDic("ACC_lbl_CardApproNo");
					msg = msg + " : " + duplObj.CCList
				}
				
				alert(mobile_comm_getDic("ACC_msg_isExpAppDupl"));
				mobile_comm_hideload();
			}
			else{
				alert(data.message);
				mobile_comm_hideload();
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/account/mobile/account/saveExpenceApplication.do", response, status, error);
		}
	});
}

function mobile_account_htmlFormSetVal(inputStr, replaceMap) {
	var noInfiniteLoofVal = 0;
	while (true) {
		var stIdx = inputStr.indexOf("@@{");
		var edIdx = inputStr.indexOf("}", stIdx+1);
		
		if(stIdx != -1
			&& edIdx != -1){
			var getWord = inputStr.substr(stIdx, edIdx-stIdx+1);
			var getKeyWord = inputStr.substr(stIdx+3, edIdx-stIdx-3);
			var transWord = replaceMap[getKeyWord];
			inputStr = inputStr.replace(new RegExp(getWord, 'gi'), mobile_account_nullToBlank(transWord));
		}
		else{
			break;
		}
		noInfiniteLoofVal ++;
		if(noInfiniteLoofVal>9999){
			break;
		}
	}
	return inputStr;
}

function mobile_account_htmlFormDicTrans(inputStr) {
	if(inputStr == null){
		return;
	}
	var noInfiniteLoofVal = 0;
	while (true) {
		var stIdx = inputStr.indexOf("**{");
		var edIdx = inputStr.indexOf("}", stIdx+1);
		
		if(stIdx != -1
			&& edIdx != -1){
			var getWord = inputStr.substr(stIdx, edIdx-stIdx+1);
			var getKeyWord = inputStr.substr(stIdx+3, edIdx-stIdx-3);
			var transWord = mobile_comm_getDic(getKeyWord);
			inputStr = inputStr.replace(getWord, transWord);
		}
		else{
			break;
		}
		noInfiniteLoofVal ++;
		if(noInfiniteLoofVal>9999){
			break;
		}
	}
	return inputStr;
}

// 비용증빙 목록 조회
function mobile_account_searchData(expAppID) {
	$.ajax({
		type:"POST",
		url:"/account/mobile/account/searchExpenceApplication.do",
		data:{
			ExpenceApplicationID : expAppID
		},
		success:function (data) {
			if(data.result == "ok"){
				mobile_account_autoDraft(data.data, expAppID);
			}
			else{
				alert(data);
				mobile_comm_hideload();
			}
		},
		error:function (error){
			alert(mobile_comm_getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
			mobile_comm_hideload();
		}
	});
}

function mobile_account_makeViewForm(expObj, expAppId) {
	var divValMap = {};
	var valMap = {};
	var today = new Date();
	var proofTodayDateStr = today.getFullYear() + '.' + mobile_account_addZero(today.getMonth()+1) + '.' + mobile_account_addZero(today.getDate());
	
	var amountAreaHtml = '';
	amountAreaHtml += '<div class="total_acooungting_wrap" id="comCostApp_TotalWrap" style="margin-top: 20px;">';
	amountAreaHtml += '	<table class="total_table">';
	amountAreaHtml += '		<thead>';
	amountAreaHtml += '			<tr>';
	amountAreaHtml += '				<th>' + mobile_comm_getDic("lbl_eviTotalAmt") + '</th>';
	amountAreaHtml += '				<th>' + mobile_comm_getDic("ACC_billReqAmt") + '</th>';
	amountAreaHtml += '			</tr>';
	amountAreaHtml += '		</thead>';
	amountAreaHtml += '		<tbody>';
	amountAreaHtml += '			<tr>';
	amountAreaHtml += '				<td><span class="tx_ta">' + $("#account_write_TotalAmount").text() + '</span>' + mobile_comm_getDic("ACC_lbl_won") + '</td>';
	amountAreaHtml += '				<td><span class="tx_ta">' + $("#account_write_ReqAmount").text() + '</span>' + mobile_comm_getDic("ACC_lbl_won") + '</td>';
	amountAreaHtml += '			</tr>';
	amountAreaHtml += '		</tbody>';
	amountAreaHtml += '	</table>';
	amountAreaHtml += '</div>';
	
	$("div[name=mobileApp_hiddenViewForm]").append(amountAreaHtml);
	
	for(var i = 0; i < expObj.pageExpenceAppEvidList.length; i++) {
		var htmlDivFormStr = divForm;
		var formStr = viewForm;
		var getItem = expObj.pageExpenceAppEvidList[i];
		
		for(var j = 0; j < getItem.divList.length; j++) {
			var divItem = getItem.divList[j];
			divValMap = {
					DivAmount : mobile_account_toAmtFormat(divItem.Amount),
					AccountName : mobile_account_nullToBlank(divItem.AccountName),
					CostCenterName : mobile_account_nullToBlank(divItem.CostCenterName),
					StandardBriefName : mobile_account_nullToBlank(divItem.StandardBriefName),
					IOName : mobile_account_nullToBlank(divItem.IOName),
					VendorName : mobile_account_nullToBlank(getItem.VendorName),
					UsageComment : mobile_account_nullToBlank(divItem.UsageComment),
					OneLine : "class='one_line'"
			}
			htmlDivFormStr = mobile_account_htmlFormSetVal(htmlDivFormStr, divValMap);
		}
		
		valMap = {
				ViewKeyNo : mobile_account_nullToBlank(i),
				ProofCode : mobile_account_nullToBlank(getItem.ProofCode),
				TotalAmount : mobile_account_toAmtFormat(mobile_account_nullToBlank(getItem.TotalAmount)),
				ProofDate : mobile_account_nullToBlank(getItem.ProofDateStr),
				PayDate : mobile_account_nullToBlank(getItem.PayDateStr),
				PostingDate : mobile_account_nullToBlank(getItem.PostingDateStr),
				StoreName : mobile_account_nullToBlank(getItem.StoreName),
				CardUID : mobile_account_nullToBlank(getItem.CardUID),
				CardApproveNo : mobile_account_nullToBlank(getItem.CardApproveNo),
				ReceiptID : mobile_account_nullToBlank(getItem.ReceiptID),
				TaxCodeNm : mobile_account_nullToBlank(getItem.TaxCodeName),
				TaxTypeNm : mobile_account_nullToBlank(getItem.TaxTypeName),
				
				RepAmount : mobile_account_toAmtFormat(mobile_account_nullToBlank(getItem.RepAmount)),
				TaxAmount : mobile_account_toAmtFormat(mobile_account_nullToBlank(getItem.TaxAmount)),
				
				VendorNo : mobile_account_nullToBlank(getItem.VendorNo),
				VendorName : mobile_account_nullToBlank(getItem.VendorName),
				PersonalCardNo : mobile_account_nullToBlank(getItem.PersonalCardNo),
				PersonalCardNoView : mobile_account_nullToBlank(getItem.PersonalCardNoView),
				SupplyCost : mobile_account_nullToBlank(getItem.SupplyCost),
				Tax : mobile_account_nullToBlank(getItem.Tax),
				
				pageNm : "SimpleApplication"+requestType,
				divApvArea  : htmlDivFormStr,
				MobileAppClick : "simpApp_MobileAppClick",
				FileID : mobile_account_nullToBlank(getItem.FileID)
		}

		var getForm = mobile_account_htmlFormSetVal(formStr, valMap);
		getForm = mobile_account_htmlFormDicTrans(getForm);

		$("div[name=mobileApp_hiddenViewForm]").append(getForm);
	}
	$("div[name=noViewArea]").remove();
	$("[name=accArea]").html(mobile_comm_getDic("ACC_expType"));
	
	mobile_account_autoDraft(expObj, expAppId);
}

// 기간계 자동상신 웹서비스를 사용한 기안
function mobile_account_autoDraft(expObj, expAppId) {
	var sKey = expAppId;
	var sSubject = expObj.ApplicationTitle;
	var sLogonId = mobile_comm_getSession("USERID");
	var sDeptId = mobile_comm_getSession("DEPTID");
	var sLegacyFormID = _mobile_account_write.ExpenceFormInfo.ApprovalFormInfo;
	var sDataType = "JSON"; //HTML, JSON, ALL
	var now = new Date();
	
	now = now.getFullYear() + '-' + mobile_account_addZero(now.getMonth() + 1) + '-' + mobile_account_addZero(now.getDate()) + " " 
			+ mobile_account_addZero(now.getHours()) + ":" + mobile_account_addZero(now.getMinutes()) + ":" + mobile_account_addZero(now.getSeconds());
	
	var sBodyContext = {
		LegacyFormID : sLegacyFormID,
		ERPKey : sKey,
		//HTMLBody : mobile_account_getHTMLBody(),
		JSONBody : expObj,
		InitiatedDate : now,
		InitiatorCodeDisplay : mobile_comm_getSession("UR_Code"),
		InitiatorDisplay : mobile_comm_getSession("UR_Name"),
		InitiatorOUDisplay : mobile_comm_getSession("GR_Name")
	};
	
	// 양식별/담당업무함별 전결규정 조회
	//var nRuleItemID = mobile_account_getRuleItem();
	//var apvLine = mobile_account_getApvLine(sLegacyFormID, nRuleItemID);	

	var formData = new FormData();
	formData.append("key", sKey);
	formData.append("subject", sSubject);
	formData.append("logonId", sLogonId);
	formData.append("deptId", sDeptId);
	formData.append("legacyFormID", sLegacyFormID);
	formData.append("apvline", $("#APVLIST").val());
	formData.append("bodyContext", JSON.stringify(sBodyContext));
	formData.append("scChgrValue", expObj.ChargeJob);
	formData.append("attachFile[]", null);
	formData.append("actionComment", $("#ACTIONCOMMENT").val()); // 의견
	formData.append("signImage", getUserSignInfo(sLogonId));
	formData.append("g_authKey",_mobile_fido_authKey);
	formData.append("g_password", aesUtil.encrypt(proaas, proaaI, proaapp, $("#account_write_inputpassword").val()) );
	formData.append("formID", _mobile_account_write.ExpenceFormInfo.FormID);

	$.ajax({
		type:"POST",
		url:"/approval/legacy/draftForAccount.do",
		data:formData,
		contentType: false,
		processData: false,
		async:false,
		success:function (data) {
			var sUrl = "/account/mobile/account/list.do";
			
			if(data.status == "SUCCESS") {
				alert(mobile_comm_getDic("ACC_msg_draftComplete"));
				mobile_comm_go(sUrl);
			} else {
				alert(data.message);
				mobile_comm_hideload();
				mobile_account_disableBtns(false, false);
			}
		},
		error:function (error){
			mobile_comm_hideload();
			mobile_account_disableBtns(false, false);
			alert(error.message);
		}
	});
}

// 담당업무함에 해당하는 전결규정 조회
function mobile_account_getRuleItem() {
	var chargeJob = $("#account_write_chargeJob").val().replace("JF_ACCOUNT_","");
	var ruleItemId = 0;
	
	$.ajax({
		type:"POST",
		url:"/account/baseCode/getCodeListByCodeGroup.do",
		async:false,
		data:{
			codeGroup : 'ApvRule'
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				if(data.list.length > 0) {
					$(data.list).each(function(i, obj){
						if(obj.IsUse == "Y" && obj.IsGroup == "N") {
							if(obj.Code.split('_')[0] == chargeJob) {
								ruleItemId = obj.Code.split('_')[1];
								return false;
							}
						}
					});
				}
			}
		},
		error:function (error){
			alert(error.message);
		}
	});
	
	return ruleItemId;
}

// 전결규정에 해당하는 결재선 조회
function mobile_account_getApvLine(pLegacyFormID, pRuleItemID) {
	var apvLine = "";
	
	$.ajax({
		type:"POST",
		url:"/approval/legacy/getRuleApvLine.do",
		async:false,
		data:{
			legacyFormID : pLegacyFormID,
			ruleItemID : pRuleItemID
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				apvLine = data.result;
			}
		},
		error:function (error){
			alert(error.message);
		}
	});
	
	return apvLine;
}

function mobile_account_getHTMLBody() {	
    // 버튼 삭제, 체크박스 삭제
    $("div[name=mobileApp_hiddenViewForm] .acstatus_wrap").each(function(){ 
    	$(this).find("input[type=checkbox]").parent().parent().remove();
    });
    $("[name=noViewArea]").remove();
    
	return $("div[name=mobileApp_hiddenViewForm]").html();
}

// 증빙 삭제
function mobile_account_deleteExpence() {
	var arrDel = [];
	
	$("input[type=checkbox][id^=account_write_chk_]:checked").each(function(i, obj){
		if(_mobile_account_write.OpenMode != "DRAFT") {
			var delEvid = {};
			var jsonObj = {};

			jsonObj = JSON.parse(decodeURIComponent($("#account_write_DetailInfo_" + $(obj).val()).val()));
			
			delEvid = {
				"ExpenceApplicationID": _mobile_account_write.ExpenceApplicationID,
				"ExpenceApplicationListID": jsonObj.ExpenceApplicationListID
			};
			
			
			_mobile_account_write.ExpenceAppEvidDeletedList.push(delEvid);
		}
		
		$("#account_write_list").find("#account_write_li_" + $(obj).val()).remove();
		arrDel.push($(obj).val());
	});
	
	_mobile_account_write.CardReceiptID = mobile_account_getReceiptIDAfterDel(_mobile_account_write.CardReceiptID, arrDel);
	_mobile_account_write.MobileReceiptID = mobile_account_getReceiptIDAfterDel(_mobile_account_write.MobileReceiptID, arrDel);
	
	mobile_account_setAmount();
}

// 증빙별 첨부파일 삭제
function mobile_account_deleteEvidenceFile(pObj) {
	if(_mobile_account_write.OpenMode != "DRAFT") {
		var delFile = {};
		var jsonObj = {};

		jsonObj = JSON.parse(decodeURIComponent($("#account_write_DetailInfo_" + $(pObj).data("controlid")).val()));
		
		delFile = {
			"ExpenceApplicationListID": jsonObj.ExpenceApplicationListID,
			"FileID": $(pObj).data("fileid")
		};
		
		_mobile_account_write.ExpenceAppEvidDeletedFile.push(delFile);
	}
}

// 삭제된 증빙 데이터 정보 삭제
function mobile_account_getReceiptIDAfterDel(pReceiptIDs, pDelArr) {
	var retValue = "";
	var tempReceiptID = pReceiptIDs.split(',');
	
	for(var i = 0; i < pDelArr.length; i++) {
		var index = tempReceiptID.indexOf(pDelArr[i]);
		
		if(index > -1) {
			tempReceiptID.splice(index, 1);
		}
	}
	
	for(var j = 0; j < tempReceiptID.length; j++) {
		retValue += tempReceiptID[j];
		
		if(tempReceiptID.length - 1 > j) {
			retValue += ",";
		}
	}
	
	return retValue;
}

// 코스트센터 상세정보 가져오기 (현재 사용 안함)
function mobile_account_getCostCenterDetail(pCostCenterID) {
	$.ajax({
		type:"POST",
		data:{
			costCenterID: pCostCenterID
		},
		url:"/account/mobile/account/getCostCenterDetail.do",
		success:function (data) {
			if(data.status == "SUCCESS") {
				if(data.list.length > 0) {
					var obj = data.list[0];
					var divHtml = "";
					divHtml += "<dl class='card_info'><dt style='width: 50px;'>" + mobile_comm_getDic("lbl_Period") + "</dt><dd>" + obj.UsePeriodStart + " ~ " + obj.UsePeriodFinish + "</dd></dl>";
					divHtml += "<dl class='card_info'><dt style='width: 50px;'>" + mobile_comm_getDic("lbl_explanation") + "</dt><dd>" + obj.Description + "</dd></dl>";
					$("#account_write_cc_p").text("[" + obj.CostCenterCode + "] " + obj.CostCenterName);
					$("#account_write_cc_div").html(divHtml);
				}
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/account/mobile/account/getCostCenterDetail.do", response, status, error);
		}
	});
}

// 사용자 코스트센터 코드 가져오기
function mobile_account_getUserCC() {
	$.ajax({
		type:"POST",
		data:{},
		url:"/account/mobile/account/getUserCC.do",
		success:function (data) {
			if(data.status == "SUCCESS") {
				var oCCInfo = data.CCInfo;
				
				if(oCCInfo != undefined) {
					$("#account_write_costCenter_code").val(data.CCInfo.CostCenterCode);
					$("#account_write_costCenter").val(data.CCInfo.CostCenterName);
					
					// 코스트센터 상세정보 조회(미사용)
					/*if(_mobile_account_write.CostCenterCode != "") {
						mobile_account_getCostCenterDetail(data.CCInfo.CostCenterID);
					}*/
				}
				
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/account/mobile/account/getUserCC.do", response, status, error);
		}
	});
	
}

// 마감일자 체크
function mobile_account_chkDeadline(inputDateStr) {
	var inputDate = new Date(inputDateStr);
	var retVal = false;
	retVal = (_mobile_account_write.DeadlineSDate >= inputDate) && (_mobile_account_write.DeadlineEDate <= inputDate);
	
	return retVal;
}

// 팝업 검색 영역 텍스트 초기화
function mobile_account_cleansearch(search_input_id) {
	$("#" + search_input_id).val("");
}

// 팝업 닫기
function mobile_account_popupClose(type) {
	switch(type) {
	case "Vendor":
		_mobile_account_vendor.SearchText = "";
		_mobile_account_vendor.Page = 1;
		_mobile_account_vendor.EndOfList = false;
		break;
	case "PRCard":
		_mobile_account_prcard.Page = 1;
		_mobile_account_prcard.EndOfList = false;
		break;
	case "CostCenter":
		_mobile_account_costcenter.SearchText = "";
		_mobile_account_costcenter.Page = 1;
		_mobile_account_costcenter.EndOfList = false;
		break;
	case "IO":
		_mobile_account_io.SearchText = "";
		_mobile_account_io.Page = 1;
		_mobile_account_io.EndOfList = false;
		break;
	}
	
	$('.ui-dialog').dialog('close');
}

/* 
 * 
 * 거래처 선택 페이지 시작
 * 
 */

var _mobile_account_vendor = {
	ReceiptID : '',
	SearchText : '',
	
	// 리스트 조회 초기 데이터
	Page: 1,			//조회할 페이지
	PageSize: 10,		//페이지당 건수
	
	// 페이징을 위한 데이터
	TotalCount: -1,		//전체 건수
	EndOfList: false,	//전체 리스트를 다 보여줬는지
};

// 거래처 목록 초기화
function mobile_account_VendorInit() {
	if (window.sessionStorage["vendor_receipt_id"] != undefined) {
		_mobile_account_vendor.ReceiptID = window.sessionStorage["vendor_receipt_id"];
    } else {
    	_mobile_account_vendor.ReceiptID = '';
    }
	
	mobile_account_getVendor();
	
	$("a[role=button]").eq(0).remove();
}

// 거래처 목록 가져오기
function mobile_account_getVendor() {
	var sHtml = "";
	
	$.ajax({
		type:"POST",
		data:{
			searchText: _mobile_account_vendor.SearchText,
			pageNo: _mobile_account_vendor.Page
		},
		url:"/account/mobile/account/getVendorPopupList.do",
		success:function (data) {
			if(data.status == "SUCCESS") {
				_mobile_account_vendor.TotalCount = data.page.listCount;
				
				if(data.list.length > 0) {
					var tempNum = (_mobile_account_vendor.Page - 1) * _mobile_account_vendor.PageSize;
					$(data.list).each(function(i, obj) {
						sHtml += "<li id='account_vendor_li" + obj.VendorID + "'>";
						sHtml += "	<div class='receipt_chk'>"; //TODO: vendor_rdo class 새로 생성 필요
						sHtml += "		<input type='radio' name='account_vendor_rdo' value='" + obj.VendorNo + "@@" + obj.VendorName + "' id='account_vendor_rdo_" + (tempNum + i) + "'><label for='account_vendor_rdo_" + (tempNum + i) + "'></label>";
						sHtml += "	</div>";
						sHtml += "	<div class='receipt_con'>";
						sHtml += "		<p class='tx_name ellip'><span class='cate' style='border: 1px solid #c7c7c7; color: #222;'>" + obj.VendorTypeName + "</span>" + obj.VendorName + "(" + obj.VendorNo + ")</p>";
						sHtml += "		<p class='tx_sub'><span class='tx_sub_txt'>" + mobile_comm_getDic("ACC_lbl_CorporateNumber") + " : " + (obj.CorporateNo == undefined ? '' : obj.CorporateNo) + "</span><span class='tx_sub_txt'>" + mobile_comm_getDic("ACC_lbl_PayType") + " : " + (obj.PaymentConditionName == undefined ? '' : obj.PaymentConditionName) + "</span></p>";
						sHtml += "	</div>";
						sHtml += "</li>";
					});
					
					if(_mobile_account_vendor.Page == 1 || sHtml.indexOf("no_list") > -1) {
						$('#account_vendor_list').html(sHtml).trigger("create");
					} else {
						$('#account_vendor_list').append(sHtml).trigger("create");
					}
					
					if (Math.min((_mobile_account_vendor.Page) * _mobile_account_vendor.PageSize, _mobile_account_vendor.TotalCount) == _mobile_account_vendor.TotalCount) {
						_mobile_account_vendor.EndOfList = true;
		                $('#account_vendor_more').hide();
		            } else {
		                $('#account_vendor_more').show();
		            }
				}
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/account/mobile/account/getVendorPopupList.do", response, status, error);
		}
	});
}

// 거래처 선택 후 비용신청 페이지 내 거래처 input box에 바인딩
function mobile_account_selectVendor() {
	var vendorNo = $("#account_vendor_list").find("input[type=radio][name=account_vendor_rdo]:checked").val().split("@@")[0];
	var vendorName = $("#account_vendor_list").find("input[type=radio][name=account_vendor_rdo]:checked").val().split("@@")[1];
	$("#account_write_receipt_vendor_no_" + _mobile_account_vendor.ReceiptID).val(vendorNo);
	$("#account_write_receipt_vendor_" + _mobile_account_vendor.ReceiptID).val(vendorName);

	_mobile_account_vendor.SearchText = "";
	_mobile_account_vendor.Page = 1;
	_mobile_account_vendor.EndOfList = false;
	
	mobile_comm_back();
}

// 거래처 검색 클릭
function mobile_account_clickSearchVendor() {
	_mobile_account_vendor.SearchText = $('#account_vendor_search_input').val();
	_mobile_account_vendor.Page = 1;
	_mobile_account_vendor.EndOfList = false;
	mobile_account_getVendor();
}


/* 
 * 
 * 개인카드 선택 페이지 시작
 * 
 */

var _mobile_account_prcard = {
	ReceiptID : '',
	
	// 리스트 조회 초기 데이터
	Page: 1,			//조회할 페이지
	PageSize: 10,		//페이지당 건수
	
	// 페이징을 위한 데이터
	TotalCount: -1,		//전체 건수
	EndOfList: false,	//전체 리스트를 다 보여줬는지
};

// 개인카드 목록 초기화
function mobile_account_PRCardInit() {
	if (window.sessionStorage["prcard_receipt_id"] != undefined) {
		_mobile_account_prcard.ReceiptID = window.sessionStorage["prcard_receipt_id"];
    } else {
    	_mobile_account_prcard.ReceiptID = '';
    }
	
	mobile_account_getPrivateCard();
	
	$("a[role=button]").eq(0).remove();
}

// 개인카드 목록 가져오기
function mobile_account_getPrivateCard() {
	var sHtml = "";
	$.ajax({
		type:"POST",
		data:{
			searchText: '',
			pageNo: _mobile_account_prcard.Page
		},
		url:"/account/mobile/account/getPrivateCardPopupList.do",
		success:function (data) {
			if(data.status == "SUCCESS") {
				_mobile_account_prcard.TotalCount = data.page.listCount;
				
				if(data.list.length > 0) {
					$(data.list).each(function(i, obj) {
						sHtml += "<li id='account_prcard_li" + obj.VendorID + "'>";
						sHtml += "	<div class='receipt_chk'>"; //TODO: prcard_rdo class 새로 생성 필요
						sHtml += "		<input type='radio' name='account_prcard_rdo' value='" + obj.CardNo + "@@" + obj.CardNoView + "' id='account_prcard_rdo_" + i + "'><label for='account_prcard_rdo_" + i + "'></label>";
						sHtml += "	</div>";
						sHtml += "	<div class='receipt_con'>";
						sHtml += "		<p class='tx_name ellip'><span class='cate' style='border: 1px solid #c7c7c7; color: #222;'>" + obj.CardCompanyName + "</span>" + obj.CardNoView + " (" + obj.OwnerUserName + ")</p>";
						sHtml += "	</div>";
						sHtml += "</li>";
					});
					
					if(_mobile_account_prcard.Page == 1 || sHtml.indexOf("no_list") > -1) {
						$('#account_prcard_list').html(sHtml).trigger("create");
					} else {
						$('#account_prcard_list').append(sHtml).trigger("create");
					}
					
					if (Math.min((_mobile_account_prcard.Page) * _mobile_account_prcard.PageSize, _mobile_account_prcard.TotalCount) == _mobile_account_prcard.TotalCount) {
						_mobile_account_prcard.EndOfList = true;
		                $('#account_prcard_more').hide();
		            } else {
		                $('#account_prcard_more').show();
		            }
				}
			}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/account/mobile/account/getPrivateCardPopupList.do", response, status, error);
		}
	});
}

// 개인카드 선택 후 비용신청 페이지 내 개인카드 input box에 바인딩
function mobile_account_selectPrivateCard() {
	var cardNo = $("#account_prcard_list").find("input[type=radio][name=account_prcard_rdo]:checked").val().split("@@")[0];
	var cardNoView = $("#account_prcard_list").find("input[type=radio][name=account_prcard_rdo]:checked").val().split("@@")[1];
	$("#account_write_receipt_prcard_no_" + _mobile_account_prcard.ReceiptID).val(cardNo);
	$("#account_write_receipt_prcard_" + _mobile_account_prcard.ReceiptID).val(cardNoView);

	_mobile_account_prcard.Page = 1;
	_mobile_account_prcard.EndOfList = false;
	
	mobile_comm_back();
}


/* 
 * 
 * 코스트센터 선택 페이지 시작
 * 
 */

var _mobile_account_costcenter = {
	SearchText : '',
	
	// 리스트 조회 초기 데이터
	Page: 1,					//조회할 페이지
	PageSize: 10,				//페이지당 건수
	
	// 페이징을 위한 데이터
	TotalCount: -1,				//전체 건수
	EndOfList: false,			//전체 리스트를 다 보여줬는지
	isPopup: true,				//팝업리스트 여부

	//현재 목록 유형
	Mode: 'CostCenterSearch' 	//리스트 타입
};

// 코스트센터 목록 초기화
function mobile_account_CostCenterInit() {	
	mobile_account_getList(_mobile_account_costcenter);
}

//코스트센터 검색 팝업 목록 HTML 리턴
function mobile_account_getCostCenterSearchListHtml(list){
	var sHtml = "";
	
	if(list.length > 0) {
		var tempNum = (_mobile_account_costcenter.Page - 1) * _mobile_account_costcenter.PageSize;
		
		$(list).each(function (i, obj){
			sHtml += "<li id='account_costcenter_li" + obj.CostCenterCode + "'>";
			sHtml += "	<div class='receipt_chk'>";
			sHtml += "		<input type='radio' name='account_costcenter_rdo' value='" + obj.CostCenterCode + "@@" + obj.CostCenterName + "' id='account_costcenter_rdo_" + (tempNum + i) + "'><label for='account_costcenter_rdo_" + (tempNum + i) + "'></label>";
			sHtml += "	</div>";
			sHtml += "	<div class='receipt_con'>";
			sHtml += "		<p class='tx_name ellip'>[" + obj.CostCenterCode + "] " + obj.CostCenterName + "</p>";
			sHtml += "		<p class='tx_sub'>";
			sHtml += "			<span class='tx_sub_txt'>" + mobile_comm_getDic("lbl_Period") + " : " + obj.UsePeriodStart + " ~ " + obj.UsePeriodFinish + "</span>";
			sHtml += "			<span class='tx_sub_txt'>" + mobile_comm_getDic("lbl_explanation") + " : " + obj.Description + "</span>";
			sHtml += "		</p>";
			sHtml += "	</div>";
			sHtml += "</li>";
		});
	} else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}

//스크롤 더보기
function mobile_account_costcenter_page_ListAddMore() {
	mobile_account_nextlist(_mobile_account_costcenter);
}

// 코스트센터 선택 후 비용신청 페이지 내 코스트센터 input box에 바인딩
function mobile_account_selectCostCenter() {
	var CostCenterCode = $("#account_costcenter_list").find("input[type=radio][name=account_costcenter_rdo]:checked").val().split("@@")[0];
	var CostCenterName = $("#account_costcenter_list").find("input[type=radio][name=account_costcenter_rdo]:checked").val().split("@@")[1];
	$("#account_write_costCenter_code").val(CostCenterCode);
	$("#account_write_costCenter").val(CostCenterName);

	_mobile_account_costcenter.SearchText = "";
	_mobile_account_costcenter.Page = 1;
	_mobile_account_costcenter.EndOfList = false;
	
	mobile_comm_back();
}

// 코스트센터 검색 클릭
function mobile_account_clickSearchCostCenter() {
	_mobile_account_costcenter.SearchText = $('#account_costcenter_search_input').val();
	_mobile_account_costcenter.Page = 1;
	_mobile_account_costcenter.EndOfList = false;
	mobile_account_getList(_mobile_account_costcenter);
}


/* 
 * 
 * IO 선택 페이지 시작
 * 
 */

var _mobile_account_io = {
	SearchText : '',
	
	// 리스트 조회 초기 데이터
	Page: 1,			//조회할 페이지
	PageSize: 10,		//페이지당 건수
	
	// 페이징을 위한 데이터
	TotalCount: -1,		//전체 건수
	EndOfList: false,	//전체 리스트를 다 보여줬는지
	isPopup: true,		//팝업리스트 여부

	//현재 목록 유형
	Mode: 'IOSearch' 	//리스트 타입
};

// IO 목록 초기화
function mobile_account_IOInit() {
	mobile_account_getList(_mobile_account_io);
}

//IO 검색 팝업 목록 HTML 리턴
function mobile_account_getIOSearchListHtml(list){
	var sHtml = "";
	
	if(list.length > 0) {
		var tempNum = (_mobile_account_io.Page - 1) * _mobile_account_io.PageSize;
		
		$(list).each(function (i, obj){
			sHtml += "<li id='account_io_li" + obj.Code + "'>";
			sHtml += "	<div class='receipt_chk' style='line-height: 36px;'>";
			sHtml += "		<input type='radio' name='account_io_rdo' value='" + obj.Code + "@@" + obj.CodeName + "' id='account_io_rdo_" + (tempNum + i) + "'><label for='account_io_rdo_" + (tempNum + i) + "'></label>";
			sHtml += "	</div>";
			sHtml += "	<div class='receipt_con'>";
			sHtml += "		<p class='tx_name ellip' style='line-height: 36px;'>[" + obj.Code + "] " + obj.CodeName + "</p>";
			sHtml += "	</div>";
			sHtml += "</li>";
		});
	} else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}

//스크롤 더보기
function mobile_account_io_page_ListAddMore() {
	mobile_account_nextlist(_mobile_account_io);
}

// IO 선택 후 비용신청 페이지 내 IO input box에 바인딩
function mobile_account_selectIO() {
	var IOCode = $("#account_io_list").find("input[type=radio][name=account_io_rdo]:checked").val().split("@@")[0];
	var IOName = $("#account_io_list").find("input[type=radio][name=account_io_rdo]:checked").val().split("@@")[1];
	$("#account_write_IO_code").val(IOCode);
	$("#account_write_IO").val(IOName);

	_mobile_account_io.SearchText = "";
	_mobile_account_io.Page = 1;
	_mobile_account_io.EndOfList = false;
	
	mobile_comm_back();
}

// IO 검색 클릭
function mobile_account_clickSearchIO() {
	_mobile_account_io.SearchText = $('#account_io_search_input').val();
	_mobile_account_io.Page = 1;
	_mobile_account_io.EndOfList = false;
	mobile_account_getList(_mobile_account_io);
}


/*
 * 
 * 기타 함수 시작 
 * 
 */
// 0 붙이기
function mobile_account_addZero(pNum) {
	return (pNum < 10 ? ("0" + pNum) : pNum);
}

// 카드번호 마스킹 
function mobile_account_setCardNo(pCardNo) {
	return pCardNo.substring(0, 4) + "-" + pCardNo.substring(4, 8) + "-" + "****" + "-" + pCardNo.substring(12);
}

// Date Format
function mobile_account_setDateFormat(pDate) {
	return pDate.getFullYear() + "-" 
			+ mobile_account_addZero(pDate.getMonth()+1) + "-" 
			+ mobile_account_addZero(pDate.getDate()) + " " 
			+ mobile_account_addZero(pDate.getHours()) + ":"
			+ mobile_account_addZero(pDate.getMinutes()) + ":"
			+ mobile_account_addZero(pDate.getSeconds());
}

// Amount Format
function mobile_account_toAmtFormat(val) {
	var retVal = "";
	if(val != null){
		if(val.toString != null){
			if(!isNaN(val)){
				retVal = val.toString();
				var splitVal = retVal.split(".");
				if(splitVal.length==2){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
					retVal = retVal +"."+ splitVal[1];
				}
				else if(splitVal.length==1){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
				}else{
					retVal = "";
				}
			}
		}
	}
	//	str.replace(/[^\d]+/g,'')
	return retVal
}

function mobile_account_checkNaN(pVal) {
	var retVal = 0;
	
	if(isNaN(pVal)) {
		retVal = 0;
	} else {
		retVal = Number(pVal);	
	}
	
	return retVal;
}

function mobile_account_nullToBlank(pVal) {
	var retVal = "";
	
	if(!mobile_account_isEmptyStr(pVal)){
		retVal = pVal;
	}
	
	return retVal;
}

function mobile_account_isEmptyStr(pStr){
	if(pStr == null){
		return true;
	}
	
	if(pStr.toString == null){
		return true;
	}
	
	var getStr = pStr.toString();
	
	if(getStr == null){
		return true;
	}
	
	if(getStr != "" && getStr != null && !(/^\s*$/.test(getStr))){
		return false;
	}
	
	return true;
}

function mobile_account_inputNumChk(e){
	var keyValue = e.keyCode;
	
	if((keyValue >= 48) && (keyValue <= 57)){
		return true;
	} else {
		return false;
	}
}

function mobile_account_setNumberComma(obj) {
	$(obj).val(mobile_comm_addComma($(obj).val().replace(/,/gi, "")));
}

function mobile_account_getEscapeStr(pStr) {
	var retValue = pStr.replace(/\'/gi, "&#39;");
	
	return retValue;
}

function mobile_account_getUnescapeStr(pStr) {
	var retValue = pStr.replace(/&#39;/gi, "\'");
	
	return retValue;
}

var mobile_account_setManagerPortal = function(){
	
		/* 공통함수 */		
		var mngComm = {		
			getData : function(purl,param){				
				var deferred = $.Deferred();
				$.ajax({
					url: purl,
					type:"POST",
					data: param,			
					success:function (data) { deferred.resolve(data);},
					error:function(response, status, error){ deferred.reject(status); }
				});				
			 	return deferred.promise();
			}
			,makeComma : function( value ){ return String(value).replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,') }
			,lpad : function( str ){ return /^[0-9]$/.exec(str) ? String(str).replace( /^([0-9])$/, '0$1' ) : String(str) }
			,getPrevDate : function( str ){ 
				var dateArr 		= /(\d{4})(\d{2})/.exec( str );
				var strYear  		= this.lpad( (dateArr[2]-1) * 1 === 0 ? dateArr[1]-1 : dateArr[1] );
		        var strMonth 		= this.lpad( (dateArr[2]-1) * 1 === 0 ? 12 : (dateArr[2]-1) );
		        return strYear+strMonth;			
			}
			,getNextDate : function( str ){ 
				var dateArr 		= 	/(\d{4})(\d{2})/.exec( str );
				var date  			=   new Date( dateArr[1] , dateArr[2] , 1 );
				var strYear  		=   date.getFullYear();
		        var strMonth   		=   this.lpad( date.getMonth()+1 );
				return strYear+strMonth;	
			}
			,addEvent : function(){				
				//상위 카테고리 이벤트
				$("#account_portal_manager_report,#account_portal_manager_monthReport,#account_portal_manager_budgetReport").on( 'change', function(){
					var attr =  this.getAttribute('id');
					attr === 'account_portal_manager_report' 		&& reportTopObj.changeReport();
					attr === 'account_portal_manager_monthReport'	&& monthChartObj.changeChart();
					attr === 'account_portal_manager_budgetReport' 	&& budgetChartObj.changeChart();
				});				
				$("#account_portal_manager_popup").on('click',function(){ event.target.dataset.type && event.target.dataset.type === "close" && $(this).empty().hide(); });				
				/* 리포트 이벤트 */
				reportTopObj.addEvent();								
				/* 월별 신청내역 이벤트 */			
				monthChartObj.addEvent();
				/* 예산대비 지출현황 */
				budgetChartObj.addEvent();
			}
			,objectInit : function(){
				this.setCategory();
				this.addEvent();
				//감사규칙
				var date = new Date();			
				var strDate = date.getFullYear()+this.lpad( date.getMonth()+1 );
				this.getData("/account/accountPortal/getAuditCnt.do",{ 
					proofDate :  strDate
				}).done( function( data ){						
					$("#account_portal_manager_auditDupStore")		.text( data.auditDupStore+"건" );
					$("#account_portal_manager_auditEnterTain")		.text( data.auditEnterTain+"건" );
					$("#account_portal_manager_auditHolidayUse")	.text( data.auditHolidayUse+"건" );
					$("#account_portal_manager_auditLimitAmount")	.text( data.auditLimitAmount+"건" );
					$("#account_portal_manager_auditUserVacation")	.text( data.auditUserVacation+"건" );
				}).fail(  function( e ){  console.error(e) })
			}
			,setCategory : function(){			
				mngComm.getData("/account/accountPortal/getTopCategory.do",{})
					.done( $.proxy( function( data ){						
						$("#account_portal_manager_report,#account_portal_manager_monthReport,#account_portal_manager_budgetReport")
							.append( data.topCateList.map( function( item,idx ){ return $("<option>",{ "value" : item.UserCode, "text" : item.DisplayName }).data('type', item.type )}) );							
						var date = new Date();			
						var strDate = date.getFullYear()+this.lpad( date.getMonth()+1 );						
						reportTopObj.init( strDate );
						monthChartObj.init( strDate );
						budgetChartObj.init( strDate );
					} ,this))
					.fail(  function( e ){  console.error(e) })
			}
		}
	
		/* 리포트 함수  */	
		var reportTopObj = {
			data : {}
			,init : function( date ){ 
				this.data.payDate = date;
				this.changeReport();
			}
			,prevReport : function(){			
				this.data.payDate 	= mngComm.getPrevDate( this.data.payDate );			
	            this.changeReport();
			}
			,nextReport : function(){
				this.data.payDate 	= mngComm.getNextDate( this.data.payDate );			
				this.changeReport();
			}
			,changeReport : function(){
				var type = $('#account_portal_manager_report option:selected').data('type');
				this.data.stdCode = $('#account_portal_manager_report').val();			
				this.data.searchType = type ? type : '';
				mngComm.getData("/account/accountPortal/getReportCategoryList.do",this.data)
					.done( $.proxy( function( data ){  this.drawReport( data ) } ,this) )
					.fail(  function( e ){  console.error(e) })				
			}
			,drawReport : function( data ){			
				var dateArr 		= /(\d{4})(\d{2})/.exec( this.data.payDate );
				$("#account_portal_manager_reportCalTxt").text( dateArr[1]+"년 "+dateArr[2]+"월");				
				$("#account_portal_manager_reportExpTot").text( mngComm.makeComma( data.totalSummery.amount )  );
				$("#account_portal_manager_reportExpCnt").text( "(총 "+data.totalSummery.cnt+"건)" );			
				$("#account_portal_manager_proofCategory")
					.empty()
					.append( data.deptCateList.map( function( item,idx ){ return $("<option>",{ "value" : item.DeptCode, "text" : item.DeptName }) }) )
					.trigger('change');				
				$("#account_portal_manager_accountCategory")
					.empty()
					.append( data.accountCateList.map( function( item,idx ){ return $("<option>",{ "value" : item.AccountCode, "text" : item.AccountName }) }) )
					.trigger('change');			            			
			}
			,addEvent : function(){
				$('#account_portal_manager_proofCategory')		.on('change',function(){	 proofObj.changeCategory( $(this).val() ) });
				$('#account_portal_manager_accountCategory')	.on('change',function(){	 accountObj.changeCategory( $(this).val() ) });
				$("#account_portal_manager_reportCal").on('click',function(){					
					event.target.classList.value === 'prev_month ui-link'  && reportTopObj.prevReport();
					event.target.classList.value === 'next_month ui-link'  && reportTopObj.nextReport();
				});
				$("#account_portal_manager_reportDiv .Slideroll_btn").on('click',function(){
					var click = $(event.target).parent();
					if( $(event.target).parent().attr('class') === 'Slideroll_btn_off' ){
						var idx = $('a',this).index( click );
						$("#account_portal_manager_accountList li").hide().slice( idx*5 , (idx*5)+5 ).show();
						$('a',this).prop('class','Slideroll_btn_off').eq( idx ).prop('class','Slideroll_btn_on')
					}				
				});
			}
			,reportChartDraw : function(calcList){
				var chartColorList = [ "rgba(35,29,180,100)","rgba(0,127,244,100)","rgba(100,202,204,100)","rgba(251,210,5,100)","rgba(255,108,100,100)" ];
				var chartObj = {
						data : {
							labels : calcList.length > 0 ? calcList.map(function(item){ return item.ProofCodeName || item.Name  }) : []					
							,datasets : [{
					    		data : calcList.length > 0 ? calcList.map(function(item){ return item.Amount }) : [1]
					    		,borderWidth : 0
					    		,backgroundColor : chartColorList.slice(0,calcList.length)
					    	}]					
						}
						,options: {		    	
					    	tooltips: { 
					    		enabled: calcList.length > 0
					    		,callbacks: {
					                label: function(tooltipItem, data) {				                	
					                    var label = data.labels[tooltipItem.index] || '';
					                    if (label) {
					                        label += ': ';
					                    }
					                    return label += mngComm.makeComma(data.datasets[0].data[tooltipItem.index])+"원";
					                }
					            }
					    	}
							,legend: { display: false }
					    }
					}			
					if( !this.chart ){				
						chartObj.type = 'doughnut';
						this.chart = new Chart(  this === proofObj ? $("#account_portal_manager_proofDoughnut") : $("#account_portal_manager_accountDoughnut") , chartObj ); 
					} else {				
						this.chart.data = chartObj.data;
						this.chart.options.tooltips.enabled = chartObj.options.tooltips.enabled;				
						this.chart.update();
					}
			}
		}
		
		var proofObj = {			
			data : {}
			,changeCategory : function( dept ){						
				this.data.payDate 		= reportTopObj.data.payDate; 
				this.data.deptCode 		= dept;			
				this.data.searchType 	= reportTopObj.data.searchType;
				this.data.stdCode 		= reportTopObj.data.stdCode;
				this.data.prevPayDate 	= mngComm.getPrevDate( this.data.payDate );
				
				mngComm.getData("/account/accountPortal/portalProof.do",this.data)
					.done( $.proxy( function( data ){ this.draw( data ) },this))
					.fail(  function( e ){  console.error(e) })
			}
			,draw : function( list ){			
				var calcList = 
						list.proofList.filter( function(item){ 						
							//증감 표기
							var prvObj =  list.prevProofList.filter(function(prev){ return prev.AccountCode === item.AccountCode });						
							prvObj.length > 0 && (item.prevAmount = prvObj[0].Amount);
							prvObj.length === 0 && (item.prevAmount = 0);
							item.inDecreate = item.prevAmount === 0 ? "100" : ( Math.trunc( ((item.Amount/item.prevAmount)*100) - 100 ) );		
							return 	item.AccountCode !== 'Total'					
						});
				//리스트
				$("<ul>").append(				
					calcList.length > 0 
					?	calcList.map(function(item,idx){
							var $li 	= $("<li>");
							var $tit 	= $("<div>",{ "class" : "DetailRank10 height" });
							var $price 	= $("<div>",{ "class" : "Detailaccount10" });
							var $prev 	= $("<div>",{ "class" : "Detailaccount30" });
							var sign	= Math.sign( item.inDecreate ) === 1 ? "+" : "";
							
							$tit.append( $("<div>",{ "class" : "Gragh_color blue"+( (idx+1) > 5 ? 6 : (idx+1) )}) )
								.append( $("<a>",{ "href" : "#","text" : item.AccountName }) )
								.appendTo( $li );
							
							$price.append( $("<a>",{ "href" : "#","text" : mngComm.makeComma( item.Amount )+"원" }) )
								  .appendTo( $li );
							
							$prev.append( $("<a>",{ "href" : "#","style" : Math.sign( item.inDecreate ) === -1 ? "color:#cb0a2e" : "color:#002bb4","text" : sign+item.inDecreate+"%" }) )
								 .append( $("<div>",{ "class" : "Gragh_per down" }) )
								 .appendTo( $li );
							return $li;
						})
					:	$("<li>").append( $("<div>",{ "class" : "OWList_none", "text" : "조회할 목록이 없습니다." }) )
				)
				.appendTo( $("#account_portal_manager_proofList").empty() );				
				//차트
				reportTopObj.reportChartDraw.call(this,calcList);
					
			}		
		}
		
		var accountObj = {
			data : {}
			,changeCategory : function( code ){			
				this.data.payDate 		= reportTopObj.data.payDate;
				this.data.accountCode 	= code;
				this.data.searchType 	= reportTopObj.data.searchType;
				this.data.stdCode 		= reportTopObj.data.stdCode;
				this.data.prevPayDate 	= mngComm.getPrevDate( this.data.payDate );				
				this.data.searchType 	= reportTopObj.data.searchType;
				mngComm.getData("/account/accountPortal/portalAccount.do",this.data)
					.done( $.proxy( function( data ){  this.draw( data ) } ,this) )
					.fail(  function( e ){  coviCmn.traceLog(e); })
			}
			,draw : function( list ){
				var calcList = 
					list.accountList.filter( function(item){ 						
						var prvObj =  list.prevAccountList.filter(function(prev){ return prev.ProofCode === item.ProofCode });
						prvObj.length > 0 && (item.prevAmount = prvObj[0].Amount);
						prvObj.length === 0 && (item.prevAmount = 0);
						item.inDecreate = item.prevAmount === 0 ? "100" : ( Math.trunc( ((item.Amount/item.prevAmount)*100) - 100 ) );
						return 	item.Code !== 'Total'					
					});			
				var $obj = $("#account_portal_manager_accountList")
				
				$("<ul>").append(
					calcList.length > 0 
					?	calcList.map(function(item,idx){					
							var $li 	= $("<li>");
							var $tit 	= $("<div>",{ "class" : "DetailRank10 height" });
							var $price 	= $("<div>",{ "class" : "Detailaccount10" });
							var $prev 	= $("<div>",{ "class" : "Detailaccount30" });
							var sign	= Math.sign( item.inDecreate ) === 1 ? "+" : "";
							
							$tit.append( $("<div>",{ "class" : "Gragh_color blue"+( (idx+1) > 5 ? 6 : (idx+1) )}) )
								.append( $("<a>",{ "href" : "#","text" : item.Name }) )
								.appendTo( $li );
							
							$price.append( $("<a>",{ "href" : "#","text" : mngComm.makeComma( item.Amount )+"원" }) )
								  .appendTo( $li );
							
							$prev.append( $("<a>",{ "href" : "#","style" : Math.sign( item.inDecreate ) === -1 ? "color:#cb0a2e" : "color:#002bb4","text" : sign+item.inDecreate+"%" }) )
								 .append( $("<div>",{ "class" : "Gragh_per down" }) )
								 .appendTo( $li );
							return $li;
						})
					:	$("<li>").append( $("<div>",{ "class" : "OWList_none", "text" : "조회할 목록이 없습니다." }) )
				)
				.appendTo( $obj.empty() );
				//차트
				reportTopObj.reportChartDraw.call(this,calcList);
	
				$("li",$obj).slice( 5 ).hide();
				var btnLen = Math.ceil( $("li",$obj).length / 5 );
				var $fragment = $( document.createDocumentFragment());			
				for( var i =0; i< btnLen; i++) $fragment.append( $("<a>",{ "class" : "Slideroll_btn_"+(i===0 ? "on" : "off") , "href" : "#" }).append("<span>") );
				$("#account_portal_manager_reportDiv .Slideroll_btn").empty().append( $fragment );
				
			}	
		}
		
		/* 월별 신청내역 함수 */
		var monthChartObj = {
			data : {}
			,init : function( date ){ 
				this.data.payYear = 2019
				this.chart = new Chart( $("#account_portal_manager_monthChart"),{
				    type: 'bar',
				    data: { labels: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'] }
				    ,options: {
				    	legend: {
				            display: true,			            
				            labels: {			                
			                	boxWidth : 20	
			                	,usePointStyle : true
			                	,padding : 30
				            }
				        }
				        ,scales: {
				            xAxes: [{ stacked: true }],			            
					        yAxes: [{
					        	stacked: true
					        	,ticks: {
				                    callback: function(value, index, values) {
				                    	return mngComm.makeComma(value)   
				                    }
				                }
				            }]
				        }
					    ,tooltips: { enabled: false }
				    }
				});				
				this.changeChart();
			}
			,prevReport : function(){
				this.data.payYear 	-=  1;
	            this.changeChart();
			}
			,nextReport : function(){
				this.data.payYear 	+=  1;
				this.changeChart();
			}		
			,changeChart : function(){			
				var type = $('#topMonthCate option:selected').data('type');	
				this.data.stdCode = $('#topMonthCate').val();
				this.data.searchType = type ? type : '';				
				mngComm.getData("/account/accountPortal/getAccountMonth.do",this.data)
					.done( $.proxy( function( data ){  this.draw( data.chartObj ) } ,this) )
					.fail(  function( e ){  coviCmn.traceLog(e); })
			}
			,draw : function( obj ){				
				var chartColorList = [ "rgba(253,207,2,100)","rgba(255,105,101,100)","rgba(101,203,204,100)","rgba(158,112,176,100)","rgba(118.215,116,100)","rgba(118.215,116,200)" ];			
				this.chart.data.datasets = 
						obj.monthHeader.slice(0,6).reduce(function( acc,cur,idx,arr ){
							var rowHeader = {};
							rowHeader.label					= 	idx < 5 ? 	cur.Name : "기타" ;
							rowHeader.data 					=	idx < 5 ?	obj.monthList.map(function(item,idx){ return item["SUM_"+cur.Code] || 0 })
																		:	obj.monthList.map(function( item,idx ){ return obj.monthHeader.slice(5).reduce(function( acc,cur,idx,arr ){ return acc = acc + item["SUM_"+cur.Code] || 0; },0) });
							rowHeader.backgroundColor 		=	chartColorList[idx] 
							rowHeader.hoverBackgroundColor	=	chartColorList[idx]
							rowHeader.borderColor			=	'rgb(255, 255, 255)'
							return acc = acc.concat( rowHeader );
						},[]);			
				obj.monthHeader.length > 0 && this.chart.update();
				obj.monthHeader.length === 0 && this.chart.render();
				
				this.chart.popup = 
					obj.monthList.reduce(function( acc,cur,idx,arr ){
						return acc = cur.paydt !== null ? acc.concat(
								$("<div>",{ "class" : "eac_user_month_txt", "style" : "left:50px;" })									
								.append(
									$("<div>",{ "class" : "arrow_box", "style" : "display:block" })
										.append(  $("<div>",{ "class" : "xbtn_area" }).append($("<a>",{ "href" : "#", "class" : "btn_del", "data-type" : "close"})) )								
										.append( 
											$("<h1>",{ "class" : "arrow_titlename" })
													.append( cur.payDate.replace(/(\d{4})(\d{2})/,"$2")+"월 " )
											  		.append( $("<span>",{ "text" : mngComm.makeComma( cur.AmountSum ) }) )
											  		.append( "원" )
										)	
										.append( 
											$("<ul>").append(												
												obj.monthHeader.reduce( function( acc,item,idx,arr ){
													var price = cur[ "SUM_"+item.Code  ];
													if( price === 0 ) return acc;
													var $li = $("<li>",{ "class" : (idx+1) > 5 ?  "arrowBtncolor06" : "arrowBtncolor0"+(idx+1) });
													$li.append( $("<span>",{ "class" : "txt01", "text" : item.Name }) )
													   .append( $("<span>",{ "class" : "txt02", "text" : mngComm.makeComma( price )+"원"}) )
													   .data('item', cur[ "SUM_"+item.Code  ] );
													return acc = acc.concat( $li );
												},[]).sort(function(a,b){ return $(b).data('item') - $(a).data('item') })
											)		
										)	
								)	
						) : acc.concat( null );
					},[]);					
			}
			,addEvent : function(){
				$("#account_portal_manager_monthChart").on('click',function(){
					var element 	= monthChartObj.chart.getElementAtEvent(event)[0] || false;
					if( element ){
						var $popupEle = element._chart.popup[ element._index ];						
						$(".arrow_titlename",$popupEle).append("( "+ $("ul > li",$popupEle).length +"건 )");						
						$popupEle && $("#account_portal_manager_popup").empty().append( $popupEle ).show();
					}
				});
			}
		}		
		/* 월별 신청내역 함수 END */
		
		/* 월별 예산대비 지출 함수 */	
	var budgetChartObj = {
		data : {}
		,init : function( date ){ 
			/*var comm = Common.getBaseCode('BUDGET_STD').CacheData[0];*/			
			this.data.payYear = Number( date.replace(/(\d{4})(\d{2})/,"$1") );			
			/*this.data.accountCode	=	comm.Reserved1;
			this.data.sbCode1		=	comm.Reserved2;
			this.data.sbCode2		=	comm.Reserved3;*/
			this.chart = new Chart( $("#account_portal_manager_budgetChart"),{
			    type: 'bar',
			    data: { labels: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'] }
			    ,options: {
			    	legend: {
			            display: false,			            
			            labels: {			                
		                	boxWidth : 20	
		                	,usePointStyle : true
		                	,padding : 30
			            }
			        }
			        ,scales: {			            			            
				        yAxes: [{				        	
				        	ticks: {
			                    callback: function(value, index, values) {
			                    	return mngComm.makeComma(value)   
			                    }
			                }
			            }]
			        }
				    ,tooltips: { enabled: false }
			    }
			});
			this.changeChart();
		}
		,prevReport : function(){			
	        this.data.payYear 	-=  1;
	        this.changeChart();
		}
		,nextReport : function(){
			this.data.payYear 	+=  1;
			this.changeChart();
		}
		,changeChart : function(){
			var type = $('#topBudgetCate option:selected').data('type');	
			this.data.stdCode = $('#topBudgetCate').val();
			this.data.searchType = type ? type : '';
			mngComm.getData("/account/accountPortal/getBudgetMonthSum.do",this.data)
				.done( $.proxy( function( data ){  this.draw( data ) } ,this) )
				.fail(  function( e ){  coviCmn.traceLog(e); })
		}
		,draw : function( obj ){		
			
			var budgetAmount = obj.budgetTotal.BudgetAmount;
			var totalObj = obj.chartObj[12];
			
			
			this.chart.data.datasets = [{
				label : '지출'
				,data : obj.chartObj.slice(0,12).map(function( item,idx ){ return item.UsedAmount })
				,backgroundColor	: 	'rgba(0, 43, 180, 100)'
				,borderColor		:	'rgb(0, 43, 180)'
			}];
			this.chart.popup = 
				obj.chartObj.slice(0,12).reduce(function( acc,cur,idx,arr ){
					return acc = cur.UsedAmount > 0 ? acc.concat(
							$("<div>",{ "class" : "eac_user_month_txt", "style" : "left:50px;" })
								.append( 
									$("<div>",{ "class" : "arrow_box", "style" : "display:block" }) 
										.append( $("<div>",{ "class" : "xbtn_area" }).append( $("<a>",{ "href" : "#", "class" : "btn_del", "data-type" : "close" }) ) )
										.append( $("<h1>",{ "class" : "arrow_titlename", "text" : (idx+1)+"월 자산대비 지출 현황" }) )
										.append( 
											$("<ul>")
												.append( 
													$("<li>",{ "class" : "arrowBtncolor06" })
														.append( $("<span>",{ "class" : "txt01", "text" : "지출" }) )
														.append( $("<span>",{ "class" : "txt02", "text" : mngComm.makeComma( cur.UsedAmount )+"원"  }) )
												)
												
										)						
								)	
					) : acc.concat( null );
				},[]);
			this.chart.update();	
			$("#account_portal_manager_budgetAmount")	.text( mngComm.makeComma(budgetAmount) );
			$("#account_portal_manager_UsedAmount")		.text( mngComm.makeComma(totalObj.UsedAmount) );
			$("#account_portal_manager_processAmount")	.text( mngComm.makeComma(totalObj.pending) );
			$("#account_portal_manager_leftAmount")		.text( mngComm.makeComma(budgetAmount - totalObj.UsedAmount) );
		}
		,addEvent : function(){
			$("#account_portal_manager_budgetChart").on('click',function(){
				var element 	= budgetChartObj.chart.getElementAtEvent(event)[0] || false;				
				if( element ){
					var $popupEle = element._chart.popup[ element._index ];
					$popupEle && $("#account_portal_manager_popup").empty().append( $popupEle ).show();
				}
			});
		}
	}
	/* 월별 예산대비 지출 함수 END */
	mngComm.objectInit();
}

// 담당업무 정보 조회/수정 (전결규정에서 담당업무를 셋팅할때 사용)
function mobile_getChargeJob(pMode){
	var chargeJob = "";
	if(pMode == "Write" && _mobile_account_write.ExpenceFormInfo) chargeJob = _mobile_account_write.ExpenceFormInfo.ChargeJob;
	else if(pMode == "View" && _mobile_account_view.ExpenceApplicationInfo) chargeJob = _mobile_account_view.ExpenceApplicationInfo.ChargeJob;
	
	return chargeJob;
}
function mobile_setChargeJob(pMode, pChargeJobInfo){
	var setChargeJobInfo = "";
	
	if(pMode == "Write"){
		if(pChargeJobInfo && pChargeJobInfo.split("@").length > 1){
			setChargeJobInfo = pChargeJobInfo;
		} else{
			setChargeJobInfo = _mobile_account_write.ExpenceFormInfo.SchemaContext.scChgr.value; // 전결규정 담당업무가 없으면 양식 기본설정된 정보 이용 (mobile_account_getFormManageInfo 에서 전자결재 설정이 아닌 경비결재 담당업무 설정으로 변경된 데이터)
		}
		if(setChargeJobInfo && setChargeJobInfo.split("@").length > 1){
			var aChargeJob = setChargeJobInfo.split("^").map(pair => pair.split("@")[0]);
			var setChargeJob = aChargeJob.join("^");
			
			_mobile_account_write.ExpenceFormInfo.AccountChargeInfo = setChargeJob; // jfcode
			_mobile_account_write.ExpenceFormInfo.ChargeJob = setChargeJobInfo; // jfcode@jfname
			_mobile_account_write.ExpenceApplicationInfo.ChargeJob = setChargeJobInfo; // jfcode@jfname
			mobile_account_getJobFunctionData(); //$("#account_write_chargeJob").val(setChargeJobInfo); // _mobile_account_write.ExpenceFormInfo.AccountChargeInfo
			//_mobile_account_write.ExpenceFormInfo.SchemaContext.scChgr.value
		}
	} else if(pMode == "View") {
		// 불필요함
		// _mobile_account_view.ExpenceApplicationInfo.ChargeJob
		// _mobile_account_view.SchemaContext.scChgr.value
	}
}
