<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.coviframework.util.StringUtil"%>
<%
  String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
  
  String communityID = request.getParameter("communityId");
  String portalID = request.getParameter("portalID");
  String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path", "");
  
  pageContext.setAttribute("communityID", communityID);
  pageContext.setAttribute("portalID", portalID);
%>

<c:if test="${empty communityID || communityID eq ''}">
	<head>
		<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
	</head>
</c:if>

<style>
html,body{height:100%;}
body{font-size: 12px; padding:15px; box-sizing: border-box;}
ul, ol, dl {   list-style: none; }
.column{box-sizing:border-box;} 
.layoutsetting {clear:both; padding-top:15px; background:#fff; }
.layoutsetting_box {position:relative;clear:both;margin:8px 8px 15px 0px;background:#fff;border:1px solid rgb(224, 224, 224);}
.layoutsetting_ul .ui-widget {margin-top:13px; margin-bottom:7px; padding-top:2px; padding-bottom:5px; display:inline-block; width:100px; height:auto;}
.layoutsetting_ul .ui-widget:hover, .layoutsetting_ul .ui-widget.selected {display:inline-block; background-color: lightblue; }
<%
	//out.println(".layoutsetting_ul .ui-widget:hover {display:inline-block; background:url(" + cssPath + "/covicore/resources/images/covision/webpart_ico_sel.gif) no-repeat left top; }");
%>
.btn_left {position:absolute; top:25%; left:12px;}
.btn_right {position:absolute; top:25%; right:12px;}
.layoutsetting_ul {list-style:none; margin:0; padding:0; height:auto;}
.layoutsetting_list {list-style:none; margin:0; padding:0;}
.layoutsetting_list li {vertical-align:top;}
.layoutsetting_list li a {display:inline-table; font-weight:bold; word-break: break-all;}
.btn_paging {bottom:5px; list-style:none; margin:0; height:10px; display:inline-table; padding:0; clear:both; margin-top:5px; margin-left:-47px; margin-bottom:10px;}
.btn_paging li {float:left; margin:0 2px;}
.webpartListTitle{color: white; font-size: 14px; background-color: #0f0f5a; border-radius: 5px; padding: 5px; letter-spacing: 3px;}
.webpartList {text-align:left; height: 91%;   overflow-y: auto;}
.webpartList ul{list-style:none; }
.webpartList .wpTitle{border-bottom: 1px solid #cacbcc;}
.webpartList .wpTitle li{line-height:20px;  }
.webpartList ul li:hover { background: #f7f7f7;  }
.webpartList ul li a{  display: inline-block;  padding: 5px 10px;     box-sizing: border-box;   width: 100%;}
.webpartList ul li a:hover {cursor: pointer;  background: #f7f7f7;  border: 1px solid #dde9f8;}
.layout_in_webpart {position:relative; width:100%; border:1px solid #979797; border-top: 3px solid #000000; margin-bottom: 5px;}
.webpart_title{display: inline-block;   width: 88%;    line-height: 14px;    height: 14px;    word-break: break-all;    word-wrap: break-word;    overflow: hidden;}
<%
	out.println(".searchImgGry {display:inline-block; background: url(" + cssPath + "/covicore/resources/images/theme/icn_png.png) no-repeat -10px -168px !important;	line-height:18px; margin: 0 0 0 -24px; text-indent:-20000px; width:24px; height:20px; border:0px;}");
%>
.searchBox {margin: 0px; padding: 0px; height: 25px; color: #333; border: 1px solid #c6c6c6; border-radius: 3px !important; box-shadow: none !important; text-indent: 6px; margin-top: 6px;}
<%
	out.println(".inputDel {width: 23px; height: 20px;  background: url(" + cssPath + "/covicore/resources/images/theme/icn_png.png) no-repeat -4px -272px; float:right; }");
%>
.WebpartOrder {float:right; margin-right:3px; height:10px; width:26px; text-align:right; padding:0 1px; font-size:10px; line-height:10px;margin-top:1px;}
#mainBoardDiv table{table-layout: fixed;}
#btnx{border:0px;}
<%
	out.println(".docIcn{background: url(" + cssPath + "/covicore/resources/images/theme/icn_png.png) no-repeat -455px -366px; margin: 0px; padding: 6px 0 6px 22px; float: right;  border: 0px;}");
%>
.webpart_set { float: right; margin-top: 2px; margin-right: 3px; line-height: 10px;}
</style>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/Portallayout.css<%=resourceVersion%>">

<script>

//# sourceURL=WebpartSetting.jsp
var portalID = <%=portalID%> ? "<%=portalID%>" : "";
var communityID = <%=communityID%> ? "<%=communityID%>" : "";
var cssPath = "<%=cssPath%>";

var _webpartSet = {
	portalID: portalID,
	wplist: "",
	portalTag: "",
	sTableWidthInfo: "",
	layoutID: 0,
	layoutIsDefault: 0,
	layoutType: 0
};

_webpartSet.init = function(){
	_webpartSet.getLayoutList($("#divLayoutslides"), "auto", 1);
	_webpartSet.getWebpartList();
	_webpartSet.getPortalData();
	_webpartSet.setEvent();
	
	//커뮤니티 웹파트 설정은 미리보기 지원 하지 않음.
	if(communityID){
		$("#previewBtn").hide();
	}
}

_webpartSet.getPortalData = function(){
	  //$("#portalName").text(Common.getDic("PT_" + portalID)); 다국어 처리 후 주석해제
	  $.ajax({
	    	url: "/groupware/portal/getPortalSettingData.do",
	    	type: "post",
	    	data:{
	    		"portalID": portalID
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			_webpartSet.portal = data;
	    			$("#portalName").text(data.portal[0].DisplayName);
	    			$("#portalInfo").text(Common.getDic("PortalType_"+data.portal[0].PortalType)+"-"+data.layout[0].DisplayName);
	    			
	    			_webpartSet.setLayout(data.layout[0].LayoutID,data.layout[0].IsDefault,data.layout[0].LayoutType);
	    			
	    			var webpartData = '';
	    			
	    			$.each(data.webpart,function(i,obj){
	    				webpartData += obj.WebpartID+";";
	    				webpartData += obj.LayoutDivNumber+";";
	    				webpartData += obj.LayoutDivSort+";";
	    				webpartData += obj.WebpartOrder+"|";
	    			});
	    			
	    			_webpartSet.SetCurrentPortal(webpartData);
	    			
	    			var saInput = data.portal[0].LayoutSizeTag.split('|');
	                for (var i = 0; i < saInput.length - 1; i++) {
                        var saInputDetail = saInput[i].split('`');
                        if (document.getElementById(saInputDetail[0]+'webpart')){
	                        $('#' + saInputDetail[0] + 'webpart')[0].parentElement.children[0].value = saInputDetail[2];
	                        $('#' + saInputDetail[0] + 'webpart')[0].parentElement.children[1].value = saInputDetail[1];
	                    }
                    }
	    			$("#hidConfigLayout_"+data.layout[0].LayoutID).closest(".ui-widget").addClass("selected");
	    		}
	    	},
	    	error:function(response,status,error){
	    		CFN_ErrorAjax("/groupware/portal/getPortalSettingData.do",response,status,error);
	    	}
	    });
}

_webpartSet.getLayoutList= function(pObj, pPage, pCurrentPage) {
	var sSuccess = false;
	var sResult;
    try {
	    $.ajax({
	    	url: "/groupware/portal/getSettingLayoutList.do",
	    	data:{
	    		"isCommunity" : (communityID ? 'Y' : 'N')
	    	},
	    	type: "post",
	    	async: false,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			sSuccess = true;
	    			sResult =  data.list;
	    			_webpartSet.layouts = {};
	    			$.each(sResult, function(idx, el){
	    				_webpartSet.layouts[el.LayoutID] = el;
	    			})
	    		}
	    	},
	    	error:function(response,status,error){
	    		CFN_ErrorAjax("/groupware/portal/getSettingLayoutList.do",response,status,error);
	    	}
	    });
        
        var sHTML = "";
        var sbHtml = new StringBuilder();
		
        if (sSuccess) {
            if (sResult.length == 0) {
            } else {
                var i = 0;
                var iNowRow = 0;
                var iNowPage = 0;
                var backStorage = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")); // // baseconfig LayoutThumbnail_SavePath 경로의 파일 조회
                
                if (pPage == "auto") pPage = parseInt((($("#layoutListDiv").width() - 120) / 100), 10);
                var l_TotalCnt = sResult.length;
                var l_TotalPage = parseInt((l_TotalCnt / pPage), 10);
                var l_LastPageRowCnt = 0;
                if (l_TotalCnt % pPage > 0) {
                    l_LastPageRowCnt = l_TotalCnt - (l_TotalPage * pPage);
                    l_TotalPage = l_TotalPage + 1;
                }
                
                $(sResult).each(function(i,obj) {
                    var l_LayoutID = obj.LayoutID
                    var l_DisplayName = obj.DisplayName;
                    var l_LayoutThumbnail = obj.LayoutThumbNail!='' ? coviCmn.loadImage(backStorage + obj.LayoutThumbNail) : cssPath+'/covicore/resources/images/covision/no_img.gif';
                    var l_LayoutTag = obj.LayoutTag;
                    var l_IsDefault = obj.IsDefault;
                    var l_LayoutType = obj.LayoutType;
                    
                    if (iNowRow == 0) {
                        sbHtml.AppendFormat("<ul class=\"layoutsetting_ul\" style=\"margin:0 45px; display:none; position:absolute; width:{0}px;\">", ($("#layoutListDiv").width() - 120));
                    }
					
                    sbHtml.Append("<li class=\"ui-widget\" >");
                    sbHtml.Append("<ul class=\"layoutsetting_list\">");
                    sbHtml.AppendFormat("<li> <a href=\"javascript:;\" onclick=\"_webpartSet.setLayout({0},'{2}',{3})\"><img src=\"{1}\" alt=\"\" style=\"width:40px; height:40px;\" onerror='coviCmn.imgError(this);'/></a>", l_LayoutID, l_LayoutThumbnail, l_IsDefault,l_LayoutType);
                    sbHtml.AppendFormat("<textarea id=\"hidConfigLayout_{0}\" name=\"hidConfigLayout_{0}\" style=\"display:none;\">{1}</textarea> </li>", l_LayoutID, l_LayoutTag);
                    sbHtml.AppendFormat("<li><a href=\"javascript:;\">{0}</a></li>",l_IsDefault=="Y"?("[기본]"+l_DisplayName):l_DisplayName);
                    sbHtml.Append("</ul>");
                    sbHtml.Append("</li>");
					
                    if ((iNowRow + 1) == pPage || ((iNowPage + 1) == l_TotalPage && l_LastPageRowCnt == (iNowRow + 1))) {
                        sbHtml.Append("</ul>");
                        iNowRow = 0;
                        iNowPage++;
                    } else {
                        iNowRow++;
                    }
					
                    i++;
                });
				
                // 이전/다음 버튼
                if (l_TotalPage > 0) {
                    sbHtml.Append("<span class=\"btn_left\" style=\"\"><a href=\"javascript:;\" title=\"Prev\"><img src=\""+cssPath+"/covicore/resources/images/covision/btn_webpartp_left.png\" alt=\"Prev\" /></a></span>");
                    sbHtml.Append("<span class=\"btn_right\" style=\"\"><a href=\"javascript:;\" title=\"Next\"><img src=\""+cssPath+"/covicore/resources/images/covision/btn_webpartp_right.png\" alt=\"Next\" /></a></span>");
                }
				
                // 페이징
                //if (l_TotalPage > 1) {
                var paging_css = "position:absolute;";
                if (_ie) paging_css += " margin-left:50%;";
                sbHtml.AppendFormat("<ul class=\"btn_paging\" style=\"{0}\">", paging_css);
				
                for (var j = 0; j < l_TotalPage; j++) {
                    var l_img = cssPath+"/covicore/resources/images/covision/btn_paging_off.png";
                    if (pCurrentPage == (j + 1)) l_img = cssPath+"/covicore/resources/images/covision/btn_paging_on.png";
					
                    sbHtml.AppendFormat("<li><a href=\"javascript:;\" title=\"{0}\"><img src=\"{1}\" alt=\"{0}\" /></a></li>", (j + 1), l_img);
                }
                sbHtml.Append("</ul>");
                //}
                $(pObj).html(sbHtml.ToString());
                sbHtml.Clear();
				
                $(pObj).find(".layoutsetting_ul").first().show();
                $(pObj).css("height", "118px");
            }
        }
    } catch (e) {
        alert("Error4: " + e.message);
        return false;
    }
}

_webpartSet.getWebpartList= function(){
	var sSuccess = false;
	var sResult;
    try {
	    $.ajax({
	    	url: "/groupware/portal/getSettingWebpartList.do",
	    	type: "post",
	    	data:{
	    		"isCommunity" : (communityID ? 'Y' : 'N'),
	    		"searchWord":$("#searchWord").val(),
	    		"CU_ID" : communityID
	    	},
	    	async: false,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			sSuccess = true;
	    			sResult =  data.list;
	    		}
	    	},
	    	error:function(response,status,error){
	    		CFN_ErrorAjax("/groupware/portal/getSettingWebpartList.do",response,status,error);
	    	}
	    });
		$("#webpartList").html('');
	 
		$.each(sResult,function(i,obj){
	    	var html = "";
	    	html += "<div class='dragbox clone'>";
	    	html += "<div class='wpTitle'>";
	    	html += "<ul>";
	    	html += "<li>";
	    	html += "<a title='{5}'><span class='webpart_title' style='font-weight: 600;'>{1}</span><p>";
	    	html += "<span class='txt_gn11_blur3' style='color:gray'>{2} | {3} | {4}<span></span></span></p>";
	    	html += "<input id='{0}bt'  alt='DetailInfo' onclick=showWebPartManageInfo('{0}') type='button' class='docIcn' style='margin-top: -43px;  margin-right: -6px;'>";
	    	html += "<input id='{0}wp' value='{0}' type='hidden' />";
	    	html += "</a>";
	    	html += "</li>";
	    	html += "</ul>";
	    	html += "</div>";
	    	html += "</div>";
	    	
	    	var appendHtml = String.format(html, obj.WebpartID, CFN_GetDicInfo(obj.WebpartName), CFN_GetDicInfo(obj.CompanyName), obj.BizSection, isNull(obj.MinHeight,'0'),  isNull(obj.Description,''));
	    	
	    	$("#webpartList").append(appendHtml);
	    });
	    
	    buildDraggableLayout();
	    
    }catch (e) {
        alert("Error4: " + e.message);
        return false;
    }
	
};

// 웹 파트가 추가 되어 있던 포탈을 열었다면 웹 파트의 상태 대로 저장해 주기
_webpartSet.SetCurrentPortal = function (iWebpartID) {
    var aWebpart = new Array();
    var aWebpartItem = new Array();
    var sp = document.getElementById('webpartList');
    aWebpart = iWebpartID.split('|');
    for (var i = 0; i < aWebpart.length - 1; i++) {
        aWebpartItem = aWebpart[i].split(';');
        var sID = '';
        for (var k = 0; k < sp.children.length; k++) {
            if (sp.children[k].children[0].children[0].children[0].children[0].children[3].value == aWebpartItem[0]) {
                sID = sp.children[k].children[0].children[0].children[0].children[0].children[3].id;
                break;
            }
        }
        var obj = document.getElementById(sID);
        var aHTML = new Array();
        if (obj != null) {
            if (obj.outerHTML) {
                aHTML = (document.getElementById(sID).parentNode.parentNode.parentNode.parentNode.parentNode.outerHTML).split('>');
            } else {
                aHTML = ((new XMLSerializer).serializeToString(document.getElementById(sID).parentNode.parentNode.parentNode.parentNode.parentNode)).split('>');
            }
            var aHTML_P_Tag = ''
            for (var p = 0; p < aHTML[6].split('<').length - 1; p++) {
                aHTML_P_Tag += aHTML[6].split('<')[p];
                if (aHTML[6].split('<').length > 3) {
                    if (p != aHTML[6].split('<').length - 3) {
                        aHTML_P_Tag += '<';
                    }
                }
            }

            if (aWebpartItem[3].toLowerCase() == 'null') {
                aWebpartItem[3] = i.toString();
            }
            var aHtmlInputValue = "";
            aHtmlInputValue = aHTML[14];
            aHtmlInputValue = aHtmlInputValue.split('value=\"')[1];
            aHtmlInputValue = aHtmlInputValue.split('"')[0];
            
            var aHtmlDescription = "";
            aHtmlDescription = aHTML[4];
            aHtmlDescription = aHtmlDescription.split('title=\"')[1];
            aHtmlDescription = aHtmlDescription.split('"')[0];
            
            //var minHeight = "";
            //minHeight = aHTML[1];
            //minHeight = minHeight.split('minheight=\"')[1];
            //minHeight = minHeight.split('"')[0]+"px;";
            
            aHTML_P_Tag = "<span class='webpart_title' style='font-weight: 600;'>" + aHTML_P_Tag + "</span>";
            //  x 버튼이 ie7,8,과 opera 에서 디자인이 틀어져서 맞추는 작업 추가
            if (document.getElementById(aWebpartItem[1] + 'webpart')){
	            if (_ie) {
	                document.getElementById(aWebpartItem[1] + 'webpart').innerHTML += aHTML[0].replace('dragbox clone', 'layout_in_webpart') +'>' + aHTML[1] + '>' + aHTML[2] + '>' + aHTML[3] + '>' + aHTML[4] + '>'
	                    + aHTML_P_Tag + aHTML[14] + '>'
	                    + '<input type="button" id="btnx" class="inputDel" onclick="_webpartSet.deleteWebpartDiv(this)"/>'
	                    + '<img id="btne" type="image" src="'+cssPath+'/covicore/resources/images/covision/btn_zadmin_setting.gif" onclick="showWebPartManageInfo(' + aHtmlInputValue + ');" class="webpart_set"/>'
	                    + '<input type="text" class="WebpartOrder" id="loadOrder" value="' + aWebpartItem[3] + '"/>' 
	                    + '<div style="padding: 5px 15px;">'+ aHtmlDescription +'</div>'+ aHTML[15] + '>' + aHTML[16] + '>' + aHTML[17] + '>' + aHTML[18] + '>' + aHTML[19] + '>';
	            } else if (navigator.userAgent.indexOf("Opera") > -1) {
	                document.getElementById(aWebpartItem[1] + 'webpart').innerHTML += aHTML[0].replace('dragbox clone', 'layout_in_webpart') + '>' + aHTML[1] + '>' + aHTML[2] + '>' + aHTML[3] + '>' + aHTML[4] + '>'
	                    + aHTML_P_Tag + aHTML[14] + '>'
	                    + '<input type="button" id="btnx" class="inputDel" onclick="_webpartSet.deleteWebpartDiv(this)"/>'
	                    + '<img id="btne" type="image" src="'+cssPath+'/covicore/resources/images/covision/btn_zadmin_setting.gif" onclick="showWebPartManageInfo(' + aHtmlInputValue + ');" class="webpart_set"/>'
	                    + '<input type="text" class="WebpartOrder" id="loadOrder" value="' + aWebpartItem[3] + '"/>' 
	                    + '<div style="padding: 5px 15px;">'+ aHtmlDescription +'</div>'+ aHTML[15] + '>' + aHTML[16] + '>' + aHTML[17] + '>' + aHTML[18] + '>' + aHTML[19] + '>';
	            } else {
	                document.getElementById(aWebpartItem[1] + 'webpart').innerHTML += aHTML[0].replace('dragbox clone', 'layout_in_webpart') + '>' + aHTML[1] + '>' + aHTML[2] + '>' + aHTML[3] + '>' + aHTML[4] + '>'
	                    + aHTML_P_Tag + aHTML[14] + '>'
	                    + '<input type="button" id="btnx" class="inputDel" onclick="_webpartSet.deleteWebpartDiv(this)"/>'
	                    + '<img id="btne" type="image" src="'+cssPath+'/covicore/resources/images/covision/btn_zadmin_setting.gif" onclick="showWebPartManageInfo(' + aHtmlInputValue + ');" class="webpart_set"/>'
	                    + '<input type="text" class="WebpartOrder" id="loadOrder" value="' + aWebpartItem[3] + '"/>' 
	                    + '<div style="padding: 5px 15px;">'+ aHtmlDescription +'</div>'+ aHTML[15] + '>' + aHTML[16] + '>' + aHTML[17] + '>' + aHTML[18] + '>' + aHTML[19] + '>';
	            }
	        }
	    }
	}
}

//환경설정 페이지 이동-이전페이지
_webpartSet.LayoutPagePrev = function() {	
	var $obj = $("#divLayoutslides");
	var nowPageIdx = $(".layoutsetting_ul:visible",$obj).index();
	var $pageList = $(".layoutsetting_ul",$obj);
	var prevIdx = nowPageIdx === 0 ? 0 : nowPageIdx - 1;
	var $thisPage = $pageList.eq(nowPageIdx);
	$thisPage.hide("slide", { direction: "left" }, 500, null);
	nowPageIdx === 0 && $thisPage.show("slide", { direction: "right" }, 500, null);
	nowPageIdx !== 0 && $thisPage.prev().show("slide", { direction: "right" }, 500, null);
	this.setPageBtn( prevIdx );
};

// 환경설정 페이지 이동-다음페이지
_webpartSet.LayoutPageNext = function() {
	var $obj = $("#divLayoutslides");
	var nowPageIdx = $(".layoutsetting_ul:visible",$obj).index();
	var $pageList = $(".layoutsetting_ul",$obj);
	var pageCount = $pageList.length - 1;
	var nextIdx = nowPageIdx === pageCount ? nowPageIdx : nowPageIdx + 1; 
	var $thisPage = $pageList.eq(nowPageIdx);	
	$thisPage.hide("slide", { direction: "right" }, 500, null);
	nowPageIdx === nextIdx && $thisPage.show("slide", { direction: "left" }, 500, null);
	nowPageIdx !== nextIdx && $thisPage.next().show("slide", { direction: "left" }, 500, null);
	this.setPageBtn( nextIdx );	
};

_webpartSet.setPageBtn = function( idx ){
	var $obj = $("#divLayoutslides");
	var paging = $(".btn_paging",$obj).detach();
	$("img",paging).each(function(pageIdx,item){
		if( idx === pageIdx ){
			item.src = item.src.replace("_off.png", "_on.png");
		}else{
			item.src = item.src.replace("_on.png", "_off.png");
		}
	});
	$("#divLayoutslides").append( paging.data('page',idx) );
}

_webpartSet.setEvent = function(){	
	//페이지 버튼 클릭시
	$("#divLayoutslides .btn_paging").data('page',0).find("img").on('click',function(){
		var $pageWrap = $("#divLayoutslides .btn_paging");	
		var targetPageIdx = $("img",$pageWrap).index(this); 
		var thisPageIdx = $pageWrap.data('page');
		var moveIdx =  targetPageIdx - thisPageIdx;
		var $pageList = $("#divLayoutslides .layoutsetting_ul");
		
		if( moveIdx === 0 ) return false;		
		if( moveIdx > 0 ) {
			//next
			$pageList.eq( thisPageIdx ).hide("slide", { direction: "right" }, 500, null);
			$pageList.eq( thisPageIdx + moveIdx ).show("slide", { direction: "left" }, 500, null);
		}else{
			//prev
			$pageList.eq( thisPageIdx ).hide("slide", { direction: "left" }, 500, null);
			$pageList.eq( thisPageIdx + moveIdx ).show("slide", { direction: "right" }, 500, null);	
		}
		_webpartSet.setPageBtn( thisPageIdx + moveIdx );
	});
	//좌우 슬라이드
	$(".btn_left,.btn_right","#divLayoutslides").on('click',function(){
		var className = this.className;
		className === "btn_left" 	&& _webpartSet.LayoutPagePrev();
		className === "btn_right" 	&& _webpartSet.LayoutPageNext();
	});
	
}

//레이아웃 적용
_webpartSet.setLayout =  function (layoutID, isDefault, sTag) {
	var sLayout ='';
	
	if (_webpartSet.layouts[layoutID].SettingLayoutTag != ''){
		sLayout = Base64.b64_to_utf8(_webpartSet.layouts[layoutID].SettingLayoutTag);
	}
	else {
		if(isDefault == "Y"){
			switch(String(sTag)){
			case "1": //2행 4열
				sLayout = '<table width="100%" class="con_table"><tr><td id="Td1" align="left" valign="top" colspan="1" rowspan="2" style="width: 129px;height: 400px;">W:205px<div id="2webpart">{{ doc.layout.div2 }}</div></td><td id="Td2" align="left" valign="top" colspan="2" rowspan="1" style="width: 258px;height: 200px;">W:100%<div id="5webpart">{{ doc.layout.div5 }}</div></td><td id="Td3" align="left" valign="top" colspan="1" rowspan="2" style="width: 129px;height: 400px;">W:205px<div id="13webpart">{{ doc.layout.div13 }}</div></td></tr><tr><td id="Td4" align="left" valign="top" colspan="1" rowspan="1" style="width: 129px;height: 200px;">W:50%<div id="8webpart">{{ doc.layout.div8 }}</div></td><td id="Td5" align="left" valign="top" colspan="1" rowspan="1" style="width: 129px;height: 200px;">W:50%<div id="11webpart">{{ doc.layout.div11 }}</div></td></tr></table>';
				break;
			case "2": //2행 3열(우측)
				sLayout = '<table width="100%" class="con_table"><tr><td id="Td6" align="left" valign="top" colspan="2" rowspan="1" style="height: 200px;">W:100%<div id="4webpart">{{ doc.layout.div4 }}</div></td><td id="Td7" align="left" valign="top" colspan="1" rowspan="2" style="height: 400px;">W:203px<div id="13webpart">{{ doc.layout.div13 }}</div></td></tr><tr><td id="Td8" align="left" valign="top" colspan="1" rowspan="1" style="height: 200px;">W:50%<div id="8webpart">{{ doc.layout.div8 }}</div></td><td id="Td9" align="left" valign="top" colspan="1" rowspan="1" style="height: 200px;">W:50%<div id="11webpart">{{ doc.layout.div11 }}</div></td></tr></table>';
				break;
			case "3": //메인
				sLayout = '<table width="100%" class="con_table"><tr><td colspan="2" align="left" valign="top" style="height: 200px;">W:100%<div id="4webpart" class="table_layout">{{ doc.layout.div4 }}</div></td><td align="left" valign="top" style="height: 200px;">W:205px<div id="8webpart" class="table_layout">{{ doc.layout.div8 }}</div></td></tr><tr><td width="205" align="left" valign="top" style="height: 200px;">W:205px<div id="11webpart" class="table_layout">{{ doc.layout.div11 }}</div></td><td align="left" valign="top" style="width: 129px; height: 200px;">W:100%<div id="13webpart">{{ doc.layout.div13 }}</div></td><td width="205" align="left" valign="top" style="height: 200px;">W:205px<div id="15webpart" class="table_layout">{{ doc.layout.div15 }}</div></td></tr></table>';
				break;
			case "4": //2행 2열
				sLayout = '<table width="100%" class="con_table"><tr><td colspan="2" align="left" valign="top" style="width: 516px; height: 200px;">W:100%<div id="4webpart">{{ doc.layout.div4 }}</div></td></tr><tr><td align="left" valign="top" style="width: 258px; height: 200px;">W:50%<div id="8webpart">{{ doc.layout.div8 }}</div></td><td class="table_layout" align="left" valign="top" style="width: 258px; height: 200px;">W:50%<div id="11webpart">{{ doc.layout.div11 }}</div></td></tr></table>';
				break;
			case "5": //2행 3열(좌측)
				sLayout = '<table width="100%" class="con_table"><tr><td align="left" valign="top" rowspan="2" style="height: 400px;">W:203px<div id="3webpart">{{ doc.layout.div3 }}</div></td><td colspan="2" align="left" valign="top" style="height: 200px;">W:100%	<div id="6webpart">{{ doc.layout.div6 }}</div></td></tr><tr><td align="left" valign="top" style="height: 200px;">W:50%<div id="10webpart">{{ doc.layout.div10 }}</div></td><td align="left" valign="top" style="height: 200px;">W:50%<div id="13webpart">{{ doc.layout.div13 }}</div></td></tr></table>';
				break;
			case "6": //3열(3단)
				sLayout = '<table width="100%" class="con_table"><tr><td valign="top" style="width: 172px; height: 400px;">W:203px<div id="2webpart">{{ doc.layout.div2 }}</div></td><td valign="top" style="width: 172px; height: 400px;">W:100%<div id="5webpart">{{ doc.layout.div5 }}</div></td><td valign="top" style="width: 172px; height: 400px;">W:203px<div id="7webpart">{{ doc.layout.div7 }}</div></td></tr></table>';
				break;
			case "7": //3열(3단)
				sLayout = '<table width="100%" class="con_table"><tr><td valign="top" style="width: 172px; height: 400px;">좌측<div id="0webpart">{{ doc.layout.div0 }}</div></td><td valign="top" style="width: 172px; height: 400px;">중앙<div id="1webpart">{{ doc.layout.div1 }}</div></td><td valign="top" style="width: 172px; height: 400px;">마이컨텐츠 영역<div id="2webpart">{{ doc.layout.div2 }}</div></td></tr></table>';
				break;
			case "8": //2열(2단)
				sLayout = '<table width="100%" class="con_table"><tr><td valign="top" style="width: 258px; height: 400px;">좌측<div id="0webpart">{{ doc.layout.div0 }}</div></td><td valign="top" style="width: 258px; height: 400px;">마이컨텐츠 영역<div id="2webpart">{{ doc.layout.div2 }}</div></td></tr></table>';
				break;
			case "10": //1행 1열
				sLayout = '<table width="100%" class="con_table"><tr><td id="Td7" align="left" valign="top" style="height: 400px;">W:203px<div id="0webpart">{{ doc.layout.div0 }}</div></td></tr></table>';
				break;
			default:
				sLayout = '<table width="100%" class="con_table"><tr><td valign="top" style="width: 258px; height: 400px;">'+Base64.b64_to_utf8($("#hidConfigLayout_"+layoutID).text())+'</td></tr></table>';
				break;
			}
		}else{
			sLayout =  Base64.b64_to_utf8($("#hidConfigLayout_"+layoutID).text());
		}
	}
	
    if (_webpartSet.layoutID != "" &&_webpartSet.layoutID != 0 && _webpartSet.layoutID != undefined ) {
        Common.Confirm("<spring:message code='Cache.msg_Layout8'/>", "<spring:message code='Cache.lbl_SelectLayout'/>", function (result) {
        	if(result){
		         _webpartSet.layoutID = layoutID;
		         _webpartSet.layoutIsDefault = isDefault;
		         _webpartSet.layoutType = sTag;
		         _webpartSet.insertLayout(sLayout, isDefault);
		         
		         $(".ui-widget.selected").removeClass("selected");
		         $("#hidConfigLayout_"+layoutID).closest(".ui-widget").addClass("selected");
        	}
        });
    } else {
    	 //document.getElementById('hidSelectedLayout').value = $(item).text();
    	 _webpartSet.layoutID = layoutID;
    	 _webpartSet.layoutIsDefault = isDefault;
    	 _webpartSet.layoutType = sTag;
    	 _webpartSet.insertLayout(sLayout, isDefault);
    }
};


_webpartSet.deleteWebpartDiv = function(item) {
    var parentdiv = item.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
    var deletediv = item.parentNode.parentNode.parentNode.parentNode.parentNode;
    parentdiv.removeChild(deletediv);
}

_webpartSet.insertLayout = function (divs, IsDefault) {
    if (divs != null && divs != "") {
        // 캔버스에 레이아웃 HTML을 넣기 
        $('#mainBoardDiv').html(divs);
        // 높이 맞추기 
        var iHeight = 0;
//         if (IsDefault == 'Y') {
        	var trCnt = (divs.split('tr').length-1)/ 2;
        	iHeight = parseInt( ( $("#mainBoardDiv").height()-(trCnt * 20)) / trCnt ); //30: select box 위치 
            $('#mainBoardDiv td').each(function () {
                this.style.border = "solid 1px #aaa";
                this.style.color = "#fff";
                this.style.background = "rgb(96, 117, 154)";
            });
//         } else {
//         	var trCnt = (divs.split('tr').length-1)/ 2;
//             iHeight = parseInt( ( $("#mainBoardDiv").height()-(trCnt * 30)) / trCnt ); //30: select box 위치 
//             $('#mainBoardDiv td').each(function () {
//                 this.style.border = "solid 1px #aaa";
//                 this.style.color = "#fff";
//                 this.style.background = "rgb(96, 117, 154)";
//                	this.children[2].rowSpan = this.rowSpan;
//             });
//         }

        $('#mainBoardDiv div').each(function () {
            // 웹파트 드래그 해서 두는 부분 디자인
            if (this.id.toString().indexOf('webpart') > -1) {
            	this.innerText = "";
                this.className = "column";
                if (IsDefault == 'Y') {
                   	
                	/*   if (this.parentElement.style.height == '400px') {
                        this.style.height = this.parentElement.style.height;
                    } else if (this.parentElement.style.height == '200px') {
                        this.style.height = '190px';
                    } */
                	//this.parentElement.style.height = ((iHeight * this.parentElement.rowSpan) + ((this.parentElement.rowSpan - 1) * 30)) + 'px';
                    this.style.height = ((iHeight * this.parentElement.rowSpan) + ((this.parentElement.rowSpan - 1) * 20)) + 'px';
                } else {
                    this.parentElement.style.height = ((iHeight * this.rowSpan) + ((this.rowSpan - 1) * 30)) + 'px';
                    this.style.height = ((iHeight * this.rowSpan) + ((this.rowSpan - 1) * 30) + (this.rowSpan * 4)) + 'px';
                }
                this.style.width = 100 + '%';
                this.style.background = '#fff';
                this.style.overflow = "auto";
                this.style.padding = "10px 15px";
                this.style.boxSizing = "border-box";
               // $(this).attr("align","center");
            } else {
                this.style.border = 'solid 1px #d4d4d4';
                this.style.background = '#fff';
            }
        });
        
        if (IsDefault != 'Y') {
        	$("#mainBoardDiv .con_table").css("height", "100%");
	        $("#mainBoardDiv div[id$=webpart]").css("height", "100%");
	        $("#mainBoardDiv div[id$=webpart]").css("overflow-x", "hidden");
        }
        
        buildDraggableLayout();
    }

    // 기본 레이아웃 인경우
   /*  if (IsDefault != 'Y') {
        // 현재 레이아웃 명 표시
        //var selectedL = document.getElementById('hidSelectedLayout').value.split('|');
        ///$("#portalName").text(Common.getDic("PT_" + portalID));
        // 사용자 정의 레이아웃 선택된 표시
    } */
}

function buildDraggableLayout() {
    $(".clone").draggable({
        helper: 'clone', //드래그 되는 객체
        cursor: 'hand', //커서 모양
        connectToSortable: ".column", //여기에 붙여넣음.
        //revert: "invalid", //드래그엘리먼트를 드랍했을때 원래의 위치로 가지고 올것인지 판단
        opacity: '0.6', //불투명도
        // 웹파트 명으로 검색
        start: function (event, ui) {
        	var target = event.target || event.srcElement;
        	//var target = event.srcElement;
            if (target != null) {
            	if(target.children[0].children[0].children[0].children[0].children[3]!=null){ //최상위 Div 드래그
            		var eWp = $('#mainBoardDiv input[id="'+target.children[0].children[0].children[0].children[0].children[3].id+'"]')[0]
                    if (eWp != null) {
                        if (eWp.value == target.children[0].children[0].children[0].children[0].children[3].value) {
                            Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                            return false;
                        }
                    }
            	}else if(target.children[0].children[0].children[0].children[3] != null){ //wpTitle div를 클릭했을 경우
           		    var eWp = $('#mainBoardDiv input[id="'+target.children[0].children[0].children[0].children[3].id+'"]')[0]
                    if (eWp != null) {
                        if (eWp.value == target.children[0].children[0].children[0].children[3].value) {
                            Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                            return false;
                        }
                    }
            	}else if (target.parentNode.children[3] != null) { //a 요소안에 span,p,input을 드래그한경우
                    var eWp = $('#mainBoardDiv input[id="'+target.parentNode.children[3].id+'"]')[0]
                    if (eWp != null) {
                        if (eWp.value == target.parentNode.children[3].value) {
                            Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                            return false;
                        }
                    }
                } else if (target.parentNode.children[0].children[3] != null) { //a를 드래그한 경우
                	var eWp = $('#mainBoardDiv input[id="'+target.parentNode.children[0].children[3].id+'"]')[0]
                    if (eWp != null) {
                        if (eWp.value == target.parentNode.children[0].children[3].value) {
                            Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                            return false;
                        }
                    }
                } else if (target.parentNode.parentNode.children[3] != null) { //p태그 안에 span태그를 드래그한 경우(회사명|업무구분|최소높이 부분 드래그)
                	var eWp = $('#mainBoardDiv input[id="'+target.parentNode.parentNode.children[3].id+'"]')[0]
                    if (eWp != null) {
                        if (eWp.value == target.parentNode.parentNode.children[3].value) {
                            Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                            return false;
                        }
                    }
                } else if (target.parentNode.parentNode.children[0].children[3] != null) { //a 요소안에 span,p,input을 드래그한경우
                    var eWp = $('#mainBoardDiv input[id="'+target.parentNode.parentNode.children[0].children[3].id+'"]')[0]
                    if (eWp != null) {
                        if (eWp.value == target.parentNode.parentNode.children[0].children[3].value) {
                            Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                            return false;
                        }
                    }
                } else if (target.children[0] != null) { //a태그를 드래그한 경우
                    if (target.children[0].innerText != '' && target.children[0] != null) {
                    	var eWp = $('#mainBoardDiv input[id="'+target.children[3].id+'"]')[0]
                        if (eWp != null) {
                            if (eWp.value == target.children[3].value) {
                                Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                                return false;
                            }
                        }
                    }
                }
                // FF 용
            } else if (this.triggeringElement != null) { //div를 택한 경우
                if (this.triggeringElement.children[0].children[0].children[0].children[0].children[0] != null) {
                    var eWp = $('#mainBoardDiv input[id="' + this.triggeringElement.children[0].children[0].children[0].children[0].children[3].id + '"]')[0];
                    if (eWp != null) {
                        if (eWp.value == this.triggeringElement.children[0].children[0].children[0].children[0].children[3].value) {
                            Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                            return false;
                        }
                    }
                } else if (this.triggeringElement.children[0] != null) {  
                    if (this.triggeringElement.children[0].children[0].children[0].children[0].children[0].innerText != ''
                    && this.triggeringElement.children[0].children[0].children[0].children[0].children[0] != null) {
                        var eWp = $('#mainBoardDiv input[id="' + this.triggeringElement.children[0].children[0].children[0].children[0].children[3].id + '"]')[0];
                        if (eWp != null) {
                            if (eWp.value == this.triggeringElement.children[0].children[0].children[0].children[0].children[3].value) {
                                Common.Inform("<spring:message code='Cache.msg_Layout11'/>");
                                return false;
                            }
                        }
                    }
                }
            }
        }
    })

    $('.column').sortable({
        connectWith: '.column',
        handle: '.wpTitle',
        cursor: 'move',
        placeholder: 'placeholder',
        forcePlaceholderSize: true,
        revert: true,
        stop: function (event, ui) {
            var sortorder = '';
            ui.item[0].className = 'layout_in_webpart';
            ui.item[0].removeAttribute("style");
            if (ui.item[0].children.length > 0) {
	            //var minHeight = ui.item[0].children[0].getAttribute("minHeight")+"px";
	            //ui.item[0].style.minHeight =  minHeight;
	            //ui.item[0].children[0].style.minHeight =  minHeight;
	            if (ui.item[0].children[0].innerHTML.toString().indexOf('btnx') <= -1) {
                    //이민지(2011-10-19): 날짜 정보 및 상세보기 정보 삭제
                    var oParent = ui.item[0].children[0].children[0].children[0].children[0];
                    var removechild1 = ui.item[0].children[0].children[0].children[0].children[0].children[1];
                    var removechild2 = ui.item[0].children[0].children[0].children[0].children[0].children[2];
                    var inputchild = ui.item[0].children[0].children[0].children[0].children[0].children[3];

                   
	                var appendchild1 = document.createElement('input');
                    appendchild1.id = 'btnx';
                    appendchild1.type = 'button';
                    appendchild1.className = 'inputDel';
                    $(appendchild1).bind("click", function () { _webpartSet.deleteWebpartDiv(this); });

                    if (_ie) {
                        appendchild1.style.marginTop = '2px';
                    } else if (navigator.userAgent.indexOf("Opera") > -1) {
                        appendchild1.style.marginTop = '-14px';
                    }
                                       
                  
                    //로드 순서 결정
                    var appendchild2 = document.createElement('input');
                    appendchild2.id = 'loadOrder';
                    appendchild2.className = 'WebpartOrder';
                    appendchild2.value = '0';
                    //appendchild2.style.width = '15px';
                    //appendchild2.style.height = '11px';
                                      
                    //설명 순서 결정
                    var appendchild3 = document.createElement('div');
                    appendchild3.innerHTML = ui.item[0].children[0].children[0].children[0].children[0].title;
                    appendchild3.style.padding = "5px 15px";
                    
                    var appendchild4 = document.createElement('img');
                    appendchild4.id = 'btne';
                    appendchild4.src = cssPath+'/covicore/resources/images/covision/btn_zadmin_setting.gif';
                    appendchild4.className = 'webpart_set';
                    $(appendchild4).bind("click", function () { showWebPartManageInfo($(inputchild).val()); });

                    oParent.removeChild(removechild1);
                    oParent.removeChild(removechild2);
                    oParent.appendChild(appendchild1);  //삭제버튼
                    oParent.appendChild(appendchild4); 
                    oParent.appendChild(appendchild2);
                    oParent.appendChild(appendchild3);
                }
            }
 
            $('.column').each(function () {
                var itemorder = $(this).sortable('toArray');
                var columnId = $(this).attr('id');
                sortorder += columnId + '=' + itemorder.toString() + '&';
            });
        }
    })
	.disableSelection();
}

_webpartSet.savePortal = function(){
	var chkVali = _webpartSet.savePortalConfig();
	   
	if(chkVali){
	    $.ajax({
	    	type:"POST",
	    	url: "/groupware/portal/setPortalData.do",
	    	data:{
	    		portalID: _webpartSet.portalID,
	    		layoutID: _webpartSet.layoutID,
	    		isDefault: _webpartSet.layoutIsDefault,
	    		webpartList: _webpartSet.wplist,
	    		layoutTag: _webpartSet.portalTag,
	    		layoutWidthInfo: _webpartSet.sTableWidthInfo
	    	},
	    	success:function(data){
	    		if(data.status == "SUCCESS"){
	    			Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ //저장되었습니다.
						location.reload();
	            	});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); //오류가 발생했습니다.
	    		}
	    	},
	    	error:function(response,status,error){
	    		CFN_ErrorAjax("/groupware/portal/setPortalData.do",response,status,error);
	    	}
	    	
	    });
	}
}

