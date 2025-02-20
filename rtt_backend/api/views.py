from django.shortcuts import render
from django import http
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