from django.db import models
from django.contrib.auth.models import User
from django.core import validators

WEEK_LENGTH = 7

class weekStringValidator(validators.MinLengthValidator):
    def __init__(self):
        super.__init__(self, WEEK_LENGTH)
    def validate(self, string):
        super.validate(self, string)
        for char in string:
            if not(char == '.' or char == '#'):
                raise validators.ValidationError

HEADER_LENGTH = 50

class Goal(models.Model):
    owner = models.ForeignKey(User, to_field='username', on_delete=models.CASCADE)
    name = models.CharField(max_length=HEADER_LENGTH)
    description = models.CharField(max_length=HEADER_LENGTH*5)
    timeCost = models.IntegerField() # In Minutes
    weekday = models.CharField(max_length=WEEK_LENGTH, validators=[weekStringValidator]) # Should be seven characters selected from # for a selected weekday and . for an unselected one.
    tag = models.CharField(max_length=HEADER_LENGTH)
    class Meta():
        unique_together = ['owner', 'name', 'weekday']

# Note that this is one way. Treat one way only as a request to the recipient and treat both ways as a full friendship in frontend.
class FriendTree(models.Model):
    root = models.OneToOneField(User, to_field='username', related_name="user_root", on_delete=models.DO_NOTHING)
    leaves = models.ManyToManyField(to=User, related_name="user_leaves")