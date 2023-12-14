package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.CashBillVO;

public class CashBillDao{

	private ArrayList<CashBillVO> cashBillList = new ArrayList<CashBillVO>();

	public ArrayList<CashBillVO> getCashBillList() {
		return cashBillList;
	}

	public void setCashBillList(ArrayList<CashBillVO> cashBillList) {
		this.cashBillList = cashBillList;
	}
}
