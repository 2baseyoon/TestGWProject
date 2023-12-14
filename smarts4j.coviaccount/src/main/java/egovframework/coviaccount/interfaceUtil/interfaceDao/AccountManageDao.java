package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.AccountManageVO;

public class AccountManageDao{

	private ArrayList<AccountManageVO> accountManageList = new ArrayList<AccountManageVO>();

	public ArrayList<AccountManageVO> getAccountManageList() {
		return accountManageList;
	}

	public void setAccountManageList(ArrayList<AccountManageVO> accountManageList) {
		this.accountManageList = accountManageList;
	}
}
