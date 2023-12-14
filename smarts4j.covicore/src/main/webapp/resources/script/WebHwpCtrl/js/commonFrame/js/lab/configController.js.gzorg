define(function (require) {
    "use strict";

    /*******************************************************************************
     * Import
     ******************************************************************************/

    var $ = require("jquery"),
        Util = require("commonFrameJs/utils/util");

    /*******************************************************************************
     * Private Variables
     ******************************************************************************/

    var _userId;

    /*******************************************************************************
     * Constructor
     ******************************************************************************/

    var ConfigController = function () {
        this.defaultConfigInfo = {};
        this.startFunc = {};
        this.exitFunc = {};
    };

    /*********************************************
     * Public method
     **********************************************/

    /**
     * 컨트롤러에 실험실 모듈의 객체(ex. AoriView 등...)를 등록시켜줌
     * @param {String} userId               : 사용자 아이디
     * @param {String} key                  : 객체를 등록할 때 쓸 이름
     * @param {Object} obj                  : AoriView 와 같은 객체
     * @param {Boolean} defaultConfig       : default 활성화 설정 (true : on / false : off)
     * @param {Object=} subConf              : default 옵션 설정 객체
     * @author <a href="mailto:juko@hancom.com">고정욱</a>
     */
    ConfigController.prototype.regist = function (userId, key, obj, defaultConfig, subConf) {
        this.startFunc[key] = $.proxy(obj.start, obj);
        this.exitFunc[key] = $.proxy(obj.exit, obj);
        this.defaultConfigInfo[key] = {
            enabled: defaultConfig,
            subConf: subConf || null
        };
        _userId = userId;
    };

    /**
     * 실험실의 기능이 on 인지 off 인지 판단하여 적절한 함수를 실행시켜줌.
     * @author <a href="mailto:juko@hancom.com">고정욱</a>
     */
    ConfigController.prototype.exec = function () {
        var configInfo = Util.getItemFromLocalStorage("configInfo") || {},
            key;

        configInfo = configInfo[_userId];

        if (!configInfo) {
            configInfo = this.defaultConfigInfo;
        }

        for (key in configInfo) {
            if (configInfo[key].enabled) {
                this.startFunc[key] && this.startFunc[key]();
            } else {
                this.exitFunc[key] && this.exitFunc[key]();
            }
        }
    };

    /**
     * 실험실의 default 설정을 반환함
     * @return {Object}
     * @author <a href="mailto:juko@hancom.com">고정욱</a>
     */
    ConfigController.prototype.getDefaultConfigInfo = function () {
        return this.defaultConfigInfo;
    };

    /**
     * 사용자 아이디를 반환함
     * @returns {String}
     */
    ConfigController.prototype.getUserId = function () {
        return _userId;
    };

    return new ConfigController();
});