_webpartSet.previewPortal = function(){
	var chkVali = _webpartSet.savePortalConfig();
	if(chkVali){
		var data= {
			webpartList: _webpartSet.wplist,
			layoutTag: _webpartSet.portalTag,
			isDefault: _webpartSet.layoutIsDefault
		};
		
		var portalInfo = {
			LayoutType: _webpartSet.layoutType
		};
	
		window.open('','previewPopup');

		var previewForm = document.previewForm;
		previewForm.action = "/groupware/portal/goWebpartSettingPreview.do?CLSYS=portal&CLMD=user&CLBIZ=Portal";
		previewForm.method = "post";
		previewForm.target = "previewPopup";
	/* 	previewForm.CLSYS.value = "portal";
		previewForm.CLMD.value = "user";
		previewForm.CLBIZ.value = "Portal"; */
		previewForm.portalID.value = _webpartSet.portalID;
		previewForm.previewData.value = JSON.stringify(data);
		previewForm.portalInfo.value = JSON.stringify(portalInfo);
		previewForm.submit();
	}
}

// 포탈 설정 저장 처리
_webpartSet.savePortalConfig = function(){
	 // 웹파트 리스트 생성(공통)
    _webpartSet.wplist = '';
    // 인풋값 저장
   	_webpartSet.sTableWidthInfo = '';
  
    $('#mainBoardDiv div').each(function () {
        var num = 0;
        if (this.id.toString().indexOf('webpart') > -1) {
            for (var a = 0; a < this.children.length; a++) {
                if (this.children[a].children.length > 0) {
                    var webpartOrder = this.children[a].children[0].children[0].children[0].children[0].children[4].value;
                    if (webpartOrder == '') {
                        webpartOrder = 0;
                    }
                    _webpartSet.wplist += this.id.toString().replace('webpart', '') + '|' + this.children[a].children[0].children[0].children[0].children[0].children[1].value + '|' + num.toString() + '|' + webpartOrder + ';';
                    num++;
                } else {
                    num--;
                }
            }
        }
    });

    //이민지(2011-10-04): 가로 맞추는 부분
    _webpartSet.portalTag = "";
     if (_webpartSet.layouts[_webpartSet.layoutID].SettingLayoutTag != ''){
    	_webpartSet.portalTag = _webpartSet.layouts[_webpartSet.layoutID].LayoutTag;
    	return true;
    }
     else if (_webpartSet.layoutIsDefault == 'Y') {//이민지(2011-10-11): 기본 레이아웃				
		_webpartSet.portalTag = _webpartSet.layoutType;
    	return true;
    }
    else {//이민지(2011-10-05): 생성 레이아웃
        var aArray = new Array();
        /////////////////////////고정폭 처리 추가 및 input 값 저장
        var iTableWidth = 0;
        //이민지: 고정폭 일 경우 처리
        for (var c = 0; c < $('#mainBoardDiv')[0].children[0].children[0].children.length; c++) {
            var tdLength = $('#mainBoardDiv')[0].children[0].children[0].children[c].children.length;
            if (c == 0) {
                for (var d = 0; d < tdLength; d++) {
                    if ($('#mainBoardDiv')[0].children[0].children[0].children[c].children[d].children[1].value == 'px') {
                        iTableWidth += parseInt($('#mainBoardDiv')[0].children[0].children[0].children[c].children[d].children[0].value);
                        _webpartSet.sTableWidthInfo += $($('#mainBoardDiv')[0].children[0].children[0].children[c].children[d]).find("div[id$='webpart']").attr("id").replace('webpart', '') + '`px`' + $('#mainBoardDiv')[0].children[0].children[0].children[c].children[d].children[0].value + '|';
                    }
                    else {
                        iTableWidth = 0;
                        _webpartSet.sTableWidthInfo += $($('#mainBoardDiv')[0].children[0].children[0].children[c].children[d]).find("div[id$='webpart']").attr("id").replace('webpart', '') + '`per`' + $('#mainBoardDiv')[0].children[0].children[0].children[c].children[d].children[0].value + '|';
                    }
                }
            }
            else {
                for (var e = 0; e < tdLength; e++) {
                    _webpartSet.sTableWidthInfo += $($('#mainBoardDiv')[0].children[0].children[0].children[c].children[e]).find("div[id$='webpart']").attr("id").replace('webpart', '') + '`' + $('#mainBoardDiv')[0].children[0].children[0].children[c].children[e].children[1].value + '`' + $('#mainBoardDiv')[0].children[0].children[0].children[c].children[e].children[0].value + '|';
                }
            }
        }
        var fCheckValue = true;

        if ($('#mainBoardDiv table').length==0)
        {	
            $("#mainBoardCopy").html($('#mainBoardDiv').html());
	        $('#mainBoardCopy div').each(function () {
	            // 웹파트 드래그 해서 두는 부분 디자인
	            this.style.border = 'solid 0px #d4d4d4';
	            this.style.background = '#fff';
	        });
	        $('div[id$="webpart"]').each( function () {
	        	var iWebpartIDTemp = $(this).attr('id').replace("webpart",'');
	        	$(this).parent().find('select').remove();
	        	$(this).parent().find('input').remove();
	//        	$(this).parent().attr('id', iWebpartIDTemp) ;;//.html('{{ doc.layout.div'+iWebpartIDTemp+' }}');
	        	$(this).wrap("<div/>").parent().parent().html('{{ doc.layout.div'+iWebpartIDTemp+' }}');
	        	this.style.color = '';
			    this.style.border = 'none';
			    this.style.background = 'none';
	        })
        }
        else{
	        if (iTableWidth != 0) {
	            $('#mainBoardDiv')[0].children[0].style.width = iTableWidth;
	            $('#mainBoardDiv')[0].children[0].align = 'center';
	        }
	        else {
	            $('#mainBoardDiv')[0].children[0].style.width = '100%';
	        }
	        ///////////////////////////////////
	        var fCheckValue = true;
	        var oInput = null;
	        $('#mainBoardDiv input').each(function () {
	            if (this.id != 'btnx' && this.id.indexOf('webpart') <= -1 && this.id.indexOf('List') <= -1 && this.id.indexOf('Order') <= -1) {
	                if (!IsNumericData(this.value)) {
	                    fCheckValue = false;
	                    oInput = this;
	                    return false;
	                }
	                var typeId = this.id.replace('i', 's');
	                if (document.getElementById(typeId).value == 'px') {
	                    this.parentNode.style.width = this.value + 'px';
	                    this.parentNode.style.height = '';
	                }
	                else {
	                    this.parentNode.style.width = this.value + '%';
	                    this.parentNode.style.height = '';
	                }
	            }
	        });

	        if (!fCheckValue) {
	            Common.Inform("<spring:message code='Cache.lbl_enterWidthValue'/>", "", function () {
	                oInput.focus();
	            });
	            return false;
	        }
	        /////////// 마지막 tr 아래 패딩 없음, 마지막 td 우측 패딩 없음
			$("#mainBoardCopy").html($('#mainBoardDiv').html());
	        
	        $('#mainBoardCopy tr').each( function () {
			    var bBottom = false;
			    if (this == $('#mainBoardCopy tr')[$('#mainBoardCopy tr').length - 1]) {
			        bBottom = true;
			    }
			    var iTD_Length = $(this).find('td').length;
			    var iTD_LengthCount = 0;
			    $(this).find('td').each(function () {
					    iTD_LengthCount++;
					    var iWebpartIDTemp = 0;
					    if (this.children.length > 0) {
					        for (var a = 0; a < this.children.length; a++) {
					            if (this.children[a].id.indexOf('webpart') > -1) {
					                iWebpartIDTemp = this.children[a].id.replace('webpart', '');
					            }
					        }
					    }
					    
					    this.innerHTML = "";
					    this.innerHTML = '<div id ="' + iWebpartIDTemp + '">{{ doc.layout.div'+iWebpartIDTemp+' }}</div>';
					    //this.innerHTML = '<div id ="' + iWebpartIDTemp + '" style="width:' + this.style.width + ';">{{ doc.layout.div'+iWebpartIDTemp+' }}</div>';
					    this.id = this.id + 't';
					    
					    this.style.color = '';
					    this.style.border = 'none';
					    this.style.background = 'none';
				});
			});
        }

        /////////// 마지막 tr 아래 패딩 없음, 마지막 td 우측 패딩 없음 끝

        var obj = document.getElementById('mainBoardCopy');
        var tag = "";
        if (obj.outerHTML) {
            tag = document.getElementById('mainBoardCopy').children[0].outerHTML;
        } else {
            tag = (new XMLSerializer).serializeToString(document.getElementById('mainBoardCopy').children[0]);
        }
		
        _webpartSet.portalTag = Base64.utf8_to_b64(tag);
        return true;
    }

} 

