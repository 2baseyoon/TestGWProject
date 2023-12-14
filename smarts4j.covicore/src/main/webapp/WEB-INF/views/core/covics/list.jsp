<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="egovframework.core.sso.oauth.*" %>
<%@ page import="java.util.*" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-1.8.0.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
</head>
<body>	
	<!-- 로그인 고객지원 팝업 시작 : width, height 그대로 적용해주세요 -->
	<div class="layer_divpop layer_customer" style="width:840px; height:630px; left:0; right:0; top:0; bottom:0; margin:auto; z-index:104; display:none;">
		<div class="divpop_contents">
			<div class="pop_header"><h4 class="divpop_header"><span class="divpop_header_ico">Covision Customer Support Service</span></h4><a class="divpop_close" style="cursor:pointer;"></a><%-- <a class="divpop_window" style="cursor:pointer;display:none;"></a><a class="divpop_full" style="cursor:pointer;"></a><a class="divpop_mini" style="cursor:pointer;"></a>--%></div>
			<div class="divpop_body" style="overflow:hidden; padding:0; height:585px;">
				<!-- 게시판 list 화면일경우 -->
				<div class="customer_popup" style="display:block;">
					<ul class="tabMenu clearFloat">
						<li class="" data="notice"><a href="#">NOTICE</a></li>
						<li class="" data="news"><a href="#">NEWS</a></li>
						<li class="" data="faq"><a href="#">FAQ</a></li>
					</ul>
					<!-- NOTICE -->
					<div class="tabContent active">
						<div class="searchBox02">
							<span>
								<input type="text" class="searchText">
								<button type="button" class="btnSearchType01">검색</button>
							</span>
						</div>
						<div class="notice_list" id="notice_list">
							<!-- 목록 8개까지 노출 -->
							<ul>
							</ul>
							<!-- 페이징 -->
							<div class="table_paging_wrap">
								<div class="table_paging">
									<input type="button" class="paging_begin">
									<input type="button" class="paging_prev">
									<span class="table_paging_no">
									</span>
									<input type="button" class="paging_next">
									<input type="button" class="paging_end">
								</div>
							</div>
							<!-- //페이징 -->
						</div>
					</div>
					<!-- NEWS -->
					<div class="tabContent">
						<div class="searchBox02">
							<span>
								<input type="text" class="searchText">
								<button type="button" class="btnSearchType01">검색</button>
							</span>
						</div>
						<div class="news_list" id="news_list">
							<!-- 목록 4개까지 노출 / 제목 최대2줄까지 노출 -->
							<ul>
							</ul>
							<!-- 페이징 -->
							<div class="table_paging_wrap">
								<div class="table_paging">
									<input type="button" class="paging_begin">
									<input type="button" class="paging_prev">
									<span class="table_paging_no">
									</span>
									<input type="button" class="paging_next">
									<input type="button" class="paging_end">
								</div>
							</div>
							<!-- //페이징 -->
						</div>
					</div>
					<!-- FAQ -->
					<div class="tabContent">
						<div class="searchBox02">
							<span>
								<input type="text" class="searchText">
								<button type="button" class="btnSearchType01">검색</button>
							</span>
						</div>
						<div class="faqList" id="faq_list">
						</div>
						<!-- 페이징 -->
						<div class="table_paging_wrap">
							<div class="table_paging">
								<input type="button" class="paging_begin">
								<input type="button" class="paging_prev">
								<span class="table_paging_no">
								</span>
								<input type="button" class="paging_next">
								<input type="button" class="paging_end">
							</div>
						</div>
						<!-- //페이징 -->
					</div>
				</div>
				<!-- //게시판 list 화면일경우 -->
				<!-- 게시판 view 화면일경우 : pd0클래스 추가 -->
				<div class="customer_popup pd0" style="display:none;">
					<div class="cRConTop">
						<div class="cRTopButtons ">
							<div class="pagingType02 buttonStyleBoxLeft">
								<a href="#" class="btnTypeDefault btnTypeLArrr">목록</a>
							</div>
							<div class="surveySetting">
								<a href="#" class="surveryWinPop">팝업</a>
							</div>
						</div>
					</div>
					<div class='cRContBottom mScrollVH '>
						<div class="boardAllCont">
							<div class="boradTopCont">
								<div class=" cRContBtmTitle">
									<div class="boardTitle">
										<h2 ></h2>
										<span class="boardTitData"><span class="date"></span><span class="hit"></span></span>
									</div>
								</div>
							</div>
							<div class="boradBottomCont">
								<div class="boardViewCont">
									
								</div>
							</div>
						</div>
					</div>
				</div>
				<!-- //게시판 view 화면일경우 -->
			</div>
		</div>
	</div>
	<!-- 로그인 고객지원 팝업 끝 -->
