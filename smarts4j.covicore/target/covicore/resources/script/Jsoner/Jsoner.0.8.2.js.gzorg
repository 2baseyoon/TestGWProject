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
*/

//--- JSONER.0.8.2.08 ---
//
/*

 //JSONER.0.8.2.08
 16.12.16 - different 속성비교시 key가 없는 경우도 포함
 
 //JSONER.0.8.2.07
 16.12.07 - has() 메서드 오류 수정
 
 //JSONER.0.8.2.06
 16.12.02 - has() 필터내 ">" 구문 사용 오류 수정
 
 //JSONER.0.8.2.05.1
 16.12.02 - concat() 오류 수정
 
 //JSONER.0.8.2.05
 16.12.01 - children() 배열이 시작지점인 경우 해당 인덱스의 요소를 반환
 
 //JSONER.0.8.2.04
 16.12.01 - remove() 배열의 요소가 시작 지점인 경우 상위 노드가 삭제되는 오류 수정
 
 //JSONER.0.8.2.03
 16.11.30 - eq() 인덱스 초과시 빈 jsoner 오브젝트 반환 
*/

//--------------------------------------------
// WRAPPER
//--------------------------------------------
function $$(json){ 
  if (typeof json === 'object' && json.hasOwnProperty('pack') && json.hasOwnProperty('root')) {
    return json;
  } else {
    var root = json;
    return new Jsoner(json, root);   
  }
}
//--------------------------------------------
// JSONER CLASS
//--------------------------------------------
function Jsoner (json, root) {
  var rootobj = [];
  var obj = (typeof json == 'object') ? json : (json !== undefined && json != null ? JSON.parse(json) : null); 
  if(obj===null) return;

  var childobj, rootobj=[];
  if(Array.isArray(obj)){
    rootobj = obj;
  }else{
    childobj = this.makeObject(obj,'','/','');
    rootobj.push(childobj);
  }

  this.pack = this.makeRootObject(rootobj, '');
  this.root = root;
  this.length = rootobj.length;
}
//--------------------------------------------
// JSONER PARENT CLASS
//--------------------------------------------
function JsonQuery (json) {
  this.getPath = getPath;
  this.getPathObjects = getPathObjects;
  this.getObjects = getObjects;
  this.matchAttr = matchAttr;
  this.hasObjects = hasObjects;
  this.hasObjectsOrNot = hasObjectsOrNot;
  this.makeObject = makeObject;
  this.makeRootObject = makeRootObject;
  this.stringToObject = stringToObject;
  this.parentPath = parentPath;
  this.parentArrayPath = parentArrayPath;
  this.checkEmpty = checkEmpty;
  this.validIndex = validIndex;
  this.getParentNode = getParentNode;

  //--------------------------------------------
  // CLASS MEMBER FUNCTION : START
  //--------------------------------------------
  function parentPath(s){
    // formt==>   /root/sub1/sub2...
    var arr = s.split('/');
    arr.splice(arr.length-1,1);
    arr.splice(0,1);
    return '/' + arr.join('/');
  }

  function parentArrayPath(s){
    // formt==>   /root/sub1/sub2...
    var arr = s.split('/');
    var lastnode = arr[arr.length-1];
    var arrLastnode = lastnode.split('[');
    var suffix = '';
    //마지막 노드가 배열 요소인 경우
    if(arrLastnode.length > 1){
      suffix = '/' + arrLastnode[0];
    }
    arr.splice(arr.length-1,1);
    arr.splice(0,1);
    return '/' + arr.join('/') + suffix;
  }

  function makeRootObject(obj, context){  
    var objects ={
      jsoner: obj,
      context: context,
    };
    return objects;
  }

  function makeObject(obj, node, path, parent){
    var objects ={
      json: obj,
      node: node,
      path: path,
      parent: parent,
      length: Array.isArray(obj) ? obj.length : 1
    };
    return objects;
  }

  function getPath(path) {
    var p = path.split('>');
    var nodename,keyname,valname, keys=[], vals=[], comparison=[], filter; 

    for(var i=0;i<p.length;i++){
      //[ 또는 : 으로 시작
      if(p[i].indexOf('[')<0){
        nodename = p[i];
      } else {
        if(p[i].indexOf(':has')<0){
          var at = p[i].split('[');
          if(p[i].indexOf('[')>0){
            nodename = at[0];
          }
          at.splice(0,1); //remove nodename item      
          for(var j=0; j<at.length;j++){
            at[j] = at[j].replace(']','');
            var atb, comparisonType;
            if(at[j].indexOf('!=') > 0) {
              atb = at[j].split('!=');
              comparisonType = 'different';
            } else if(at[j].indexOf('^=') > 0) {
              atb = at[j].split('^=');
              comparisonType = 'begin';
            } else if(at[j].indexOf('$=') > 0) {
              atb = at[j].split('$=');
              comparisonType = 'end';
            } else if(at[j].indexOf('~=') > 0) {
              atb = at[j].split('~=');
              comparisonType = 'contain';
              //} else if(at[j].indexOf('=') > 0) {
            } else {
              atb = at[j].split('=');
              comparisonType = 'equal';
            } 

            keyname = atb[0].trim();
            valname = atb.length > 1 ? atb[1].trim().replace(/^["|']|["|']$/g, '') : ''; //remove double quote , single quote 

            keys.push(keyname);
            vals.push(valname);
            comparison.push(comparisonType);
          }  
        } else {
          nodename = p[i].split(':has(')[0];
          filter = p[i].split('(')[1].replace(')','');
        }

      }
    }
    return {
      path : path,
      node: nodename,
      keys : keys,
      vals : vals,
      comparison : comparison,
      filter : filter
    }
  }
  function getLastNode(s){
    var t = s.split('/');
    return t[t.length-1];
  }
  function getParentNode(s){
    var t = s.split('/');
    var i = t.length-2;

    return i >= 0 ? t[i] : '';
  }
  //path : object
  function getPathObjects(obj, oPath, childonly) {

    var po = [];
    var arr = [];
    var pathObjects, fobjects, item, npath, path, arrHaspath, filter, haschildonly;

    if(Array.isArray(obj)){
      arr = obj;
    }else{
      arr.push(obj);
    }

    for (var i=0; i<arr.length; i++) {
      item = arr[i];
      npath = item.path;

      arrHaspath = oPath.path.split(':has'); //node:has(subnode[key=val])

      if(arrHaspath.length > 0){
        pathObjects = getObjects(item.json, this.getPath(arrHaspath[0]), npath, childonly);

        if(arrHaspath.length > 1){
          for(var k=0; k<pathObjects.length; k++){
            filter = arrHaspath[1].replace('(','').replace(')','');
            haschildonly = filter.indexOf('|||a|||') === 0;
            filter = filter.replace(/^\|\|\|a\|\|\|/,'');
            //fobjects = hasObjects(pathObjects[k], this.getPath(filter) , false);
            path = this.getPath(filter);
            fobjects = hasObjects(pathObjects[k], path , haschildonly);
            po = po.concat(fobjects);
          }
        } else {
          po = po.concat(pathObjects);     
        }    
      }
    }

    return po;
  }

  function getObjects(obj, path, npath, childonly) {
    var node = path.hasOwnProperty('node') ? path.node : null, 
        keys = path.hasOwnProperty('keys') ? path.keys : null,
        vals = path.hasOwnProperty('vals') ? path.vals : null,
        comparison = path.hasOwnProperty('comparison') ? path.comparison : null;

    var objects = [];
    var objType = Array.isArray(obj) ? 'array' : 'object';
    var n = 0;
    var parentpath = npath ? npath : '';
    var nodepath;
    var arraypath = '';
    var o;
    var selfnode;
    var parent;

    selfnode = getLastNode(parentpath);
    parent = getParentNode(parentpath);
    //키 비교
    if ( (node == '' || node == undefined) && matchAttr(obj, keys, vals, comparison))  { //
      //obj, node, path, parent
      o = makeObject(obj, selfnode, parentpath, parent);      
      objects.push(o);
    }     

    //노드 비교
    if(objType == 'array'){
      for (var i in obj) {
        if(typeof obj[i] !== 'object') continue;

        nodepath = parentpath + '[' + i + ']'  ;

        if(node === ''){
          if(matchAttr(obj[i], keys, vals, comparison)){
            selfnode = getLastNode(nodepath);          
            o = makeObject(obj[i], selfnode, nodepath, parent);   
            objects.push(o);
          }        
        }else{
          for (var j in obj[i]) {
            if (!obj[i].hasOwnProperty(j)) continue;

            if(j==node){
              parent = nodepath;            
              nodepath = nodepath + '/' + j;
              if(keys != null && keys.length > 0){
                if(matchAttr(obj[i][j], keys, vals, comparison)) {
                  selfnode = getLastNode(nodepath);  
                  o = makeObject(obj[i][j], selfnode, nodepath, parent);    
                  objects.push(o);
                }
              }else{
                o = makeObject(obj[i][j], selfnode, nodepath, parent);    
                objects.push(o);
              }
            }
          }
        }

      }
    }else{
      for (var i in obj) {
        if (!obj.hasOwnProperty(i)) continue;

        if (typeof obj[i] == 'object') {

          if(objType == 'array'){
            nodepath = parentpath + '[' + i + ']'  ;
          }else{
            nodepath = (parentpath != '/' ? parentpath : '') + '/' + i;
          }

          if(node && i==node) {
            if(Array.isArray(obj[i]) && ((keys != null && keys.length > 0) || (vals != null && vals.length > 0))){
              for(var n=0; n<obj[i].length; n++){
                if(typeof obj[i][n] === 'object' && matchAttr(obj[i][n], keys, vals, comparison)){
                  selfnode = getLastNode(nodepath);
                  parent = getParentNode(nodepath); 
                  //obj, node, path, parent
                  o = makeObject(obj[i][n], selfnode, nodepath + '[' + n + ']', parent);
                  objects.push(o);
                }             
              }

            }else{
              if(matchAttr(obj[i], keys, vals, comparison)){
                selfnode = getLastNode(nodepath);
                parent = getParentNode(nodepath);          
                //obj, node, path, parent
                o = makeObject(obj[i], selfnode, nodepath, parent);
                objects.push(o);
              }          
            }

          } else if(childonly===false) {
            objects = objects.concat(getObjects(obj[i], path, nodepath, childonly));    
          }
        }
      }
    }

    return objects;
  }

  function matchAttr(obj, keys, vals, comparison){
    var keyarrary, valarray, comparray;
    if(!Array.isArray(keys)) {
      keyarrary = [].push(keys);
      valarray = [].push(vals);
      comparray = [].push(comparison);
    } else {
      keyarrary = keys;
      valarray = vals;
      comparray = comparison;
    }

    var matched = true;
    for(var i=0; i<keyarrary.length; i++){
      var key = keyarrary[i];
      var val = valarray[i];
      var comp = comparray[i];

      var keyonly = obj[key] && (val == undefined || val == '');
      var keyCompare;
      if(comp == 'equal'){
        keyCompare = obj[key] && (obj[key] == val);
      }else if(comp == 'different'){
        keyCompare = !obj.hasOwnProperty(key) || (obj[key] && obj[key] != val);
      }else if(comp == 'begin'){
        keyCompare = obj[key] && (obj[key].indexOf(val) === 0);
      }else if(comp == 'end'){
        keyCompare = obj[key] && (obj[key].indexOf(val) === (obj[key].length - val.length));
      }else if(comp == 'contain'){
        keyCompare = obj[key] && (obj[key].indexOf(val) > -1);
      }

      if(keyonly){
      } else if(keyCompare){
      } else {
        matched = false;
        break;
      }
    }

    return matched;
  }

  function hasObjects(obj, path, childonly) {
    var node = path.hasOwnProperty('node') ? path.node : null, 
        keys = path.hasOwnProperty('keys') ? path.keys : null,
        vals = path.hasOwnProperty('vals') ? path.vals : null,
        comparison = path.hasOwnProperty('comparison') ? path.comparison : null;

    var objects = [];
    var depth = childonly === true ? 1: 0;
    var jsoner = [];
    if(Array.isArray(obj)) {
      jsoner = obj;
    }else{
      jsoner.push(obj)
    }
    for (var i=0; i<jsoner.length; i++) {
      if (!jsoner.hasOwnProperty(i)) continue;     
      var hasObj = hasObjectsOrNot(jsoner[i].json, node, keys, vals, comparison, depth);
      if(hasObj===true){
        objects.push(jsoner[i]);
      }
    }

    return objects;
  }

  function hasObjectsOrNot(obj, node, keys, vals, comparison, depth) {
    var has = false;
    for (var i in obj) {
      if (!obj.hasOwnProperty(i)) continue;
      //노드네임이 정의된 경우만 하위개체 참조
      if (depth === 1 && (node == undefined || node == '')) break;

      if (typeof obj[i] == 'object') {
        if(node && i==node) {
          if(Array.isArray(obj[i]) && (keys.length > 0 || vals.length > 0)){
            for(var n=0; n<obj[i].length; n++){
              if(typeof obj[i][n] === 'object' && matchAttr(obj[i][n], keys, vals, comparison)){
                return true;
              }
            }
          }else{
            if(matchAttr(obj[i], keys, vals, comparison)){
              return true;
            }         
          }        

        } else { 
          //노드가 일치하지 않거나, 노드가 없는 경우
          //노드가 없는 경우 : 키/값 비교를 하므로, depth가 정의되지 않은 경우에 한해 하위 노드를 다시 호출
          //노드가 일치하지 않는 경우, 
          if(depth == undefined || depth === 0){
            has = has || hasObjectsOrNot(obj[i], node, keys, vals, comparison);    
          }        
        }
      }
    }

    //키/값 비교
    if (node == '' || node == undefined) { //
      if( matchAttr(obj, keys, vals, comparison) ){
        has = true;    
      }
    }
    return has;
  } 


  function stringToObject(oJson, s, lastPath){
    let path = s.split('/');
    path.splice(0,1);// 맨 앞의 슬래시 포함 인덱스 제거

    var o = oJson, o2 = {}, objs = [], currpath = (lastPath === undefined ? '' : lastPath);
    for(var i=0; i<path.length; i++){
      var item = path[i];
      var arrItem = item.split('[');
      var node, index;      

      if(arrItem.length === 1){
        node = arrItem[0];
        if(!Array.isArray(o)){
          o = o.hasOwnProperty(node) ? o[node] : null;
          if(o) {
            currpath += '/' + node;
          }else{
            break;
          }
        }else{
          //현재 노드가 배열인 경우, 배열요소에서 node를 검색
          var suffix = makeSuffixPath(path, i);
          var subObjLength = o.length;
          for(var j=0; j<subObjLength; j++){
            var tmp = stringToObject(o[j], suffix, currpath + '[' + j + ']');      
            if(tmp.length > 0) {
              if(Array.isArray(tmp)){
                objs = objs.concat(tmp);
              }else{
                objs.push(tmp);
              }
            }
          }
          return objs;          
        }

      } else {
        node = arrItem[0];
        index = arrItem[1].replace(/\]/g,'');
        o = o[node][parseInt(index)];
        currpath += '/' + item;    
      }
    }

    if(o !== null && o !== undefined) {
      objs.push({ obj: o, path: currpath } );
    }

    return objs;    

    function makeSuffixPath(arrPath, i){
      var newpath = '';
      if(arrPath.length > i){
        for(var n=i; n<arrPath.length; n++){
          newpath += '/' + arrPath[n];
        }    
      }
      return newpath;
    }
  }

  function checkEmpty(obj) {
    for(var prop in obj) {
      if(obj.hasOwnProperty(prop))
        return false;
    }

    return true;
  }

  function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  }

  function validIndex(n) {
    return isNumber(n) && n > -1;
  }  
  //--------------------------------------------
  // function : END
  //--------------------------------------------
}

