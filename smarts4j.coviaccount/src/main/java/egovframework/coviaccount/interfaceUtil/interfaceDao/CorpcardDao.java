package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.CorpcardVO;

public class CorpcardDao{

	private ArrayList<CorpcardVO> corpcardList = new ArrayList<CorpcardVO>();

	public ArrayList<CorpcardVO> getCorpcardList() {
		return corpcardList;
	}

	public void setCorpcardList(ArrayList<CorpcardVO> corpcardList) {
		this.corpcardList = corpcardList;
	}
}
