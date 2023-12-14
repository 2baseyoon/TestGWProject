package egovframework.covision.coviflow.api.SynchronizeWebService;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

public class SynchronizeWebServiceSoapProxy implements egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoap {
  private String _endpoint = null;
  private egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoap synchronizeWebServiceSoap = null;
  private static final Logger LOGGER = LogManager.getLogger(SynchronizeWebServiceSoapProxy.class);

  
  public SynchronizeWebServiceSoapProxy() {
    _initSynchronizeWebServiceSoapProxy();
  }
  
  public SynchronizeWebServiceSoapProxy(String endpoint) {
    _endpoint = endpoint;
    _initSynchronizeWebServiceSoapProxy();
  }
  
  private void _initSynchronizeWebServiceSoapProxy() {
    try {
      synchronizeWebServiceSoap = (new egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceLocator()).getSynchronizeWebServiceSoap();
      if (synchronizeWebServiceSoap != null) {
        if (_endpoint != null)
          ((javax.xml.rpc.Stub)synchronizeWebServiceSoap)._setProperty("javax.xml.rpc.service.endpoint.address", _endpoint);
        else
          _endpoint = (String)((javax.xml.rpc.Stub)synchronizeWebServiceSoap)._getProperty("javax.xml.rpc.service.endpoint.address");
      }
      
    }
    catch (javax.xml.rpc.ServiceException serviceException) {
    	LOGGER.debug(serviceException);
    }
  }
  
  public String getEndpoint() {
    return _endpoint;
  }
  
  public void setEndpoint(String endpoint) {
    _endpoint = endpoint;
    if (synchronizeWebServiceSoap != null)
      ((javax.xml.rpc.Stub)synchronizeWebServiceSoap)._setProperty("javax.xml.rpc.service.endpoint.address", _endpoint);
    
  }
  
  public egovframework.covision.coviflow.api.SynchronizeWebService.SynchronizeWebServiceSoap getSynchronizeWebServiceSoap() {
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    return synchronizeWebServiceSoap;
  }
  
  public java.lang.String btnSmartUserADCreate_Click() throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    return synchronizeWebServiceSoap.btnSmartUserADCreate_Click();
  }
  
  public void createADOU() throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    synchronizeWebServiceSoap.createADOU();
  }
  
  public void setLockUser_InitPassword(java.lang.String pStrUR_Code) throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    synchronizeWebServiceSoap.setLockUser_InitPassword(pStrUR_Code);
  }
  
  public boolean setUnLockUser_ChangePassword(java.lang.String pStrUR_Code, java.lang.String pStrPassword) throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    return synchronizeWebServiceSoap.setUnLockUser_ChangePassword(pStrUR_Code, pStrPassword);
  }
  
  public java.lang.String setRdpUserEnable(java.lang.String pLogonID, java.lang.String pStrPassword, java.lang.String pExpairedDate) throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    return synchronizeWebServiceSoap.setRdpUserEnable(pLogonID, pStrPassword, pExpairedDate);
  }
  
  public boolean getUserStatus(java.lang.String pStrUR_Code) throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    return synchronizeWebServiceSoap.getUserStatus(pStrUR_Code);
  }
  
  public void sendMsgReq(java.lang.String pMessageContext, java.lang.String pReceiverText) throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    synchronizeWebServiceSoap.sendMsgReq(pMessageContext, pReceiverText);
  }
  
  public int startSynchronize(java.lang.String pXml) throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    return synchronizeWebServiceSoap.startSynchronize(pXml);
  }
  
  public boolean createHRTempData(java.lang.String pMod, java.lang.String pStrInsertDate) throws java.rmi.RemoteException{
    if (synchronizeWebServiceSoap == null)
      _initSynchronizeWebServiceSoapProxy();
    return synchronizeWebServiceSoap.createHRTempData(pMod, pStrInsertDate);
  }
  
  
}