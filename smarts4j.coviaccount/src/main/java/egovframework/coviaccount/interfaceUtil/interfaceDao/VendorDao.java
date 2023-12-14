package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.VendorVO;

public class VendorDao{

	private ArrayList<VendorVO> vendorList = new ArrayList<VendorVO>();

	public ArrayList<VendorVO> getVendorList() {
		return vendorList;
	}

	public void setVendorList(ArrayList<VendorVO> vendorList) {
		this.vendorList = vendorList;
	}
}