//--------------------------------------------
// JSONER METHOD RETURNING JSONER OBJECT
//--------------------------------------------

JsonQuery.prototype.findpath = function(path){

  var oPath = this.getPath(path);
  var ob = this.pack.jsoner;
  var jsoner = [];
  if(!Array.isArray(ob)){
    jsoner.push(ob);
  } else {
    jsoner = ob;
  }

  var objects = this.getPathObjects(jsoner, oPath);

  return (new Jsoner(objects, this.root));
}


//isArray : boolean : true => 3차원 배열로 반환
JsonQuery.prototype.getTrimPath = function(path, isArray){
	
  //[IE 10 이하  const 사용 오류]
  /*const C_SPACE = '|||s|||';
  const C_SPACE_RE = '\\|\\|\\|s\\|\\|\\|';
  const C_COMMA = '|||c|||';
  const C_ARROW = '|||a|||';
  const C_ARROW_RE = '\\|\\|\\|a\\|\\|\\|';*/

  // 선언 이외의 곳에서 값 변경 X
  var C_SPACE = '|||s|||';
  var C_SPACE_RE = '\\|\\|\\|s\\|\\|\\|';
  var C_COMMA = '|||c|||';
  var C_ARROW = '|||a|||';
  var C_ARROW_RE = '\\|\\|\\|a\\|\\|\\|';

  var tpath = trimPath(path);
  if(isArray && isArray === true){
    return trimPathArray(tpath);
  }else{
    return tpath;
  }

  function trimPathArray(tpath){
    var c = tpath.split(C_COMMA), s, a;
    for(var i=0; i<c.length; i++){
      s = c[i].split(C_SPACE);
      for(var j=0; j<s.length; j++){
        var x = s[j];
        var yyy = tpath;
        s[j] = mergeParenth(s[j], C_ARROW, yyy);        
      }  
      c[i] = s;
    }

    return c;
  }

  function trimPath(path, spaceDel, commaDel, arrowDel){

    var spaceDelimiter = spaceDel ? spaceDel : C_SPACE;
    var commaDelimiter = commaDel ? commaDel : C_COMMA;
    var arrowDelimiter = arrowDel ? arrowDel : C_ARROW;
    var arrComma;
    var arrSpace, arrGt, arrBracketTail, arrBracketHead;
    var result;

    //trim -step1
    arrBracketTail = path.trim().split(']');  //--->  ]

    for(var j=0; j<arrBracketTail.length; j++){
      //trim -step2
      arrBracketTail[j] = trimHeadSpace(arrBracketTail[j], spaceDelimiter);
      arrBracketHead = arrBracketTail[j].split('[');  //--->  [

      for(var k=0; k<arrBracketHead.length; k++){
        //trim -step3
        arrBracketHead[k] = trimTailspace(arrBracketHead[k], spaceDelimiter);
        if(arrBracketHead.length === 1 || k<arrBracketHead.length-1){
          //split the string that does not containe bracket
          arrComma = arrBracketHead[k].split(','); 
          for(var n=0; n<arrComma.length; n++){
            arrComma[n] = arrComma[n].trim().replace(/\s+/g,spaceDelimiter);
          }

          arrBracketHead[k] = arrComma.join(commaDelimiter);    
          arrBracketHead[k] = replaceArrowOuterParenthesis(arrBracketHead[k], arrowDelimiter);

          arrBracketHead[k] = arrBracketHead[k].replace(arrowDelimiter + spaceDelimiter,arrowDelimiter);  
          arrBracketHead[k] = arrBracketHead[k].replace(spaceDelimiter + arrowDelimiter,arrowDelimiter);  

        }
        arrBracketHead[k] = arrBracketHead[k].replace(commaDelimiter + spaceDelimiter,commaDelimiter);       }

      arrBracketTail[j] = arrBracketHead.join('[');
    }

    //trim -step4
    var newpath = arrBracketTail.join(']');

    //space + arrow => arrow
    var regEx = new RegExp(C_SPACE_RE+C_ARROW_RE, 'gi');
    newpath = newpath.replace(regEx,C_ARROW);
    //arrow + space => arrow
    regEx = new RegExp(C_ARROW_RE+C_SPACE_RE, 'gi');
    newpath = newpath.replace(regEx,C_ARROW);

    var arrNewpath = newpath.split(arrowDelimiter);
    for(var i=0; i<arrNewpath.length; i++){
      arrNewpath[i] = arrNewpath[i].trim();
    }
    result = arrNewpath.join(arrowDelimiter);
    return result;
  }

  
  function replaceArrowOuterParenthesis(str, arrowDelimiter){
    var arrArrows = str.split('>');
    var joinedArrows = '';
    var outerParenth = true;
    for(var i=0;i<arrArrows.length;i++){
      var ap = arrArrows[i].indexOf('(');
      if(ap > -1){
        outerParenth = false;
        if(ap < arrArrows[i].indexOf(')')){
          outerParenth = true;
        }
      }else{
        if(arrArrows[i].indexOf(')') > -1){
          outerParenth = true;
        }
      }
      if(outerParenth){
        joinedArrows += arrArrows[i] + (arrArrows.length !==i+1 ? arrowDelimiter : '');
      }else{
        joinedArrows += arrArrows[i] + (arrArrows.length !==i+1 ? '>' : '');
      }
    }
    return joinedArrows;
    //arrBracketHead[k] = joinedArrows;
  }



  function trimHeadSpace(s, spaceDelimiter){
    return (s.substr(0,1) === ' ' ? spaceDelimiter : '') + s.replace(/^\s+/,"");
  }

  function trimTailspace(s, spaceDelimiter){
    return s.replace(/\s+$/,'') + (s.substr(s.length-1,1) === ' ' ? spaceDelimiter : '');
  } 

  function mergeParenth(s, d, yyy){
    var found0=-1, found1=-1;
    var newArr = [], mstr;
    var x = s.split(C_ARROW);
    for(var i=0; i<x.length; i++){
      if(found0 < 0){
        if(x[i].indexOf('(') > -1 && x[i].indexOf(')') < 0){
          found0 = i;
        }else{
          newArr.push(x[i]);
        }
      }else if(found0 > -1 && x[i].indexOf(')') > -1) {
        found1 = i;
        mstr = '';
        for(var j=found0; j<=found1;j++){
          mstr = mstr + (j > 0 ? d : '') + x[j];
        }
        newArr.push(mstr);
        found0 = -1;
        found1 = -1;
      }   
    }
    return newArr;
  }
}

