package egovframework.coviaccount.api.slip.service;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.api.slip.repository.SlipRepository;

@Service
public class SlipService {
	
	private final SlipRepository slipRepository;

    public SlipService(final SlipRepository slipRepository) {
        this.slipRepository = slipRepository;
    }

	public int listCnt(CoviMap params) {
		return slipRepository.findSlipCnt(params);
	}
	
    public CoviList list(CoviMap params) throws Exception {
    	CoviList slips = slipRepository.findSlip(params);
    	
    	for (Object object1: slips) {
    		CoviMap slip = (CoviMap) object1;
    		CoviList slipLists = slipRepository.findSlipList(slip);
    		slip.put("slipLists", slipLists);
    		
    		for (Object object2 : slipLists) {
    			CoviMap slipList = (CoviMap) object2;
    			addProofInfo(slipList);
    			CoviList slipDivs = slipRepository.findSlipDiv(slipList);
    			slipList.put("slipDivs", slipDivs);
    		}
    	}
    	return slips;
    }
    
    private void addProofInfo(CoviMap slipList) {
    	//VendorNo 존재하면 거래처정보 추가
    	if(checkVendor(slipList)) {
    		slipList.put("vendorInfo", slipRepository.findVendorInfo(slipList));
    	}
    	//증빙유형이 법인카드, 세금계산서, 모바일 영수증일 경우 증빙정보 추가
    	if(checkProof(slipList)) {
    		switch(getProofType(slipList)) {
	    		case "card" : slipList.put("corpCardInfo", slipRepository.getcorpCardInfo(slipList));
	    			break;
	    		case "tax" : slipList.put("taxInfo", slipRepository.getTaxInfo(slipList));
	    			break;
	    		case "receipt" : slipList.put("receiptInfo", slipRepository.getReceiptInfo(slipList));
	    			break;
				default : 
					break;
    		}
    	}
	}

    private boolean checkVendor(CoviMap slipList) {
    	return !"".equals(StringUtil.replaceNull(slipList.get("VendorNo"))) ? true : false;
    }

	private boolean checkProof(CoviMap slipList) {
		String cardUID = StringUtil.replaceNull(slipList.get("CardUID"));
		String taxUID = StringUtil.replaceNull(slipList.get("TaxUID"));
		String receiptID = StringUtil.replaceNull(slipList.get("ReceiptID"));
		return !"".equals(cardUID) || !"".equals(taxUID) || !"".equals(receiptID) ? true : false;
	}

	private String getProofType(CoviMap slipList) {
		String cardUID = StringUtil.replaceNull(slipList.get("CardUID"));
		String taxUID = StringUtil.replaceNull(slipList.get("TaxUID"));
		String receiptID = StringUtil.replaceNull(slipList.get("ReceiptID"));
		return !"".equals(cardUID) ? "card" : !"".equals(taxUID) ? "tax" : !"".equals(receiptID) ? "receipt" : "";
	}

	public void complete(CoviMap params) throws Exception {
    	slipRepository.slipComplete(params);
    }
    
    public void cancel(CoviMap params) throws Exception {
    	slipRepository.slipCancel(params);
    }
}
