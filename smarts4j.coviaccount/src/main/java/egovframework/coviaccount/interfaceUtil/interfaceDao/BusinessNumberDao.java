package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.BusinessNumberVO;

public class BusinessNumberDao{

	private ArrayList<BusinessNumberVO> businessNumberList = new ArrayList<BusinessNumberVO>();

	public ArrayList<BusinessNumberVO> getBusinessNumberList() {
		return businessNumberList;
	}

	public void setBusinessNumberList(ArrayList<BusinessNumberVO> businessNumberList) {
		this.businessNumberList = businessNumberList;
	}
}
	