JsonQuery.prototype.find = function(path){

  var arrCommaPath = this.getTrimPath(path, true); //[comma][space]
  var ob = this.pack.jsoner;  //array
  var jsoner = [];
  if(!Array.isArray(ob)){
    jsoner.push(ob);
  } else {
    jsoner = ob;
  }  

  var subpath, objects = [], subjson;
  for(var j=0;j<jsoner.length;j++){
    for(var k=0;k<arrCommaPath.length;k++){
      subjson = findx(jsoner[j], arrCommaPath[k], this);
      if(subjson !== null){
        objects = objects.concat(subjson);
      }
    }
  }

  return (new Jsoner(objects, this.root));

  //--- function for findX method : start
  function getPathProp(path){
    var arrSelfpath = path.split('/');
    var selfnode = arrSelfpath[arrSelfpath.length-1];
    var parentnode = arrSelfpath.length > 1 ? arrSelfpath[arrSelfpath.length-2] : '';
    return {
      node: selfnode,
      parent: parentnode
    };
  }

  function getQuickSearch(parJsoners, mainpath, oThis){

    var jsoners = [], jsoner, newJsoner, subpath, fullpath, rawObj, pathprop;
    var arrJsoners = [];
    if(!Array.isArray(parJsoners)){
      arrJsoners.push(parJsoners);
    }else{
      arrJsoners = parJsoners;
    }

    for(var i=0; i<arrJsoners.length;i++){
      jsoner = arrJsoners[i];
      subpath = mainpath.replace(/\|\|\|a\|\|\|/g, '/');
      subpath = subpath.replace(/^\//, '');
      fullpath = (jsoner.path + '/' + subpath).replace('//', '/');
      let arrRawObj = oThis.stringToObject(oThis.root, fullpath); //[{ obj: o, path: currpath }..];

      if(arrRawObj.length === 0){
        continue;
      }
      for(var x=0; x<arrRawObj.length; x++){
        rawObj = arrRawObj[x]['obj'];
        fullpath = arrRawObj[x]['path'];
        pathprop = getPathProp(fullpath);
        newJsoner = oThis.makeObject(rawObj, pathprop.node, fullpath, pathprop.parent);
        jsoners.push(newJsoner);      
      }

    }

    return jsoners;
  }

  function getSubPathObject(subpath, oJsoner, oThis, childonly){
    if(subpath == '') return oJsoner;
    var oPath = oThis.getPath(subpath);
    var oJsoner = oThis.getPathObjects(oJsoner, oPath, childonly);

    return oJsoner;
  }
  //arrPath: 1차원배열=space 구분자, 2차원배열=arrow 구분자
  function findx(oJsoner, arrPath, oThis){

    var oPath, objects, arrSubPath, fullpath, bsplit, oRaw, pathprop;
    //
    // space를 구분자로 생성한 배열 => arrPath
    //
    var childonly;
    for(var p=0;p<arrPath.length;p++){ //space
      childonly = false; //space구분 시작 지점은 바로 하위 노드 검색은 false
      // >를 구분자로 생성한 배열 => arrSubPath
      //
      arrSubPath = arrPath[p]; 

      // 경로가 ">" 로 시작하지 않으면 첫 노드 별도 검색
      //
      var firstNodeSearch = false;
      if(arrSubPath[0] !==''){
        firstNodeSearch = true;
        oJsoner = getSubPathObject(arrSubPath[0], oJsoner, oThis, childonly);
        //노드가 1개 뿐 인 경우
        if(arrSubPath.length === 1){
          continue;
        }
        arrSubPath.splice(0,1); // 맨 앞 노드 제거
      }

      //첫째 경로노드가 제거된 경로 => arrMainPath  => (문자열) mainpath
      var mainpath = arrSubPath.join('|||a|||');
      mainpath = (mainpath.indexOf('|||a|||') !==0) ? '|||a|||' + mainpath : mainpath;

      var quickfind = false;
      if(mainpath.indexOf('[') < 0){
        quickfind = true;
      }else{
        //배열 인덱스를 제거한 문자열에 [ 또는 (가 없으면 quickfind = true
        var ptn = '\[[0-9]+\]';
        var str1 = mainpath.replace(/\[[0-9]+\]/g, '');
        quickfind = (str1.indexOf('[') < 0 && str1.indexOf('(') < 0); // [n] 배열 인덱스가 없으면  true
      }

      if(quickfind){
        oJsoner = getQuickSearch(oJsoner, mainpath, oThis);
      } else {
        for(var c=0;c<arrSubPath.length;c++){
          if(c > 0) childonly = true;
          subpath = arrSubPath[c];
          //debugger;
          oJsoner = getSubPathObject(subpath, oJsoner, oThis, childonly);
        }      
      }
    }

    return oJsoner;
  }  
  //--- function for findX method : end

}

//특정 자손 개체를 갖춘 오브젝트를 필터링
JsonQuery.prototype.has = function(path){
  var jsoners = [];
  this.concat().each(function(i, $$){
    var length = $$.find(path).length;
    if(length > 0){
      jsoners.push($$.jsoner(0));
    }
  });
  
  //var oPath = this.getPath(path);
  //var objects = this.hasObjects(this.pack.jsoner, oPath);

  return (new Jsoner(jsoners, this.root));  
}

//특정 자손 개체가 없는 오브젝트를 필터링
JsonQuery.prototype.not = function(path){
  var jsoners = [];
  this.concat().each(function(i, $$){
    var length = $$.find(path).length;
    if(length == 0){
      jsoners.push($$.jsoner(0));
    }
  });

  //var oPath = this.getPath(path);
  //var objects = this.hasObjects(this.pack.jsoner, oPath);

  return (new Jsoner(jsoners, this.root));  
}

//특정 자식 개체를 갖춘 오브젝트를 필터링
JsonQuery.prototype.hasChild = function(path){
  var oPath = this.getPath(path);
  var objects = this.hasObjects(this.pack.jsoner, oPath, true);

  return (new Jsoner(objects, this.root));
}

JsonQuery.prototype.parentArray = function(){
  //const CON_INCLUDE_ARRAY = true;			 //[IE 10 이하  const 사용 오류]
  var CON_INCLUDE_ARRAY = true;				// 선언 이외의 곳에서 값 변경 X
  return this.parent(CON_INCLUDE_ARRAY);
}

//부모개체
JsonQuery.prototype.parent = function(bIncludeArray){
  //parentPath
  //stringToObject
  var root = this.root;
  var objects = [];
  var selfjson = this.pack.jsoner;
  var arrSelfpath, objJson, path, selfpath, selfnode, parentnode, o;

  for(var i=0; i<selfjson.length; i++){
    objJson = selfjson[i].json;
    path = selfjson[i].path;

    if(path == '/') {
      continue;
    }
    
    if(bIncludeArray === true){
      selfpath = this.parentArrayPath(path);
    }else{
      selfpath = this.parentPath(path);
    }

    if(selfpath != '/'){

      arrSelfpath = selfpath.split('/');
      selfnode = arrSelfpath[arrSelfpath.length-1];
      parentnode = arrSelfpath[arrSelfpath.length-2];

      //o = this.stringToObject(root, selfpath);
      var oTmp = this.stringToObject(root, selfpath);
      if(Array.isArray(oTmp)){
        o = oTmp[0].obj;
      }else{
        o = oTmp;
      }

    } else {
      o = root;
      selfnode = '';
      parentnode = '';
    }

    if(o !== null){
      var o2 = this.makeObject(o, selfnode, selfpath, parentnode);
      objects.push(o2);
    }

  }

  return (new Jsoner(objects, this.root));
}

//가장 가까운 조상(ancestor) 검색
JsonQuery.prototype.closest = function(nodename){
  //parentPath
  //stringToObject
  var root = this.root;
  var selfjson = this.pack.jsoner;
  var objects = [];

  for(var i=0; i<selfjson.length; i++){
    var objJson = selfjson[i].json;
    var selfpath = selfjson[i].path;
    //path 내에 nodename이 있는지 확인

    var parentpath = this.parentPath(selfpath);
    var oClosest = getClosestNodePath(parentpath, nodename);
    //var o = this.stringToObject(root, oClosest.path); //path는 맨 앞에 슬래시 없어야 함 
    var o;
    var oTmp = this.stringToObject(root, oClosest.path);
    if(Array.isArray(oTmp)){
      o = oTmp[0].obj;
    }else{
      o = oTmp;
    }
    if(o !== null){
      var o2 = this.makeObject(o, oClosest.node, oClosest.path, oClosest.parent);
      objects.push(o2);
    }
  }

  return (new Jsoner(objects, this.root));

  function getClosestNodePath(parentpath, searchnode){
    var arrPath = parentpath.split('/');
    var lastid = arrPath.length-1;
    var found=false, node='', path='', parent='';
    for(var i=0; i<=lastid; i++){
      var n = lastid - i;
      var s = strip(arrPath[n]);

      if(searchnode == s){
        found = true;
        node = searchnode;
        parent = n > 0 ? strip(arrPath[n-1]) : '';
        break;
      }else{
        arrPath.splice(n, 1);
      }
    }

    if(found ===true){
      path = arrPath.join('/');
    }

    return {
      path : path,
      node : node,
      parent : parent
    };
  }  
  //[] 제거
  function strip(s){
    return s.split('[')[0];
  }
}

//오브젝트가 아닌 속성 키를 제거
JsonQuery.prototype.remove = function(key){
  //obj > json=array > json(object)
  if(this.invalid()) return this;
  var jsoners, objects, oParents;
  //키 삭제
  if(key !== undefined && key !== ''){

    var re = new RegExp(/^\d+$/);
    var isIndex = re.test(key) === true;

    var keys = [];
    keys.push(key);

    this.each(function(i, $$){
      jsoners = $$.pack.jsoner;
      if(isIndex){
        deleteIndex(jsoners[0], key);
        refreshJsonerLength(jsoners[0]);
      }else{
        deleteNode(jsoners, keys);
      }
    });
    
  } else {
    //선택항목의 부모노드에서 키를 삭제
    //삭제후 부모노드를 반환
    this.each(function(i, $$){
      var keys = [];
      var selfJsoners = $$.pack.jsoner;
      var lastNodeIndex = getLastNodeIndex(selfJsoners[0].path);
      if(lastNodeIndex === ''){
        jsoners = $$.parent().pack.jsoner;
        keys = getKeys(selfJsoners);
        deleteNode(jsoners, keys);
      }else{
        jsoners = $$.parentArray().pack.jsoner;
        deleteIndex(jsoners[0], lastNodeIndex);
        refreshJsonerLength(jsoners[0]);
      }
    });

    //jsoners = this.parent().pack.jsoner;
    //keys = getKeys(this.pack.jsoner);
    //deleteNode(jsoners, keys);
  }

  return (new Jsoner(jsoners, this.root));  

  function deleteIndex(jsoner, i){
    jsoner.json.splice(i,1);
  }
  
  function refreshJsonerLength(jsoner){
  	if(Array.isArray(jsoner.json)){
    	jsoner.length = jsoner.json.length;
    }
  }

  function getKeys(jsoners){
    var keys = [];
    for(var i=0;i<jsoners.length;i++){
      keys.push(jsoners[i]['node']);
    }
    return keys;
  }
  function deleteNode(jsoners, keys){
    var key;
    for(var i=0; i<jsoners.length; i++){
      deleteSingleNode(jsoners[i], keys);
    }  
  }
  function deleteSingleNode(jsoner, keys){
    for(var j=0; j<keys.length; j++){
      var key = keys[j];
      delete jsoner.json[key];
    }  
  }
  function getLastNodeIndex(path){
    var arrSelfpath = path.split('/');
    var selfnode = arrSelfpath[arrSelfpath.length-1];
    if (selfnode.indexOf('[') < 0) return '';  
    
    var regExp = /\[([^)]+)\]/;
    var matches = regExp.exec(selfnode);
    return matches[1];
  }
}

