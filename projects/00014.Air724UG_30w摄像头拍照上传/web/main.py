#!/usr/bin/python3
# -*- coding: UTF-8 -*-

## 需要使用到的库
import os, struct, sys, logging, subprocess, shutil, hashlib, requests
import uuid
from datetime import datetime

# web相关
import bottle
from bottle import request, post, static_file, response, get, abort, HTTPResponse

@post("/api/upload/jpg")
def upload():
    dt = datetime.now()
    path = dt.strftime("%Y-%m-%d_%H%M%S") + ".jpg"
    with open("data/" + path, "wb") as f :
        f.write(request.body.read())

@post("/api/upload/form")
def upload():
    dt = datetime.now()
    path = dt.strftime("data/%Y-%m-%d_%H%M%S") + ".jpg"
    if "filename" in request.files :
        f = request.files["filename"]
        f.save(path)

bottle.run(host="0.0.0.0", port=9000)
