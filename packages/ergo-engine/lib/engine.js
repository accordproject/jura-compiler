/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

const Logger = require('@accordproject/ergo-compiler').Logger;
const Util = require('./util');
const ResourceValidator = require('composer-concerto/lib/serializer/resourcevalidator');

const Moment = require('moment');
// Make sure Moment serialization preserves utcOffset. See https://momentjs.com/docs/#/displaying/as-json/
Moment.fn.toJSON = Util.momentToJson;

const {
    VM,
    VMScript
} = require('vm2');

/**
 * <p>
 * Engine class. Execution of template logic against a request object, returning a response to the caller.
 * </p>
 * @class
 * @public
 * @memberof module:ergo-engine
 */
class Engine {

    /**
     * Create the Engine.
     */
    constructor() {
        this.scripts = {};
    }

    /**
     * Compile and cache JavaScript logic
     * @param {ScriptManager} scriptManager  - the script manager
     * @param {string} clauseId - the clause identifier
     * @private
     */
    compileJsLogic(scriptManager, clauseId) {
        let allJsScripts = '';

        scriptManager.getAllScripts().forEach(function (element) {
            if (element.getLanguage() === '.js') {
                allJsScripts += element.getContents();
            }
        }, this);

        if (allJsScripts === '') {
            throw new Error('Did not find any JavaScript logic');
        }

        const script = new VMScript(allJsScripts);
        this.scripts[clauseId] = script;
    }

    /**
     * Execute a clause, passing in the request object
     * @param {TemplateLogic} logic  - the logic to execute
     * @param {string} clauseId - the clause identifier
     * @param {object} contract - the contract data
     * @param {object} request - the request, a JS object that can be deserialized
     * using the Composer serializer.
     * @param {object} state - the contract state, a JS object that can be deserialized
     * using the Composer serializer.
     * @param {string} currentTime - the definition of 'now'
     * @return {Promise} a promise that resolves to a result for the clause
     * @private
     */
    async execute(logic, clauseId, contract, request, state, currentTime) {
        const serializer = logic.getSerializer();
        const scriptManager = logic.getScriptManager();

        // ensure the contract is valid
        const validContract = serializer.fromJSON(contract, {validate: false, acceptResourcesForRelationships: true});
        validContract.$validator = new ResourceValidator({permitResourcesForRelationships: true});
        validContract.validate();

        // ensure the request is valid
        const validRequest = serializer.fromJSON(request, {validate: false, acceptResourcesForRelationships: true});
        validRequest.$validator = new ResourceValidator({permitResourcesForRelationships: true});
        validRequest.validate();

        // Set the current time and UTC Offset
        const validNow = Util.setCurrentTime(currentTime);
        const validUtcOffset = validNow.utcOffset();

        // ensure the state is valid
        const validState = serializer.fromJSON(state, {validate: false, acceptResourcesForRelationships: true});
        validState.$validator = new ResourceValidator({permitResourcesForRelationships: true});
        validState.validate();

        Logger.debug('Engine processing request ' + request.$class + ' with state ' + state.$class);

        let script;

        this.compileJsLogic(scriptManager, clauseId);
        script = this.scripts[clauseId];

        const callScript = logic.getDispatchCall(logic);

        const vm = new VM({
            timeout: 1000,
            sandbox: {
                moment: Moment,
                serializer: serializer,
                logger: Logger,
                utcOffset: validUtcOffset
            }
        });

        // add immutables to the context
        vm.freeze(validContract, 'data'); // Second argument adds object to global.
        vm.freeze(validRequest, 'request'); // Second argument adds object to global.
        vm.freeze(validState, 'state'); // Second argument adds object to global.
        vm.freeze(validNow, 'now'); // Second argument adds object to global.

        // execute the logic
        vm.run(script);
        const result = vm.run(callScript);

        // ensure the response is valid
        result.response.$validator = new ResourceValidator({permitResourcesForRelationships: true});
        result.response.validate();
        const responseResult = serializer.toJSON(result.response, {convertResourcesToRelationships: true});

        // ensure the new state is valid
        result.state.$validator = new ResourceValidator({permitResourcesForRelationships: true});
        result.state.validate();
        const stateResult = serializer.toJSON(result.state, {convertResourcesToRelationships: true});

        // ensure all the emits are valid
        let emitResult = [];
        for (let i = 0; i < result.emit.length; i++) {
            result.emit[i].$validator = new ResourceValidator({permitResourcesForRelationships: true});
            result.emit[i].validate();
            emitResult.push(serializer.toJSON(result.emit[i], {convertResourcesToRelationships: true}));
        }

        return {
            'clause': clauseId,
            'request': request,
            'response': responseResult,
            'state': stateResult,
            'emit': emitResult,
        };
    }

    /**
     * Initialize a clause
     * @param {TemplateLogic} logic  - the logic to execute
     * @param {string} clauseId - the clause identifier
     * @param {object} contract - the contract data
     * @param {string} currentTime - the definition of 'now'
     * @return {Promise} a promise that resolves to a result for the clause initialization
     * @private
     */
    async init(logic, clauseId, contract, currentTime) {
        const serializer = logic.getSerializer();
        const scriptManager = logic.getScriptManager();

        // ensure the contract is valid
        const validContract = serializer.fromJSON(contract, {validate: false, acceptResourcesForRelationships: true});
        validContract.$validator = new ResourceValidator({permitResourcesForRelationships: true});
        validContract.validate();

        // Set the current time and UTC Offset
        const validNow = Util.setCurrentTime(currentTime);
        const validUtcOffset = validNow.utcOffset();

        let script;

        this.compileJsLogic(scriptManager, clauseId);
        script = this.scripts[clauseId];

        const callScript = logic.getInitCall();

        const vm = new VM({
            timeout: 1000,
            sandbox: {
                moment: Moment,
                serializer: serializer,
                logger: Logger,
                utcOffset: validUtcOffset
            }
        });

        // add immutables to the context
        vm.freeze(validContract, 'data'); // Second argument adds object to global.
        vm.freeze(validNow, 'now'); // Second argument adds object to global.

        // execute the logic
        vm.run(script);
        const ergoResult = vm.run(callScript);
        let result;

        if (ergoResult.hasOwnProperty('left')) {
            result = ergoResult.left;
        } else if (ergoResult.hasOwnProperty('right')) {
            throw new Error("[Ergo] " + JSON.stringify(ergoResult.right));
        } else {
            result = ergoResult;
        }

        let responseResult = null;
        if (result.response) {
            result.response.$validator = new ResourceValidator({permitResourcesForRelationships: true});
            result.response.validate();
            responseResult = serializer.toJSON(result.response, {convertResourcesToRelationships: true});
        }
        console.log('RESULT!!! ' + JSON.stringify(responseResult));
        // ensure the response is valid

        // ensure the new state is valid
        result.state.$validator = new ResourceValidator({permitResourcesForRelationships: true});
        result.state.validate();
        const stateResult = serializer.toJSON(result.state, {convertResourcesToRelationships: true});

        // ensure all the emits are valid
        let emitResult = [];
        for (let i = 0; i < result.emit.length; i++) {
            result.emit[i].$validator = new ResourceValidator({permitResourcesForRelationships: true});
            result.emit[i].validate();
            emitResult.push(serializer.toJSON(result.emit[i], {convertResourcesToRelationships: true}));
        }

        return {
            'clause': clauseId,
            'request': null,
            'response': responseResult,
            'state': stateResult,
            'emit': emitResult,
        };
    }
}

module.exports = Engine;