//bIncludeKeyName: true-키이름을 포한한 json반환
JsonQuery.prototype.json = function(bIncludeKeyName){
  if(this.invalid()) return this;

  var obj = this.jsonArray();
  var returns = [];
  var keyNeeded = bIncludeKeyName === true;

  if(obj.length===1){
    return keyNeeded ? wrap(obj[0].node, obj[0].json) : obj[0].json;
  }

  for (var n=0; n<obj.length; n++) {
    var item = obj[n];
    var json = keyNeeded ? wrap(item.node, item.json) : item.json;
    returns.push(json);
  }

  return returns;

  function wrap(keyname, val){
    var o = {};
    o[keyname] = val;
    return o;
  }
}

JsonQuery.prototype.attr = function(k, v){
  if(this.invalid()) return this;

  if(typeof v !== 'undefined'){
    var objects = setVal(this.jsonArray(), k, v);
    return (new Jsoner(objects, this.root));
  }else{
    return getVal(this.jsonArray(), k);
  }

  //allChildren=true => 
  function setVal(obj, key, val) {
    if(Array.isArray(obj)) {
      for (var n=0; n<obj.length; n++) {
        var item = obj[n]; //array item
        var json = item.json;
        json[key] = val;
      }
    }
    return obj;
  }     
  function getVal(obj, key) {
    var res = [];
    if(Array.isArray(obj)) {
      for (var n=0; n<obj.length; n++) {
        var json = obj[n].json;
        res.push(json[key]);
      }
    }
    //1개의 인덱스를 가지면 배열이 아닌 값만 반환
    if(res.length === 0) {
      return null;
    } else if(res.length === 1) {
      return res[0];
    }else{
      return res;
    }
  }
} 

