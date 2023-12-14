<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<!-- 웹에디터 버전  -->
    <meta name="CoviEditorVersion" content="2.23.11.002" />
    
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title></title>
    <script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
    <script type="text/javascript" src="/covicore/resources/script/covieditor/tinymce_5.10.2/js/tinymce/tinymce.js<%=resourceVersion%>"></script>
    <script type="text/javascript" src="/covicore/resources/script/covieditor/covieditor.js<%=resourceVersion%>"></script>
    <script type="text/javascript" src="/covicore/resources/script/covieditor/utils/aes.js<%=resourceVersion%>"></script>
    
    <script type="text/javascript" src="/covicore/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>
    <link rel="stylesheet" href="/groupware/resources/css/fileControl/jquery-ui-1.8.11.custom.css<%=resourceVersion%>">
    
    <script type="text/javascript">
        var containerID = window.name;
		
        var toggleResize = false;
        
        function covi_editor_loaded_event(editor) {
            if (window.parent.coviEditor && window.parent.coviEditor.editorVariables[containerID] != null &&
                window.parent.coviEditor.editorVariables[containerID].focusObjID != undefined ){
                var focusObjId = window.parent.coviEditor.editorVariables[containerID].focusObjID;

                if (focusObjId != ''){
                    $('#' + focusObjId, window.parent.document).focus();
                }
            }

            if (window.parent.coviEditor && window.parent.coviEditor.editorVariables[containerID] != null &&
                window.parent.coviEditor.editorVariables[containerID].useResize != undefined ){
                var useResize = window.parent.coviEditor.editorVariables[containerID].useResize;
                if (useResize == 'N'){
                    $('#resizeContainer').hide();
                }
            }

            if (window.parent.coviEditor && window.parent.coviEditor.editorVariables[containerID] != null &&
                window.parent.coviEditor.editorVariables[containerID].onLoad != undefined &&
                window.parent.coviEditor.editorVariables[containerID].onLoad != '' ){

                if (typeof window.parent.coviEditor.editorVariables[containerID].onLoad == "string" &&
                    window.parent[window.parent.coviEditor.editorVariables[containerID].onLoad] != undefined){
                    window.parent[window.parent.coviEditor.editorVariables[containerID].onLoad]();

                } else if(typeof window.parent.coviEditor.editorVariables[containerID].onLoad == "function"){
                    window.parent.coviEditor.editorVariables[containerID].onLoad();
                }

            }

            // 22.05.12, Covision, Editor size control, start.
            var $frame = $(parent.document).find("#tbContentElementFrame");
            var $application = $frame.contents().find('[role="application"]');
            
            // 높이 초기값.
            var initYCoord = 504;
            // iframe에 resizable 적용.
            $frame.attr("style","display:flex; resize:vertical;").resizable();
            $frame.css("min-height", "350px");
            $frame.css("max-height", "1000px");
            $application.css("min-height", "340px");
            $application.css("max-height", "990px");

            // iframe 안에서의 mousedown 이벤트
            $frame.mousedown(function(event1) {
            	toggleResize = true;
            	initYCoord = event1.clientY;
            	
            	// iframe 안에서는 mouseup 이벤트가 발생하지 않음. mousedown일 때 iframe을 덮는 div를 생성해서 iframe 위의 div에서 mouseup 이벤트가 발생할 수 있게 함.
            	$('<div class="ui-resizable-iframeFix" style="background: #fff;"></div>').css({
                    width:'100%', height: '100%',
                    position: "fixed", opacity: "0.0", zIndex: 100
            	}).prependTo($(parent.document.body));
            });
            
         	// iframe 밖에서의 mouseup 이벤트
        	$(parent.document).mouseup(function(event3){
        		// mousedown 이벤트에서 생성한 iframe 위로 덮은 div 제거.
        		$(parent.document.body).find('.ui-resizable-iframeFix').remove();
        		
        		// 크기 조절.
        		if (toggleResize) {
        			var frameHeight = $frame.height() + (event3.clientY - initYCoord);
        			$frame.height( frameHeight );
        			$frame.eq(0).contents().find('[role="application"]').height( -10 + frameHeight);
        			$frame.eq(0).contents().find('[role="application"]').css('visibility', 'visible');

            		toggleResize = false;
        		}

        	});
            // 22.05.12, Covision, Editor size control, end.

        }

        function resizeHeight(pMode) {
            var $container = $('.covieditorContainer');
            if (pMode == "plus") {
                if (($container.height() + 200) < 1000) {
                    $container.height($container.height() + 200);
                }
            }

            if (pMode == "minus") {
                if (($container.height() - 200) > 100) {
                    $container.height($container.height() - 200);
                }
            }

            // covieditor 높이 조절
            //$('#dext_frame_holder' + containerID).height($container.height());

            // covieditor 감싸는 iFrame 높이 조절
            //parent.document.all[containerID + 'Frame'].height = $container.height() + 30;
        }
    </script>
