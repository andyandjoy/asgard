#pagination
pagination          = require 'node-pagination'
#contents collection
contents_model      = require '../model/contents-model'
ContentsModel       = contents_model.ContentsModel
#category controller
category            = require './category'

#global variables
#每页显示的条数
pagesize   = 5
#全局catename
catename   = null
#操作员
operator   = null
#search
search     = null
#当前状态
state      = null

#articles
exports.articles = ( req, res ) ->
	#生成随机字符串
	random = require( '../libs/random' ).random
	#console.log req.params.page
	console.log 'req.params.page = ' + req.params.page
	#set page no
	pageno = if `req.params.page != undefined` then req.params.page else 1
	#设定当前类型
	state = 'index'
	#call findAll
	contents_model.once random + '_contents_count_success', ( result ) ->
		#console log
		console.log '-- _contents_count_success --'
		#invoke page
		if result is 0 then res.redirect '/setup' else getpagination req, res, result, pageno
	contents_model.once random + '_contents_count_error', ( err ) ->
		console.log '_contents_count_error = ' + err
	#由于每次文章总数可能会发生变化，所以，需要每次重新取得pagetotal
	contents_model.count ContentsModel, {}, random

#类型
exports.category = ( req, res ) ->
	#生成随机字符串
	random = require( '../libs/random' ).random
	#设定当前类型
	state = 'category'
	#set catename
	catename = if `req.params.catename != undefined` then req.params.catename else res.redirect '/'
	console.log 'catename =========== ' + catename
	#set pageno
	pageno   = if `req.params.page != undefined` then req.params.page else 1
	console.log 'pageno ============= ' + pageno
	#
	contents_model.once random + '_contents_countcatename_success', ( result ) ->
		console.log '_contents_countcatename_success =' + result + '|'
		#call page function
		getpagination req, res, result, pageno
	contents_model.once random + '_contents_countcatename_error', ( err ) ->
		console.log '_contents_countcatename_error = ' + err
	#由于每次分类总数可能会发生变化，所以，需要每次重新取得catetotal
	contents_model.countCatename ContentsModel, catename, random

#用户
exports.operator = ( req, res ) ->
	#生成随机字符串
	random = require( '../libs/random' ).random
	#设定当前类型
	state = 'operator'
	#set operator
	operator = if `req.params.operator != undefined` then req.params.operator else res.redirect '/'
	console.log 'operator =========== ' + operator
	#set pageno
	pageno = if `req.params.page != undefined` then req.params.page else 1
	console.log 'pageno ============= ' + pageno
	#
	contents_model.once random + '_contents_countoperator_success', ( result ) ->
		console.log '_contents_countoperator_success =' + result + '|'
		#call page function
		getpagination req, res, result, pageno
	contents_model.once random + '_contents_countoperator_error', ( err ) ->
		console.log '_contents_countoperator_error = ' + err
	#每次都重新计算分页数
	contents_model.countOperator ContentsModel, operator, random

#取得contents，包括：全部文章和分类文章
getpagination = ( req, res, total, pageno ) ->
	#生成随机字符串
	random = require( '../libs/random' ).random
	#set pv
	pv = pagination.build total, pageno, pagesize, 0, pagesize
	#call findAll
	contents_model.once random + '_contents_findall_success', ( result ) ->
		#set obj,inclue contents & pv
		obj = 
			contents : result
			pv       : pv
		#由于每次分类内容可能会发生变化，所以，需要每次重新取得categories
		category.getcategoies req, res, obj, getCategoiesHandler
	contents_model.once random + '_contents_findall_error', ( err ) ->
		console.log '_contents_findall_error = ' + err
	#exec
	#
	if state == 'index'
		query = {}
	else if state == 'category'
		query = { catename : catename }
	else if state == 'operator'
		query = { username : operator }
	else if state == 'search'
		re = new RegExp search, 'i'
		query = { '$or' : [{ 'title' : re }, { 'content' : re }] }
	contents_model.findAll ContentsModel, query, pageno, pagesize, random

#search
exports.search = ( req, res ) ->
	#生成随机字符串
	random = require( '../libs/random' ).random
	#设定当前类型
	state = 'search'
	#print
	console.log 'req.body.key = ' + req.body.key
	#
	if `req.body.key == undefined && search == null` then res.redirect '/'
	#set search（判断语句用于判断翻页，当翻页的时候，req.body.key则为undefined）
	search = if `req.body.key    != undefined` then req.body.key else search
	#print
	console.log 'search ============= ' + search
	#set pageno
	pageno = if `req.params.page != undefined` then req.params.page else 1
	#print
	console.log 'pageno ============= ' + pageno
	#call findAll
	contents_model.once random + '_contents_searchcount_success', ( result ) ->
		#console log
		console.log '-- _contents_searchcount_success --' + result
		#call page function
		if result > 0 then getpagination req, res, result, pageno else res.redirect '/'
	contents_model.once random + '_contents_searchcount_error', ( err ) ->
		console.log '_contents_searchcount_error = ' + err
	#set regexp
	re = new RegExp search, 'i'
	#set query
	query = { '$or' : [{ 'title' : re }, { 'content' : re }] }
	#call search
	contents_model.searchCount ContentsModel, query, random

#文章详细页
exports.detail = ( req, res ) ->
	#生成随机字符串
	random = require( '../libs/random' ).random
	#设定当前类型
	state = 'detail'
	#set url
	url = if `req.params.url != undefined` then req.params.url else res.redirect '/'
	#
	contents_model.once random + '_contents_findurl_success', ( result ) ->
		console.log '_contents_findurl_success =' + result + '|'
		#set obj,inclue contents & pv
		obj = 
			contents : result
			pv       : null
		#由于每次分类内容可能会发生变化，所以，需要每次重新取得categories
		category.getcategoies req, res, obj, getCategoiesHandler
	contents_model.once random + '_contents_findurl_error', ( err ) ->
		console.log '_contents_findurl_error = ' + err
	contents_model.findURL ContentsModel, url, random

#category.getcategoies callback
getCategoiesHandler = ( req, res, obj, result ) ->
	#print user agent
	console.log '-- req.headers -- ' + req.headers[ 'user-agent' ]
	#判断ua是 Destop 环境 还是 Mobile 环境
	ua = req.headers[ 'user-agent' ]
	if ua.search( /iPod/    )    is -1 and 
	   ua.search( /iPhone/  )    is -1 and 
	   ua.search( /iPad/    )    is -1 and 
	   ua.search( /Kindle/  )    is -1 and 
	   ua.search( /Android/ )    is -1 and 
	   ua.search( /Opera Mini/ ) is -1 and 
	   ua.search( /BlackBerry/ ) is -1 and 
	   ua.search( /webOS/      ) is -1 and 
	   ua.search( /UCWEB/      ) is -1 and 
	   ua.search( /Blazer/     ) is -1 and 
	   ua.search( /PSP/        ) is -1 and 
	   ua.search( /IEMobile/   ) is -1 
	then prefix = 'front-end/desktop' else prefix = 'front-end/mobile'
	#print prefix
	console.log 'prefix = ' + prefix

	#res.render
	if state != 'detail'
		res.render prefix + '/index', { contents : obj.contents, pv : obj.pv, categories : result, state : state }
	else 
		res.render prefix + '/detail', { content : obj.contents, categories : result }