//iterater
JsonQuery.prototype.each = function(callback){
  if(this.invalid()) return this;
  var baseJsoners = this.pack.jsoner, jsoner, jsoners=[];
  if (typeof callback === "function") {
    for(var i=0;i<baseJsoners.length;i++){
      //var objects = [];
      jsoners = [];
      //objects.push(baseJsoners[i]);
      jsoner = baseJsoners[i];
      jsoners.push(jsoner);
      callback.apply (callback, [i, (new Jsoner(jsoners, this.root)) ]);
    }
  }

  return (new Jsoner(baseJsoners, this.root));
}
JsonQuery.prototype.concat = function(){
  if(this.invalid()) return this;

  var baseJsoners = this.pack.jsoner, jsoner, newobj, newjsoner, newJsoners=[], path, node, parent;

  for(var i=0;i<baseJsoners.length;i++){
    jsoner = baseJsoners[i];
    if(Array.isArray(jsoner.json)){
      for(var j=0; j<jsoner.json.length; j++){
        var newobj = jsoner.json[j];
        path = jsoner.path + '[' + j + ']';
        node = jsoner.node;
        parent = jsoner.parent;          
        newjsoner = this.makeObject(newobj, node, path, parent);           
        newJsoners.push(newjsoner);
      }
    }else{
      newJsoners.push(jsoner);
    }
  }
  return (new Jsoner(newJsoners, this.root));
}