</head>
<body>
    <div id="covieditorContainer" class="covieditorContainer" style="width: 100%; height: 600px;">
        <script type="text/javascript">
            var g_editorLang = "ko_KR";

            if (window.parent && window.parent.Common) {
                switch(window.parent.Common.getSession("lang")){
                    case "en":
                        g_editorLang = "en_US";
                        break;
                    case "ko":
                        g_editorLang = "ko_KR";
                        break;
                    case "ja":
                        g_editorLang = "ja";
                        break;
                    case "zh":
                        g_editorLang = "zh_CN";
                        //g_editorLang = "zh_TW";
                        break;
                    default:
                        g_editorLang = "ko_KR";
                        break;
                }
            }

            var zXssUse = "1";
            var zXssRemoveTags = "script,iframe,object";
            var zXssAllowedEvents = ""; // remove all events as default, to allow event ex) "button[onclick|onmouseover],img[onclick]"
            

            COVIEDITOR_CONFIG.Lang = g_editorLang;
        	try {
       	    	if(window.parent.coviEditor.editorVariables[containerID].target == "divWebEditorContainer") {
       	    		COVIEDITOR_CONFIG.initJson = "covi_editor_approval.json";
       	    	}
       	    	else if(window.parent.coviEditor.editorVariables[containerID].target.indexOf("Mail") != -1) {
                    COVIEDITOR_CONFIG.initJson = "covi_editor_mail.json";
                }
       	    	else {
       	    		COVIEDITOR_CONFIG.initJson = "covi_editor.json";
       	    	}
       		} catch(e) {
       		    COVIEDITOR_CONFIG.initJson = "covi_editor.json";
       		}
       		
            COVIEDITOR_CONFIG.zXssUse = zXssUse;
            COVIEDITOR_CONFIG.zXssRemoveTags = zXssRemoveTags;
            COVIEDITOR_CONFIG.zXssAllowedEvents = zXssAllowedEvents;
            COVIEDITOR_CONFIG.DialogWindow = parent.window;
            
            // 23.08.31 : covision modify(코비젼 자체 추가) : 변경 웹소스 로딩.
            COVIEDITOR_CONFIG.resourceVersion = "<%=resourceVersion%>";
            COVIEDITOR_CONFIG.editorVersion = $("meta[name=CoviEditorVersion]").attr("content");
           
            new CoviEditor(containerID);
        </script>
    </div>
    <div id="resizeContainer">
        <table style="width: 100%; background: #F6F6F6; margin-top: 0px; border: 1px solid #BDBDBD; border-top: 0.5px; border-bottom: 0.5px">
            <tr>
                <td style="height: 15px; text-align: center;">
                    <table class="editor_size" cellpadding="0" cellspacing="0" align="center">
                        <tr>
                            <td style="height: 11px; text-align: center; vertical-align: middle">
                                <a href="javascript:;" onclick="resizeHeight('minus');">
                                    <img src="/HtmlSite/smarts4j_n/approval/resources/images/Approval/editor_minus.gif" alt="minus" title="minus" />
                                </a>
                            </td>
                            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                            <td style="height: 11px; text-align: center; vertical-align: middle">
                                <a href="javascript:;" onclick="resizeHeight('plus');">
                                    <img src="/HtmlSite/smarts4j_n/approval/resources/images/Approval/editor_plus.gif" alt="plus" title="plus" />
                                </a>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>