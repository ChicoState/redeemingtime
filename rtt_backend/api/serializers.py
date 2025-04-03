from rest_framework import serializers
from django.contrib.auth.models import User
from api import models

class GoalWriteSerializer(serializers.ModelSerializer):
    class Meta():
        model = models.Goal
        fields = ['owner', 'name', 'description']

class GoalReadSerializer(serializers.ModelSerializer):
    class Meta():
        model = models.Goal
        fields = ['name', 'description']

class UserSerializer(serializers.ModelSerializer):
    class Meta():
        model = User
        fields = ['username', 'password']