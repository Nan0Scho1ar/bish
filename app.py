#!/bin/python
# APP.PY: Flask server to serve html or plain text depending on client's useragent string
# Author: Nan0Scho1ar (Christopher Mackinga)
# Created: 21/01/2021
# License: MIT License
# Requires flask, pygments, markdown

import sys
import os
import markdown
import markdown.extensions.fenced_code
import markdown.extensions.codehilite
from flask import Flask, request, make_response, render_template, abort
from pygments.formatters import HtmlFormatter

PLAIN_TEXT_AGENTS = [ "curl", "httpie", "lwp-request", "wget", "python-requests", "openbsd ftp", "powershell", "fetch" ]
INDEX_PATH = "./README.md"
app = Flask(__name__)

def to_html(lines):
    md = markdown.markdown(lines, extensions=["fenced_code", "codehilite"])
    formatter = HtmlFormatter(style="monokai",full=True,cssclass="codehilite")
    css = "\nbody { background-color: #33363B; color: #CCCCCC;}\ntd.linenos pre { background-color: #AAAAAA; }"
    return "<style>" + formatter.get_style_defs() + css + "</style>" + md

def get_file_path(path, is_man):
    if is_man:
        if path == None:
            return "./man/README.md"
        elif os.path.isfile("./man/" + path):
            return "./man/" + path
        elif os.path.isfile("./man/" + path + ".md"):
            return "./man/" + path + ".md"
    else:
        if path == None:
            return INDEX_PATH
        elif os.path.isfile("./" + path):
            return "./" + path
        elif os.path.isfile("./" + path + ".sh"):
            return "./" + path + ".sh"
    return None

def try_get_lines(file_path):
    if file_path == None:
        return ""
    with open(file_path) as f:
        lines = f.read()
    return lines

def get_content(path, request, is_man, is_raw):
    file_path = get_file_path(path, is_man)
    lines = try_get_lines(file_path)
    user_agent = request.headers.get('User-Agent', '').lower()
    if any([x in user_agent for x in PLAIN_TEXT_AGENTS]):
        return "Error: file not found" if file_path == None else lines
    if file_path == None:
        abort(404)
    if is_raw:
        resp = make_response(lines)
        resp.mimetype = 'text/plain'
        return resp
    if file_path == INDEX_PATH or is_man:
        return to_html(lines)
    #This must be the base url so display the man above the file
    man_path = get_file_path(path, True)
    man_lines = try_get_lines(man_path)
    return to_html(man_lines + "\n##CODE:\n```\n" + lines + "\n```")

@app.route("/")
@app.route("/<path>")
def get_file(path=None):
    return get_content(path, request, False, False)

@app.route("/man/<path>")
def get_man(path=None):
    return get_content(path, request, True, False)

@app.route("/raw/<path>")
def get_raw(path=None):
    return get_content(path, request, False, True)

@app.route("/raw/man/<path>")
def get_raw_man(path=None):
    return get_content(path, request, True, True)

if __name__ == '__main__':
    app.run(host='0.0.0.0')
