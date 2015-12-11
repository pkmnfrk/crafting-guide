###
Crafting Guide - main.coffee

Copyright (c) 2014-2015 by Redwood Labs
All rights reserved.
###

require './polyfill'

$                   = require 'jquery'
CraftingGuideClient = require('crafting-guide-common').CraftingGuideClient
CraftingGuideRouter = require './crafting_guide_router'
FeedbackController  = require './controllers/feedback_controller'
Logger              = require('crafting-guide-common').Logger
_                   = require './underscore_mixins'
backbone            = require 'backbone'
marked              = require 'marked'
views               = require './views'

########################################################################################################################

if typeof(global) is 'undefined'
    window.global = window
    global = window.global

global.hostName = window.location.hostname
global.logger = new Logger

switch global.hostName
    when 'prerender.crafting-guide.com'
        global.env   = 'prerender'
        logger.level = Logger.FATAL
        apiBaseUrl   = 'http://local.crafting-guide.com:8001'
    when 'local.crafting-guide.com', 'localhost'
        global.env   = 'local'
        logger.level = Logger.DEBUG
        apiBaseUrl   = 'http://local.crafting-guide.com:8001'
    when 'new.crafting-guide.com'
        global.env   = 'staging'
        logger.level = Logger.VERBOSE
        apiBaseUrl   = 'https://crafting-guide-staging.herokuapp.com'
    when 'crafting-guide.com'
        global.env   = 'production'
        logger.level = Logger.INFO
        apiBaseUrl   = 'https://crafting-guide-production.herokuapp.com'
    else
        throw new Error "cannot determine the environment of: #{window.location.hostname}"

client = _.extend new CraftingGuideClient(baseUrl:apiBaseUrl), backbone.Events
client.onStatusChanged = (c, oldStatus, newStatus)->
    logger.info "Crafting Guide server status changed from #{oldStatus} to #{newStatus}"
    client.trigger 'change:status', client, oldStatus, newStatus
    client.trigger 'change', client

backbone.$ = $

marked.setOptions
    sanitize: true

global.feedbackController = new FeedbackController el:'.view__feedback'
feedbackController.render()

global.router = new CraftingGuideRouter client:client
global.router.loadCurrentUser()
global.router.loadDefaultModPack()

global.mode = if window.localStorage.mode then window.localStorage.mode else 'expert'

backbone.history.start pushState:true
client.checkStatus()

logger.info -> "CraftingGuide is ready"
