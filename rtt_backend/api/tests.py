from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.test import TestCase
from django import http
import json

# We want to verify...
#   A: ...that the server gives the correct responses to different types of requests.
#   B: ...that the database doesn't add or not add entries inappropriately.
#   C: ...that the data sent back is correct.
class RequestTestCase(TestCase):
    # Testing Credentials
    USER='Jim'
    PASS='Banana'
    def basic(self, expectedRes, expectedDB, reqDict):
        response = self.client.post('/', reqDict, content_type='application/json')
        self.assertEqual(response.status_code, expectedRes)
        self.assertEqual(len(User.objects.all()), expectedDB)
        user = authenticate(username=RequestTestCase.USER, password=RequestTestCase.PASS)
        if (expectedDB == 0):
            self.assertEqual(user, None)
        else:
            self.assertNotEqual(user, None)
    def authenticated(self, expectedRes, reqDict):
        self.client.post('/', {'Needs':'Register', 'Username': RequestTestCase.USER, 'Password': RequestTestCase.PASS}, content_type='application/json')
        response = self.client.post('/', reqDict, content_type='application/json')
        self.assertEqual(response.status_code, expectedRes)
    def test_get(self):
        # There's No Website
        response = self.client.get('/')
        self.assertEqual(response.status_code, 403)
        self.assertEqual(len(User.objects.all()), 0)
    def test_emptyPost(self):
        # No Data in Post
        response = self.client.post('/')
        self.assertEqual(response.status_code, 406)
        self.assertEqual(len(User.objects.all()), 0)
    def test_gibberishPost(self):
        # Data in Post is Garbage
        response = self.client.post('/', {'asdcawwf':'ebfwhwqiubfyfbgeiwfew'})
        self.assertEqual(response.status_code, 406)
        self.assertEqual(len(User.objects.all()), 0)
    def test_emptyJSONPost(self):
        # Json Data in Post is Empty
        self.basic(422, 0, {})
    def test_gibberishJSONPost(self):
        # Json Data in Post is Garbage
        self.basic(422, 0, {'ababa':'babab'})
    def test_gibberishNeedsJSONPost(self):
        # Needs in Post is Garbage. Should hit that it's not authenticated.
        self.basic(401, 0, {'Needs':'babab'})
    def test_badNewUserJSONPost1(self):
        # Incomplete Registration
        self.basic(422, 0, {'Needs':'Register'})
    def test_badNewUserJSONPost2(self):
        # Incomplete Registration
        self.basic(422, 0, {'Needs':'Register', 'Username': RequestTestCase.USER})
    def test_badNewUserJSONPost3(self):
        # Incomplete Registration
        self.basic(422, 0, {'Needs':'Register', 'Password': RequestTestCase.PASS})
    def test_goodNewUserJSONPost(self):
        # Successful Registration
        self.basic(200, 1, {'Needs':'Register', 'Username': RequestTestCase.USER, 'Password': RequestTestCase.PASS})
    def test_incompleteUserJSONPostOne(self):
        # No Credentials in Authentication
        self.authenticated(401, {'Needs':'Test', 'Input': {}})
    def test_incompleteUserJSONPostTwo(self):
        # No Password Provided in Credentials
        self.authenticated(401, {'Needs':'Test', 'Input': {}, 'Username': RequestTestCase.USER})
    def test_incompleteUserJSONPostThree(self):
        # No Username Provided in Credentials
        self.authenticated(401, {'Needs':'Test', 'Input': {}, 'Password': RequestTestCase.PASS})
    def test_badUserJSONPostOne(self):
        # Bad Credentials
        self.authenticated(401, {'Needs':'Test', 'Input': {}, 'Username': 'Gibberish', 'Password':'Gibberish'})
    def test_badUserJSONPostTwo(self):
        # Bad Password
        self.authenticated(401, {'Needs':'Test', 'Input': {}, 'Username': 'Gibberish', 'Password': RequestTestCase.PASS})
    def test_badUserJSONPostThree(self):
        # Bad Username
        self.authenticated(401, {'Needs':'Test', 'Input': {}, 'Username': RequestTestCase.USER, 'Password':'Gibberish'})
    def test_existingUserBadJSONPost(self):
        # Good Credentials, Bad Input
        self.authenticated(422, {'Needs':'Test', 'Username': RequestTestCase.USER, 'Password': RequestTestCase.PASS})
    def test_existingUserGoodJSONPostOne(self):
        # Good Credentials, Bad Input
        self.authenticated(200, {'Needs':'Test', 'Input': 'Something', 'Username': RequestTestCase.USER, 'Password': RequestTestCase.PASS})
    def test_existingUserGoodJSONPostTwo(self):
        # Good Credentials, Good Input
        self.authenticated(200, {'Needs':'Test', 'Input': {'a': 'b'}, 'Username': RequestTestCase.USER, 'Password': RequestTestCase.PASS})