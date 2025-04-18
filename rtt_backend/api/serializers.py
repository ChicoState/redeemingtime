from rest_framework import serializers
from django.contrib.auth.models import User
from api import models

GOAL_STATS = ['name', 'description', 'timeCost', 'weekday', 'completed', 'tag']

class GoalWriteSerializer(serializers.ModelSerializer):
    class Meta():
        model = models.Goal
        fields = ['owner'] + GOAL_STATS

class GoalReadSerializer(serializers.ModelSerializer):
    class Meta():
        model = models.Goal
        fields = GOAL_STATS

class UserSerializer(serializers.ModelSerializer):
    class Meta():
        model = User
        fields = ['username', 'password']