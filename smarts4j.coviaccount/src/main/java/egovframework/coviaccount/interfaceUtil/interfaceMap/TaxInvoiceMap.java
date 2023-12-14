package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class TaxInvoiceMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getDBMap() {
		map = new CoviMap();
		/**
		 * MAIN
		 */
		//map.put("",					"taxInvoiceID");			//세금계산서ID
		map.put("",						"companyCode");				//회사코드
		//map.put("SUPBUY_TYPE",		"dataIndex");				//매입매출구분(AP:매입AR:매입)
		map.put("DTI_WDATE",			"writeDate");				//작성일자
		map.put("DTI_IDATE",			"issueDT");					//발행일시
		map.put("DTI_TYPE",				"invoiceType");				//세금계산서종류
		map.put("DTT_YN",				"taxType");					//과세형태
		map.put("TAX_AMOUNT_MAIN",		"taxTotal");				//세액합계
		map.put("SUP_AMOUNT_MAIN",		"supplyCostTotal");			//공급가액합계
		map.put("TOTAL_AMOUNT",			"totalAmount");				//합계금액
		map.put("TAX_DEMAND",			"purposeType");				//영수청구구분
		map.put("SEQ_ID",				"serialNum");				//일련번호
		map.put("CASH_AMOUNT",			"cash");					//현금
		map.put("CHECK_AMOUNT",			"chkBill");					//수표
		map.put("RECEIVABLE_AMOUNT",	"credit");					//외상
		map.put("NOTE_AMOUNT",			"note");					//어음
		map.put("REMARK",				"remark1");					//비고1
		map.put("REMARK2",				"remark2");					//비고2
		map.put("REMARK3",				"remark3");					//비고3
		map.put("APPROVE_ID",			"nTSConfirmNum");			//국세청승인번호
		map.put("AMEND_CODE",			"modifyCode");				//수정사유코드
		map.put("ORI_ISSUE_ID",			"orgNTSConfirmNum");		//원본국세청승인번호
		map.put("SUP_COM_REGNO",		"invoicerCorpNum");			//공급자사업자번호
		map.put("SUP_COM_ID",			"invoicerMgtKey");			//공급자관리번호
		map.put("SUP_BIZPLACE_CODE",	"invoicerTaxRegID");		//공급자종사업장번호
		map.put("SUP_COM_NAME",			"invoicerCorpName");		//공급자회사명
		map.put("SUP_REP_NAME",			"invoicerCEOName");			//공급자대표자명
		map.put("SUP_COM_ADDR",			"invoicerAddr");			//공급자주소
		map.put("SUP_COM_TYPE",			"invoicerBizType");			//공급자업태
		map.put("SUP_COM_CLASSIFY",		"invoicerBizClass");		//공급자업종
		map.put("SUP_EMP_NAME",			"invoicerContactName");		//공급자담당자이름
		map.put("SUP_DEPT_NAME",		"invoicerDeptName");		//공급자담당자부서이름
		map.put("SUP_TEL_NUM",			"invoicerTel");				//공급자담당자연락처
		map.put("SUP_EMAIL",			"invoicerEmail");			//공급자담당자이메일
		map.put("BYR_COM_REGNO",		"invoiceeCorpNum");			//공급받는자사업자번호
		//map.put("",					"invoiceeType");			//공급받는자구분
		map.put("BYR_COM_ID",			"invoiceeMgtKey");			//공급받는자관리번호
		map.put("BYR_BIZPLACE_CODE",	"invoiceeTaxRegID");		//공급받는자종사업장번호
		map.put("BYR_COM_NAME",			"invoiceeCorpName");		//공급받는자회사명
		map.put("BYR_REP_NAME",			"invoiceeCEOName");			//공급받는자대표자명
		map.put("BYR_COM_ADDR",			"invoiceeAddr");			//공급받는자주소
		map.put("BYR_COM_TYPE",			"invoiceeBizType");			//공급받는자업태
		map.put("BYR_COM_CLASSIFY",		"invoiceeBizClass");		//공급받는자업종
		map.put("BYR_EMP_NAME",			"invoiceeContactName1");	//공급받는자주)담당자이름
		map.put("BYR_DEPT_NAME",		"invoiceeDeptName1");		//공급받는자주)담당자부서이름
		map.put("BYR_TEL_NUM",			"invoiceeTel1");				//공급받는자주)담당자연락처
		map.put("BYR_EMAIL",			"invoiceeEmail1");			//공급받는자주)담당자이메일
		map.put("BYR_EMP_NAME2",		"invoiceeContactName2");	//공급받는자부)담당자이름
		map.put("BYR_DEPT_NAME2",		"invoiceDeptName2");			//공급받는자부)담당자부서이름
		map.put("BYR_TEL_NUM2",			"invoiceTel2");				//공급받는자부)담당자연락처
		map.put("BYR_EMAIL2",			"invoiceEmail2");			//공급받는자부)담당자이메일
		map.put("BROKER_COM_REGNO",		"trusteeCorpNum");			//수탁자사업자번호
		map.put("BROKER_COM_ID",		"trusteeMgtKey");			//수탁자관리번호
		map.put("BRK_BIZPLACE_CODE",	"trusteeTaxRegID");			//수탁자종사업장번호
		map.put("BROKER_COM_NAME",		"trusteeCorpName");			//수탁자회사명
		map.put("BROKER_REP_NAME",		"trusteeCEOName");			//수탁자대표자명
		map.put("BROKER_COM_ADDR",		"trusteeAddr");				//수탁자주소
		map.put("BROKER_COM_TYPE",		"trusteeBizType");			//수탁자업태
		map.put("BROKER_COM_CLASSIFY",	"trusteeBizClass");			//수탁자업종
		map.put("BROKER_EMP_NAME",		"trusteeContactName");		//수탁자담당자이름
		map.put("BROKER_DEPT_NAME",		"trusteeDeptName");			//수탁자담당자부서이름
		map.put("BROKER_TEL_NUM",		"trusteeTel");				//수탁자담당자연락처
		map.put("BROKER_EMAIL",			"trusteeEmail");			//수탁자이메일
		//map.put("",					"tossUserCode");			//전달받은사용자코드
		//map.put("",					"tossSenderUserCode");		//전달자사용자코드
		//map.put("",					"tossDate");				//전달일시
		//map.put("",					"toss");					//증빙전달시코멘트항목
		map.put("CREATION_DATE_MAIN",	"registDate_main");			//등록일
		//map.put("",					"intDate");					//인터페이스시각
		//map.put("",					"isOffset");				//상계처리여부
		map.put("CONVERSATION_ID",		"cONVERSATION_ID");			//CONVERSATION_ID(세금계산서IF용)
		map.put("SUPBUY_TYPE",			"sUPBUY_TYPE");				//매입매출구분(세금계산서IF용)
		map.put("DIRECTION",			"dIRECTION");				//정/역구분(세금계산서IF용)
		
		/**
		 * ITEM
		 */ 
		//map.put("",					"taxInvoiceItemID");		//세금계산서품목ID
		//map.put("",					"taxInvoiceID");			//세금계산서ID
		map.put("ITEM_MD",				"purchaseDT");				//거래일자
		map.put("ITEM_NAME",			"itemName");				//품명
		map.put("ITEM_SIZE",			"spec");					//규격
		map.put("ITEM_QTY",				"qty");						//수량
		map.put("UNIT_PRICE",			"unitCost");				//단가
		map.put("SUP_AMOUNT_ITEM",		"supplyCost");				//공급가액
		map.put("TAX_AMOUNT_ITEM",		"tax");						//세액
		map.put("REMARK",				"remark");					//비고
		map.put("CREATION_DATE_ITEM",	"registDate_item");			//등록일시
		
		return map;
	}
	
	public CoviMap getInfoTechDBMap() {
		map = new CoviMap();
		/**
		 * MAIN
		 */
		map.put("",					"taxInvoiceID");			//세금계산서ID
		map.put("CompanyCode",		"companyCode");				//회사코드 (SaaS, 추가, 2020.10.14)
		map.put("내역구분코드",			"dataIndex");				//매입매출구분(AP:매입AR:매입)
		map.put("작성일자",			"writeDate");				//작성일자
		map.put("발행일자",			"issueDT");					//발행일시
		map.put("전자세금계산서분류",		"invoiceType");				//세금계산서종류
		map.put("",					"taxType");					//과세형태
		map.put("세액",				"taxTotal");				//세액합계
		map.put("공급가액",			"supplyCostTotal");			//공급가액합계
		map.put("합계금액",			"totalAmount");				//합계금액
		map.put("영수청구구분",			"purposeType");				//영수청구구분
		map.put("",					"serialNum");				//일련번호
		map.put("",					"cash");					//현금
		map.put("",					"chkBill");					//수표
		map.put("",					"credit");					//외상
		map.put("",					"note");					//어음
		map.put("비고",				"remark1");					//비고1
		map.put("",					"remark2");					//비고2
		map.put("",					"remark3");					//비고3
		map.put("승인번호",			"nTSConfirmNum");			//국세청승인번호
		map.put("수정사유코드",			"modifyCode");				//수정사유코드
		map.put("원승인번호",			"orgNTSConfirmNum");		//원본국세청승인번호
		map.put("공급자사업자등록번호",	"invoicerCorpNum");			//공급자사업자번호
		map.put("",					"invoicerMgtKey");			//공급자관리번호
		map.put("공급자종사업장코드",		"invoicerTaxRegID");		//공급자종사업장번호
		map.put("공급자상호명",			"invoicerCorpName");		//공급자회사명
		map.put("공급자대표자명",		"invoicerCEOName");			//공급자대표자명
		map.put("공급자주소",			"invoicerAddr");			//공급자주소
		map.put("공급자업태",			"invoicerBizType");			//공급자업태
		map.put("공급자업종",			"invoicerBizClass");		//공급자업종
		map.put("공급자담당자명",		"invoicerContactName");		//공급자담당자이름
		map.put("공급자담당부서명",		"invoicerDeptName");		//공급자담당자부서이름
		map.put("",					"invoicerTel");				//공급자담당자연락처
		map.put("공급자담당자이메일주소",	"invoicerEmail");			//공급자담당자이메일
		map.put("받는자사업자등록번호",	"invoiceeCorpNum");			//공급받는자사업자번호
		map.put("",					"invoiceeType");			//공급받는자구분
		map.put("",					"invoiceeMgtKey");			//공급받는자관리번호
		map.put("받는자종사업장코드",		"invoiceeTaxRegID");		//공급받는자종사업장번호
		map.put("받는자상호명",			"invoiceeCorpName");		//공급받는자회사명
		map.put("받는자대표자명",		"invoiceeCEOName");			//공급받는자대표자명
		map.put("받는자주소",			"invoiceeAddr");			//공급받는자주소
		map.put("받는자업태",			"invoiceeBizType");			//공급받는자업태
		map.put("받는자업종",			"invoiceeBizClass");		//공급받는자업종
		map.put("받는자담당자명",		"invoiceeContactName1");	//공급받는자주)담당자이름
		map.put("받는자담당부서명",		"invoiceeDeptName1");		//공급받는자주)담당자부서이름
		map.put("",					"invoiceeTel1");			//공급받는자주)담당자연락처
		map.put("받는자담당자이메일주소1",	"invoiceeEmail1");			//공급받는자주)담당자이메일
		map.put("",					"invoiceeContactName2");	//공급받는자부)담당자이름
		map.put("",					"invoiceDeptName2");		//공급받는자부)담당자부서이름
		map.put("",					"invoiceTel2");				//공급받는자부)담당자연락처
		map.put("받는자담당자이메일주소2",	"invoiceEmail2");			//공급받는자부)담당자이메일
		map.put("수탁사사업자등록번호",	"trusteeCorpNum");			//수탁자사업자번호
		map.put("",					"trusteeMgtKey");			//수탁자관리번호
		map.put("수탁사종사업장코드",		"trusteeTaxRegID");			//수탁자종사업장번호
		map.put("수탁사상호명",			"trusteeCorpName");			//수탁자회사명
		map.put("수탁사대표자명",		"trusteeCEOName");			//수탁자대표자명
		map.put("수탁사주소",			"trusteeAddr");				//수탁자주소
		map.put("수탁사업태",			"trusteeBizType");			//수탁자업태
		map.put("수탁사업종",			"trusteeBizClass");			//수탁자업종
		map.put("수탁사담당자명",		"trusteeContactName");		//수탁자담당자이름
		map.put("수탁사담당부서명",		"trusteeDeptName");			//수탁자담당자부서이름
		map.put("",					"trusteeTel");				//수탁자담당자연락처
		map.put("수탁사담당자이메일주소",	"trusteeEmail");			//수탁자이메일
		map.put("",					"tossUserCode");			//전달받은사용자코드
		map.put("",					"tossSenderUserCode");		//전달자사용자코드
		map.put("",					"tossDate");				//전달일시
		map.put("",					"toss");					//증빙전달시코멘트항목
		map.put("",					"registDate_main");			//등록일
		map.put("",					"intDate");					//인터페이스시각
		map.put("",					"isOffset");				//상계처리여부
		map.put("CONVERSATION_ID",	"cONVERSATION_ID");			//CONVERSATION_ID(세금계산서IF용)
		map.put("",					"sUPBUY_TYPE");				//매입매출구분(세금계산서IF용)
		map.put("",					"dIRECTION");				//정/역구분(세금계산서IF용)

		/**
		 * ITEM
		 */ 
		map.put("",					"taxInvoiceItemID");		//세금계산서품목ID
		map.put("",					"taxInvoiceID");			//세금계산서ID
		map.put("일자_품목",			"purchaseDT");				//거래일자
		map.put("품목명_품목",			"itemName");				//품명
		map.put("규격",				"spec");					//규격
		map.put("수량",				"qty");						//수량
		map.put("단가",				"unitCost");				//단가
		map.put("공급가액_품목",		"supplyCost");				//공급가액
		map.put("세액_품목",			"tax");						//세액
		map.put("비고_품목",			"remark");					//비고
		map.put("등록일자_품목",		"registDate_item");			//등록일시
		
		return map;
	}
	
	public CoviMap getSoapMap() {
		map = new CoviMap();
		//map.put("",					"taxInvoiceID");			//세금계산서ID
		map.put("",						"companyCode");				//회사코드
		//map.put("SUPBUY_TYPE",		"dataIndex");			//매입매출구분(AP:매입AR:매입)
		map.put("DTI_WDATE",			"writeDate");				//작성일자
		map.put("DTI_IDATE",			"issueDT");					//발행일시
		map.put("DTI_TYPE",				"invoiceType");				//세금계산서종류
		map.put("DTT_YN",				"taxType");					//과세형태
		map.put("TAX_AMOUNT",			"taxTotal");				//세액합계
		map.put("SUP_AMOUNT",			"supplyCostTotal");			//공급가액합계
		map.put("TOTAL_AMOUNT",			"totalAmount");				//합계금액
		map.put("TAX_DEMAND",			"purposeType");				//영수청구구분
		map.put("SEQ_ID",				"serialNum");				//일련번호
		map.put("CASH_AMOUNT",			"cash");					//현금
		map.put("CHECK_AMOUNT",			"chkBill");					//수표
		map.put("RECEIVABLE_AMOUNT",	"credit");					//외상
		map.put("NOTE_AMOUNT",			"note");					//어음
		map.put("REMARK",				"remark1");					//비고1
		map.put("REMARK2",				"remark2");					//비고2
		map.put("REMARK3",				"remark3");					//비고3
		map.put("ISSUE_ID",				"nTSConfirmNum");			//국세청승인번호
		map.put("AMEND_CODE",			"modifyCode");				//수정사유코드
		map.put("ORI_ISSUE_ID",			"orgNTSConfirmNum");		//원본국세청승인번호
		map.put("SUP_COM_REGNO",		"invoicerCorpNum");			//공급자사업자번호
		map.put("SUP_COM_ID",			"invoicerMgtKey");			//공급자관리번호
		map.put("SUP_BIZPLACE_CODE",	"invoicerTaxRegID");		//공급자종사업장번호
		map.put("SUP_COM_NAME",			"invoicerCorpName");		//공급자회사명
		map.put("SUP_REP_NAME",			"invoicerCEOName");			//공급자대표자명
		map.put("SUP_COM_ADDR",			"invoicerAddr");			//공급자주소
		map.put("SUP_COM_TYPE",			"invoicerBizType");			//공급자업태
		map.put("SUP_COM_CLASSIFY",		"invoicerBizClass");		//공급자업종
		map.put("SUP_EMP_NAME",			"invoicerContactName");		//공급자담당자이름
		map.put("SUP_DEPT_NAME",		"invoicerDeptName");		//공급자담당자부서이름
		map.put("SUP_TEL_NUM",			"invoicerTel");				//공급자담당자연락처
		map.put("SUP_EMAIL",			"invoicerEmail");			//공급자담당자이메일
		map.put("BYR_COM_REGNO",		"invoiceeCorpNum");			//공급받는자사업자번호
		map.put("TYPE_CODE",			"invoiceeType");			//공급받는자구분
		map.put("BYR_COM_ID",			"invoiceeMgtKey");			//공급받는자관리번호
		map.put("BYR_BIZPLACE_CODE",	"invoiceeTaxRegID");		//공급받는자종사업장번호
		map.put("BYR_COM_NAME",			"invoiceeCorpName");		//공급받는자회사명
		map.put("BYR_REP_NAME",			"invoiceeCEOName");			//공급받는자대표자명
		map.put("BYR_COM_ADDR",			"invoiceeAddr");			//공급받는자주소
		map.put("BYR_COM_TYPE",			"invoiceeBizType");			//공급받는자업태
		map.put("BYR_COM_CLASSIFY",		"invoiceeBizClass");		//공급받는자업종
		map.put("BYR_EMP_NAME",			"invoiceeContactName1");	//공급받는자주)담당자이름
		map.put("BYR_DEPT_NAME",		"invoiceeDeptName1");		//공급받는자주)담당자부서이름
		map.put("BYR_TEL_NUM",			"invoiceeTel1");			//공급받는자주)담당자연락처
		map.put("BYR_EMAIL",			"invoiceeEmail1");			//공급받는자주)담당자이메일
		map.put("BYR_EMP_NAME2",		"invoiceeContactName2");	//공급받는자부)담당자이름
		map.put("BYR_DEPT_NAME2",		"invoiceDeptName2");		//공급받는자부)담당자부서이름
		map.put("BYR_TEL_NUM2",			"invoiceTel2");				//공급받는자부)담당자연락처
		map.put("BYR_EMAIL2",			"invoiceEmail2");			//공급받는자부)담당자이메일
		map.put("BROKER_COM_REGNO",		"trusteeCorpNum");			//수탁자사업자번호
		map.put("BROKER_COM_ID",		"trusteeMgtKey");			//수탁자관리번호
		map.put("BRK_BIZPLACE_CODE",	"trusteeTaxRegID");			//수탁자종사업장번호
		map.put("BROKER_COM_NAME",		"trusteeCorpName");			//수탁자회사명
		map.put("BROKER_REP_NAME",		"trusteeCEOName");			//수탁자대표자명
		map.put("BROKER_COM_ADDR",		"trusteeAddr");				//수탁자주소
		map.put("BROKER_COM_TYPE",		"trusteeBizType");			//수탁자업태
		map.put("BROKER_COM_CLASSIFY",	"trusteeBizClass");			//수탁자업종
		map.put("BROKER_EMP_NAME",		"trusteeContactName");		//수탁자담당자이름
		map.put("BROKER_DEPT_NAME",		"trusteeDeptName");			//수탁자담당자부서이름
		map.put("BROKER_TEL_NUM",		"trusteeTel");				//수탁자담당자연락처
		map.put("BROKER_EMAIL",			"trusteeEmail");			//수탁자이메일
		map.put("CREATION_DATE_MAIN",	"registDate_main");			//등록일
		map.put("CONVERSATION_ID",		"cONVERSATION_ID");			//CONVERSATION_ID(세금계산서IF용)
		map.put("SUPBUY_TYPE",			"sUPBUY_TYPE");				//매입매출구분(세금계산서IF용)
		map.put("DIRECTION",			"dIRECTION");				//정/역구분(세금계산서IF용)

		map.put("TOTAL_COUNT",			"total");
		
		return map;
	}
	
	public CoviMap getKwicDBMap() {
		map = new CoviMap();
		/**
		 * MAIN
		 */
		map.put("",					"taxInvoiceID");			//세금계산서ID
		map.put("CompanyCode",		"companyCode");				//회사코드 (SaaS, 추가, 2020.10.14)
		map.put("내역구분코드",			"dataIndex");				//매입매출구분(AP:매입AR:매입)
		map.put("작성일자",			"writeDate");				//작성일자
		map.put("발행일자",			"issueDT");					//발행일시
		map.put("전자세금계산서분류",		"invoiceType");				//세금계산서종류
		map.put("",					"taxType");					//과세형태
		map.put("세액",				"taxTotal");				//세액합계
		map.put("공급가액",			"supplyCostTotal");			//공급가액합계
		map.put("합계금액",			"totalAmount");				//합계금액
		map.put("영수청구구분",			"purposeType");				//영수청구구분
		map.put("",					"serialNum");				//일련번호
		map.put("",					"cash");					//현금
		map.put("",					"chkBill");					//수표
		map.put("",					"credit");					//외상
		map.put("",					"note");					//어음
		map.put("비고",				"remark1");					//비고1
		map.put("",					"remark2");					//비고2
		map.put("",					"remark3");					//비고3
		map.put("승인번호",			"nTSConfirmNum");			//국세청승인번호
		map.put("수정사유코드",			"modifyCode");				//수정사유코드
		map.put("원승인번호",			"orgNTSConfirmNum");		//원본국세청승인번호
		map.put("공급자사업자등록번호",	"invoicerCorpNum");			//공급자사업자번호
		map.put("",					"invoicerMgtKey");			//공급자관리번호
		map.put("공급자종사업장코드",		"invoicerTaxRegID");		//공급자종사업장번호
		map.put("공급자상호명",			"invoicerCorpName");		//공급자회사명
		map.put("공급자대표자명",		"invoicerCEOName");			//공급자대표자명
		map.put("공급자주소",			"invoicerAddr");			//공급자주소
		map.put("공급자업태",			"invoicerBizType");			//공급자업태
		map.put("공급자업종",			"invoicerBizClass");		//공급자업종
		map.put("공급자담당자명",		"invoicerContactName");		//공급자담당자이름
		map.put("공급자담당부서명",		"invoicerDeptName");		//공급자담당자부서이름
		map.put("",					"invoicerTel");				//공급자담당자연락처
		map.put("공급자담당자이메일주소",	"invoicerEmail");			//공급자담당자이메일
		map.put("받는자사업자등록번호",	"invoiceeCorpNum");			//공급받는자사업자번호
		map.put("",					"invoiceeType");			//공급받는자구분
		map.put("",					"invoiceeMgtKey");			//공급받는자관리번호
		map.put("받는자종사업장코드",		"invoiceeTaxRegID");		//공급받는자종사업장번호
		map.put("받는자상호명",			"invoiceeCorpName");		//공급받는자회사명
		map.put("받는자대표자명",		"invoiceeCEOName");			//공급받는자대표자명
		map.put("받는자주소",			"invoiceeAddr");			//공급받는자주소
		map.put("받는자업태",			"invoiceeBizType");			//공급받는자업태
		map.put("받는자업종",			"invoiceeBizClass");		//공급받는자업종
		map.put("받는자담당자명",		"invoiceeContactName1");	//공급받는자주)담당자이름
		map.put("받는자담당부서명",		"invoiceeDeptName1");		//공급받는자주)담당자부서이름
		map.put("",					"invoiceeTel1");			//공급받는자주)담당자연락처
		map.put("받는자담당자이메일주소1",	"invoiceeEmail1");			//공급받는자주)담당자이메일
		map.put("",					"invoiceeContactName2");	//공급받는자부)담당자이름
		map.put("",					"invoiceDeptName2");		//공급받는자부)담당자부서이름
		map.put("",					"invoiceTel2");				//공급받는자부)담당자연락처
		map.put("받는자담당자이메일주소2",	"invoiceEmail2");			//공급받는자부)담당자이메일
		map.put("수탁사사업자등록번호",	"trusteeCorpNum");			//수탁자사업자번호
		map.put("",					"trusteeMgtKey");			//수탁자관리번호
		map.put("수탁사종사업장코드",		"trusteeTaxRegID");			//수탁자종사업장번호
		map.put("수탁사상호명",			"trusteeCorpName");			//수탁자회사명
		map.put("수탁사대표자명",		"trusteeCEOName");			//수탁자대표자명
		map.put("수탁사주소",			"trusteeAddr");				//수탁자주소
		map.put("수탁사업태",			"trusteeBizType");			//수탁자업태
		map.put("수탁사업종",			"trusteeBizClass");			//수탁자업종
		map.put("수탁사담당자명",		"trusteeContactName");		//수탁자담당자이름
		map.put("수탁사담당부서명",		"trusteeDeptName");			//수탁자담당자부서이름
		map.put("",					"trusteeTel");				//수탁자담당자연락처
		map.put("수탁사담당자이메일주소",	"trusteeEmail");			//수탁자이메일
		map.put("",					"tossUserCode");			//전달받은사용자코드
		map.put("",					"tossSenderUserCode");		//전달자사용자코드
		map.put("",					"tossDate");				//전달일시
		map.put("",					"toss");					//증빙전달시코멘트항목
		map.put("",					"registDate_main");			//등록일
		map.put("",					"intDate");					//인터페이스시각
		map.put("",					"isOffset");				//상계처리여부
		map.put("CONVERSATION_ID",	"cONVERSATION_ID");			//CONVERSATION_ID(세금계산서IF용)
		map.put("",					"sUPBUY_TYPE");				//매입매출구분(세금계산서IF용)
		map.put("",					"dIRECTION");				//정/역구분(세금계산서IF용)

		/**
		 * ITEM
		 */ 
		map.put("",					"taxInvoiceItemID");		//세금계산서품목ID
		map.put("",					"taxInvoiceID");			//세금계산서ID
		map.put("일자_품목",			"purchaseDT");				//거래일자
		map.put("품목명_품목",			"itemName");				//품명
		map.put("규격",				"spec");					//규격
		map.put("수량",				"qty");						//수량
		map.put("단가",				"unitCost");				//단가
		map.put("공급가액_품목",		"supplyCost");				//공급가액
		map.put("세액_품목",			"tax");						//세액
		map.put("비고_품목",			"remark");					//비고
		map.put("등록일자_품목",		"registDate_item");			//등록일시
		
		return map;
	}
	
	
}
