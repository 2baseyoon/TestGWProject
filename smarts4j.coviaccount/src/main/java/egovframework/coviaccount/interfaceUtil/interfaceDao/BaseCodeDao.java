package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.BaseCodeVO;

public class BaseCodeDao{

	private ArrayList<BaseCodeVO> baseCodeList = new ArrayList<BaseCodeVO>();

	public ArrayList<BaseCodeVO> getBaseCodeList() {
		return baseCodeList;
	}

	public void setBaseCodeList(ArrayList<BaseCodeVO> baseCodeList) {
		this.baseCodeList = baseCodeList;
	}
}
