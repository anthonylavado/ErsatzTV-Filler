const { CONFIG_CONSTANTS } = require("../constants/path.constants");
const { doesFileExist, loadFileContentsIntoMemory } = require("../utils/file.utils");
const { parseConfigurationFile, createNewUserConfigFromDefault } = require("../utils/config.utils");
const fs = require('fs');
const logger = require("../utils/logger.utils");



let CURRENT_CONFIG = {}; //In memory store for config data

/**
 * Boot taks to setup the configuration file or load the users current one
 * @returns {Promise<void>}
 */
const setupConfigurationFile = async () => {
    //For now, check exists and just load the user one over the default one... can be expanded to control your variable updating, and it will always run on server boot.
    const HAVE_USER_CONFIG = await doesFileExist(CONFIG_CONSTANTS().USER_CONFIG);
    if(!HAVE_USER_CONFIG){
        logger.warn("Can not find a user configuration file... loading default...")
        await createNewUserConfigFromDefault();
    }else{
        logger.success("Found a user configuration file... loading...")
        await parseConfigurationFileContents(CONFIG_CONSTANTS().USER_CONFIG)
    }
    await jsonifyCurrentConfiguration();
}

/**
 * Given a path of a configuration file, it will parse into CURRENT_CONFIG the config key and value pairs
 * @param path
 * @returns {Promise<void>}
 */
const parseConfigurationFileContents = async (path) => {
    CURRENT_CONFIG = await parseConfigurationFile(path).parsed;
}


/**
 * Return the current configuration as a object
 * @returns {{}}
 */
const retrieveCurrentConfiguration2 = () => {
    return CURRENT_CONFIG
}

const jsonifyCurrentConfiguration = async () => {

  // convert config.conf to config.json  -- Delete config.conf totally in future versions
const config = await retrieveCurrentConfiguration2();
const FILE_EXISTS = await doesFileExist(CONFIG_CONSTANTS().USER_CONFIG)
if (!FILE_EXISTS) {
  logger.error('The config.json file does not exist.');
  await fs.writeFile(CONFIG_CONSTANTS().USER_CONFIG, JSON.stringify(CONFIG_CONSTANTS().DEFAULT_CONFIG, null, 2), (err) => {
    if (err) {
      logger.error(`Error creating user config file: ${err}`);
    } else {
    logger.success('Created config.json file');
  };
});
}
}

const retrieveCurrentConfiguration = async () => {
  const configFileExists = await doesFileExist(CONFIG_CONSTANTS().USER_CONFIG);
  const defaultConfigFileExists = await doesFileExist(CONFIG_CONSTANTS().USER_CONFIG);

  if (!configFileExists) {
    logger.warn("config.json file is missing... Generating a new copy");
    await jsonifyCurrentConfiguration();
} else {
    logger.info("Found a user configuration file... loading...");
  //  await retrieveCurrentConfiguration2()
  }

    const data = await fs.readFileSync(CONFIG_CONSTANTS().USER_CONFIG);
    CURRENT_CONFIG = JSON.parse(data);
logger.info(`Current config is: ${CURRENT_CONFIG}`);
return CURRENT_CONFIG;
};




//async log
//(async () => { const config = await retrieveCurrentConfiguration(); logger.info(config)})()


module.exports = {
    setupConfigurationFile,
    retrieveCurrentConfiguration,
}