JsonQuery.prototype.create = function(key){
  if(this.invalid()) return this;

  var newJsoners = [], newjsoner, jsoner, rawObj, node, path, parent;
  var me = this, newobj;

  this.each(function(i, $$){
    $$.append(key, {});

    var arrJsoner = $$.jsoner(); //-----------------------------------------------------
    var jsoner = arrJsoner[0];
    var json  = jsoner.json;
    if(Array.isArray(json)){
      for(var i=0; i<json.length; i++){
        newobj = json[i][key];    
        path = jsoner.path + '[' + i + ']/' + key;
        node = key;
        parent = jsoner.path + '[' + i + ']/';          
        newjsoner = me.makeObject(newobj, node, path, parent);           
        newJsoners.push(newjsoner);
      } 
    }else if (typeof json === 'object'){
      if(Array.isArray(json[key])){ //value가 배열인 경우, 마지막 인덱스 선택 
        var lastid = json[key].length-1;
        newobj = json[key][lastid];
        path = jsoner.path + '/' + key + '[' + lastid + ']'; 
        node = key;
        parent = jsoner.node;
      }else{
        newobj = json[key];
        path = jsoner.path + '/' + key; 
        node = jsoner.parent;
        parent = jsoner.node;
      }

      newjsoner = me.makeObject(newobj, node, path, parent);           
      newJsoners.push(newjsoner);     
    }

  });

  return (new Jsoner(newJsoners, this.root));
}