<script>

$(document).ready(function () {		
	//탭클릭
	$(".tabMenu li").click(function(){
		$(".tabMenu li").removeClass("active");
		$(".tabContent").removeClass("active");
		$(this).addClass("active");
		$(".tabContent:eq("+$(this).index()+")").addClass("active");
		
		 var params = {
		            'listType': $(this).attr("data"),
		            'searchText' : '',
		            'pageNo': 1,
		        };
		csList.setParam(params);
		csList.getList();
		 
	});

	$(".tabMenu li:eq("+$(".layer_customer").attr("data")+")").trigger("click");
	//검색창
	$(".searchText").on('keypress', function(e){ 
		if (e.which == 13) {
			csList.setParamItem("searchText", $(this).val());
			csList.setParamItem("pageNo", 1);
			csList.getList();
	    }
	});
	
	$(".btnSearchType01").click(function(){
		csList.setParamItem("searchText", $(this).prev().val());
		csList.setParamItem("pageNo", 1);
		csList.getList();
	});
	//목록화면
	$(".btnTypeLArrr").click(function(){
		$(".customer_popup:eq(0)").show();
		$(".customer_popup:eq(1)").hide();
	});
	
	$(".paging_begin").click(function(){
		csList.setParamItem("pageNo", 1);
		csList.getList();
	});
	$(".paging_prev").click(function(){
		var curPageNo = csList.getParamItem("pageNo");
		if (curPageNo > 1){
			csList.setParamItem("pageNo", (curPageNo-1));
			
			csList.getList();
		}
	});
	$(".paging_next").click(function(){
		var curPageNo = csList.getParamItem("pageNo");
		if (curPageNo < csList.getParamItem("pageCount")){
			csList.setParamItem("pageNo", (curPageNo+1));
			csList.getList();
		}
	});
	$(".paging_end").click(function(){
		csList.setParamItem("pageNo", csList.getParamItem("pageCount"));
		csList.getList();
	});

	$(".layer_customer .divpop_close").click(function(){
		$(".layer_customer").hide();
	});

});

//공지,뉴스 상세
$(document).on("click","#notice_list ul li a, #news_list ul li a",function(){
	csList.setParamItem("messageID", $(this).attr("data"));

	csList.getAjax("/covicore/covics/getCsContents.do", csList.getParam(), function (jsonData) {
		$(".customer_popup:eq(0)").hide();
		$(".customer_popup:eq(1)").show();
		$(".boardTitle h2").text(jsonData.data.Subject);
		$(".boardViewCont").html(unescape(jsonData.data.Body));
		$(".boardTitData .date").text(jsonData.data.CreateDate);
		$(".surveryWinPop").remove();
		if (csList.getListTpe() == "news" && jsonData.data.FileID != ""){
			//covics/photo.do
			$(".boardViewCont").append($("<img>",{"src":"/covicore/covics/photo.do?messageID="+jsonData.data.MessageID}).bind( "error", function(){$(this).attr("src", "/covicore/resources/images/no_image.jpg");}));
//			$(".boardViewCont").append("<img src='/covicore/common/view/Board/"+jsonData.data.FileID+".do' onerror=csList.imgError()");
		}

		
	});
});
//faq 상세
$(document).on("click","#faq_list .faqBox .faq_q",function(){
	csList.setParamItem("messageID", $(this).find("a").attr("data"));
	var obj = $(this).next();
	obj.toggle();
	$(this).parents('.faqBox').toggleClass('active');

	if (obj.is(':visible')){
		csList.getAjax("/covicore/covics/getCsContents.do", csList.getParam(), function (jsonData) {
			obj.find("div").html(unescape(jsonData.data.Body));
		});
	}	
});
//paging no 
$(document).on("click",".table_paging_no input",function(){
	csList.setParamItem("pageNo", $(this).val());
	csList.getList();
});



