from django.db import models
from django.contrib.auth.models import User

class Goal(models.Model):
    owner = models.ForeignKey(User, to_field='username', on_delete=models.CASCADE)
    name = models.CharField(max_length=20)
    description = models.CharField(max_length=200)
    class Meta():
        unique_together = ['owner', 'name']