'use strict'

const SFCategoryBase        = require('../category-base');

/**
 * Site API Calls
 */
class SFSites extends SFCategoryBase {

  /**
   * Creates a new instance of SFSites
   *
   * @param {SFRequest} client A SFRequest client.
   */
  constructor(client) {
    super(client);
  }

  /**
   * Lists the sites in the factory.
   *
   * @param {object} param.limit Sites to return (DEFAULT: 100, Max 100)
   * @param {object} param.page Page of results to return (DEFAULT: 1)
   */
  async list({
    limit = 100,
    page = 1
  } = {}) {

    if (limit > 100) {
      throw new Error("You can only get 100 sites at a time");
    }

    // If the count > number requested then fetch more.
    return this.client.get('/sites', {
      limit,
      page
    });
  }

  /**
   * Gets the details of a site.
   *
   * @param {*} siteID
   */
  async get(siteID) {
    //TODO: Check if number.

    return this.client.get('/sites/' + siteID);
  }

  /**
   * Gets the backups for a site.
   *
   * @param {*} siteID
   * @param {object} param.limit Sites to return (DEFAULT: 100, Max 100)
   * @param {object} param.page Page of results to return (DEFAULT: 1)
   */
  async getBackups(siteID, {
    limit = 100,
    page = 1
  } = { }) {
    return this.client.get('/sites/' + siteID + '/backups',{
      limit,
      page
    });
  }
}

module.exports = SFSites;
