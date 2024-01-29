'use strict';

/**
 * request-dataset service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::request-dataset.request-dataset');
