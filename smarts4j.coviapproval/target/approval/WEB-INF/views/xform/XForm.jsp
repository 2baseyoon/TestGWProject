<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<html>
<head id="Head1">
    <title></title>
    <!-- <link type="text/css" rel="stylesheet" href="/approval/resources/css/Common.css<%=resourceVersion%>" /> -->
    <link rel="stylesheet" type="text/css" href="/approval/resources/css/xform/approval.css<%=resourceVersion%>" />
    <link rel="stylesheet" type="text/css"  href="/approval/resources/css/xform/approval_form_canvas.css<%=resourceVersion%>" />
    <link rel="stylesheet" type="text/css" href="/approval/resources/css/xform/xform.1.5.css<%=resourceVersion%>" media="screen" />
	<script type="text/javascript" src="/approval/resources/script/xform/Jquery-last.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>	
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script>	
	<script type="text/javascript" src="/approval/resources/script/xform/jquery-ui-1.8.11.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/approval/resources/script/xform/jquery.selectbox-0.6.1.js<%=resourceVersion%>"></script>
</head>
<body>
    <form id="form1">
        <div class="wrapper">
            <div id="header">
                <h2><span class="xform-file-name"></span> - <span class="xform-form-name"></span></h2>
                <ul class="tab">
                    <!--<li><a href="javascript: void(0);" id="toolbox" class="active">Toolbox</a></li>-->
                    <!--<li><a href="javascript: void(0);" id="templates">Templates</a></li>-->
                    <li><a href="javascript: void(0);" id="toolbox" class="active">도구모음</a></li>
                    <li><a href="javascript: void(0);" id="templates">양식목록</a></li>
                    <li>                        
                        <a href="javascript: void(0);" id="writelink" style="float: right; display:none;">
                            <label><input type="checkbox" class="show-writelink-panel" />완료저장연동</label>
                        </a>
                        <a href="javascript: void(0);" id="viewlink" style="float: right; display:none;">
                            <label><input type="checkbox" class="show-viewlink-panel" />기안조회연동</label>
                        </a>
                        <a href="javascript: void(0);" id="templatelink" style="float: right; display:none;">
                            <label><input type="checkbox" class="show-template-panel" />템플릿</label>
                        </a>
                        <a href="javascript: void(0);" id="editorsource" style="float: right; display:none;">
                            <label><input type="checkbox" class="code-edit" onclick="editCode(this);" />소스편집</label>
                        </a>
                        <a href="javascript: void(0);" id="properties" style="float: right; display:none;">
                            <label><input type="checkbox" class="show-right-panel" />속성보기</label>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="header_up" style="display:none;"><a href="javascript: void(0);" class="btn_close"></a></div>
            <div class="colmask threecol">
                <div class="colmid">
                    <div class="colleft">
                        <div class="col1">
                            <!-- Column 1 start -->
                            <div id="tools_panel">
                                <!--<h3 class="tools-toggle layout">Layout Tools</h3>-->
                                <h3 class="tools-toggle layout">컨테이너 도구</h3>
                                <p class="information element-tool-stat">컨테이너를 캔버스로 드래그하세요</p>
                                <div id="layout_tool" class="toolbox">
                                    <ul id="block">
                                        <li data-field="table">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Table</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas">
                                                <img src="/approval/resources/images/xform/ico_add.png" />
                                            </a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>
                                        <li data-field="div">
                                            <img src="/approval/resources/images/xform/ico_div.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">DIV</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas">
                                                <img src="/approval/resources/images/xform/ico_add.png" /></a></li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>
                                    </ul>
                                </div>
                                <!--<h3 class="tools-toggle element">Element Tools</h3>-->
                                <h3 class="tools-toggle element">객체 도구</h3>
                                <!--<p class="information element-tool-stat">필드를 컨테이너로 드래그하세요</p>-->
                                <p class="information element-tool-stat">객체를 컨테이너로 드래그하세요</p>
                                <div id="element_tool" class="toolbox">
                                    <ul id="element">
                                        <li data-field="label">
                                            <img src="/approval/resources/images/xform/ico_label.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Label</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <!-- [2016-02-18 leesm] span, p 태그 추가 -->
                                        <li data-field="span">
                                            <img src="/approval/resources/images/xform/ico_label.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Span</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="p">
                                            <img src="/approval/resources/images/xform/ico_label.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">P</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="heading1">
                                            <img src="/approval/resources/images/xform/ico_header.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Heading(H1)</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="text">
                                            <img src="/approval/resources/images/xform/ico_textbox.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Textbox</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="numeric">
                                            <img src="/approval/resources/images/xform/ico_textbox.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Numeric</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="currency">
                                            <img src="/approval/resources/images/xform/ico_textbox.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Currency(1,000)</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="date">
                                            <img src="/approval/resources/images/xform/ico_textbox.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Date(1999-01-01)</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="maxchar">
                                            <img src="/approval/resources/images/xform/ico_textbox.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Max Char</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="textarea">
                                            <img src="/approval/resources/images/xform/ico_textarea.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Textarea</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="selectbox">
                                            <img src="/approval/resources/images/xform/ico_selectbox.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Select box</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="radio">
                                            <img src="/approval/resources/images/xform/ico_selectbox.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Radio</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="checkbox">
                                            <img src="/approval/resources/images/xform/ico_selectbox.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Checkbox</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>

                                        <li data-field="button">
                                            <img src="/approval/resources/images/xform/ico_button.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Button</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li data-field="a">
                                            <img src="/approval/resources/images/xform/ico_link.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Link</span>
                                            <a href="javascript: void(0);" class="btn_add add-block"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                    </ul>
                                </div>
                                <!--<h3 class="tools-toggle quick">Quick Tools</h3>-->
                                <h3 class="tools-toggle quick">응용 객체 도구</h3>
                                <!--<p class="information element-tool-stat">필드를 컨테이너로 드래그하세요</p>-->
                                <p class="information element-tool-stat">객체를 컨테이너로 드래그하세요</p>
                                <div id="quick_tool" class="toolbox">
                                    <ul id="quick">
                                        <li data-field="table1row2col">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Label & Text</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>
                                        <li data-field="table1row2colselect">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Label & Select</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>
                                        <li data-field="table1row2colcheck">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">Label & Check</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>
                                        <li data-field="table3col">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">5 columns</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>
                                        <li data-field="multi_row_table">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">multi rows</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>
                                        <li data-field="sum_table">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">sum table</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>

                                        <li data-field="sum_multi_row_table">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">multi sum table</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>

                                        <li data-field="jqgrid">
                                            <img src="/approval/resources/images/xform/ico_table.png" class="ico_img drag-handle" />
                                            <span class="drag-handle">jqgrid</span>
                                            <a href="javascript: void(0);" class="btn_add add-canvas"><img src="/approval/resources/images/xform/ico_add.png" /></a>
                                        </li>
                                        <li class="element-preview">
                                            <div class="preview-desc"></div>
                                            <div class="preview-area"></div>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            <div id="template_list">
                                <!--<h3>Template List</h3>-->
                                <h3>양식 목록</h3>
                                <div class="toolbox">
                                    <table>
                                        <tbody></tbody>
                                    </table>
                                </div>

                            </div>
                            <!-- Column 1 end -->
                        </div>
                        <div class="col2">
                            <ul style="list-style: none;">
                                <li class="status-option" style="margin-top: 5px; margin-left: 8px; float: left;">
                                    <label>
                                        <input type="radio" name="edit_mode" value="move" />
                                        <!--<span class="element-movable tooltip" title="Movable"></span>Movable</label>-->
                                        <span class="element-movable tooltip" title="이동"></span>이동
                                    </label>
                                    &nbsp;
                                    <label>
                                        <!--<input type="radio" name="edit_mode" value="edit" />&nbsp;<span class="element-editable tooltip" title="Editable"></span>Editable-->
                                        <input type="radio" name="edit_mode" value="edit" />&nbsp;<span class="element-editable tooltip" title="편집"></span>편집
                                    </label>
                                    &nbsp;&nbsp;&nbsp;
                                    <label class="canvas-opt" style="display:none;">
                                        <!--<input id="Checkbox2" type="checkbox" class="multi-select" /><span style="">multi select</span></label>-->
                                        <input id="Checkbox2" type="checkbox" class="multi-select" checked="checked" /><span style="">다중선택</span></label>
                                    <label class="canvas-opt">
                                        <!--<input id="Checkbox3" type="checkbox" class="element-highlight" /><span style="">Container Highlight</span></label>-->
                                        <input id="Checkbox3" type="checkbox" class="element-highlight" /><span style="">&nbsp;컨테이너 강조</span>
                                    </label>
                                    <!--&nbsp;
                                    <label class="canvas-opt">
                                        <input id="Checkbox4" type="checkbox" class="code-edit" onclick="editCode(this);" /><span style="">Edit Code</span></label>                                        
                                    </label>-->
                                    <%--<label class="canvas-opt"><input id="Checkbox5" type="checkbox" class="code-edit" onclick="editJsCode(this);" /><span style="">Edit Javascript Code</span></label>--%>
                                </li>
                            </ul>
                            <span class="canvas-status"></span>
                            <p id="layoutdims">
                                <div class="layout_tab_box">
                                    <ul id="view_mode" class="layout_tab">
                                        <!--<li><a id="design_view" href="javascript:void(0);" class="select">Form</a></li>-->
                                        <li><a id="design_view" href="javascript:void(0);" class="select">캔버스</a></li>
                                        <!--<li><a id="pre_view" href="javascript: void(0);" onclick="window.open('xpreview.jsp','','top=0,left=150,width=790,height=700');">Preview</a></li>-->
                                        <li><a id="A1" href="javascript: void(0);" onclick="window.open('/approval/resources/script/xform/XFormPreview.html','','top=0,left=150,width=790,height=700');">미리보기</a></li>
                                        <!--<li><a id="code_view" href="javascript:void(0);">Code</a></li>-->
                                        <!--<li><a id="origin_view" href="javascript:void(0);">Origin</a></li>-->
                                        <li><a id="origin_view" href="javascript:void(0);">원본소스</a></li>
                                        <!--<li><a id="live_view" href="javascript:void(0);">Live Test</a></li>-->
                                        <li><a id="live_view" href="javascript:void(0);">양식미리보기</a></li>
                                        <!--<li><a href="javascript:$('#html_popup').click();">Html Editor</a></li>-->
                                        <!--<li class="status"><a id="edit_mode"><span>Element</span></a></li>-->
                                    </ul>
                                </div>
                            </p>
                            <br/>
                            <div id="toolbars_panel">
                                <p id="edit_option">
                                    <input class="cell_merge" type="button" value="merge" style="display: none;" />
                                    <input type="button" class="cell_split" value="split" style="display: none;" />
                                </p>

                                <!-- canvas control menu -->
                                <ul class="canvas-control" style="list-style-type: none;">
                                    <!--<li style="display: inline;"><a href="javascript: void(0);" class="element-undo tooltip" title="Undo"></a></li>-->
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-undo tooltip" title="뒤로"></a></li>
                                    <!--<li style="display: inline;"><a href="javascript: void(0);" class="element-redo tooltip" title="Redo"></a></li>-->
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-redo tooltip" title="앞으로"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="element-new tooltip" title="New Form"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="element-copy tooltip" title="Copy"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="element-cut tooltip" title="Copy"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="element-paste tooltip" title="Paste"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="element-quit tooltip" title="Quit"></a></li>
                                    <!--<li style="display: inline;"><a href="javascript: void(0);" class="element-duplicate tooltip" title="Duplicate"></a></li>-->
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-duplicate tooltip" title="복제"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="element-edit tooltip" title="Edit"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="container-code tooltip" title="Code"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="container-copy tooltip" title="Copy"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="container-cut tooltip" title="Cut"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="container-paste tooltip" title="Paste"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="container-delete tooltip" title="Delete"></a></li>
                                    <li style="display: none;"><a href="javascript: void(0);" class="container-duplicate tooltip" title="Duplicate"></a></li>
                                    
                                    <!--<li style="display: inline;"><a href="javascript: void(0);" class="element-table tooltip" title="Edit Table"></a></li>-->
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-table tooltip" title="테이블 편집"></a></li>
                                    <!--<li style="display: inline;"><a href="javascript: void(0);" class="element-delete tooltip" title="Delete"></a></li>-->
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-delete tooltip" title="삭제"></a></li>

                                    <li style="display: none;"><a href="javascript: void(0);" class="element-code tooltip" title="View Html Code"></a></li>
                                    <!--<li style="display: inline;"><a href="javascript: void(0);" class="element-temporary tooltip" title="Temporary Saving"></a></li>-->
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-temporary tooltip" title="임시저장"></a></li>
                                    <!--<li style="display: inline;"><a href="javascript: void(0);" class="element-history tooltip" title="History"></a></li>-->
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-history tooltip" title="변경이력"></a></li>
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-magic tooltip" title="붙여넣기마법사"></a></li>
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-multirow tooltip" title="multi rows 필수 참고사항"></a></li>


                                    <!--<li style="display: inline; float: right;"><a href="javascript: void(0);" class="element-save" title="Save template"></a></li>-->
                                    <li style="display: inline;"><a href="javascript: void(0);" class="element-save" title="캔버스저장"></a></li>
                                    <!--<li style="display: inline; float:right;" ><a href="javascript: void(0);" class="element-container container-mode" title="Select Container"></a></li>-->
                                </ul>
                                <div id="version_tracer" style="display: none;">
                                    현재: ver.<span class="history-tracer-ver"></span>
                                    <!--<a class="template-original" style="display: inline-block; border: solid 1px #ccc; background-color: #EFEFEF; padding: 3px 5px; cursor: pointer;">Original</a>-->
                                    <a class="template-original" style="display: inline-block; border: solid 1px #ccc; background-color: #EFEFEF; padding: 3px 5px; cursor: pointer;">원본</a>
                                    <!--<a class="history-clear" style="display: inline-block; border: solid 1px #ccc; background-color: #EFEFEF; padding: 3px 5px; cursor: pointer;">Clear all</a>-->
                                    <a class="history-clear" style="display: inline-block; border: solid 1px #ccc; background-color: #EFEFEF; padding: 3px 5px; cursor: pointer;">이력삭제</a>
                                    <span class="storage-history"></span>


                                    <div style="display: none;">
                                        <input type="button" class="history-save" value="set value">
                                        <input type="button" class="history-backward" value="backward">
                                        <input type="button" class="history-forward" value="forward">
                                        <input type="button" class="history-restore" value="apply to html">
                                        <textarea id="storage-history-pulled" style="width: 300px; height: 200px; display: none;"></textarea>
                                    </div>
                                </div>

                            </div>
                            <!-- Column 2 start -->
                            <div id="codeview" class="view-mode" style="display: none;"></div>
                            <div id="originview" class="view-mode" style="display: none;"></div>

                            <iframe id="if_convert" name="if_convert" style="height: 300px; display: none;"></iframe>

                            <!-- [2016-02-24 leesm] js 편집기능 추가 -->
                            <iframe id="if_convert_js" name="if_convert_js" style="height: 300px; display: none;"></iframe>

                            <!-- canvas -->
                            <div id="canvas" class="view-mode"></div>
                            <div class="view-mode">
                                <textarea id="canvas_js" style="display: none;"></textarea>
                            </div>
                            <!-- code editor -->
                            <div id="demotext_wrap">
                                <textarea id="demotext" style="display: none;"></textarea>
                                <textarea id="demotext_js" style="display: none;"></textarea>
                            </div>
                        </div>

                    </div>
                    <div class="col3 property-area">                        
                        <h2>Properties</h2>
                        <p class="information">선택한 필드의 속성을 설정합니다.</p>
                        <div class="property-panel">
                            <!--right -->
                            <input class="property-apply" type="button" value="Apply" />
                            <input class="object-delete" type="button" value="Delete" />
                            <p style="display: inline-block;">*필드 속성을 캔버스에 반영합니다.</p>
                            <span class="property-apply-success" style="display: inline-block; display: none;"></span>
                        </div>
                        <h3>Required</h3>
                        <div class="property-required">
                        </div>
                        <h3>Data</h3>
                        <div class="property-data">
                        </div>
                        <h3>Optional</h3>
                        <div class="property-optional">
                        </div>                        
                    </div>
                    <div class="col4 viewlink-area">                        
                        <h2>조회연동</h2>                        
                        <p class="information">기안 시 Legacy 데이터를 조회 후 바인딩 합니다.</p>
                        <h3>연동구분 : 
                            <select class="viewlink-type">
                                <option value="">선택</option>
                                <option value="D">DataBase</option>
                                <option value="W">WebService</option>
                                <option value="S">Sap</option>
                            </select>
                        </h3>
                        <div class="viewlink-type-database" style="display:none;">          
                            <h3>연결문자열</h3>                            
                            <textarea class="viewlink-type-database-connect">192.168.11.127:3306/covi_approval4j?user=root&password=P@ssw0rd</textarea>
                            <input type="button" class="viewlink-type-database-connect-button" value="조회" />
                            <h3>테이블목록 : 
                                <select class="viewlink-type-database-table">
                                    <option value="">선택</option>
                                </select>
                            </h3>
                            <h3>파라미터1&nbsp;&nbsp;:
                                <select class="viewlink-type-database-param1">
                                    <option value="">선택</option>
                                </select>                                                                
                            </h3>
                            <h3>파라미터2&nbsp;&nbsp;:
                                <select class="viewlink-type-database-param2">
                                    <option value="">선택</option>
                                </select>                                                                
                            </h3>
                            <h3>파라미터3&nbsp;&nbsp;:
                                <select class="viewlink-type-database-param3">
                                    <option value="">선택</option>
                                </select>                                                                
                            </h3>
                            <h3>파라미터4&nbsp;&nbsp;:
                                <select class="viewlink-type-database-param4">
                                    <option value="">선택</option>
                                </select>                                                                
                            </h3>
                            <h3>컬럼목록</h3>
                            <div id="viewlink-tool-database" class="toolbox">
                                <ul id="viewlink-database-ul"></ul>
                            </div>
                        </div>                        
                        <div class="viewlink-type-webservice" style="display:none;">          
                            <h3>웹서비스 URL</h3>                            
                            <textarea class="viewlink-type-webservice-connect">http://localhost:8080/approval/xform/getJSONList.do</textarea>
                            <input type="button" class="viewlink-type-webservice-connect-button" value="조회" />                            
                            <h3>함수목록&nbsp;&nbsp;&nbsp;: 
                                <select class="viewlink-type-webservice-table">
                                    <option value="">선택</option>
                                </select>
                            </h3>
                            <h3>파라미터1&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-webservice-param1" readonly="readonly"/>
                            </h3>
                            <h3>파라미터2&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-webservice-param2" readonly="readonly"/>
                            </h3>
                            <h3>파라미터3&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-webservice-param3" readonly="readonly"/>
                            </h3>
                            <h3>파라미터4&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-webservice-param4" readonly="readonly"/>
                            </h3>                       
                            <h3>컬럼</h3>
                            <div id="viewlink-tool-webservice" class="toolbox">
                                <ul id="viewlink-webservice-ul"></ul>
                            </div>
                        </div>         
                        <div class="viewlink-type-sap" style="display:none;">          
                            <h3>Destination :
                                <input type="text" class="viewlink-type-sap-connect" />                            
                            </h3>
                            <h3>Function&nbsp;&nbsp;&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-sap-table" />    
                            </h3>
                            <h3>파라미터1&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-sap-param1" />
                            </h3>
                            <h3>파라미터2&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-sap-param2" />
                            </h3>
                            <h3>파라미터3&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-sap-param3" />
                            </h3>
                            <h3>파라미터4&nbsp;&nbsp;:
                                <input type="text" class="viewlink-type-sap-param4" />
                            </h3>                       
                            <h3>컬럼</h3>
                            <div id="viewlink-tool-sap" class="toolbox">
                                <ul id="viewlink-sap-ul"></ul>
                            </div>
                        </div>        
                    </div>
                    <div class="col5 writelink-area">                        
                        <h2>저장연동</h2>                        
                        <p class="information">결재문서 최종 승인시 Legacy 연동 합니다.<br />연동오류 발생 시 최종 승인 되지 않습니다.</p>
                        <h3>연동구분 : 
                            <select class="writelink-type">
                                <option value="">선택</option>
                                <option value="D">DataBase</option>
                                <option value="W">WebService</option>
                                <option value="S">Sap</option>                                
                            </select>
                        </h3>
                        <div class="writelink-type-database" style="display:none;">    
                            <h3>연결문자열</h3>                            
                            <textarea class="writelink-type-database-connect">192.168.11.127:3306/covi_approval4j?user=root&password=P@ssw0rd</textarea>
                            <input type="button" class="writelink-type-database-connect-button" value="조회" />
                            <h3>테이블목록 : 
                                <select class="writelink-type-database-table">
                                    <option value="">선택</option>
                                </select>
                            </h3>                            
                            <h3>컬럼목록</h3>
                            <div id="writelink-tool-database" class="toolbox">
                                <ul id="writelink-database-ul"></ul>
                            </div>
                        </div>            
                        <div class="writelink-type-webservice" style="display:none;">          
                            <h3>웹서비스 URL</h3>                            
                            <textarea class="writelink-type-webservice-connect">http://localhost:8080/approval/xform/getJSONList.do</textarea>
                            <input type="button" class="writelink-type-webservice-connect-button" value="조회" />                            
                            <h3>함수목록&nbsp;&nbsp;&nbsp;: 
                                <select class="writelink-type-webservice-table">
                                    <option value="">선택</option>
                                </select>
                            </h3>                            
                            <h3>컬럼</h3>
                            <div id="writelink-tool-webservice" class="toolbox">
                                <ul id="writelink-webservice-ul"></ul>
                            </div>
                        </div>         
                        <div class="writelink-type-sap" style="display:none;">          
                            <h3>Destination :
                                <input type="text" class="writelink-type-sap-connect" />                            
                            </h3>
                            <h3>Function&nbsp;&nbsp;&nbsp;&nbsp;:
                                <input type="text" class="writelink-type-sap-table" />    
                            </h3>                            
                            <h3>컬럼</h3>
                            <div id="writelink-tool-sap" class="toolbox">
                                <ul id="writelink-sap-ul"></ul>
                            </div>
                        </div>            
                    </div>
                    <div class="col6 templatelink-area">
                        <!-- Column 6 start -->
                        <h2>템플릿</h2>                        
                        <p class="information">템플릿을 등록 및 적용합니다.</p>
                        
                        <div class="templatelink-type-template">          
                            <h3>템플릿명 : 
                                <input type="text" id="templatelink-template-name" />
                                <input type="button" id="templatelink-template-save" class="templatelink-template-save" value="저장" />
                            </h3>
                            <h3>템플릿목록</h3>
                            <div id="templatelink-tool" class="toolbox">
                                <ul id="templatelink-ul"></ul>
                            </div>
                        </div>
                        <!-- Column 6 end -->
                    </div>
                </div>
            </div>
            <div id="footer">
                <p>Powered by X FORM</p>
            </div>
            <div class="reference" style="display: none;">
                <div class="block_hover">
                    <div class="block_button" style="position: absolute; z-index: 999; background-color: #F5F5F5;">
                        <a href="javascript:void(0);" class="item_pinup" style="display: inline-block; background-color: #EFEFEF;">Edit Table</a>
                        <a href="javascript:void(0);" class="item_menu">Edit</a>
                        <a href="javascript:void(0);" class="item_delete">delete</a>
                    </div>
                </div>
            </div>
            <!----------------------
    System : Template 
