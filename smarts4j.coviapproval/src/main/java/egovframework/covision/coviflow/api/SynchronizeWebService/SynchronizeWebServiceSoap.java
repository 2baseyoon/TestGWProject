/**
 * SynchronizeWebServiceSoap.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package egovframework.covision.coviflow.api.SynchronizeWebService;

public interface SynchronizeWebServiceSoap extends java.rmi.Remote {
    public java.lang.String btnSmartUserADCreate_Click() throws java.rmi.RemoteException;
    public void createADOU() throws java.rmi.RemoteException;
    public void setLockUser_InitPassword(java.lang.String pStrUR_Code) throws java.rmi.RemoteException;
    public boolean setUnLockUser_ChangePassword(java.lang.String pStrUR_Code, java.lang.String pStrPassword) throws java.rmi.RemoteException;
    public java.lang.String setRdpUserEnable(java.lang.String pLogonID, java.lang.String pStrPassword, java.lang.String pExpairedDate) throws java.rmi.RemoteException;
    public boolean getUserStatus(java.lang.String pStrUR_Code) throws java.rmi.RemoteException;
    public void sendMsgReq(java.lang.String pMessageContext, java.lang.String pReceiverText) throws java.rmi.RemoteException;
    public int startSynchronize(java.lang.String pXml) throws java.rmi.RemoteException;
    public boolean createHRTempData(java.lang.String pMod, java.lang.String pStrInsertDate) throws java.rmi.RemoteException;
}
