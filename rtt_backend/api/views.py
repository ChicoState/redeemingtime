from django.contrib.auth.models import User
from django import http
import secrets
import json

def err(sc):
    res = http.HttpResponse()
    res.status_code = sc
    res.content = '<!DOCTYPE html>\n<html>\n   <head>\n</head>\n<body>\n   <h1>' + str(sc) + ' ' + res.reason_phrase + '</h1>\n</body>\n</html>'
    return res

# REMOVE EXEMPTION FOR PRODUCTION #
from django.views.decorators.csrf import csrf_exempt
@csrf_exempt
def invoke(request):
    if (request.method == 'POST'):
        try:
            dictIn = json.loads(request.body)
            if 'Needs' not in dictIn:
                return err(422)
            needs = dictIn['Needs']
            dictOut = {}
            if (needs == 'Register'):
                lng = -1
                while (lng != 0): 
                    nm = ''
                    for _ in range(128):
                        nm += chr(65 + secrets.randbelow(26))
                    lng = len(User.objects.filter(username=nm))
                raw = ''
                for _ in range(100):
                    raw += chr(65 + secrets.randbelow(26))
                newClient = User()
                newClient.username=nm
                newClient.set_password(raw)
                newClient.save()
                dictOut['User'] = nm
                dictOut['Pass'] = raw
            else:
                if 'User' not in dictIn:
                    return err(401)
                inst = User.objects.filter(username=dictIn['User'])
                if (len(inst) == 0):
                    return err(401)
                if inst[0].check_password(dictIn['Pass']) != True:
                    return err(401)
                if (needs == 'Schedule'):
                    dictOut['Sunday'] = '<Activity>'
                    dictOut['Monday'] = '<Activity>'
                    dictOut['Tuesday'] = '<Activity>'
                    dictOut['Wednesday'] = '<Activity>'
                    dictOut['Thursday'] = '<Activity>'
                    dictOut['Friday'] = '<Activity>'
                    dictOut['Saturday'] = '<Activity>'
                else:
                    return err(422)
            return http.JsonResponse(dictOut)
        except json.decoder.JSONDecodeError:
            return err(406)
    else:
        return err(403)