------------------------>
            <div id="template" style="display: none;">
                <div data-field="div" data-info="DIV 기본 컨테이너">
                    <div class="xform-div"></div>
                </div>
                <div data-field="table" data-info="3행 3열의 기본 테이블">
                    <table class="table_10 tableStyle linePlus mt10">
                        <tbody>
                            <tr>
                                <td style="font-size : 14px">Head 1</td>
                                <td style="font-size : 14px">Head 2</td>
                                <td style="font-size : 14px">Head 3</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <!-- table template : end -->
                <div data-field="table1row2col" data-info="Label과 Input box로 구성된 1행 테이블">
                    <table class="table_10 tableStyle linePlus mt10">
                        <colgroup>
                            <col style="width: 12%;" />
                            <col style="width: 87%;" />
                        </colgroup>
                        <tbody>
                            <tr>
                                <th>Label</th>
                                <td>
                                    <input type="text" class="xform" style="width: 96%;" /></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div data-field="table1row2colselect" data-info="Label과 Select 로 구성된 1행 테이블">
                    <table class="table_10 tableStyle linePlus mt10">
                        <colgroup>
                            <col style="width: 12%;" />
                            <col style="width: 87%;" />
                        </colgroup>
                        <tbody>
                            <tr>
                                <th>Label</th>
                                <td>
                                    <select class="xform" data-element-type="sel_d_t" style="width: 60px">
                                        <option value="1">One</option>
                                        <option value="2">Two</option>
                                        <option value="3">Three</option>
                                    </select></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div data-field="table1row2colcheck" data-info="Label과 Checkbox로 구성된 1행 테이블">
                    <table class="table_10  tableStyle linePlus mt10">
                        <colgroup>
                            <col style="width: 12%;" />
                            <col style="width: 87%;" />
                        </colgroup>
                        <tbody>
                            <tr>
                                <th>Label</th>
                                <td>
                                    <label class="xform-checkbox" data-node-name="" data-type="mField" data-element-type="chk_d">
                                        <input type="checkbox" value="Red" text="Red" />Red
                                        <input type="checkbox" value="White" text="White" />White
                                        <input type="checkbox" value="Black" text="Black" />Black
                                    </label>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div data-field="table3col" data-info="5행 5열의 테이블 - 텍스트 박스 포함">
                    <table class="table_10 tableStyle linePlus mt10" cellspacing="0" cellpadding="0">
                        <colgroup>
                            <col style="width: 20%;" />
                            <col style="width: 20%;" />
                            <col style="width: 20%;" />
                            <col style="width: 20%;" />
                            <col style="width: 20%;" />
                        </colgroup>
                        <tbody>
                            <tr>
                                <th rowspan="4">출 장 자</th>
                                <th>부 서 명</th>
                                <th>성 명</th>
                                <th>직 위</th>
                                <th>비 고</th>
                            </tr>
                            <tr>
                                <td>
                                    <input id="user_dept_1" data-type="mField" value="{{ doc.BodyContext.user_dept_1 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_name_1" data-type="mField" value="{{ doc.BodyContext.user_name_1 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_pstn_1" data-type="mField" value="{{ doc.BodyContext.user_pstn_1 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_etc_1" data-type="mField" value="{{ doc.BodyContext.user_etc_1 }}" style="width: 95%; height: 20px;" type="text" /></td>
                            </tr>
                            <tr>
                                <td>
                                    <input id="user_dept_2" data-type="mField" value="{{ doc.BodyContext.user_dept_2 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_name_2" data-type="mField" value="{{ doc.BodyContext.user_name_2 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_pstn_2" data-type="mField" value="{{ doc.BodyContext.user_pstn_2 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_etc_2" data-type="mField" value="{{ doc.BodyContext.user_etc_2 }}" style="width: 95%; height: 20px;" type="text" /></td>
                            </tr>
                            <tr>
                                <td>
                                    <input id="user_dept_3" data-type="mField" value="{{ doc.BodyContext.user_dept_3 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_name_3" data-type="mField" value="{{ doc.BodyContext.user_name_3 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_pstn_3" data-type="mField" value="{{ doc.BodyContext.user_pstn_3 }}" style="width: 95%; height: 20px;" type="text" /></td>
                                <td>
                                    <input id="user_etc_3" data-type="mField" value="{{ doc.BodyContext.user_etc_3 }}" style="width: 95%; height: 20px;" type="text" /></td>
                            </tr>
                            <tr>
                                <th>출장지역</th>
                                <td colspan="4">
                                    <textarea id="t_area" data-type="mField" style="width: 98%; padding-right: 0px; padding-left: 0px; -ms-overflow-y: auto;" rows="3" cols="15">{{ doc.BodyContext.t_area }}</textarea>
                                </td>
                            </tr>
                            <tr>
                                <th>출장목적</th>
                                <td colspan="4">
                                    <textarea id="t_purpose" data-type="mField" style="width: 98%; padding-right: 0px; padding-left: 0px; -ms-overflow-y: auto;" rows="4" cols="15">{{ doc.BodyContext.t_purpose }}</textarea>
                                </td>
                            </tr>
                            <!--실 결재양식 내용 부분 끝 -->
                        </tbody>
                    </table>
                </div>
                <div data-field="multi_row_table" data-info="동적 테이블">
                    <table class="multi-row-table table_10 tableStyle linePlus mt10">
                        <colgroup>
                            <col style="width: 5%;" />
                            <col style="width: 40%;" />
                            <col style="width: 10%;" />
                            <col style="width: 15%;" />
                            <col style="width: 15%;" />
                            <col style="width: 15%;" />
                        </colgroup>
                        <tbody>
							<tr class="multi-row-control" data-mode="writeOnly">
								<td colspan="6" class="ui-sortable">
									<span style="float: right;"> 
										<input class="usa multi-row-add" type="button" value="+추가"> 
										<input class="usa multi-row-del-auto" type="button" value="-삭제"> 
									</span>
								</td>
							</tr>
                            <tr>
                                <th><input type="checkbox" class="multi-row-select-all"/></th>
                                <th>기간</th>
                                <th>일수</th>
                                <th>확인여부</th>
                                <th>사용여부</th>
                                <th>비고</th>
                            </tr>
                            <tr class="multi-row-template">
                                <td>
                                    <input type="checkbox" class="multi-row-selector" />
                                    <span class="multi-row-seq">1</span>
                                </td>
                                <td>
                                    <input type="text" name="_MULTI_VACATION_SDT" data-pattern="date" data-type="rField" />
                                    ~
                                    <input type="text" name="_MULTI_VACATION_EDT" data-pattern="date" data-type="rField" />
                                </td>
                                <td>
                                    <input type="text" name="_MULTI_DAYS" data-type="rField" style="width: 8px; border: 0px; text-align: right;" value="0" />일
                                </td>
                                <td>
                                    <label class="xform-radio" data-type="rField" data-element-type="rdo_d" data-node-name="">
                                        <input type="radio" data-face-for="yesno" data-element-type="rdo_d" value="Yes" text="Yes" />Yes
                                        <br/>
                                        <input type="radio" data-face-for="yesno" data-element-type="rdo_d" value="No" text="No" />No
                                        <input type="text" name="yesno" data-face-real="y" data-type="rField" style="display: none;" />
                                    </label>
                                </td>

                                <td>
                                    <label class="xform-checkbox" data-node-name="" data-type="rField" data-element-type="chk_d">
                                        <input type="checkbox" data-face-for="opt" value="use" text="use" />Use
                                        <br/>
                                        <input type="checkbox" data-face-for="opt" value="hide" text="hide" />Hide      
                                        <input type="text" name="opt" data-face-real="y" data-type="rField" style="display: none;" />
                                    </label>
                                </td>
                                <td>
                                    <select name="select" data-type="rField">
                                        <option value="First">First</option>
                                        <option value="Second">Second</option>
                                        <option value="Third">Third</option>
                                    </select>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div data-field="sum_table" data-info="합계 테이블">
                    <table class="table_10 tableStyle linePlus mt10 RowSumTable" id="tblVacInfo" cellpadding="0" cellspacing="0">
                        <colgroup>
                            <col style="width: 12%;" />
                            <col style="width: 13%;" />
                            <col style="width: 15%;" />
                            <col style="width: 15%;" />
                            <col style="width: 15%;" />
                            <col style="width: 15%;" />
                            <col style="width: 15%;" />
                        </colgroup>
                        <tbody>
                            <tr>
                                <th rowspan="4">예상경비</th>
                                <th>성명</th>
                                <th>교통비</th>
                                <th>숙박비</th>
                                <th>식비</th>
                                <th>잡비</th>
                                <th>합계</th>
                            </tr>
                            <tr>
                                <td>
                                    <input type="text" data-type="mField" id="a_user_name_1" value="{{ doc.BodyContext.a_user_name_1 }}" style="width: 98%;" value="Hong" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_11" value="{{ doc.BodyContext.a_cost_11 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_12" value="{{ doc.BodyContext.a_cost_12 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_13" value="{{ doc.BodyContext.a_cost_13 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_14" value="{{ doc.BodyContext.a_cost_14 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" id="a_cost_15" value="{{ doc.BodyContext.a_cost_15 }}" class="sum-table-rowsum" style="width: 98%;" readonly="readonly" /></td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="text" data-type="mField" id="a_user_name_2" value="{{ doc.BodyContext.a_user_name_2 }}" style="width: 98%;" value="Kang" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_21" value="{{ doc.BodyContext.a_cost_21 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_22" value="{{ doc.BodyContext.a_cost_22 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_23" value="{{ doc.BodyContext.a_cost_23 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_24" value="{{ doc.BodyContext.a_cost_24 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" id="a_cost_25" value="{{ doc.BodyContext.a_cost_25 }}" class="sum-table-rowsum" style="width: 98%;" readonly="readonly" /></td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="text" data-type="mField" id="a_user_name_3" value="{{ doc.BodyContext.a_user_name_3 }}" style="width: 98%;" value="Shin" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_31" value="{{ doc.BodyContext.a_cost_31 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_32" value="{{ doc.BodyContext.a_cost_32 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_33" value="{{ doc.BodyContext.a_cost_33 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_cost_34" value="{{ doc.BodyContext.a_cost_34 }}" class="sum-table-cell" style="width: 98%;" /></td>
                                <td>
                                    <input type="text" data-type="mField" id="a_cost_35" value="{{ doc.BodyContext.a_cost_35 }}" class="sum-table-rowsum" style="width: 98%;" readonly="readonly" /></td>
                            </tr>
                            <tr>
                                <th colspan="2">합계
                                    <input type="button" class="table-sum-button" data-mode="writeOnly" value="계산하기" /></th>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_sum_1" style="width: 98%;" value="{{ doc.BodyContext.a_sum_1 }}" class="sum-table-colsum" readonly="readonly" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_sum_2" style="width: 98%;" value="{{ doc.BodyContext.a_sum_2 }}" class="sum-table-colsum" readonly="readonly" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_sum_3" style="width: 98%;" value="{{ doc.BodyContext.a_sum_3 }}" class="sum-table-colsum" readonly="readonly" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_sum_4" style="width: 98%;" value="{{ doc.BodyContext.a_sum_4 }}" class="sum-table-colsum" readonly="readonly" /></td>
                                <td>
                                    <input type="text" data-type="mField" data-pattern="currency" id="a_sum_5" style="width: 98%;" value="{{ doc.BodyContext.a_sum_5 }}" class="sum-table-total" readonly="readonly" /></td>
                            </tr>
                        </tbody>
                    </table>
                </div>


                <div data-field="sum_multi_row_table" data-info="동적 합계 테이블">
                    <table class="multi-row-table table_10 tableStyle linePlus mt10  RowSumTable">
                        <colgroup>
                            <col style="width: 5%;"/>
                            <col style="width: 10%;"/>
                            <col style="width: 7%;"/>
                            <col style="width: 8%;"/>
                            <col style="width: 20%;"/>
                            <col style="width: 20%;"/>
                            <col style="width: 15%;"/>
                            <col style="width: 15%;"/>
                        </colgroup>
                        <tbody>
                            <tr class="multi-row-control" data-mode="writeOnly">
                                <td colspan="8">
                                    <em class="btn_iws_l" style="float: right">
                                        <span class="btn_iws_r multi-row-add">
                                            <strong class="txt_btn_ws">
                                                <img class="ico_btn" alt="" src="/approval/resources/images/xform/ico_plus.gif"/>추가
                                            </strong>
                                        </span>
                                    </em>
                                    <em class="btn_iws_l" style="float: right">
                                        <span class="btn_iws_r multi-row-del">
                                            <strong class="txt_btn_ws">
                                                <img class="ico_btn" alt="" src="/approval/resources/images/xform/ico_x.gif"/>삭제
                                            </strong>
                                        </span>
                                    </em>
                                </td>
                            </tr>
                            <tr>
                                <th><input type="checkbox" class="multi-row-select-all"/></th>
                                <th>성명</th>
                                <th>교통비</th>
                                <th>식사비</th>
                                <th>이동수단</th>
                                <th>조식</th>
                                <th>교통수단</th>
                                <th>합계</th>
                            </tr>
                            <tr class="multi-row-template">
                                <td>
                                   <input type="checkbox" class="multi-row-selector" style="text-align: center;"/>
                                    <span class="multi-row-seq">1</span>
                                </td>
                                <td>
                                    <input name="people_name" style="width: 98%;" type="text" data-type="rField"/>
                                </td>
                                <td>
                                    <input name="cost_traffic" class="sum-table-cell" style="width: 98%;" type="text" data-type="rField" data-pattern="currency"/>
                                </td>
                                <td>
                                    <input name="cost_meal" class="sum-table-cell" style="width: 98%;" type="text" data-type="rField" data-pattern="currency"/>
                                </td>
                                <td>
                                    <label class="xform-radio" data-type="rField" data-element-type="rdo_d" data-node-name="">
                                        <input type="radio" data-face-for="yesno" data-element-type="rdo_d" value="기차" data-text="기차" />기차
                                        <br/>
                                        <input type="radio" data-face-for="yesno" data-element-type="rdo_d" value="비행기" data-text="비행기" />비행기
                                        <input type="text" name="yesno" data-face-real="y" data-type="rField" style="display: none;" />
                                    </label>
                                </td>

                                <td>
                                    <label class="xform-checkbox" data-node-name="" data-type="rField" data-element-type="chk_d">
                                        <input type="checkbox" data-face-for="opt" value="시리얼" data-text="시리얼" />시리얼
                                        <br/>
                                        <input type="checkbox" data-face-for="opt" value="토스트" data-text="토스트" />토스트      
                                        <input type="text" name="opt" data-face-real="y" data-type="rField" style="display: none;" />
                                    </label>
                                </td>

                                <td>
                                    <select name="select" data-type="rField">
                                        <option value="자전거">자전거</option>
                                        <option value="자가용">자가용</option>
                                        <option value="버스">버스</option>
                                    </select>
                                </td>
                                <td>
                                    <input type="text" data-type="rField" name="cost_row_total" class="sum-table-rowsum" style="width: 98%;" readonly="readonly" data-pattern="currency" />
                                </td>
                            </tr>
                            <tr>
                                <th colspan="2">합계
                                    <input class="table-sum-button" type="button" value="계산하기" data-mode="writeOnly"/>
                                </th>
                                <td>
                                    <input class="sum-table-colsum" id="cost_col_total1" style="width: 98%;" type="text" readonly="readonly" value="{{ doc.BodyContext.cost_col_total1 }}" data-type="mField" data-pattern="currency"/>
                                </td>
                                <td>
                                    <input class="sum-table-colsum" id="cost_col_total2" style="width: 98%;" type="text" readonly="readonly" value="{{ doc.BodyContext.cost_col_total2 }}" data-type="mField" data-pattern="currency"/>
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td>
                                    <input class="sum-table-total" id="cost_all_total" style="width: 98%;" type="text" readonly="readonly" value="{{ doc.BodyContext.cost_all_total }}" data-type="mField" data-pattern="currency"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div data-field="jqgrid" data-info="JqGrid">
                    <div>
                        <table id="tblJqgrid" class="cas-data-grid" border="0" cellspacing="0" cellpadding="0"></table>
                        <div id="pager"></div>
                    </div>
                </div>
            </div>
            <!----------------------
                System : Modal 
            ------------------------>
            <div id="property_popup" class="xform-overlay">
                <div class="header">
                    <h2>속성 추가/편집창</h2>
                    <a class="modal_close" href="javascript: void(0);"></a>
                </div>
                <div class="content">
                    <table style="width: 95%">
                        <colgroup>
                            <col style="width: 17%;" />
                            <col style="width: 83%;" />
                        </colgroup>
                        <tbody>
                            <tr class="attr-container attr-container-type">
                                <td>Tag[type]</td>
                                <td><span data-field-id="type" class="xform-builder"></span>
                                    <label style="display: none;">
                                        <input type="checkbox" id="show_html" />show html</label>
                                </td>
                            </tr>
                            <tr class="attr-container attr-container-id">
                                <td>ID</td>
                                <td>
                                    <input type="text" name="id" data-field-id="id" class="xform-builder input-50" value="xformid_4" style="float: left;" />
                                    <button class="apply_all">모두적용</button>
                                </td>
                            </tr>
                            <tr class="attr-container attr-container-name">
                                <td>Name</td>
                                <td>
                                    <input type="text" name="name" data-field-id="name" class="xform-builder input-50" value="" /></td>
                            </tr>
                            <tr class="attr-container attr-container-name">
                                <td>Value</td>
                                <td>
                                    <input type="text" name="value" data-field-id="value" class="xform-builder input-100" value="" /></td>
                            </tr>
                            <tr class="attr-container attr-container-class">
                                <td>Class</td>
                                <td>
                                    <input type="text" name="class" data-field-id="class" class="xform-builder input-100" value="" /></td>
                            </tr>
                            <tr class="attr-container attr-container-style">
                                <td>Style</td>
                                <td>
                                    <input type="text" name="style" data-field-id="style" class="xform-builder input-100" value="" /></td>
                            </tr>
                            <tr class="attr-container attr-container-href">
                                <td>Href</td>
                                <td>
                                    <input type="text" name="href" data-field-id="href" class="xform-builder input-100" value="" /></td>
                            </tr>
                            <tr class="attr-container attr-container-target">
                                <td>Target</td>
                                <td>
                                    <select name="target" data-field-id="target" class="xform-builder">
                                        <option value="_blank">New Window</option>
                                        <option value="self">This Window</option>
                                    </select>
                                    * A 태그를 클릭시 새창을 띄울 것인지, 같은 창에서 이동할 것인지 선택합니다.
                                </td>
                            </tr>
                            <tr class="attr-container attr-container-data-node-name">
                                <td>Data-node-name</td>
                                <td>
                                    <input type="text" name="data-node-name" data-field-id="data-node-name" class="xform-builder input-50" value="" /></td>
                            </tr>
                            <tr class="attr-container attr-container-option">
                                <td>Option</td>
                                <td>
                                    <!-- Option Selector -->
                                    <div data-field-id="options" class='selectBox'>
                                        <span class='selected'></span>
                                        <span class='selectArrow'>
                                            <!--&#9660-->
                                            <span style="move">
                                                <label class="new_option">new option</label></span>
                                        </span>
                                        <div class="selectOptions">
                                            <span class="selectHelp">Collapse/Expand</span>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr class="attr-container attr-container-html">
                                <td>HTML</td>
                                <td>
                                    <div>
                                        <label>
                                            <input name="attr_disp_opt" type="radio" value="textarea" checked />
                                            <span>textarea</span></label>
                                        <label>
                                            <input name="attr_disp_opt" type="radio" value="html" />
                                            <span>editor</span></label>
                                    </div>
                                    <textarea name="html" data-field-id="html" class="xform-builder input-100" style="width: 90%; height: 50px;"></textarea></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="control">
                    <div class="btn-fld">
                        <button class="cancel">취소 »</button>
                        <button class="ok">적용 »</button>
                    </div>
                </div>
            </div>
            <div id="modal_popup_content" class="xform-overlay">
                <div class="modal-header header">
                    <h2 class="title">Title</h2>
                    <p class="subtitle">Sub Title</p>
                    <a class="modal_close" href="javascript: void(0);"></a>
                </div>
                <div class="modal-content">
                    <!-- content -->
                </div>
            </div>
            <!-- <div id="multirowView" class="view-mode" style="width: 600px;position: absolute;top: 193px;left: 310px;">
				<div class="snippet-container" style="undefined;">
					<div class="sh_kwrite snippet-wrap">
						<pre class="htmlCode sh_html snippet-formatted sh_sourceCode">
							<ol class="snippet-num">
								<li><span class="sh_comment">&lt;!--실 결재양식 내용 부분 시작 --&gt;</span></li>
								<li><span style="display:none;">&nbsp;</span></li>
								<li><span class="sh_comment">&lt;!--실 결재양식 내용 부분 끝 --&gt;</span></li>
								<li><span class="sh_keyword">&lt;table</span> <span class="sh_type">class</span><span class="sh_symbol">=</span><span class="sh_string">"table_10 tableStyle linePlus mt10"</span></li>
								<li>&nbsp;&nbsp;&nbsp;&nbsp;<span class="sh_keyword">&lt;colgroup&gt;</span></li>
							</ol>
						</pre>
					</div>
				</div>
			</div> -->

            <!-- table row and col setting -->
            <div id="table_resize" class="xform-overlay">
                <div>
                    <div class="header">
                        <h2 class="title">Create a table</h2>
                        <p class="subtitle">슬라이더를 이동하여 행과 열의 개수를 선택하세요.</p>
                        <a class="table_modal_close" href="javascript: void(0);"></a>
                    </div>

                    <div class="txt-fld">
                        <label for="">Rows</label>
                        <input type="range" id="rows" name="rows" min="1" max="30" value="5" />
                        <span id="newValue" value="0" style="font-size: 16px; font-weight: bold; color: #777;">0</span>

                    </div>
                    <div class="txt-fld">
                        <label for="">Columns</label>
                        <input type="range" id="cols" name="cols" min="1" max="30" value="3"><span id="newValue2" value="0" style="font-size: 16px; font-weight: bold; color: #777;">0</span>
                    </div>
                    <div id="table_content" class="txt-fld">
                    </div>
                    <div class="btn-fld">
                        <button class="cancel">취소 »</button>
                        <button class="ok">적용 »</button>
                    </div>

                </div>
            </div>
            <!-- html editor -->
            <div id="html_editor" class="xform-overlay">
                <div class="header">
                    <h2>속성 추가/편집창</h2>
                    <p>It's simple</p>
                    <a class="modal_close" href="javascript: void(0);"></a>
                </div>
                <div class="content">
                    html editor  
            <textarea id="html_editor_jqte" style="width: 99%; height: 200px; margin-top: 10px; margin: auto;"></textarea>
                </div>
                <div class="control">
                    <div class="btn-fld">
                        <button class="cancel">취소 »</button>
                        <button class="ok">적용 »</button>
                    </div>
                </div>
            </div>

            <!----------------------
                System : Data 
            ------------------------>
            <div id="system_data" style="display: none;">
                <input type="checkbox" class="edit-table" />
                <input id="object_id" />
            </div>
            <div id="clipboard" style="display: none;"></div>
            <div class="table-panel" style="position: absolute;">
                <ul class="table-mode-control" style="display: inline; list-style-type: none;">
                    <li style="display: inline; float: left;"><a href="javascript: void(0);" class="cell-merge table-mode tooltip" title="Merge" />
                        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABNElEQVRIS2NkoDFgBJnf3t6+gJGR0Zladv3//39vZWVlNtC8n2ALOjo6HkdGRsogW3Dq1CkGMzMzFDuJETt69CjDo0ePnlRUVNgANb9FseD58+dwA2/dusWgpqaGYgExYvfu3YNZ4AbU/JyWFngCLXhKPwuUlZVlvn//TnE8P3nyhIGJiQkUB15Aw57g9UFAQADJFl6/fp1h//79oxbgDjmcQYQtkkfjYJglU7pE8rNnz1BKU3JS0bVr1xgOHjyIPScPCQtu3LiBuyw6ffo0A7DqZPj79y+o0mBwcHBgYGVlBYv9+fOHgYWFheHXr19YxWBh++LFC4YrV66gBhGN6uQ2oKUvwMU1EHADsSiUBonBxEkuroEa/gPxLyD+BsQfYAaxAjnsQMxCoeEwB/0FMv4B8U8A4w+IiKdzBHwAAAAASUVORK5CYII=" />
                    </li>
                    <li style="display: inline; float: left;"><a href="javascript: void(0);" class="cell-split-v table-mode tooltip" title="split vertically" />
                        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABmElEQVRIS+2WTWqDUBDHR0MXpXQt5ARZKdllVwSXpTS5gMtuXJszeIGcoN0Y0E3QTSD0BIEcoC39oi5UiIG2hMbOSAx+JUWr0EUf/Hm+0Tc/hzfOyEDDg0n4p+vsugo+3G6iOYwdMpqm3aDhrIrHzJ7b4XB4hbZP1DoGsAh4UlW1nQVMJhPgeT7Hnc1mIMtyyr5arWA0Gr0iQMQbDirIAYIgSG2ybRs6nU4OMJ/PYTAYpOyu64Ku6wS4wBsPKD8GtDCCR4qgJsAlOr9vEkCh3aG8piIoBnAclzvkslnlOA6dQbkIer1eYRYdOORygApZ9A8A+OFD+0NZZBgGiCKVlvSgWlRLFhGg2+2WrUX7s2i5XKacmaa5F9Dv93PFbjweH/7QfgPwPC+upsURKIrS9n0/eqvNZgMsy8J0OgVBECJbGIbAMEw0LxYLkCQpeo7WNOjlLMuiCM5x+ZwsdtRwrtFQV0fT0NdLslyzuDhBUbE7RbXKFrnE8x94TXpD7Toale0j1PF2Tjb/sqwv3EB6R+16Mjlp5K/iGwbyhmDWLoIUAAAAAElFTkSuQmCC" />
                    </li>
                    <li style="display: inline; float: left;"><a href="javascript: void(0);" class="cell-split-h table-mode tooltip" title="split horizontally" />
                        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABkUlEQVRIS+2WQWqDUBCGn6bdtPQCWbn2BAEXpbsIUkpX3qAb10boCbyAJ2ghJFtJsi0ieICuW2mh2EUUVGyhVTvT1BJ9L4XGSDcN/Jj8+OZzXubNyJGOP9xafPze/L0NvvxahNeyCsiZpnkNxvE2ERtrbkaj0QV4r6D3CsAD4FHX9X4TYNs2URSF4rL8NE2JZVlPADiBBc+ghAIkSVILNp/PiSzLFIDlL5dLMplMEHAKC3xQVAF6kMEDZrAjwBkEv+8ScA7B70BhVxmwAaIo9rMsa1VIvu/jf8AGqKpKVZHneWQwGFDQTf54PP4ZEARBLRg8EREEgQKw/DzPieM4/4DVbm21RZ1X0Q5P8h8dNMwgjuNaSS4WCzIcDqkyZfnY7KbT6eYybQsIw7Dqpuwt0jStH0XR59MWRUF4nieu6xJJkmoeHig8yejjfWW5GmKY/Ww2Y2aAA+cK7mk90QB2axjGZXMe8GAcgrAXHYF6LTpeDmtxamHP+Z5o2Lb3QAegfdD68P8tC/frDfSC187fKj4AzAuJYLP0h3kAAAAASUVORK5CYII=" />
                    </li>
                    <li style="display: inline; float: left;"><a href="javascript: void(0);" class="cell-row-insert table-mode text-button tooltip" title="increase rows">row +</a></li>
                    <li style="display: inline; float: left;"><a href="javascript: void(0);" class="cell-row-delete table-mode text-button tooltip" title="decrease rows">row -</a></li>
                    <li style="display: inline; float: left;"><a href="javascript: void(0);" class="cell-col-insert table-mode text-button tooltip" title="increase columns">column +</a></li>
                    <li style="display: inline; float: left;"><a href="javascript: void(0);" class="cell-col-delete table-mode text-button tooltip" title="decrease columns">column -</a></li>
                    <li style="display: inline; float: left;"><a href="javascript: void(0);" class="cell-col-close table-mode text-button tooltip" title="close">X</a></li>
                </ul>
            </div>
            <div id="container_panel" class="container-panel"><span class="container-type">T</span><span class="element-mode element-movable tooltip tooltipstered" title="이동"></span><span class="element-mode element-editable tooltip tooltipstered" title="편집"></span><span class="element-mode element-table-edit tooltip tooltipstered" title="테이블 편집"></span><a href="javascript: void(0);" class="container-control" title="더보기"></a></div>
            <div id="element_css" class="element-panel">
                <div class="drag-handle" style="cursor: move; position: absolute; top: -22px; right: 5px; height: 20px; width: 100px; border-top-left-radius: 5px; border-top-right-radius: 5px; background-color: #EAEAEA; border-left: solid 1px #aaa; border-top: solid 1px #aaa; border-right: solid 1px #aaa;">
                    <label style="margin: 3px;">
                        <input type="checkbox" class="tool-fixed" />Fix</label>
                </div>
                <div class="fg-toolbar ui-widget-header ui-corner-all ui-helper-clearfix">

                    <div class="fg-buttonset ui-helper-clearfix">
                        <span>Font: </span>
                        <select id="styler_font_size" class="css-tool-select css-tool-single" data-style-key="font-size" data-style-value="12px" style="height: 26px; !important; margin-top: 1px;"></select>px
                    </div>
                    <div class="fg-buttonset fg-buttonset-single">
                        <a class="fg-button canvas-set-style ui-state-default ui-priority-primary ui-corner-left css-tool-single" data-style-key="text-align" data-style-value="left">L</a>
                        <a class="fg-button canvas-set-style ui-state-default ui-priority-primary css-tool-single" data-style-key="text-align" data-style-value="center">C</a>
                        <a class="fg-button canvas-set-style ui-state-default ui-priority-primary ui-corner-right css-tool-single" data-style-key="text-align" data-style-value="right">R</a>
                    </div>
                    <div class="fg-buttonset fg-buttonset-multi">
                        <a href="javascript: void(0);" class="fg-button canvas-set-style ui-state-default ui-corner-left css-tool-single" data-style-key="font-weight" data-style-value="bold" data-style-toggle="true"><b>B</b></a>
                        <a href="javascript: void(0);" class="fg-button canvas-set-style ui-state-default css-tool-single" data-style-key="font-style" data-style-value="italic" data-style-toggle="true"><i>I</i></a>
                        <a href="javascript: void(0);" class="fg-button canvas-set-style ui-state-default ui-corner-right css-tool-single" data-style-key="text-decoration" data-style-value="underline" data-style-toggle="true"><u>U</u></a>
                    </div>
                    <div class="fg-buttonset ui-helper-clearfix">
                        <a href="javascript: void(0);" class="fg-button canvas-set-style ui-state-default fg-button-icon-solo ui-corner-all" title="Duplicate"><span class="ui-icon ui-icon-copy css-tool-copy"></span>Duplicate</a>
                        <a href="javascript: void(0);" class="fg-button canvas-set-style ui-state-default fg-button-icon-solo ui-corner-all" title="Delete"><span class="ui-icon ui-icon-trash css-tool-trash"></span>Delete</a>
                        <a href="javascript: void(0);" class="fg-button canvas-set-style ui-state-default fg-button-icon-solo ui-corner-all" title="Edit"><span class="ui-icon ui-icon-gear css-tool-gear"></span>Edit</a>
                        <a href="javascript: void(0);" class="fg-button canvas-set-style ui-state-default fg-button-icon-solo ui-corner-all" title="Save"><span class="ui-icon ui-icon-disk css-tool-disk"></span>Save</a>
                        <a href="javascript: void(0);" class="fg-button canvas-set-style ui-state-default fg-button-icon-solo ui-corner-all" title="Code"><span class="ui-icon ui-icon-info css-tool-info"></span>Code</a>
                        <a href="javascript: void(0);" class="fg-button ui-state-default ui-corner-left ui-corner-right  css-tool-close">Close</a>
                    </div>
                    <div class="element-width-style" style="clear: both; display: block;">
                        <span>Width: </span><a href="javascript:void(0);" class="width-minus ui-icon ui-icon-minus" style="display: inline-block; vertical-align: middle; opacity: 0.6"></a>
                        <input class="slide-width" data-style-key="width" data-style-value="" data-style-suffix="y" type="range" id="Range1" name="cols" min="1" max="1600" value="5" />
                        <span class="slide-width-max">100</span>
                        <a href="javascript:void(0);" class="width-plus ui-icon ui-icon-plus" style="display: inline-block; vertical-align: middle; opacity: 0.6"></a>
                        <input class="manual-width" data-style-for="prev" style="width: 40px; margin: 0 5px;" />
                        <select class="width-style">
                            <option value="px">px</option>
                            <option value="em">em</option>
                            <option value="pt">pt</option>
                            <option value="%">%</option>
                        </select>
                    </div>
                </div>
            </div>

            <!----------------------
    System : Table Edit
------------------------>
            <div id="system_ui" style="display: none;">
                <p class="table-mode-option" style="border: solid 1px #ACACAC; padding: 5px 10px;">
                    <label>Select Mode: </label>
                    <label for="table_opt_1" class="table-opt">
                        <input type="radio" id="table_opt_1" name="table_option" value="cell-merge" disabled="disabled" />Merge/Split</label>
                    <label for="table_opt_2" class="table-opt">
                        <input type="radio" id="table_opt_2" name="table_option" value="row-move" disabled="disabled" />Move Row/Column</label>
                    <label for="table_opt_4" class="table-opt">
                        <input type="radio" id="table_opt_" name="table_option" value="column-resize" disabled="disabled" />Column Resize</label>
                </p>
                <p class="table-mode-control" style="display: none; border: solid 1px #ACACAC; padding: 5px 3px;">
                    <a id="table_design" href="#table_resize" rel="leanModal" style="display: none;">Modal</a>
                    <a id="modal_popup" href="#property_popup" rel="leanModal" style="display: none;">Modal2</a>
                    <a id="modal_content" href="#modal_popup_content" rel="leanModal" style="display: none;">Content Modal</a>
                    <a id="html_popup" href="#html_editor" rel="leanModal" style="display: none;">Content Modal</a>
                    <a id="modal_magic" href="#modal_magic_popup" rel="leanModal" style="display: none;">Magic Modal</a>
                </p>

            </div>
            <div id="loader"></div>
            <div id="alerts">파일이 존재하지 않습니다.</div>

            <!----------------------
            System : jQuery Core
            ------------------------>

            <link rel="stylesheet" type="text/css" href="/approval/resources/css/xform/jquery-ui-themes-1.8.18/themes/smoothness/jquery-ui.css<%=resourceVersion%>" />
            <script src="/approval/resources/script/xform/jquery.cookie.js<%=resourceVersion%>"></script>

            <!----------------------
            System : Ext. Script 
            ------------------------>
            <script type="text/javascript" src="/approval/resources/script/xform/xform-leanModal.min.js<%=resourceVersion%>"></script>
            <!-- code highlight -->
            <link rel="stylesheet" type="text/css" href="/approval/resources/css/xform/xform-snippet.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/xform-snippet.js<%=resourceVersion%>"></script>
            <script src="/approval/resources/script/xform/xform-contextMenu.js<%=resourceVersion%>"></script>
            <link rel="stylesheet" href="/approval/resources/css/xform/xform-contextMenu.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/xform-mousetrap.js<%=resourceVersion%>"></script>
            <!-- table manipulation -->
            <script type="text/javascript" src="/approval/resources/script/xform/xform-redips-table.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/xform-tablednd.js<%=resourceVersion%>"></script>
<%--             <script type="text/javascript" src="/approval/resources/script/xform/xform-colResizable.js<%=resourceVersion%>"></script> --%>
            <script type="text/javascript" src="/approval/resources/script/xform/colResizable-1.6.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/xform-tablehighlight.js<%=resourceVersion%>"></script>
            <!-- <script type="text/javascript" src="/approval/resources/script/xform/xform-dragtable.js<%=resourceVersion%>"></script> : contenteditable conflict-->

            <link rel="stylesheet" type="text/css" href="/approval/resources/css/xform/tooltipster.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/jquery.tooltipster.js<%=resourceVersion%>"></script>


            <!-- html editor -->
            <link rel="stylesheet" type="text/css" href="/approval/resources/script/xform/jquery-te-1.4.0.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/jquery-te-1.4.0.js<%=resourceVersion%>"></script>

            <!-- [2016-02-18 leesm] code mirror add -->
            <link rel="stylesheet" type="text/css" href="/approval/resources/script/xform/codemirror/codemirror.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/codemirror.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/mode/xml.js<%=resourceVersion%>"></script>
            <%--<script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/codemirror-dialog.js<%=resourceVersion%>"></script>--%>

            <link rel="stylesheet" type="text/css" href="/approval/resources/script/xform/codemirror/addon/display/fullscreen.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/display/fullscreen.js<%=resourceVersion%>"></script>

            <link rel="stylesheet" type="text/css" href="/approval/resources/script/xform/codemirror/addon/hint/show-hint.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/hint/show-hint.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/hint/html-hint.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/hint/javascript-hint.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/hint/xml-hint.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/hint/css-hint.js<%=resourceVersion%>"></script>
            
            <!-- [2016-04-08 leesm] 검색 기능 추가 -->
            <link rel="stylesheet" type="text/css" href="/approval/resources/script/xform/codemirror/addon/search/matchesonscrollbar.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/search/searchcursor.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/search/search.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/scroll/annotatescrollbar.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/search/matchesonscrollbar.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/search/jump-to-line.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/scroll/annotatescrollbar.js<%=resourceVersion%>"></script>

            <link rel="stylesheet" type="text/css" href="/approval/resources/script/xform/codemirror/addon/dialog/dialog.css<%=resourceVersion%>" />
            <script type="text/javascript" src="/approval/resources/script/xform/codemirror/addon/dialog/dialog.js<%=resourceVersion%>"></script>
            


            <!-- html5 storage -->
            <script type="text/javascript" src="/approval/resources/script/xform/xform-jStorage.js<%=resourceVersion%>"></script>

            <!----------------------
            System : Core Script 
            ------------------------>
            <script type="text/javascript" src="/approval/resources/script/xform/xform.0.9.6.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/xform.ui.0.9.5.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/xform.xstorage.js<%=resourceVersion%>"></script>
            <script type="text/javascript" src="/approval/resources/script/xform/xform-load.js<%=resourceVersion%>"></script>
            <!----------------------
            System : Hidden 
            ------------------------>
            <input type="hidden" ID="hidFormList" Value=""/>
            <input type="hidden" ID="hidFormId"/>
            <input type="hidden" ID="hidFilename"/>
            <input type="hidden" ID="hidJsFilename"/>
            <input type="hidden" ID="hidFormversion"/>

        </div>
        <!-- Wrapper : End -->
    </form>
</body>
</html>
<script>
    var g_template_version = 'new'; //template version
    var tableDnD = new TableDnD(); //table row drag
    var editor;
    var js_editor;
    var param = location.search.substring(1).split('&');
	var formID =param[0].split('=')[1];
	
    
    $(document.body).ready(function () {
    	getFormList(); //	$("#hidFormList") 값 세팅
    	$("#hidFormId").val(formID);
	});
	
	$(window).load(function(){
		//main init - must be placed in last
        xform.init();

        //html editor initialize
        $('#html_editor_jqte').jqte();

        //loading spin
        XFORM.loader.hide();
	});
  

	function getFormList(){
		$.ajax({
			type:"POST",
			url:"xform/getFormList.do",
			async: false,
			success:function (data) {
				if(data.result=="ok"){
					$("#hidFormList").val(JSON.stringify(data.list));
				}
			},
			error:function (error){
				alert(error.message);
			}
		});
	}
	
    // [2016-02-18 leesm] code mirror add
    function editCode(that) {
        if (!$(that).is(':checked')) {            
            if (editor || js_editor) {
                editor.toTextArea();
                js_editor.toTextArea();
            }            
            XFORM.layout.codePanel.hide();
        } else {
            XFORM.layout.codePanel.show();

            $('#canvas table').destroyTableResizable();
            $('#demotext').val($('#canvas').html());
            XFORM.form.tableResizable(null, "ALL");
            
            editor = CodeMirror.fromTextArea(document.getElementById("demotext"), {
                lineNumbers: true,
                mode: "text/html",
                htmlMode: true,
                matchBrackets: true,
                extraKeys: {
                    "F11": function (cm) {
                        cm.setOption("fullScreen", !cm.getOption("fullScreen"));
                    },
                    "Esc": function (cm) {
                        if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
                    },
                    "Ctrl-Space": "autocomplete"
                }
            });

            editor.on("changes", function (cm, change) {
                var v = cm.getValue();
                $('#canvas').empty();
                XFORM.template.loadToCanvas('', v, $('#canvas_js').val()); // [16-03-31] kimhs, js내용 파라미터 추가
                XFORM.form.tableResizable(null, "ALL");
            });


            $('#demotext_js').val($('#canvas_js').val());
            js_editor = CodeMirror.fromTextArea(document.getElementById("demotext_js"), {
                lineNumbers: true,
                mode: { name: "javascript", globalVars: true },
                htmlMode: true,
                matchBrackets: true,
                extraKeys: {
                    "F11": function (cm) {
                        cm.setOption("fullScreen", !cm.getOption("fullScreen"));
                    },
                    "Esc": function (cm) {
                        if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
                    },
                    "Ctrl-Space": "autocomplete"
                }
            });

            js_editor.on("changes", function (cm, change) {
                var v = cm.getValue();
                $('#canvas_js').empty();
                XFORM.template.loadToCanvas('', $('#canvas').html(), v);
            });
        }
    }

    function getCompletions(token, context) {
        var found = [], start = token.string;
        function maybeAdd(str) {
            if (str.indexOf(start) == 0) found.push(str);
        }
        function gatherCompletions(obj) {
            if (typeof obj == "string") forEach(stringProps, maybeAdd);
            else if (obj instanceof Array) forEach(arrayProps, maybeAdd);
            else if (obj instanceof Function) forEach(funcProps, maybeAdd);
            for (var name in obj) maybeAdd(name);
        }

        if (context) {
            // If this is a property, see if it belongs to some object we can
            // find in the current environment.
            var obj = context.pop(), base;
            if (obj.className == "js-variable")
                base = window[obj.string];
            else if (obj.className == "js-string")
                base = "";
            else if (obj.className == "js-atom")
                base = 1;
            while (base != null && context.length)
                base = base[context.pop().string];
            if (base != null) gatherCompletions(base);
        }
        else {
            // If not, just look in the window object and any local scope
            // (reading into JS mode internals to get at the local variables)
            for (var v = token.state.localVars; v; v = v.next) maybeAdd(v.name);
            gatherCompletions(window);
            forEach(keywords, maybeAdd);
        }
        return found;
    }
</script>
