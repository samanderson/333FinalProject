import json
import random
import hashlib
from bottle import route, run, request, abort, response
from pymongo import Connection

connection = Connection('localhost', 27017)
db = connection.mydatabase
actions = ['addFriend', 'acceptFriend','rejectFriend', 'addPath', 'addUser', 'share', 'deleteSharedPath', 'checkUser', 'getPath']

@route('/get/<collection>/<id>', method='GET')
def getRow(id, collection):
	if (not id):
		id = ' '
	row = db[collection].find_one({"_id" : id})
	if collection == "sharepaths" and not (getHash(id) == request.get_cookie("hash")):
		#return getHash(id) + " " + request.get_cookie("hash")
		abort(400, "NOT ALLOWED")
	if not row:
		abort(404, 'No %s for user id %s' % (collection,id))
	return row

@route('/getPathByUser/<id:int>', method='GET')
def getRow(id):
	try:
		return db["paths"].find({"userId" : id})
	except ValidationError as ve:
		logError(ve)

@route('/<url:path>', method='POST')
def router(url):
	if '/' in url:
		first_word, rest = url.split('/', 1 )
		url = first_word

	if url in actions:
		s = '{0}()'.format(url)
		return eval(s)
	else:
		return '404: Page not found.'

def getHash(id):
	lower = str(hashlib.md5(str(id) + "#.4a!").hexdigest())
	return lower.upper()
		
def getPath():
	fromUser = request.POST.get('fromUser')
	id = request.POST.get('pathId')
	row = db["paths"].find_one({"_id" : id})
	count = db["sharepaths"].find({"_id" : fromUser, "list.path" : id}).count()
	if (getHash(fromUser) != request.get_cookie("hash") or count == 0):
		abort(400, "NOT ALLOWED")
	if not row:
		abort(404, 'No path with id %s' % (id))
	return row

def share():
	owner = request.POST.get('fromUser')
	if getHash(owner) == request.get_cookie("hash"):
		userId = request.POST.get('userId')
		pathId = request.POST.get('pathId')	
		userName = request.POST.get('userName')
		try:
			pathInfo = db["paths"].find_one({"_id" : pathId})
			pathName = pathInfo["pathName"]
			if checkIfExists(userId, 'sharepaths') == 0:
				db["sharepaths"].save({"_id" : userId, "list" : [{"path" : pathId, "pathName" : pathName, "userName" : userName}]})
			else:
				if db["sharepaths"].find({"_id" : userId, "list.paths" : pathId}).count() == 0:
					db["sharepaths"].update({"_id" : userId}, {"$push" : {"list" : {"path" : pathId, "userName" : userName, "pathName" : pathName}}})
			return '1'
		except ValidationError as ve:
			logError(ve)
	else:
		return "0"

def addUser():
	id_user = request.POST.get('fbid')
	#hash_key = hashlib.md5(str(id_user)).hexdigest()
	try:
		if checkIfExists(id_user, "users") == 0:
			db["users"].save({"_id" : id_user})
	except ValidationError as ve:
		logError(ve)

def checkUser():
	users = request.POST.get('users')
	ids = users.split(",")
	ret = ''
	for i in range(0, len(ids) - 1):
		try:
			if db["users"].find({"_id" : ids[i]}).count() == 0:
				ret = ret + '0'
			else :
				ret = ret + '1'
		except ValidationError as ve:
			logError(ve)
	return ret

'''
def addFriend():
	id1 = int(request.POST.get('id1', '').strip()) #requesting
	id2 = int(request.POST.get('id2', '').strip()) #pending
	hash_key = request.POST.get('hash_key', '').strip()

	for friends_user in db["friends"].find({"_id" : id1}):
		if id2 in friends_user["friends"]:
			return '0'

	try:
		if checkIfExists(id1, "penFriends") == 0:
			db["penFriends"].save({"_id" : id2, "users" : [id1]})
		else:
			db["penFriends"].update({"_id" : id2} , {"$addToSet" : {"users" : id1}})
		return '1'
	except ValidationError as ve:
		logError(ve)
	
def rejectFriend():
	id1 = int(request.POST.get('id1', '').strip())
	id2 = int(request.POST.get('id1','').strip())
	hash_key = request.POST.get('hash_key', '')
	try:
		db["penFriends"].update({"_id" : id1}, {"$pull" : {"users" : id2 }})
		return '1'
	except ValidationError as ve:
		logError(ve)

def acceptFriend():
	id1 = int(request.POST.get('id1', '').strip()) #accepting
	id2 = int(request.POST.get('id2', '').strip()) #requested
	hash_key = request.POST.get('hash_key', '').strip()
	try:
		if checkIfExists(id1, 'friends') == 0:
			db["friends"].save({"_id" : id1, "friends" : [id2]})
		else:
			db["friends"].update({"_id" : id1}, {"$addToSet" : {"friends" : id2}})

		if checkIfExists(id2, 'friends') == 0:
			db["friends"].save({"_id" : id2, "friends" : [id1]})
		else:
			db["friends"].update({"_id" : id2}, {"$addToSet" : {"friends" : id1}})
		
		db["penFriends"].update({"_id" : id1}, {"$pull" : {"users" : id2 }})

		return '1'
	except ValidationError as ve:
		logError(ve)
'''		
def deleteSharedPath():
	userId = request.POST.get('userId')
	if request.get_cookie("hash") == getHash(userId):
		pathId = request.POST.get('pathId')
		try:
			db["sharepaths"].update({"_id" : userId}, {"$pull" : {"list" : {"path" : pathId}}})
			return "1"
		except ValidationError as ve:
			logError(ve)
	else:
		return "0"

def addPath():
	userId = request.POST.get('userId')
	if request.get_cookie("hash") == getHash(userId):
		idPath = request.POST.get('idPath')
		id = str(userId) + "a" + str(idPath)
		userName = request.POST.get('userName')
		pathName = request.POST.get('name')
		points = request.POST.get('points')
		times = request.POST.get('times')
		distance = request.POST.get('distance')
		numPoints = request.POST.get('numPoints')
		numAnnotations = request.POST.get('numAnnotations')
		annotations = request.POST.get('annotations')
		totalTime = request.POST.get('totalTime')
		try:
			db["paths"].save({"_id" : id, "idPath" : idPath, "userId" : userId,  "userName" : userName, "pathName": pathName, 
				"points" : points, "times" : times, "distance" : distance, "numPoints" : numPoints,
				"numAnnotations" : numAnnotations, "annotations" : annotations, "totalTime" : totalTime})
			return "1"
		except ValidationError as ve:
			logError(ve)
	else:
		return "0"

def checkIfExists(id, collection):
	if db[collection].find({"_id" : id}).count() == 0:
		return 0
	else:
		return 1

def processLogin(id, hash):
	for user in db["users"].find({"_id" : id}):
		if (hash == user["hash"]):
			return '1'
		else:
			return '0'

def logError(error):
	with open('errors.log', 'a') as f:
		f.write(str(error))
	abort(400, str(ve))
#run(host='localhost', port=8080)
run(host='ec2-177-71-143-149.sa-east-1.compute.amazonaws.com', port=8080)