from django.db import models
from django.contrib.auth.models import User

HEADER_LENGTH = 50

class Goal(models.Model):
    owner = models.ForeignKey(User, to_field='username', on_delete=models.CASCADE)
    name = models.CharField(primary_key=True, max_length=HEADER_LENGTH)
    description = models.CharField(max_length=HEADER_LENGTH*5)
    timeCost = models.IntegerField() # In Minutes
    weekday = models.CharField() # Should be seven characters selected from # for a selected weekday and . for an unselected one.
    completed = models.BooleanField(default=False)
    tag = models.CharField(max_length=HEADER_LENGTH, null=True, default=None)
    class Meta():
        unique_together = ['owner', 'name', 'weekday']

# Note that this is one way. Treat one way only as a request to the recipient and treat both ways as a full friendship in frontend.
class FriendTree(models.Model):
    root = models.OneToOneField(User, to_field='username', related_name="user_root", on_delete=models.DO_NOTHING)
    leaves = models.ManyToManyField(to=User, related_name="user_leaves")