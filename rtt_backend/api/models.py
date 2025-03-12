from django.db import models
from django.contrib.auth.models import User

class Day(models.Model):
    morning = models.CharField
    noon = models.CharField
    evening = models.CharField

class Schedule(models.Model):
    username = models.ForeignKey(User, on_delete=models.CASCADE)
    sunday = models.ForeignKey(Day, related_name="_su", blank=True, default="", on_delete=models.SET_DEFAULT)
    monday = models.ForeignKey(Day, related_name="_m", blank=True, default="", on_delete=models.SET_DEFAULT)
    tuesday = models.ForeignKey(Day, related_name="_tu", blank=True, default="", on_delete=models.SET_DEFAULT)
    wednesday = models.ForeignKey(Day, related_name="_w", blank=True, default="", on_delete=models.SET_DEFAULT)
    thursday = models.ForeignKey(Day, related_name="_th", blank=True, default="", on_delete=models.SET_DEFAULT)
    friday = models.ForeignKey(Day, related_name="_f", blank=True, default="", on_delete=models.SET_DEFAULT)
    saturday = models.ForeignKey(Day, related_name="_sa", blank=True, default="", on_delete=models.SET_DEFAULT)