function IsNumericData(strField) {
    var i;
    var ch;
    var isNumeric = true;
    for (i = 0; i < strField.length; i++) {
        ch = strField.charAt(i);
        if (!((ch >= '0') && (ch <= '9'))) {
            isNumeric = false;
        }
        return isNumeric;
    }
}

function showWebPartManageInfo(webpartID){
	if(communityID){
		Common.open("","modifyWebpart","<spring:message code='Cache.lbl_WebPartManage_03'/>|||<spring:message code='Cache.msg_WebPartManage_08'/>","/groupware/portal/goWebpartManageSetPopup.do?webpartID="+webpartID,"620px","500px","iframe",false,null,null,true,"UA");
	}else{
		Common.open("","modifyWebpart","<spring:message code='Cache.lbl_WebPartManage_03'/>|||<spring:message code='Cache.msg_WebPartManage_08'/>","/groupware/portal/goWebpartManageSetPopup.do?webpartID="+webpartID,"620px","500px","iframe",false,null,null,true);
	}
}

function isNull(data,defaultVal){
	if(typeof data == 'undefined' || data == null){
		return defaultVal;
	}
	return data;
}

$(document).ready(function(){
	
	_webpartSet.init();
	
});
</script>

<body style="background-color: #f7f7f7;">
<div id="webpartSettingDiv" style="height: 100%; text-align: center;">
	<div >
		<span style="float:left">
			<font color="black" size="5"><b id="portalName"></b></font><font color="rgb(94, 94, 94)"><span id="portalInfo"></span></font>
		</span>
		<span style="float:right">
			<input id="previewBtn" type="button" class="AXButton" value="<spring:message code='Cache.btn_preview'/>" onclick="_webpartSet.previewPortal();"/>
			<input type="button" class="AXButton Blue" value="<spring:message code='Cache.btn_save'/>" onclick="_webpartSet.savePortal();"/>
		</span>
	</div>
	<div style="clear: both; height:95%;">
		<!--레이아웃 목록 & 메인 보드 시작  -->
		<div class="layoutsetting_lwrap" style="float:left;width:85%;box-sizing: border-box;height: 100%;">
			<div id="layoutListDiv" class="layoutsetting_box" style="overflow: hidden; height: 17%;">
				<div id="divLayoutslides">
					
				</div>
			</div>
			<div id="mainBoardDiv" style="margin: 15px 8px 0px 0px; background-color:#fff; height: 80%; border: 1px solid rgb(224, 224, 224);"></div>
			<div id="mainBoardCopy" style="display:none;"></div>
		</div>
		<!--레이아웃 목록 & 메인 보드 끝 -->
		<!--웹파트 목록 시작 -->
		<div id="webpartListDiv"  style="box-sizing: content-box; float:right;width:14%;margin-top: 8px; border: 1px solid rgb(224, 224, 224); background-color:#fff; height:100%;" >
			<div class="webpartListTitle">
				<b><spring:message code='Cache.lbl_WebpartList'/></b>
			</div>
		  	<div style="height: 40px; border-bottom: 1px solid #eaecef; background: #f8f8f8;">
			    <input class="W200 searchBox" type="text" id="searchWord"  onkeypress="if (event.keyCode==13){ _webpartSet.getWebpartList(); return false;}" placeholder="<spring:message code='Cache.msg_WebPartManage_13'/>">
			    <a class="searchImgGry"  style="width:20px;" onclick="_webpartSet.getWebpartList()">검색</a>
		  	</div>
			<div id="webpartList" class="webpartList"></div>
		</div>
		<!--웹파트 목록 끝 -->
	</div>
</div>
<form name="previewForm">
<!-- 	<input type="hidden" name="CLSYS" value="portal"/>
	<input type="hidden" name="CLMD" value="user"/>
	<input type="hidden" name="CLBIZ" value="Portal" /> -->
	<input type="hidden" name="portalID" />
	<input type="hidden" name="previewData"/>
	<input type="hidden" name="portalInfo"/>
</form>
</body>