JsonQuery.prototype.last = function(){
  if(this.invalid()) return this;

  if(this.length === 0){
    return (new Jsoner(null, this.root));
  }else{
    return this.eq(this.length-1);
  }
}

//append
JsonQuery.prototype.append = function(key,val){

  if(this.invalid()) return this;

  var jsoners = this.pack.jsoner;

  var k, v;
  if(val !== undefined && val !== null){ //value를 지정한 경우, JSON lib변경으로 인해 null 비교 추가.
    append(jsoners, key, val);    
  }else if(typeof key === 'object'){
    for(var i in key){
      if (!key.hasOwnProperty(i)) continue;
      append(jsoners, i, key[i]);
    }       
  } else { //key가 오브젝트가 아닌 경우
    return this;
  }

  return (new Jsoner(jsoners, this.root));

  function append(jsoners, k, v){
    for(var i=0;i<jsoners.length;i++){
      var json = jsoners[i].json;

      if(!Array.isArray(json)){
        appendNode(json, k, v);
      }else{
        for(var n=0;n<json.length; n++){
          appendNode(json[n], k, v);
        }
      }
    }  
  }

  function isEmpty(myObject) {
    for(var key in myObject) {
      if (myObject.hasOwnProperty(key)) {
        return false;
      }
    }

    return true;
  }

  function appendNode(json, k, v){
    if(json.hasOwnProperty(k)){ //키가 있는 경우
      if(!Array.isArray(json[k])){ //배열이면 인덱스 추가
        var tmp = json[k];
        json[k] = [];
        json[k].push(tmp);
      }
      json[k].push(v);
    } else { //새로운 키를 추가
      json[k] = v;
    } 
  }
}

JsonQuery.prototype.invalid = function(){
  return !(this.hasOwnProperty('pack') && this.pack.hasOwnProperty('jsoner'));
}

//선택된 노드가 빈 오브젝트인지 true/false
JsonQuery.prototype.isEmpty = function(){
  return this.pack.jsoner.length == 1 && this.checkEmpty(this.pack.jsoner[0].json);
}

//--------------------------------------------
// JSONER METHODS RETURNING VALUE
//--------------------------------------------

JsonQuery.prototype.length = function(){
  return this.pack.jsoner.length;
}
//최종 값 기준의 항목 개수
JsonQuery.prototype.valLength = function(){
  var jsoners = this.pack.jsoner;
  var total = 0;
  for(var i=0;i<jsoners.length; i++){
    total += jsoners[i].length;

  }
  return total;
}
JsonQuery.prototype.keyLength = function(){
  return this.pack.jsoner.length;
}
JsonQuery.prototype.jsonArray = function(){
  return this.pack.jsoner;
}

JsonQuery.prototype.nodename = function(){
  return getVal(this.jsonArray());

  function getVal(obj) {
    var res = [];
    if(Array.isArray(obj)) {
      for (var n=0; n<obj.length; n++) {
        res.push(obj[n].node.split('[')[0]); //배열 인덱스 제거
      }
    }
    //1개의 인덱스를 가지면 배열이 아닌 값만 반환
    if(res.length === 1) {
      return res[0];
    }else{
      return res;
    }
  }
} 

JsonQuery.prototype.love = function(i){
  return this.children(i);
}

