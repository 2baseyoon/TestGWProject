<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!-- 컨텐츠앱 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
	<script type="text/javascript" src="<%=cssPath%>/contentsApp/resources/js/contentsApp.js"></script>
	
<div id='wrap'>
		<section id='ca_container'>
			<div class='commContLeft contentsAppLeft'>
				<div class='cLnbTop'>
					<h2>컨텐츠 앱</h2>
					<div>
						<a href="#" class="btnType01">컨텐츠 앱 만들기</a>
						<a href="#" class="btnType01 btnBlueBoder">컨텐츠 앱 스토어</a>
					</div>
				</div>
				<div class='cLnbMiddle mScrollV scrollVType01'>
					<div>
						<ul id="leftmenu" class="contLnbMenu contentsAppMenu">
							<li class="caMenu01">
								<a href="javascript:;" onclick="" class="">즐겨찾는 앱</a>
							</li>
							<li>
								<div id="coviTree_FolderMenu" class="treeList radio">
									<a id="coviTree_FolderMenu_AX_tree_focus"></a>
									<div class="AXTree_none" id="coviTree_FolderMenu_AX_tree" style="">
										<div class="AXTreeScrollBody" id="coviTree_FolderMenu_AX_treeScrollBody" style="z-index:2;">
											<div class="AXTreeColHead AXUserSelectNone" id="coviTree_FolderMenu_AX_treeColHead" onselectstart="return false;" style="display: none; width: 279px;"></div>
											<div class="AXTreeBody" id="coviTree_FolderMenu_AX_treeBody" style="top: 0px;">
												<div id="coviTree_FolderMenu_AX_scrollContent" class="treeScrollContent" style="width: 279px; left: 0px; top: 0px;">
													<table cellpadding="0" cellspacing="0" class="treeBodyTable" style="">
														<colgroup>
															<col width="100%" style="" id="coviTree_FolderMenu_AX_col_AX_0_AX_CB">
														</colgroup>
														<thead id="coviTree_FolderMenu_AX_thead"></thead>
														<tbody id="coviTree_FolderMenu_AX_tbody">
															<tr class="gridBodyTr gridBodyTr_0 line0 parentHash000 " id="coviTree_FolderMenu_AX_tr_0_AX_n_AX_0" style="">
																<td valign="middle" style="vertical-align:middle;" id="coviTree_FolderMenu_AX_nbody_AX_0_AX_0_AX_0" class="bodyTd">
																	<div class="tdRelBlock" title="">
																		<div class="bodyNode bodyTdText" style="padding-left:46px;" align="left" id="coviTree_FolderMenu_AX_bodyText_AX_0_AX_0_AX_0">
																			<span class="connectionLineContainer"></span>
																			<a class="bodyNodeIndent expand" id="coviTree_FolderMenu_AX_bodyNodeIndent_AX_0_AX_0_AX_0" style="left:3px;"></a>
																			<a class="bodyNodeIcon board_root" id="coviTree_FolderMenu_AX_bodyNodeIcon_AX_0_AX_0_AX_0" style="left: 23px; display: block;"></a>
																			<a id="folder_item_6487" type="board_Root">코비젼</a>
																		</div>
																	</div>
																</td>
															</tr>
															<tr class="gridBodyTr gridBodyTr_1 line1 parentHash000_000" id="coviTree_FolderMenu_AX_tr_0_AX_n_AX_1" style="">
																<td valign="middle" style="vertical-align:middle;" id="coviTree_FolderMenu_AX_nbody_AX_0_AX_0_AX_1" class="bodyTd">
																	<div class="tdRelBlock" title="">
																		<div class="bodyNode bodyTdText" style="padding-left:66px;" align="left" id="coviTree_FolderMenu_AX_bodyText_AX_0_AX_0_AX_1">
																			<span class="connectionLineContainer">
																				<span class="connectionLine " style="left:3px;width:20px;"></span>
																			</span>
																			<a class="bodyNodeIndent expand" id="coviTree_FolderMenu_AX_bodyNodeIndent_AX_0_AX_0_AX_1" style="left:23px;"></a>
																			<a class="bodyNodeIcon board_folder" id="coviTree_FolderMenu_AX_bodyNodeIcon_AX_0_AX_0_AX_1" style="left: 43px; display: block;"></a>
																			<a id="folder_item_6489" type="board_Folder">지원</a>
																		</div>
																	</div>
																</td>
															</tr>
															<tr class="gridBodyTr gridBodyTr_2 line0 parentHash000_000_000" id="coviTree_FolderMenu_AX_tr_0_AX_n_AX_2" style="">
																<td valign="middle" style="vertical-align:middle;" id="coviTree_FolderMenu_AX_nbody_AX_0_AX_0_AX_2" class="bodyTd">
																	<div class="tdRelBlock" title="">
																		<div class="bodyNode bodyTdText" style="padding-left:86px;" align="left" id="coviTree_FolderMenu_AX_bodyText_AX_0_AX_0_AX_2">
																			<span class="connectionLineContainer">
																				<span class="connectionLine isParentInside" style="left:3px;width:20px;"></span>
																				<span class="connectionLine " style="left:23px;width:20px;"></span>
																			</span>
																			<a class="bodyNodeIndent noChild" id="coviTree_FolderMenu_AX_bodyNodeIndent_AX_0_AX_0_AX_2" style="left:43px;"></a>
																			<a class="bodyNodeIcon board_default" id="coviTree_FolderMenu_AX_bodyNodeIcon_AX_0_AX_0_AX_2" style="left: 63px; display: block;"></a>
																			<a id="folder_item_6493" type="board_default">내용1</a>
																		</div>
																	</div>
																</td>
															</tr>
															<tr class="gridBodyTr gridBodyTr_3 line1 parentHash000_000_000" id="coviTree_FolderMenu_AX_tr_0_AX_n_AX_3" style="">
																<td valign="middle" style="vertical-align:middle;" id="coviTree_FolderMenu_AX_nbody_AX_0_AX_0_AX_3" class="bodyTd">
																	<div class="tdRelBlock" title="">
																		<div class="bodyNode bodyTdText" style="padding-left:86px;" align="left" id="coviTree_FolderMenu_AX_bodyText_AX_0_AX_0_AX_3">
																			<span class="connectionLineContainer">
																				<span class="connectionLine isParentInside" style="left:3px;width:20px;"></span>
																				<span class="connectionLine isLastChild" style="left:23px;width:20px;"></span>
																			</span>
																			<a class="bodyNodeIndent noChild" id="coviTree_FolderMenu_AX_bodyNodeIndent_AX_0_AX_0_AX_3" style="left:43px;"></a>
																			<a class="bodyNodeIcon board_default" id="coviTree_FolderMenu_AX_bodyNodeIcon_AX_0_AX_0_AX_3" style="left: 63px; display: block;"></a>
																			<a id="folder_item_6495" type="board_default">내용2</a>
																		</div>
																	</div>
																</td>
															</tr>
															<tr class="gridBodyTr gridBodyTr_4 line0 parentHash000_000" id="coviTree_FolderMenu_AX_tr_0_AX_n_AX_4" style="">
																<td valign="middle" style="vertical-align:middle;" id="coviTree_FolderMenu_AX_nbody_AX_0_AX_0_AX_4" class="bodyTd">
																	<div class="tdRelBlock" title="">
																		<div class="bodyNode bodyTdText" style="padding-left:66px;" align="left" id="coviTree_FolderMenu_AX_bodyText_AX_0_AX_0_AX_4">
																			<span class="connectionLineContainer">
																				<span class="connectionLine " style="left:3px;width:20px;"></span>
																			</span>
																			<a class="bodyNodeIndent" id="coviTree_FolderMenu_AX_bodyNodeIndent_AX_0_AX_0_AX_4" style="left:23px;"></a>
																			<a class="bodyNodeIcon board_folder" id="coviTree_FolderMenu_AX_bodyNodeIcon_AX_0_AX_0_AX_4" style="left: 43px; display: block;"></a>
																			<a id="folder_item_6500" type="board_Folder">테스트</a>
																		</div>
																	</div>
																</td>
															</tr>
														</tbody>
														<tfoot id="coviTree_FolderMenu_AX_tfoot"></tfoot>
													</table>
												</div>
												<div id="coviTree_FolderMenu_AX_scrollTrackY" class="treeScrollTrackY" style="display: none;">
													<div id="coviTree_FolderMenu_AX_scrollYHandle" class="treeScrollHandle"></div>
												</div>
												<div id="coviTree_FolderMenu_AX_scrollTrackX" class="treeScrollTrackX" style="display: none;">
													<div id="coviTree_FolderMenu_AX_scrollXHandle" class="treeScrollHandle" style="left: 0px;"></div>
												</div>
												<div style="display:none;">
													<div id="coviTree_FolderMenu_AX_Selector" class="AXtreeSelector"></div>
												</div>
											</div>
											<div class="AXTreeEditor" id="coviTree_FolderMenu_AX_treeEditor" style="display: none;"></div>
										</div>
									</div>
								</div>
							</li>
						</ul>
					</div>
				</div>
			</div>
			<div class='commContRight'>
				<div id="content">
					<div class="cRConTop titType">
						<h2 class="title">컨텐츠 앱 보기</h2>
						<div class="searchBox02">
							<span><input type="text"><button type="button" class="btnSearchType01">검색</button></span><a href="#" class="btnDetails">상세</a>
						</div>
					</div>
					<div class="cRContBottom mScrollVH ">
						<div class="inPerView type02">
							<div>
								<div class="selectCalView">
									<span>내용</span>
									<select class="selectType02">
										<option>제목</option>
										<option>내용</option>
										<option>제목 + 내용</option>
									</select>
									<div class="dateSel type02">
										<input type="text">
									</div>
								</div>
								<div>
									<a href="#" class="btnTypeDefault btnSearchBlue nonHover">검색</a>
								</div>
								<div class="chkGrade">
									<div class="chkStyle01">
										<input type="checkbox" id="chkGrade"><label for="chkGrade"><span></span>읽지않음</label>
									</div>
								</div>
							</div>
							<div>
								<div class="selectCalView">
									<span>기간</span>
									<select class="selectType02">
										<option>1주</option>
										<option>2주</option>
										<option>한달</option>
										<option>일년</option>
									</select>
									<div class="dateSel type02">
										<input class="adDate" type="text" readonly=""><a class="icnDate" href="#">날짜선택</a> - <input class="adDate" type="text" readonly=""><a class="icnDate" href="#">날짜선택</a>
									</div>
								</div>
							</div>
						</div>
						<div id="contentDiv" class="caContent">
							<div class="caMakeTitle listBox_app">
								<div class="icon app14">
								</div>
								<span class="appname">${folderData.DisplayName}</span>
							</div>
							<div class="caMakeSavePath">
								<strong>저장위치</strong>
								<input type="text" value="${folderData.FolderPath}" disabled="">
								<a class="btnTypeDefault" href="#">폴더위치변경</a>
								<div class="viewbutton">
									<a class="btnTypeDefault" href="#">차트접기</a>
									<a class="btnTypeDefault" href="#">권한관리</a>
								</div>
							</div>
							<div class="caViewComponent">
								<div class="caChart_wrap">
									<div class="caChart">
										<img src="/HtmlSite/smarts4j_n/contentsApp/resources/images/img_chart.png" />
									</div>
									<div class="caChart addChart">
										<div class="icon"></div>
										<h3>차트 추가하기</h3>
										<p>데이터 개수를 차트 형태로 확인할 수 있습니다.<br>데이터 목록에서 설정한 차트를 확인하세요.</p>
									</div>
								</div>
								<div class="caMTopCont">
									<div class="pagingType02 buttonStyleBoxLeft">
										<a class="btnTypeDefault btnPosChange" href="#"><span>등록</span></a>
										<a class="btnTypeDefault btnSaRemove" href="#">삭제</a>
										<a class="btnTypeDefault btnExcel_upload" href="#">일괄등록</a>
										<a class="btnTypeDefault btnExcel" href="#">목록 다운로드</a>
										<a id="caAddpopbtn" class="btnTypeDefault btnPlusAdd" href="#">컴포넌트를 목록 화면에 추가</a>
										<div class="caAddpop">
											<input type="text" value="">
											<div class="listbox">
												<div class="chkStyle01"><input type="checkbox" id="ccc36"><label for="ccc36"><span></span>고객사명</label></div>
												<div class="chkStyle01"><input type="checkbox" id="ccc37"><label for="ccc37"><span></span>담당자 성함</label></div>
												<div class="chkStyle01"><input type="checkbox" id="ccc38"><label for="ccc38"><span></span>담당자 연락처</label></div>
												<div class="chkStyle01"><input type="checkbox" id="ccc39"><label for="ccc39"><span></span>담당자 직책</label></div>
												<div class="chkStyle01"><input type="checkbox" id="ccc40"><label for="ccc40"><span></span>담당자 부서</label></div>
												<div class="chkStyle01"><input type="checkbox" id="ccc41"><label for="ccc41"><span></span>기타</label></div>
												<div class="chkStyle01"><input type="checkbox" id="ccc42"><label for="ccc42"><span></span>기타옵션</label></div>
											</div>
										</div>
									</div>
									<div class="buttonStyleBoxRight">
										<select class="selectType02 listCount">
											<option>10</option>
										</select>
										<button class="btnRefresh" type="button" href="#"></button>
									</div>
								</div>
								<div class="tblList tblCont">
									<div id="AXGridTarget" style="height: auto;">
										<a id="AXGridTarget_AX_grid_focus" href="#axtree"></a>
										<div class="AXGrid" id="AXGridTarget_AX_grid" style="overflow:hidden;height:auto;">
											<div class="AXgridScrollBody" id="AXGridTarget_AX_gridScrollBody" style="z-index: 2; height:200px;">
												<div class="AXGridColHead AXUserSelectNone" id="AXGridTarget_AX_gridColHead" onselectstart="return false;" style="width: 100%; left: 0px;">
													<table cellpadding="0" cellspacing="0" class="colHeadTable" style="width:100%;">
														<colgroup>
															<col width="46" style="" id="AXGridTarget_AX_col_AX_0_AX_CH">
															<col width="120" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
															<col width="100" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
															<col width="100" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
															<col width="120" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
															<col width="120" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
															<col width="100" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
															<col width="100" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
														</colgroup>
														<tbody>
															<tr>
																<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd" style="height:401px;">
																	<div class="tdRelBlock" style="height:35px;">
																		<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 8px;"><span class="chkStyle01">
																				<input type="checkbox" id="checkall"><label for="checkall"><span></span></label>
																			</span></div>
																		<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
																		<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
																	</div>
																</td>
																<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd sortDesc" style="height:35px;">
																	<div class="tdRelBlock" style="height:35px;">
																		<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 8px;">등록일</div>
																		<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
																		<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
																	</div>
																</td>
																<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd sortDesc" style="height:35px;">
																	<div class="tdRelBlock" style="height:35px;">
																		<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 8px;">고객사명</div>
																		<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
																		<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
																	</div>
																</td>
																<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd sortDesc" style="height:35px;">
																	<div class="tdRelBlock" style="height:35px;">
																		<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 8px;">버전현황</div>
																		<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
																		<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
																	</div>
																</td>
																<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd sortDesc" style="height:35px;">
																	<div class="tdRelBlock" style="height:35px;">
																		<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 8px;">업그레이드 횟수</div>
																		<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
																		<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
																	</div>
																</td>
																<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd sortDesc" style="height:35px;">
																	<div class="tdRelBlock" style="height:35px;">
																		<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 8px;">방문정기점검</div>
																		<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
																		<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
																	</div>
																</td>
																<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd sortDesc" style="height:35px;">
																	<div class="tdRelBlock" style="height:35px;">
																		<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 8px;">원격정기점검</div>
																		<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
																		<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
																	</div>
																</td>
																<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd sortDesc" style="height:35px;">
																	<div class="tdRelBlock" style="height:35px;">
																		<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 8px;">등록자</div>
																		<a href="#AXexec" class="colHeadTool readyTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
																		<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
																	</div>
																</td>

															</tr>
														</tbody>
													</table>
												</div>
												<div class="AXGridToolGroup top" id="AXGridTarget_AX_gridToolGroupTop"></div>
												<div class="AXGridBody" id="AXGridTarget_AX_gridBody" style="top: 36px; height: 165px;">
													<div id="AXGridTarget_AX_scrollContent" class="gridScrollContent" style="width: 100%; left: 0px; top: 0px;">
														<table cellpadding="0" cellspacing="0" class="gridBodyTable" id="AXGridTarget_AX_gridBodyTable">
															<colgroup>
																<col width="46" style="" id="AXGridTarget_AX_col_AX_0_AX_CH">
																<col width="120" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
																<col width="100" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
																<col width="100" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
																<col width="120" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
																<col width="120" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
																<col width="100" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
																<col width="100" style="" id="AXGridTarget_AX_col_AX_2_AX_CH">
															</colgroup>
															<thead id="AXGridTarget_AX_thead"></thead>
															<tbody id="AXGridTarget_AX_hpadding">
																<tr class="thpadding">
																	<td colspan="5" style="height: 0px;"></td>
																</tr>
															</tbody>
															<tbody id="AXGridTarget_AX_tbody">
																<tr class="gridBodyTr gridBodyTr_0 line0" id="AXGridTarget_AX_tr_0_AX_n_AX_0">
																	<td class="bodyTd bodyTd_0 bodyTdr_0 " id="AXGridTarget_AX_nbody_AX_0_AX_0_AX_0" valign="middle" style="vertical-align:middle;" rowspan="1">
																		<div title="" align="center" class="bodyNode bodyTdText bodyTdCheckBox" id="AXGridTarget_AX_bodyText_AX_0_AX_0_AX_0"><input name="chk" class="gridCheckBox_body_colSeq0" id="AXGridTarget_AX_checkboxItem_AX_0_AX_0"
																				onfocus="this.blur();" type="checkbox" value="undefined"></div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022.04.22</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">코비젼</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">v1.0</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">5</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022-05-01</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022-05-01</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">코비젼</div>
																	</td>
																</tr>
																<tr class="gridBodyTr gridBodyTr_0 line0" id="AXGridTarget_AX_tr_0_AX_n_AX_0">
																	<td class="bodyTd bodyTd_0 bodyTdr_0 " id="AXGridTarget_AX_nbody_AX_0_AX_0_AX_0" valign="middle" style="vertical-align:middle;" rowspan="1">
																		<div title="" align="center" class="bodyNode bodyTdText bodyTdCheckBox" id="AXGridTarget_AX_bodyText_AX_0_AX_0_AX_0"><input name="chk" class="gridCheckBox_body_colSeq0" id="AXGridTarget_AX_checkboxItem_AX_0_AX_0"
																				onfocus="this.blur();" type="checkbox" value="undefined"></div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022.04.22</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">코비제약</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">v2.0</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">4</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022-05-01</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022-05-01</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">코비제약</div>
																	</td>
																</tr>
																<tr class="gridBodyTr gridBodyTr_0 line0" id="AXGridTarget_AX_tr_0_AX_n_AX_0">
																	<td class="bodyTd bodyTd_0 bodyTdr_0 " id="AXGridTarget_AX_nbody_AX_0_AX_0_AX_0" valign="middle" style="vertical-align:middle;" rowspan="1">
																		<div title="" align="center" class="bodyNode bodyTdText bodyTdCheckBox" id="AXGridTarget_AX_bodyText_AX_0_AX_0_AX_0"><input name="chk" class="gridCheckBox_body_colSeq0" id="AXGridTarget_AX_checkboxItem_AX_0_AX_0"
																				onfocus="this.blur();" type="checkbox" value="undefined"></div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022.04.22</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">코비제철</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">v3.77</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022-05-01</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">2022-05-01</div>
																	</td>
																	<td valign="middle" style="vertical-align:middle;" id="AXGridTarget_AX_nbody_AX_0_AX_2_AX_0" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
																		<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">코비제철</div>
																	</td>
																</tr>
															</tbody>
														</table>
													</div>
												</div>
											</div>
											<div class="AXgridPageBody" id="approvalListGrid_AX_gridPageBody" style="z-index:1;">
												<div class="AXgridPagingUnit" id="approvalListGrid_AX_gridPagingUnit" style="display: none;"> <a class="AXgridPagingPrev">PREV</a>
													<div class="AXgridPageNumber"><select id="approvalListGrid_AX_gridPageNo" class="AXgridPageNo" data-axbind="select" style="visibility: hidden;"></select>
														<div id="AXselect_AX_approvalListGrid_AX_gridPageNo" class="AXanchor" style="left: 0px; top: 0px; width: 4px; height: 21px; display: block;">
															<div id="AXselect_AX_approvalListGrid_AX_gridPageNo_AX_SelectBox" class="AXanchorSelect" style="width:4px;height:21px;"><a href="javascript:;" class="selectedTextBox"
																	id="AXselect_AX_approvalListGrid_AX_gridPageNo_AX_SelectTextBox" style="height:21px;">
																	<div class="selectedText" id="AXselect_AX_approvalListGrid_AX_gridPageNo_AX_SelectText" style="line-height:21px;padding:0px 4px;font-size:13.3333px;"></div>
																	<div class="selectBoxArrow" id="AXselect_AX_approvalListGrid_AX_gridPageNo_AX_SelectBoxArrow" style="height:21px;"></div>
																</a></div>
														</div>
													</div>
													<div class="AXgridPageNumberCount" id="approvalListGrid_AX_gridPageCount">/ 1 page(s)</div> <a class="AXgridPagingNext">NEXT</a>
												</div>
												<div class="AXgridStatus" id="approvalListGrid_AX_gridStatus"><b>0</b> 개</div>
												<div id="custom_navi_approvalListGrid" style="text-align:center;margin-top:2px;"><input type="button" id="AXPaging_begin" class="AXPaging_begin"><input type="button" id="AXPaging_prev" class="AXPaging_prev"><input
														type="button" id="AXPaging" value="1" style="min-width:20px;" class="AXPaging Blue"><input type="button" id="AXPaging_next" class="AXPaging_next"><input type="button" id="AXPaging_end" class="AXPaging_end"></div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</section>
	</div>