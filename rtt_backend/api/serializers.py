from rest_framework import serializers
from django.contrib.auth.models import User
from api import models

class GoalSerializer(serializers.ModelSerializer):
    class Meta():
        model = models.Goal

class UserSerializer(serializers.ModelSerializer):
    class Meta():
        model = User
        fields = ['username', 'password']