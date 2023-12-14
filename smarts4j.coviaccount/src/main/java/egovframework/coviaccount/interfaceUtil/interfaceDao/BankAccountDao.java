package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.BankAccountVO;

public class BankAccountDao{

	private ArrayList<BankAccountVO> bankAccountList = new ArrayList<BankAccountVO>();

	public ArrayList<BankAccountVO> getBankAccountList() {
		return bankAccountList;
	}

	public void setBankAccountList(ArrayList<BankAccountVO> bankAccountList) {
		this.bankAccountList = bankAccountList;
	}
}
