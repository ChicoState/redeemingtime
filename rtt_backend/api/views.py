from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status, viewsets, views
from api.serializers import UserSerializer, GoalWriteSerializer, GoalReadSerializer
from api.models import Goal

class UserView(views.APIView):
    permission_classes = [ AllowAny ]
    serializer_class = UserSerializer
    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            user.set_password(user.password)
            user.save()
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
        

