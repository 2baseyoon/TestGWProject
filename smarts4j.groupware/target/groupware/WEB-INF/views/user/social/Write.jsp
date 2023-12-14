<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="form_wrap">
	<div class="wordCont" style="top:30px;">
	    <div class="form_box">
	    <table class="wordLayout">
			<colgroup>
				<col style="*" />
			</colgroup>
			<thead>
				<tr>
					<td class="wordLeft">
						<div class="btn_group mb10">설문작성</div>
						<table class="tableStyle linePlus">
							<colgroup>
								<col style="width:10%">
								<col style="width:40%">
								<col style="width:10%">
								<col style="width:40%">										
							</colgroup>
							<tbody>
								<tr>
									<th><span class="apptit_h4">설문주제</span></th>
									<td colspan="3">
										<input name="surveySubject" type="text" style="width:99%;"/>
									</td>
								</tr>
								<tr>
									<th>설문설명</th>
									<td colspan="3">
										<textarea name="description" class="AXTextarea" rows=5 style="width:99%;resize:none"></textarea>
									</td>
								</tr>
								<tr>
									<th>설문기간</th>
									<td>
										<input class="AXInput W100" id="surveyStartDate" date_separator="." kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="surveyEndDate"> ~  				   	   
										<input class="AXInput W100" id="surveyEndDate" date_separator="." kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="surveyStartDate">
									</td>
									<th>조회기간</th>
									<td>
										<input class="AXInput W100" id="resultViewStartDate" date_separator="." kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="resultViewEndDate"> ~  				   	   
										<input class="AXInput W100" id="resultViewEndDate" date_separator="." kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="resultViewStartDate">
									</td>											
								</tr>
								<tr>
									<th>검토자</th>
									<td>
										<input name="reviewerName" type="text" style="width:30%;"/>
									</td>
									<th>승인자</th>
									<td>
										<input name="approverName" type="text" style="width:30%;"/>
									</td>											
								</tr>
									<th>설문대상</th>
									<td>
										<input name="targetName" type="text" style="width:30%;"/>
									</td>
									<th>결과공개범위</th>
									<td>
										<input type="radio" name="targetResultView" value="all" checked="checked" />참여대상 
										<input type="radio" name="targetResultView" value="part" />결과공개대상지정												
									</td>											
								</tr>
								</tr>
									<th>진행등급</th>
									<td>
										<input type="checkbox" name="isImportance" />긴급
										<input type="checkbox" name="isAnonymouse" />익명사용
									</td>
									<th>알림매체</th>
									<td>
										<input type="checkbox" name="isSendTodo" />메일
										<input type="checkbox" name="isSendMail" />Todo								
									</td>											
								</tr>										
							</tbody>
						</table>
					</td>
				</tr>
				<tr>
					<td class="wordLeft">
						<table class="tableStyle linePlus">
								<colgroup>
								<col style="width:*">
							</colgroup>
							<tbody>
								<tr>
									<td>
										<div>
											<div id="questionDiv" class="sortEl">
											</div>
												<div id="menuDiv" class="surveyMenu">
												<div style="margin-bottom:15px;">
													<a href="#" id="addQBtn">＋</a>
													</div>
												<div>
													<a href="#" id="addGBtn">G</a>
												</div>
											</div>
										</div>
										<div style="margin-top:30px;">
											<input type="button" value="승인요청" onclick="reqApproval()">
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>						
			</thead>
		</table>
	    </div>
	</div>
</div>
	