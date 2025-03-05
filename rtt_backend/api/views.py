from api.models import ClientData
from django import http
import time
import secrets
import json

# Simple Error Page

def _err(sc):
    res = http.HttpResponse()
    res.status_code = sc
    res.content = '<!DOCTYPE html>\n<html>\n   <head>\n</head>\n<body>\n   <h1>' + str(sc) + ' ' + res.reason_phrase + '</h1>\n</body>\n</html>'
    return res

# Tasks and Task Parser

def _schedule():
    return {'Sunday': '', 'Monday': '', 'Tuesday': '', 'Wednesday': '', 'Thursday': '', 'Friday': '', 'Saturday': ''}

def _bad():
    return {'Bad':'Request'}

def _task(cwant):
    if (cwant == 'Schedule'):
        # They want a schedule.
        return _schedule()
    else:
        # I don't know what you want.
        return _bad()

# View as a Whole
# REMOVE EXEMPTION FOR PRODUCTION #
from django.views.decorators.csrf import csrf_exempt
@csrf_exempt
def invoke(request):
    dictOut = {} # Whole response
    dictMain = {} # Answer to our question
    dictCrd = {} # Credentials if they are given back.
    inst: ClientData
    # Must POST.
    if (request.method == 'POST'):
        try:
            # I/O Dictionaries
            dictIn = json.loads(request.body)
            # Request is valid json. Now we need to authenticate.
            if 'User' not in dictIn and 'Pass' not in dictIn: # New User
                # Make unique username.
                lng = -1
                while (lng != 0): 
                    nm = ''
                    for _ in range(ClientData.CRED_LENGTH):
                        nm += chr(65 + secrets.randbelow(26))
                        lng = len(ClientData.objects.filter(username=nm))
                # Make a passcode for this new client.
                raw = ''
                for _ in range(ClientData.CRED_LENGTH):
                    raw += chr(65 + secrets.randbelow(26))
                # Fill out the credentials portion with the new user and password.
                dictCrd['User'] = nm
                dictCrd['Pass'] = raw
                # Only actually create a new user if the request is good.
            else: # Authenticate existing user.
                if 'User' not in dictIn or 'Pass' not in dictIn: # Incomplete Credentials
                    return _err(401)
                instF = ClientData.objects.filter(username=dictIn['User'])
                if (len(instF) == 0): # User is incorrect.
                    return _err(401)
                inst = instF[0]
                if (inst.check_password(dictIn['Pass']) != True): # Password is incorrect.
                    return _err(401)
		        # Record that this user has done an action just now.
                inst.lastRequest = time.time_ns()
                inst.save(force_update=True)
            # Do we have a 'Needs' field?
            if 'Needs' not in dictIn:
                return _err(422)
            # What does the client want?
            dictMain = _task(dictIn['Needs'])
            if (dictMain == _bad()):
                return _err(422)
        # Request is not in json.
        except json.decoder.JSONDecodeError:
            return _err(406)
    # Only POST.
    else:
        return _err(403)
    # Successful! Now respond (and, if needed, register the new user)!
    if (dictCrd != {}):
        inst = ClientData()
        inst.username=nm
        inst.set_password(raw)
        inst.lastRequest = time.time_ns()
        inst.save()
        dictOut['Credentials'] = dictCrd
    if (dictMain != {}):
        dictOut['Data'] = dictMain
    # If the time of the last request gets too far out of date, we should cull the user.
    # If another request is given extremely quickly, it should probably be denied.
    return http.JsonResponse(dictOut)
