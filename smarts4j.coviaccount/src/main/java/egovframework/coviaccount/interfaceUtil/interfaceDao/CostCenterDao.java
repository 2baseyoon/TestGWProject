package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.CostCenterVO;

public class CostCenterDao{

	private ArrayList<CostCenterVO> costCenterList = new ArrayList<CostCenterVO>();

	public ArrayList<CostCenterVO> getCostCenterList() {
		return costCenterList;
	}

	public void setCostCenterList(ArrayList<CostCenterVO> costCenterList) {
		this.costCenterList = costCenterList;
	}
}
