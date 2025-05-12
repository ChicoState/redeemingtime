from rest_framework.test import APIRequestFactory, force_authenticate
from api.views import UserView, GoalViews, FriendView
from django.contrib.auth.models import User
from django.test import TestCase
from django import http

def authedReq(request, tester):
    UserView.as_view()(tester.post('/register/', {"username":"trevor", "password":"12345"}))
    force_authenticate(request, user=User.objects.get(username="trevor"))
    return request

class RegisterTestCase(TestCase):
    tester = APIRequestFactory()
    def test_Register_Good(self):
        res = UserView.as_view()(self.tester.post('/register/', {"username":"trevor", "password":"12345"}))
        self.assertEqual(res.status_code, 200)
    def test_Register_Empty(self):
        res = UserView.as_view()(self.tester.post('/register/'))
        self.assertEqual(res.status_code, 406)
    def test_Register_Bad(self):
        res = UserView.as_view()(self.tester.post('/register/', {"usernarm":"qwdn", "posswird":"vase"}))
        self.assertEqual(res.status_code, 406)

class GoalTestCase(TestCase):
    tester = APIRequestFactory()
    def test_Goal_Unauthorized(self):
        res = GoalViews.as_view({'post': 'create'})(self.tester.post('/goals/'))
        self.assertEqual(res.status_code, 401)
    def test_GoalCreate_Empty(self):
        res = GoalViews.as_view({'post': 'create'})(authedReq(self.tester.post('/goals/'), self.tester))
        self.assertEqual(res.status_code, 406)
    def test_GoalCreate_Bad_1(self):
        res = GoalViews.as_view({'post': 'create'})(authedReq(self.tester.post('/goals/', {"name": "hash", "deskjob": "qewdip"}), self.tester))
        self.assertEqual(res.status_code, 406)
    def test_GoalCreate_Bad_2(self):
        res = GoalViews.as_view({'post': 'create'})(authedReq(self.tester.post('/goals/', {"name": "hash", "description": "qewdip"}), self.tester))
        self.assertEqual(res.status_code, 406)
    def test_GoalCreate_Good(self):
        res = GoalViews.as_view({'post': 'create'})(authedReq(self.tester.post('/goals/', {"name": "hash", "description": "qewdip", "timeCost": 100, "weekday": "...#..."}), self.tester))
        self.assertEqual(res.status_code, 200)
    def test_GoalList_Empty(self):
        res = GoalViews.as_view({'get': 'list'})(authedReq(self.tester.get('/goals/'), self.tester))
        self.assertEqual(res.status_code, 404)
    def test_GoalList_Good(self):
        GoalViews.as_view({'post': 'create'})(authedReq(self.tester.post('/goals/', {"name": "hash", "description": "qewdip", "timeCost": 100, "weekday": "...#..."}), self.tester))
        res = GoalViews.as_view({'get': 'list'})(authedReq(self.tester.get('/goals/'), self.tester))
        self.assertEqual(res.status_code, 200)
    def test_GoalDelete(self):
        GoalViews.as_view({'post': 'create'})(authedReq(self.tester.post('/goals/', {"name": "hash", "description": "qewdip", "timeCost": 100, "weekday": "...#..."}), self.tester))
        GoalViews.as_view({'delete': 'destroy'})(authedReq(self.tester.delete('/goals/hash'), self.tester))
        res = GoalViews.as_view({'get': 'list'})(authedReq(self.tester.get('/goals/'), self.tester))
        self.assertEqual(res.status_code, 404)

class FriendTestCase(TestCase):
    tester = APIRequestFactory()
    def test_FriendPost_Empty(self):
        res = FriendView.as_view()(authedReq(self.tester.post('/friends/'), self.tester))
        self.assertEqual(res.status_code, 406)
    def test_FriendPost_NotFound(self):
        res = FriendView.as_view()(authedReq(self.tester.post('/friends/', {'username': 'eqqdf'}), self.tester))
        self.assertEqual(res.status_code, 404)
    def test_FriendPost_Good(self):
        UserView.as_view()(self.tester.post('/register/', {"username":"rovert", "password":"12345"}))
        res = FriendView.as_view()(authedReq(self.tester.post('/friends/', {'username': 'rovert'}), self.tester))
        self.assertEqual(res.status_code, 200)
    def test_FriendsGet_Empty(self):
        res = FriendView.as_view()(authedReq(self.tester.get('/friends/'), self.tester))
        self.assertEqual(res.status_code, 404)
    def test_FriendsGet_Good(self):
        UserView.as_view()(self.tester.post('/register/', {"username":"rovert", "password":"12345"}))
        FriendView.as_view()(authedReq(self.tester.post('/friends/', {'username': 'rovert'}), self.tester))
        res = FriendView.as_view()(authedReq(self.tester.get('/friends/'), self.tester))
        self.assertEqual(res.status_code, 200)
    def test_FriendsDelete(self):
        UserView.as_view()(self.tester.post('/register/', {"username":"rovert", "password":"12345"}))
        FriendView.as_view()(authedReq(self.tester.post('/friends/', {'username': 'rovert'}), self.tester))
        FriendView.as_view()(authedReq(self.tester.delete('/friends/', {"username":"rovert"}), self.tester))
        res = FriendView.as_view()(authedReq(self.tester.get('/friends/'), self.tester))
        self.assertEqual(res.status_code, 404)