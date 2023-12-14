package egovframework.coviaccount.api.slip.dto;

import javax.validation.constraints.Min;

import egovframework.baseframework.data.CoviMap;
import io.swagger.annotations.ApiModelProperty;

public class SlipListReq {
	@Min(value = 1) //안먹힘 확인필요
	@ApiModelProperty(value = "페이지 번호", required = false, example = "1")
	private int pageNo = 1;
	@ApiModelProperty(value = "페이지 당 개수", required = false, example = "10")
	private int pageSize = 10;
	@ApiModelProperty(value = "조회하고 싶은 전표 번호", required = false, example = "")
	private String expenceApplicationID = "";
	
	public int getPageNo() {
		return pageNo;
	}

	public void setPageNo(int pageNo) {
		this.pageNo = pageNo;
	}

	public int getPageSize() {
		return pageSize;
	}

	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

	public String getExpenceApplicationID() {
		return expenceApplicationID;
	}

	public void setExpenceApplicationID(String expenceApplicationID) {
		this.expenceApplicationID = expenceApplicationID;
	}

	public CoviMap getMap() {
		CoviMap params = new CoviMap();
		params.put("expenceApplicationID", expenceApplicationID);
		params.put("pageNo", pageNo);
		params.put("pageSize", pageSize);
		params.put("pageOffSet", (pageNo - 1) * pageSize);
		return params;
	}

	public String toString() {
		return "SlipReqVO [pageNo=" + pageNo + ", pageSize=" + pageSize + ", expenceApplicationID=" + expenceApplicationID + "]";
	}

}
