<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="divFormApvLines" style="padding: 20px 30px;"></div>

<!-- 결재선 정보 시작-->
<script type="text/x-frozen-html" id="frozen">
<input type="hidden" data-type="dField" id="ReceiveNames" data-model="FormInstanceInfo.ReceiveNames" data-binding="post" />
<input type="hidden" data-type="dField" id="ReceiptList" data-model="FormInstanceInfo.ReceiptList" data-binding="post" />
	<div>
		<!-- 일반결재 -->
		<table class="signTable" id="FormApvLines" style="display: none;">
			<colgroup>
				<col style="width:50%">
				<col style="width:*">
			</colgroup>
		    <tr>
		    	<td id="AppLine" style="float:right;display: none;" colspan="2">
		    		<table class="tableStyle linePlus tCenter">
						<colgroup>
							<col style="width:30px;">
						</colgroup>
						<tbody>
						</tbody>
					</table>
		    	</td>
		    </tr>
		    <tr>
				<td id="LApvLine" style="display: none">
					<table class="tableStyle linePlus tCenter">
						<colgroup>
							<col style="width:30px;">
						</colgroup>
						<tbody>
						</tbody>
					</table>
				</td>
				<td id="RApvLine" style="float:right;display: none;">
					<table class="tableStyle linePlus tCenter" >
						<colgroup>
							<col style="width:30px;">
						</colgroup>
						<tbody>
						</tbody>
					</table>
				</td>
			</tr>
		</table>
		
		<!-- 리스트형 결재선 표시 -->
		<div id="AppLineListType" style="display: none;">
			<div>
				<h3 class="apptit_h3 mt10"><span id="tableTitle"></span></h3>
				<table class="tableStyle linePlus t_center">
					<colgroup>
					</colgroup>
				</table>
			</div>
		</div>
		
		<!-- 합의목록 -->
		<div id="AssistLine" style="display: none;">
			<div>
				<table class="tableStyle linePlus t_center mt10">
					<colgroup>
					</colgroup>
				</table>
			</div>
		</div>
	</div>

<table class="tableStyle linePlus mt10"  style="display: none" summary="수신처" cellpadding="0" cellspacing="0" id="ReceiveLine"><!-- class="table_10" -->
    <colgroup>
        <col style="width:12%" />
        <col style="width:*" />
    </colgroup>
    <tr>
        <th id="TIT_RECLINE"><spring:message code='Cache.lbl_DESTINATION'/></th>
        <td id="RecLine"></td>
    </tr>
</table>

<table class="tableStyle linePlus mt10"  style="display: none"  summary="참조" cellpadding="0" cellspacing="0" id="CCLine"><!-- class="table_10" -->
    <colgroup>
        <col style="width:12%" />
        <col style="width:*" />
    </colgroup>
    <tr>
        <th id="TIT_L_CCINFO">참조</th>
        <td>
            <span id="SendCC"></span>
        </td>
    </tr>
    <tr>
        <th id="TIT_R_CCINFO">수신 참조</th>
        <td>
            <span id="RecCC"></span>
        </td>
    </tr>
</table>
</script>