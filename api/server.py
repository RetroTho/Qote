from bottle import request, run, static_file, route, error, template, HTTPResponse
from tinydb import TinyDB, Query
from tinydb.operations import set, delete
import json
import random
import re

db = TinyDB('db.json')

users = db.table('users')
notes = db.table('notes')

User = Query()
Note = Query()

def check_info(firstName, lastName, emailAddress, username, password):
	if ((len(firstName) < 1) or (len(firstName) > 50)):
		return 1
	elif ((len(lastName) < 1) or (len(lastName) > 50)):
		return 2
	elif (not (re.fullmatch('[a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,}', emailAddress.lower()))):
		return 3
	elif (not (re.fullmatch('[a-z0-9_]{3,16}', username.lower()))):
		return 4
	elif (not (re.fullmatch('[a-z0-9_!?-]{8,24}', password.lower()))):
		return 5
	else:
		return 0

def do_auth(username, password):
	if ((users.count(User.username == username)) > 1):
		print('duplicate users')
		return False
	elif ((users.count(User.username == username)) < 1):
		print('user not found')
		return False
	else:
		if (users.get(User.username == username)['password'] == password):
			return True
		else:
			print('incorrect password')
			return False

def is_auth(username, token):
	try:
		if (users.get(User.username == username)['token'] == token):
			return True
		else:
			return False
	except:
		print('no saved key (header)')
		return False

def login(data):
	username = data['username']
	password = data['password']
	if do_auth(username, password):
		token = random.randint(1000, 9999)
		users.update(set('token', token), User.username == username)
		return json.dumps({'username': username, 'token': token})
	else:
		return 'false'

def signup(data):
	firstName = data['first_name']
	lastName = data['last_name']
	emailAddress = data['email_address']
	username = data['username']
	password = data['password']
	checkResult = check_info(firstName, lastName, emailAddress, username, password)
	if (checkResult == 0):
		if ((users.count(User.username == username) < 1) and (users.count(User.email == emailAddress) < 1)):
			users.insert({'username': username, 'first_name': firstName, 'last_name': lastName, 'email': emailAddress, 'password': password, 'token': 0})
			return 'success'
		elif (users.count(User.email == emailAddress) >= 1):
			return 'email already in use'
		elif (users.count(User.username == username) < 1):
			return 'username taken'
	elif (checkResult == 1):
		return 'first name must be 1-50 characters'
	elif (checkResult == 2):
		return 'last name must be 1-50 characters'
	elif (checkResult == 3):
		return 'not a valid email address'
	elif (checkResult == 4):
		return 'username can only contain letters, numbers, and _ and must be 3-16 characters'
	elif (checkResult == 5):
		return 'password can only contain letters, numbers, _, !, ?, and - and must be 8-24 characters'

def logout(data):
	users.update(delete('token'), User.username == data['username'])

@route('/account', method='POST')
def actionSelect():
	action = (dict(request.query.decode()))['action']
	if (action == 'signup'):
		return signup(json.loads(request.body.read()))
	elif (action == 'login'):
		return login(json.loads(request.body.read()))
	elif (action == 'logout'):
		return logout(json.loads(request.body.read()))

@route('/account', method='GET')
def getAccount():
	authHeader = json.loads(request.headers.get('auth'))
	username = authHeader['username']
	token = int(authHeader['token'])
	if is_auth(username, token):
		return users.get(User.username == username)
	else:
		return HTTPResponse(status=401)

@route('/qote', method='POST')
def newNote():
	authHeader = json.loads(request.headers.get('auth'))
	username = authHeader['username']
	token = int(authHeader['token'])
	if is_auth(username, token):
		notes.insert({'title': '', 'body': '', 'user_id': users.get(User.username == username).doc_id, 'noteNum': ((notes.count(Note.user_id == ((users.get(User.username == username)).doc_id))))})
	else:
		return HTTPResponse(status=401)

@route('/qote', method='PUT')
def editNote():
	authHeader = json.loads(request.headers.get('auth'))
	username = authHeader['username']
	token = int(authHeader['token'])
	if is_auth(username, token):
		value = int((dict(request.query.decode()))['val'])
		data = json.loads(request.body.read())
		notes.update(set('title', data['title']), (Note.user_id == (users.get(User.username == username).doc_id)) & (Note.noteNum == value))
		notes.update(set('body', data['body']), (Note.user_id == (users.get(User.username == username).doc_id)) & (Note.noteNum == value))
	else:
		return HTTPResponse(status=401)

@route('/qote', method='GET')
def getNotes():
	authHeader = json.loads(request.headers.get('auth'))
	username = authHeader['username']
	token = int(authHeader['token'])
	if is_auth(username, token):
		notesDict = {}
		for x in range(notes.count(Note.user_id == (users.get(User.username == username).doc_id))):
			print(x)
			notesDict[str(x)] = {'title': notes.get(Note.noteNum == x)['title'], 'body': notes.get(Note.noteNum == x)['body']}
		return json.dumps(notesDict)
	else:
		return HTTPResponse(status=401)

@route('/qote', method='DELETE')
def deleteNote():
	authHeader = json.loads(request.headers.get('auth'))
	username = authHeader['username']
	token = int(authHeader['token'])
	if is_auth(username, token):
		value = int((dict(request.query.decode()))['val'])
		notes.remove((Note.user_id == (users.get(User.username == username).doc_id)) & (Note.noteNum == value))
		for i in range((notes.count(Note.user_id == (users.get(User.username == username).doc_id))) - value):
			notes.update(set('noteNum', value + i), (Note.user_id == (users.get(User.username == username).doc_id)) & (Note.noteNum == value + i + 1))
		#notes.remove(Note.noteNum == value)
	else:
		return HTTPResponse(status=401)

run(host='localhost', port=21012, debug=True)