package egovframework.coviaccount.api.slip.repository;

import org.springframework.stereotype.Repository;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;

@Repository
public class SlipRepository {
	
	private final CoviMapperOne coviMapperOne;

    public SlipRepository(final CoviMapperOne coviMapperOne) {
        this.coviMapperOne = coviMapperOne;
    }
	
    public int findSlipCnt(CoviMap params) {
		return (int) coviMapperOne.getNumber("slip.selectSlipCnt", params);
	}
	
    public CoviList findSlip(CoviMap params) throws Exception {
		return coviMapperOne.list("slip.selectSlip", params);
	}
    
	public CoviList findSlipList(CoviMap params) throws Exception {
		return coviMapperOne.list("slip.selectSlipList", params);
	}
	
	public CoviList findSlipDiv(CoviMap params) throws Exception {
		return coviMapperOne.list("slip.selectSlipDiv", params);
	}
	
	public void slipComplete(CoviMap params) throws Exception {
		coviMapperOne.update("slip.slipComplete", params);
	}
	
	public void slipCancel(CoviMap params) throws Exception {
		coviMapperOne.update("slip.slipCancel", params);
	}

	public CoviList findVendorInfo(CoviMap params) {
		return coviMapperOne.list("slip.selectVendorInfo", params);
	}

	public Object getcorpCardInfo(CoviMap params) {
		return coviMapperOne.list("slip.selectCorpCardInfo", params);
	}

	public Object getTaxInfo(CoviMap params) {
		return coviMapperOne.list("slip.selectTaxInfo", params);
	}

	public Object getReceiptInfo(CoviMap params) {
		return coviMapperOne.list("slip.selectReceiptInfo", params);
	}

}

