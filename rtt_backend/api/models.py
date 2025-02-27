from django.db import models
from django.contrib.auth.models import User

class ClientData(User):
    CRED_LENGTH = 128
    lastRequest = models.IntegerField()