package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class VendorMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getMap() {
		map.put("vendor_code"			, "vendorID");			//거래처관리ID
		map.put(""						, "companyCode");		//회사코드
		map.put("vendor_gbn"			, "vendorType");		//거래처구분
		map.put("vendor_regno"			, "vendorNo");			//사업자등록번호
		//map.put(""					, "corporateNo");		//법인번호
		map.put("vendor_name"			, "vendorName");		//거래처명
		//map.put(""					, "cEOName");			//대표자명
		//map.put(""					, "industry");			//업태
		//map.put(""					, "sector");			//업종
		//map.put(""					, "address");			//주소
		//map.put(""					, "bankName");			//은행명
		map.put("vendor_bank_account"	, "bankAccountNo");		//은행계좌
		map.put("vendor_bank_name"		, "bankAccountName");	//예금주명
		//map.put(""					, "paymentCondition");	//지급조건#공통코드
		map.put("vendor_pay_term"		, "paymentMethod");		//지급방법#공통코드
		//map.put(""					, "vendorStatus");		//거래처상태#공통코드
		//map.put(""					, "incomTax");			//소득세유형
		//map.put(""					, "localTax");			//지방세유형
		return map;
	}
	
	public CoviMap getSapMap() {
		map.put(""	, "vendorID");			//거래처관리ID
		map.put(""	, "companyCode");		//회사코드
		map.put(""	, "vendorType");		//거래처구분
		map.put(""	, "vendorNo");			//사업자등록번호
		map.put(""	, "corporateNo");		//법인번호
		map.put(""	, "vendorName");		//거래처명
		map.put(""	, "cEOName");			//대표자명
		map.put(""	, "industry");			//업태
		map.put(""	, "sector");			//업종
		map.put(""	, "address");			//주소
		map.put(""	, "bankName");			//은행명
		map.put(""	, "bankAccountNo");		//은행계좌
		map.put(""	, "bankAccountName");	//예금주명
		map.put(""	, "paymentCondition");	//지급조건#공통코드
		map.put(""	, "paymentMethod");		//지급방법#공통코드
		map.put(""	, "vendorStatus");		//거래처상태#공통코드
		map.put(""	, "incomTax");			//소득세유형
		map.put(""	, "localTax");			//지방세유형
		return map;
	}
	
	public CoviMap getSapODataMap() {
		map.put(""	, "vendorID");			//거래처관리ID
		map.put(""	, "companyCode");		//회사코드
		map.put("YY1_ZMASTER_bus"	, "vendorType");		//거래처구분
		map.put("BusinessPartner"	, "vendorNo");			//사업자등록번호
		map.put(""	, "corporateNo");		//법인번호
		map.put("BusinessPartnerFullName"	, "vendorName");		//거래처명
		map.put("PersonFullName"	, "cEOName");			//대표자명
		map.put("Industry"	, "industry");			//업태
		map.put(""	, "sector");			//업종
		map.put(""	, "address");			//주소
		map.put(""	, "bankName");			//은행명
		map.put(""	, "bankAccountNo");		//은행계좌
		map.put(""	, "bankAccountName");	//예금주명
		map.put(""	, "paymentCondition");	//지급조건#공통코드
		map.put(""	, "paymentMethod");		//지급방법#공통코드
		map.put(""	, "vendorStatus");		//거래처상태#공통코드
		map.put(""	, "incomTax");			//소득세유형
		map.put(""	, "localTax");			//지방세유형	
		map.put(""	, "currencyCode");		//통화			
		map.put(""	, "businessNumber");		//사업자번호			

		return map;
	}
}
