<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- grid css -->
<link rel="stylesheet" type="text/css" href="<c:url value='/resources/css/axisj/arongi/AXGrid.css'/>" />

<script type="text/javascript">
/**
 * Require Files for AXISJ UI Component...
 * Based        : jQuery
 * Javascript   : AXJ.js, AXGrid.js, AXInput.js, AXSelect.js
 * CSS          : AXJ.css, AXGrid.css, AXButton.css, AXInput.css, AXSelecto.css
 */
AXConfig.AXGrid.fitToWidthRightMargin = 11;

var pageID = "AXGrid";
var AXGrid_instances = [];
var fnGridObj = {
    pageStart: function(){
        fnGridObj.grid.bind();
    },
    grid: {
        target: new AXGrid(),
        bind: function(){
            window.myGrid = fnGridObj.grid.target;

            var getColGroup = function(){
                return [
                    {key:"LOGID",    label:"로그NO", width:"50", align:"center"},
                    {key:"LOGONID",  label:"로그인ID", width:"50", align:"center"},
                    {key:"IPADDRESS", label:"IP", width:"80", align:"center"},
                    {key:"OS",  label:"OS", width:"100"},
                    {key:"BROWSER", label:"브라우저", width:"100"},
                    {key:"LOGONDATE",   label:"로그인시각" + Common.getSession("UR_TimeZoneDisplay"),   width:"100", align:"right", formatter: function(){
    					return CFN_TransLocalTime(this.item.LOGONDATE);
    				}},
                ];
            };

            myGrid.setConfig({
                targetID    : "AXGridTarget",
                colGroup    : getColGroup(),
                body        : {
                    onclick: function(){
                        toast.push(Object.toJSON({ "event": "click", "index": this.index, "r": this.r, "c": this.c, "item": this.item }));
                        // this.list, this.page
                    },
                    /* ondblclick 선언하면 onclick 이벤트가 0.25 초 지연 발생 됩니다. 주의 하시기 바람니다. */
                    ondblclick: function(){
                        toast.push(Object.toJSON({ "event": "dblclick", "index": this.index, "r": this.r, "c": this.c, "item": this.item }));
                        // this.list, this.page
                    },
                    addClass: function(){
                        return (this.index % 2 == 0 ? "gray" : "white"); // red, green, blue, yellow, white, gray
                    }
                }
            });
            
            myGrid.setList({
                ajaxUrl : "/covicore/admin/log/selectconnect.do",
                ajaxPars: {
                	searchInput : ""
                }
            });

        },
        deleteItem: function(index) {
            $.Event(event).stopPropagation(); // 버튼클릭 이벤트가 row click 이벤트를 발생시키지 않도록 합니다.
            var item = myGrid.list[index];
            toast.push('deleteItem: ' + $.param(item).dec());
        },
        getExcel: function(type){
            var obj = myGrid.getExcelFormat(type);
            $("#printout").html(Object.toJSON(obj));
        },
        getSelectedItem: function(){
            toast.push('콘솔창에 데이터를 출력하였습니다.');
        }
        
        /* 페이징 표시 커스터마이징
        ,
        fnMakeNavi: function(){

            var list_offset = 5; // navigation에서 한번에 보여질 페이지 개수
            var start_page = Math.ceil(myGrid.page.pageNo / list_offset) * list_offset - (list_offset - 1);
            var end_page = (start_page + list_offset - 1 > myGrid.page.pageCount) ? myGrid.page.pageCount : start_page + list_offset - 1;

            var custom_navi_html = "";

            custom_navi_html += "<input type=\"button\" value=\"<<\" class=\"AXButton\" onclick=\"fnObj.fnGoPage(1)\"/>";
            custom_navi_html += "<input type=\"button\" value=\"<\" class=\"AXButton\" onclick=\"fnObj.fnGoPage(" + (start_page > 1 ? start_page - 1 : 1) + ")\"/>";

            for (var i=start_page; i<= end_page; i++) {

                custom_navi_html += "<input type=\"button\" value=\"" + i + "\" style=\"width:20px;\" class=\"AXButton " + (i == myGrid.page.pageNo ? "Blue\"" : "\" onclick=\"fnObj.fnGoPage(" + i + ")\"") + "/>";

            }
            custom_navi_html += "<input type=\"button\" value=\">\" class=\"AXButton\" onclick=\"fnObj.fnGoPage(" + (end_page < myGrid.page.pageCount ? end_page + 1 : end_page) + ")\"/>";
            custom_navi_html += "<input type=\"button\" value=\">>\" class=\"AXButton\" onclick=\"fnObj.fnGoPage(myGrid.page.pageCount)\"/>";
            $('#custom_navi').html(custom_navi_html);

        },
        fnGoPage: function(page){

            var pageAdd = page - myGrid.page.pageNo;
            myGrid.goPageMove(pageAdd);
            fnObj.fnMakeNavi();

        }
        */
    }
};

$(window).load(function() {
    fnGridObj.pageStart();
});
</script>

<div id="AXGridTarget" style="height:347px;"></div>
<br/>
<div id="testBtnArea">
	<a href="dbconnect.do">DB 연결</a><br/>
	<a href="selectconnect.do">grid 연결</a><br/>
	<a href="egovbizerror.do">EgovBiz 오류 생성</a><br/>
	<a href="daerror.do">DataAccess 오류 생성</a><br/>
	<a href="ioerror.do">IO 오류 생성</a><br/>
</div>