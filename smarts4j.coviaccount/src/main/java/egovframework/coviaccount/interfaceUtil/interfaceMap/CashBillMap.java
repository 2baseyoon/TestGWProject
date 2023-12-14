package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class CashBillMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getInfoTechDBMap() {
		map = new CoviMap();
		map.put("",				"cashBillID");			//현금영수증ID
		map.put("",				"companyCode");			//회사코드
		map.put("승인번호",		"nTSConfirmNum");		//현금영수증승인번호
		map.put("승인일자",		"tradeDT");				//거래일시
		map.put("공제구분명",		"tradeUsage");			//현금영수증거래유형#지출증빙용,소득공제용
		map.put("승인상태",		"tradeType");			//거래구분#승인거래,취소거래
		map.put("공급가액",		"supplyCost");			//공급가액
		map.put("부가세",			"tax");					//세금
		map.put("봉사료",			"serviceFree");			//서비스금액
		map.put("승인금액",		"totalAmount");			//거래금액
		map.put("",				"invoiceType");			//현금영수증유형#매입,매출
		map.put("가맹자사업자번호",	"franchiseCorpNum");	//발행자사업자번호
		map.put("가맹점명",		"franchiseCorpName");	//발행자명
		map.put("발행구분명",		"franchiseCorpType");	//발생자구분
		map.put("등록일자",		"registDate");			//등록일시
		return map;
	}
	
	public CoviMap getKwicDBMap() {
		map = new CoviMap();
		map.put("",				"cashBillID");			//현금영수증ID
		map.put("",				"companyCode");			//회사코드
		map.put("승인번호",		"nTSConfirmNum");		//현금영수증승인번호
		map.put("승인일자",		"tradeDT");				//거래일시
		map.put("공제구분명",		"tradeUsage");			//현금영수증거래유형#지출증빙용,소득공제용
		map.put("승인상태",		"tradeType");			//거래구분#승인거래,취소거래
		map.put("공급가액",		"supplyCost");			//공급가액
		map.put("부가세",			"tax");					//세금
		map.put("봉사료",			"serviceFree");			//서비스금액
		map.put("승인금액",		"totalAmount");			//거래금액
		map.put("",				"invoiceType");			//현금영수증유형#매입,매출
		map.put("가맹자사업자번호",	"franchiseCorpNum");	//발행자사업자번호
		map.put("가맹점명",		"franchiseCorpName");	//발행자명
		map.put("발행구분명",		"franchiseCorpType");	//발생자구분
		map.put("등록일자",		"registDate");			//등록일시
		return map;
	}
}