from api.serializers import UserSerializer, GoalWriteSerializer, GoalReadSerializer
from rest_framework import status, viewsets, views
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.contrib.auth.models import User
from api.models import Goal, FriendTree

class UserView(views.APIView):
    permission_classes = [ AllowAny ]
    serializer_class = UserSerializer
    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            user.set_password(user.password)
            user.save()
            friends = FriendTree()
            friends.root = user
            friends.save()
            return Response(status=status.HTTP_200_OK)
        return Response(status=status.HTTP_406_NOT_ACCEPTABLE)

class GoalViews(viewsets.ModelViewSet):
    queryset = Goal.objects.all()
    serializer_class = GoalReadSerializer
    def create(self, request):
        serializer_class = GoalWriteSerializer
        completed_data = request.data
        completed_data['owner'] = request.user
        serializer = self.serializer_class(data=completed_data)
        if serializer.is_valid():
            goal = serializer.save(**completed_data)
            goal.save()
            return Response(status=status.HTTP_200_OK)
        return Response(status=status.HTTP_406_NOT_ACCEPTABLE)
    def list(self, request):
        queryset = Goal.objects.filter(owner=request.user).filter()
        if len(queryset) == 0:
            return Response(status=status.HTTP_404_NOT_FOUND)
        else:
            return super().list(self, request)
    def destroy(self, request, pk):
        queryset = Goal.objects.filter(owner=request.user).filter()
        return super().destroy(self, request, pk)

class FriendView(views.APIView):
    def get(self, request):
        names = []
        friends = FriendTree.objects.get(root=request.user).leaves.iterator()
        for friend in friends:
            names += friend.username
        if len(names) == 0:
            return Response(status=status.HTTP_404_NOT_FOUND)
        return Response(data=names, status=status.HTTP_200_OK)
    def post(self, request):
        fro = FriendTree.objects.get(root=request.user)
        try:
            ask = request.data['username']
        except:
            return Response(status=status.HTTP_406_NOT_ACCEPTABLE)
        for friend in fro.leaves.iterator():
            if friend.username == ask:
                return Response(data="Friend is already added.")
        to = None
        try:
            to = User.objects.get(username=ask)
        except:
            return Response(status=status.HTTP_404_NOT_FOUND)
        to.user_leaves.add(fro)
        to.save()
        return Response(status=status.HTTP_200_OK)
    def delete(self, request):
        fro = FriendTree.objects.get(root=request.user)
        try:
            ask = request.data['username']
        except:
            return Response(status=status.HTTP_406_NOT_ACCEPTABLE)
        for friend in fro.leaves.iterator():
            if friend.username == ask:
                friend.user_leaves.remove(fro)
                friend.save()
                return Response(status=status.HTTP_200_OK)
        return Response(status=status.HTTP_404_NOT_FOUND)
        