var csList = {
	params : {}
	,setParam:function(params){
		this.params = params;
	}
	,setParamItem:function(key, val){
		this.params[key] = val;
	}
	,getParam:function(params){
		return this.params;
	}
	,getParamItem:function(key){
		return this.params[key];
	}
	,getListTpe:function(){
		return this.params["listType"]
	}
	,getList:function(){
		csList.getAjax("/covicore/covics/getCsList.do", this.params, function (jsonData) {
			var objId = csList.getListTpe();
			var objList = "";
			var objPage = "";
			if (objId == "faq"){
				objList = $("#"+objId+"_list");
				objPage = $("#"+objId+"_list").next(".table_paging_wrap");
			}else{
				objList = $("#"+objId+"_list ul");
				objPage = $("#"+objId+"_list .table_paging_wrap");
			}	
			objList.empty().append(
					jsonData.list.length > 0 		
						?	jsonData.list.map( function( item,idx ){
								var $li;
								switch(csList.getListTpe()){
									case "news":

										$li = $("<li>").append($("<a>").attr("data", item.MessageID)
																		.append($("<span>",{"class":"nImg"}).append($("<img>",{"src":item.FileID!=null?"/covicore/covics/photo.do?messageID="+item.MessageID:""}).bind( "error", function(){$(this).attr("src", "/covicore/resources/images/no_image.jpg");})))
																		.append($("<span>",{"class":"nTit", "text":item.Subject}))
																		.append($("<span>",{"class":"date", "text":item.CreateDate}))
											);
										break;
									case "faq":
										$li = $("<div>",{"class":"faqBox"})
												.append($("<div>",{"class":"faq_q"}).append($("<a>").attr("data", item.MessageID)
																									.append($("<strong>",{"class":"type","text":item.CategoryName}))
																									.append($("<span>",{"text":item.Subject}))))
												.append($("<div>",{"class":"faq_a"}).append($("<div>",{"class":"faq_inner"}))
											);
										break;
									default:	
										$li = $("<li>").append($("<a>").attr("data", item.MessageID)
																		.append($("<span>",{"class":"tit", "text":item.Subject}))
																		.append($("<span>",{"class":"date", "text":item.CreateDate}))
										);
										break;
								}	
								return $li;
							})
						:	csList.getListTpe() == "faq"?$("<ul>").append($("<li>",{ "class" : "OWList_none", "text" : "조회 할 목록이 없습니다." })):$("<li>",{ "class" : "OWList_none", "text" : "조회 할 목록이 없습니다." })
			);
			if (jsonData.page.pageCount < 2){
				objPage.hide();
			}	
			else{
				objPage.show();
				objPage.find(".table_paging_no").empty();//<input type="button" value="1" class="paging selected">
				csList.setParamItem("pageCount", jsonData.page.pageCount);
				for(var i=1;i<=jsonData.page.pageCount;i++){
					objPage.find(".table_paging_no").append($("<input>",{"value":i, "class":"paging"+(jsonData.page.pageNo==i?" selected":"")}));
				}
			}
		});
	}
	,getAjax: function (apiLink, params, callback) {
         $.ajax({
             type: "POST",
             url: apiLink,
             data: params,
             success: function (result) {
                 if (result.status == "FAIL") {
                	 Common.Error(result.message);
                     return false;
                 }
                 else {
                     return callback(result);
                 }
             },
             error: function (request, status, error) {
            	 Common.Error(status);
             }
         });
    }
  }
	
</script>
</body>
</html>

