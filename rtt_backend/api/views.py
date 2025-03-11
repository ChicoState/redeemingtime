from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django import http
import time
import secrets
import json

# Simple Status Page

def _stat(sc):
    res = http.HttpResponse()
    res.status_code = sc
    res.content = '<!DOCTYPE html>\n<html>\n   <head>\n</head>\n<body>\n   <h1>' + str(sc) + ' ' + res.reason_phrase + '</h1>\n</body>\n</html>'
    return res

# Actual Inner Task Functions

def _schedule(input):
    return _stat(200)

# Select task based on needs.

def _task(dictIn):
    # All tasks can assume there is 'Input' in dictIn.
    # What They Want
    needs = dictIn['Needs']
    input = dictIn['Input']
    # Output goes here.
    dictOut = {}
    # Select task based on need.
    if (needs == 'Test'):
        return _stat(200)
    elif (needs == 'Schedule'):
        # Wants to Store Schedule
        dictOut = _schedule(input)
    else:
        # I don't know what you want.
        return _stat(422)
    # Successful
    return http.JsonResponse(dictOut)

# New User

def _newUser(dictIn):
    if 'Username' not in dictIn or 'Password' not in dictIn: # Incomplete Credentials
        return _stat(422)
    # Fill out the credentials portion with the new user and password.
    inst = User()
    inst.username=dictIn['Username']
    inst.set_password(dictIn['Password'])
    inst.save()
    return _stat(200)

# Authenticate from JSON.

def _verify(dictIn):
    if 'Username' not in dictIn or 'Password' not in dictIn: # Incomplete Credentials
        return None
    return authenticate(username=dictIn['Username'], password=dictIn['Password']) # Authenticate Complete Credentials using Django

# Authenticate existing user and do task or create new user.

def _ingest(dictIn):
    # Did they specify their want?
    if 'Needs' not in dictIn:
        return _stat(422)
    # Get the want.
    needs = dictIn['Needs']
    # Registration
    if (needs == 'Register'):
        return _newUser(dictIn)
    # The remaining ones need authentication.
    user = _verify(dictIn)
    # Bad Credentials
    if (not user):
        return _stat(401)
    # Good Credentials
    # We will need an input to do a task, though.
    if ('Input' not in dictIn):
        return _stat(422)
    # Select the task based on needs.
    return _task(dictIn)

# Invoke the API as a view.
# REMOVE EXEMPTION FOR PRODUCTION #

from django.views.decorators.csrf import csrf_exempt
@csrf_exempt
def invoke(request):
    # Must POST.
    if (request.method == 'POST'):
        try:
            # See if JSON was provided.
            dictIn = json.loads(request.body)
            # Request is valid json. Give it to _ingest.
            return _ingest(dictIn)
        # Request does not have json.
        except json.decoder.JSONDecodeError:
            return _stat(406)
    # Only POST.
    else:
        return _stat(403)
    
