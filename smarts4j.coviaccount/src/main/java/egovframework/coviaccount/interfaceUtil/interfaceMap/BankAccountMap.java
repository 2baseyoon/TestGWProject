package egovframework.coviaccount.interfaceUtil.interfaceMap;

import egovframework.baseframework.data.CoviMap;

public class BankAccountMap  {
	private CoviMap map = new CoviMap();
	
	public CoviMap getMap() {
		
		return map;
	}
	
	public CoviMap getSapMap() {
	
		return map;
	}
	
	public CoviMap getSapODataMap() {
		map.put("BusinessPartner"	, "vendorNo");			//거래처 코드
		map.put("BankName"	, "bankName");			//은행명
		map.put("BankAccount"	, "bankAccountNo");		//은행계좌
		map.put("BankAccountName"	, "bankAccountName");		
		map.put("BankNumber"	, "bankCode");			//은행코드
		map.put("BankIdentification"	, "bankIdentification");
		map.put("BankCountryKey"	, "bankCountryKey");
		map.put("SWIFTCode"	, "SWIFTCode");
		map.put("BankControlKey"	, "bankControlKey");
		map.put("bankAccountHolderName"	, "bankAccountHolderName"); //예금주명	
		map.put("ValidityStartDate"	, "validityStartDate");
		map.put("ValidityEndDate"	, "ValidityEndDate");
		map.put("IBAN"	, "IBAN");
		map.put("IBANValidityStartDate"	, "IBANValidityStartDate");
		map.put("BankAccountReferenceText"	, "bankAccountReferenceText");
		map.put("CollectionAuthInd"	, "collectionAuthInd");
		map.put("CityName"	, "cityName");
		map.put("AuthorizationGroup"	, "authorizationGroup");

		return map;
	}
}
