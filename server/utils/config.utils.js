const dotenv = require('dotenv')
const {CONFIG_CONSTANTS} = require("../constants/path.constants");
const {overWriteFileContents} = require("../utils/file.utils");
const {stringifyJavaScriptObjectToConfigFormat} = require("../utils/string.utils")

/**
 * Parse the configuration file with given path
 * @param path
 * @returns {DotenvConfigOutput}
 */
const parseConfigurationFile = (path) => {
    return dotenv.config({path})
}


/**
 * Write a key, value pair to the configuration file
 * @param key
 * @param value
 * @returns {Promise<void>}
 */
const writeValueToConfigurationFile = async (key, value) => {
    const latestDotEnvConfig = parseConfigurationFile(CONFIG_CONSTANTS().USER_CONFIG)


    const newDotEnv = {
        ...latestDotEnvConfig.parsed,
        [key]: value
    };

    const newDotEnv[key] = value;
    await overWriteFileContents(CONFIG_CONSTANTS().USER_CONFIG,  newDotEnv[key])


}


module.exports = {
    parseConfigurationFile,
    writeValueToConfigurationFile
}
