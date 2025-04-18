from django.db import models
from django.contrib.auth.models import User

HEADER_LENGTH = 50

class Goal(models.Model):
    WEEKDAY_VALUES = {0 : 'Sunday', 1 : 'Monday', 2 : 'Tuesday', 3 : 'Wednesday', 4 : 'Thursday', 5 : 'Friday', 6 : 'Saturday'}
    owner = models.ForeignKey(User, to_field='username', on_delete=models.CASCADE)
    name = models.CharField(max_length=HEADER_LENGTH)
    description = models.CharField(max_length=HEADER_LENGTH*5)
    timeCost = models.IntegerField() # In Minutes
    weekday = models.IntegerField(choices=WEEKDAY_VALUES)
    completed = models.BooleanField()
    tag = models.CharField(max_length=HEADER_LENGTH)
    class Meta():
        unique_together = ['owner', 'name', 'weekday']