'use strict'

const SFCategoryBase        = require('../category-base');

/**
 * Domains API Calls
 */
class SFDomains extends SFCategoryBase {

  /**
   * Creates a new instance of SFDomain
   *
   * @param {SFRequest} client A SFRequest client.
   */
  constructor(client) {
    super(client);
  }

  /**
   * Gets the domains for a site.
   * @param {*} siteid
   */
  async get(siteid) {
    //TODO: Validate Siteid
    return this.client.get('/domains/' + siteid);
  }
}

module.exports = SFDomains;
