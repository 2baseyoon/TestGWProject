package egovframework.coviframework.service.impl;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMapperOne;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

import egovframework.coviframework.service.CoviService;;

@Service("coviService")
public class CoviServiceImpl extends EgovAbstractServiceImpl implements CoviService {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public int insert(String serviceId, CoviMap coviMap) throws Exception
	{
		coviMapperOne.insert(serviceId, coviMap);
		return  1;
	}
	
	@Override
	public CoviList   list(String serviceId, CoviMap coviMap) throws Exception
	{
		return coviMapperOne.list(serviceId, coviMap);
	}
	/*
	@Override
	public CoviList   list(String serviceId, Object coviMap) throws Exception
	{
		return coviMapperOne.list(serviceId, coviMap);
	}*/

	
	@Override
	public CoviMap select(String serviceId, CoviMap coviMap) throws Exception
	{
		return coviMapperOne.selectOne(serviceId, coviMap);
	}

	
}