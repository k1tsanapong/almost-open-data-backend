'use strict';

/**
 * dataset-file service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::dataset-file.dataset-file');
