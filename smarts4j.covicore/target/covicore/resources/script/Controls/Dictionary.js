/* 프로그램 저작권 정보
// 이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
// (주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
// (주)코비젼의 지적재산권 침해에 해당됩니다.
// (Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
// You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
// as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
// owns the intellectual property rights in and to this program.
// (Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>황선희(sunnyhwang@covision.co.kr)</creator> 
///<createDate>2011.12.16</createDate> 
///<lastModifyDate>2014.06.26</lastModifyDate> 
///<version>1.1.0</version>
///<summary> 
///다국어에 이용되는 공용 JS
///</summary>
///<ModifySpc>
///2014.06.26 ( 임소희 shlim@covision.co.kr) : Copyright, ID Block 추가
///</ModifySpc>
*/
/*
File: Dictionary.js
Version: 1.0
Last modified: 09.17.2002
Author: Alexandar Minkovsky (a_minkovsky@hotmail.com)
Copyright: Left
Type: Class
Exports: Dictionary class.
Dependencies: None.
Description:
    Similar to ASP "Scripting.Dictionary" Object, or an associative array
    with somewhat limited functionality. There's a few differences:
        - "item" property is replaced by two methods getVal and setVal.
        - "key" property is replaced by the setKey method.
    As the value of an item can be virtually anything, even another Dictionary object,
    the Dictionary Class might be usefull.
    If someone have a suggestion or wants the Dictionary class to be extended some way,
    feel free to drop me an e-mail.
Tested with: IE4; IE5; IE5.5; IE6; NS4.78; NS6.0; NS6.1; NS6.2; NS7.0; Mozilla 1.0; Mozilla 1.1; Opera 6.0
*/
/*
================
Dictionary Class
================
    - Instanciating
        oDict = new Dictionary();

    - Properties
       ~ Public
         (int) Count - Number of Keys in the Dictionary. Default: 0. Read only, do never manually set this property!
       ~ Private
         (Object) Obj - the object actually containing the data. Do never use it directly.

    - Methods - look at the function descriptions for detailed explanation.
      ~ Public
        (BOOL)  Exists(sKey)
        (BOOL)  Add (sKey,aVal)
        (BOOL)  Remove(sKey)
        (void)  RemoveAll()
        (Array) values()
        (Array) Keys()
        (Array) Items()
        (Any)   getVal(sKey)
        (void)  setVal(sKey,aVal)
        (void)  setKey(sKey,sNewKey)
        (void)  Key(sKey)
        (Array) Item(sKey)
        
*/
//****************************************
//Dictionary Object
//****************************************
/*
function: Dictionary
Parameters: None
Returns: A new Dictionary object.
Actions: Constructor.
*/
function Dictionary(){
//Properties
  //~Public
  this.Count = 0;
  //~Private
  this.Obj = new Object();
//Methods
  //~Public
  this.Exists = Dictionary_Exists;
  this.Add = Dictionary_Add;
  this.Remove = Dictionary_Remove;
  this.RemoveAll = Dictionary_RemoveAll;
  this.Keys = Dictionary_Keys;
  this.Items = Dictionary_Items;

  this.Key = Dictionary_Key;
  this.Item = Dictionary_Item;
  this.item = Dictionary_Item;

  this.values = Dictionary_values;
  this.getVal = Dictionary_getVal;
  this.setVal = Dictionary_setVal;
  this.setKey = Dictionary_setKey;
}
//****************************************
//Method implementations
//****************************************
/*
function: Dictionary_Exists
implements: Dictionary.Exists
Parameters:
    (String) sKey - Key name being looked for.
Returns: (BOOL) - true if sKey is found ; false if it is not.
Actions: Iterates through all Dictionary Keys and checks for sKey.
*/
function Dictionary_Exists(sKey){
  return (this.Obj[sKey])?true:false;
}
//****************************************
/*
function: Dictionary_Add
implements: Dictionary.Add
Parameters:
    (String) sKey - Key name to be Added.
    (Any)    aVal - Value to be associated with sKey.
Returns: (BOOL) - true if sKey is created ; false if it is not (because of a duplicate Key name).
Actions: Adds a new Key=Value pair to the Dictionary.
*/
function Dictionary_Add(sKey,aVal){
  var K = String(sKey);
  if(this.Exists(K)) return false;
  this.Obj[K] = aVal;
  this.Count++;
  return true;
}
//****************************************
/*
function Dictionary_Remove
implements: Dictionary.Remove
Parameters:
    (String) sKey - Key to be Removed.
Returns: (BOOL) - true if sKey has been Removed ; false if it has not (did not exist).
Actions: Removes a specified key from the Dictionary.
*/
function Dictionary_Remove(sKey){
  var K = String(sKey);
  if(!this.Exists(K)) return false;
  delete this.Obj[K];
  this.Count--;
  return true;
}
//****************************************
/*
function: Dictionary_RemoveAll
implements: Dictionary.RemoveAll
Parameters: None
Returns: Nothing
Actions: Removes all key=value pairs from a Dictionary object.
*/
function Dictionary_RemoveAll(){
  for(var key in this.Obj) delete this.Obj[key];
  this.Count = 0;
}
//****************************************
/*
function: Dictionary_values
implements: Dictionary.values
Parameters: None
Returns: Returns an Array containing all the item values in a Dictionary object.
Actions: Iterates through the Dictionary name=value pairs and builds an Array of all values.
*/
function Dictionary_values(){
  var Arr = new Array();
  for(var key in this.Obj) Arr[Arr.length] = this.Obj[key];
  return Arr;
}
//****************************************
/*
function: Dictionary_Keys
implements: Dictionary.Keys
Parameters: None
Returns: Returns an Array containing all existing Keys in a Dictionary object.
Actions: Iterates through the Dictionary name=value pairs and builds an Array of all Keys.
*/
function Dictionary_Keys(){
  var Arr = new Array();
  for(var key in this.Obj) Arr[Arr.length] = key;
  return Arr;
}
//****************************************
/*
function: Dictionary_Items
implements: Dictionary.Items
Parameters: None
Returns: Returns a bidimensional Array containing all existing Keys=value pairs in a Dictionary object.
Actions:
    - Iterates through the Dictionary key=value pairs and builds a bidimensional Array.
    - First index contains the key name ; second index contains the value:
        ex. Arr[0][0] is the key name of the first Dictionary item
            Arr[0][1] is the value of the first Dictionary item
*/
function Dictionary_Items(){
    /*
  var Arr = new Array();
  for(var key in this.Obj){
    var A = new Array(key,this.Obj[key]);
    Arr[Arr.length] = A;
  }
  return Arr;
  */
  var Arr = new Array();
  for(var key in this.Obj) Arr[Arr.length] = this.Obj[key];
  return Arr;  
}
//****************************************
/*
function: Dictionary_getVal
implements: Dictionary.getVal
Parameters:
    (String) sKey
Returns: Item value for the passed sKey.
Actions: Retrieves the Dictionary item value corresponding to sKey.
*/
function Dictionary_getVal(sKey){
  var K = String(sKey);
  return this.Obj[K];
}
//****************************************
/*
function: Dictionary_setVal
implements: Dictionary.setVal
Parameters:
    (String) sKey
    (Any)    aVal
Returns: Nothing.
Actions:
    - Sets the Dictionary item value corresponding to sKey to aVal.
    - If The key is not found in the dictionary it is created.
*/
function Dictionary_setVal(sKey,aVal){
  var K = String(sKey);
  if(this.Exists(K))
    this.Obj[K] = aVal;
  else
    this.Add(K,aVal);
}
//****************************************
/*
function: Dictionary_setKey
implements: Dictionary.setKey
Parameters:
    (String) sKey
    (String) sNewKey
Returns: Nothing.
Actions:
    - Changes sKey to sNewKey
    - if sKey is not found, creates a new item with key=sNewKey and value=null
    - if sKey is not found, but sNewKey is found - does nothing.
    - if sKey and sNewKey both exist - does nothing.
*/
function Dictionary_setKey(sKey,sNewKey){
  var K = String(sKey);
  var Nk = String(sNewKey);
  if(this.Exists(K)){
    if(!this.Exists(Nk)){
      this.Add(Nk,this.getVal(K));
      this.Remove(K);
    }
  }
  else if(!this.Exists(Nk)) this.Add(Nk,null);
}
//****************************************
/*
function: Dictionary_Item
implements: Dictionary.Item
Parameters:
    (String) sKey
Returns: Item value for the passed sKey.
Actions: Retrieves the Dictionary item value corresponding to sKey.
*/
function Dictionary_Item(sKey){
  var K = String(sKey);
  return this.Obj[K];
}
//****************************************
/*
function: Dictionary_Key
implements: Dictionary.Key
Parameters:
    (String) sKey
Returns: Nothing.
Actions:
    - Changes sKey to sNewKey
    - if sKey is not found, creates a new item with key=sNewKey and value=null
    - if sKey is not found, but sNewKey is found - does nothing.
    - if sKey and sNewKey both exist - does nothing.
*/
function Dictionary_Key(sKey){
  var K = String(sKey);
  if(!this.Exists(K)){
    this.Add(K,null);
  }
}
//****************************************