package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class ExpenceApplicationMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getMap() {
		map = new CoviMap();
		/**
		 * act_expence_application
		 */
		map.put("",							"companyCode");					//회사코드
		map.put("evidence_title",			"applicationTitle");			//신청제목
		//map.put("",						"applicationType");				//신청유형
		//map.put("",						"applicationStatus");			//신청상태
		map.put("post_date",				"applicationDate");				//신청일
		//map.put("",						"processID");					//결재 Process ID
		map.put("employee_code",			"ur_code");						//결재행위자
		//map.put("",						"comment");						//결재내용(반려사유포함)
		
		/**
		 * act_expence_application_list
		 */
		map.put("evidence_date",			"proofDate");					//증빙일자
		map.put("evidence_type",			"proofCode");					//증빙타입
		map.put("card_approval_no",			"cardUID");				//카드승인번호
		//map.put("",						"cashUID");			//현금영수증승인번호
		//map.put("",						"taxUID");			//세금계산서승인번호
		//map.put("",						"receiptID");					//모바일영수증ID
		//map.put("post_date",				"postingDate");					//전기일자			- act_expence_application		- applicationDate
		map.put("tax_code_type",			"taxType");						//세금유형
		map.put("tax_code",					"taxCode");						//세금코드
		map.put("pay_adjust_method",		"payAdjustMethod");				//정산방법
		map.put("pay_method",				"payMethod");					//지급방법
		//map.put("",						"payDate");						//지급일자
		//map.put("",						"isWithholdingTax");			//원천세여부
		//map.put("",						"incomeTax");					//소득세유형
		//map.put("",						"localTax");					//지방세유형
		map.put("vendor_code",				"vendorNo");					//거래처등록번호
		//map.put("",						"personalCardNo");				//개인카드번호
		map.put("total_amount",				"totalAmount");					//합계액
		map.put("posting_pay_out_number",	"docNo");						//전표번호
		//map.put("post_date",				"docPostingDate");				//전표전기일자		- act_expence_application		- applicationDate
		//map.put("",						"docPayDate");					//전표지급일자
		
		/**
		 * act_expence_application_div
		 */
		map.put("division_gl_account_code",	"accountCode");					//계정과목
		//map.put("",						"standardBriefID");				//표준적요ID
		map.put("division_costcenter_code",	"costCenterCode");				//코스트센터코드
		//map.put("",						"iOCode");						//IO코드
		map.put("division_use_money",		"amount");						//금액
		map.put("division_comment",			"usageComment");				//사용내역
		
		/**
		 * SETTING
		 */
		map.put("interFaceSetType",			"interFaceSetType");
		map.put("form_inst_id",				"form_inst_id");
		map.put("evidence_index",			"evidence_index");
		map.put("division_index",			"division_index");
		
		return map;
	}
}
