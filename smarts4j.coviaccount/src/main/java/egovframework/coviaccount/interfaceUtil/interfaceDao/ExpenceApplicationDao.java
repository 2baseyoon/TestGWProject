package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.ExpenceApplicationVO;

public class ExpenceApplicationDao{

	private ArrayList<ExpenceApplicationVO> expenceApplicationList = new ArrayList<ExpenceApplicationVO>();

	public ArrayList<ExpenceApplicationVO> getExpenceApplicationList() {
		return expenceApplicationList;
	}

	public void setExpenceApplicationList(ArrayList<ExpenceApplicationVO> expenceApplicationList) {
		this.expenceApplicationList = expenceApplicationList;
	}
}
