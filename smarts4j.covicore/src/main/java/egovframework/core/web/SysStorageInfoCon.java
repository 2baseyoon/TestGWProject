package egovframework.core.web;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.dto.StorageInfoDTO;
import egovframework.coviframework.service.StorageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;


/**
 * @Class Name : SysStorageInfoCon.java
 * @Description : 시스템 - 스토리지 정보 관리
 * @Modification Information 
 * @ 2022.04.18 최초생성
 *
 * @author 코비젼 연구소
 * @since 2022.04.18
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
@RequestMapping("/storage-info")
public class SysStorageInfoCon {

	private static final Logger LOGGER = LogManager.getLogger(SysStorageInfoCon.class);
	
	@Autowired
	private StorageService storageInfoSvc;
		
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	@RequestMapping(value="/popup.do", method=RequestMethod.GET)
	public ModelAndView storageInfoManagePopup(
			@RequestParam(value = "mode", required = true) String mode,
			@RequestParam(value = "storageID", required = false) Integer storageID) {
		ModelAndView mav = new ModelAndView("core/system/StorageInfoManagePopup");
		mav.addObject("mode", mode);
		if(mode.equalsIgnoreCase("modify")) {
			mav.addObject("storageID", storageID);
		}
		return mav;
	}

	@RequestMapping(value = "/list.do", method=RequestMethod.POST)
	public ResponseEntity<CoviMap> getList(HttpServletRequest request,
			@RequestParam(value = "domain", required = false, defaultValue = "") int domain,
			@RequestParam(value = "pageNo", required = false, defaultValue = "1") String pageNo,
			@RequestParam(value = "pageSize", required = false, defaultValue = "10") String pageSize) {
		
		CoviMap returnList = new CoviMap();
		
		try {
			String sortBy = request.getParameter("sortBy");			
			String sortColumn = (sortBy != null)? sortBy.split(" ")[0] : "";
			String sortDirection = (sortBy != null)? sortBy.split(" ")[1] : "";

			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);			
			params.put("domainList", ComUtils.getAssignedDomainID());
			
			CoviMap result = storageInfoSvc.findAll(params);
			
			returnList.put("list", result.get("list"));
			returnList.put("page", result.get("page"));
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnList);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnList);
		}
		return ResponseEntity.ok(returnList);		
	}
	
	@RequestMapping(value = "/get/{storageId}.do", method=RequestMethod.GET)
	public ResponseEntity<CoviMap> findById(@PathVariable int storageId) {
		CoviMap returnList = new CoviMap();			
		try {			
			CoviMap returnObject = storageInfoSvc.findById(storageId);
			returnList.put("info", returnObject);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnList);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnList);
		}
		return ResponseEntity.ok(returnList);
	}

	@RequestMapping(value = "add.do", method=RequestMethod.POST)
	public ResponseEntity<String> save(@RequestBody StorageInfoDTO storageInfoDTO)
	{
		try {			
			storageInfoSvc.save(storageInfoDTO);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return ResponseEntity.badRequest().body(e.getLocalizedMessage());
		} catch (IllegalStateException e) {
			return ResponseEntity.badRequest().body(e.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return ResponseEntity.badRequest().body(isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return ResponseEntity.status(HttpStatus.CREATED).body(storageInfoDTO.toString());
	}
	
	@RequestMapping(value = "/modify/{storageId}.do", method=RequestMethod.PUT)
	public ResponseEntity<String> update(@PathVariable int storageId,
			@RequestBody StorageInfoDTO storageInfoDTO)
	{
		try {
			storageInfoDTO.setStorageID(storageId);
			storageInfoSvc.update(storageInfoDTO);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return ResponseEntity.badRequest().body(e.getLocalizedMessage());
		} catch (IllegalStateException e) {
			return ResponseEntity.badRequest().body(e.getLocalizedMessage());
		} 
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return ResponseEntity.badRequest().body(isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return ResponseEntity.status(HttpStatus.CREATED).body(storageInfoDTO.toString());
	}
	
	// 해당 메소드로 수정이 IsActive만 수정될 예정
	@RequestMapping(value = "/{storageId}", method=RequestMethod.PATCH)
	public ResponseEntity<Void> toggleActive(@PathVariable int storageId)
	{
		try {
			storageInfoSvc.toggleActive(storageId);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return ResponseEntity.badRequest().build();
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return ResponseEntity.badRequest().build();
		}
		return ResponseEntity.status(HttpStatus.CREATED).build();
	}
	
	@RequestMapping(value = "/remove.do", method=RequestMethod.DELETE)
	public ResponseEntity<Void> deleteByIds(@RequestBody List<String> ids)
	{
		try {
			storageInfoSvc.delete(ids.stream().mapToInt(Integer::parseInt).toArray());
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return ResponseEntity.badRequest().build();
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return ResponseEntity.badRequest().build();
		}
		return ResponseEntity.noContent().build();
	}
	
	@RequestMapping(value = "/getDiskSize.do", method=RequestMethod.GET)
	public ResponseEntity<CoviMap> getDiskSize() {
		CoviMap returnList = new CoviMap();			
		try {			
			CoviMap returnObject = FileUtil.getDiskSize(FileUtil.getBackPath());
			returnList.put("info", returnObject);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnList);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return ResponseEntity.badRequest().body(returnList);
		}
		return ResponseEntity.ok(returnList);
	}
	
}
