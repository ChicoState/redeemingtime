from django.shortcuts import render

def invoke(request):
    return render(request, 'response.json.template')