JsonQuery.prototype.children = function(i){
  if(this.invalid()) return this;

  //하위 노드를 반환
  if(i !== undefined && !this.validIndex(i)) {
    return this.find('>' + i);
  }
  var me = this;
  var newJsoners = [], newJsoner, node, json, rawJson, fullpath, parent, iStart, iEnd, nodeSuffix;  
  this.each(function(index, $$){
      var jsoners = $$.pack.jsoner;  //2 array
      var jsoner = jsoners[0];
      var json = jsoners[0].json;
      var path = jsoners[0].path;
      var fullpath = (path == '/' ? '' : path);
            
      if(i !== undefined && Array.isArray(json)){
        parent = me.getParentNode(fullpath);
        nodeSuffix = '[' + i + ']';
        node = jsoner.node;// + nodeSuffix;
        rawJson = json[i];
        newJsoner = me.makeObject(rawJson, node, fullpath + nodeSuffix, parent);
        newJsoners.push(newJsoner);          
      }else{
        if(Array.isArray(json)){
          parent = me.getParentNode(fullpath);
          for(var j in json) {
            nodeSuffix = '[' + j + ']';
            node = jsoner.node;// + nodeSuffix;
            rawJson = json[j];
            newJsoner = me.makeObject(rawJson, node, fullpath + nodeSuffix, parent);
            newJsoners.push(newJsoner);        
          } 
        }else{
          var searchAll = (i === undefined);
          parent = jsoner.node;
          var n = 0;
          for(var j in json) {
            if(json.hasOwnProperty(j) && typeof json[j] === 'object') {
              if(searchAll || n===i) {
                node = j;
                rawJson = json[j];
                newJsoner = me.makeObject(rawJson, node, fullpath + '/' + node, parent);
                newJsoners.push(newJsoner);      
                if(n===i) break;
              }
              n++;
            }
          }          
        }
      }
  });


  return (new Jsoner(newJsoners, this.root));

}

JsonQuery.prototype.jsoner = function(i){
  if(this.invalid()) return this;

  var re = new RegExp(/^\d+$/);
  var res;
  if(i !== undefined){
    if(!this.checkIndex(i, this.pack.jsoner)){
      res = null;
    }else{
      res = this.pack.jsoner[i];
    }
  }else{
    res = this.pack.jsoner;
  }
  return res;
}
JsonQuery.prototype.checkIndex = function(i, arr){
  var re = new RegExp(/^\d+$/);
  if(i === undefined || re.test(i) === false){
    if(window.console) console.log('index needed!');
    return false;
  }

  if(!Array.isArray(arr) || parseInt(i) > arr.length-1){
    if(window.console) console.log('index limit exceeded!');
    return false;
  }

  return true;
}
JsonQuery.prototype.eq = function(i){
  if(this.invalid()) return this;

  var re = new RegExp(/^\d+$/), rawJson, jsoner, newJsoner, newJsoners=[];
  if(i === undefined || re.test(i) === false){
    //return null;
    return (new Jsoner([], this.root));
  }

  jsoner = this.jsoner();
  if(!this.checkIndex(i, jsoner)){
    //return null;
    return (new Jsoner([], this.root));
  }

  rawJson = jsoner[i].json;
  newJsoner = this.makeObject(rawJson, jsoner[i].node, jsoner[i].path, jsoner[i].parent);
  newJsoners.push(newJsoner);
  return (new Jsoner(newJsoners, this.root));
}
JsonQuery.prototype.index = function(){
  var rawNodes = this.jsoner()[0].path.split('[');
  return rawNodes.length > 1 ? rawNodes[rawNodes.length - 1].replace(']','') : 0;
}

JsonQuery.prototype.sibling = function(n){
  if(this.invalid()) return this;

  var newJsoners=[];
  var oldJsoner = this.jsoner();
  var addStep = parseInt(n);

  for(var k=0; k<oldJsoner.length;k++){

    var currPath = oldJsoner[k].path;
    var arrPath = currPath.split('/');
    var currNode = arrPath[arrPath.length-1];
    var currIndex = getIndex(currNode);

    if(currIndex == '' || currIndex == null) continue;
    currIndex = parseInt(currIndex);

    var newIndex = currIndex + addStep;
    var jsoners = [];

    if(newIndex > -1){
      var newNode = setIndex(currNode, newIndex);
      arrPath.splice(arrPath.length-1,1); //마지막 인덱스 삭제
      var newPath = arrPath.join('/') + '/' + newNode;
      //rawObj = this.stringToObject(this.root, newPath);
      var rawObj;
      var oTmp = this.stringToObject(this.root, newPath);
      if(Array.isArray(oTmp)){
        rawObj = oTmp[0].obj;
      }else{
        rawObj = oTmp;
      }

      if(rawObj !== null && rawObj !== undefined){
        var pathprop = getPathProp(newPath);
        var newJsoner = this.makeObject(rawObj, pathprop.node, newPath, pathprop.parent);
        newJsoners.push(newJsoner);  
      }
    }
  }

  return (new Jsoner(newJsoners, this.root));

  function getIndex(s) {
    if(s.indexOf('[') < 0) return '';
    var regExp = /\[([^)]+)\]/;
    var matches = regExp.exec(s);
    return matches[1];
  }

  function setIndex(t, r) {
    return t.replace(/\[([^)]+)\]/,'['+r+']');
  }

  //--- function for findX method : start
  function getPathProp(path){
    var arrSelfpath = path.split('/');
    var selfnode = arrSelfpath[arrSelfpath.length-1];
    var parentnode = arrSelfpath.length > 1 ? arrSelfpath[arrSelfpath.length-2] : '';
    return {
      node: selfnode,
      parent: parentnode
    };
  }
}

JsonQuery.prototype.prev = function(){
  return this.sibling(-1);
}
JsonQuery.prototype.next = function(){
  return this.sibling(1);
}
JsonQuery.prototype.path = function(){
  var objects = this.pack.jsoner;
  var paths = [];

  for(var i=0;i<objects.length;i++){
    paths.push(objects[i].path);
  }

  if(paths.length===1){
    paths = paths[0];
  }
  return paths;
}
JsonQuery.prototype.comparePath = function(obj){
  return this.path() == obj.path();
}
JsonQuery.prototype.text = function(){
  return this.attr('#text');
}
JsonQuery.prototype.exist = function(){
  return (this.length > 0);
}
//--------------------------------------------
// JSONER CLASS INHERIT PARENT CLASS
//--------------------------------------------

Jsoner.prototype = new JsonQuery();

