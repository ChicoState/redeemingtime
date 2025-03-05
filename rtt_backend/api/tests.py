from django.test import TestCase
from django import http
from api.models import ClientData
import json

# We want to verify...
#   A: ...that the server gives the correct responses to different types of requests.
#   B: ...that the database doesn't add or not add entries inappropriately.
#   C: ...that the data sent back is correct.
#   D: ...that last request time is different per saving of that field.
class RequestTestCase(TestCase):
    def test_get(self):
        # There's No Website
        response = self.client.get('/')
        self.assertEqual(response.status_code, 403)
        self.assertEqual(len(ClientData.objects.all()), 0)
    def test_emptyPost(self):
        # No Data in Post
        response = self.client.post('/')
        self.assertEqual(response.status_code, 406)
        self.assertEqual(len(ClientData.objects.all()), 0)
    def test_gibberishPost(self):
        # Data in Post is Garbage
        response = self.client.post('/', {'asdcawwf':'ebfwhwqiubfyfbgeiwfew'})
        self.assertEqual(response.status_code, 406)
        self.assertEqual(len(ClientData.objects.all()), 0)
    def test_emptyJSONPost(self):
        # Json Data in Post is Empty
        response = self.client.post('/', {}, content_type='application/json')
        self.assertEqual(response.status_code, 422)
        self.assertEqual(len(ClientData.objects.all()), 0)
    def test_gibberishJSONPost(self):
        # Json Data in Post is Garbage
        response = self.client.post('/', {'ababa':'babab'}, content_type='application/json')
        self.assertEqual(response.status_code, 422)
        self.assertEqual(len(ClientData.objects.all()), 0)
    def test_gibberishNeedsJSONPost(self):
        # Needs in Post is Garbage
        response = self.client.post('/', {'Needs':'babab'}, content_type='application/json')
        self.assertEqual(response.status_code, 422)
        self.assertEqual(len(ClientData.objects.all()), 0)
    def test_newUserJSONPost(self):
        # This will occur when a valid need is sent without ANY credentials, indicating a new entity.
        response = self.client.post('/', {'Needs':'Schedule'}, content_type='application/json')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(ClientData.objects.all()), 1)
        resJson = json.loads(response.content)
        data = resJson['Data']
        self.assertTrue('Sunday' in data)
        self.assertTrue('Monday' in data)
        self.assertTrue('Tuesday' in data)
        self.assertTrue('Wednesday' in data)
        self.assertTrue('Thursday' in data)
        self.assertTrue('Friday' in data)
        self.assertTrue('Saturday' in data)
        credentials = resJson['Credentials']
        self.assertEqual(len(credentials['User']), ClientData.CRED_LENGTH)
        self.assertTrue('Saturday' in data)
    def test_incompleteUserJSONPostOne(self):
        # No Password Provided in Credentials
        first = self.client.post('/', {'Needs':'Schedule'}, content_type='application/json')
        user = json.loads(first.content)['Credentials']['User']
        response = self.client.post('/', {'Needs':'Schedule', 'User':user}, content_type='application/json')
        self.assertEqual(response.status_code, 401)
        self.assertEqual(len(ClientData.objects.all()), 1)
    def test_incompleteUserJSONPostTwo(self):
        # No Username Provided in Credentials
        first = self.client.post('/', {'Needs':'Schedule'}, content_type='application/json')
        pswd = json.loads(first.content)['Credentials']['Pass']
        response = self.client.post('/', {'Needs':'Schedule', 'Pass':pswd}, content_type='application/json')
        self.assertEqual(response.status_code, 401)
        self.assertEqual(len(ClientData.objects.all()), 1)
    def test_badUserJSONPostOne(self):
        # Bad Credentials
        self.client.post('/', {'Needs':'Schedule'}, content_type='application/json')
        response = self.client.post('/', {'Needs':'Schedule', 'User':'Gibberish', 'Pass':'Gibberish'}, content_type='application/json')
        self.assertEqual(response.status_code, 401)
        self.assertEqual(len(ClientData.objects.all()), 1)
    def test_badUserJSONPostTwo(self):
        # Bad Password
        first = self.client.post('/', {'Needs':'Schedule'}, content_type='application/json')
        user = json.loads(first.content)['Credentials']['User']
        response = self.client.post('/', {'Needs':'Schedule', 'User':user, 'Pass':'Gibberish'}, content_type='application/json')
        self.assertEqual(response.status_code, 401)
        self.assertEqual(len(ClientData.objects.all()), 1)
    def test_badUserJSONPostThree(self):
        # Bad Username
        first = self.client.post('/', {'Needs':'Schedule'}, content_type='application/json')
        pswd = json.loads(first.content)['Credentials']['Pass']
        response = self.client.post('/', {'Needs':'Schedule', 'User':'Gibberish', 'Pass':pswd}, content_type='application/json')
        self.assertEqual(response.status_code, 401)
        self.assertEqual(len(ClientData.objects.all()), 1)
    def test_existingUserBadJSONPost(self):
        # Good Credentials, Bad Command
        first = self.client.post('/', {'Needs':'Schedule'}, content_type='application/json')
        user = json.loads(first.content)['Credentials']['User']
        pswd = json.loads(first.content)['Credentials']['Pass']
        current = ClientData.objects.filter(username=user)[0]
        starttime = current.lastRequest
        response = self.client.post('/', {'Needs':'desdefeas', 'User':user, 'Pass':pswd}, content_type='application/json')
        self.assertEqual(response.status_code, 422)
        current = ClientData.objects.filter(username=user)[0]
        self.assertNotEqual(starttime, current.lastRequest)
        self.assertEqual(len(ClientData.objects.all()), 1)
    def test_existingUserGoodJSONPost(self):
        # Good Credentials, Good Command, Returning User
        first = self.client.post('/', {'Needs':'Schedule'}, content_type='application/json')
        user = json.loads(first.content)['Credentials']['User']
        pswd = json.loads(first.content)['Credentials']['Pass']
        current = ClientData.objects.filter(username=user)[0]
        starttime = current.lastRequest
        response = self.client.post('/', {'Needs':'Schedule', 'User':user, 'Pass':pswd}, content_type='application/json')
        self.assertEqual(response.status_code, 200)
        resJson = json.loads(response.content)
        self.assertTrue('Credentials' not in resJson)
        self.assertTrue('User' not in resJson)
        self.assertTrue('Pass' not in resJson)
        data = resJson['Data']
        self.assertTrue('Sunday' in data)
        self.assertTrue('Monday' in data)
        self.assertTrue('Tuesday' in data)
        self.assertTrue('Wednesday' in data)
        self.assertTrue('Thursday' in data)
        self.assertTrue('Friday' in data)
        self.assertTrue('Saturday' in data)
        current = ClientData.objects.filter(username=user)[0]
        self.assertNotEqual(starttime, current.lastRequest)
        self.assertEqual(len(ClientData.objects.all()), 1)