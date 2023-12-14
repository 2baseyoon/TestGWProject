define(['webhwpapp/hwp/HwpCtrlID', "webhwpapp/hwp/HwpDef"], function(HwpCtrlID, HwpDef){

    var COLDEFtoSTR = function(ctrl, dataArray) {
        dataArray.push(
            ctrl["cc"] + "|" +
            ctrl["ci"] + "|" +
            ctrl["co"] + "|" +
            JSON.stringify(ctrl["cs"]) + "|" +
            ctrl["la"] + "|" +
            ctrl["lc"] + "|" +
            ctrl["lt"] + "|" +
            ctrl["lw"] + "|" +
            ctrl["sg"] + "|" +
            ctrl["ss"] + "|" +
            ctrl["ty"]);
    };

    var BORDERFILLtoSTR = function(bflist, bfid, dataArray) {
        var bf = bflist[bfid];
        var datastr = (bf["td"] + "|" + bf["sh"] + "|" + bf["st"] + "|" + bf["sc"] + "|" +
        bf["si"] + "|" + bf["bt"] + "|" + bf["bi"] + "|" + bf["cl"] + "|" + bf["bc"] + "|" +
        bf["lt"] + "|" + bf["lw"] + "|" + bf["lc"] + "|" + bf["rt"] + "|" + bf["rw"] + "|" +
        bf["rc"] + "|" + bf["tt"] + "|" + bf["tw"] + "|" + bf["tc"] + "|" + bf["bbt"] + "|" +
        bf["bbw"] + "|" + bf["bbc"] + "|" + bf["dt"] + "|" + bf["dw"] + "|" + bf["dc"]);
        if (bf["fi"]["wb"]) {
            if (bf["fi"]["wb"]["fc"] != 0xFFFFFFFF || bf["fi"]["wb"]["hs"] != -1) {
                datastr += ("|" + bf["fi"]["wb"] + "|" + bf["fi"]["wb"]["fc"] + "|" + bf["fi"]["wb"]["hc"] + "|" +
                bf["fi"]["wb"]["al"] + "|" + bf["fi"]["wb"]["hs"]);
            }
        }
        if (bf["fi"]["gr"]) {
            datastr += (JSON.stringify(bf["fi"]["gr"]));
        }
        if (bf["fi"]["ib"]) {
            datastr += (JSON.stringify(bf["fi"]["ib"]));
        }
        dataArray.push(datastr);
    };

    var PARAPROPtoSTR = function(paraprop, borderfills, dataArray) {
        var datastr = (paraprop["ah"] + "|" + paraprop["av"] + "|" + paraprop["ht"] + "|" +
        paraprop["hl"] + "|" + paraprop["kb"] + "|" +
        paraprop["kn"] + "|" + paraprop["ko"] + "|" + paraprop["kk"] + "|" + paraprop["kl"] + "|" +
        paraprop["kp"] + "|" + paraprop["kw"] + "|" + paraprop["co"] + "|" + paraprop["fl"] + "|" +
        paraprop["st"] + "|" + paraprop["sl"] + "|" + paraprop["ae"] + "|" + paraprop["aa"] + "|" +
        paraprop["mi"] + "|" + paraprop["ml"] + "|" + paraprop["mr"] + "|" + paraprop["mp"] + "|" +
        paraprop["mn"] + "|" + paraprop["lt"] + "|" + paraprop["lv"] + "|" + paraprop["bl"] + "|" +
        paraprop["br"] + "|" + paraprop["bt"] + "|" + paraprop["bb"] + "|" + paraprop["bc"] + "|" +
        paraprop["bi"]);

        BORDERFILLtoSTR(borderfills,  paraprop["bf"], dataArray);
        dataArray.push(datastr);
    };

    var CHARPROPtoSTR = function(charprop, borderfills, dataArray) {
        var datastr = (charprop["tc"] + "|" + charprop["sc"] + "|" + charprop["he"] + "|" +
        charprop["uf"] + "|" + charprop["uk"] + "|" + charprop["sm"] + "|" + charprop["f1"] + "|" +
        charprop["t1"] + "|" + charprop["f2"] + "|" + charprop["t2"] + "|" + charprop["f3"] + "|" +
        charprop["t3"] + "|" + charprop["f4"] + "|" + charprop["t4"] + "|" + charprop["f5"] + "|" +
        charprop["t5"] + "|" + charprop["f6"] + "|" + charprop["t6"] + "|" + charprop["f7"] + "|" +
        charprop["t7"] + "|" + charprop["r1"] + "|" + charprop["r2"] + "|" + charprop["r3"] + "|" +
        charprop["r4"] + "|" + charprop["r5"] + "|" + charprop["r6"] + "|" + charprop["r7"] + "|" +
        charprop["s1"] + "|" + charprop["s2"] + "|" + charprop["s3"] + "|" + charprop["s4"] + "|" +
        charprop["s5"] + "|" + charprop["s6"] + "|" + charprop["s7"] + "|" + charprop["e1"] + "|" +
        charprop["e2"] + "|" + charprop["e3"] + "|" + charprop["e4"] + "|" + charprop["e5"] + "|" +
        charprop["e6"] + "|" + charprop["e7"] + "|" + charprop["o1"] + "|" + charprop["o2"] + "|" +
        charprop["o3"] + "|" + charprop["o4"] + "|" + charprop["o5"] + "|" + charprop["o6"] + "|" +
        charprop["o7"] + "|" + charprop["it"] + "|" + charprop["bo"] + "|" + charprop["ut"] + "|" +
        charprop["us"] + "|" + charprop["uc"] + "|" + charprop["st"] + "|" + charprop["ss"] + "|" +
        charprop["so"] + "|" + charprop["ot"] + "|" + charprop["ht"] + "|" + charprop["hc"] + "|" +
        charprop["hx"] + "|" + charprop["hy"] + "|" + charprop["em"] + "|" + charprop["en"] + "|" +
        charprop["su"] + "|" + charprop["sb"]) ;

        BORDERFILLtoSTR(borderfills,  charprop["bf"], dataArray);
        dataArray.push(datastr);
    };

    var SECDEFtoSTR = function(ctrl, dataArray) {
        var item, i;
        var datastr = ctrl["cc"] + "|" + ctrl["ci"] + "|" + ctrl["td"] + "|" + ctrl["tv"] + "|" + ctrl["sc"] + "|" + ctrl["ts"] + "|" +
            ctrl["gl"] + "|" + ctrl["gc"] + "|" + ctrl["gw"] + "|" + ctrl["ns"] + "|" + ctrl["np"] + "|" + ctrl["ni"] + "|" +
            ctrl["nt"] + "|" + ctrl["ne"] + "|" + ctrl["hh"] + "|" + ctrl["hf"] + "|" + ctrl["hm"] + "|" + ctrl["fb"] + "|" +
            ctrl["hb"] + "|" + ctrl["fi"] + "|" + ctrl["hp"] + "|" + ctrl["hi"] + "|" + ctrl["he"] + "|" + ctrl["sl"] + "|" +
            ctrl["lr"] + "|" + ctrl["lc"] + "|" + ctrl["ld"] + "|" + ctrl["pp"]["ls"] + "|" + ctrl["pp"]["wi"] + "|" + ctrl["pp"]["he"] + "|" +
            ctrl["pp"]["gt"] + "|" + ctrl["pp"]["ml"] + "|" + ctrl["pp"]["mr"] + "|" + ctrl["pp"]["mt"] + "|" + ctrl["pp"]["mb"] + "|" +
            ctrl["pp"]["mh"] + "|" + ctrl["pp"]["mf"] + "|" + ctrl["pp"]["mg"] + "|" + ctrl["fn"]["at"] + "|" + ctrl["fn"]["au "]+ "|" +
            ctrl["fn"]["ap"] + "|" + ctrl["fn"]["ac"] + "|" + ctrl["fn"]["as"] + "|" + ctrl["fn"]["ll"] + "|" + ctrl["fn"]["lt"] + "|" +
            ctrl["fn"]["lw"] + "|" + ctrl["fn"]["lc"] + "|" + ctrl["fn"]["sa"] + "|" + ctrl["fn"]["sb"] + "|" + ctrl["fn"]["st"] + "|" +
            ctrl["fn"]["nt"] + "|" + ctrl["fn"]["nn"] + "|" + ctrl["fn"]["pp"] + "|" + ctrl["fn"]["pb"] + "|" + ctrl["en"]["at"] + "|" +
            ctrl["en"]["au"] + "|" + ctrl["en"]["ap"] + "|" + ctrl["en"]["ac"] + "|" + ctrl["en"]["as"] + "|" + ctrl["en"]["ll"] + "|" +
            ctrl["en"]["lt"] + "|" + ctrl["en"]["lw"] + "|" + ctrl["en"]["lc"] + "|" + ctrl["en"]["sa"] + "|" + ctrl["en"]["st"] + "|" +
            ctrl["en"]["nt"] + "|" + ctrl["en"]["nn"] + "|" + ctrl["en"]["pp"] + "|" + ctrl["en"]["pb"];

        for (i = 0; i < ctrl["pb"].length; i++) {
            item = ctrl["pb"][i];
            datastr += ("|" + item["fa"] + "|" + item["fi"] + "|" + item["hi"] + "|" + item["ob"] + "|" +
            item["ol"] + "|" + item["or"] + "|" + item["ot"] + "|" + item["tb"] + "|" + item["ty"]);
        }
        datastr += ("|" + JSON.stringify(ctrl["mp"]));
        dataArray.push(datastr);
    };

    var SUBLISTPARAtoSTR  = function(sublist, parahead, controlSet, borderfills, paraprops, charprops, dataArray) {
        var i, j, para, run, runArray, runArraLen, ch, chArray, chArrayLen, ctrl;
        var pos = parahead;
        var paraprop, charprop;
        while((pos != null && pos != "")) {
            para = sublist[pos];

            paraprop = para["pp"];
            PARAPROPtoSTR(paraprops[paraprop], borderfills, dataArray);

            runArray = para["ru"];
            runArraLen = runArray.length;
            for (i = 0; i < runArraLen; i++) {
                run = runArray[i];

                charprop = run["cp"];
                CHARPROPtoSTR(charprops[charprop], borderfills, dataArray);

                chArray = run["ch"];
                chArrayLen = chArray.length;
                for (j = 0; j < chArrayLen; j++) {
                    ch = chArray[j];
                    if (ch["co"] != null) {
                        ctrl = controlSet[ch["co"]];
                        GetCtrlData(ctrl, sublist, controlSet, borderfills, paraprops, charprops, dataArray);
                    } else if(ch["cc"] && ch["cc"] == HwpDef.HWPCH_TAB){
                        dataArray.push(String.fromCharCode(HwpDef.HWPCH_TAB));
                    } else {
                        dataArray.push(ch["t"]);
                    }
                }
            }
            pos = para["np"];
        }
    };

    var RemoveObjID = function(key, value){
        var startIdx = value.indexOf('"'+ key + '":"');
        var endIdx;
        while(startIdx != -1){
            startIdx += 6;
            endIdx = value.indexOf('"', startIdx);
            if(endIdx != -1){
                value = value.substring(0, startIdx) + value.substring(endIdx);
                startIdx = value.indexOf('"'+ key + '":"', startIdx + 1);
            } else {
                startIdx = -1;
            }
        }
        return value;
    };

    var TABLEtoSTR = function(ctrl, sublist, controlSet, borderfills, paraprops, charprops, dataArray) {
        var datastr = ctrl["cc"] + "|" + ctrl["ci"] + "|" + ctrl["zo"] + "|" + ctrl["nt"] + "|" +
            ctrl["tw"] + "|" + ctrl["tf"] + "|" + ctrl["lo"] + "|" + ctrl["swi"] + "|" +
            /*
            * + ctrl["she"] + "|"  글자 처럼 취급이 아닌 표의 경우, 다음 페이지로 넘아갈 때 Placement의 크기가 저장되기 때문에 새로 저장할 때와 값이 달라진다.
            *  Save Serialize 때에는 위와같이 잘려서 저장하고, 오픈할 때는 재계산을 하는 것으로 어쩔수 없이 임시로 she는 비교셋에서 제외한다. !문제될 수 있음!
            * */
            ctrl["swr"] + "|" + ctrl["shr"] + "|" + ctrl["spr"] + "|" + ctrl["pta"] + "|" + ctrl["pal"] + "|" +
            ctrl["pvr"] + "|" + ctrl["phr"] + "|" + ctrl["pva"] + "|" + ctrl["ph1"] + "|" + ctrl["pvo"] + "|" +
            ctrl["ph2"] + "|" + ctrl["pfw"] + "|" + ctrl["pao"] + "|" + ctrl["pha"] + "|" + ctrl["ole"] + "|" +
            ctrl["ori"] + "|" + ctrl["oto"] + "|" + ctrl["obo"] + "|" + ctrl["sc"] + "|" + ctrl["pb"] + "|" + ctrl["rh"] + "|" +
            ctrl["na"] + "|" + ctrl["ho"] + "|" + ctrl["if"] + "|" + ctrl["sa"] + "|" + ctrl["rc"] + "|" + ctrl["cco"] + "|" +
            ctrl["cs"] + "|" + ctrl["ile"] + "|" + ctrl["iri"] + "|" + ctrl["ito"] + "|" + ctrl["ibo"];

        BORDERFILLtoSTR(borderfills,  ctrl["bf"], dataArray);

        datastr += ("|" + RemoveObjID("so",JSON.stringify(ctrl["ca"])));
        datastr += ("|" + RemoveObjID("bf", JSON.stringify(ctrl["cl"])));
        //TODO: cl도 별도 함수로 만들어서 bf 정보를 추가해야함. 임시로 objid 제거.

        var tablelist = ctrl["tr"];
        var i,j, row, cell, cell_sublist;
        datastr += ("|" + tablelist.length);
        for (i = 0; i < tablelist.length;i++) {
            row = tablelist[i];
            datastr += ("|" + row.length);
            for (j = 0; j < row.length; j++) {
                cell = row[j];
                cell_sublist = sublist[cell["so"]];
                if (cell_sublist != null) {
                    datastr += ("|" + cell_sublist["td"] + "|" + cell_sublist["lw"] + "|" +
                    cell_sublist["va"] + "|" + cell_sublist["ll"] + "|" + cell_sublist["ln"] + "|" + cell_sublist["tc"]["he"] + "|" +
                    cell_sublist["tc"]["hm"] + "|" + cell_sublist["tc"]["pr"] + "|" + cell_sublist["tc"]["ed"] + "|" +
                    cell_sublist["tc"]["di"] + "|" + cell_sublist["tc"]["ac"] + "|" + cell_sublist["tc"]["ar"] + "|" +
                    cell_sublist["tc"]["sc"] + "|" + cell_sublist["tc"]["sr"] + "|" + cell_sublist["tc"]["sw"] + "|" +
                    cell_sublist["tc"]["sh"] + "|" + cell_sublist["tc"]["ml"] + "|" + cell_sublist["tc"]["mr"] + "|" +
                    cell_sublist["tc"]["mt"] + "|" + cell_sublist["tc"]["mb"]);
                }
            }
        }
        dataArray.push(datastr);
        for (i = 0; i < tablelist.length;i++) {
            for (j = 0; j < tablelist[i].length; j++) {
                cell_sublist = sublist[tablelist[i][j]["so"]];
                if (cell_sublist != null) {
                    BORDERFILLtoSTR(borderfills,  cell_sublist["tc"]["bf"], dataArray);
                }
            }
        }
        for (i = 0; i < tablelist.length;i++) {
            for (j = 0; j < tablelist[i].length; j++) {
                cell_sublist = sublist[tablelist[i][j]["so"]];
                if (cell_sublist != null) {
                    SUBLISTPARAtoSTR(sublist, cell_sublist["hp"], controlSet, borderfills, paraprops, charprops, dataArray);
                }
            }
        }
    };

    var GENSHAPEOBJtoSTR = function(ctrl, sublist, controlSet, borderfills, paraprops, charprops, dataArray) {
        var shape_sublist;
        var datastr = (ctrl["cc"] + "|" + ctrl["ci"] + "|" + ctrl["zo"] + "|" +
        ctrl["nt"] + "|" + ctrl["tw"] + "|" + ctrl["tf"] + "|" + ctrl["lo"] + "|" + ctrl["swi"] + "|" +
        ctrl["she"] + "|" + ctrl["swr"] + "|" + ctrl["shr"] + "|" + ctrl["spr"] + "|" + ctrl["pta"] + "|" +
        ctrl["pal"] + "|" + ctrl["pvr"] + "|" + ctrl["phr"] + "|" + ctrl["pva"] + "|" + ctrl["ph1"] + "|" +
        ctrl["pvo"] + "|" + ctrl["ph2"] + "|" + ctrl["pfw"] + "|" + ctrl["pao"] + "|" + ctrl["pha"] + "|" +
        ctrl["ole"] + "|" + ctrl["ori"] + "|" + ctrl["oto"] + "|" + ctrl["obo"] + "|" + ctrl["sc"]);

        if (ctrl["ca"]) {
            datastr += ("|" + RemoveObjID("so",JSON.stringify(ctrl["ca"])));
        }

        if (ctrl["rc"]) {
            var rc = ctrl["rc"];
            datastr += ("|" + rc["cc"] + "|" + rc["ci"] + "|" + rc["hr"] + "|" + rc["gl"] + "|" +
            rc["ox"] + "|" + rc["oy"] + "|" + rc["ow"] + "|" + rc["oh"] + "|" +
                // rc["cw"] + "|" + rc["ch"] + "|" +
            rc["fh"] + "|" + rc["fv"] + "|" +
                // rc["ra"] + "|" + rc["rcx"] + "|" +
                // rc["rcy"] + "|" + rc["rc"] + "|" + rc["ri"] + "|" +
                // rc["iw"] + "|" + rc["ih"] + "|" +
            rc["ix0"] + "|" + rc["iy0"] + "|" + rc["ix1"] + "|" + rc["iy1"] + "|" + rc["ix2"] + "|" +
            rc["iy2"] + "|" + rc["ix3"] + "|" + rc["iy3"] + "|" +
                // rc["il"] + "|" + rc["ir"] + "|" + rc["it"] + "|" + rc["ib"] + "|" +
            rc["ml"] + "|" + rc["mr"] + "|" + rc["mt"] + "|" + rc["mb"]);

            datastr += ("|" + JSON.stringify(rc["re"]));
            datastr += ("|" + JSON.stringify(rc["ls"]));

            if (rc["in"] != null) {
                //datastr += ("|" + rc["in"]["ma"]); // maxdirty인데 더 확인 필요해서 일단 주석처리
                datastr += ("|" + rc["in"]["rb"]);
                if (rc["in"]["tm"] != null) {
                    datastr += ("|" + rc["in"]["tm"]["e1"]);
                    datastr += ("|" + rc["in"]["tm"]["e2"]);
                    datastr += ("|" + rc["in"]["tm"]["e3"]);
                    datastr += ("|" + rc["in"]["tm"]["e4"]);
                    datastr += ("|" + rc["in"]["tm"]["e5"]);
                    datastr += ("|" + rc["in"]["tm"]["e6"]);
                }
                // datastr += JSON.stringify(rc["in"]["re"]);
            }

            if (rc["img"] != null) {
                datastr += ("|" + rc["img"]["br"]);
                datastr += ("|" + rc["img"]["co"]);
                datastr += ("|" + rc["img"]["ef"]);
                datastr += ("|" + rc["img"]["al"]);
                datastr += ("|" + rc["img"]["ie"]);
                // datastr += ("|" + rc["img"]["bi"]);
            }

            if (rc["ef"] != null) {
                datastr += ("|" + JSON.stringify(rc["ef"]["sh"]));
                datastr += ("|" + JSON.stringify(rc["ef"]["gl"]));
                datastr += ("|" + JSON.stringify(rc["ef"]["se"]));
                datastr += ("|" + JSON.stringify(rc["ef"]["re"]));
            }


            shape_sublist = sublist[ctrl["rc"]["so"]];
            if (shape_sublist != null) {
                datastr += ("|" + shape_sublist["td"] + "|" + shape_sublist["lw"] + "|" +
                shape_sublist["va"] + "|" + shape_sublist["ll"] + "|" + shape_sublist["ln"] + "|" +
                /* shape_sublist["dt"]["lw"] + "|" +*/ shape_sublist["dt"]["ed"] + "|" +
                shape_sublist["dt"]["ml"] + "|" + shape_sublist["dt"]["mr"] + "|" +
                shape_sublist["dt"]["mt"] + "|" + shape_sublist["dt"]["mb"]);
            }
        }

        dataArray.push(datastr);
        if (shape_sublist) {
            SUBLISTPARAtoSTR(sublist, shape_sublist["hp"], controlSet, borderfills, paraprops, charprops, dataArray);
        }
    };

    var GetCtrlData = function(ctrl, sublist, controlSet, borderfills, paraprops, charprops, dataArray) {
        switch (ctrl["ci"]) {
            case HwpCtrlID.HWPCTRLID_COLDEF:
                COLDEFtoSTR(ctrl, dataArray);
                return;
            case HwpCtrlID.HWPCTRLID_SECDEF:
                SECDEFtoSTR(ctrl, dataArray);
                return;
            case HwpCtrlID.HWPCTRLID_TABLE:
                TABLEtoSTR(ctrl, sublist, controlSet, borderfills, paraprops, charprops, dataArray);
                return;
            case HwpCtrlID.HWPCTRLID_GEN_SHAPE_OBJECT:
                GENSHAPEOBJtoSTR(ctrl, sublist, controlSet, borderfills, paraprops, charprops, dataArray);
                break;
            // case HwpCtrlID.HWPCTRLID_EQEDIT:
            //     console.log(ctrl);
            //     break;
            // case HwpCtrlID.HWPCTRLID_FOOTNOTE:
            //     console.log(ctrl);
            //     break;
            // case HwpCtrlID.HWPCTRLID_ENDNOTE:
            //     console.log(ctrl);
            //     break;
            // case HwpCtrlID.HWPCTRLID_AUTO_NUM:
            //     console.log(ctrl);
            //     break;
            // case HwpCtrlID.HWPCTRLID_NEW_NUM:
            //     console.log(ctrl);
            //     break;
            // case HwpCtrlID.HWPCTRLID_PAGE_NUM_CTRL:
            //     console.log(ctrl);
            //     break;
            // case HwpCtrlID.HWPCTRLID_PAGE_HIDING:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_PAGE_NUM_POS:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_HEADER:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FOOTER:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FORM_OBJECT:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FORM_PUSHBUTTON:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FORM_RADIOBUTTON:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FORM_CHECKBUTTON:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FORM_COMBOBOX:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FORM_EDIT:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FORM_SCROLLBAR:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FORM_LISTBOX:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_END:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_UNKNOWN:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_DATE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_DOCDATE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_PATH:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_BOOKMARK:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_MAILMERGE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_CROSSREF:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_FORMULA:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_CLICKHERE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_SUMMARY:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_USERINFO:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_HYPERLINK:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_CITATION:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_BIBLIOGRAPHY:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_SIGN:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_DELETE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_ATTACH:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_CLIPPING:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_SAWTOOTH:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_THINKING:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_PRAISE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_LINE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_SIMPLECHANGE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_HYPERLINK:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_LINEATTACH:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_LINELINK:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_LINETRANSFER:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_RIGHTMOVE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_LEFTMOVE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_TRANSFER:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_SIMPLEINSERT:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_SPLIT:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_REVISION_CHANGE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_MEMO:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_PRIVATE_INFO_SECURITY:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_TABLEOFCONTENTS:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_FIELD_METADATA:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_BOOKMARK:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_INDEXMARK:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_COMPOSE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_DUTMAL:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_COMMENT:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_MARK_TITLE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_MARK_IGNORE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_CONTAINER:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_LINE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_RECTANGLE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_ELLIPSE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_ARC:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_POLYGON:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_CURVE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_PICTURE:
            //     console.log(JSON.stringify(ctrl));
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_OLE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_CANVAS:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_CONNECT_LINE:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_TEXTART:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_SHAPE_COMPONENT_UNKNOWN:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_PLUGIN:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_CHART:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_VIDEO:
            //     console.log(ctrl);
            //     break;
            //
            // case HwpCtrlID.HWPCTRLID_WEBBROWSER:
            //     console.log(ctrl);
            //     break;

            default:
                console.log(ctrl);
                break;
        }
    };

    var GetCmpData = function(text) {
        var jsonObject;
        var dataArray = [];

        try {
            jsonObject = JSON.parse(text);
        } catch (e) {
            return dataArray;
        }

        if (jsonObject == null)
            return null;

        var rootlist = jsonObject["ro"];
        var sublist = jsonObject["sl"];
        var controlSet = jsonObject["cs"];
        var borderfills = jsonObject["bf"];
        var paraprops = jsonObject["pp"];
        var charprops = jsonObject["cp"];

        if (rootlist == null || rootlist["hp"] == null) {
            return dataArray;
        }

        var pos = rootlist["hp"];
        var paraprop, charprop;
        var para,runArray, runArraLen,run;
        var i, j;
        var ch, chArray, chArrayLen;
        var ctrl;

        while (pos != null && pos != "") {
            para = rootlist[pos];
            paraprop = para["pp"];
            PARAPROPtoSTR(paraprops[paraprop], borderfills, dataArray);

            runArray = para["ru"];
            runArraLen = runArray.length;
            for (i = 0; i < runArraLen; i++) {
                run = runArray[i];
                chArray = run["ch"];

                charprop = run["cp"];
                CHARPROPtoSTR(charprops[charprop], borderfills, dataArray);

                chArrayLen = chArray.length;
                for (j = 0; j < chArrayLen; j++) {
                    ch = chArray[j];
                    if (ch["co"] != null) {
                        ctrl = controlSet[ch["co"]];
                        GetCtrlData(ctrl, sublist, controlSet, borderfills, paraprops, charprops, dataArray);
                    } else if(ch["cc"] && ch["cc"] == HwpDef.HWPCH_TAB){
                        dataArray.push(String.fromCharCode(HwpDef.HWPCH_TAB));
                    } else {
                        dataArray.push(ch["t"]);
                    }
                }
            }
            pos = para["np"];
        }
        return dataArray;
    };

    var IsEqualObject = function(srcDataArray, dstDataArray) {
        if (srcDataArray.length != dstDataArray.length) {
            return false;
        }

        var i;
        for (i = 0; i < srcDataArray.length; i++) {
            if (srcDataArray[i].localeCompare(dstDataArray[i]) != 0) {
                return false;
            }
        }

        return true;
    };

    var IsEqualData = function(srctext, dsttext) {
        var srcDataArray = GetCmpData(srctext);
        var dstDataArray = GetCmpData(dsttext);
        // console.log(JSON.stringify(srcDataArray));
        // console.log("================================================");
        // console.log(JSON.stringify(dstDataArray));

        if (srcDataArray == null || dstDataArray == null)
            return false;

        var result = IsEqualObject(srcDataArray, dstDataArray);
        // console.log("================================================");
        // console.log("result : " + result);
        return result;
    };

    return {
        "IsEqualData" : IsEqualData
    };
});
